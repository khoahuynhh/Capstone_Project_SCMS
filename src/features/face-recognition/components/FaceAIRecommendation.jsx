import React, { useCallback, useEffect, useState, useMemo, useRef } from 'react';
import { X, Search, CreditCard, Plus, Minus, Sparkles, User, Brain, ArrowLeft } from 'lucide-react';
import { useProducts } from '../hooks/useProducts';
import { serverApi } from '../../../core/api/server_api';
import '../css/ProductRecommendation.css';
import PaymentInterface from './PaymentInterface';

const getRecommendationSessionId = () => {
    const key = 'fbrs_recommendation_session_id';
    const existing = window.sessionStorage.getItem(key);
    if (existing) return existing;

    const sessionId = window.crypto?.randomUUID?.() || `${Date.now()}-${Math.random().toString(16).slice(2)}`;
    window.sessionStorage.setItem(key, sessionId);
    return sessionId;
};

// --- HELPER: Map data DB (CSV format) -> UI ---
const mapDbProductToUi = (p) => {
    const originalPrice = Number(p.price ?? 0);
    const discountPrice = p.discount_price ? Number(p.discount_price) : null;
    
    return {
        id: String(p.id ?? p.product_pk ?? p.product_id),
        productCode: p.product_code || p.product_id,
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
        usageContext: p.usage_context || '',                      // 'cooking', 'travel', etc.
        recommendationId: p.recommendation_id ?? p.recommendationId ?? null,
        recommendationSurface: p.recommendation_surface || p.recommendationSurface,
        recommendationAlgorithm: p.recommendation_algorithm || p.recommendationAlgorithm,
        recommendationPosition: p.recommendation_position ?? p.recommendationPosition ?? null,
    };
};

const EMOTION_LABELS = {
    neutral: 'Bình thường',
    happy: 'Vui vẻ',
    sad: 'Buồn',
    angry: 'Tức giận',
    surprise: 'Ngạc nhiên',
    surprised: 'Ngạc nhiên',
    fear: 'Lo lắng',
    fearful: 'Lo lắng',
    disgust: 'Không hài lòng',
    contempt: 'Không hài lòng',
};

const toDisplayLabel = (value, labels = {}) => {
    if (value === null || value === undefined || value === '') return 'Chưa có';
    const key = String(value).trim().toLowerCase();
    if (labels[key]) return labels[key];

    return key
        .replace(/[_-]+/g, ' ')
        .replace(/\s+/g, ' ')
        .replace(/\b\w/g, (char) => char.toUpperCase());
};

const FaceAIRecommendation = ({ aiContext, isOpen = true, onClose }) => {
    // aiContext: { gender: 'male'|'female', age: number, emotion: string }
    
    const [cart, setCart] = useState([]);
    const [searchTerm, setSearchTerm] = useState('');
    const { products: dbProducts, isLoading } = useProducts();
    const [cloudRecommendations, setCloudRecommendations] = useState([]);
    const [loadingRecommendations, setLoadingRecommendations] = useState(false);
    const [selectedProduct, setSelectedProduct] = useState(null);
    const [relatedProducts, setRelatedProducts] = useState([]);
    const [isLoadingRelated, setIsLoadingRelated] = useState(false);
    const [historyStack, setHistoryStack] = useState([]);
    const [showPayment, setShowPayment] = useState(false);
    const sessionIdRef = useRef(null);
    const trackedImpressionsRef = useRef(new Set());
    const trackedAcceptancesRef = useRef(new Set());
    const [relatedRecommendationId, setRelatedRecommendationId] = useState(undefined);

    if (!sessionIdRef.current && typeof window !== 'undefined') {
        sessionIdRef.current = getRecommendationSessionId();
    }

    useEffect(() => {
        if (!isOpen || !aiContext) {
            setCloudRecommendations([]);
            return;
        }

        setLoadingRecommendations(true);
        serverApi.recommendationsByAttributes({
            age: aiContext.age,
            ageGroup: aiContext.age_group,
            gender: aiContext.gender,
            emotion: aiContext.emotion,
            branchId: import.meta.env.VITE_BRANCH_ID || 'HCM_Q1',
            deviceId: import.meta.env.VITE_DEVICE_ID || 'EDGE_HCM_Q1_01',
            sessionId: sessionIdRef.current,
            topK: 50,
        })
            .then((data) => {
                const recommendationId = data?.recommendation_id ?? null;
                const products = Array.isArray(data?.products) ? data.products : [];
                setCloudRecommendations(products.map((product, index) => ({
                    ...product,
                    recommendation_id: recommendationId,
                    recommendation_surface: 'face_ai_recommendation',
                    recommendation_algorithm: 'attribute_ai',
                    recommendation_position: index + 1,
                })));
            })
            .catch((error) => {
                console.error('Lỗi tải gợi ý theo AI context:', error);
                setCloudRecommendations([]);
            })
            .finally(() => setLoadingRecommendations(false));
    }, [isOpen, aiContext]);

    useEffect(() => {
        if (!selectedProduct?.id) {
            setRelatedProducts([]);
            setIsLoadingRelated(false);
            return;
        }

        let cancelled = false;
        setIsLoadingRelated(true);

        serverApi.relatedProducts(selectedProduct.id, 5)
            .then((data) => {
                if (cancelled) return;
                setRelatedProducts(Array.isArray(data) ? data.map(mapDbProductToUi) : []);
            })
            .catch((error) => {
                if (cancelled) return;
                console.error('Lỗi tải sản phẩm liên quan:', error);
                setRelatedProducts([]);
            })
            .finally(() => {
                if (!cancelled) setIsLoadingRelated(false);
            });

        return () => {
            cancelled = true;
        };
    }, [selectedProduct?.id]);

    // --- AI LOGIC: Tính toán độ phù hợp (Scoring Engine) ---
    const displayProducts = useMemo(() => {
        if (!dbProducts) return [];
        let list = dbProducts.map(mapDbProductToUi);
        const cloudList = Array.isArray(cloudRecommendations)
            ? cloudRecommendations.map(mapDbProductToUi)
            : [];

        if (searchTerm) {
            list = list.filter(p => p.name.toLowerCase().includes(searchTerm.toLowerCase()));
        }

        if (cloudList.length > 0 && !searchTerm) {
            const seen = new Set(cloudList.map((p) => p.id));
            return [...cloudList, ...list.filter((p) => !seen.has(p.id))];
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
    }, [dbProducts, searchTerm, aiContext, cloudRecommendations]);

    const cartTotal = cart.reduce((sum, item) => sum + (item.finalPrice * item.quantity), 0);
    const cartCount = cart.reduce((sum, item) => sum + item.quantity, 0);
    const formatMoney = (n) => n.toLocaleString('vi-VN') + 'đ';
    const branchId = import.meta.env.VITE_BRANCH_ID || 'HCM_Q1';
    const deviceId = import.meta.env.VITE_DEVICE_ID || 'EDGE_HCM_Q1_01';
    const emotionLabel = toDisplayLabel(aiContext?.emotion, EMOTION_LABELS);

    const mapProductsToBatchPayload = (products) =>
        products.map((product, index) => ({
            id: Number(product.id),
            product_code: product.productCode || product.product_code || '',
            name: product.name,
            price: product.finalPrice ?? product.price ?? product.originalPrice ?? 0,
            category: product.category,
            recommendation_position: index + 1,
        }));

    useEffect(() => {
        if (!isOpen || showPayment || !selectedProduct || relatedProducts.length === 0) {
            setRelatedRecommendationId(undefined);
            return undefined;
        }

        let cancelled = false;
        setRelatedRecommendationId(undefined);
        serverApi.createRecommendationBatch({
            branchId,
            deviceId,
            sessionId: sessionIdRef.current,
            surface: 'face_related_products',
            algorithm: 'association_rules',
            context: { source_product_id: selectedProduct.id },
            products: mapProductsToBatchPayload(relatedProducts),
        })
            .then((data) => {
                if (!cancelled) setRelatedRecommendationId(data?.recommendation_id ?? null);
            })
            .catch((error) => {
                console.error('Lỗi tạo related recommendation batch:', error);
                if (!cancelled) setRelatedRecommendationId(null);
            });

        return () => {
            cancelled = true;
        };
    }, [isOpen, showPayment, selectedProduct, relatedProducts, branchId, deviceId]);

    const sendRecommendationEvents = useCallback((events) => {
        if (!events.length) return;
        for (let i = 0; i < events.length; i += 100) {
            serverApi.recommendationEvents(events.slice(i, i + 100)).catch((error) => {
                console.error('Failed to write recommendation event:', error);
            });
        }
    }, []);

    const buildRecommendationEvent = useCallback((eventType, product, position) => ({
        event_type: eventType,
        product_id: Number(product.id),
        branch_id: branchId,
        device_id: deviceId,
        surface: product.recommendationSurface || 'face_ai_recommendation',
        algorithm: product.recommendationAlgorithm || 'attribute_ai',
        position,
        session_id: sessionIdRef.current,
        recommendation_id: product.recommendationId
            ?? (product.recommendationSurface === 'face_related_products' ? relatedRecommendationId : null),
        event_metadata: {
            age: aiContext?.age ?? null,
            age_group: aiContext?.age_group ?? null,
            gender: aiContext?.gender ?? null,
            emotion: aiContext?.emotion ?? null,
            source_product_id: product.sourceProductId ?? null,
        },
    }), [aiContext, branchId, deviceId, relatedRecommendationId]);

    useEffect(() => {
        if (!isOpen || showPayment || isLoading || loadingRecommendations || displayProducts.length === 0) return;

        const events = [];
        displayProducts.forEach((product, index) => {
            const position = index + 1;
            const key = `face_ai_recommendation:${product.id}:${position}:${aiContext?.age ?? ''}:${aiContext?.gender ?? ''}:${aiContext?.emotion ?? ''}`;
            if (trackedImpressionsRef.current.has(key)) return;
            trackedImpressionsRef.current.add(key);
            events.push(buildRecommendationEvent('impression', product, position));
        });

        sendRecommendationEvents(events);
    }, [aiContext, buildRecommendationEvent, displayProducts, isLoading, isOpen, loadingRecommendations, sendRecommendationEvents, showPayment]);

    const addToCart = (product) => {
        const surface = product.recommendationSurface || 'face_ai_recommendation';
        const acceptanceKey = `${surface}:${product.id}`;
        if (!trackedAcceptancesRef.current.has(acceptanceKey)) {
            trackedAcceptancesRef.current.add(acceptanceKey);
            sendRecommendationEvents([
                buildRecommendationEvent('add_to_cart', product, product.recommendationPosition ?? null),
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

    useEffect(() => {
        if (!isOpen || showPayment || !selectedProduct || relatedRecommendationId === undefined || relatedProducts.length === 0) return;

        const events = [];
        relatedProducts.forEach((product, index) => {
            const position = index + 1;
            const key = `face_related_products:${selectedProduct.id}:${product.id}:${position}`;
            if (trackedImpressionsRef.current.has(key)) return;
            trackedImpressionsRef.current.add(key);
            events.push(buildRecommendationEvent('impression', {
                ...product,
                recommendationSurface: 'face_related_products',
                recommendationAlgorithm: 'association_rules',
                sourceProductId: selectedProduct.id,
            }, position));
        });

        sendRecommendationEvents(events);
    }, [buildRecommendationEvent, isOpen, relatedProducts, relatedRecommendationId, selectedProduct, sendRecommendationEvents, showPayment]);

    const handleSelectRelatedProduct = (product, position) => {
        const relatedProduct = {
            ...product,
            recommendationSurface: 'face_related_products',
            recommendationAlgorithm: 'association_rules',
            recommendationPosition: position,
            sourceProductId: selectedProduct?.id ?? null,
        };

        sendRecommendationEvents([buildRecommendationEvent('click', relatedProduct, position)]);
        setHistoryStack((prev) => [...prev, selectedProduct]);
        setSelectedProduct(relatedProduct);
    };

    const handleGoBack = () => {
        if (historyStack.length === 0) return;

        const nextStack = [...historyStack];
        const previousProduct = nextStack.pop();
        setHistoryStack(nextStack);
        setSelectedProduct(previousProduct);
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
                            <h2 style={{ margin: 0, color: '#fff', fontSize: '1.5rem' }}>Sản phẩm dành cho bạn</h2>
                            <div className="ai-badge-container">
                                <span className="ai-mini-badge">
                                    <User size={12}/> {aiContext?.gender === 'male' ? 'Nam' : 'Nữ'}
                                </span>
                                <span className="ai-mini-badge">{aiContext?.age} tuổi</span>
                                <span className="ai-mini-badge">{emotionLabel}</span>
                            </div>
                        </div>
                    </div>
                    {onClose ? (
                        <button
                            onClick={onClose}
                            className="recoCloseBtn"
                            style={{ color: '#fff', background: 'transparent', border: 'none', cursor: 'pointer' }}
                            aria-label="Đóng gợi ý AI"
                        >
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

                        {isLoading || loadingRecommendations ? (
                            <div style={{ padding: '20px', textAlign: 'center' }}>Đang tải dữ liệu sản phẩm...</div>
                        ) : (
                            <div className="recoGrid">
                                {displayProducts.map((product, index) => (
                                    <div
                                        key={product.id}
                                        className="recoCard"
                                        onClick={() => {
                                            sendRecommendationEvents([
                                                buildRecommendationEvent('click', product, index + 1),
                                            ]);
                                            setHistoryStack([]);
                                            setSelectedProduct(product);
                                        }}
                                    >
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
                    <div className="recoDetailOverlay" onClick={() => {
                        setSelectedProduct(null);
                        setHistoryStack([]);
                    }}>
                        <div className="recoDetailPanel" onClick={(e) => e.stopPropagation()}>
                            {historyStack.length > 0 && (
                                <button
                                    className="recoDetailCloseBtn"
                                    onClick={handleGoBack}
                                    title="Quay lại sản phẩm trước"
                                    type="button"
                                    aria-label="Quay lại sản phẩm trước"
                                >
                                    <ArrowLeft size={24} />
                                </button>
                            )}
                            <button className="recoDetailClose" aria-label="Đóng chi tiết sản phẩm" onClick={() => {
                                setSelectedProduct(null);
                                setHistoryStack([]);
                            }}>
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

                            <div className="related-products-section">
                                <h4 className="related-products-title">Sản phẩm liên quan</h4>

                                {isLoadingRelated ? (
                                    <div className="related-products-status">Đang tải đề xuất...</div>
                                ) : relatedProducts.length > 0 ? (
                                    <div className="related-products-list">
                                        {relatedProducts.map((product, index) => (
                                            <div
                                                key={product.id}
                                                className="related-product-card"
                                                onClick={() => handleSelectRelatedProduct(product, index + 1)}
                                                title={product.name}
                                            >
                                                <img
                                                    src={product.image}
                                                    alt={product.name}
                                                    className="related-product-image"
                                                />
                                                <p className="related-product-name">{product.name}</p>
                                                <p className="related-product-price">{formatMoney(product.finalPrice)}</p>
                                            </div>
                                        ))}
                                    </div>
                                ) : (
                                    <div className="related-products-status">Chưa có dữ liệu mua kèm.</div>
                                )}
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
