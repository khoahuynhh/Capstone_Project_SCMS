import { useNavigate } from "react-router-dom";
import RegisterAccount from "../features/login/RegisterAccount.jsx";

export default function RegisterPage() {
  const navigate = useNavigate();

  return (
    <RegisterAccount
      isOpen={true}
      onClose={() => navigate("/login")}
    />
  );
}
