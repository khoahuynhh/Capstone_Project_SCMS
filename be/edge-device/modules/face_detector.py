import random
from typing import Any

import numpy as np


class FaceDetector:
    """Lightweight face detector simulator for the Docker edge runtime."""

    def detect_and_extract(self, frame: Any) -> dict[str, Any] | None:
        if frame is None:
            return None

        if random.random() < 0.1:
            return None

        age = random.randint(18, 65)
        if age <= 25:
            age_group = "18-25"
        elif age <= 35:
            age_group = "26-35"
        elif age <= 45:
            age_group = "36-45"
        elif age <= 60:
            age_group = "46-60"
        else:
            age_group = "60+"

        attributes = {
            "age": age,
            "age_group": age_group,
            "gender": random.choice(["Male", "Female"]),
            "emotion": random.choice(["Neutral", "Happy", "Interested"]),
        }

        return {
            "customer_id": random.choice([None, "CUST_001", "CUST_002", "CUST_003"]),
            "attributes": attributes,
            "embedding": np.random.normal(size=128).astype(float).tolist(),
        }
