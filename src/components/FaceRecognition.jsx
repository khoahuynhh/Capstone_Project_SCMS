import { useState } from 'react';
// import { FaFaceViewfinder   } from 'react-icons/fa6';
import FaceRecognitionIcon from "./FaceRecognitionIcon";
import RegisterAccount from "./RegisterAccount";
import ProductRecommendation from "./ProductRecommendation";
import Camera from "./Camera";

const FaceRecognition = () => {
    // Các trạng thái của hệ thống
    const [status, setStatus] = useState('idle'); // idle, identifying, success, failed, registering
    const [customerData, setCustomerData] = useState(null);
    const [showNoDataModal, setShowNoDataModal] = useState(false);
    const [showRegisterForm, setShowRegisterForm] = useState(false);
    const [showProductRecommendation, setShowProductRecommendation] = useState(false);

    // Mock dữ liệu khách hàng
    const mockCustomerData = {
        firstName: 'Nguyen',
        lastName: 'Van An',
        id: '00123',
        contact: '0123456789',
        email: 'nguyenvanan@gmail.com',
        isLoyal: true,
        avatar: 'http://weart.vn/wp-content/uploads/2025/06/buc-ve-don-gian-mot-co-gai-de-thuong.jpg'
    };

    // Xử lý bắt đầu nhận diện
    const handleStartIdentification = () => {
        setStatus('identifying');
        
        // Giả lập quá trình nhận diện (2 giây)
        setTimeout(() => {
        // Giả lập kết quả random: 70% thành công, 30% thất bại
        const isSuccess = Math.random() > 0.3;
        
        if (isSuccess) {
            // setCustomerData(mockCustomerData);
            // setStatus('success');
            setStatus('failed');
            setShowNoDataModal(true);
            // Hiển thị trang gợi ý sản phẩm sau 1.5 giây
            setTimeout(() => {
                setShowProductRecommendation(true);
            }, 1500);
        } else {
            setStatus('failed');
            setShowNoDataModal(true);
            // setCustomerData(mockCustomerData);
            // setStatus('success');
            // Hiển thị trang gợi ý sản phẩm sau 1.5 giây
            setTimeout(() => {
                setShowProductRecommendation(true);
            }, 1500);
        }
        }, 2000);
    };

    // Xử lý reset
    const handleReset = () => {
        setStatus('idle');
        setCustomerData(null);
        setShowNoDataModal(false);
        setShowRegisterForm(false);
        setShowProductRecommendation(false);
    };

    // Xử lý cancel
    const handleCancel = () => {
        setShowNoDataModal(false);
        setShowRegisterForm(false);
        setStatus('idle');
    };

    // Xử lý mở form đăng ký
    const handleRegister = () => {
        setShowNoDataModal(false);
        setShowRegisterForm(true);
    };

    // Xử lý submit form đăng ký từ RegisterAccount component
    const handleSubmitRegister = (formData) => {
        // Xử lý logic đăng ký ở đây
        console.log('Registering new customer:', formData);
        
        // Giả lập API call
        setTimeout(() => {
        alert('Đăng ký thành công!');
        // Reset về trạng thái ban đầu
        handleReset();
        }, 1000);
    };

    // Xử lý đóng RegisterAccount
    const handleCloseRegister = () => {
        setShowRegisterForm(false);
        setStatus('idle');
    };

    return (
        <div className="min-h-screen bg-gradient-to-br from-[#03486c] to-[#00324D] flex items-center justify-center p-4">
        <div className="flex gap-8 max-w-6xl w-full">
            {/* Khung camera */}
            <div className="flex flex-col items-center">
            <div className="relative">
                <Camera  className="w-80 h-96  rounded-lg overflow-hidden relative">
                {/* Hình ảnh người dùng */}
                <div className="w-full h-full bg-cover bg-center" 
                    style={{backgroundImage: "url('http://weart.vn/wp-content/uploads/2025/06/buc-ve-don-gian-mot-co-gai-de-thuong.jpg')"}}
                />
                
                </Camera>
            </div>
            
            {/* Text và icon trạng thái */}
            <div className="mt-4 text-center">
                {status === 'identifying' && (
                <div className="flex items-center gap-2">
                    <div className="w-6 h-6 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                    <span className="text-white italic text-lg">Identifying</span>
                </div>
                )}
                
                {status === 'success' && (
                <div className="flex items-center justify-center">
                    <div className="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center">
                    <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
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
                    style=
                    {{
                    backgroundColor: "rgba(255, 255, 255, 0.49)", // nền trắng mờ
                    color: "#00324D", // chữ & icon xanh đậm
                    }}
                    onMouseDown={(e) => {
                    e.currentTarget.style.backgroundColor = "rgba(255, 255, 255, 0.7)";
                    e.currentTarget.style.color = "#00243A";
                    }}
                    onMouseUp={(e) => {
                    e.currentTarget.style.backgroundColor = "rgba(255, 255, 255, 0.49)";
                    e.currentTarget.style.color = "#00324D";
                    }}
                    onMouseLeave={(e) => {
                    e.currentTarget.style.backgroundColor = "rgba(255, 255, 255, 0.49)";
                    e.currentTarget.style.color = "#00324D";
                    }}
                >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                </svg>
                RESET
                </button>
                
                <button
                onClick={handleCancel}
                className="flex items-center gap-2 px-6 py-3 rounded-lg font-semibold transition-colors active:scale-95"
                    style=
                    {{
                    backgroundColor: "rgba(255, 255, 255, 0.49)", // nền trắng mờ
                    color: "#00324D", // chữ & icon xanh đậm
                    }}
                    onMouseDown={(e) => {
                    e.currentTarget.style.backgroundColor = "rgba(255, 255, 255, 0.7)";
                    e.currentTarget.style.color = "#00243A";
                    }}
                    onMouseUp={(e) => {
                    e.currentTarget.style.backgroundColor = "rgba(255, 255, 255, 0.49)";
                    e.currentTarget.style.color = "#00324D";
                    }}
                    onMouseLeave={(e) => {
                    e.currentTarget.style.backgroundColor = "rgba(255, 255, 255, 0.49)";
                    e.currentTarget.style.color = "#00324D";
                    }}
                >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
                CANCEL
                </button>
                
                <button
                onClick={() => setStatus('idle')}
                className="flex items-center gap-2 px-6 py-3 rounded-lg font-semibold transition-colors active:scale-95"
                    style=
                    {{
                    backgroundColor: "rgba(255, 255, 255, 0.49)", // nền trắng mờ
                    color: "#00324D", // chữ & icon xanh đậm
                    }}
                    onMouseDown={(e) => {
                    e.currentTarget.style.backgroundColor = "rgba(255, 255, 255, 0.7)";
                    e.currentTarget.style.color = "#00243A";
                    }}
                    onMouseUp={(e) => {
                    e.currentTarget.style.backgroundColor = "rgba(255, 255, 255, 0.49)";
                    e.currentTarget.style.color = "#00324D";
                    }}
                    onMouseLeave={(e) => {
                    e.currentTarget.style.backgroundColor = "rgba(255, 255, 255, 0.49)";
                    e.currentTarget.style.color = "#00324D";
                    }}
                disabled={status === 'identifying'}
                >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                </svg>
                NEXT
                </button>
            </div>
            </div>
            
            {/* Panel thông tin */}
            <div className="flex-1 ml-20">
            {/* Trạng thái ban đầu */}
            {status === 'idle' && (
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
            
            {/* Trạng thái đang nhận diện */}
            {status === 'identifying' && (
                <div className="bg-gray-400 bg-opacity-30 rounded-lg p-8 h-96">
                <div className="text-white italic text-xl mb-6">Identifying</div>
                <div className="space-y-4">
                    <div className="h-12 bg-gray-300 bg-opacity-50 rounded-lg animate-pulse"></div>
                    <div className="h-12 bg-gray-300 bg-opacity-50 rounded-lg animate-pulse"></div>
                    <div className="h-12 bg-gray-300 bg-opacity-50 rounded-lg animate-pulse"></div>
                </div>
                </div>
            )}
            
            {/* Trạng thái nhận diện thành công */}
            {status === 'success' && customerData && (
                <div className="bg-gray-400 bg-opacity-30 rounded-xl inline-block p-8">
                <div className="text-white italic text-xl mb-6">Identified</div>
                
                <div className="flex gap-6">
                    <div className="w-32 h-32 rounded-lg overflow-hidden bg-purple-400">
                    <img 
                        src="http://weart.vn/wp-content/uploads/2025/06/buc-ve-don-gian-mot-co-gai-de-thuong.jpg" 
                        alt="Customer" 
                        className="w-full h-full object-cover"
                    />
                    </div>
                    
                    <div className="flex-1 space-y-3">
                    <div className="bg-gray-300 bg-opacity-70 rounded-lg p-3">
                        <div className="text-sm text-gray-700 font-medium">FIRST NAME: {customerData.firstName}</div>
                    </div>
                    
                    <div className="bg-gray-300 bg-opacity-70 rounded-lg p-3">
                        <div className="text-sm text-gray-700 font-medium">LAST NAME: {customerData.lastName}</div>
                    </div>
                    
                    <div className="bg-gray-300 bg-opacity-70 rounded-lg p-3">
                        <div className="text-sm text-gray-700 font-medium">ID: {customerData.id}</div>
                    </div>

                    <div className="bg-gray-300 bg-opacity-70 rounded-lg p-3">
                        <div className="text-sm text-gray-700 font-medium">CONTACT: {customerData.contact}</div>
                    </div>

                    <div className="bg-gray-300 bg-opacity-70 rounded-lg p-3">
                        <div className="text-sm text-gray-700 font-medium">
                        LOYAL CUSTOMER: {customerData.isLoyal ? 'YES' : 'NO'}
                        </div>
                    </div>

                    <div className="bg-gray-300 bg-opacity-70 rounded-lg p-3">
                        <div className="text-sm text-gray-700 font-medium">OTHER: {customerData.other}</div>
                    </div>

                    </div>
                </div>
                
                <div className="mt-4 text-center">
                    <div className="text-lg font-semibold text-white">{customerData.lastName}</div>
                </div>
                </div>
            )}
            </div>
        </div>
        
        {/* Modal No Data Available */}
        {showNoDataModal && (
            <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg p-8 max-w-md w-full mx-4">
                <div className="text-center">
                <button
                    onClick={() => {
                    setShowNoDataModal(false);
                    setStatus('idle');
                    }}
                    className="absolute top-4 right-4 text-gray-400 hover:text-gray-600"
                >
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
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
            </div>
        )}
        
        {/* Component đăng ký tài khoản */}
        <RegisterAccount 
            isOpen={showRegisterForm}
            onClose={handleCloseRegister}
            onSubmit={handleSubmitRegister}
        />

        {/* Component gợi ý sản phẩm */}
        <ProductRecommendation 
            customer={customerData}
            isOpen={showProductRecommendation}
            onClose={() => setShowProductRecommendation(false)}
        />
        </div>
    );
};

export default FaceRecognition;