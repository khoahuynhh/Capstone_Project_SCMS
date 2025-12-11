import { useState } from 'react';
import FaceRecognitionIcon from "./FaceRecognitionIcon";
import RegisterAccount from "./RegisterAccount";
import ProductRecommendation from "./ProductRecommendation";
import Camera from "./Camera";

const FaceRecognition = () => {
  // Các trạng thái của hệ thống
  const [status, setStatus] = useState("idle"); // idle, identifying, success, failed
  const [customerData, setCustomerData] = useState(null);
  const [showNoDataModal, setShowNoDataModal] = useState(false);
  const [showRegisterForm, setShowRegisterForm] = useState(false);
  const [showProductRecommendation, setShowProductRecommendation] = useState(false);

  // trigger cho Camera: mỗi lần tăng 1 là yêu cầu chụp + gửi API
  const [captureToken, setCaptureToken] = useState(0);

  // Bấm nút Start → đổi trạng thái + yêu cầu Camera chụp
  const handleStartIdentification = () => {
    setStatus("identifying");
    setCustomerData(null);
    setShowNoDataModal(false);
    setShowProductRecommendation(false);
    setCaptureToken((prev) => prev + 1);
  };

  // Nhận kết quả từ Camera (gọi API edge xong)
  // result là JSON backend trả về, ví dụ:
  // { success: true, customer: {...}, similarity, embedding, reason }
  const handleRecognitionResult = (result) => {
    // Camera có thể gọi onResult(null) nếu lỗi nặng
    if (!result) {
      setStatus("failed");
      setShowNoDataModal(true);
      return;
    }

    if (result.success && result.customer) {
      // Nhận diện thành công: có customer trong hệ thống
      setCustomerData(result.customer);
      setStatus("success");
      setShowProductRecommendation(true);
    } else {
      // Không tìm thấy trong DB edge → cho đăng ký
      setStatus("failed");
      setShowNoDataModal(true);

      // Nếu bạn muốn vẫn show gợi ý (ví dụ mặc định theo chi nhánh) thì giữ đoạn này
      setTimeout(() => {
        setShowProductRecommendation(true);
      }, 1500);
    }
  };

  // Reset mọi thứ
  const handleReset = () => {
    setStatus("idle");
    setCustomerData(null);
    setShowNoDataModal(false);
    setShowRegisterForm(false);
    setShowProductRecommendation(false);
  };

  const handleCancel = () => {
    setShowNoDataModal(false);
    setShowRegisterForm(false);
    setStatus("idle");
  };

  const handleRegister = () => {
    setShowNoDataModal(false);
    setShowRegisterForm(true);
  };

  const handleSubmitRegister = (formData) => {
    // TODO: gọi API đăng ký khách hàng mới ở server BE
    console.log("Registering new customer:", formData);

    setTimeout(() => {
      alert("Đăng ký thành công!");
      handleReset();
    }, 1000);
  };

  const handleCloseRegister = () => {
    setShowRegisterForm(false);
    setStatus("idle");
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#03486c] to-[#00324D] flex items-center justify-center p-4">
      <div className="flex gap-8 max-w-6xl w-full">
        {/* Khung camera */}
        <div className="flex flex-col items-center">
          <div className="relative">
            <Camera
              className="w-80 h-96 rounded-lg overflow-hidden relative"
              captureToken={captureToken}         // ⬅️ mỗi lần đổi sẽ chụp + gửi API
              onResult={handleRecognitionResult}  // ⬅️ nhận kết quả nhận diện từ edge API
            />
          </div>

          {/* Text và icon trạng thái */}
          <div className="mt-4 text-center">
            {status === "identifying" && (
              <div className="flex items-center gap-2">
                <div className="w-6 h-6 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                <span className="text-white italic text-lg">Identifying</span>
              </div>
            )}

            {status === "success" && (
              <div className="flex items-center justify-center">
                <div className="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center">
                  <svg
                    className="w-5 h-5 text-white"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M5 13l4 4L19 7"
                    />
                  </svg>
                </div>
              </div>
            )}
          </div>

          {/* Các nút điều khiển */}
          <div className="flex gap-4 mt-40">
            <button
              onClick={handleReset}
              className="flex items-center gap-2 px-6 py-3 rounded-lg font-semibold transition-colors active:scale-95"
              style={{
                backgroundColor: "rgba(255, 255, 255, 0.49)",
                color: "#00324D",
              }}
            >
              {/* icon RESET */}
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                      d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
              RESET
            </button>

            <button
              onClick={handleCancel}
              className="flex items-center gap-2 px-6 py-3 rounded-lg font-semibold transition-colors active:scale-95"
              style={{
                backgroundColor: "rgba(255, 255, 255, 0.49)",
                color: "#00324D",
              }}
            >
              {/* icon CANCEL */}
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                      d="M6 18L18 6M6 6l12 12" />
              </svg>
              CANCEL
            </button>

            <button
              onClick={() => setStatus("idle")}
              className="flex items-center gap-2 px-6 py-3 rounded-lg font-semibold transition-colors active:scale-95"
              style={{
                backgroundColor: "rgba(255, 255, 255, 0.49)",
                color: "#00324D",
              }}
              disabled={status === "identifying"}
            >
              {/* icon NEXT */}
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                      d="M9 5l7 7-7 7" />
              </svg>
              NEXT
            </button>
          </div>
        </div>

        {/* Panel thông tin bên phải */}
        <div className="flex-1 ml-20">
          {status === "idle" && (
            <div className="bg-gray-400 bg-opacity-30 rounded-lg p-8 h-96">
              <div className="text-white italic text-xl mb-6">Identifying</div>
              <div className="space-y-4">
                <div className="h-12 bg-gray-300 bg-opacity-50 rounded-lg"></div>
                <div className="h-12 bg-gray-300 bg-opacity-50 rounded-lg"></div>
                <div className="h-12 bg-gray-300 bg-opacity-50 rounded-lg"></div>
              </div>
              <div className="mt-8">
                <button
                  onClick={handleStartIdentification}
                  className="w-full py-3 bg-[#03486c] hover:bg-[#00324D] active:bg-[#00324D] text-white rounded-lg font-semibold transition-colors active:scale-98"
                >
                  Start Identification
                </button>
              </div>
            </div>
          )}

          {status === "identifying" && (
            <div className="bg-gray-400 bg-opacity-30 rounded-lg p-8 h-96">
              <div className="text-white italic text-xl mb-6">Identifying</div>
              <div className="space-y-4">
                <div className="h-12 bg-gray-300 bg-opacity-50 rounded-lg animate-pulse"></div>
                <div className="h-12 bg-gray-300 bg-opacity-50 rounded-lg animate-pulse"></div>
                <div className="h-12 bg-gray-300 bg-opacity-50 rounded-lg animate-pulse"></div>
              </div>
            </div>
          )}

          {status === "success" && customerData && (
            <div className="bg-gray-400 bg-opacity-30 rounded-xl inline-block p-8">
              <div className="text-white italic text-xl mb-6">Identified</div>
              {/* ... phần hiển thị customerData giữ nguyên như bạn đang có ... */}
            </div>
          )}
        </div>
      </div>

      {/* Modal No Data Available */}
      {showNoDataModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-8 max-w-md w-full mx-4 relative">
            <button
              onClick={() => {
                setShowNoDataModal(false);
                setStatus("idle");
              }}
              className="absolute top-4 right-4 text-gray-400 hover:text-gray-600"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                      d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>

            <div className="w-16 h-16 bg-orange-500 rounded-full flex items-center justify-center mx-auto mb-4">
              <span className="text-white text-2xl font-bold">!</span>
            </div>

            <h3 className="text-xl font-semibold text-gray-800 mb-6">No data available</h3>

            <button
              onClick={handleRegister}
              className="w-full py-3 bg-[#03486c] hover:bg-[#00324D] active:bg-[#00324D] text-white rounded-lg font-semibold transition-colors active:scale-98"
            >
              REGISTER
            </button>
          </div>
        </div>
      )}

      <RegisterAccount
        isOpen={showRegisterForm}
        onClose={handleCloseRegister}
        onSubmit={handleSubmitRegister}
      />

      <ProductRecommendation
        customer={customerData}
        isOpen={showProductRecommendation}
        onClose={() => setShowProductRecommendation(false)}
      />
    </div>
  );
};

export default FaceRecognition;
