import { useState } from 'react';


const RegisterAccount = ({ isOpen, onClose, onSubmit }) => {
    const [showPassword, setShowPassword] = useState(false);
    const [formData, setFormData] = useState({
        lastName: '',
        firstName: '',
        birthDate: '',
        email: '',
        phone: '',
        cccd: '',
        gender: '',
        age: '',
        address: '',
        password: '',
        customerLevel: '',
        description: ''
    });
    const [formErrors, setFormErrors] = useState({});

    // Xử lý thay đổi form
    const handleFormChange = (field, value) => {
        setFormData(prev => ({
        ...prev,
        [field]: value
        }));
        
        // Xóa lỗi khi người dùng bắt đầu nhập
        if (formErrors[field]) {
        setFormErrors(prev => ({
            ...prev,
            [field]: ''
        }));
        }

        // Tự động tính tuổi khi nhập ngày sinh
        if (field === 'birthDate' && value) {
        const birthYear = new Date(value).getFullYear();
        const currentYear = new Date().getFullYear();
        const calculatedAge = currentYear - birthYear;
        setFormData(prev => ({
            ...prev,
            [field]: value,
            age: calculatedAge > 0 ? calculatedAge.toString() : ''
        }));
        }
    };

    // Validation functions
    const validateName = (name) => {
        const trimmed = name.trim(); // Loại bỏ khoảng trắng đầu/cuối
        const regex = /^[A-ZÀ-Ỵ][a-zà-ỹ]*(\s[A-ZÀ-Ỵ][a-zà-ỹ]*)*$/;
        return regex.test(trimmed);
    };

    const validateEmail = (email) => {
        const emailRegex = /^[^\s@]+@gmail\.com$/;
        return emailRegex.test(email);
    };

    const validatePhone = (phone) => {
        // Vietnamese phone format: 10-11 digits, starts with 0
        const phoneRegex = /^0[3|5|7|8|9][0-9]{8,9}$/;
        return phoneRegex.test(phone);
    };

    const validateCCCD = (cccd) => {
        // CCCD: 12 digits, CMND: 9 or 12 digits
        const cccdRegex = /^[0-9]{12}$/; // CCCD
        const cmndRegex = /^[0-9]{9}$/;  // CMND cũ
        return cccdRegex.test(cccd) || cmndRegex.test(cccd);
    };

    // Validate password format
    const validatePasswordFormat = (password) => {
        const errors = [];
        
        if (password.length < 8) {
            errors.push('Password must be at least 8 characters');
        }
        
        if (!/[A-Z]/.test(password)) {
            errors.push('Password must contain at least 1 uppercase letter');
        }
        
        if (!/[a-z]/.test(password)) {
            errors.push('Password must contain at least 1 lowercase letter');
        }
        
        if (!/[0-9]/.test(password)) {
            errors.push('Password must have at least 1 number');
        }
        
        if (!/[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?]/.test(password)) {
            errors.push('Password must contain at least 1 special character');
        }
        
        return errors;
    };

    // Check từng rule của PW
    const checkPasswordRules = (password) => {
        return {
            length: password.length >= 8,
            uppercase: /[A-Z]/.test(password),
            lowercase: /[a-z]/.test(password),
            number: /[0-9]/.test(password),
            special: /[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?]/.test(password),
        };
    };

    const passwordRules = checkPasswordRules(formData.password);

    // Validate toàn bộ form
    const validateForm = () => {
        const errors = {};

        // Validate lastName
        if (!formData.lastName.trim()) {
        errors.lastName = 'Last name cannot be empty';
        } else if (!validateName(formData.lastName)) {
        errors.lastName = 'Last name must start with a capital letter and contain at least 1 word';
        }

        // Validate firstName
        if (!formData.firstName.trim()) {
        errors.firstName = 'First name cannot be empty';
        } else if (!validateName(formData.firstName)) {
        errors.firstName = 'First name must start with a capital letter and contain at least 1 word';
        }

        // Validate birthDate
        if (!formData.birthDate) {
        errors.birthDate = 'Birth date cannot be empty';
        }
        else {
            const today = new Date().toISOString().split("T")[0];
            if(formData.birthDate >today){
                errors.birthDate = 'Birth date cannot be in the future';
            }
        }

        // Validate email
        if (!formData.email.trim()) {
        errors.email = 'Email cannot be empty';
        } else if (!validateEmail(formData.email)) {
        errors.email = 'Email must be in the format ...@gmail.com';
        }

        // Validate phone
        if (!formData.phone.trim()) {
        errors.phone = 'Phone number cannot be empty';
        } else if (!validatePhone(formData.phone)) {
        errors.phone = 'Phone number must be 10-11 digits and start with 03/05/07/08/09';
        }

        // Validate CCCD
        if (!formData.cccd.trim()) {
        errors.cccd = 'Identification number cannot be empty';
        } else if (!validateCCCD(formData.cccd)) {
        errors.cccd = 'Identification number must be exactly 12 digits';
        }

        // Validate gender
        if (!formData.gender) {
        errors.gender = 'Gender cannot be empty';
        }

        // Validate address
        if (!formData.address.trim()) {
        errors.address = 'Address cannot be empty';
        } else if (formData.address.trim().length < 10) {
            errors.address = 'Address must be at least 10 characters';
        }

        // Validate password
        if (!formData.password.trim()) {
        errors.password = 'Password cannot be empty';
        } else {
            const passwordErrors = validatePasswordFormat(formData.password);
            if (passwordErrors.length > 0) {
                errors.password = passwordErrors[0]; // Show first error
            }
        }

        // Validate customerLevel
        if (!formData.customerLevel.trim()) {
        errors.customerLevel = 'Customer level cannot be empty';
        }

        setFormErrors(errors);
        return Object.keys(errors).length === 0;
    };

    // Xử lý submit form
    const handleSubmit = () => {
        if (!validateForm()) {
        return; // Dừng lại nếu validation không thành công
        }
        
        // Gọi callback từ parent component
        onSubmit(formData);
        
        // Reset form
        resetForm();
    };

    // Reset form
    const resetForm = () => {
        setFormData({
        lastName: '',
        firstName: '',
        birthDate: '',
        email: '',
        phone: '',
        cccd: '',
        gender: '',
        age: '',
        address: '',
        password: '',
        customerLevel: '',
        description: ''
        });
        setFormErrors({});
    };

    // Toggle password visibility
    const togglePasswordVisibility = () => {
        setShowPassword(!showPassword);
    };    
    
    // Xử lý đóng modal
    const handleClose = () => {
        resetForm();
        onClose();
    };

    // Toggle password visibility
    // const togglePasswordVisibility = () => {
    //     setShowPassword(!showPassword);
    // };
    
    if (!isOpen) return null;

    return (
        <>
        <style>{`
            @keyframes fadeIn {
                from {
                opacity: 0;
                transform: translateY(-8px);
                }
                to {
                opacity: 1;
                transform: translateY(0);
            }
        `}</style>

        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 backdrop-blur-sm">
        <div className="bg-white rounded-lg p-8 max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto shadow-2xl transform transition-all duration-300 ease-out">
            <div className="relative">
            <h2 className="text-2xl font-bold text-gray-800 mb-6 text-center">Register for a Customer Account</h2>
            
            <button
                onClick={handleClose}
                className="absolute top-0 right-0 text-gray-400 hover:text-gray-600"
            >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
            </button>
            {/* </div> */}
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Họ */}
            <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                LAST NAME <span className="text-red-500">*</span>
                </label>
                <input
                type="text"
                value={formData.lastName}
                onChange={(e) => handleFormChange('lastName', e.target.value)}
                className={`w-full px-4 py-3 bg-gray-200 rounded-lg border-none focus:outline-none focus:ring-2 ${
                    formErrors.lastName ? 'focus:ring-red-500 ring-2 ring-red-500' : 'focus:ring-blue-500'
                }`}
                placeholder="Vd: Nguyễn"
                />
                {formErrors.lastName && (
                <p className="text-red-500 text-xs mt-1">{formErrors.lastName}</p>
                )}
            </div>
            
            {/* Tên */}
            <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                FIRST NAME <span className="text-red-500">*</span>
                </label>
                <input
                type="text"
                value={formData.firstName}
                onChange={(e) => handleFormChange('firstName', e.target.value)}
                className={`w-full px-4 py-3 bg-gray-200 rounded-lg border-none focus:outline-none focus:ring-2 ${
                    formErrors.firstName ? 'focus:ring-red-500 ring-2 ring-red-500' : 'focus:ring-blue-500'
                }`}
                placeholder="Vd: Minh An"
                />
                {formErrors.firstName && (
                <p className="text-red-500 text-xs mt-1">{formErrors.firstName}</p>
                )}
            </div>

            {/* Ngày sinh */}
            <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                DATE OF BIRTH <span className="text-red-500">*</span>
                </label>
                <input
                type="date"
                value={formData.birthDate}
                onChange={(e) => handleFormChange('birthDate', e.target.value)}
                max={new Date().toISOString().split("T")[0]} // Chặn chọn ngày trong tương lai
                className={`w-full px-4 py-3 bg-gray-200 rounded-lg border-none focus:outline-none focus:ring-2 ${
                    formErrors.birthDate ? 'focus:ring-red-500 ring-2 ring-red-500' : 'focus:ring-blue-500'
                }`}
                />
                {formErrors.birthDate && (
                <p className="text-red-500 text-xs mt-1">{formErrors.birthDate}</p>
                )}
            </div>

            {/* Tuổi */}
            <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">AGE</label>
                <input
                type="number"
                value={formData.age}
                readOnly
                className="w-full px-4 py-3 bg-gray-300 rounded-lg border-none focus:outline-none cursor-not-allowed"
                placeholder="The system will automatically calculate..."
                />
            </div>

            {/* Email */}
            <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                EMAIL <span className="text-red-500">*</span>
                </label>
                <input
                type="email"
                value={formData.email}
                onChange={(e) => handleFormChange('email', e.target.value)}
                className={`w-full px-4 py-3 bg-gray-200 rounded-lg border-none focus:outline-none focus:ring-2 ${
                    formErrors.email ? 'focus:ring-red-500 ring-2 ring-red-500' : 'focus:ring-blue-500'
                }`}
                placeholder="Vd: example@gmail.com"
                />
                {formErrors.email && (
                <p className="text-red-500 text-xs mt-1">{formErrors.email}</p>
                )}
            </div>

            {/* Số điện thoại */}
            <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                PHONE NUMBER <span className="text-red-500">*</span>
                </label>
                <input
                type="tel"
                value={formData.phone}
                onChange={(e) => handleFormChange('phone', e.target.value)}
                className={`w-full px-4 py-3 bg-gray-200 rounded-lg border-none focus:outline-none focus:ring-2 ${
                    formErrors.phone ? 'focus:ring-red-500 ring-2 ring-red-500' : 'focus:ring-blue-500'
                }`}
                placeholder="Vd: 0xxxxxxxxx"
                maxLength="11"
                />
                {formErrors.phone && (
                <p className="text-red-500 text-xs mt-1">{formErrors.phone}</p>
                )}
            </div>

            {/* CCCD */}
            <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                IDENTITY NUMBER <span className="text-red-500">*</span>
                </label>
                <input
                type="text"
                value={formData.cccd}
                onChange={(e) => handleFormChange('cccd', e.target.value)}
                className={`w-full px-4 py-3 bg-gray-200 rounded-lg border-none focus:outline-none focus:ring-2 ${
                    formErrors.cccd ? 'focus:ring-red-500 ring-2 ring-red-500' : 'focus:ring-blue-500'
                }`}
                placeholder="Vd: 123456789012"
                maxLength="12"
                />
                {formErrors.cccd && (
                <p className="text-red-500 text-xs mt-1">{formErrors.cccd}</p>
                )}
            </div>

            {/* Giới tính */}
            <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                GENDER <span className="text-red-500">*</span>
                </label>
                <select
                value={formData.gender}
                onChange={(e) => handleFormChange('gender', e.target.value)}
                className={`w-full px-4 py-3 bg-gray-200 rounded-lg border-none focus:outline-none focus:ring-2 ${
                    formErrors.gender ? 'focus:ring-red-500 ring-2 ring-red-500' : 'focus:ring-blue-500'
                }`}
                >
                <option value="">Select gender</option>
                <option value="male">Male</option>
                <option value="female">Female</option>
                </select>
                {formErrors.gender && (
                <p className="text-red-500 text-xs mt-1">{formErrors.gender}</p>
                )}
            </div>

            {/* Cấp độ khách hàng */}
            <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                CUSTOMER TIER <span className="text-red-500">*</span>
                </label>
                <select
                value={formData.customerLevel}
                onChange={(e) => handleFormChange('customerLevel', e.target.value)}
                className={`w-full px-4 py-3 bg-gray-200 rounded-lg border-none focus:outline-none focus:ring-2 ${
                    formErrors.customerLevel ? 'focus:ring-red-500 ring-2 ring-red-500' : 'focus:ring-blue-500'
                }`}
                >
                <option value="">Select customer tier</option>
                <option value="BASIC">BASIC</option>
                <option value="SILVER">SILVER</option>
                <option value="GOLD">GOLD</option>
                <option value="VIP">VIP</option>
                </select>
                {formErrors.customerLevel && (
                <p className="text-red-500 text-xs mt-1">{formErrors.customerLevel}</p>
                )}
            </div>

            {/* Mật khẩu */}
            <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                PASSWORD <span className="text-red-500">*</span>
                </label>
                <div className="relative group">
                    <input
                            type={showPassword ? "text" : "password"}
                            value={formData.password}
                            onChange={(e) => handleFormChange('password', e.target.value)}
                            className={`w-full px-4 py-3 pr-14 bg-gray-200 rounded-lg border-none focus:outline-none focus:ring-2 transition-all duration-200 ${
                            formErrors.password ? 'focus:ring-red-500 ring-2 ring-red-500 ' : 'focus:ring-blue-500 '
                        }`}
                        placeholder="At least 8 characters"
                    />
                    <button
                        type="button"
                        onClick={togglePasswordVisibility}
                        className="absolute right-2 top-1/2 transform -translate-y-1/2 p-2 rounded-full 
                                    hover:bg-gray-300 focus:bg-gray-300 focus:outline-none 
                                    transition-all duration-200 ease-in-out
                                    group-hover:bg-gray-100 active:scale-95"
                        title={showPassword ? "Ẩn mật khẩu" : "Hiển thị mật khẩu"}
                    >
                        {showPassword ? (
                            // Icon "Eye Slash" - Ẩn password với animation
                            <svg className="w-5 h-5 text-gray-600 hover:text-blue-600 transition-colors duration-200" 
                                fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} 
                                        d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} 
                                        d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                            </svg>
                        ) : (
                            // Icon "Eye" - Hiển thị password với animation
                                <svg className="w-5 h-5 text-gray-600 hover:text-gray-800 transition-colors duration-200" 
                                fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} 
                                        d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.523 10.523 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228l-3.65-3.65m0 0a3 3 0 11-4.243-4.243m4.242 4.242L9.88 9.88"/>
                            </svg>
                        )}
                    </button>

                    {/* Subtle visual feedback */}
                    <div className={`absolute inset-0 rounded-lg pointer-events-none transition-all duration-200 ${
                        showPassword ? 'ring-1 ring-blue-200 bg-blue-50 bg-opacity-20' : ''
                    }`}>
                    </div>
                </div>
                {formErrors.password && (
                    <p className="text-red-500 text-sm mt-1 opacity-0 animate-pulse" 
                        style={{
                        animation: 'fadeIn 0.3s ease-out forwards',
                        animationFillMode: 'forwards'
                        }}>
                        {formErrors.password}
                    </p>
                )}
                    <div className="mt-2 text-xs text-gray-600">
                        <p className="font-medium mb-1">Password required:</p>
                        <ul className="list-disc pl-4 space-y-1">
                            <li className={passwordRules.length ? "text-green-600" : "text-gray-600"}>At least 8 characters</li>
                            <li className={passwordRules.uppercase ? "text-green-600" : "text-gray-600"}>At least 1 uppercase letter (A-Z)</li>
                            <li className={passwordRules.lowercase ? "text-green-600" : "text-gray-600"}>At least 1 lowercase letter (a-z)</li>
                            <li className={passwordRules.number ? "text-green-600" : "text-gray-600"}>At least 1 number (0-9)</li>
                            <li className={passwordRules.special ? "text-green-600" : "text-gray-600"}>At least 1 special character (!@#$%^&*)</li>
                        </ul>
                    </div>
            </div>

            {/* Địa chỉ - full width */}
            <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                ADDRESS <span className="text-red-500">*</span>
                </label>
                <input
                type="text"
                value={formData.address}
                onChange={(e) => handleFormChange('address', e.target.value)}
                className={`w-full px-4 py-3 bg-gray-200 rounded-lg border-none focus:outline-none focus:ring-2 ${
                    formErrors.address ? 'focus:ring-red-500 ring-2 ring-red-500' : 'focus:ring-blue-500'
                }`}
                placeholder="Vd: 123 Đường ABC, Phường XYZ, Quận 1, TP.HCM"
                />
                {formErrors.address && (
                <p className="text-red-500 text-xs mt-1">{formErrors.address}</p>
                )}
            </div>

            {/* Mô tả - full width */}
            <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-2">DESCRIPTION</label>
                <textarea
                value={formData.description}
                onChange={(e) => handleFormChange('description', e.target.value)}
                className="w-full px-4 py-3 bg-gray-200 rounded-lg border-none focus:outline-none focus:ring-2 focus:ring-blue-500 h-24 resize-none"
                placeholder="Additional information about the customer..."
                />
            </div>
            </div>
            
            <button
            onClick={handleSubmit}
            className="w-full py-3 bg-[#03486c] hover:bg-[#00324D] active:bg-[#00324D] text-white rounded-lg font-semibold transition-colors active:scale-98 mt-6"
            >
            REGISTER ACCOUNT
            </button>
            </div>
        </div>
        </div>
        </>
    );
};

export default RegisterAccount;
