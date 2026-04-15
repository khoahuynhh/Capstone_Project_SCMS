import React from 'react';
import '../css/ProductRecommendation.css'; // Sử dụng chung bộ UI kit

const OrderReceipt = ({ orderDetails, customerInfo, onClose }) => {
    // Format tiền tệ theo chuẩn VN
    const formatCurrency = (amount) => {
        return new Intl.NumberFormat('vi-VN', {
            style: 'currency',
            currency: 'VND'
        }).format(amount || 0);
    };

    // Format thời gian từ Database
    const formatDate = (dateString) => {
        const date = dateString ? new Date(dateString) : new Date();
        return new Intl.DateTimeFormat('vi-VN', {
            year: 'numeric', month: '2-digit', day: '2-digit',
            hour: '2-digit', minute: '2-digit'
        }).format(date);
    };

    const handlePrint = () => {
        window.print();
    };

    if (!orderDetails) return null;

    return (
        <div style={{ zIndex: 9999 }}>
            <div className="recoShell animate-fade-in" style={{ maxWidth: '500px', height: 'auto', maxHeight: '90vh' }}>
                
                {/* HEADER - Phong cách Brand của bạn */}
                <header className="recoHeader" style={{ borderBottom: 'var(--glass-border)' }}>
                    <div className="flex items-center gap-3">
                        <div className="ai-status-icon" style={{ background: 'var(--c-accent)', color: 'white' }}>
                            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                        <div>
                            <h2 className="m-0 text-lg">Giao dịch thành công</h2>
                            <p className="recoDetailCategory" style={{ margin: 0 }}>Mã: {orderDetails.transaction_id || orderDetails.db_id}</p>
                        </div>
                    </div>
                    <button onClick={onClose} className="recoCloseBtn">✕</button>
                </header>

                <div className="recoBody flex-col p-6 custom-scrollbar" style={{ overflowY: 'auto' }}>
                    
                    {/* THÔNG TIN CỬA HÀNG & KHÁCH HÀNG */}
                    <section className="text-center mb-6">
                        <h1 style={{ color: 'var(--c-primary)', fontSize: '1.5rem', fontWeight: 800, marginBottom: '4px' }}>
                            EDGESCAN RETAIL
                        </h1>
                        <p className="recoDetailCategory bg-transparent p-0">Chi nhánh: {orderDetails.branch_id || import.meta.env.VITE_BRANCH_ID}</p>
                        <div className="mt-4 p-3 rounded-lg" style={{ background: 'var(--bg-subtle)', border: '1px solid rgba(0,0,0,0.05)' }}>
                            <div className="flex justify-between text-sm mb-1">
                                <span className="text-gray-500">Khách hàng:</span>
                                <span className="font-bold">{customerInfo?.name || "Khách vãng lai"}</span>
                            </div>
                            <div className="flex justify-between text-sm">
                                <span className="text-gray-500">Thời gian:</span>
                                <span>{formatDate(orderDetails.timestamp)}</span>
                            </div>
                        </div>
                    </section>

                    {/* DANH SÁCH MÓN ĐỒ - Dùng style recoCartItem */}
                    <section className="space-y-3 mb-6">
                        <p className="recoDetailCategory">Chi tiết sản phẩm</p>
                        {orderDetails.items?.map((item, idx) => (
                            <div key={idx} className="recoCartItem" style={{ background: 'transparent', padding: '8px 0', borderBottom: '1px dashed rgba(0,0,0,0.1)' }}>
                                <div className="flex-1">
                                    <h4 className="m-0 text-sm font-bold">{item.name || `Sản phẩm #${item.product_id}`}</h4>
                                    <p className="text-xs text-gray-500">{item.qty} x {formatCurrency(item.unit_price || item.price)}</p>
                                </div>
                                <div className="font-bold text-sm">
                                    {formatCurrency((item.qty) * (item.unit_price || item.price))}
                                </div>
                            </div>
                        ))}
                    </section>

                    {/* TỔNG TIỀN */}
                    <section className="space-y-2 pt-4" style={{ borderTop: '2px solid var(--c-primary)' }}>
                        <div className="flex justify-between">
                            <span className="text-gray-500">Tổng cộng</span>
                            <span className="font-bold">{formatCurrency(orderDetails.total_amount)}</span>
                        </div>
                        <div className="flex justify-between">
                            <span className="text-gray-500">Phương thức</span>
                            <span className="capitalize font-medium">{orderDetails.payment_method === 'cash' ? 'Tiền mặt' : 'Chuyển khoản'}</span>
                        </div>
                        
                        {orderDetails.payment_method === 'cash' && (
                            <>
                                <div className="flex justify-between text-sm">
                                    <span>Khách đưa</span>
                                    <span>{formatCurrency(orderDetails.paidAmount)}</span>
                                </div>
                                <div className="flex justify-between font-bold" style={{ color: 'var(--c-accent)' }}>
                                    <span>Tiền thừa</span>
                                    <span>{formatCurrency(orderDetails.change)}</span>
                                </div>
                            </>
                        )}
                    </section>

                    {/* THÔNG BÁO TÍCH ĐIỂM */}
                    <div className="mt-8 p-4 rounded-xl text-center" style={{ background: 'linear-gradient(135deg, #f8fafc 0%, #eff6ff 100%)', border: '1px solid #dbeafe' }}>
                        <p className="m-0 text-sm font-medium text-blue-800">
                            🎉 Chúc mừng! Bạn đã tích lũy thêm
                        </p>
                        <p className="m-0 text-xl font-black text-blue-600">
                            +{Math.floor(orderDetails.total_amount / 10000)} điểm
                        </p>
                        <p className="text-xs text-blue-500 mt-1">Hạng hiện tại: {customerInfo?.membershipLevel || 'Thành viên'}</p>
                    </div>
                </div>

                {/* FOOTER ACTIONS */}
                <footer className="p-6 pt-0 flex gap-3">
                    <button onClick={onClose} className="recoTab flex-1 justify-center m-0">Đóng</button>
                    <button 
                        onClick={handlePrint} 
                        className="recoCheckoutBtn flex-1 m-0"
                        style={{ padding: '12px' }}
                    >
                        <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
                        </svg>
                        In hóa đơn
                    </button>
                </footer>
            </div>
        </div>
    );
};

export default OrderReceipt;