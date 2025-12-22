# modules/face_detector.py

import os
import hashlib
from typing import Optional, Dict, Any, Tuple

import cv2
import numpy as np
import mediapipe as mp
from PIL import Image
import torch

from model import FaceVerification, Config

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_PATH = os.path.join(BASE_DIR, "models", "embedder.onnx")
DB_PATH = os.path.join(BASE_DIR, "data", "embber_db.json")

mp_face_detection = mp.solutions.face_detection


class FaceDetector:
    """
    Dùng:
      - MediaPipe BlazeFace để detect mặt trên full frame
      - FaceVerification (model.py) để trích embedding + nhận diện
    """

    def __init__(
        self,
        model_path: str = MODEL_PATH,
        db_path: str = DB_PATH,
        threshold: float = 0.5,
        device: Optional[str] = None,
        min_conf: float = 0.5,
    ):
        # 1. Khởi tạo FaceVerification
        if device is None:
            device = "cuda" if torch.cuda.is_available() else "cpu"

        self.verifier = FaceVerification(
            model_path=model_path,
            backbone_name=Config.BACKBONE,
            embedding_size=Config.EMBEDDING_SIZE,
            device=torch.device(device),
        )
        self.verifier.set_threshold(threshold)

        # 2. Load DB embedding nếu có
        self.db_path = db_path
        if os.path.exists(db_path):
            self.verifier.load_database(db_path)
            print(
                f"[FaceDetector] Loaded DB from {db_path} with {len(self.verifier.database)} identities"
            )
        else:
            print(f"[FaceDetector] No DB found at {db_path}, starting empty.")

        # 3. Detector BlazeFace (MediaPipe)
        self.detector = mp_face_detection.FaceDetection(
            model_selection=0,
            min_detection_confidence=min_conf,
        )

        self.threshold = threshold

    # ---------------------- PUBLIC API ----------------------

    def reload_database(self):
        if os.path.exists(self.db_path):
            self.verifier.load_database(self.db_path)
            print(
                f"[FaceDetector] Reloaded DB: {len(self.verifier.database)} identities"
            )

    def save_database(self):
        # Lưu DB hiện tại của FaceVerification
        self.verifier.save_database(self.db_path)
        print(f"[FaceDetector] Saved DB to {self.db_path}")

    def register_face(self, frame: np.ndarray, identity: str) -> bool:
        """
        Đăng ký 1 khuôn mặt mới từ full frame, lưu vào DB với identity.
        """
        face_bgr, _ = self._detect_biggest_face(frame)
        if face_bgr is None:
            return False

        face_rgb = cv2.cvtColor(face_bgr, cv2.COLOR_BGR2RGB)
        # FaceVerification.add_face chấp nhận np.ndarray hoặc PIL
        self.verifier.add_face(face_rgb, identity)
        self.save_database()
        return True

    def detect_and_extract(self, frame: np.ndarray) -> Optional[Dict[str, Any]]:
        """
        Hàm bạn đang dùng trong EdgeDevice.
        Nhận: frame BGR (H, W, 3)
        Trả: dict chứa bbox, attributes, embedding, customer_id, similarity
        """
        # 1. detect mặt lớn nhất
        face_bgr, box = self._detect_biggest_face(frame)
        if face_bgr is None or box is None:
            return None

        # 2. convert sang RGB để dùng cho FaceVerification
        face_rgb = cv2.cvtColor(face_bgr, cv2.COLOR_BGR2RGB)

        # 3. Nhận diện bằng FaceVerification
        # identity, similarity = self.verifier.recognize(face_rgb)

        # 4. Lấy embedding thủ công từ cùng model + transform
        emb = self._get_embedding(face_rgb)
        if emb is None:
            return None

        x1, y1, x2, y2 = box
        bbox = (x1, y1, x2 - x1, y2 - y1)

        # Nếu identity là "Unknown" thì tạo ID tạm từ hash embedding
        # if identity == "Unknown":
        #     customer_id = self._generate_customer_id(emb)
        # else:
        #     customer_id = identity

        # attributes = self._mock_attributes(face_rgb)

        return {
            "bbox": bbox,
            # "attributes": attributes,
            "embedding": emb.tolist(),
            # "customer_id": customer_id,
            # "similarity": float(similarity),
        }

    # ---------------------- INTERNAL HELPERS ----------------------

    def _detect_biggest_face(
        self,
        img_bgr: np.ndarray,
        expand_ratio: float = 0.3,
    ) -> Tuple[Optional[np.ndarray], Optional[Tuple[int, int, int, int]]]:
        """
        Dùng MediaPipe FaceDetection detect tất cả mặt, chọn mặt lớn nhất.
        Trả về face_bgr + (x1,y1,x2,y2)
        """
        h, w, _ = img_bgr.shape
        img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)

        results = self.detector.process(img_rgb)
        if not results.detections:
            return None, None

        best_box = None
        best_area = 0

        for det in results.detections:
            bbox = det.location_data.relative_bounding_box
            x = bbox.xmin * w
            y = bbox.ymin * h
            bw = bbox.width * w
            bh = bbox.height * h

            cx = x + bw / 2
            cy = y + bh / 2
            side = max(bw, bh) * (1.0 + expand_ratio)

            x1 = int(max(0, cx - side / 2))
            y1 = int(max(0, cy - side / 2))
            x2 = int(min(w, cx + side / 2))
            y2 = int(min(h, cy + side / 2))

            area = (x2 - x1) * (y2 - y1)
            if area > best_area and x2 > x1 and y2 > y1:
                best_area = area
                best_box = (x1, y1, x2, y2)

        if best_box is None:
            return None, None

        x1, y1, x2, y2 = best_box
        face_bgr = img_bgr[y1:y2, x1:x2]
        return face_bgr, best_box

    def _get_embedding(self, face_rgb: np.ndarray) -> Optional[np.ndarray]:
        """
        Dùng lại model + transform bên trong FaceVerification để lấy embedding.
        """
        if face_rgb is None or face_rgb.size == 0:
            return None

        img = Image.fromarray(face_rgb.astype("uint8"))

        # Dùng transform và model đã load trong FaceVerification
        image_tensor = (
            self.verifier.transform(img).unsqueeze(0).to(self.verifier.device)
        )

        with torch.no_grad():
            emb = self.verifier.model(image_tensor)  # [1, D]

        emb = emb.squeeze(0).cpu().numpy().astype(np.float32)
        # L2-normalize cho chắc (model đã normalize, nhưng làm lại cũng không sao)
        norm = np.linalg.norm(emb)
        if norm > 0:
            emb = emb / norm
        return emb

    def _mock_attributes(self, face_rgb: np.ndarray) -> Dict[str, Any]:
        """
        Tạm thời mock attribute, sau này bạn có model age/gender riêng thì thay ở đây.
        """
        return {
            "age_group": "unknown",
            "gender": "unknown",
            "wearing_glasses": False,
            "facial_expression": "neutral",
            "estimated_income_level": "unknown",
        }

    def _generate_customer_id(self, embedding: np.ndarray) -> str:
        """
        Sinh ID ẩn danh từ embedding để track khách chưa có trong DB.
        """
        embedding_bytes = embedding.tobytes()
        h = hashlib.sha256(embedding_bytes).hexdigest()
        return f"CUST_{h[:12]}"
