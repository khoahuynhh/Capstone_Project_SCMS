import React, { useState, useMemo, useEffect, useRef} from 'react';
import { useNavigate } from 'react-router-dom';
import { X, ShoppingCart, Search, CreditCard, Plus, Minus, Trash2, Package, LogOut, ArrowLeft } from 'lucide-react';
import { History as HistoryIcon } from 'lucide-react';
// Import hooks và api
import { serverApi } from '../../../core/api/server_api';
import { useAuth } from '../../../core/auth/useAuth';
import { useProducts } from '../hooks/useProducts';
import { useCustomerHistory } from '../hooks/useCustomerHistory';
import '../css/ProductRecommendation.css';
import PaymentInterface from './PaymentInterface';
import CustomerProfile from './CustomerProfile';

const getRecommendationSessionId = () => {
    const key = 'fbrs_recommendation_session_id';
    const existing = window.sessionStorage.getItem(key);
    if (existing) return existing;

    const sessionId = window.crypto?.randomUUID?.() || `${Date.now()}-${Math.random().toString(16).slice(2)}`;
    window.sessionStorage.setItem(key, sessionId);
    return sessionId;
};

const CHECKOUT_DRAFT_KEY = 'fbrs_product_checkout_draft';

const readCheckoutDraft = () => {
    if (typeof window === 'undefined') return { cart: [], showPayment: false };

    try {
        const raw = window.sessionStorage.getItem(CHECKOUT_DRAFT_KEY);
        if (!raw) return { cart: [], showPayment: false };

        const parsed = JSON.parse(raw);
        return {
            cart: Array.isArray(parsed.cart) ? parsed.cart : [],
            showPayment: Boolean(parsed.showPayment && parsed.cart?.length),
        };
    } catch {
        return { cart: [], showPayment: false };
    }
};

// --- HELPER: Map data DB -> UI ---
const mapDbProductToUi = (p) => {
    const originalPrice = Number(p.price ?? 0);
    const discountPrice = p.discount_price ? Number(p.discount_price) : null;

    let finalPrice = originalPrice;
    let discountPercentage = 0;
    let hasDiscount = false;

    if (discountPrice !== null && discountPrice < originalPrice && originalPrice > 0) {
        finalPrice = discountPrice;
        discountPercentage = Math.round(((originalPrice - discountPrice) / originalPrice) * 100);
        hasDiscount = true;
    }

    return {
        id: String(p.id ?? p.product_id), // Ép kiểu String
        name: p.name || "Sản phẩm",
        productCode: p.product_code || "",
        category: p.category || "Khác",
        originalPrice,
        finalPrice,
        image: p.image_url || "https://via.placeholder.com/150",
        stock: p.stock ?? 0,
        hasDiscount,
        discountPercentage,
        description: p.description || "",
        targetGender: p.target_gender?.toLowerCase() || 'unisex',
        targetAgeGroup: p.target_age_group || 'all'
    };
};

const normalizeAgeGroup = (value) => {
    if (!value) return '';
    return String(value).trim().toLowerCase().replace('-', '_');
};

const isAgeGroupMatch = (targetAgeGroup, customerAge, customerAgeGroup) => {
    const target = normalizeAgeGroup(targetAgeGroup);
    if (!target || ['all', 'any', 'unisex'].includes(target)) return true;

    const normalizedCustomerAgeGroup = normalizeAgeGroup(customerAgeGroup);
    if (normalizedCustomerAgeGroup && target === normalizedCustomerAgeGroup) return true;

    const age = Number(customerAge);
    if (!Number.isFinite(age)) return false;

    if (target.includes('_')) {
        const [min, max] = target.split('_').map(Number);
        return Number.isFinite(min) && Number.isFinite(max) && age >= min && age <= max;
    }

    if (target.endsWith('_plus') || target.endsWith('+')) {
        const min = Number(target.replace('_plus', '').replace('+', ''));
        return Number.isFinite(min) && age >= min;
    }

    return false;
};

const getDemographicRecommendationScore = (product, customer) => {
    let score = 0;
    const customerGender = customer?.gender?.toLowerCase();
    const targetGender = product.targetGender?.toLowerCase();

    if (customerGender) {
        if (targetGender === customerGender) {
            score += 50;
        } else if (['unisex', 'all', 'any'].includes(targetGender)) {
            score += 25;
        }
    }

    if (isAgeGroupMatch(product.targetAgeGroup, customer?.age, customer?.age_group)) {
        score += 40;
    }

    return score;
};

const ProductRecommendation = ({ customer: customerProp, isOpen = true, onClose, onViewProfile }) => {
    const navigate = useNavigate();
    const { user, setUser } = useAuth();
    const checkoutDraft = useMemo(readCheckoutDraft, []);

    // --- STATE ---
    const [cart, setCart] = useState(checkoutDraft.cart);
    const [searchTerm, setSearchTerm] = useState('');
    const [activeTab, setActiveTab] = useState('cart'); // 'cart' | 'history' | 'profile'
    const [loggingOut, setLoggingOut] = useState(false);
    const [showLogoutConfirm, setShowLogoutConfirm] = useState(false);

    const customer = customerProp ?? user?.customer ?? null;

    // --- DATA ---
    // LƯU Ý: Trong useProducts, bạn hãy set limit cao lên (ví dụ limit=200) để lấy hết hàng trong kho về
    const { products: dbProducts, isLoading: loadingProducts } = useProducts();
    const [relatedProducts, setRelatedProducts] = useState([]);
    const [isLoadingRelated, setIsLoadingRelated] = useState(false);
    const { historyInvoices, isLoading: loadingHistory } = useCustomerHistory(customer?.customer_id);
    const [selectedProduct, setSelectedProduct] = useState(null);
    const [historyStack, setHistoryStack] = useState([]);
    const [showPayment, setShowPayment] = useState(checkoutDraft.showPayment);
    const sessionIdRef = useRef(null);
    const trackedImpressionsRef = useRef(new Set());
    const trackedAcceptancesRef = useRef(new Set());

    if (!sessionIdRef.current && typeof window !== 'undefined') {
        sessionIdRef.current = getRecommendationSessionId();
    }

    useEffect(() => {
        if (typeof window === 'undefined') return;

        if (!cart.length && !showPayment) {
            window.sessionStorage.removeItem(CHECKOUT_DRAFT_KEY);
            return;
        }

        window.sessionStorage.setItem(CHECKOUT_DRAFT_KEY, JSON.stringify({
            cart,
            showPayment,
            customerId: customer?.customer_id ?? customer?.id ?? null,
            updatedAt: Date.now(),
        }));
    }, [cart, showPayment, customer]);

    // --- LOGIC TÍNH TOÁN ---
    const purchaseStats = useMemo(() => {
        const map = new Map();
        if (!historyInvoices) return { byProductId: map };

        historyInvoices.forEach(inv => {
            // Parse items data tuỳ cấu trúc API trả về
            const items = inv.items || (typeof inv.items_data === 'string' ? JSON.parse(inv.items_data) : inv.items_data) || [];
            items.forEach(it => {
                const pid = String(it.product_id);
                map.set(pid, (map.get(pid) || 0) + (it.qty || 1));
            });
        });
        return { byProductId: map };
    }, [historyInvoices]);

    const displayProducts = useMemo(() => {
        if (!dbProducts || dbProducts.length === 0) return [];

        // 1. Map dữ liệu
        let list = dbProducts.map(mapDbProductToUi);

        // 2. Lọc theo tìm kiếm
        if (searchTerm) {
            const lower = searchTerm.toLowerCase();
            list = list.filter(p => p.name.toLowerCase().includes(lower));
        }

        // 3. SẮP XẾP THÔNG MINH (Smart Sorting)
        list.sort((a, b) => {
            // Ưu tiên 1: Lịch sử mua (Score)
            const scoreA = purchaseStats.byProductId.get(a.id) || 0;
            const scoreB = purchaseStats.byProductId.get(b.id) || 0;
            if (scoreB !== scoreA) {
                return scoreB - scoreA; // Mua nhiều hiện lên đầu
            }

            // Ưu tiên 2: Đang giảm giá (Promotion)
            // Nếu cả 2 đều chưa mua bao giờ, cái nào giảm giá cho lên trước
            if (b.hasDiscount !== a.hasDiscount) {
                return b.hasDiscount ? 1 : -1;
            }

            // Ưu tiên 3: Phù hợp giới tính và độ tuổi của khách hàng
            const demographicScoreA = getDemographicRecommendationScore(a, customer);
            const demographicScoreB = getDemographicRecommendationScore(b, customer);
            if (demographicScoreB !== demographicScoreA) {
                return demographicScoreB - demographicScoreA;
            }

            // Ưu tiên 4 (FALLBACK): Tồn kho & Tên
            // Nếu không có lịch sử, không giảm giá -> Hiện cái nào còn nhiều hàng trước
            if (b.stock !== a.stock) {
                return b.stock - a.stock;
            }

            // Cuối cùng: Sắp xếp A-Z để danh sách nhìn gọn gàng
            return a.name.localeCompare(b.name);
        });

        return list;
    }, [dbProducts, searchTerm, purchaseStats, customer]);

    React.useEffect(() => {
        if (selectedProduct && selectedProduct.id) {
            setIsLoadingRelated(true);
            
            // Sử dụng serverApi thay vì fetch
            serverApi.relatedProducts(selectedProduct.id, 5)
                .then(data => {
                    // Map dữ liệu từ backend trả về cho khớp với UI
                    const mappedRelated = data.map(mapDbProductToUi);
                    setRelatedProducts(mappedRelated);
                })
                .catch(err => {
                    console.error("Lỗi khi tải sản phẩm liên quan:", err);
                    setRelatedProducts([]); // Set rỗng nếu có lỗi để UI không bị vỡ
                })
                .finally(() => setIsLoadingRelated(false));
        } else {
            setRelatedProducts([]);
        }
    }, [selectedProduct]);

    const cartTotal = cart.reduce((sum, item) => sum + (item.finalPrice * item.quantity), 0);
    const formatMoney = (n) => n.toLocaleString('vi-VN') + 'đ';
    const branchId = customer?.preferred_branch || import.meta.env.VITE_BRANCH_ID || 'HCM_Q1';
    const deviceId = import.meta.env.VITE_DEVICE_ID || null;
    const customerId = customer?.id ? Number(customer.id) : null;

    const sendRecommendationEvents = (events) => {
        if (!events.length) return;
        for (let i = 0; i < events.length; i += 100) {
            serverApi.recommendationEvents(events.slice(i, i + 100)).catch((error) => {
                console.error('Lỗi ghi recommendation event:', error);
            });
        }
    };

    const buildRecommendationEvent = (eventType, product, position, surface, algorithm) => ({
        event_type: eventType,
        product_id: Number(product.id),
        customer_id: customerId,
        branch_id: branchId,
        device_id: deviceId,
        surface,
        algorithm,
        position,
        session_id: sessionIdRef.current,
    });

    const getRecommendationAttribution = (product) => ({
        surface: product.recommendationSurface || 'customer_recommendation',
        algorithm: product.recommendationAlgorithm || 'purchase_history_sort',
        position: product.recommendationPosition ?? null,
    });

    useEffect(() => {
        if (!isOpen || showPayment || loadingProducts || displayProducts.length === 0) return;

        const events = [];
        displayProducts.forEach((product, index) => {
            const position = index + 1;
            const key = `customer_recommendation:${searchTerm || 'default'}:${product.id}:${position}`;
            if (trackedImpressionsRef.current.has(key)) return;
            trackedImpressionsRef.current.add(key);
            events.push(buildRecommendationEvent(
                'impression',
                product,
                position,
                'customer_recommendation',
                'purchase_history_sort',
            ));
        });

        sendRecommendationEvents(events);
    }, [isOpen, showPayment, loadingProducts, displayProducts, searchTerm]);

    useEffect(() => {
        if (!isOpen || showPayment || !selectedProduct || relatedProducts.length === 0) return;

        const events = [];
        relatedProducts.forEach((product, index) => {
            const position = index + 1;
            const key = `related_products:${selectedProduct.id}:${product.id}:${position}`;
            if (trackedImpressionsRef.current.has(key)) return;
            trackedImpressionsRef.current.add(key);
            events.push(buildRecommendationEvent(
                'impression',
                product,
                position,
                'related_products',
                'association_rules',
            ));
        });

        sendRecommendationEvents(events);
    }, [isOpen, showPayment, selectedProduct, relatedProducts]);

    // --- ACTIONS ---
    const addToCart = (product) => {
        const attribution = getRecommendationAttribution(product);
        const acceptanceKey = `${attribution.surface}:${product.id}`;
        if (!trackedAcceptancesRef.current.has(acceptanceKey)) {
            trackedAcceptancesRef.current.add(acceptanceKey);
            sendRecommendationEvents([
                buildRecommendationEvent(
                    'add_to_cart',
                    product,
                    attribution.position,
                    attribution.surface,
                    attribution.algorithm,
                ),
            ]);
        }
        setCart(prev => {
            const idx = prev.findIndex(p => p.id === product.id);
            if (idx > -1) {
                const newCart = [...prev];
                newCart[idx].quantity += 1;
                return newCart;
            }
            return [...prev, { ...product, quantity: 1 }];
        });
    };

    const updateQty = (id, delta) => {
        setCart(prev => prev.map(item => {
            if (item.id === id) return { ...item, quantity: Math.max(1, item.quantity + delta) };
            return item;
        }));
    };

    const removeProduct = (id) => setCart(prev => prev.filter(p => p.id !== id));

    const mapCartToPaymentItems = (items) =>
        items.map((p) => ({
            id: Number(p.id),            // PaymentInterface dùng product_id int
            name: p.name,
            price: p.finalPrice,         // PaymentInterface dùng price
            quantity: p.quantity,
            image_url: p.image,          // PaymentInterface dùng image_url
            product_code: p.productCode || p.product_code || '' // nếu có
        }));

    const handleLogout = async () => {
        setLoggingOut(true);

        try {
            await serverApi.logout();
        } catch (error) {
            console.error(error);
        } finally {
            window.sessionStorage.removeItem(CHECKOUT_DRAFT_KEY);
            setUser(null);
            navigate('/login', { replace: true });
        }
    };

    // Hàm 1: Khi bấm vào một sản phẩm liên quan
    const handleSelectRelatedProduct = (rp, position) => {
        sendRecommendationEvents([
            buildRecommendationEvent('click', rp, position, 'related_products', 'association_rules'),
        ]);
        // Đẩy sản phẩm "hiện tại" vào cuối mảng lịch sử (stack)
        setHistoryStack((prevStack) => [...prevStack, selectedProduct]);
        // Cập nhật sản phẩm mới để hiển thị
        setSelectedProduct({
            ...rp,
            recommendationSurface: 'related_products',
            recommendationAlgorithm: 'association_rules',
            recommendationPosition: position,
        });
    };

    // Hàm 2: Khi bấm nút Quay lại (Back)
    const handleGoBack = () => {
        if (historyStack.length === 0) return;
        
        // Lấy bản sao của lịch sử
        const newStack = [...historyStack];
        // Lấy ra sản phẩm cuối cùng vừa được đưa vào stack (sản phẩm trước đó)
        const previousProduct = newStack.pop();
        
        // Cập nhật lại lịch sử (đã xóa phần tử cuối) và hiển thị lại sản phẩm cũ
        setHistoryStack(newStack);
        setSelectedProduct(previousProduct);
    };

    if (!isOpen) return null;

    return (
        <div className="recoOverlay">
            {!showPayment ? (
                /* Chuyển comment ra ngoài hoặc bọc trong Fragment nếu cần */
                <div className="recoShell">
                    {/* --- HEADER --- */}
                    <div className="recoHeader">
                        <div>
                            <h2 style={{ margin: 0 }}>
                                {purchaseStats.byProductId.size > 0
                                    ? "Gợi ý riêng cho khách"
                                    : "Danh sách sản phẩm"}
                            </h2>
                            {customer ? (
                                <div style={{ opacity: 0.8, fontSize: '0.95rem', marginTop: 4 }}>
                                    <strong> {`${customer.last_name || ''} ${customer.first_name || ''}`.trim() || 'Khách vãng lai'} </strong>
                                    {purchaseStats.byProductId.size === 0 && " (Chưa có lịch sử mua)"}
                                </div>
                            ) : (
                                <div style={{ opacity: 0.8, fontSize: '0.95rem', marginTop: 4 }}>Khách vãng lai</div>
                            )}
                        </div>
                        <div className="recoHeaderActions">
                            <button
                                className={`recoHeaderBtn ${activeTab === 'profile' ? 'active' : ''}`}
                                onClick={() => {
                                    if (onViewProfile) {
                                        onViewProfile();
                                        return;
                                    }

                                    setActiveTab((current) => (current === 'profile' ? 'cart' : 'profile'));
                                }}
                                type="button"
                            >
                                {activeTab === 'profile' ? 'Mua sắm' : 'Hồ sơ'}
                            </button>
                            {customer ? (
                                <button
                                    className="recoHeaderBtn"
                                    onClick={() => setShowLogoutConfirm(true)}
                                    type="button"
                                    disabled={loggingOut}
                                >
                                    {loggingOut ? 'Đang đăng xuất...' : 'Đăng xuất'}
                                </button>
                            ) : null}
                            {onClose ? (
                                <button onClick={onClose} className="recoCloseBtn" type="button">
                                    ✕
                                </button>
                            ) : null}
                        </div>
                        </div>

                    {/* --- BODY --- */}
                    {activeTab === 'profile' ? (
                        <CustomerProfile customer={customer} />
                    ) : (
                    <div className="recoBody">
                        {/* 1. CỘT TRÁI */}
                        <div className="recoMain">
                            <div className="recoSearch">
                                <Search size={20} />
                                <input
                                    type="text"
                                    placeholder="Tìm kiếm sản phẩm..."
                                    value={searchTerm}
                                    onChange={e => setSearchTerm(e.target.value)}
                                />
                            </div>

                            {loadingProducts ? (
                                <div style={{ padding: 40, textAlign: 'center', color: 'var(--c-text-muted)' }}>
                                    <div className="spinner" style={{ marginBottom: 10, borderTopColor: 'var(--c-primary)' }}></div>
                                    Đang tải kho hàng...
                                </div>
                            ) : (
                                <div className="recoGrid">
                                    {displayProducts.length === 0 ? (
                                        <div style={{ gridColumn: '1/-1', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '40px 0', color: 'var(--c-text-muted)', textAlign: 'center' }}>
                                            <Package size={56} style={{ opacity: 0.25, marginBottom: 12 }} />
                                            <p style={{ fontSize: '0.8rem', lineHeight: 1.4, margin: 0, letterSpacing: '0.2px' }}>Không tìm thấy sản phẩm nào.</p>
                                        </div>
                                    ) : (
                                        displayProducts.map((product, index) => (
                                            <div
                                                key={product.id}
                                                className="recoCard animate-fade-in"
                                                onClick={() => {
                                                    sendRecommendationEvents([
                                                        buildRecommendationEvent(
                                                            'click',
                                                            product,
                                                            index + 1,
                                                            'customer_recommendation',
                                                            'purchase_history_sort',
                                                        ),
                                                    ]);
                                                    setSelectedProduct({
                                                        ...product,
                                                        recommendationSurface: 'customer_recommendation',
                                                        recommendationAlgorithm: 'purchase_history_sort',
                                                        recommendationPosition: index + 1,
                                                    });
                                                }}
                                            >
                                                <div className="recoCardImg">
                                                    <img
                                                        src={product.image}
                                                        alt={product.name}
                                                        onError={(e) => e.target.src = 'https://via.placeholder.com/200?text=No+Img'}
                                                    />
                                                    {product.hasDiscount && (
                                                        <span className="recoBadge">-{product.discountPercentage}%</span>
                                                    )}
                                                </div>

                                                <div className="recoCardContent">
                                                    <h3 className="recoCardTitle" title={product.name}>{product.name}</h3>
                                                    <div className="recoCardPrice">
                                                        {formatMoney(product.finalPrice)}
                                                        {product.hasDiscount && (
                                                            <span className="recoCardOldPrice">{formatMoney(product.originalPrice)}</span>
                                                        )}
                                                    </div>
                                                    <button
                                                        className="recoCardAddBtn"
                                                        onClick={(e) => {
                                                            e.stopPropagation();
                                                            addToCart(product);
                                                        }}
                                                    >
                                                        <Plus size={18} /> Thêm
                                                    </button>
                                                </div>
                                            </div>
                                        ))
                                    )}
                                </div>
                            )}
                        </div>

                        {/* 2. CỘT PHẢI */}
                        <div className="recoSidebar">
                            <div className="recoTabs">
                                <button
                                    className={`recoTab ${activeTab === 'cart' ? 'active' : ''}`}
                                    onClick={() => setActiveTab('cart')}
                                >
                                    Giỏ hàng ({cart.reduce((a, b) => a + b.quantity, 0)})
                                </button>
                                <button
                                    className={`recoTab ${activeTab === 'history' ? 'active' : ''}`}
                                    onClick={() => setActiveTab('history')}
                                >
                                    Lịch sử mua
                                </button>
                            </div>

                            {activeTab === 'cart' && (
                                <>
                                    <div className="recoCartList">
                                        {cart.length === 0 ? (
                                            <div style={{ textAlign: 'center', color: 'var(--c-text-muted)', marginTop: 60 }}>
                                                <ShoppingCart size={64} style={{ opacity: 0.3, marginBottom: 20 }} />
                                                <p style={{ fontSize: '1.1rem' }}>Giỏ hàng trống</p>
                                            </div>
                                        ) : (
                                            cart.map(item => (
                                                <div key={item.id} className="recoCartItem animate-fade-in">
                                                    <img src={item.image} alt="" />
                                                    <div className="recoCartItemInfo">
                                                        <h4>{item.name}</h4>
                                                        <div className="price">{formatMoney(item.finalPrice)}</div>
                                                        <div className="recoQtyControl">
                                                            <button onClick={(e) => { e.stopPropagation(); updateQty(item.id, -1) }}><Minus size={14} /></button>
                                                            <span>{item.quantity}</span>
                                                            <button onClick={(e) => { e.stopPropagation(); updateQty(item.id, 1) }}><Plus size={14} /></button>
                                                        </div>
                                                    </div>
                                                    <button
                                                        className="recoRemoveBtn"
                                                        onClick={(e) => { e.stopPropagation(); removeProduct(item.id) }}
                                                    >
                                                        <Trash2 size={18} />
                                                    </button>
                                                </div>
                                            ))
                                        )}
                                    </div>

                                    <div className="recoCartSummary">
                                        <div className="recoCartRow total">
                                            <span>Tổng cộng</span>
                                            <span>{formatMoney(cartTotal)}</span>
                                        </div>
                                        <button
                                            className="recoCheckoutBtn"
                                            disabled={cart.length === 0}
                                            onClick={() => setShowPayment(true)}
                                        >
                                            Thanh toán <CreditCard size={20} style={{ marginLeft: 8 }} />
                                        </button>
                                    </div>
                                </>
                            )}

                            {activeTab === 'history' && (
                                <div className="recoCartList" style={{ padding: 24 }}>
                                    {loadingHistory ? <p>Đang tải...</p> : (
                                        <div style={{ color: 'var(--c-text-muted)' }}>
                                            {historyInvoices?.length > 0 ? (
                                                historyInvoices.map((inv, idx) => (
                                                    <div key={idx} style={{ padding: '16px 0', borderBottom: '1px solid var(--glass-border)', fontSize: '0.95rem' }}>
                                                        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 4 }}>
                                                            <strong>{new Date(inv.timestamp).toLocaleDateString('vi-VN')}</strong>
                                                            <strong style={{ color: 'var(--c-primary)' }}>{formatMoney(inv.total_amount)}</strong>
                                                        </div>
                                                        <div style={{ fontSize: '0.9rem', opacity: 0.8 }}>Số lượng: {inv.items_count} sản phẩm</div>
                                                    </div>
                                                ))
                                            ) : (
                                                <div style={{ textAlign: 'center', marginTop: 40 }}>
                                                    <HistoryIcon size={48} style={{ opacity: 0.3, marginBottom: 20 }} />
                                                    <p>Khách chưa có lịch sử mua hàng.</p>
                                                </div>
                                            )}
                                        </div>
                                    )}
                                </div>
                            )}
                        </div>
                    </div>
                    )}

                    {/* 3. POPUP CHI TIẾT nằm TRONG điều kiện !showPayment */}
                    {selectedProduct && (
                        <div className="recoDetailOverlay" onClick={() => setSelectedProduct(null)}>
                            <div className="recoDetailPanel" onClick={e => e.stopPropagation()}>
                                {historyStack.length > 0 && (
                                    <button 
                                        className="recoDetailCloseBtn" 
                                        onClick={handleGoBack}
                                        title="Quay lại sản phẩm trước"
                                        style={{ marginRight: '8px' }} // Cách nút Đóng một chút
                                    >
                                        <ArrowLeft size={24} />
                                    </button>
                                )}
                                <button className="recoDetailClose" onClick={() => setSelectedProduct(null)}>
                                    ✕
                                </button>
                                <div className="recoDetailGrid">
                                    <div className="recoDetailImgCol">
                                        <img src={selectedProduct.image} alt={selectedProduct.name} />
                                    </div>
                                    <div className="recoDetailInfoCol">
                                        <div>
                                            <span className="recoDetailCategory">{selectedProduct.category}</span>
                                            <h2 className="recoDetailTitle">{selectedProduct.name}</h2>
                                            <div className="recoDetailPriceRow">
                                                <span className="currentPrice">{formatMoney(selectedProduct.finalPrice)}</span>
                                                {selectedProduct.hasDiscount && (
                                                    <span className="oldPrice">{formatMoney(selectedProduct.originalPrice)}</span>
                                                )}
                                            </div>
                                            <p className="recoDetailDesc">
                                                {selectedProduct.description || "Chưa có mô tả chi tiết."}
                                            </p>
                                            <div className="recoDetailMeta">
                                                <div className="metaItem">
                                                    <span className="label">Tồn kho</span>
                                                    <span className="value">{selectedProduct.stock}</span>
                                                </div>
                                                <div className="metaItem">
                                                    <span className="label">Mã SP</span>
                                                    <span className="value">{selectedProduct.productCode || `#${selectedProduct.id}`}</span>
                                                </div>
                                            </div>
                                        </div>
                                        <div className="recoDetailActions">
                                            <button
                                                className="recoDetailAddBtn"
                                                onClick={() => {
                                                    addToCart(selectedProduct);
                                                    setSelectedProduct(null);
                                                }}
                                            >
                                                <ShoppingCart size={20} /> Thêm vào giỏ ngay
                                            </button>
                                        </div>
                                    </div>
                                </div>
                                {/* Related Products */}
                                <div className="related-products-section">
                                    <h4 className="related-products-title">Sản phẩm liên quan</h4>
                                    
                                    {isLoadingRelated ? (
                                        <div className="related-products-status">Đang tải đề xuất...</div>
                                    ) : relatedProducts.length > 0 ? (
                                        <div className="related-products-list">
                                            {relatedProducts.map((rp, index) => (
                                                <div 
                                                    key={rp.id} 
                                                    className="related-product-card"
                                                    onClick={() => handleSelectRelatedProduct(rp, index + 1)}
                                                    title={rp.name}
                                                >
                                                    <img 
                                                        src={rp.image} 
                                                        alt={rp.name} 
                                                        className="related-product-image"
                                                    />
                                                    <p className="related-product-name">{rp.name}</p>
                                                    <p className="related-product-price">
                                                        {formatMoney(rp.finalPrice)}
                                                    </p>
                                                </div>
                                            ))}
                                        </div>
                                    ) : (
                                        <div className="related-products-status">
                                            Chưa có dữ liệu mua kèm.
                                        </div>
                                    )}
                                </div>
                            </div>
                        </div>
                    )}

                    {showLogoutConfirm ? (
                        <div className="recoConfirmOverlay" onClick={() => setShowLogoutConfirm(false)}>
                            <div className="recoConfirmCard" onClick={(e) => e.stopPropagation()}>
                                <div className="recoConfirmIcon">
                                    <LogOut size={20} />
                                </div>
                                <h3 className="recoConfirmTitle">Xác nhận đăng xuất?</h3>
                                <p className="recoConfirmText">
                                    Bạn sẽ cần đăng nhập lại để tiếp tục xem gợi ý sản phẩm và lịch sử mua hàng.
                                </p>
                                <div className="recoConfirmActions">
                                    <button
                                        type="button"
                                        className="recoHeaderBtn"
                                        onClick={() => setShowLogoutConfirm(false)}
                                        disabled={loggingOut}
                                    >
                                        Ở lại
                                    </button>
                                    <button
                                        type="button"
                                        className="recoHeaderBtn recoHeaderBtn--danger"
                                        onClick={handleLogout}
                                        disabled={loggingOut}
                                    >
                                        {loggingOut ? 'Đang đăng xuất...' : 'Đăng xuất'}
                                    </button>
                                </div>
                            </div>
                        </div>
                    ) : null}
                </div>
            ) : (
                /* Khi showPayment = true */
                <PaymentInterface
                    selectedProducts={mapCartToPaymentItems(cart)}
                    customerId={customer?.customer_id ?? customer?.id}
                    customerFName={customer?.first_name}
                    customerLName={customer?.last_name}
                    customerTier={customer?.tier}
                    onBack={() => setShowPayment(false)}
                    onPaymentComplete={() => {
                        window.sessionStorage.removeItem(CHECKOUT_DRAFT_KEY);
                        setCart([]);
                        setShowPayment(false);
                        onClose?.();
                    }}
                />
            )}
        </div>
    );
}


export default ProductRecommendation;
