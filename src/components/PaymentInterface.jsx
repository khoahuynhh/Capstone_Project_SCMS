import React, { useState, useEffect } from 'react';
import Receipt from './Receipt';

const PaymentInterface = ({ selectedProducts = [], customerInfo = null, onBack, onPaymentComplete }) => {
    const [paymentMethod, setPaymentMethod] = useState('cash');
    const [paidAmount, setPaidAmount] = useState('');
    const [paymentStatus, setPaymentStatus] = useState('pending'); // pending, processing, success, failed
    const [loyaltyPoints, setLoyaltyPoints] = useState(0);
    const [discountApplied, setDiscountApplied] = useState(0);
    const [showReceipt, setShowReceipt] = useState(false);
    const [orderDetails, setOrderDetails] = useState(null);
    const [showSuggestions, setShowSuggestions] = useState(true);
  
    // Thông tin mặc định cho demo
    const defaultCustomer = {
        name: "Nguyễn Văn A",
        customerId: "KH001234",
        phone: "0987654321",
        loyaltyPoints: 1250,
        membershipLevel: "VIP",
        totalSpent: 15000000
    };

    const customer = customerInfo || defaultCustomer;

  // Sản phẩm đề xuất dựa trên đơn hàng hiện tại
    const suggestedProducts = [
    {
        id: 'acc1',
        name: 'Ốp lưng iPhone 15 Pro Max',
        image: '/api/placeholder/80/80',
        price: 299000,
        reason: 'Phụ kiện phù hợp'
    },
    {
        id: 'acc2', 
        name: 'Cáp Lightning to USB-C',
        image: '/api/placeholder/80/80',
        price: 450000,
        reason: 'Thường mua cùng'
    },
    {
        id: 'acc3',
        name: 'AirPods 3rd Generation',
        image: '/api/placeholder/80/80',
        price: 4990000,
        reason: 'Combo hoàn hảo'
    }
  ];

    // Tính toán giá trị đơn hàng
    const subtotal = selectedProducts.reduce((sum, product) => sum + (product.price * product.quantity), 0);
    const tax = subtotal * 0.1; // 10% VAT
    const discount = discountApplied;
    const totalAmount = subtotal + tax - discount;
    const change = paidAmount ? Math.max(0, parseFloat(paidAmount) - totalAmount) : 0;

    // Tích điểm tích lũy mới
    useEffect(() => {
        setLoyaltyPoints(Math.floor(totalAmount / 10000)); // 1 điểm/10k VND
    }, [totalAmount]);

    const handleApplyDiscount = (type) => {
        switch(type) {
        case 'loyalty':
            if (customer.loyaltyPoints >= 100) {
            setDiscountApplied(Math.min(customer.loyaltyPoints * 1000, subtotal * 0.2)); // Tối đa 20%
            }
            break;
        case 'member':
            if (customer.membershipLevel === 'VIP') {
            setDiscountApplied(subtotal * 0.15); // 15% cho VIP
            } else {
            setDiscountApplied(subtotal * 0.05); // 5% cho thành viên thường
            }
            break;
        default:
            setDiscountApplied(0);
        }
    };

    const addSuggestedProduct = (product) => {
        // Logic thêm sản phẩm gợi ý vào giỏ hàng
        console.log('Added suggested product:', product);
        // Ở đây bạn có thể callback để thêm vào giỏ hàng chính
    };

    const handlePayment = async () => {
        setPaymentStatus('processing');
        
        // Simulate payment processing
        setTimeout(() => {
        if (paymentMethod === 'cash' && parseFloat(paidAmount) >= totalAmount) {
            const details = {
            orderId: `DH${Date.now().toString().slice(-6)}`,
            products: selectedProducts,
            subtotal,
            tax,
            discount,
            orderTotal: totalAmount,
            paidAmount: parseFloat(paidAmount),
            change,
            paymentMethod,
            loyaltyPoints
            };
            setOrderDetails(details);
            setPaymentStatus('success');
            setTimeout(() => {
            setShowReceipt(true);
            }, 2000);
        } else if (paymentMethod !== 'cash') {
            const details = {
            orderId: `DH${Date.now().toString().slice(-6)}`,
            products: selectedProducts,
            subtotal,
            tax,
            discount,
            orderTotal: totalAmount,
            paidAmount: totalAmount,
            change: 0,
            paymentMethod,
            loyaltyPoints
            };
            setOrderDetails(details);
            setPaymentStatus('success');
            setTimeout(() => {
            setShowReceipt(true);
            }, 2000);
        } else {
            setPaymentStatus('failed');
            setTimeout(() => setPaymentStatus('pending'), 2000);
        }
        }, 2000);
    };

    const formatCurrency = (amount) => {
        return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND'
        }).format(amount);
    };

    // Show receipt if payment successful
    if (showReceipt && orderDetails) {
        return (
        <Receipt
            orderDetails={orderDetails}
            customerInfo={customer}
            onClose={() => {
            setShowReceipt(false);
            onPaymentComplete?.(orderDetails);
            }}
            onPrintReceipt={() => {
            console.log('Printing receipt...');
            }}
        />
        );
    }

    // Check if cart is empty
    if (!selectedProducts || selectedProducts.length === 0) {
        return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex z-50 backdrop-blur-sm">
            <div className="w-full h-full bg-white animate-slide-in-right flex flex-col">
            <div className="bg-gradient-to-br from-[#03486c] to-[#00324D] text-white p-6 shadow-lg flex-shrink-0">
                <div className="flex items-center justify-between">
                <div className="flex items-center space-x-4">
                    <div className="w-12 h-12 bg-white bg-opacity-20 rounded-full flex items-center justify-center">
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 3h2l.4 2M7 13h10l4-8H5.4m0 0L7 13m0 0l-2.5 5L17 18" />
                    </svg>
                    </div>
                    <div>
                    <h1 className="text-2xl font-bold">Thanh Toán</h1>
                    <p className="text-blue-100">Giỏ hàng trống</p>
                    </div>
                </div>
                <button
                    onClick={onBack}
                    className="p-2 hover:bg-white hover:bg-opacity-20 rounded-full transition-colors"
                >
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
                </div>
            </div>
            
            <div className="flex-1 flex items-center justify-center bg-gray-50">
                <div className="text-center p-8">
                <div className="w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-6">
                    <svg className="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 3h2l.4 2M7 13h10l4-8H5.4m0 0L7 13m0 0l-2.5 5L17 18" />
                    </svg>
                </div>
                <h2 className="text-2xl font-bold text-gray-800 mb-4">Giỏ hàng trống</h2>
                <p className="text-gray-600 mb-6">
                    Bạn chưa có sản phẩm nào trong giỏ hàng. 
                    <br />
                    Hãy quay lại và chọn sản phẩm để tiếp tục mua sắm.
                </p>
                <button
                    onClick={onBack}
                    className="bg-blue-600 hover:bg-blue-700 text-white py-3 px-6 rounded-lg font-semibold transition-colors inline-flex items-center"
                >
                    <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                    </svg>
                    Quay lại mua sắm
                </button>
                </div>
            </div>
            </div>
        </div>
        );
    }

    return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex z-50 backdrop-blur-sm">
        <div className="w-full h-full bg-white animate-slide-in-right flex flex-col">{/* Styled container like ProductRecommendation */}
            <style>{`
            @keyframes slideInRight {
                from {
                transform: translateX(100%);
                opacity: 0;
                }
                to {
                transform: translateX(0);
                opacity: 1;
                }
            }
            
            @keyframes fadeIn {
                from { opacity: 0; transform: translateY(20px); }
                to { opacity: 1; transform: translateY(0); }
            }
            
            .animate-slide-in-right {
                animation: slideInRight 0.4s ease-out;
            }
            
            .animate-fade-in {
                animation: fadeIn 0.3s ease-out;
            }
            
            /* Custom Scrollbar Styles */
            .custom-scrollbar::-webkit-scrollbar {
                width: 6px;
            }
            
            .custom-scrollbar::-webkit-scrollbar-track {
                background: #f1f5f9;
                border-radius: 6px;
                margin: 4px 0;
            }
            
            .custom-scrollbar::-webkit-scrollbar-thumb {
                background: linear-gradient(135deg, #03486c, #00324D);
                border-radius: 6px;
                transition: all 0.3s ease;
            }
            
            .custom-scrollbar::-webkit-scrollbar-thumb:hover {
                background: linear-gradient(135deg, #03486c, #00324D);
                box-shadow: 0 2px 8px rgba(59, 130, 246, 0.4);
            }
            
            /* Firefox scrollbar */
            .custom-scrollbar {
                scrollbar-width: thin;
                scrollbar-color: #00324D #f1f5f9;
            }
            `}</style>
            {/* Header */}
            <div className="bg-gradient-to-br from-[#03486c] to-[#00324D] text-white p-6 shadow-lg flex-shrink-0">
            <div className="flex items-center justify-between">
                <div className="flex items-center space-x-4">
                <div className="w-12 h-12 bg-white bg-opacity-20 rounded-full flex items-center justify-center">
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
                    </svg>
                </div>
                <div>
                    <h1 className="text-2xl font-bold">Thanh Toán</h1>
                    <p className="text-blue-100">
                    Xin chào {customer.name}! 
                    {customer.membershipLevel === 'VIP' && (
                        <span className="ml-2 px-2 py-1 bg-yellow-400 text-yellow-900 rounded-full text-xs font-semibold">VIP</span>
                    )}
                    </p>
                </div>
                </div>
                
                <div className="flex items-center space-x-4">
                <div className="text-right">
                    <p className="text-sm text-blue-100">Mã đơn hàng</p>
                    <p className="text-lg font-semibold">#DH{Date.now().toString().slice(-6)}</p>
                </div>
                <button
                    onClick={onBack}
                    className="p-2 hover:bg-white hover:bg-opacity-20 rounded-full transition-colors"
                >
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
                </div>
            </div>
            </div>

            {/* Main Content */}
            <div className="flex-1 flex flex-col bg-gray-50 min-h-0">
            <div className="flex-1 p-6 overflow-y-auto custom-scrollbar">
                <div className="grid lg:grid-cols-3 gap-6">
                
                {/* Cột 1: Danh sách sản phẩm và đề xuất */}
                <div className="lg:col-span-2 space-y-6">
                {/* Danh sách sản phẩm đang mua */}
                <div className="bg-gray-50 rounded-xl p-6">
                    <h2 className="text-xl font-semibold mb-4 flex items-center">
                    <svg className="w-6 h-6 mr-2 text-[#00324D]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
                    </svg>
                    Sản Phẩm Đang Mua ({selectedProducts.length} mặt hàng)
                    </h2>
                    
                    <div className="space-y-3 max-h-96 overflow-y-auto">
                    {selectedProducts.map((product, index) => (
                        <div key={index} className="bg-white rounded-lg p-4 shadow-sm border">
                        <div className="flex items-start justify-between">
                            <div className="flex space-x-4">
                            <img
                                src={product.image || "/api/placeholder/60/60"}
                                alt={product.name}
                                className="w-15 h-15 object-cover rounded-lg"
                            />
                            <div className="flex-1">
                                <h3 className="font-medium text-gray-900">{product.name}</h3>
                                <p className="text-sm text-gray-500">Mã: {product.id}</p>
                                <p className="text-sm text-gray-600 mt-1">
                                {formatCurrency(product.price)} × {product.quantity}
                                </p>
                            </div>
                            </div>
                            <div className="text-right">
                            <p className="text-lg font-semibold text-red-800">
                                {formatCurrency(product.price * product.quantity)}
                            </p>
                            </div>
                        </div>
                        </div>
                    ))}
                    </div>

                    {/* Tổng kết đơn hàng */}
                    <div className="mt-6 pt-4 border-t border-gray-200">
                    <div className="space-y-2">
                        <div className="flex justify-between text-gray-600">
                        <span>Tạm tính:</span>
                        <span>{formatCurrency(subtotal)}</span>
                        </div>
                        <div className="flex justify-between text-gray-600">
                        <span>Thuế (10%):</span>
                        <span>{formatCurrency(tax)}</span>
                        </div>
                        {discount > 0 && (
                        <div className="flex justify-between text-green-600">
                            <span>Chiết khấu:</span>
                            <span>-{formatCurrency(discount)}</span>
                        </div>
                        )}
                        <div className="flex justify-between text-xl font-bold text-gray-900 pt-2 border-t">
                        <span>Tổng cần thanh toán:</span>
                        <span className="text-red-800">{formatCurrency(totalAmount)}</span>
                        </div>
                    </div>
                    </div>
                </div>

                {/* Sản phẩm đề xuất */}
                {showSuggestions && (
                    <div className="bg-gradient-to-r from-[#badde2] to-[#87b4e5] rounded-xl p-6">
                    <div className="flex items-center justify-between mb-4">
                        <h3 className="text-lg font-semibold text-[#db5669] flex items-center">
                        <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
                        </svg>
                        Sản Phẩm Đề Xuất
                        </h3>
                        <button
                        onClick={() => setShowSuggestions(false)}
                        className="text-[#db5669] hover:text-[#db5669] text-sm"
                        >
                        Ẩn đề xuất
                        </button>
                    </div>
                    
                    <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                        {suggestedProducts.map((product) => (
                        <div key={product.id} className="bg-white rounded-lg p-4 shadow-sm border border-purple-200 hover:shadow-md transition-shadow">
                            <img
                            src={product.image}
                            alt={product.name}
                            className="w-full h-20 object-cover rounded mb-3"
                            />
                            <h4 className="font-medium text-gray-900 text-sm mb-1">{product.name}</h4>
                            <p className="text-xs text-[#457f61] mb-2">{product.reason}</p>
                            <div className="flex items-center justify-between">
                            <span className="text-sm font-semibold text-red-800">{formatCurrency(product.price)}</span>
                            <button
                                onClick={() => addSuggestedProduct(product)}
                                className="bg-[#03486c] hover:bg-[#00324D] text-white px-3 py-1 rounded text-xs transition-colors"
                            >
                                + Thêm
                            </button>
                            </div>
                        </div>
                        ))}
                    </div>
                    </div>
                )}

                {/* Khuyến mãi và chiết khấu */}
                <div className="bg-gradient-to-r from-[#badde2] to-[#87b4e5] rounded-xl p-6">
                    <h3 className="text-lg font-semibold mb-4 text-[#db5669]">Ưu Đãi & Chiết Khấu</h3>
                    <div className="grid sm:grid-cols-2 gap-4">
                    <button
                        onClick={() => handleApplyDiscount('loyalty')}
                        className="flex items-center justify-between p-4 bg-white rounded-lg shadow-sm hover:shadow-md transition-shadow border border-orange-200"
                        disabled={customer.loyaltyPoints < 100}
                    >
                        <div className="text-left">
                        <p className="font-medium text-gray-900">Điểm tích lũy</p>
                        <p className="text-sm text-gray-500">{customer.loyaltyPoints} điểm</p>
                        </div>
                        <div className="text-[#00324D]">
                        {customer.loyaltyPoints >= 100 ? (
                            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                            <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                            </svg>
                        ) : (
                            <svg className="w-6 h-6 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
                            <path fillRule="evenodd" d="M13.477 14.89A6 6 0 015.11 6.524l8.367 8.368zm1.414-1.414L6.524 5.11a6 6 0 018.367 8.367zM18 10a8 8 0 11-16 0 8 8 0 0116 0z" clipRule="evenodd" />
                            </svg>
                        )}
                        </div>
                    </button>
                    
                    <button
                        onClick={() => handleApplyDiscount('member')}
                        className="flex items-center justify-between p-4 bg-white rounded-lg shadow-sm hover:shadow-md transition-shadow border border-purple-200"
                    >
                        <div className="text-left">
                        <p className="font-medium text-gray-900">Thành viên {customer.membershipLevel}</p>
                        <p className="text-sm text-gray-500">
                            {customer.membershipLevel === 'VIP' ? '15%' : '5%'} off
                        </p>
                        </div>
                        <div className="text-[#115775]">
                        <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                            <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        </div>
                    </button>
                    </div>
                </div>
                </div>

                {/* Cột 2: Thông tin thanh toán */}
                <div className="space-y-6">
                {/* Thông tin khách hàng */}
                <div className="from-[#badde2] to-[#87b4e5] bg-gradient-to-r rounded-xl p-6">
                    <h3 className="text-lg font-semibold mb-4 flex items-center text-[#db5669]">
                    <svg className="w-6 h-6 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                    </svg>
                    Thông Tin Khách Hàng
                    </h3>
                    <div className="space-y-3">
                    <div className="flex justify-between">
                        <span className="text-gray-600">Tên khách hàng:</span>
                        <span className="font-medium">{customer.name}</span>
                    </div>
                    <div className="flex justify-between">
                        <span className="text-gray-600">Mã khách hàng:</span>
                        <span className="font-medium">{customer.customerId}</span>
                    </div>
                    <div className="flex justify-between">
                        <span className="text-gray-600">Số lượng sản phẩm:</span>
                        <span className="font-medium">{selectedProducts.reduce((sum, p) => sum + p.quantity, 0)}</span>
                    </div>
                    <div className="flex justify-between">
                        <span className="text-gray-600">Hạng thành viên:</span>
                        <span className={`font-medium ${customer.membershipLevel === 'VIP' ? 'text-purple-600' : 'text-blue-600'}`}>
                        {customer.membershipLevel}
                        </span>
                    </div>
                    <div className="flex justify-between">
                        <span className="text-gray-600">Điểm tích lũy hiện tại:</span>
                        <span className="font-medium text-orange-600">{customer.loyaltyPoints} điểm</span>
                    </div>
                    <div className="flex justify-between">
                        <span className="text-gray-600">Tổng chi tiêu:</span>
                        <span className="font-medium text-red-800">{formatCurrency(customer.totalSpent)}</span>
                    </div>
                    </div>
                </div>

                {/* Phương thức thanh toán */}
                <div className="bg-gray-50 rounded-xl p-6">
                    <h3 className="text-lg font-semibold mb-4 text-gray-800">Dịch Vụ Thanh Toán</h3>
                    <div className="space-y-3">
                    {[
                        {
                            id: 'cash',
                            name: 'Tiền mặt',
                            desc: 'Thanh toán bằng tiền mặt',
                            icon: (
                            <svg xmlns="http://www.w3.org/2000/svg"
                                viewBox="0 0 24 24" fill="currentColor"
                                className="w-5 h-5 text-green-600">
                                <path d="M3 6a3 3 0 0 0-3 3v6a3 3 0 0 0 3 3h18a3 3 0 0 0 3-3V9a3 3 0 0 0-3-3H3zm0 2h18a1 1 0 0 1 1 1v6a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1zm9 2a2 2 0 1 0 0 4 2 2 0 0 0 0-4z"/>
                            </svg>
                            ),
                        },                    
                        {
                            id: 'card',
                            name: 'Thẻ ngân hàng',
                            desc: 'Visa, Mastercard, JCB',
                            icon: (
                            <svg xmlns="http://www.w3.org/2000/svg"
                                viewBox="0 0 24 24" fill="currentColor"
                                className="w-5 h-5 text-blue-600">
                                <path d="M2 5a2 2 0 0 0-2 2v1h24V7a2 2 0 0 0-2-2H2zm22 5H0v7a2 2 0 0 0 2 2h20a2 2 0 0 0 2-2v-7zM4 16h4v2H4v-2z"/>
                            </svg>
                            ),
                        },
                        {
                            id: 'qr',
                            name: 'Quét mã QR',
                            desc: 'VietQR, MoMo, ZaloPay',
                            icon: (
                            <svg xmlns="http://www.w3.org/2000/svg"
                                viewBox="0 0 24 24" fill="currentColor"
                                className="w-5 h-5 text-purple-600">
                                <path d="M3 3h6v2H5v4H3V3zm16 0h-4v2h4v4h2V3h-2zM5 15h4v4h2v-6H3v2h2zm14 2h-4v-2h-2v6h6v-4zM9 9h6v6H9V9z"/>
                            </svg>
                            ),
                        },

                        {
                            id: 'transfer',
                            name: 'Chuyển khoản',
                            desc: 'Internet Banking',
                            icon: (
                            <svg xmlns="http://www.w3.org/2000/svg"
                                viewBox="0 0 24 24" fill="currentColor"
                                className="w-5 h-5 text-indigo-600">
                                <path d="M12 2 1 7v2h22V7L12 2zM3 11v9h4v-9H3zm7 0v9h4v-9h-4zm7 0v9h4v-9h-4z"/>
                            </svg>
                            ),
                        },
                    ].map((method) => (
                        <label key={method.id} className="flex items-center p-4 bg-white rounded-lg cursor-pointer hover:bg-gray-50 border-2 transition-all duration-200"
                            style={{ borderColor: paymentMethod === method.id ? '#00243A' : '#E5E7EB' }}>
                        <input
                            type="radio"
                            name="paymentMethod"
                            value={method.id}
                            checked={paymentMethod === method.id}
                            onChange={(e) => setPaymentMethod(e.target.value)}
                            className="sr-only"
                        />
                        <span className="text-2xl mr-4">{method.icon}</span>
                        <div className="flex-1">
                            <span className="font-medium text-gray-900">{method.name}</span>
                            <p className="text-sm text-gray-500">{method.desc}</p>
                        </div>
                        {paymentMethod === method.id && (
                            <svg className="w-5 h-5 text-[#00324D]" fill="currentColor" viewBox="0 0 20 20">
                            <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                            </svg>
                        )}
                        </label>
                    ))}
                    </div>
                </div>

                {/* Chi tiết thanh toán và tích điểm */}
                <div className="from-[#badde2] to-[#87b4e5] bg-gradient-to-r rounded-xl p-6">
                    <h3 className="text-lg font-semibold mb-4 text-[#db5669]">Chi Tiết Thanh Toán & Tích Điểm</h3>
                    <div className="space-y-4">
                    <div className="flex justify-between">
                        <span className="text-gray-600">Số tiền phải trả:</span>
                        <span className="font-bold text-lg text-red-800">{formatCurrency(totalAmount)}</span>
                    </div>

                    {paymentMethod === 'cash' && (
                        <div className="space-y-2">
                        <label className="block text-sm font-medium text-gray-700">
                            Số tiền khách đưa:
                        </label>
                        <input
                            type="number"
                            value={paidAmount}
                            onChange={(e) => setPaidAmount(e.target.value)}
                            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                            placeholder="Nhập số tiền"
                            min={totalAmount}
                        />
                        {change > 0 && (
                            <div className="flex justify-between mt-2 p-2 bg-white rounded border-l-4 border-blue-500">
                            <span className="font-medium text-blue-700">Tiền thừa:</span>
                            <span className="font-bold text-blue-600">{formatCurrency(change)}</span>
                            </div>
                        )}
                        </div>
                    )}

                    <div className="flex justify-between">
                        <span className="text-gray-600">Loại tiền:</span>
                        <span className="font-medium">VND</span>
                    </div>

                    <div className="bg-orange-100 p-4 rounded-lg border border-orange-200">
                        <h4 className="font-semibold text-orange-800 mb-2"> Tích Điểm Thưởng</h4>
                        <div className="space-y-2 text-sm">
                        <div className="flex justify-between">
                            <span>Điểm từ giao dịch:</span>
                            <span className="font-semibold text-orange-600">+{loyaltyPoints} điểm</span>
                        </div>
                        {customer.membershipLevel === 'VIP' && (
                            <div className="flex justify-between">
                            <span>Bonus VIP (x2):</span>
                            <span className="font-semibold text-purple-600">+{loyaltyPoints} điểm</span>
                            </div>
                        )}
                        <div className="border-t pt-2 flex justify-between font-semibold">
                            <span>Tổng điểm nhận được:</span>
                            <span className="text-orange-600">
                            +{customer.membershipLevel === 'VIP' ? loyaltyPoints * 2 : loyaltyPoints} điểm
                            </span>
                        </div>
                        </div>
                    </div>

                    <div className="bg-blue-100 p-3 rounded-lg">
                        <div className="flex justify-between text-sm">
                        <span>Tổng điểm sau giao dịch:</span>
                        <span className="font-bold text-[#db5669]">
                            {customer.loyaltyPoints + (customer.membershipLevel === 'VIP' ? loyaltyPoints * 2 : loyaltyPoints)} điểm
                        </span>
                        </div>
                    </div>
                    </div>
                </div>

                {/* Nút thanh toán */}
                <button
                    onClick={handlePayment}
                    disabled={paymentStatus === 'processing' || (paymentMethod === 'cash' && parseFloat(paidAmount) < totalAmount)}
                    className={`w-full py-4 px-6 rounded-xl font-semibold text-lg transition-all duration-300 transform hover:scale-105 ${
                    paymentStatus === 'processing'
                        ? 'bg-[#03486c] text-white cursor-not-allowed'
                        : paymentStatus === 'success'
                        ? 'bg-green-500 text-white cursor-not-allowed'
                        : paymentStatus === 'failed'
                        ? 'bg-red-500 text-white'
                        : paymentMethod === 'cash' && parseFloat(paidAmount) < totalAmount
                        ? 'bg-gray-300 text-gray-500 cursor-not-allowed'
                        : 'bg-gradient-to-r from-[#03486c] to-[#00324D] text-white hover:from-[#03486c] hover:to-[#00324D] shadow-lg hover:shadow-xl'
                    }`}
                >
                    {paymentStatus === 'processing' && (
                    <div className="flex items-center justify-center">
                        <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-3"></div>
                        Đang xử lý thanh toán...
                    </div>
                    )}
                    {paymentStatus === 'success' && (
                    <div className="flex items-center justify-center">
                        <svg className="w-6 h-6 mr-2" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                        </svg>
                        Thanh toán thành công!
                    </div>
                    )}
                    {paymentStatus === 'failed' && 'Thanh toán thất bại - Thử lại'}
                    {paymentStatus === 'pending' && 'Xác Nhận Thanh Toán'}
                </button>
                </div>
            </div>
            </div>
            </div>
        </div>
        </div>
    );
};

export default PaymentInterface;