import json
import logging
import os
import time
from typing import Any, Dict, List, Optional

import redis
import requests

logger = logging.getLogger(__name__)


def _clean_base_url(url: str) -> str:
    return (url or "").rstrip("/")


def _age_group(age: Optional[int]) -> str:
    if age is None:
        return "unknown"
    if age < 18:
        return "UNDER_18"
    if age <= 24:
        return "18_24"
    if age <= 34:
        return "25_34"
    if age <= 44:
        return "35_44"
    return "45_PLUS"


def _age_group_matches(product_group: Optional[str], customer_age: Optional[int]) -> bool:
    if not product_group or product_group.lower() in {"all", "any", "unisex"}:
        return True
    if customer_age is None:
        return False

    value = product_group.strip().upper().replace("-", "_")
    if value == _age_group(customer_age):
        return True

    if "_" in value:
        try:
            lo, hi = [int(x) for x in value.split("_", 1)]
            return lo <= customer_age <= hi
        except ValueError:
            return False

    if value.endswith("_PLUS") or value.endswith("+"):
        try:
            lo = int(value.replace("_PLUS", "").replace("+", ""))
            return customer_age >= lo
        except ValueError:
            return False

    return False


class ProductRecommender:
    """
    Edge-side recommendation adapter.

    The edge no longer owns a hard-coded catalog. It pulls product data from the
    cloud API, ranks anonymous visitors by face attributes, and delegates known
    customer recommendations to the cloud recommender when possible.
    """

    def __init__(self, branch_id: str):
        self.branch_id = branch_id
        self.cloud_api = _clean_base_url(os.getenv("CLOUD_API", "http://localhost:8000"))
        self.top_k = int(os.getenv("RECOMMENDATION_TOP_K", "5"))
        self.timeout = float(os.getenv("CLOUD_API_TIMEOUT", "30"))
        self.catalog_ttl = int(os.getenv("EDGE_PRODUCT_CACHE_TTL", "300"))
        self._catalog_cache: tuple[float, List[dict]] = (0.0, [])

        self.redis_client = None
        redis_url = os.getenv("REDIS_URL")
        if redis_url:
            try:
                self.redis_client = redis.from_url(redis_url, decode_responses=True)
            except Exception as exc:
                logger.warning("Redis cache disabled: %s", exc)

    def get_recommendations(
        self,
        face_attributes: Dict[str, Any],
        customer_id: Optional[str] = None,
        top_k: Optional[int] = None,
    ) -> List[Dict[str, Any]]:
        top_k = top_k or self.top_k

        if customer_id:
            cloud = self._get_cloud_customer_recommendations(customer_id, top_k)
            if cloud:
                return cloud

        catalog = self._load_product_catalog()
        return self._rank_catalog_for_attributes(catalog, face_attributes, top_k)

    def recommend_products(
        self,
        face_attributes: Dict[str, Any],
        customer_id: Optional[str] = None,
        top_k: Optional[int] = None,
    ) -> List[Dict[str, Any]]:
        return self.get_recommendations(face_attributes, customer_id, top_k)

    def _get_cloud_customer_recommendations(
        self, customer_id: str, top_k: int
    ) -> List[Dict[str, Any]]:
        cache_key = f"edge:recommend:{self.branch_id}:{customer_id}:{top_k}"
        cached = self._cache_get(cache_key)
        if cached is not None:
            return cached

        try:
            resp = requests.get(
                f"{self.cloud_api}/recommend",
                params={
                    "branch_id": self.branch_id,
                    "customer_id": customer_id,
                    "top_k": top_k,
                },
                timeout=min(self.timeout, 5.0),
            )
            resp.raise_for_status()
            data = resp.json() or []
            recommendations = [self._normalize_product(p, idx) for idx, p in enumerate(data)]
            self._cache_set(cache_key, recommendations, ttl=60)
            return recommendations
        except Exception as exc:
            logger.info("Cloud customer recommendations unavailable: %s", exc)
            return []

    def _load_product_catalog(self) -> List[dict]:
        now = time.time()
        cache_time, cached = self._catalog_cache
        if cached and now - cache_time < self.catalog_ttl:
            return cached

        redis_key = f"edge:products:{self.branch_id}"
        redis_cached = self._cache_get(redis_key)
        if redis_cached is not None:
            self._catalog_cache = (now, redis_cached)
            return redis_cached

        try:
            resp = requests.get(
                f"{self.cloud_api}/products",
                params={"limit": 500},
                timeout=min(self.timeout, 8.0),
            )
            resp.raise_for_status()
            products = resp.json() or []
        except Exception as exc:
            logger.warning("Could not load cloud products, using empty catalog: %s", exc)
            products = []

        normalized = [self._normalize_product(p, idx) for idx, p in enumerate(products)]
        self._catalog_cache = (now, normalized)
        self._cache_set(redis_key, normalized, ttl=self.catalog_ttl)
        return normalized

    def _rank_catalog_for_attributes(
        self, products: List[dict], attributes: Dict[str, Any], top_k: int
    ) -> List[Dict[str, Any]]:
        scored = []
        for idx, product in enumerate(products):
            score, reasons = self._score_product(product, attributes)
            if score <= 0:
                score = max(0.01, float(product.get("stock") or 0) / 1000.0)
            item = {
                **product,
                "score": round(score, 6),
                "reason": ", ".join(reasons) if reasons else "Sản phẩm đang có sẵn tại cửa hàng",
                "source": "edge_attribute_ranker",
            }
            scored.append((score, -idx, item))

        scored.sort(key=lambda x: (x[0], x[1]), reverse=True)
        return [item for _score, _idx, item in scored[:top_k]]

    def _score_product(self, product: Dict[str, Any], attributes: Dict[str, Any]) -> tuple[float, List[str]]:
        score = 0.0
        reasons: List[str] = []

        gender = str(
            attributes.get("gender")
            or attributes.get("gender_label")
            or ""
        ).lower()
        target_gender = str(product.get("target_gender") or "unisex").lower()
        if gender:
            if target_gender == gender:
                score += 0.45
                reasons.append("phù hợp giới tính")
            elif target_gender in {"unisex", "all", "any"}:
                score += 0.22
                reasons.append("phù hợp mọi khách hàng")

        age = attributes.get("age")
        try:
            age = int(age) if age is not None else None
        except (TypeError, ValueError):
            age = None
        if _age_group_matches(product.get("target_age_group"), age):
            score += 0.35
            reasons.append("phù hợp độ tuổi")

        emotion = str(
            attributes.get("emotion")
            or attributes.get("emotion_label")
            or ""
        ).lower()
        product_emotion = str(product.get("emotion") or "").lower()
        if emotion and product_emotion and product_emotion == emotion:
            score += 0.25
            reasons.append("phù hợp cảm xúc")

        if product.get("has_discount"):
            score += 0.12
            reasons.append("đang có ưu đãi")

        stock = int(product.get("stock") or 0)
        score += min(stock, 200) / 2000.0

        return score, reasons

    def _normalize_product(self, product: Dict[str, Any], idx: int) -> Dict[str, Any]:
        price = float(product.get("price") or 0)
        discount_price = product.get("discount_price")
        discount_price = float(discount_price) if discount_price is not None else None
        has_discount = bool(discount_price and price and discount_price < price)

        return {
            "id": product.get("id") or product.get("product_pk") or idx,
            "product_pk": product.get("product_pk") or product.get("id"),
            "product_id": product.get("product_id")
            or product.get("product_code")
            or str(product.get("id") or idx),
            "product_code": product.get("product_code")
            or product.get("product_id")
            or str(product.get("id") or idx),
            "product_name": product.get("product_name") or product.get("name") or "Sản phẩm",
            "name": product.get("name") or product.get("product_name") or "Sản phẩm",
            "category": product.get("category") or "Khác",
            "price": discount_price if has_discount else price,
            "original_price": price,
            "discount_price": discount_price,
            "discount_percent": product.get("discount_percent"),
            "has_discount": has_discount,
            "stock": int(product.get("branch_stock") or product.get("stock") or 0),
            "image_url": product.get("image_url"),
            "target_gender": product.get("target_gender") or "unisex",
            "target_age_group": product.get("target_age_group") or "all",
            "emotion": product.get("emotion") or "neutral",
            "usage_context": product.get("usage_context") or "",
        }

    def _cache_get(self, key: str):
        if not self.redis_client:
            return None
        try:
            raw = self.redis_client.get(key)
            return json.loads(raw) if raw else None
        except Exception as exc:
            logger.debug("Redis get failed for %s: %s", key, exc)
            return None

    def _cache_set(self, key: str, value: Any, ttl: int):
        if not self.redis_client:
            return
        try:
            self.redis_client.setex(key, ttl, json.dumps(value))
        except Exception as exc:
            logger.debug("Redis set failed for %s: %s", key, exc)

    def update_model(self, model_path: str):
        logger.info("Recommendation model update requested: %s", model_path)
