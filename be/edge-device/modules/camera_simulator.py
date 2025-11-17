import cv2
import numpy as np
import random
from datetime import datetime

class CameraSimulator:
    """Simulates camera capturing customer faces"""
    
    def __init__(self):
        self.width = 640
        self.height = 480
        self.frame_count = 0
        
    def capture_frame(self):
        """Generate a synthetic frame with a face-like region"""
        # Create blank frame
        frame = np.zeros((self.height, self.width, 3), dtype=np.uint8)
        
        # Add some noise to simulate real camera
        noise = np.random.randint(0, 50, frame.shape, dtype=np.uint8)
        frame = cv2.add(frame, noise)
        
        # Draw a face-like oval (simulating detected face region)
        center_x = self.width // 2 + random.randint(-100, 100)
        center_y = self.height // 2 + random.randint(-50, 50)
        axes = (80, 100)  # Width, height of oval
        
        # Face region
        cv2.ellipse(frame, (center_x, center_y), axes, 0, 0, 360, (200, 180, 160), -1)
        
        # Eyes
        eye_left = (center_x - 25, center_y - 20)
        eye_right = (center_x + 25, center_y - 20)
        cv2.circle(frame, eye_left, 8, (50, 50, 50), -1)
        cv2.circle(frame, eye_right, 8, (50, 50, 50), -1)
        
        # Nose
        nose = (center_x, center_y + 10)
        cv2.circle(frame, nose, 5, (150, 120, 100), -1)
        
        # Mouth
        mouth_start = (center_x - 20, center_y + 40)
        mouth_end = (center_x + 20, center_y + 40)
        cv2.line(frame, mouth_start, mouth_end, (100, 80, 80), 3)
        
        # Add timestamp
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        cv2.putText(frame, timestamp, (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 
                   0.6, (255, 255, 255), 1)
        
        self.frame_count += 1
        
        return frame
    
    def save_frame(self, frame, path):
        """Save frame to disk (optional)"""
        cv2.imwrite(path, frame)
        
    def release(self):
        """Cleanup (no-op for simulator)"""
        pass
