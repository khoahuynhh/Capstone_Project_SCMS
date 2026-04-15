import "./login.css";
import { useState } from "react";
import { serverApi } from "../../core/api/server_api";

const RegisterAccount = ({ isOpen = true, onClose, onSubmit }) => {
  const [status, setStatus] = useState({ type: '', message: '' });
  const [loading, setLoading] = useState(false);

  const [showPassword, setShowPassword] = useState(false);
  const [formData, setFormData] = useState({
    lastName: "",
    firstName: "",
    birthDate: "",
    email: "",
    phone: "",
    cccd: "",
    gender: "",
    age: "",
    address: "",
    password: "",
    //customerLevel: "",
    description: "",
  });
  const [formErrors, setFormErrors] = useState({});

  const handleFormChange = (field, value) => {
    setFormData((prev) => ({
      ...prev,
      [field]: value,
    }));

    if (formErrors[field]) {
      setFormErrors((prev) => ({
        ...prev,
        [field]: "",
      }));
    }

    if (field === "birthDate" && value) {
      const birthYear = new Date(value).getFullYear();
      const currentYear = new Date().getFullYear();
      const calculatedAge = currentYear - birthYear;
      setFormData((prev) => ({
        ...prev,
        [field]: value,
        age: calculatedAge > 0 ? calculatedAge.toString() : "",
      }));
    }
  };

  const validateName = (name) => {
    const trimmed = name.trim();
    const regex = /^[\p{L}][\p{L}'\s.-]*$/u;
    return regex.test(trimmed);
  };

  const validateEmail = (email) => {
    const emailRegex = /^[^\s@]+@gmail\.com$/;
    return emailRegex.test(email);
  };

  const validatePhone = (phone) => {
    const phoneRegex = /^0[3|5|7|8|9][0-9]{8,9}$/;
    return phoneRegex.test(phone);
  };

  const validateCCCD = (cccd) => {
    const cccdRegex = /^[0-9]{12}$/;
    const cmndRegex = /^[0-9]{9}$/;
    return cccdRegex.test(cccd) || cmndRegex.test(cccd);
  };

  const validatePasswordFormat = (password) => {
    const errors = [];

    if (password.length < 8) {
      errors.push("Password must be at least 8 characters");
    }

    if (!/[A-Z]/.test(password)) {
      errors.push("Password must contain at least 1 uppercase letter");
    }

    if (!/[a-z]/.test(password)) {
      errors.push("Password must contain at least 1 lowercase letter");
    }

    if (!/[0-9]/.test(password)) {
      errors.push("Password must have at least 1 number");
    }

    if (!/[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?]/.test(password)) {
      errors.push("Password must contain at least 1 special character");
    }

    return errors;
  };

  const checkPasswordRules = (password) => ({
    length: password.length >= 8,
    uppercase: /[A-Z]/.test(password),
    lowercase: /[a-z]/.test(password),
    number: /[0-9]/.test(password),
    special: /[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?]/.test(password),
  });

  const passwordRules = checkPasswordRules(formData.password);

  const validateForm = () => {
    const errors = {};

    if (!formData.lastName.trim()) {
      errors.lastName = "Last name cannot be empty";
    } else if (!validateName(formData.lastName)) {
      errors.lastName = "Last name must start with a capital letter and contain at least 1 word";
    }

    if (!formData.firstName.trim()) {
      errors.firstName = "First name cannot be empty";
    } else if (!validateName(formData.firstName)) {
      errors.firstName = "First name must start with a capital letter and contain at least 1 word";
    }

    if (!formData.birthDate) {
      errors.birthDate = "Birth date cannot be empty";
    } else {
      const today = new Date().toISOString().split("T")[0];
      if (formData.birthDate > today) {
        errors.birthDate = "Birth date cannot be in the future";
      }
    }

    if (!formData.email.trim()) {
      errors.email = "Email cannot be empty";
    } else if (!validateEmail(formData.email)) {
      errors.email = "Email must be in the format ...@gmail.com";
    }

    if (!formData.phone.trim()) {
      errors.phone = "Phone number cannot be empty";
    } else if (!validatePhone(formData.phone)) {
      errors.phone = "Phone number must be 10-11 digits and start with 03/05/07/08/09";
    }

    if (!formData.cccd.trim()) {
      errors.cccd = "Identification number cannot be empty";
    } else if (!validateCCCD(formData.cccd)) {
      errors.cccd = "Identification number must be exactly 12 digits";
    }

    if (!formData.gender) {
      errors.gender = "Gender cannot be empty";
    }

    if (!formData.address.trim()) {
      errors.address = "Address cannot be empty";
    } else if (formData.address.trim().length < 10) {
      errors.address = "Address must be at least 10 characters";
    }

    if (!formData.password.trim()) {
      errors.password = "Password cannot be empty";
    } else {
      const passwordErrors = validatePasswordFormat(formData.password);
      if (passwordErrors.length > 0) {
        errors.password = passwordErrors[0];
      }
    }

    // if (!formData.customerLevel.trim()) {
    //   errors.customerLevel = "Customer level cannot be empty";
    // }

    setFormErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const resetForm = () => {
    setFormData({
      lastName: "",
      firstName: "",
      birthDate: "",
      email: "",
      phone: "",
      cccd: "",
      gender: "",
      age: "",
      address: "",
      password: "",
      // customerLevel: "",
      description: "",
    });
    setFormErrors({});
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    
    // Reset status cũ
    setStatus({ type: '', message: '' });

    // Validate trước khi gửi
    if (!validateForm()) return;

    setLoading(true);

    try {
      // Gọi API đăng ký
      await serverApi.register(formData);

      // -- THÀNH CÔNG --
      setStatus({ 
        type: 'success', 
        message: 'Account registered successfully!' 
      });

      // Gọi prop onSubmit nếu cha cần biết
      if (typeof onSubmit === "function") {
        onSubmit(formData);
      }

      // Reset form sau 1 giây hoặc chuyển trang
      setTimeout(() => {
         handleClose(); // Nếu muốn đóng form
         window.location.href = '/login'; // Nếu muốn chuyển trang
      }, 1500);

    } catch (error) {
      // -- LỖI --
      setStatus({ 
        type: 'error', 
        message: error.message || "Something went wrong. Please try again."
      });
    } finally {
      setLoading(false);
    }
  };

  const togglePasswordVisibility = () => {
    setShowPassword((prev) => !prev);
  };

  const handleClose = () => {
    resetForm();
    if (typeof onClose === "function") {
      onClose();
    }
  };

  const getFieldClass = (field) =>
    `field-input${formErrors[field] ? " field-input-error" : ""}`;

  if (!isOpen) return null;

  return (
    <div className="login-page">
      <div className="wrapper register-wrapper">
        <form onSubmit={handleSubmit}>
          <div className="form-header">
            <h2>Register account</h2>
            {onClose && (
              <button
                type="button"
                className="icon-button"
                onClick={handleClose}
                aria-label="Close"
              >
                &times;
              </button>
            )}
          </div>

          <div className="register-grid">
            <div className="field">
              <label htmlFor="register-last-name">
                Last name <span aria-hidden="true">*</span>
              </label>
              <input
                id="register-last-name"
                type="text"
                value={formData.lastName}
                onChange={(e) => handleFormChange("lastName", e.target.value)}
                className={getFieldClass("lastName")}
                placeholder="Example: Nguyen"
              />
              {formErrors.lastName && (
                <p className="field-error">{formErrors.lastName}</p>
              )}
            </div>

            <div className="field">
              <label htmlFor="register-first-name">
                First name <span aria-hidden="true">*</span>
              </label>
              <input
                id="register-first-name"
                type="text"
                value={formData.firstName}
                onChange={(e) => handleFormChange("firstName", e.target.value)}
                className={getFieldClass("firstName")}
                placeholder="Example: Minh An"
              />
              {formErrors.firstName && (
                <p className="field-error">{formErrors.firstName}</p>
              )}
            </div>

            <div className="field">
              <label htmlFor="register-birth-date">
                Date of birth (MM/DD/YYYY) <span aria-hidden="true">*</span>
              </label>
              <input
                id="register-birth-date"
                type="date"
                value={formData.birthDate}
                onChange={(e) => handleFormChange("birthDate", e.target.value)}
                max={new Date().toISOString().split("T")[0]}
                className={getFieldClass("birthDate")}
              />
              {formErrors.birthDate && (
                <p className="field-error">{formErrors.birthDate}</p>
              )}
            </div>

            <div className="field">
              <label htmlFor="register-age">Age</label>
              <input
                id="register-age"
                type="number"
                value={formData.age}
                readOnly
                className="field-input"
                placeholder="Calculated automatically"
              />
            </div>

            <div className="field">
              <label htmlFor="register-email">
                Email <span aria-hidden="true">*</span>
              </label>
              <input
                id="register-email"
                type="email"
                value={formData.email}
                onChange={(e) => handleFormChange("email", e.target.value)}
                className={getFieldClass("email")}
                placeholder="example@gmail.com"
              />
              {formErrors.email && (
                <p className="field-error">{formErrors.email}</p>
              )}
            </div>

            <div className="field">
              <label htmlFor="register-phone">
                Phone number <span aria-hidden="true">*</span>
              </label>
              <input
                id="register-phone"
                type="tel"
                value={formData.phone}
                onChange={(e) => handleFormChange("phone", e.target.value)}
                className={getFieldClass("phone")}
                placeholder="0xxxxxxxxx"
                maxLength="11"
              />
              {formErrors.phone && (
                <p className="field-error">{formErrors.phone}</p>
              )}
            </div>

            <div className="field">
              <label htmlFor="register-cccd">
                Identity number <span aria-hidden="true">*</span>
              </label>
              <input
                id="register-cccd"
                type="text"
                value={formData.cccd}
                onChange={(e) => handleFormChange("cccd", e.target.value)}
                className={getFieldClass("cccd")}
                placeholder="123456789012"
                maxLength="12"
              />
              {formErrors.cccd && (
                <p className="field-error">{formErrors.cccd}</p>
              )}
            </div>

            <div className="field">
              <label htmlFor="register-gender">
                Gender <span aria-hidden="true">*</span>
              </label>
              <select
                id="register-gender"
                value={formData.gender}
                onChange={(e) => handleFormChange("gender", e.target.value)}
                className={getFieldClass("gender")}
              >
                <option value="">Select gender</option>
                <option value="male">Male</option>
                <option value="female">Female</option>
              </select>
              {formErrors.gender && (
                <p className="field-error">{formErrors.gender}</p>
              )}
            </div>

            {/* <div className="field">
              <label htmlFor="register-level">
                Customer tier <span aria-hidden="true">*</span>
              </label>
              <select
                id="register-level"
                value={formData.customerLevel}
                onChange={(e) => handleFormChange("customerLevel", e.target.value)}
                className={getFieldClass("customerLevel")}
              >
                <option value="">Select customer tier</option>
                <option value="BASIC">BASIC</option>
                <option value="SILVER">SILVER</option>
                <option value="GOLD">GOLD</option>
                <option value="VIP">VIP</option>
              </select>
              {formErrors.customerLevel && (
                <p className="field-error">{formErrors.customerLevel}</p>
              )}
            </div> */}

            <div className="field field-span">
              <label htmlFor="register-password">
                Password <span aria-hidden="true">*</span>
              </label>
              <div className="input-with-button">
                <input
                  id="register-password"
                  type={showPassword ? "text" : "password"}
                  value={formData.password}
                  onChange={(e) => handleFormChange("password", e.target.value)}
                  className={getFieldClass("password")}
                  placeholder="At least 8 characters"
                />
                <button
                  type="button"
                  className="password-toggle"
                  onClick={togglePasswordVisibility}
                >
                  {showPassword ? "Hide" : "Show"}
                </button>
              </div>
              {formErrors.password && (
                <p className="field-error">{formErrors.password}</p>
              )}
              <div className="password-rules">
                <div>Password required:</div>
                <ul>
                  <li className={passwordRules.length ? "password-ok" : ""}>
                    At least 8 characters
                  </li>
                  <li className={passwordRules.uppercase ? "password-ok" : ""}>
                    At least 1 uppercase letter (A-Z)
                  </li>
                  <li className={passwordRules.lowercase ? "password-ok" : ""}>
                    At least 1 lowercase letter (a-z)
                  </li>
                  <li className={passwordRules.number ? "password-ok" : ""}>
                    At least 1 number (0-9)
                  </li>
                  <li className={passwordRules.special ? "password-ok" : ""}>
                    At least 1 special character (!@#$%^&*)
                  </li>
                </ul>
              </div>
            </div>

            <div className="field field-span">
              <label htmlFor="register-address">
                Address <span aria-hidden="true">*</span>
              </label>
              <input
                id="register-address"
                type="text"
                value={formData.address}
                onChange={(e) => handleFormChange("address", e.target.value)}
                className={getFieldClass("address")}
                placeholder="123 ABC street, Ward XYZ, District 1"
              />
              {formErrors.address && (
                <p className="field-error">{formErrors.address}</p>
              )}
            </div>

            <div className="field field-span">
              <label htmlFor="register-description">Description</label>
              <textarea
                id="register-description"
                value={formData.description}
                onChange={(e) => handleFormChange("description", e.target.value)}
                className="field-input"
                rows={3}
                placeholder="Additional information about the customer..."
              />
            </div>
          </div>

          <div style={{ marginTop: '20px' }}>
            {/* Alert Box hiển thị trạng thái */}
            {status.message && (
                <div className={`status-alert ${status.type === 'error' ? 'status-error' : 'status-success'}`}>
                    {/* Icon tùy chọn */}
                    <span className="status-icon">
                        {status.type === 'error' ? '⚠️' : '✅'}
                    </span>
                    <span>{status.message}</span>
                </div>
            )}

            {/* Nút bấm duy nhất */}
            <button type="submit" disabled={loading} style={{ marginTop: '10px', width: '100%' }}>
               {loading ? 'Processing...' : 'Register account'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default RegisterAccount;
