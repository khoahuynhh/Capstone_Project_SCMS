import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import {
    Banknote,
    Building2,
    CheckCircle2,
    CreditCard,
    QrCode,
    ShoppingBag,
    Sparkles,
    UserRound,
    X,
} from 'lucide-react';
import { serverApi } from '../../../core/api/server_api.js';
import '../css/ProductRecommendation.css';
import OrderReceipt from './Receipt';

const formatMoney = (value) => `${new Intl.NumberFormat('vi-VN').format(Math.round(Number(value) || 0))} đ`;

const PAYMENT_METHODS = [
    { id: 'cash', label: 'Tiền mặt', description: 'Thanh toán bằng tiền mặt', icon: Banknote },
    { id: 'card', label: 'Thẻ ngân hàng', description: 'Visa, Mastercard, JCB', icon: CreditCard },
    { id: 'qr', label: 'Quét mã QR', description: 'VietQR, MoMo, ZaloPay', icon: QrCode },
    { id: 'transfer', label: 'Chuyển khoản', description: 'Internet Banking', icon: Building2 },
];

const getRecommendationSessionId = () => {
    const key = 'fbrs_recommendation_session_id';
    const existing = window.sessionStorage.getItem(key);
    if (existing) return existing;

    const sessionId = window.crypto?.randomUUID?.() || `${Date.now()}-${Math.random().toString(16).slice(2)}`;
    window.sessionStorage.setItem(key, sessionId);
    return sessionId;
};

const PaymentInterface = ({
    selectedProducts = [],
    customerId,
    customerFName,
    customerLName,
    customerTier,
    onBack,
    onPaymentComplete,
}) => {
    const [checkoutItems, setCheckoutItems] = useState(selectedProducts);
    const [customer, setCustomer] = useState(null);
    const [loading, setLoading] = useState(true);
    const [paymentMethod, setPaymentMethod] = useState('card');
    const [paidAmount, setPaidAmount] = useState('');
    const [paymentStatus, setPaymentStatus] = useState('pending');
    const [orderDetails, setOrderDetails] = useState(null);
    const [showReceipt, setShowReceipt] = useState(false);
    const [cartRecommendations, setCartRecommendations] = useState([]);
    const [cartRecommendationsLoading, setCartRecommendationsLoading] = useState(false);
    const [checkoutListModal, setCheckoutListModal] = useState(null);
    const trackedImpressionsRef = useRef(new Set());
    const sessionIdRef = useRef(getRecommendationSessionId());

    const branchId = import.meta.env.VITE_BRANCH_ID || 'HCM_Q1';
    const deviceId = import.meta.env.VITE_DEVICE_ID || 'EDGE_HCM_Q1_01';
    const eventCustomerId = Number.isFinite(Number(customerId)) ? Number(customerId) : null;
    const orderCode = useMemo(() => `DH${Date.now().toString().slice(-6)}`, []);

    const customerDisplayName = useMemo(() => {
        const fullName = `${customerLName || ''} ${customerFName || ''}`.trim();
        return fullName || customer?.name || 'Khách vãng lai';
    }, [customer?.name, customerFName, customerLName]);

    useEffect(() => {
        setCheckoutItems(selectedProducts);
    }, [selectedProducts]);

    const sendRecommendationEvents = useCallback((events) => {
        if (!events.length) return;
        serverApi.recommendationEvents(events).catch((error) => {
            console.error('Failed to write recommendation event:', error);
        });
    }, []);

    const buildCartRecommendationEvent = useCallback((eventType, product, position) => ({
        event_type: eventType,
        product_id: Number(product.id),
        customer_id: eventCustomerId,
        branch_id: branchId,
        device_id: deviceId,
        surface: 'checkout_cart_associations',
        algorithm: 'association_rules_cart',
        position,
        session_id: sessionIdRef.current,
        recommendation_id: product.recommendation_id ?? product.recommendationId ?? null,
        event_metadata: {
            rule: product.recommendation_rule || null,
        },
    }), [branchId, deviceId, eventCustomerId]);

    useEffect(() => {
        const fetchCustomerData = async () => {
            if (!customerId) {
                setCustomer(null);
                setLoading(false);
                return;
            }

            try {
                setLoading(true);
                const history = await serverApi.purchaseHistory(customerId);
                if (history && history.length > 0) {
                    const latestInvoice = history[0];
                    const totalSpent = history.reduce((sum, invoice) => (
                        sum + Number(invoice.total_amount || invoice.amount || 0)
                    ), 0);

                    setCustomer({
                        customerId,
                        name: customerDisplayName || `Khách hàng ${customerId}`,
                        totalInvoices: history.length,
                        lastPurchase: latestInvoice.timestamp,
                        totalSpent,
                        tier: customerTier || 'Mới',
                        points: Math.floor(totalSpent / 10000),
                    });
                } else {
                    setCustomer({
                        customerId,
                        name: customerDisplayName || 'Khách hàng mới',
                        totalSpent: 0,
                        tier: customerTier || 'Mới',
                        points: 0,
                    });
                }
            } catch (error) {
                console.error('Lỗi khi tải lịch sử mua hàng:', error);
                setCustomer({
                    customerId,
                    name: customerDisplayName || 'Khách hàng',
                    totalSpent: 0,
                    tier: customerTier || 'Mới',
                    points: 0,
                });
            } finally {
                setLoading(false);
            }
        };

        fetchCustomerData();
    }, [customerDisplayName, customerId, customerTier]);

    useEffect(() => {
        const productIds = checkoutItems.map((item) => item.id).filter(Boolean);
        if (productIds.length === 0) {
            setCartRecommendations([]);
            return undefined;
        }

        let cancelled = false;
        setCartRecommendationsLoading(true);
        serverApi.cartAssociationRecommendations(productIds, 5, {
            branchId,
            customerId: eventCustomerId,
            deviceId,
            sessionId: sessionIdRef.current,
        })
            .then((data) => {
                if (cancelled) return;
                const recommendationId = data?.recommendation_id ?? null;
                const items = Array.isArray(data?.products) ? data.products : (Array.isArray(data) ? data : []);
                setCartRecommendations(items.map((item) => ({
                    ...item,
                    recommendation_id: item.recommendation_id ?? recommendationId,
                })));
            })
            .catch((error) => {
                console.error('Lỗi khi tải gợi ý theo giỏ hàng:', error);
                if (!cancelled) setCartRecommendations([]);
            })
            .finally(() => {
                if (!cancelled) setCartRecommendationsLoading(false);
            });

        return () => {
            cancelled = true;
        };
    }, [branchId, checkoutItems, deviceId, eventCustomerId]);

    useEffect(() => {
        if (cartRecommendations.length === 0) return;

        const events = [];
        cartRecommendations.forEach((product, index) => {
            const position = index + 1;
            const key = `checkout_cart_associations:${product.id}:${position}`;
            if (trackedImpressionsRef.current.has(key)) return;
            trackedImpressionsRef.current.add(key);
            events.push(buildCartRecommendationEvent('impression', product, position));
        });
        sendRecommendationEvents(events);
    }, [buildCartRecommendationEvent, cartRecommendations, sendRecommendationEvents]);

    const subtotal = checkoutItems.reduce((sum, item) => sum + (Number(item.price) * Number(item.quantity || 0)), 0);
    const tax = subtotal * 0.1;
    const totalAmount = subtotal + tax;
    const totalQuantity = checkoutItems.reduce((sum, item) => sum + Number(item.quantity || 0), 0);
    const change = paidAmount ? Math.max(0, Number(paidAmount) - totalAmount) : 0;
    const earnedPoints = Math.floor(totalAmount / 10000);
    const memberTier = customerTier || customer?.tier || 'Mới';
    const memberDiscountRate = memberTier && memberTier !== 'Mới' ? 5 : 0;
    const isCashPaymentInsufficient = paymentMethod === 'cash' && (!paidAmount || Number(paidAmount) < totalAmount);

    const handleAddRecommendedProduct = (product, index) => {
        sendRecommendationEvents([buildCartRecommendationEvent('click', product, index + 1)]);
        setCheckoutItems((items) => {
            const productId = Number(product.id);
            const existingIndex = items.findIndex((item) => Number(item.id) === productId);
            if (existingIndex >= 0) {
                return items.map((item, itemIndex) => (
                    itemIndex === existingIndex ? { ...item, quantity: Number(item.quantity || 0) + 1 } : item
                ));
            }

            return [
                ...items,
                {
                    id: productId,
                    name: product.name,
                    price: Number(product.discount_price || product.price || 0),
                    quantity: 1,
                    image_url: product.image_url || '/placeholder-prod.png',
                    product_code: product.product_code || product.code || '',
                },
            ];
        });
    };

    const handleConfirmPayment = async () => {
        try {
            setPaymentStatus('processing');
            const payload = {
                transaction_id: `TXN-${Date.now()}`,
                branch_id: branchId,
                device_id: deviceId,
                customer_id: customerId,
                timestamp: new Date().toISOString(),
                items: checkoutItems.map((item) => ({
                    product_id: item.id,
                    name: item.name,
                    qty: item.quantity,
                    unit_price: item.price,
                    price: item.price,
                })),
            };

            const response = await serverApi.createTransaction(payload);

            if (response.status === 'success') {
                const details = {
                    ...payload,
                    db_id: response.id,
                    total_amount: totalAmount,
                    payment_method: paymentMethod,
                    paidAmount: paymentMethod === 'cash' ? Number(paidAmount || 0) : 0,
                    change: paymentMethod === 'cash' ? change : 0,
                    earned_points: earnedPoints,
                };

                setPaymentStatus('success');
                setOrderDetails(details);
                setShowReceipt(true);
            }
        } catch (error) {
            setPaymentStatus('failed');
            alert(`Không thể lưu hóa đơn: ${error.message}`);
        }
    };

    if (loading) return <div className="loader">Đang tải dữ liệu thanh toán...</div>;

    return (
        <>
            <div className="recoShell checkoutShell animate-fade-in">
                <header className="checkoutHeader">
                    <div className="checkoutHeader__identity">
                        <div className="checkoutHeader__icon">
                            <ShoppingBag size={18} />
                        </div>
                        <div>
                            <h2>Thanh Toán</h2>
                            <p>Xin chào, {customerDisplayName}!</p>
                        </div>
                    </div>
                    <div className="checkoutHeader__order">
                        <span>Mã đơn hàng</span>
                        <strong>#{orderCode}</strong>
                        <button onClick={onBack} className="checkoutCloseBtn" aria-label="Đóng thanh toán">
                            <X size={18} />
                        </button>
                    </div>
                </header>

                <div className="checkoutBody">
                    <main className="checkoutMain custom-scrollbar">
                        <section className="checkoutSection">
                            <div className="checkoutSection__head">
                                <button
                                    type="button"
                                    className="checkoutSectionHeadButton"
                                    onClick={() => setCheckoutListModal('cart')}
                                >
                                    <h3><ShoppingBag size={16} /> Sản Phẩm Đang Mua ({totalQuantity} mặt hàng)</h3>
                                    <span>Xem tất cả</span>
                                </button>
                            </div>
                            <div className="checkoutItems custom-scrollbar">
                                {checkoutItems.map((item) => (
                                    <button
                                        key={item.id}
                                        type="button"
                                        className="checkoutItem"
                                        onClick={() => setCheckoutListModal('cart')}
                                    >
                                        <img src={item.image_url || '/placeholder-prod.png'} alt={item.name} />
                                        <div className="checkoutItem__info">
                                            <h4>{item.name}</h4>
                                            <span>{item.product_code || `SP-${item.id}`}</span>
                                            <small>{formatMoney(item.price)} x {item.quantity}</small>
                                        </div>
                                        <strong>{formatMoney(Number(item.price) * Number(item.quantity))}</strong>
                                    </button>
                                ))}
                                <div className="checkoutTotals">
                                <div><span>Tạm tính:</span><strong>{formatMoney(subtotal)}</strong></div>
                                <div><span>Thuế (10%):</span><strong>{formatMoney(tax)}</strong></div>
                                <div className="checkoutTotals__grand">
                                    <span>Tổng cần thanh toán:</span>
                                    <strong>{formatMoney(totalAmount)}</strong>
                                </div>
                            </div>
                            </div>

                        </section>

                        <section className="checkoutPanel checkoutPanel--blue">
                            <div className="checkoutPanel__head custom-scrollbar">
                                <button
                                    type="button"
                                    className="checkoutSectionHeadButton"
                                    onClick={() => setCheckoutListModal('recommendations')}
                                >
                                    <h3><Sparkles size={16} /> Sản Phẩm Đề Xuất</h3>
                                    <span>{cartRecommendations.length > 0 ? 'Xem tất cả' : 'Gợi ý mua kèm'}</span>
                                </button>
                            </div>
                            {cartRecommendationsLoading ? (
                                <div className="checkoutEmpty">Đang tải gợi ý...</div>
                            ) : cartRecommendations.length > 0 ? (
                                <div className="checkoutSuggestGrid">
                                    {cartRecommendations.slice(0, 3).map((item, index) => (
                                        <article key={item.id} className="checkoutSuggestCard">
                                            <img src={item.image_url || '/placeholder-prod.png'} alt={item.name} />
                                            <div>
                                                <h4>{item.name}</h4>
                                                <p>{item.recommendation_reason || item.category || 'Thường mua cùng'}</p>
                                            </div>
                                            <footer>
                                                <strong>{formatMoney(item.discount_price || item.price)}</strong>
                                                <button type="button" onClick={() => handleAddRecommendedProduct(item, index)}>
                                                    + Thêm
                                                </button>
                                            </footer>
                                        </article>
                                    ))}
                                </div>
                            ) : (
                                <div className="checkoutEmpty">Chưa có gợi ý phù hợp cho giỏ hàng này.</div>
                            )}
                        </section>

                        <section className="checkoutPanel checkoutPanel--blue">
                            <div className="checkoutPanel__head">
                                <h3>Ưu Đãi & Chiết Khấu</h3>
                            </div>
                            <div className="checkoutDiscounts">
                                <div className="checkoutDiscount checkoutDiscount--disabled">
                                    <div>
                                        <strong>Điểm tích lũy</strong>
                                        <span>{earnedPoints > 0 ? `${earnedPoints} điểm khả dụng sau giao dịch` : 'Chưa đủ điểm để áp dụng'}</span>
                                    </div>
                                </div>
                                <div className="checkoutDiscount checkoutDiscount--active">
                                    <div>
                                        <strong>Thành viên</strong>
                                        <span>{memberDiscountRate > 0 ? `${memberDiscountRate}% off` : 'Chưa có hạng thành viên'}</span>
                                    </div>
                                    <CheckCircle2 size={16} />
                                </div>
                            </div>
                        </section>
                    </main>

                    <aside className="checkoutSidebar custom-scrollbar">
                        <section className="checkoutInfoCard">
                            <h3><UserRound size={16} /> Thông Tin Khách Hàng</h3>
                            <div className="checkoutInfoList">
                                <div><span>Tên khách hàng:</span><strong>{customerDisplayName}</strong></div>
                                <div><span>Mã khách hàng:</span><strong>{customerId || 'Khách vãng lai'}</strong></div>
                                <div><span>Số lượng sản phẩm:</span><strong>{totalQuantity}</strong></div>
                                <div><span>Hạng thành viên:</span><strong>{memberTier}</strong></div>
                                <div><span>Điểm tích lũy hiện tại:</span><strong>{customer?.points ?? 0} điểm</strong></div>
                                <div><span>Tổng chi tiêu:</span><strong>{formatMoney(customer?.totalSpent || 0)}</strong></div>
                            </div>
                        </section>

                        <section className="checkoutPaymentMethods">
                            <h3>Dịch Vụ Thanh Toán</h3>
                            <div className="checkoutMethodList">
                                {PAYMENT_METHODS.map((method) => {
                                    const Icon = method.icon;
                                    return (
                                        <button
                                            key={method.id}
                                            type="button"
                                            className={`checkoutMethod ${paymentMethod === method.id ? 'checkoutMethod--active' : ''}`}
                                            onClick={() => setPaymentMethod(method.id)}
                                        >
                                            <Icon size={16} />
                                            <span>
                                                <strong>{method.label}</strong>
                                                <small>{method.description}</small>
                                            </span>
                                            {paymentMethod === method.id && <CheckCircle2 size={16} />}
                                        </button>
                                    );
                                })}
                            </div>

                            {paymentMethod === 'cash' && (
                                <div className="checkoutCashBox">
                                    <label htmlFor="checkout-paid-amount">Số tiền khách đưa</label>
                                    <input
                                        id="checkout-paid-amount"
                                        type="number"
                                        placeholder="Nhập số tiền..."
                                        value={paidAmount}
                                        onChange={(event) => setPaidAmount(event.target.value)}
                                    />
                                    {change > 0 && <strong>Trả lại: {formatMoney(change)}</strong>}
                                </div>
                            )}
                        </section>

                        <section className="checkoutInfoCard checkoutInfoCard--summary">
                            <h3>Chi Tiết Thanh Toán & Tích Điểm</h3>
                            <div className="checkoutInfoList">
                                <div><span>Số tiền phải trả:</span><strong className="checkoutDanger">{formatMoney(totalAmount)}</strong></div>
                                <div><span>Loại tiền:</span><strong>VND</strong></div>
                            </div>
                            <div className="checkoutPointBox">
                                <div><span>Điểm từ giao dịch:</span><strong>+{earnedPoints} điểm</strong></div>
                                <div><span>Tổng điểm nhận được:</span><strong>+{earnedPoints} điểm</strong></div>
                            </div>
                            <div className="checkoutAfterPoints">
                                <span>Tổng điểm sau giao dịch:</span>
                                <strong>{(customer?.points || 0) + earnedPoints} điểm</strong>
                            </div>
                        </section>

                        <button
                            className="checkoutConfirmBtn"
                            onClick={handleConfirmPayment}
                            disabled={paymentStatus !== 'pending' || isCashPaymentInsufficient || checkoutItems.length === 0}
                        >
                            {paymentStatus === 'processing' ? 'Đang xử lý...' : 'Xác Nhận Thanh Toán'}
                        </button>
                    </aside>
                </div>
            </div>

            {checkoutListModal && (
                <div className="checkoutListModal" role="dialog" aria-modal="true">
                    <div className="checkoutListModal__card">
                        <button
                            type="button"
                            className="checkoutListModal__close"
                            onClick={() => setCheckoutListModal(null)}
                            aria-label="Đóng danh sách"
                        >
                            <X size={18} />
                        </button>
                        <div className="checkoutListModal__head">
                            <h3>
                                {checkoutListModal === 'cart'
                                    ? `Sản Phẩm Đang Mua (${totalQuantity} mặt hàng)`
                                    : `Sản Phẩm Đề Xuất (${cartRecommendations.length})`}
                            </h3>
                            <p>
                                {checkoutListModal === 'cart'
                                    ? 'Toàn bộ sản phẩm trong đơn hàng hiện tại.'
                                    : 'Toàn bộ gợi ý mua kèm theo giỏ hàng.'}
                            </p>
                        </div>

                        <div className="checkoutListModal__body custom-scrollbar">
                            {checkoutListModal === 'cart' ? (
                                checkoutItems.map((item) => (
                                    <div key={item.id} className="checkoutListRow">
                                        <img src={item.image_url || '/placeholder-prod.png'} alt={item.name} />
                                        <div className="checkoutListRow__info">
                                            <h4>{item.name}</h4>
                                            <span>{item.product_code || `SP-${item.id}`}</span>
                                            <small>{formatMoney(item.price)} x {item.quantity}</small>
                                        </div>
                                        <strong>{formatMoney(Number(item.price) * Number(item.quantity))}</strong>
                                    </div>
                                ))
                            ) : cartRecommendationsLoading ? (
                                <div className="checkoutEmpty">Đang tải gợi ý...</div>
                            ) : cartRecommendations.length > 0 ? (
                                cartRecommendations.map((item, index) => (
                                    <div key={item.id} className="checkoutListRow">
                                        <img src={item.image_url || '/placeholder-prod.png'} alt={item.name} />
                                        <div className="checkoutListRow__info">
                                            <h4>{item.name}</h4>
                                            <span>{item.product_code || item.category || `SP-${item.id}`}</span>
                                            <small>{item.recommendation_reason || 'Thường mua cùng'}</small>
                                        </div>
                                        <div className="checkoutListRow__action">
                                            <strong>{formatMoney(item.discount_price || item.price)}</strong>
                                            <button type="button" onClick={() => handleAddRecommendedProduct(item, index)}>
                                                + Thêm
                                            </button>
                                        </div>
                                    </div>
                                ))
                            ) : (
                                <div className="checkoutEmpty">Chưa có gợi ý phù hợp cho giỏ hàng này.</div>
                            )}
                        </div>
                    </div>
                </div>
            )}

            {showReceipt && (
                <OrderReceipt
                    orderDetails={orderDetails}
                    customerInfo={customer}
                    onClose={() => {
                        setShowReceipt(false);
                        onPaymentComplete?.(orderDetails);
                    }}
                />
            )}
        </>
    );
};

export default PaymentInterface;
