import os
from typing import Any

import numpy as np
import onnxruntime as ort
from PIL import Image


GENDER_LABELS = {0: "male", 1: "female"}
EMO_LABELS = {
    0: "anger",
    1: "disgust",
    2: "fear",
    3: "happy",
    4: "neutral",
    5: "sad",
    6: "surprise",
}


class OnnxFaceAttrPredictor:
    def __init__(self, model_path: str, img_size: int | None = None):
        if not os.path.exists(model_path):
            raise FileNotFoundError(model_path)

        self.session = ort.InferenceSession(
            model_path,
            providers=["CPUExecutionProvider"],
        )
        model_input = self.session.get_inputs()[0]
        self.input_name = model_input.name
        self.img_size = img_size or self._get_square_input_size(model_input.shape)

    @staticmethod
    def _get_square_input_size(input_shape: list[Any]) -> int:
        if len(input_shape) >= 4 and isinstance(input_shape[2], int) and isinstance(input_shape[3], int):
            if input_shape[2] != input_shape[3]:
                raise ValueError(f"ONNX model input must be square, got {input_shape}")
            return input_shape[2]
        return 224

    def _to_pil(self, image: Any) -> Image.Image:
        if isinstance(image, str):
            return Image.open(image).convert("RGB")
        if isinstance(image, Image.Image):
            return image.convert("RGB")
        if isinstance(image, np.ndarray):
            if image.dtype != np.uint8:
                image = image.astype(np.uint8)
            return Image.fromarray(image).convert("RGB")
        raise TypeError(f"Unsupported image type: {type(image)}")

    def _preprocess(self, image: Any) -> np.ndarray:
        pil = self._to_pil(image).resize((self.img_size, self.img_size))
        arr = np.asarray(pil, dtype=np.float32) / 255.0
        mean = np.asarray([0.485, 0.456, 0.406], dtype=np.float32)
        std = np.asarray([0.229, 0.224, 0.225], dtype=np.float32)
        arr = (arr - mean) / std
        arr = np.transpose(arr, (2, 0, 1))
        return np.expand_dims(arr, axis=0).astype(np.float32)

    @staticmethod
    def _softmax(logits: np.ndarray) -> np.ndarray:
        logits = logits.astype(np.float64)
        logits = logits - np.max(logits)
        exp = np.exp(logits)
        return exp / np.sum(exp)

    def predict(self, image: Any) -> dict[str, Any]:
        outputs = self.session.run(None, {self.input_name: self._preprocess(image)})
        if len(outputs) < 3:
            raise ValueError("ONNX model must return age, gender logits, emotion logits")

        age = float(np.asarray(outputs[0]).reshape(-1)[0])
        gender_logits = np.asarray(outputs[1]).reshape(-1)
        emotion_logits = np.asarray(outputs[2]).reshape(-1)

        gender_probs = self._softmax(gender_logits)
        gender_id = int(np.argmax(gender_probs))
        emotion_probs = self._softmax(emotion_logits)
        emotion_id = int(np.argmax(emotion_probs))

        return {
            "age": int(max(1, min(100, round(age)))),
            "gender_id": gender_id,
            "gender_label": GENDER_LABELS.get(gender_id, str(gender_id)),
            "gender_prob": float(gender_probs[gender_id]),
            "emotion_id": emotion_id,
            "emotion_label": EMO_LABELS.get(emotion_id, str(emotion_id)),
            "emotion_prob": float(emotion_probs[emotion_id]),
            "emotion_probs": emotion_probs.astype(float).tolist(),
        }
