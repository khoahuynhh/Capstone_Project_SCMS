import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import "../css/FaceScan.css";
import FaceAIRecommendation from "./FaceAIRecommendation";

import { edgeApi } from "../../../core/api/edge_api";

const GENDER_LABELS = {
  male: "Nam",
  female: "Nữ",
  man: "Nam",
  woman: "Nữ",
  unknown: "Không xác định",
};

const EMOTION_LABELS = {
  neutral: "Bình thường",
  happy: "Vui vẻ",
  sad: "Buồn",
  angry: "Tức giận",
  surprise: "Ngạc nhiên",
  surprised: "Ngạc nhiên",
  fear: "Lo lắng",
  fearful: "Lo lắng",
  disgust: "Không hài lòng",
  contempt: "Không hài lòng",
};

const AGE_GROUP_LABELS = {
  all: "Mọi độ tuổi",
  unknown: "Không xác định",
};

const toDisplayLabel = (value, labels = {}) => {
  if (value === null || value === undefined || value === "") return "Chưa có";
  const key = String(value).trim().toLowerCase();
  if (labels[key]) return labels[key];

  return key
    .replace(/[_-]+/g, " ")
    .replace(/\s+/g, " ")
    .replace(/\b\w/g, (char) => char.toUpperCase());
};

const toAgeGroupLabel = (value) => {
  if (value === null || value === undefined || value === "") return "";
  const key = String(value).trim().toLowerCase();
  if (AGE_GROUP_LABELS[key]) return AGE_GROUP_LABELS[key];

  const rangeMatch = key.match(/^(\d+)[_-](\d+)$/);
  if (rangeMatch) return `${rangeMatch[1]}-${rangeMatch[2]} tuổi`;
  if (/^\d+\+$/.test(key)) return `${key} tuổi`;

  return toDisplayLabel(key);
};

const toAgeLabel = (age, ageGroup) => {
  const roundedAge = Number(age);
  if (Number.isFinite(roundedAge)) return `${Math.round(roundedAge)} tuổi`;
  return toAgeGroupLabel(ageGroup) || "Chưa có";
};

const toProcessingTimeLabel = (value) => {
  const ms = Number(value);
  if (!Number.isFinite(ms)) return "Chưa có";
  if (ms < 1000) return `${Math.round(ms)} ms`;
  return `${(ms / 1000).toFixed(2)} giây`;
};

export default function EdgeScanPage() {
  const navigate = useNavigate();
  const videoRef = useRef(null);
  const canvasRef = useRef(null);
  const streamRef = useRef(null);

  const [hasFaceConsent, setHasFaceConsent] = useState(false);
  const [showFaceConsentPrompt, setShowFaceConsentPrompt] = useState(true);
  const [cameraReady, setCameraReady] = useState(false);
  const [stage, setStage] = useState("idle"); // idle | scanning | scanned | recommending
  const [error, setError] = useState("");

  const [attrs, setAttrs] = useState(null); // { gender, age, age_group, emotion }
  const [processingTimeMs, setProcessingTimeMs] = useState(null);
  const [previewUrl, setPreviewUrl] = useState("");

  const statusText = useMemo(() => {
    if (stage === "scanning") return "Đang quét & dự đoán...";
    if (stage === "recommending") return "Đang lấy gợi ý sản phẩm...";
    if (stage === "scanned") return "Đã có kết quả dự đoán.";
    return "Sẵn sàng. Hãy nhìn thẳng vào camera và bấm Quét.";
  }, [stage]);
  const [showAiModal, setShowAiModal] = useState(false);
  const displayAttrs = useMemo(
    () => ({
      gender: toDisplayLabel(attrs?.gender, GENDER_LABELS),
      age: toAgeLabel(attrs?.age, attrs?.age_group),
      emotion: toDisplayLabel(attrs?.emotion, EMOTION_LABELS),
      ageGroup: toAgeGroupLabel(attrs?.age_group),
      processingTime: toProcessingTimeLabel(processingTimeMs),
    }),
    [attrs, processingTimeMs]
  );

  const stopCamera = useCallback(() => {
    if (streamRef.current) {
      streamRef.current.getTracks().forEach((track) => track.stop());
      streamRef.current = null;
    }

    if (videoRef.current) {
      videoRef.current.srcObject = null;
    }

    setCameraReady(false);
  }, []);

  useEffect(() => {
    let stream;

    const startCamera = async () => {
      setError("");
      try {
        stream = await navigator.mediaDevices.getUserMedia({
          video: { facingMode: "user" },
          audio: false,
        });
        streamRef.current = stream;

        if (videoRef.current) {
          videoRef.current.srcObject = stream;
          await videoRef.current.play();
          setCameraReady(true);
        }
      } catch {
        setError("Không mở được camera. Hãy cấp quyền camera và thử lại.");
      }
    };

    if (!hasFaceConsent) {
      stopCamera();
      return undefined;
    }

    startCamera();

    return () => {
      if (stream) stream.getTracks().forEach((t) => t.stop());
      if (streamRef.current === stream) {
        streamRef.current = null;
        setCameraReady(false);
      }
    };
  }, [hasFaceConsent, stopCamera]);

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

  const handleAcceptFaceConsent = () => {
    setHasFaceConsent(true);
    setShowFaceConsentPrompt(false);
    setError("");
  };

  const handleCancelFaceConsent = () => {
    setError("");
    navigate("/login");
  };

  const handleScanOnce = async () => {
    setError("");
    setAttrs(null);
    setProcessingTimeMs(null);

    if (!hasFaceConsent) {
      setShowFaceConsentPrompt(true);
      return;
    }

    if (!cameraReady) {
      setError("Camera đang khởi động, vui lòng thử lại sau vài giây.");
      return;
    }

    try {
      setStage("scanning");

      const file = await captureToFile();

      // Edge infer: theo edge_api của bạn là identifyFace(file) (multipart)
      const raw = await edgeApi.FaceAnalysis(file);
      const norm = normalizeAttrs(raw);
      const latencyMs = Number(raw?.latency_ms ?? raw?.processing_time_ms ?? raw?.duration_ms);

      if (!norm) throw new Error("Edge API returned invalid attributes.");
      setAttrs(norm);
      setProcessingTimeMs(Number.isFinite(latencyMs) ? latencyMs : null);
      setStage("scanned");
    } catch (e) {
      setStage("idle");
      setError(e.message || "Scan failed");
    }
  };

  const handleGetRecommendations = async () => {
    if (!attrs) return;
    setError("");

    if (!hasFaceConsent) {
      setError("Vui lòng đồng ý cho phép xử lý dữ liệu khuôn mặt trước khi nhận gợi ý.");
      return;
    }

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
    setProcessingTimeMs(null);
    setPreviewUrl("");
    setShowFaceConsentPrompt(false);
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
            {showFaceConsentPrompt && !hasFaceConsent && (
              <div className="cameraCard__consentPrompt" role="dialog" aria-modal="true">
                <h3>Đồng ý xử lý dữ liệu khuôn mặt</h3>
                <p>
                  Hệ thống sẽ thu thập và xử lý ảnh khuôn mặt để phân tích đặc điểm
                  và đề xuất sản phẩm phù hợp trong phiên sử dụng này.
                </p>
                <div className="cameraCard__consentActions">
                  <button className="btn btn--primary" type="button" onClick={handleAcceptFaceConsent}>
                    Đồng ý và bật camera
                  </button>
                  <button className="btn btn--ghost" type="button" onClick={handleCancelFaceConsent}>
                    Không đồng ý
                  </button>
                </div>
              </div>
            )}
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

          <div className="predCard__metrics">
            <div className={`predMetric ${!attrs ? "predMetric--empty" : ""}`}>
              <span className="predMetric__label">Giới tính</span>
              <strong>{displayAttrs.gender}</strong>
            </div>
            <div className={`predMetric ${!attrs ? "predMetric--empty" : ""}`}>
              <span className="predMetric__label">Độ tuổi</span>
              <strong>{displayAttrs.age}</strong>
              {attrs?.age_group && <small>{displayAttrs.ageGroup}</small>}
            </div>
            <div className={`predMetric ${!attrs ? "predMetric--empty" : ""}`}>
              <span className="predMetric__label">Cảm xúc</span>
              <strong>{displayAttrs.emotion}</strong>
            </div>
            <div className={`predMetric ${processingTimeMs === null ? "predMetric--empty" : ""}`}>
              <span className="predMetric__label">Thời gian xử lý</span>
              <strong>{displayAttrs.processingTime}</strong>
            </div>
          </div>

          <div className="predCard__actions">
            <button
              className="btn btn--ghost"
              type="button"
              disabled={(hasFaceConsent && !cameraReady) || stage === "scanning" || stage === "recommending"}
              onClick={handleScanOnce}
            >
              {stage === "scanning" ? "Đang quét..." : "Quét 1 lượt"}
            </button>

            <button
              className="btn btn--secondary"
              type="button"
              disabled={!hasFaceConsent || !attrs || stage === "scanning" || stage === "recommending"}
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

          {error && <div className="alert">{error}</div>}

          <div className="predCard__tip">
            Mẹo: Nhìn thẳng, tháo kính (nếu có) và không che mặt.
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
