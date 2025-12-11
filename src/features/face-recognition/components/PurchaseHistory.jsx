import React from 'react';

const PurchaseHistory = ({ customer, isOpen, onClose }) => {

    // Mock data lịch sử mua hàng chi tiết
    const purchaseHistory = [
        {
            orderId: 'DH240901001',
            date: '2024-09-01',
            time: '14:30:25',
            status: 'Hoàn thành',
            paymentMethod: 'Tiền mặt',
            cashier: 'Nhân viên #001',
            total: 63980000,
            discount: 3000000,
            finalTotal: 60980000,
            loyaltyPoints: 60,
            products: [
                {
                    id: 1,
                    name: 'iPhone 15 Pro Max',
                    image: 'https://cdn2.fptshop.com.vn/unsafe/768x0/filters:format(webp):quality(75)/2023_9_14_638302874057113482_so-sanh-iphone-15-pro-va-iphone-15-pro-max-12.jpg',
                    quantity: 1,
                    unitPrice: 31990000,
                    totalPrice: 31990000
                },
                {
                    id: 5,
                    name: 'AirPods Pro 2',
                    image: '/api/placeholder/200/200',
                    quantity: 2,
                    unitPrice: 5990000,
                    totalPrice: 11980000
                },
                {
                    id: 3,
                    name: 'MacBook Air M3',
                    image: '/api/placeholder/200/200',
                    quantity: 1,
                    unitPrice: 26990000,
                    totalPrice: 26990000
                }
            ]
        },
        {
            orderId: 'DH240815002',
            date: '2024-08-15',
            time: '10:15:42',
            status: 'Hoàn thành',
            paymentMethod: 'Thẻ tín dụng',
            cashier: 'Nhân viên #002',
            total: 29990000,
            discount: 0,
            finalTotal: 29990000,
            loyaltyPoints: 30,
            products: [
                {
                    id: 2,
                    name: 'Samsung Galaxy S24 Ultra',
                    image: '/api/placeholder/200/200',
                    quantity: 1,
                    unitPrice: 29990000,
                    totalPrice: 29990000
                }
            ]
        },
        {
            orderId: 'DH240720003',
            date: '2024-07-20',
            time: '16:45:18',
            status: 'Hoàn thành',
            paymentMethod: 'Quét mã QR',
            cashier: 'Nhân viên #003',
            total: 25990000,
            discount: 1000000,
            finalTotal: 24990000,
            loyaltyPoints: 25,
            products: [
                {
                    id: 8,
                    name: 'iPhone 15 Pro',
                    image: '/api/placeholder/200/200',
                    quantity: 1,
                    unitPrice: 25990000,
                    totalPrice: 25990000
                }
            ]
        },
        {
            orderId: 'DH240605004',
            date: '2024-06-05',
            time: '11:20:33',
            status: 'Hoàn thành',
            paymentMethod: 'Chuyển khoản',
            cashier: 'Nhân viên #001',
            total: 8990000,
            discount: 500000,
            finalTotal: 8490000,
            loyaltyPoints: 8,
            products: [
                {
                    id: 6,
                    name: 'Sony WH-1000XM5',
                    image: '/api/placeholder/200/200',
                    quantity: 1,
                    unitPrice: 6990000,
                    totalPrice: 6990000
                },
                {
                    id: 10,
                    name: 'Nintendo Switch OLED',
                    image: '/api/placeholder/200/200',
                    quantity: 1,
                    unitPrice: 8990000,
                    totalPrice: 8990000
                }
            ]
        }
    ];

    const formatCurrency = (amount) => {
        return new Intl.NumberFormat('vi-VN', {
            style: 'currency',
            currency: 'VND'
        }).format(amount);
    };

    const formatDate = (dateString) => {
        const date = new Date(dateString);
        return new Intl.DateTimeFormat('vi-VN', {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        }).format(date);
    };

    const getPaymentMethodIcon = (method) => {
        switch (method) {
            case 'Tiền mặt':
                //  Cash
                return (
                    <svg xmlns="http://www.w3.org/2000/svg" 
                        viewBox="0 0 24 24" fill="currentColor" 
                        className="w-5 h-5 text-[#71a58a]">
                    <path d="M3 6a3 3 0 0 0-3 3v6a3 3 0 0 0 3 3h18a3 3 0 0 0 3-3V9a3 3 0 0 0-3-3H3zm0 2h18a1 1 0 0 1 1 1v6a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1zm9 2a2 2 0 1 0 0 4 2 2 0 0 0 0-4z"/>
                    </svg>
                );

            case 'Thẻ tín dụng':
                // Credit Card
                return (
                    <svg xmlns="http://www.w3.org/2000/svg" 
                        viewBox="0 0 24 24" fill="currentColor" 
                        className="w-5 h-5 text-blue-600">
                    <path d="M2 5a2 2 0 0 0-2 2v1h24V7a2 2 0 0 0-2-2H2zm22 5H0v7a2 2 0 0 0 2 2h20a2 2 0 0 0 2-2v-7zM4 16h4v2H4v-2z"/>
                    </svg>
                );

            case 'Quét mã QR':
                // QR Scan
                return (
                    <svg xmlns="http://www.w3.org/2000/svg" 
                        viewBox="0 0 24 24" fill="currentColor" 
                        className="w-5 h-5 text-purple-600">
                    <path d="M3 3h6v2H5v4H3V3zm16 0h-4v2h4v4h2V3h-2zM5 15h4v4h2v-6H3v2h2zm14 2h-4v-2h-2v6h6v-4zM9 9h6v6H9V9z"/>
                    </svg>
                );

            case 'Chuyển khoản':
                //  Bank Transfer
                return (
                    <svg xmlns="http://www.w3.org/2000/svg" 
                        viewBox="0 0 24 24" fill="currentColor" 
                        className="w-5 h-5 text-indigo-600">
                    <path d="M12 2 1 7v2h22V7L12 2zM3 11v9h4v-9H3zm7 0v9h4v-9h-4zm7 0v9h4v-9h-4z"/>
                    </svg>
                );

            default:
                //  Default Money Bag
                return (
                    <svg xmlns="http://www.w3.org/2000/svg" 
                        viewBox="0 0 24 24" fill="currentColor" 
                        className="w-5 h-5 text-yellow-600">
                    <path d="M12 2a4 4 0 0 1 4 4c0 1.11-.45 2.11-1.17 2.83L18 12a8 8 0 1 1-12 0l3.17-3.17A3.97 3.97 0 0 1 8 6a4 4 0 0 1 4-4z"/>
                    </svg>
            );
            }
    };

    const totalSpent = purchaseHistory.reduce((sum, order) => sum + order.finalTotal, 0);
    const totalOrders = purchaseHistory.length;
    const totalLoyaltyPoints = purchaseHistory.reduce((sum, order) => sum + order.loyaltyPoints, 0);

    if (!isOpen) return null;

    return (
        <>
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
            
            .product-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            }
            
            .product-card {
            transition: all 0.3s ease;
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

            /* Hide horizontal scrollbar */
            .hide-scrollbar-x {
                overflow-x: hidden;
            }
        `}</style>

            <div className="fixed inset-0 bg-black bg-opacity-50 flex z-50 backdrop-blur-sm">
                <div className="w-full h-full bg-white animate-slide-in-right flex flex-col">
                    {/* Header */}
                    <div className="bg-gradient-to-br from-[#03486c] to-[#00324D] text-white p-6 shadow-lg flex-shrink-0">
                        <div className="flex items-center justify-between">
                            <div className="flex items-center space-x-4">
                                <div className="w-12 h-12 bg-white bg-opacity-20 rounded-full flex items-center justify-center">
                                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v0a2 2 0 002 2h2m0 0h2a2 2 0 012 2v0a2 2 0 01-2 2H9m0-4h2m-2 4h2m2-4V9a2 2 0 00-2-2M7 5V3a2 2 0 012-2h6a2 2 0 012 2v2M7 5h10" />
                                    </svg>
                                </div>
                                <div>
                                    <h1 className="text-2xl font-bold">Lịch Sử Mua Hàng</h1>
                                    <p className="text-orange-100">
                                        {customer?.firstName} {customer?.lastName} - Khách hàng VIP
                                    </p>
                                </div>
                            </div>
                            
                            <button
                                onClick={onClose}
                                className="p-2 hover:bg-white hover:bg-opacity-20 rounded-full transition-colors"
                            >
                                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                                </svg>
                            </button>
                        </div>

                        {/* Statistics */}
                        <div className="mt-6 grid grid-cols-1 sm:grid-cols-3 gap-4">
                            <div className="bg-white bg-opacity-20 rounded-lg p-4 text-center">
                                <div className="text-2xl font-bold">{totalOrders}</div>
                                <div className="text-orange-100 text-sm">Đơn hàng</div>
                            </div>
                            <div className="bg-white bg-opacity-20 rounded-lg p-4 text-center">
                                <div className="text-2xl font-bold">{formatCurrency(totalSpent).replace('₫', '')}</div>
                                <div className="text-orange-100 text-sm">Tổng chi tiêu</div>
                            </div>
                            <div className="bg-white bg-opacity-20 rounded-lg p-4 text-center">
                                <div className="text-2xl font-bold">{totalLoyaltyPoints}</div>
                                <div className="text-orange-100 text-sm">Điểm tích lũy</div>
                            </div>
                        </div>
                    </div>

                    {/* Purchase History List */}
                    <div className="flex-1 bg-gray-50 overflow-y-auto custom-scrollbar">
                        <div className="p-6">
                            <div className="space-y-4">
                                {purchaseHistory.map((order) => (
                                    <div key={order.orderId} className="bg-white rounded-xl shadow-sm border hover:shadow-md transition-shadow">
                                        {/* Order Header */}
                                        <div className="p-6 border-b border-gray-100">
                                            <div className="flex items-center justify-between">
                                                <div className="flex items-center space-x-4">
                                                    <div className="w-10 h-10 bg-[#ffde76] rounded-full flex items-center justify-center">
                                                        <span className="text-amber-600 text-lg">{getPaymentMethodIcon(order.paymentMethod)}</span>
                                                    </div>
                                                    <div>
                                                        <h3 className="font-semibold text-gray-900">Đơn hàng {order.orderId}</h3>
                                                        <p className="text-sm text-gray-500">
                                                            {formatDate(order.date)} - {order.time}
                                                        </p>
                                                    </div>
                                                </div>
                                                <div className="text-right">
                                                    <div className="text-lg font-bold text-red-800">
                                                        {formatCurrency(order.finalTotal)}
                                                    </div>
                                                    <div className="text-sm text-gray-500">
                                                        {order.paymentMethod} • {order.cashier}
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        {/* Order Products */}
                                        <div className="p-6">
                                            <div className="space-y-3">
                                                {order.products.map((product) => (
                                                    <div key={product.id} className="flex items-center space-x-4 p-3 bg-gray-50 rounded-lg">
                                                        <img
                                                            src={product.image}
                                                            alt={product.name}
                                                            className="w-12 h-12 object-cover rounded-lg"
                                                        />
                                                        <div className="flex-1">
                                                            <h4 className="font-medium text-gray-900">{product.name}</h4>
                                                            <p className="text-sm text-gray-500">
                                                                {formatCurrency(product.unitPrice)} × {product.quantity}
                                                            </p>
                                                        </div>
                                                        <div className="text-right">
                                                            <div className="font-semibold text-gray-900">
                                                                {formatCurrency(product.totalPrice)}
                                                            </div>
                                                        </div>
                                                    </div>
                                                ))}
                                            </div>

                                            {/* Order Summary */}
                                            <div className="mt-4 pt-4 border-t border-gray-200">
                                                <div className="space-y-2 text-sm">
                                                    <div className="flex justify-between">
                                                        <span className="text-gray-600">Tạm tính:</span>
                                                        <span>{formatCurrency(order.total)}</span>
                                                    </div>
                                                    {order.discount > 0 && (
                                                        <div className="flex justify-between text-[#388d61]">
                                                            <span>Giảm giá:</span>
                                                            <span>-{formatCurrency(order.discount)}</span>
                                                        </div>
                                                    )}
                                                    <div className="flex justify-between font-semibold text-base pt-2 border-t">
                                                        <span>Tổng thanh toán:</span>
                                                        <span className="text-red-800">{formatCurrency(order.finalTotal)}</span>
                                                    </div>
                                                    <div className="flex justify-between text-red-800">
                                                        <span>Điểm tích lũy:</span>
                                                        <span>+{order.loyaltyPoints} điểm</span>
                                                    </div>
                                                </div>
                                            </div>

                                            {/* Order Actions */}
                                            <div className="mt-4 flex space-x-3">
                                                <button className="flex-1 bg-[#03486c] hover:bg-[#00324D] text-white py-2 px-4 rounded-lg text-sm font-medium transition-colors">
                                                    Mua lại
                                                </button>
                                                <button className="flex-1 border border-gray-300 hover:bg-gray-50 text-gray-700 py-2 px-4 rounded-lg text-sm font-medium transition-colors">
                                                    In hóa đơn
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                ))}
                            </div>

                            {/* Load More */}
                            <div className="mt-8 text-center">
                                <button className="px-6 py-3 bg-white border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors">
                                    Xem thêm lịch sử
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </>
    );
};

export default PurchaseHistory;