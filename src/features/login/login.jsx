import "./login.css";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { serverApi } from "../../core/api/server_api";
import { useAuth } from "../../core/auth/useAuth";

export default function Login() {
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
      setError("Please enter email and password.");
      return;
    }

    try {
      setLoading(true);

      await serverApi.login({ email: normalizedEmail, password });
      const userData = await checkSession();

      if (!userData) {
        setError("Không thể xác thực phiên đăng nhập. Vui lòng thử lại.");
        return;
      }

      if (userData?.account?.is_admin) {
        navigate("/dashboard", { replace: true, state: { admin: userData } });
        return;
      }

      navigate("/product-dashboard", { replace: true, state: { customer: userData } });
    } catch (err) {
      setError(err?.message || "Login failed");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-page">
      <div className="wrapper login-wrapper">
        <form onSubmit={handleSubmit}>
          <h2>Đăng nhập</h2>

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

          {error && <p style={{ marginTop: 8 }}>{error}</p>}

          <button type="submit" disabled={loading}>
            {loading ? "Đang đăng nhập..." : "Đăng nhập"}
          </button>

          {/* Add scan face decision */}
          <div style={{ marginTop: 12 }}>
            <button
              type="button"
              onClick={() => navigate("/edge-scan")}
              disabled={loading}
            >
              Quét khuôn mặt để khám phá sản phẩm khuyến mãi phù hợp với bản thân
            </button>
          </div>

          {/* Register line */}
          <div className="register">
            Chưa có tài khoản?{" "}
            <button
              type="button"
              className="link-button"
              onClick={() => navigate("/register")}
              disabled={loading}
            >
              Đăng ký
            </button>
          </div>

          {/* Link ẩn danh hoặc nhỏ dành cho Admin */}
          <div className="admin-login-link" style={{ marginTop: 20, textAlign: "center", fontSize: "12px" }}>
            <button
              type="button"
              className="link-button"
              style={{ color: "gray" }}
              onClick={() => navigate("/admin-login")}
              disabled={loading}
            >
              Đăng nhập dành cho Quản trị viên
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
