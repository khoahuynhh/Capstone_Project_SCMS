import React from 'react';

const Receipt = ({ orderDetails, customerInfo, onClose, onPrintReceipt }) => {
    const formatCurrency = (amount) => {
        return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND'
        }).format(amount);
    };

    const formatDate = (date) => {
        return new Intl.DateTimeFormat('vi-VN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
        }).format(date);
    };

    const printReceipt = () => {
        window.print();
        onPrintReceipt?.();
    };

    return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
        <div className="bg-white rounded-xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            {/* Header */}
            <div className="bg-gradient-to-r from-[#03486c] to-[#00324D] text-white p-6 rounded-t-xl">
            <div className="flex items-center justify-between">
                <div className="flex items-center space-x-4">
                <div className="w-12 h-12 bg-white bg-opacity-20 rounded-full flex items-center justify-center">
                    <svg className="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                </div>
                <div>
                    <h1 className="text-2xl font-bold">Thanh Toán Thành Công!</h1>
                    <p className="text-green-100">Hóa đơn thanh toán</p>
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
            </div>

            <div className="p-6">
            {/* Store Information */}
            <div className="text-center mb-6 pb-4 border-b border-gray-200">
                <h2 className="text-xl font-bold text-gray-800">SMART RETAIL STORE</h2>
                <p className="text-gray-600">123 Đường ABC, Quận XYZ, TP.HCM</p>
                <p className="text-gray-600">Hotline: 1900 1234</p>
            </div>

            {/* Receipt Details */}
            <div className="grid grid-cols-2 gap-4 mb-6 text-sm">
                <div>
                <p className="text-gray-600">Mã đơn hàng:</p>
                <p className="font-semibold">{orderDetails.orderId || `#DH${Date.now().toString().slice(-6)}`}</p>
                </div>
                <div>
                <p className="text-gray-600">Thời gian:</p>
                <p className="font-semibold">{formatDate(new Date())}</p>
                </div>
                <div>
                <p className="text-gray-600">Thu ngân:</p>
                <p className="font-semibold">Hệ thống tự động</p>
                </div>
                <div>
                <p className="text-gray-600">Phương thức:</p>
                <p className="font-semibold">
                    {orderDetails.paymentMethod === 'cash' && 'Tiền mặt'}
                    {orderDetails.paymentMethod === 'card' && 'Thẻ tín dụng'}
                    {orderDetails.paymentMethod === 'qr' && 'Mã QR'}
                    {orderDetails.paymentMethod === 'transfer' && 'Chuyển khoản'}
                </p>
                </div>
            </div>

            {/* Customer Information */}
            <div className="mb-6 p-4 bg-[#d4e9ff] rounded-lg">
                <h3 className="font-semibold text-[#2578d0] mb-2">Thông Tin Khách Hàng</h3>
                <div className="grid grid-cols-2 gap-4 text-sm">
                <div>
                    <p className="text-gray-600">Tên khách hàng:</p>
                    <p className="font-medium">{customerInfo?.name || 'Khách hàng'}</p>
                </div>
                <div>
                    <p className="text-gray-600">Mã khách hàng:</p>
                    <p className="font-medium">{customerInfo?.customerId || 'N/A'}</p>
                </div>
                <div>
                    <p className="text-gray-600">Hạng thành viên:</p>
                    <p className="font-medium text-purple-600">{customerInfo?.membershipLevel || 'Thường'}</p>
                </div>
                <div>
                    <p className="text-gray-600">Điểm tích lũy được:</p>
                    <p className="font-medium text-orange-600">+{orderDetails.loyaltyPoints || 0} điểm</p>
                </div>
                </div>
            </div>

            {/* Products List */}
            <div className="mb-6">
                <h3 className="font-semibold text-gray-800 mb-3">Chi Tiết Sản Phẩm</h3>
                <div className="space-y-3">
                {orderDetails.products?.map((product, index) => (
                    <div key={index} className="flex justify-between items-start p-3 bg-[#cad0d7] rounded-lg">
                    <div className="flex-1">
                        <h4 className="font-medium text-gray-900">{product.name}</h4>
                        <p className="text-sm text-gray-500">Mã: {product.id}</p>
                        <p className="text-sm text-gray-600">
                        {formatCurrency(product.price)} × {product.quantity}
                        </p>
                    </div>
                    <div className="text-right">
                        <p className="font-semibold text-red-800">
                        {formatCurrency(product.price * product.quantity)}
                        </p>
                    </div>
                    </div>
                ))}
                </div>
            </div>

            {/* Payment Summary */}
            <div className="mb-6 p-4 bg-[#d8f4e5] rounded-lg">
                <h3 className="font-semibold text-[#457f61] mb-3">Tổng Kết Thanh Toán</h3>
                <div className="space-y-2 text-sm">
                <div className="flex justify-between">
                    <span>Tạm tính:</span>
                    <span>{formatCurrency(orderDetails.subtotal || orderDetails.orderTotal)}</span>
                </div>
                <div className="flex justify-between">
                    <span>Thuế (10%):</span>
                    <span>{formatCurrency((orderDetails.subtotal || orderDetails.orderTotal) * 0.1)}</span>
                </div>
                {orderDetails.discount > 0 && (
                    <div className="flex justify-between text-red-800">
                    <span>Chiết khấu:</span>
                    <span>-{formatCurrency(orderDetails.discount)}</span>
                    </div>
                )}
                <div className="border-t border-green-200 pt-2 mt-2">
                    <div className="flex justify-between text-lg font-bold">
                    <span>Tổng thanh toán:</span>
                    <span className="text-red-800">{formatCurrency(orderDetails.orderTotal)}</span>
                    </div>
                </div>
                <div className="flex justify-between">
                    <span>Số tiền đã trả:</span>
                    <span>{formatCurrency(orderDetails.paidAmount)}</span>
                </div>
                {orderDetails.change > 0 && (
                    <div className="flex justify-between text-blue-600">
                    <span>Tiền thừa:</span>
                    <span className="font-semibold">{formatCurrency(orderDetails.change)}</span>
                    </div>
                )}
                </div>
            </div>

            {/* Footer Message */}
            <div className="text-center mb-6 p-4 bg-gradient-to-r from-[#e8e4f3] to-[#fbebfb] rounded-lg">
                <div className="flex items-center justify-center mb-2">
                <svg className="w-6 h-6 text-[#875aef] mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                </svg>
                <h4 className="font-semibold text-[#875aef] ">Cảm ơn quý khách!</h4>
                </div>
                <p className="text-[#875aef] text-sm">
                Cảm ơn quý khách đã sử dụng dịch vụ của chúng tôi.
                <br />
                Hẹn gặp lại quý khách trong những lần mua sắm tiếp theo!
                </p>
                {customerInfo?.membershipLevel === 'VIP' && (
                <p className="text-gold-600 text-sm font-medium mt-2">
                    Quý khách được hưởng ưu đãi đặc biệt với thẻ VIP
                </p>
                )}
            </div>

            {/* Action Buttons */}
            <div className="flex space-x-4">
                <button
                onClick={printReceipt}
                className="flex-1 bg-gradient-to-r bg-[#066090] hover:bg-[#00324D] text-white  py-3 px-6 rounded-lg font-semibold transition-colors flex items-center justify-center"
                >
                <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
                </svg>
                In hóa đơn
                </button>
                <button
                onClick={onClose}
                className="flex-1 bg-gray-500 hover:bg-gray-600 text-white py-3 px-6 rounded-lg font-semibold transition-colors"
                >
                Hoàn thành
                </button>
            </div>

            
            </div>
        </div>
        </div>
    );
};

export default Receipt;