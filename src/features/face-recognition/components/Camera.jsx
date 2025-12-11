import React, { useRef, useEffect, useCallback, useState } from "react";
import Webcam from "react-webcam";
import { edgeApi } from '../services/edgeApi';

const Camera = ({ captureToken, onResult, className = "" }) => {
  const webcamRef = useRef(null);
  const [loading, setLoading] = useState(false);

  // Convert base64 dataURL -> Blob để gửi như file
  const dataURLtoBlob = (dataURL) => {
    const arr = dataURL.split(",");
    const mimeMatch = arr[0].match(/:(.*?);/);
    const mime = mimeMatch ? mimeMatch[1] : "image/jpeg";
    const bstr = atob(arr[1]);
    let n = bstr.length;
    const u8arr = new Uint8Array(n);
    while (n--) {
      u8arr[n] = bstr.charCodeAt(n);
    }
    return new Blob([u8arr], { type: mime });
  };

  const captureAndSend = useCallback(async () => {
    if (!webcamRef.current) return;

    const imageSrc = webcamRef.current.getScreenshot();
    if (!imageSrc) {
      console.error("Không chụp được ảnh từ webcam");
      onResult?.({ success: false, reason: "no_frame" });
      return;
    }

    setLoading(true);

    try {
      const blob = dataURLtoBlob(imageSrc);
      const formData = new FormData();
      formData.append("file", blob, "frame.jpg");

      const data = await edgeApi.identifyFace(blob);
      // const res = await fetch("http://localhost:8001/face/identify", { ... })

      // data = JSON mà BE edge trả về (success, customer, embedding, similarity,...)
      onResult?.(data);
    } catch (err) {
      console.error("Lỗi khi gọi edge API:", err);
      onResult?.({ success: false, reason: "exception", error: String(err) });
    } finally {
      setLoading(false);
    }
  }, [onResult]);

  // Mỗi lần captureToken thay đổi → tự động chụp + gửi
  useEffect(() => {
    if (captureToken > 0) {
      captureAndSend();
    }
  }, [captureToken, captureAndSend]);

  return (
    <div className={`relative ${className}`}>
      <Webcam
        ref={webcamRef}
        screenshotFormat="image/jpeg"
        className="w-80 h-96 object-cover rounded-lg"
        videoConstraints={{
          facingMode: "user",
        }}
      />

      {loading && (
        <div className="absolute inset-0 bg-black/40 flex items-center justify-center">
          <div className="w-8 h-8 border-2 border-white border-t-transparent rounded-full animate-spin" />
        </div>
      )}
    </div>
  );
};

export default Camera;
