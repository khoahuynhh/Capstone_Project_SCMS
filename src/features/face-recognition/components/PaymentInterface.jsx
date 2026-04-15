import React, { useState, useEffect } from 'react';
import { serverApi } from '../../../core/api/server_api.js';
import '../css/ProductRecommendation.css';
import OrderReceipt from './Receipt';

const PaymentInterface = ({ selectedProducts = [], customerId, customerFName, customerLName, onBack, onPaymentComplete }) => {
    const [customer, setCustomer] = useState(null);
    const [loading, setLoading] = useState(true);
    const [paymentMethod, setPaymentMethod] = useState('cash');
    const [paidAmount, setPaidAmount] = useState('');
    const [paymentStatus, setPaymentStatus] = useState('pending');
    const [orderDetails, setOrderDetails] = useState(null);
    const [showReceipt, setShowReceipt] = useState(false);

    // 1. Tải dữ liệu khách hàng từ Database dựa trên Model 'Customer'
    useEffect(() => {
        const fetchCustomerData = async () => {
            if (!customerId) {
                setCustomer(null);
                setLoading(false);
                return;
            }
            try {
                setLoading(true);
                // API trả về List[PurchaseInvoice]
                const history = await serverApi.purchaseHistory(customerId);

                if (history && history.length > 0) {
                    // Lấy thông tin từ hóa đơn gần nhất để hiển thị
                    const latestInvoice = history[0];

                    setCustomer({
                        customerId: customerId,
                        // Vì API history không trả về tên khách trực tiếp trong Invoice,
                        // ta có thể hiển thị ID hoặc kết hợp với API profile nếu có.
                        name: `Khách hàng ${customerId}`,
                        totalInvoices: history.length,
                        lastPurchase: latestInvoice.timestamp
                    });
                } else {
                    setCustomer({ customerId, name: 'Khách hàng mới' });
                }
            } catch (error) {
                console.error('Lỗi khi tải lịch sử mua hàng:', error);
                setCustomer({ customerId, name: 'Khách hàng' });
            } finally {
                setLoading(false);
            }
        };

        fetchCustomerData();
    }, [customerId]);

    // 2. Tính toán (Sử dụng Numeric từ bảng Product)
    const subtotal = selectedProducts.reduce((sum, item) => sum + (Number(item.price) * item.quantity), 0);
    const tax = subtotal * 0.1; // VAT
    const totalAmount = subtotal + tax;
    const change = paidAmount ? Math.max(0, Number(paidAmount) - totalAmount) : 0;
    const isCashPaymentInsufficient = paymentMethod === 'cash' && (!paidAmount || Number(paidAmount) < totalAmount);

    // 3. Gửi dữ liệu thanh toán (Khớp với model Transaction & TransactionItem)
    const handleConfirmPayment = async () => {
        try {
            setPaymentStatus('processing');
            const branchId = import.meta.env.VITE_BRANCH_ID || 'DEFAULT_BRANCH';
            const deviceId = import.meta.env.VITE_DEVICE_ID || 'DEFAULT_POS';

            const payload = {
                transaction_id: `TXN-${Date.now()}`, // Mã đơn hàng tạm thời từ thiết bị
                branch_id: branchId,
                device_id: deviceId,
                customer_id: customerId,
                timestamp: new Date().toISOString(),
                items: selectedProducts.map(p => ({
                    product_id: p.id,
                    name: p.name,
                    qty: p.quantity,
                    unit_price: p.price,
                    price: p.price
                }))
            };

            // Gửi POST lên endpoint /transactions
            const response = await serverApi.createTransaction(payload);

            if (response.status === 'success') {
                const details = {
                    ...payload,
                    db_id: response.id,
                    total_amount: totalAmount,
                    payment_method: paymentMethod,
                    paidAmount: paymentMethod === 'cash' ? Number(paidAmount || 0) : 0,
                    change: paymentMethod === 'cash' ? change : 0
                };

                setPaymentStatus('success');
                setOrderDetails(details);
                setShowReceipt(true);
            }
        } catch (error) {
            setPaymentStatus('failed');
            alert('Không thể lưu hóa đơn: ' + error.message);
        }
    };

    if (loading) return <div className="loader">Đang tải dữ liệu database...</div>;

    return (
        <>
            <div className="recoShell animate-fade-in">
                <header className="recoHeader">
                    <div className="flex items-center gap-4">
                        <div className="ai-status-icon" style={{ background: 'var(--c-primary)' }}>
                            <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" />
                            </svg>
                        </div>
                        <div>
                            <h2 className="m-0">Xác nhận thanh toán</h2>
                            <p className="recoDetailCategory" style={{ margin: 0 }}>
                                <strong> {`${customerLName || ''} ${customerFName || ''}`.trim() || 'Khách vãng lai'} </strong>
                            </p>
                        </div>
                    </div>
                    <button onClick={onBack} className="recoCloseBtn">✕</button>
                </header>

                <div className="recoBody">
                    <main className="recoMain custom-scrollbar">
                        <h3 className="section-title">Chi tiết đơn hàng</h3>
                        <div className="grid gap-3">
                            {selectedProducts.map((item) => (
                                <div key={item.id} className="recoCartItem" style={{ background: 'white' }}>
                                    <img src={item.image_url || "/placeholder-prod.png"} alt={item.name} />
                                    <div className="recoCartItemInfo flex-1">
                                        <h4>{item.name}</h4>
                                        <code>{item.product_code}</code>
                                    </div>
                                    <div className="text-right">
                                        <div className="font-bold">{item.quantity} x {new Intl.NumberFormat('vi-VN').format(item.price)}</div>
                                        <div className="recoCardPrice" style={{ fontSize: '0.9rem' }}>
                                            {new Intl.NumberFormat('vi-VN').format(item.price * item.quantity)} đ
                                        </div>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </main>

                    <aside className="recoSidebar">
                        <div className="recoTabs">
                            <button
                                className={`recoTab ${paymentMethod === 'cash' ? 'active' : ''}`}
                                onClick={() => setPaymentMethod('cash')}
                            >Tiền mặt</button>
                            <button
                                className={`recoTab ${paymentMethod === 'transfer' ? 'active' : ''}`}
                                onClick={() => setPaymentMethod('transfer')}
                            >Chuyển khoản</button>
                        </div>

                        <div className="recoSidebarContent space-y-4">
                            <div className="recoDetailMeta border-none p-0">
                                <div className="metaItem">
                                    <span className="label">Tích điểm (Loyalty)</span>
                                    <span className="value text-blue-600">+{Math.floor(totalAmount/1000)} pts</span>
                                </div>
                                <div className="metaItem">
                                    <span className="label">Hạng thành viên</span>
                                    <span className="value text-orange-500">{customer?.tier || 'Mới'}</span>
                                </div>
                            </div>

                            <hr style={{ opacity: 0.1 }} />

                            <div className="recoCartRow">
                                <span>Tạm tính:</span>
                                <span>{new Intl.NumberFormat('vi-VN').format(subtotal)} đ</span>
                            </div>
                            <div className="recoCartRow">
                                <span>Thuế VAT (10%):</span>
                                <span>{new Intl.NumberFormat('vi-VN').format(tax)} đ</span>
                            </div>
                            <div className="recoCartRow total">
                                <span>Tổng thanh toán</span>
                                <span style={{ color: 'var(--c-accent)' }}>
                                    {new Intl.NumberFormat('vi-VN').format(totalAmount)} đ
                                </span>
                            </div>

                            {paymentMethod === 'cash' && (
                                <div className="animate-fade-in">
                                    <input
                                        type="number"
                                        className="recoSearch w-full"
                                        placeholder="Số tiền khách đưa..."
                                        value={paidAmount}
                                        onChange={(e) => setPaidAmount(e.target.value)}
                                        style={{ padding: '12px' }}
                                    />
                                    {change > 0 && (
                                        <div className="mt-2 text-right font-bold text-green-600">
                                            Trả lại: {new Intl.NumberFormat('vi-VN').format(change)} đ
                                        </div>
                                    )}
                                </div>
                            )}
                        </div>

                        <div className="recoCartSummary">
                            <button
                                className="recoCheckoutBtn"
                                onClick={handleConfirmPayment}
                                disabled={paymentStatus !== 'pending' || isCashPaymentInsufficient}
                            >
                                {paymentStatus === 'processing' ? 'ĐANG XỬ LÝ...' : 'XÁC NHẬN & IN HÓA ĐƠN'}
                            </button>
                        </div>
                    </aside>
                </div>
            </div>

            {showReceipt && (
                <OrderReceipt
                    orderDetails={orderDetails}
                    customerInfo={customer}
                    onClose={() => { setShowReceipt(false); onPaymentComplete?.(orderDetails); }}
                />
            )}
        </>
    );
};

export default PaymentInterface;
