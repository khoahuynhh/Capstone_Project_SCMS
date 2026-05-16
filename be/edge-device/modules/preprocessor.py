import argparse
from pathlib import Path

import cv2
import numpy as np


IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}
DEFAULT_FACE_DETECTOR_MODEL = ""


class YuNetOnnxDetector:
    """OpenCV YuNet ONNX face detector with 5-point landmarks."""

    def __init__(
        self,
        model_path,
        score_threshold=0.7,
        nms_threshold=0.3,
        top_k=5000,
        max_input_size=640,
    ):
        self.model_path = Path(model_path)
        self.max_input_size = max_input_size
        if not self.model_path.exists():
            raise FileNotFoundError(self.model_path)
        if not hasattr(cv2, "FaceDetectorYN_create"):
            raise RuntimeError("OpenCV was built without FaceDetectorYN support")

        self.detector = cv2.FaceDetectorYN_create(
            str(self.model_path),
            "",
            (320, 320),
            float(score_threshold),
            float(nms_threshold),
            int(top_k),
        )

    def detect(self, img_rgb):
        source_height, source_width = img_rgb.shape[:2]
        input_rgb, scale = self._resize_for_detection(img_rgb)
        input_height, input_width = input_rgb.shape[:2]

        self.detector.setInputSize((input_width, input_height))
        img_bgr = cv2.cvtColor(input_rgb, cv2.COLOR_RGB2BGR)
        _, faces = self.detector.detect(img_bgr)
        if faces is None or len(faces) == 0:
            return None

        face = max(faces, key=lambda item: item[2] * item[3])
        if scale != 1.0:
            face = face.copy()
            face[:14] = face[:14] / scale

        x, y, box_width, box_height = face[:4]
        x = max(0, min(x, source_width - 1))
        y = max(0, min(y, source_height - 1))
        box_width = max(1, min(box_width, source_width - x))
        box_height = max(1, min(box_height, source_height - y))
        eye_points = [
            (int(round(face[4])), int(round(face[5]))),
            (int(round(face[6])), int(round(face[7]))),
        ]
        eye_points.sort(key=lambda point: point[0])

        return {
            "box": [
                int(round(x)),
                int(round(y)),
                int(round(box_width)),
                int(round(box_height)),
            ],
            "keypoints": {
                "left_eye": eye_points[0],
                "right_eye": eye_points[1],
                "nose": (int(round(face[8])), int(round(face[9]))),
                "right_mouth": (int(round(face[10])), int(round(face[11]))),
                "left_mouth": (int(round(face[12])), int(round(face[13]))),
            },
            "score": float(face[14]) if len(face) > 14 else None,
        }

    def _resize_for_detection(self, img_rgb):
        if not self.max_input_size:
            return img_rgb, 1.0

        height, width = img_rgb.shape[:2]
        longest_side = max(height, width)
        if longest_side <= self.max_input_size:
            return img_rgb, 1.0

        scale = self.max_input_size / longest_side
        resized = cv2.resize(
            img_rgb,
            (int(round(width * scale)), int(round(height * scale))),
            interpolation=cv2.INTER_AREA,
        )
        return resized, scale


class FacePreprocessor:
    def __init__(
        self,
        target_size=(224, 224),
        margin=20,
        detector_model_path=DEFAULT_FACE_DETECTOR_MODEL,
        detection_confidence=0.7,
        max_detection_size=640,
    ):
        self.target_size = target_size
        self.margin = margin
        self.detector = self._create_detector(
            detector_model_path,
            detection_confidence,
            max_detection_size,
        )

        if self.detector is None:
            self.detector_backend = "haar_cascade"
            haar_dir = Path(cv2.data.haarcascades)
            self.face_cascade = cv2.CascadeClassifier(
                str(haar_dir / "haarcascade_frontalface_default.xml")
            )
            self.eye_cascade = cv2.CascadeClassifier(
                str(haar_dir / "haarcascade_eye.xml")
            )
            if detector_model_path:
                print(
                    "ONNX face detector is unavailable. "
                    "Falling back to OpenCV Haar Cascade."
                )
            else:
                print(
                    "No ONNX face detector configured. "
                    "Using OpenCV Haar Cascade."
                )
        else:
            self.detector_backend = "yunet_onnx"
            self.face_cascade = None
            self.eye_cascade = None

    @staticmethod
    def _create_detector(model_path, detection_confidence, max_detection_size):
        if not model_path:
            return None

        try:
            return YuNetOnnxDetector(
                model_path=model_path,
                score_threshold=detection_confidence,
                max_input_size=max_detection_size,
            )
        except Exception as exc:
            print(f"Failed to load ONNX face detector ({exc}).")
            return None

    def detect_main_face(self, img_rgb):
        if self.detector is not None:
            return self.detector.detect(img_rgb)

        img_gray = cv2.cvtColor(img_rgb, cv2.COLOR_RGB2GRAY)
        faces = self.face_cascade.detectMultiScale(
            img_gray,
            scaleFactor=1.1,
            minNeighbors=5,
            minSize=(30, 30),
        )
        if len(faces) == 0:
            return None

        x, y, width, height = max(faces, key=lambda face: face[2] * face[3])
        face_gray = img_gray[y : y + height, x : x + width]
        eyes = self.eye_cascade.detectMultiScale(
            face_gray,
            scaleFactor=1.1,
            minNeighbors=5,
            minSize=(10, 10),
        )

        keypoints = {}
        if len(eyes) >= 2:
            eye_centers = [
                (x + ex + ew // 2, y + ey + eh // 2)
                for ex, ey, ew, eh in sorted(eyes, key=lambda eye: eye[0])[:2]
            ]
            keypoints = {
                "left_eye": eye_centers[0],
                "right_eye": eye_centers[1],
            }

        return {
            "box": [int(x), int(y), int(width), int(height)],
            "keypoints": keypoints,
        }

    def align_face(self, img, left_eye, right_eye):
        d_y = right_eye[1] - left_eye[1]
        d_x = right_eye[0] - left_eye[0]
        angle = np.degrees(np.arctan2(d_y, d_x))

        eyes_center = (
            int((left_eye[0] + right_eye[0]) / 2),
            int((left_eye[1] + right_eye[1]) / 2),
        )

        rotation_matrix = cv2.getRotationMatrix2D(eyes_center, angle, 1.0)
        height, width = img.shape[:2]
        return cv2.warpAffine(
            img,
            rotation_matrix,
            (width, height),
            flags=cv2.INTER_CUBIC,
        )

    def process_rgb_array(self, img_rgb):
        main_face = self.detect_main_face(img_rgb)
        if main_face is None:
            return None

        keypoints = main_face["keypoints"]
        if "left_eye" in keypoints and "right_eye" in keypoints:
            aligned_img = self.align_face(
                img_rgb,
                keypoints["left_eye"],
                keypoints["right_eye"],
            )
        else:
            aligned_img = img_rgb

        aligned_face = self.detect_main_face(aligned_img)
        if aligned_face is None:
            return None

        x, y, width, height = aligned_face["box"]

        x1 = max(0, x - self.margin)
        y1 = max(0, y - self.margin)
        x2 = min(aligned_img.shape[1], x + width + self.margin)
        y2 = min(aligned_img.shape[0], y + height + self.margin)

        cropped_face = aligned_img[y1:y2, x1:x2]
        if cropped_face.size == 0:
            return None

        resized_face = cv2.resize(cropped_face, self.target_size)
        return resized_face.astype(np.uint8)

    def process_image(self, image_path):
        img = cv2.imread(str(image_path))
        if img is None:
            raise ValueError(f"Cannot read image: {image_path}")

        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        processed_face = self.process_rgb_array(img_rgb)
        if processed_face is None:
            print(f"No usable face found: {image_path}")
            return None

        return processed_face.astype("float32") / 255.0

    def save_processed_image(self, image_path, output_path):
        img = cv2.imread(str(image_path))
        if img is None:
            raise ValueError(f"Cannot read image: {image_path}")

        processed_face = self.process_rgb_array(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))
        if processed_face is None:
            print(f"No usable face found: {image_path}")
            return False

        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_img = cv2.cvtColor(processed_face, cv2.COLOR_RGB2BGR)
        return cv2.imwrite(str(output_path), output_img)

    def process_folder(self, input_dir, output_dir, overwrite=False, limit=None):
        input_dir = Path(input_dir)
        output_dir = Path(output_dir)

        image_paths = [
            path
            for path in input_dir.rglob("*")
            if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
        ]
        image_paths.sort()

        if limit is not None:
            image_paths = image_paths[:limit]

        total = len(image_paths)
        saved = 0
        skipped = 0
        failed = 0

        for index, image_path in enumerate(image_paths, start=1):
            relative_path = image_path.relative_to(input_dir)
            output_path = output_dir / relative_path

            if output_path.exists() and not overwrite:
                skipped += 1
                continue

            try:
                ok = self.save_processed_image(image_path, output_path)
            except Exception as exc:
                ok = False
                print(f"Failed: {image_path} ({exc})")

            if ok:
                saved += 1
            else:
                failed += 1

            if index % 100 == 0 or index == total:
                print(
                    f"[{index}/{total}] saved={saved} skipped={skipped} failed={failed}"
                )

        return {
            "total": total,
            "saved": saved,
            "skipped": skipped,
            "failed": failed,
            "output_dir": str(output_dir),
        }


def parse_args():
    parser = argparse.ArgumentParser(
        description="Align, crop, resize, and normalize face images in a folder."
    )
    parser.add_argument(
        "--input",
        default="faces",
        help="Input image folder. Default: faces",
    )
    parser.add_argument(
        "--output",
        default="faces_processed",
        help="Output folder. Default: faces_processed",
    )
    parser.add_argument(
        "--size",
        type=int,
        default=224,
        help="Output image width and height. Default: 224",
    )
    parser.add_argument(
        "--margin",
        type=int,
        default=15,
        help="Face crop margin in pixels. Default: 15",
    )
    parser.add_argument(
        "--detector-model",
        default=DEFAULT_FACE_DETECTOR_MODEL,
        help=(
            "YuNet ONNX face detector path. "
            f"Default: {DEFAULT_FACE_DETECTOR_MODEL}"
        ),
    )
    parser.add_argument(
        "--confidence",
        type=float,
        default=0.7,
        help="Face detection confidence threshold. Default: 0.7",
    )
    parser.add_argument(
        "--max-detection-size",
        type=int,
        default=640,
        help="Resize longest image side before detection. Default: 640",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite existing output images.",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=None,
        help="Process only the first N images. Useful for testing.",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    preprocessor = FacePreprocessor(
        target_size=(args.size, args.size),
        margin=args.margin,
        detector_model_path=args.detector_model,
        detection_confidence=args.confidence,
        max_detection_size=args.max_detection_size,
    )
    summary = preprocessor.process_folder(
        input_dir=args.input,
        output_dir=args.output,
        overwrite=args.overwrite,
        limit=args.limit,
    )
    print("Done:", summary)


if __name__ == "__main__":
    main()
