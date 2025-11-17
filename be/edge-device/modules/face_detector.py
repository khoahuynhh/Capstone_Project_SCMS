import cv2
import numpy as np
import random
import hashlib

class FaceDetector:
    """Mock face detection and attribute extraction"""
    
    def __init__(self):
        self.face_cascade = cv2.CascadeClassifier(
            cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'


        )
        
    def detect_and_extract(self, frame):
        """
        Detect face and extract attributes
        Returns: dict with face_bbox, attributes, embedding
        """
        # Convert to grayscale for detection
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        # Detect faces
        faces = self.face_cascade.detectMultiScale(
            gray, scaleFactor=1.1, minNeighbors=5, minSize=(50, 50)
        )
        
        if len(faces) == 0:
            return None
        
        # Take the first/largest face
        x, y, w, h = faces[0]
        face_region = frame[y:y+h, x:x+w]
        
        # Extract mock attributes
        attributes = self._extract_attributes(face_region)
        
        # Generate mock embedding (512-dim vector)
        embedding = self._generate_embedding(face_region)
        
        # Generate customer ID from embedding hash
        customer_id = self._generate_customer_id(embedding)
        
        return {
            'bbox': (x, y, w, h),
            'attributes': attributes,
            'embedding': embedding.tolist(),
            'customer_id': customer_id
        }
    
    def _extract_attributes(self, face_region):
        """Mock attribute extraction (age, gender, etc.)"""
        # In reality, this would use a trained model
        # For simulation, we generate random but consistent attributes
        
        age_group = random.choice(['18-25', '26-35', '36-45', '46-60', '60+'])
        gender = random.choice(['Male', 'Female'])
        
        # Additional attributes
        attributes = {
            'age_group': age_group,
            'gender': gender,
            'wearing_glasses': random.choice([True, False]),
            'facial_expression': random.choice(['neutral', 'smile', 'serious']),
            'estimated_income_level': random.choice(['low', 'medium', 'high']),
        }
        
        return attributes
    
    def _generate_embedding(self, face_region):
        """Generate mock face embedding vector"""
        # In reality, this would use FaceNet, ArcFace, etc.
        # For simulation, create a pseudo-random but deterministic vector
        
        # Use face pixels to seed randomness
        seed = int(np.mean(face_region))
        np.random.seed(seed % 10000)
        
        # 512-dimensional embedding (normalized)
        embedding = np.random.randn(512).astype(np.float32)
        embedding = embedding / np.linalg.norm(embedding)
        
        return embedding
    
    def _generate_customer_id(self, embedding):
        """Generate pseudo-anonymous customer ID from embedding"""
        # Hash the embedding to create consistent ID
        embedding_bytes = embedding.tobytes()
        hash_obj = hashlib.sha256(embedding_bytes)
        customer_id = f"CUST_{hash_obj.hexdigest()[:12]}"
        
        return customer_id
