import random
import redis
import json
import os
from typing import List, Dict
import httpx

CLOUD_API = os.getenv("CLOUD_API", "http://localhost:8000")


async def fetch_cloud_recommendations(branch_id: str, customer_id: str, top_k: int = 5):
    url = f"{CLOUD_API}/api/recommend"
    params = {"branch_id": branch_id, "customer_id": customer_id, "top_k": top_k}
    async with httpx.AsyncClient(timeout=2.5) as client:
        r = await client.get(url, params=params)
        r.raise_for_status()
        return r.json()


class ProductRecommender:
    """Product recommendation engine at the edge"""

    def __init__(self, branch_id):
        self.branch_id = branch_id

        # Connect to Redis for caching
        redis_url = os.getenv("REDIS_URL", "redis://redis:6379")
        self.redis_client = redis.from_url(redis_url, decode_responses=True)

        # Mock product catalog
        self.products = self._load_product_catalog()

    def _load_product_catalog(self):
        """Load mock product catalog"""
        categories = {
            "Beverage": [
                {
                    "id": "BEV001",
                    "name": "Coca Cola",
                    "price": 15000,
                    "popularity": 0.9,
                },
                {"id": "BEV002", "name": "Pepsi", "price": 14000, "popularity": 0.8},
                {
                    "id": "BEV003",
                    "name": "Trà xanh",
                    "price": 10000,
                    "popularity": 0.85,
                },
                {
                    "id": "BEV004",
                    "name": "Nước suối",
                    "price": 5000,
                    "popularity": 0.95,
                },
                {"id": "BEV005", "name": "Sting", "price": 12000, "popularity": 0.7},
            ],
            "Snack": [
                {
                    "id": "SNK001",
                    "name": "Lay's Chips",
                    "price": 20000,
                    "popularity": 0.85,
                },
                {
                    "id": "SNK002",
                    "name": "Oishi Snack",
                    "price": 10000,
                    "popularity": 0.8,
                },
                {"id": "SNK003", "name": "Poca", "price": 15000, "popularity": 0.75},
                {"id": "SNK004", "name": "Bánh quy", "price": 25000, "popularity": 0.7},
            ],
            "Personal Care": [
                {
                    "id": "PC001",
                    "name": "Kem đánh răng",
                    "price": 35000,
                    "popularity": 0.6,
                },
                {"id": "PC002", "name": "Dầu gội", "price": 80000, "popularity": 0.5},
                {"id": "PC003", "name": "Xà phòng", "price": 20000, "popularity": 0.65},
            ],
            "Dairy": [
                {
                    "id": "DRY001",
                    "name": "Sữa tươi Vinamilk",
                    "price": 30000,
                    "popularity": 0.85,
                },
                {"id": "DRY002", "name": "Sữa chua", "price": 8000, "popularity": 0.9},
                {"id": "DRY003", "name": "Phô mai", "price": 45000, "popularity": 0.6},
            ],
            "Instant Food": [
                {
                    "id": "IF001",
                    "name": "Mì Hảo Hảo",
                    "price": 5000,
                    "popularity": 0.95,
                },
                {"id": "IF002", "name": "Cơm hộp", "price": 25000, "popularity": 0.7},
                {
                    "id": "IF003",
                    "name": "Bánh mì sandwich",
                    "price": 20000,
                    "popularity": 0.75,
                },
            ],
        }

        # Flatten to list
        all_products = []
        for category, items in categories.items():
            for item in items:
                item["category"] = category
                all_products.append(item)

        return all_products

    def get_recommendations(
        self, face_attributes: Dict, customer_id: str = None, top_k: int = 5
    ) -> List[Dict]:
        """
        Get product recommendations based on face attributes and history

        Args:
            face_attributes: Demographics (age, gender, etc.)
            customer_id: Optional customer identifier
            top_k: Number of recommendations

        Returns:
            List of recommended products
        """
        # Try to get cached recommendations first
        if customer_id:
            cached = self._get_cached_recommendations(customer_id)
            if cached:
                return cached[:top_k]

        # Generate recommendations
        recommendations = []

        # Rule-based recommendations based on demographics
        age_group = face_attributes.get("age_group", "26-35")
        gender = face_attributes.get("gender", "Male")

        # Age-based filtering
        if age_group in ["18-25", "26-35"]:
            # Young adults: prefer snacks, beverages, instant food
            preferred_categories = ["Snack", "Beverage", "Instant Food"]
        elif age_group in ["36-45", "46-60"]:
            # Middle-aged: prefer dairy, personal care
            preferred_categories = ["Dairy", "Personal Care", "Beverage"]
        else:
            # Seniors: prefer dairy, personal care
            preferred_categories = ["Dairy", "Personal Care"]

        # Gender-based adjustments
        if gender == "Female":
            # Boost personal care products
            preferred_categories.insert(0, "Personal Care")

        # Filter and score products
        scored_products = []
        for product in self.products:
            score = product["popularity"]

            # Boost score if in preferred category
            if product["category"] in preferred_categories:
                score *= 1.5

            # Add some randomness for diversity
            score *= random.uniform(0.8, 1.2)

            scored_products.append(
                {
                    "product_id": product["id"],
                    "product_name": product["name"],
                    "category": product["category"],
                    "price": product["price"],
                    "score": score,
                    "reason": self._generate_reason(product, face_attributes),
                }
            )

        # Sort by score and take top K
        scored_products.sort(key=lambda x: x["score"], reverse=True)
        recommendations = scored_products[:top_k]

        # Cache recommendations
        if customer_id:
            self._cache_recommendations(customer_id, recommendations)

        return recommendations

    def _generate_reason(self, product: Dict, attributes: Dict) -> str:
        """Generate human-readable recommendation reason"""
        reasons = [
            f"Phổ biến với nhóm tuổi {attributes.get('age_group', 'của bạn')}",
            f"Sản phẩm bán chạy tại {self.branch_id}",
            "Khuyến mãi đặc biệt hôm nay",
            "Thường mua cùng với sản phẩm khác",
            "Xu hướng mua sắm gần đây",
        ]
        return random.choice(reasons)

    def _get_cached_recommendations(self, customer_id: str):
        """Get cached recommendations from Redis"""
        try:
            cache_key = f"rec:{customer_id}"
            cached = self.redis_client.get(cache_key)
            if cached:
                return json.loads(cached)
        except Exception as e:
            print(f"Redis cache error: {e}")
        return None

    def _cache_recommendations(self, customer_id: str, recommendations: List[Dict]):
        """Cache recommendations to Redis (TTL: 1 hour)"""
        try:
            cache_key = f"rec:{customer_id}"
            self.redis_client.setex(
                cache_key, 3600, json.dumps(recommendations)  # 1 hour
            )
        except Exception as e:
            print(f"Redis cache error: {e}")

    def update_model(self, model_path: str):
        """Update recommendation model from cloud server"""
        # In production, this would load new model weights
        # For simulation, we just log the update
        print(f"Model updated from: {model_path}")
