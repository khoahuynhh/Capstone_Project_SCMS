import React, { useState, useMemo } from 'react';
import { X, Search, CreditCard, Plus, Minus, Sparkles, User, Brain } from 'lucide-react';
import { useProducts } from '../hooks/useProducts';
import '../css/ProductRecommendation.css';
import PaymentInterface from './PaymentInterface';

// --- HELPER: Map data DB (CSV format) -> UI ---
const mapDbProductToUi = (p) => {
    const originalPrice = Number(p.price ?? 0);
    const discountPrice = p.discount_price ? Number(p.discount_price) : null;
    
    return {
        id: String(p.id ?? p.product_id),
        productCode: p.product_code,
        name: p.name || "Sản phẩm",
        category: (p.category || "Khác").toLowerCase(),
        originalPrice,
        finalPrice: (discountPrice && discountPrice < originalPrice) ? discountPrice : originalPrice,
        image: p.image_url || "https://via.placeholder.com/150",
        stock: p.stock ?? 0,
        hasDiscount: !!(discountPrice && discountPrice < originalPrice),
        discountPercentage: Math.round(((originalPrice - (discountPrice || 0)) / originalPrice) * 100),
        description: p.description || "",
        
        // CÁC TRƯỜNG DÀNH CHO AI GỢI Ý ĐƯỢC CẬP NHẬT TỪ CSV
        targetGender: p.target_gender?.toLowerCase() || 'unisex', // 'male', 'female', 'unisex'
        targetAgeGroup: p.target_age_group || 'all',              // '25_34', '35_44', etc.
        emotion: (p.mood_tag || p.emotion || 'neutral').toLowerCase(), // Lấy từ mood_tag
        usageContext: p.usage_context || ''                       // 'cooking', 'travel', etc.
    };
};

const FaceAIRecommendation = ({ aiContext, isOpen = true, onClose }) => {
    // aiContext: { gender: 'male'|'female', age: number, emotion: string }
    
    const [cart, setCart] = useState([]);
    const [searchTerm, setSearchTerm] = useState('');
    const { products: dbProducts, isLoading } = useProducts();
    const [selectedProduct, setSelectedProduct] = useState(null);
    const [showPayment, setShowPayment] = useState(false);

    // --- AI LOGIC: Tính toán độ phù hợp (Scoring Engine) ---
    const displayProducts = useMemo(() => {
        if (!dbProducts) return [];
        let list = dbProducts.map(mapDbProductToUi);

        if (searchTerm) {
            list = list.filter(p => p.name.toLowerCase().includes(searchTerm.toLowerCase()));
        }

        return list.sort((a, b) => {
            const getScore = (p) => {
                let score = 0;

                // 1. Gợi ý theo Giới tính
                if (aiContext?.gender) {
                    if (p.targetGender === aiContext.gender.toLowerCase()) {
                        score += 50; // Trùng khớp nam/nữ
                    } else if (p.targetGender === 'unisex' || p.targetGender === 'all') {
                        score += 25; // Sản phẩm dùng chung
                    }
                }

                // 2. Gợi ý theo Độ tuổi (Xử lý định dạng dấu gạch dưới VD: "25_34")
                if (aiContext?.age && p.targetAgeGroup !== 'all') {
                    const age = aiContext.age;
                    
                    // Xử lý định dạng "25_34" hoặc "25-34"
                    if (p.targetAgeGroup.includes('_') || p.targetAgeGroup.includes('-')) {
                        const separator = p.targetAgeGroup.includes('_') ? '_' : '-';
                        const [min, max] = p.targetAgeGroup.split(separator).map(Number);
                        
                        if (age >= min && age <= max) {
                            score += 40; // Nằm trong độ tuổi vàng
                        } else if (Math.abs(age - min) <= 3 || Math.abs(age - max) <= 3) {
                            score += 15; // Cận kề khoảng tuổi (chênh lệch +-3 tuổi vẫn gợi ý)
                        }
                    } 
                    // Xử lý định dạng lớn hơn VD: "40+" (nếu sau này có)
                    else if (p.targetAgeGroup.includes('+')) {
                        const min = Number(p.targetAgeGroup.replace('+', ''));
                        if (age >= min) score += 40;
                    }
                } else if (p.targetAgeGroup === 'all') {
                    score += 10;
                }

                // 3. Gợi ý theo Cảm xúc (Match với mood_tag)
                if (aiContext?.emotion && p.emotion !== 'neutral') {
                    if (p.emotion === aiContext.emotion.toLowerCase()) {
                        score += 30; 
                    }
                }

                return score;
            };

            return getScore(b) - getScore(a); 
        });
    }, [dbProducts, searchTerm, aiContext]);

    const cartTotal = cart.reduce((sum, item) => sum + (item.finalPrice * item.quantity), 0);
    const cartCount = cart.reduce((sum, item) => sum + item.quantity, 0);
    const formatMoney = (n) => n.toLocaleString('vi-VN') + 'đ';

    const addToCart = (product) => {
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
        setCart(prev => {
            return prev.map(item => {
                if (item.id === id) {
                    const newQty = item.quantity + delta;
                    return newQty > 0 ? { ...item, quantity: newQty } : item;
                }
                return item;
            }).filter(item => item.quantity > 0);
        });
    };

    const mapCartToPaymentItems = (items) =>
        items.map((item) => ({
            id: Number(item.id),
            name: item.name,
            price: item.finalPrice,
            quantity: item.quantity,
            image_url: item.image,
            product_code: item.productCode || '',
        }));

    if (!isOpen) return null;

    return (
        <div className="recoOverlay">
            {!showPayment ? (
            <div className="recoShell">
                {/* --- HEADER AI --- */}
                <div className="recoHeader" style={{ background: 'linear-gradient(135deg, #6366f1 0%, #a855f7 100%)' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
                        <div className="ai-status-icon">
                            <Brain size={32} color="#fff" />
                        </div>
                        <div>
                            <h2 style={{ margin: 0, color: '#fff', fontSize: '1.5rem' }}>Gợi ý AI thông minh</h2>
                            <div className="ai-badge-container">
                                <span className="ai-mini-badge">
                                    <User size={12}/> {aiContext?.gender === 'male' ? 'Nam' : 'Nữ'}
                                </span>
                                <span className="ai-mini-badge">{aiContext?.age} tuổi</span>
                                <span className="ai-mini-badge" style={{textTransform: 'capitalize'}}>{aiContext?.emotion}</span>
                            </div>
                        </div>
                    </div>
                    {onClose ? (
                        <button onClick={onClose} className="recoCloseBtn" style={{ color: '#fff', background: 'transparent', border: 'none', cursor: 'pointer' }}>
                            <X size={24} />
                        </button>
                    ) : null}
                </div>

                <div className="recoBody">
                    {/* CỘT TRÁI: DANH SÁCH SẢN PHẨM */}
                    <div className="recoMain">
                        <div className="recoSearch">
                            <Search size={20} />
                            <input 
                                type="text" 
                                placeholder="Dựa trên khuôn mặt, chúng tôi khuyên dùng..." 
                                value={searchTerm}
                                onChange={e => setSearchTerm(e.target.value)}
                            />
                        </div>

                        {isLoading ? (
                            <div style={{ padding: '20px', textAlign: 'center' }}>Đang tải dữ liệu sản phẩm...</div>
                        ) : (
                            <div className="recoGrid">
                                {displayProducts.map((product, index) => (
                                    <div key={product.id} className="recoCard" onClick={() => setSelectedProduct(product)}>
                                        <div className="recoCardImg">
                                            <img src={product.image} alt={product.name} />
                                            {index < 3 && !searchTerm && (
                                                <span className="recoBadge ai-best-match">
                                                    <Sparkles size={12} /> Phù hợp nhất
                                                </span>
                                            )}
                                        </div>
                                        <div className="recoCardContent">
                                            <h3 className="recoCardTitle">{product.name}</h3>
                                            <div className="recoCardPrice">{formatMoney(product.finalPrice)}</div>
                                            <button className="recoCardAddBtn" onClick={(e) => { e.stopPropagation(); addToCart(product); }}>
                                                <Plus size={18} /> Thêm vào giỏ
                                            </button>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>

                    {/* CỘT PHẢI: GIỎ HÀNG */}
                    <div className="recoSidebar">
                        <div className="recoTabs">
                            <button className="recoTab active">Giỏ hàng ({cartCount})</button>
                        </div>
                        <div className="recoCartList">
                            {cart.map(item => (
                                <div key={item.id} className="recoCartItem">
                                    <img src={item.image} alt={item.name} />
                                    <div className="recoCartItemInfo">
                                        <h4>{item.name}</h4>
                                        <div className="price">{formatMoney(item.finalPrice)}</div>
                                    </div>
                                    <div className="recoQtyControl">
                                        <button onClick={() => updateQty(item.id, -1)}><Minus size={14}/></button>
                                        <span>{item.quantity}</span>
                                        <button onClick={() => updateQty(item.id, 1)}><Plus size={14}/></button>
                                    </div>
                                </div>
                            ))}
                            {cart.length === 0 && (
                                <div style={{ textAlign: 'center', padding: '20px', color: '#666' }}>
                                    Giỏ hàng trống
                                </div>
                            )}
                        </div>
                        <div className="recoCartSummary">
                            <div className="recoCartRow total">
                                <span>Tổng:</span>
                                <span>{formatMoney(cartTotal)}</span>
                            </div>
                            <button
                                className="recoCheckoutBtn"
                                style={{ background: 'var(--c-primary)', width: '100%', display: 'flex', justifyContent: 'center', alignItems: 'center' }}
                                disabled={cart.length === 0}
                                onClick={() => setShowPayment(true)}
                            >
                                Thanh toán ngay <CreditCard size={20} style={{marginLeft: 8}}/>
                            </button>
                        </div>
                    </div>
                </div>

                {selectedProduct && (
                    <div className="recoDetailOverlay" onClick={() => setSelectedProduct(null)}>
                        <div className="recoDetailPanel" onClick={(e) => e.stopPropagation()}>
                            <button className="recoDetailClose" onClick={() => setSelectedProduct(null)}>
                                <X size={20} />
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
                                            <Plus size={18} /> Thêm vào giỏ ngay
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                )}
            </div>
            ) : (
                <PaymentInterface
                    selectedProducts={mapCartToPaymentItems(cart)}
                    onBack={() => setShowPayment(false)}
                    onPaymentComplete={() => {
                        setCart([]);
                        setShowPayment(false);
                        onClose?.();
                    }}
                />
            )}
        </div>
    );
};

export default FaceAIRecommendation;
