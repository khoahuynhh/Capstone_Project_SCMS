import { Navigate, Outlet } from "react-router-dom";
import { useAuth } from "../core/auth/useAuth";

export default function ProtectedRoute({ requireAdmin = false, requireCustomer = false }) {
  const { checking, isAuthenticated, user } = useAuth();
  const isAdmin = !!user?.account?.is_admin;
  const isCustomer = !!user?.customer;

  if (checking) {
    return (
      <div
        style={{
          minHeight: '100vh',
          display: 'grid',
          placeItems: 'center',
          background: 'linear-gradient(180deg, #f8fafc 0%, #eef2ff 100%)',
          color: '#0f172a',
        }}
      >
        <div style={{ textAlign: 'center' }}>
          <div
            style={{
              width: 40,
              height: 40,
              margin: '0 auto 12px',
              borderRadius: '999px',
              border: '3px solid rgba(37, 99, 235, 0.18)',
              borderTopColor: '#2563eb',
            }}
          />
          <div style={{ fontWeight: 700 }}>Đang kiểm tra phiên đăng nhập...</div>
        </div>
      </div>
    );
  }
  if (!isAuthenticated) return <Navigate to="/login" replace />;
  if (requireAdmin && !isAdmin) return <Navigate to="/product-dashboard" replace />;
  if (requireCustomer && !isCustomer) return <Navigate to="/dashboard" replace />;

  return <Outlet />;
}
