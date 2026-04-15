import { Routes, Route, Navigate } from "react-router-dom";
import Login from "../features/login/login.jsx";
import AdminLogin from "../features/login/adminLogin.jsx";
import RegisterPage from "../pages/RegisterPage.jsx";
import DashboardPage from "../pages/Dashboard.jsx";
import DashboardProduct from "../features/face-recognition/components/ProductRecommendation.jsx"; 
import EdgeScanPage from "../features/face-recognition/components/FaceScan.jsx";
import AIRecommendationPage from "../features/face-recognition/components/FaceAIRecommendation.jsx";
import ProtectedRoute from "../routes/ProtectedRoute.jsx";

export default function App() {
  return (
    <Routes>
      {/* ==========================================
          1. PUBLIC ROUTES (Ai cũng có thể truy cập)
          ========================================== */}
      <Route path="/login" element={<Login />} />
      <Route path="/admin-login" element={<AdminLogin />} />
      <Route path="/register" element={<RegisterPage />} />
      
      {/* Các trang tính năng Scan (nếu bạn muốn cho xem thử trước khi login) */}
      <Route path="/edge-scan" element={<EdgeScanPage />} />
      <Route path="/explore" element={<AIRecommendationPage />} />


      {/* ==========================================
          2. PROTECTED ROUTES (Phải Login mới vào được)
          ========================================== */}
      <Route element={<ProtectedRoute requireCustomer />}>
        {/* Route dành riêng cho Khách hàng theo quy định của bạn */}
        <Route path="/product-dashboard" element={<DashboardProduct />} />
      </Route>

      <Route element={<ProtectedRoute requireAdmin />}>
        {/* Route dành riêng cho Admin */}
        <Route path="/dashboard" element={<DashboardPage />} />
      </Route>


      {/* ==========================================
          3. REDIRECTS (Điều hướng mặc định)
          ========================================== */}
      {/* Khi vào trang chủ, đẩy ra trang login */}
      <Route path="/" element={<Navigate to="/login" replace />} />

      {/* Xử lý khi người dùng gõ sai URL (404) */}
      <Route path="*" element={<Navigate to="/login" replace />} />
    </Routes>
  );
}
