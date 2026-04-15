import "./login.css";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { serverApi } from "../../core/api/server_api";
import { useAuth } from "../../core/auth/useAuth";

export default function AdminLogin() {
  const navigate = useNavigate();
  const { checkSession } = useAuth();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    const normalizedEmail = email.trim();

    if (!normalizedEmail || !password) {
      setError("Vui lòng nhập email và mật khẩu.");
      return;
    }

    try {
      setLoading(true);

      await serverApi.login({ email: normalizedEmail, password }); 
      
      const adminData = await checkSession();
      
      // BƯỚC BẢO MẬT: Kiểm tra xem user này có thực sự là Admin không
      // Tuỳ vào cách backend trả dữ liệu mà biến này có thể là adminData.role === 'admin'
      if (!adminData.account.is_admin) {
        await serverApi.logout().catch(() => {});
        setError("Truy cập bị từ chối. Tài khoản này không có quyền quản trị.");
        return;
      }

      // Điều hướng tới trang Dashboard của Admin
      navigate("/dashboard", { replace: true, state: { admin: adminData } });
    } catch (err) {
      setError(err?.message || "Đăng nhập thất bại");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-page">
      <div className="wrapper">
        <form onSubmit={handleSubmit}>
          {/* Đổi tiêu đề để phân biệt */}
          <h2 style={{ color: "#d32f2f" }}>Đăng nhập</h2>

          <div className="input-field">
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
            <label>Nhập email của bạn</label>
          </div>

          <div className="input-field">
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
            <label>Nhập mật khẩu của bạn</label>
          </div>

          {error && <p style={{ marginTop: 8, color: "red" }}>{error}</p>}

          <button type="submit" disabled={loading}>
            {loading ? "Đang xác thực..." : "Đăng nhập"}
          </button>

          {/* Nút quay lại trang khách hàng */}
          <div style={{ marginTop: 20, textAlign: "center" }}>
            <button
              type="button"
              className="link-button"
              onClick={() => navigate("/login")}
              disabled={loading}
            >
              &larr; Quay lại
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
