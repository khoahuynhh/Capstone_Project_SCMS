import { useEffect, useMemo, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import "../css/FaceScan.css";
import FaceAIRecommendation from "./FaceAIRecommendation";

import { edgeApi } from "../../../core/api/edge_api";

export default function EdgeScanPage() {
  const navigate = useNavigate();
  const videoRef = useRef(null);
  const canvasRef = useRef(null);

  const [cameraReady, setCameraReady] = useState(false);
  const [stage, setStage] = useState("idle"); // idle | scanning | scanned | recommending
  const [error, setError] = useState("");

  const [attrs, setAttrs] = useState(null); // { gender, age, age_group, emotion }
  const [previewUrl, setPreviewUrl] = useState("");

  const statusText = useMemo(() => {
    if (stage === "scanning") return "Đang quét & dự đoán...";
    if (stage === "recommending") return "Đang lấy gợi ý sản phẩm...";
    if (stage === "scanned") return "Đã có kết quả dự đoán.";
    return "Sẵn sàng. Hãy nhìn thẳng vào camera và bấm Quét.";
  }, [stage]);
  const [showAiModal, setShowAiModal] = useState(false);

  useEffect(() => {
    let stream;

    const startCamera = async () => {
      setError("");
      try {
        stream = await navigator.mediaDevices.getUserMedia({
          video: { facingMode: "user" },
          audio: false,
        });

        if (videoRef.current) {
          videoRef.current.srcObject = stream;
          await videoRef.current.play();
          setCameraReady(true);
        }
      } catch {
        setError("Không mở được camera. Hãy cấp quyền camera và thử lại.");
      }
    };

    startCamera();

    return () => {
      if (stream) stream.getTracks().forEach((t) => t.stop());
    };
  }, []);

  const captureToFile = async () => {
    const video = videoRef.current;
    const canvas = canvasRef.current;
    if (!video || !canvas) throw new Error("Camera not ready");

    const w = video.videoWidth;
    const h = video.videoHeight;
    if (!w || !h) throw new Error("Camera not ready");

    canvas.width = w;
    canvas.height = h;
    const ctx = canvas.getContext("2d");
    ctx.drawImage(video, 0, 0, w, h);

    // Preview (dataURL)
    const dataUrl = canvas.toDataURL("image/jpeg", 0.9);
    setPreviewUrl(dataUrl);

    return new Promise((resolve) => {
      canvas.toBlob((blob) => {
        const file = new File([blob], "face.jpg", { type: "image/jpeg" });
        resolve(file);
      }, "image/jpeg", 0.9);
    });
  };

  const normalizeAttrs = (raw) => {
    const source = raw?.face_attributes || raw?.attributes || raw;
    const gender = source?.gender;
    const emotion = source?.emotion;
    const age = Number(source?.age);

    if (!gender || !emotion || Number.isNaN(age)) return null;
    return {
      gender: String(gender).toLowerCase(),
      emotion: String(emotion).toLowerCase(),
      age: Math.round(age),
      age_group: source?.age_group,
    };
  };

  const handleScanOnce = async () => {
    setError("");
    setAttrs(null);

    try {
      setStage("scanning");

      const file = await captureToFile();

      // Edge infer: theo edge_api của bạn là identifyFace(file) (multipart)
      const raw = await edgeApi.FaceAnalysis(file);
      const norm = normalizeAttrs(raw);

      if (!norm) throw new Error("Edge API returned invalid attributes.");
      setAttrs(norm);
      setStage("scanned");
    } catch (e) {
      setStage("idle");
      setError(e.message || "Scan failed");
    }
  };

  const handleGetRecommendations = async () => {
    if (!attrs) return;
    setError("");

    try {
      setStage("recommending");

      setShowAiModal(true); 
      setStage("scanned");
    } catch (e) {
      setStage("scanned");
      setError(e.message || "Không thể lấy gợi ý");
    }
  };

  const handleReset = () => {
    setError("");
    setAttrs(null);
    setPreviewUrl("");
    setStage("idle");
  };

  return (
    <div className="facescan-page">
      <div className="facescan-blur" />
      <div className="edgeScan">
        <div className="edgeScan__top">
          <div>
            <h2 className="edgeScan__title">Quét khuôn mặt</h2>
            <p className="edgeScan__subtitle">{statusText}</p>
        </div>

        <div className="edgeScan__topActions">
          <button className="btn btn--ghost" type="button" onClick={() => navigate("/login")}>
            Quay lại
          </button>
        </div>
      </div>

      <div className="edgeScan__grid">
        {/* LEFT: Camera */}
        <section className="card cameraCard">
          <div className="cameraCard__viewport">
            <video ref={videoRef} className="cameraCard__video" playsInline muted />
            <div className="cameraCard__overlay">
              <div className="cameraCard__frame" />
            </div>
          </div>

          <div className="cameraCard__actions">
            <button
              className="btn btn--ghost"
              type="button"
              disabled={!cameraReady || stage === "scanning" || stage === "recommending"}
              onClick={handleScanOnce}
            >
              {stage === "scanning" ? "Đang quét..." : "Quét 1 lượt"}
            </button>

            <button
              className="btn btn--secondary"
              type="button"
              disabled={!attrs || stage === "scanning" || stage === "recommending"}
              onClick={handleGetRecommendations}
            >
              {stage === "recommending" ? "Đang lấy gợi ý..." : "Nhận gợi ý sản phẩm"}
            </button>

            <button
              className="btn btn--ghost"
              type="button"
              disabled={stage === "scanning" || stage === "recommending"}
              onClick={handleReset}
            >
              Quét lại
            </button>
          </div>

          <canvas ref={canvasRef} className="cameraCard__canvas" />
        </section>

        {/* RIGHT: Prediction panel */}
        <section className="card predCard">
          <div className="predCard__head">
            <h3 className="predCard__title">Dự đoán</h3>
            <span className="predCard__meta">{attrs ? "Cập nhật từ Edge" : "Chưa có dữ liệu"}</span>
          </div>

          {previewUrl ? (
            <img className="predCard__preview" src={previewUrl} alt="captured" />
          ) : (
            <div className="predCard__placeholder">Ảnh chụp sẽ hiện ở đây</div>
          )}

          <div className="predCard__chips">
            <span className="chip">
              <b>Giới tính:</b> {attrs?.gender ?? "—"}
            </span>
            <span className="chip">
              <b>Tuổi:</b> {attrs?.age ?? "—"}
            </span>
            <span className="chip">
              <b>Cảm xúc:</b> {attrs?.emotion ?? "—"}
            </span>
          </div>

          {error && <div className="alert">{error}</div>}

          <div className="predCard__tip">
            Mẹo: Đứng nơi đủ sáng, nhìn thẳng, không che mặt.
          </div>
        </section>
      </div>
      </div>
      <FaceAIRecommendation 
        isOpen={showAiModal} 
        onClose={() => setShowAiModal(false)} 
        aiContext={attrs} // attrs chứa {gender, age, emotion}
      />
    </div>
  );
}
