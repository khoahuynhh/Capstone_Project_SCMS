import { useState } from 'react';
import PaymentInterface from './PaymentInterface';
import PurchaseHistory from './PurchaseHistory';

const ProductRecommendation = ({ customer, isOpen, onClose }) => {
    const [searchQuery, setSearchQuery] = useState('');
    const [selectedProduct, setSelectedProduct] = useState(null);
    const [cart, setCart] = useState([]);
    const [showPayment, setShowPayment] = useState(false);
    const [showHistory, setShowHistory] = useState(false);

    // Functions
    const addToCart = (product) => {
        const existingItem = cart.find(item => item.id === product.id);
        if (existingItem) {
            setCart(cart.map(item => 
                item.id === product.id 
                    ? { ...item, quantity: item.quantity + 1 }
                    : item
            ));
        } else {
            setCart([...cart, { ...product, quantity: 1 }]);
        }
        setSelectedProduct(null);
    };

    const buyNow = (product) => {
        setCart([{ ...product, quantity: 1 }]);
        setSelectedProduct(null);
        setShowPayment(true);
    };

    const handlePaymentComplete = (paymentDetails) => {
        console.log('Payment completed:', paymentDetails);
        setCart([]);
        setShowPayment(false);
        onClose();
    };

    // Mock data lịch sử mua hàng của khách (giả lập từ database)
    const customerPurchaseHistory = [
        { productId: 1, productName: 'iPhone 15 Pro Max', purchaseCount: 3, lastPurchase: '2024-09-01' },
        { productId: 2, productName: 'Samsung Galaxy S24', purchaseCount: 1, lastPurchase: '2024-08-15' },
        { productId: 5, productName: 'AirPods Pro 2', purchaseCount: 2, lastPurchase: '2024-09-10' },
        { productId: 8, productName: 'iPhone 15 Pro', purchaseCount: 1, lastPurchase: '2024-07-20' },
        { productId: 6, productName: 'Sony WH-1000XM5', purchaseCount: 1, lastPurchase: '2024-08-25' }
    ];

    // Tính điểm ưu tiên cho sản phẩm
    const calculateProductPriority = (product) => {
        let priority = 0;

        // 1. Điểm cao nhất cho sản phẩm khách đang tìm kiếm
        if (searchQuery && (
            product.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
            product.category.toLowerCase().includes(searchQuery.toLowerCase()) ||
            product.description.toLowerCase().includes(searchQuery.toLowerCase())
        )) {
            priority += 1000; // Điểm tối đa cho kết quả tìm kiếm
        }

        // 2. Điểm cao cho sản phẩm khách đã từng mua
        const purchaseHistory = customerPurchaseHistory.find(p => p.productId === product.id);
        if (purchaseHistory) {
            priority += 500 + (purchaseHistory.purchaseCount * 50); // 500 điểm base + thêm điểm theo số lần mua
        }

        // 3. Điểm cho sản phẩm có khuyến mãi/ưu đãi
        if (product.isPromotion) {
            priority += 300; // Khuyến mãi đặc biệt
        }

        if (product.isVipOnly && customer?.membershipLevel === 'VIP') {
            priority += 250; // Ưu đãi VIP cho khách VIP
        }

        if (product.discount) {
            const discountValue = parseFloat(product.discount.replace('%', ''));
            priority += discountValue * 10; // Càng giảm giá nhiều càng ưu tiên
        }

        if (product.salePrice && product.salePrice < product.originalPrice) {
            const discountAmount = product.originalPrice - product.salePrice;
            priority += Math.min(discountAmount / 100000, 100); // Điểm theo số tiền giảm
        }

        // 4. Điểm cho sản phẩm tương tự với lịch sử mua hàng (theo category)
        const purchasedCategories = customerPurchaseHistory.map(p => {
            const purchasedProduct = [...mockProducts.recommended, ...mockProducts.similar, ...mockProducts.promotions, ...mockProducts.vipVouchers, ...mockProducts.others].find(prod => prod.id === p.productId);
            return purchasedProduct?.category;
        }).filter(Boolean);

        if (purchasedCategories.includes(product.category)) {
            priority += 150; // Ưu tiên sản phẩm cùng loại đã mua
        }

        // 5. Điểm cho rating cao
        if (product.rating) {
            priority += product.rating * 20; // 20 điểm per rating star
        }

        // 6. Điểm cho sản phẩm còn ít (tạo cảm giác khan hiếm)
        if (product.stock <= 5) {
            priority += 80;
        }

        // 7. Điểm cho sản phẩm phổ biến (giả định theo số lượng còn lại)
        const soldQuantity = 100 - product.stock; // Giả định ban đầu có 100
        priority += soldQuantity * 2;

        return priority;
    };

    // Mock data cho sản phẩm
    const mockProducts = {
        recommended: [
        {
            id: 1,
            name: 'iPhone 15 Pro Max',
            image: 'https://cdn2.fptshop.com.vn/unsafe/768x0/filters:format(webp):quality(75)/2023_9_14_638302874057113482_so-sanh-iphone-15-pro-va-iphone-15-pro-max-12.jpg',
            originalPrice: 34990000,
            salePrice: 31990000,
            discount: '9%',
            location: 'Kệ A1-05',
            description: 'iPhone 15 Pro Max với chip A17 Pro mạnh mẽ, camera chuyên nghiệp',
            category: 'Điện thoại',
            stock: 15,
            rating: 1
        },
        {
            id: 2,
            name: 'Samsung Galaxy S24 Ultra',
            image: '/api/placeholder/200/200',
            originalPrice: 32990000,
            salePrice: 29990000,
            discount: '9%',
            location: 'Kệ A1-08',
            description: 'Galaxy S24 Ultra với bút S Pen, camera 200MP, màn hình Dynamic AMOLED',
            category: 'Điện thoại',
            stock: 12,
            rating: 4.7
        },
        {
            id: 3,
            name: 'MacBook Air M3',
            image: '/api/placeholder/200/200',
            originalPrice: 28990000,
            salePrice: 26990000,
            discount: '7%',
            location: 'Kệ B2-03',
            description: 'MacBook Air với chip M3, thiết kế siêu mỏng, pin 18 giờ',
            category: 'Laptop',
            stock: 8,
            rating: 4.9
        }
        ],
        similar: [
        {
            id: 4,
            name: 'iPad Pro 12.9"',
            image: '/api/placeholder/200/200',
            originalPrice: 25990000,
            salePrice: 23990000,
            discount: '8%',
            location: 'Kệ A2-12',
            description: 'iPad Pro với chip M2, màn hình Liquid Retina XDR',
            category: 'Tablet',
            stock: 10,
            rating: 4.6
        },
        {
            id: 5,
            name: 'AirPods Pro 2',
            image: '/api/placeholder/200/200',
            originalPrice: 6490000,
            salePrice: 5990000,
            discount: '8%',
            location: 'Kệ C1-15',
            description: 'AirPods Pro với Active Noise Cancellation, Spatial Audio',
            category: 'Phụ kiện',
            stock: 25,
            rating: 4.8
        }
        ],
        promotions: [
        {
            id: 6,
            name: 'Sony WH-1000XM5',
            image: '/api/placeholder/200/200',
            originalPrice: 8990000,
            salePrice: 6990000,
            discount: '22%',
            location: 'Kệ C2-08',
            description: 'Tai nghe chống ồn cao cấp, chất lượng âm thanh tuyệt vời',
            category: 'Phụ kiện',
            stock: 18,
            rating: 4.7,
            isPromotion: true
        },
        {
            id: 7,
            name: 'LG OLED C3 55"',
            image: '/api/placeholder/200/200',
            originalPrice: 35990000,
            salePrice: 28990000,
            discount: '19%',
            location: 'Kho D-TV-01',
            description: 'Smart TV OLED 4K, HDR10, Dolby Vision, Gaming Mode',
            category: 'TV',
            stock: 5,
            rating: 4.8,
            isPromotion: true
        }
        ],
        vipVouchers: [
        {
            id: 8,
            name: 'iPhone 15 Pro',
            image: '/api/placeholder/200/200',
            originalPrice: 28990000,
            voucherPrice: 25990000,
            voucherDiscount: 'VIP -10%',
            location: 'Kệ A1-03',
            description: 'iPhone 15 Pro với camera Pro, chip A17 Pro',
            category: 'Điện thoại',
            stock: 20,
            rating: 4.8,
            isVipOnly: true
        },
        {
            id: 9,
            name: 'MacBook Pro 14" M3',
            image: '/api/placeholder/200/200',
            originalPrice: 45990000,
            voucherPrice: 41990000,
            voucherDiscount: 'VIP -9%',
            location: 'Kệ B2-01',
            description: 'MacBook Pro với chip M3 Pro, màn hình Liquid Retina XDR',
            category: 'Laptop',
            stock: 6,
            rating: 4.9,
            isVipOnly: true
        }
        ],
        others: [
        {
            id: 10,
            name: 'Nintendo Switch OLED',
            image: '/api/placeholder/200/200',
            originalPrice: 8990000,
            salePrice: 8990000,
            location: 'Kệ E1-20',
            description: 'Console gaming di động với màn hình OLED 7 inch',
            category: 'Gaming',
            stock: 15,
            rating: 4.6
        },
        {
            id: 11,
            name: 'Canon EOS R6 Mark II',
            image: '/api/placeholder/200/200',
            originalPrice: 42990000,
            salePrice: 42990000,
            location: 'Kệ F2-05',
            description: 'Máy ảnh mirrorless chuyên nghiệp, cảm biến Full Frame',
            category: 'Camera',
            stock: 3,
            rating: 4.7
        }
        ]
    };

    // Lấy nhãn ưu tiên cho sản phẩm
    const getPriorityLabel = (product) => {
        const labels = [];

        // Kiểm tra tìm kiếm
        if (searchQuery && (
            product.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
            product.category.toLowerCase().includes(searchQuery.toLowerCase()) ||
            product.description.toLowerCase().includes(searchQuery.toLowerCase())
        )) {
            labels.push({ text: 'Kết quả tìm kiếm', color: 'bg-blue-100 text-blue-800' });
        }

        // Kiểm tra lịch sử mua hàng
        const purchaseHistory = customerPurchaseHistory.find(p => p.productId === product.id);
        if (purchaseHistory) {
            if (purchaseHistory.purchaseCount > 2) {
                labels.push({ 
                    icon: (
                        <svg xmlns="http://www.w3.org/2000/svg" 
                            className="w-6 h-6" 
                            viewBox="0 0 256 256" 
                            fill="none">
                        <path 
                            fill="#F9B618" 
                            stroke="#F9B618" 
                            strokeWidth="4" 
                            strokeLinecap="round" 
                            strokeLinejoin="round" 
                            strokeMiterlimit="10" 
                            d="M123.574 52.994c2.434-4.932 6.417-4.932 8.852 0l18.164 36.807c2.434 4.932 8.879 9.613 14.322 10.404l40.617 5.902c5.443.791 6.674 4.578 2.735 8.418l-29.391 28.648c-3.938 3.84-6.4 11.416-5.47 16.836l6.938 40.453c.93 5.422-2.292 7.764-7.161 5.203l-36.329-19.1c-4.868-2.559-12.834-2.559-17.703 0l-36.329 19.1c-4.868 2.561-8.09.219-7.161-5.203l6.938-40.453c.93-5.42-1.532-12.996-5.47-16.836l-29.391-28.648c-3.938-3.84-2.708-7.627 2.735-8.418l40.617-5.902c5.443-.791 11.888-5.473 14.322-10.404l18.165-36.807z"
                        />
                        </svg>
                ),

                    text: 'Yêu thích', 
                    color: 'bg-yellow-200 text-yellow-800' });
            }
            // Ẩn label "Đã mua" - chỉ dùng cho thuật toán ưu tiên
        }

        // Kiểm tra khuyến mãi
        if (product.isPromotion) {
            labels.push({ 
                icon: (
                    <svg 
                    xmlns="http://www.w3.org/2000/svg" 
                    viewBox="0 0 64 64" 
                    className="w-4 h-4"
                    >
                    <path 
                        d="M13.75 56s-5-7.566-5-19c0-11.434 5.332-8.909 3-20 
                        0 0 6.391 8.123 6 16 0 0 .015-8.682 10-15s10-10 10-10 
                        6.877 7.303 9 17-1 15-1 15 6.606-4.632 7-10c0 0 7.734 
                        17.053-4 26"
                        style={{ fill: "currentColor", color: "#e34234" , stroke: "currentColor", strokeWidth: "2px" }}
                    />
                    <path 
                        d="M17.75 33s-.499 2.865.25 8M25.917 56s-1.667-2.522-1.667-6.333
                        c0-3.812 1.777-2.97 1-6.667 0 0 2.13 2.708 2 5.333 
                        0 0 .005-2.894 3.333-5C33.912 41.227 33.917 40 33.917 40
                        s2.292 2.434 3 5.667c.707 3.232-.334 5-.334 5
                        s2.202-1.544 2.334-3.334c0 0 2.578 5.685-1.334 8.667
                        M21 36.5c-.254-.624-.89-8.275 7-14M48 52s4.051-2.844 4-10"
                        style={{ fill: "currentColor", color: "#ffcc5c" , stroke: "currentColor", strokeWidth: "2px" }}
                    />
                    </svg>
                ),
                text: 'Khuyến mãi hot',
                color: 'bg-red-200 text-red-800'
            });

        }

        if (product.isVipOnly && customer?.membershipLevel === 'VIP') {
            labels.push({ 
                icon: (
                    <svg xmlns="http://www.w3.org/2000/svg" 
                        className="w-6 h-6" 
                        viewBox="0 0 128 128" 
                        fill="currentColor">
                    <rect x="25.148" y="87.83" width="77.705" height="10.553" rx="4.872" fill="#f89068"/>
                    <path d="M100.551 47.49a7.624 7.624 0 0 0-5.986 12.355l-16.534 7.6-11.48-22.586a7.631 7.631 0 1 0-5.1 0L49.969 67.446l-16.534-7.6a7.732 7.732 0 1 0-5.04 2.842l4.251 25.142h62.708l4.251-25.143a7.628 7.628 0 1 0 .946-15.2z" fill="#ffc26f"/>
                    <path d="M64 96.633a1.75 1.75 0 0 1 0 3.5h-1.667a1.75 1.75 0 0 1 0-3.5zm37.075-32.146-3.651 21.594h.556a6.63 6.63 0 0 1 6.62 6.619v.808a6.63 6.63 0 0 1-6.623 6.622H73a1.75 1.75 0 0 1 0-3.5h24.98a3.126 3.126 0 0 0 3.123-3.122V92.7a3.126 3.126 0 0 0-3.123-3.122H30.02A3.126 3.126 0 0 0 26.9 92.7v.808a3.126 3.126 0 0 0 3.123 3.122H52.5a1.75 1.75 0 0 1 0 3.5H30.02a6.63 6.63 0 0 1-6.62-6.619V92.7a6.63 6.63 0 0 1 6.623-6.622h.556l-3.654-21.591a9.381 9.381 0 1 1 9.9-9.366 9.288 9.288 0 0 1-.874 3.956l13.216 6.075 9.91-19.5a9.381 9.381 0 1 1 9.836 0l9.91 19.5 13.216-6.075a9.288 9.288 0 0 1-.874-3.956 9.381 9.381 0 1 1 9.905 9.366zM100.551 61a5.881 5.881 0 1 0-5.881-5.881 5.818 5.818 0 0 0 1.268 3.639 1.751 1.751 0 0 1-.643 2.675l-16.534 7.6a1.749 1.749 0 0 1-2.291-.8L64.99 45.652a1.752 1.752 0 0 1 .975-2.442 5.881 5.881 0 1 0-3.93 0 1.752 1.752 0 0 1 .975 2.442L51.53 68.238a1.749 1.749 0 0 1-2.291.8l-16.534-7.6a1.75 1.75 0 0 1-.642-2.675 5.823 5.823 0 0 0 1.267-3.639A5.881 5.881 0 1 0 27.449 61a6.121 6.121 0 0 0 .732-.051 1.755 1.755 0 0 1 1.94 1.445l4 23.685h59.75l4-23.685a1.754 1.754 0 0 1 1.94-1.445 6.121 6.121 0 0 0 .74.051z" fill="#13134c"/>
                    </svg>
                ),
                text: 'Ưu đãi VIP',
                color: 'bg-purple-100 text-purple-800' 
            });
        }

        if (product.discount) {
        const discountValue = parseFloat(product.discount.replace('%', ''));
            if (discountValue >= 20) {
                labels.push({ 
                icon: (
                    <svg
                    xmlns="http://www.w3.org/2000/svg"
                    viewBox="0 0 2048 2048"
                        className="w-4 h-4"
                    >
                        <g id="Layer_1">
                            <path
                                style={{ fill: "currentColor", color: "#e34234" , stroke: "#000000", strokeWidth: "2px" }}
                            d="M256 1531l469 25c3 0 6 1 9 2 18 2 42 8 68 14l127 22c103-8 168 2 222-1 46-3 80-17 162-35 1 0 2 0 2-1 4-1 8-2 12-1l463-25-412-227c-1-1-3-2-4-2-18-13-22-37-9-55l218-305-381 104c-1 0-2 1-3 1-21 6-43-6-49-27l-129-452-129 452c-5 17-21 30-40 29l-280-17 109 220c10 19 3 43-16 53l-412 226zm545-70 116 6h5c4 1 7 1 11 2s9 2 13 3l43 7c22-2 39-1 54-1 9 0 17 1 24 0 9-1 17-3 28-6 8-2 17-5 27-7 1 0 3-1 4-1h4l113-6-102-56h-1 1l-13-7 2-4c-2-3-3-6-4-10-1-7 0-15 5-22l54-76-95 26-2 1h1c-7 2-15 1-21-3s-12-10-14-17l-32-112-32 112-4 14-4-1-3 3c-5 4-12 6-18 5l-75-5 28 56c4 7 4 15 2 21-2 7-7 13-14 17l-102 56zm115 36zm0 0-168-9-52-3 45-25 147-81-39-79-11-23 25 2 100 6 4-14 42-148 14-50 14 50 46 161 136-37 40-11-24 34-78 109 12 7 135 74 45 25-52 3-166 9h-2c-12 3-20 5-26 6-13 3-22 6-34 7h-27c-14 0-31-1-53 1h-4l-45-8c-5-1-9-2-13-3s-7-2-10-2h-2zm215 0zm13-92 2 1-2-1zm15-26zm0 0zm-75-94zm8 28h-1 1zm-203 66zM1205 1239"
                            />
                        </g>
                    </svg>      
                ),
                    text: 'Giảm sốc',
                    color: 'bg-orange-200 text-orange-800' 
                });
            }
        }

        return labels; // Chỉ hiển thị tối đa 2 nhãn
    };

    const getFilteredProducts = () => {
        const allProducts = [...mockProducts.recommended, ...mockProducts.similar, ...mockProducts.promotions, ...mockProducts.vipVouchers, ...mockProducts.others];
        
        let filteredProducts = allProducts;

        // Lọc theo từ khóa tìm kiếm nếu có
        if (searchQuery) {
            filteredProducts = allProducts.filter(product => 
                product.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                product.category.toLowerCase().includes(searchQuery.toLowerCase()) ||
                product.description.toLowerCase().includes(searchQuery.toLowerCase())
            );
        }

        // Tính điểm ưu tiên cho từng sản phẩm và sắp xếp
        const productsWithPriority = filteredProducts.map(product => ({
            ...product,
            priority: calculateProductPriority(product)
        }));

        // Sắp xếp theo độ ưu tiên giảm dần
        return productsWithPriority.sort((a, b) => b.priority - a.priority);
    };

    // Format giá tiền VNĐ
    const formatPrice = (price) => {
        return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND'
        }).format(price);
    };

    // Xử lý click vào sản phẩm
    const handleProductClick = (product) => {
        setSelectedProduct(product);
    };

    // Đóng modal chi tiết sản phẩm
    const closeProductDetail = () => {
        setSelectedProduct(null);
    };

    if (!isOpen) return null;

    // Show purchase history
    if (showHistory) {
        return (
            <PurchaseHistory
                customer={customer}
                isOpen={showHistory}
                onClose={() => setShowHistory(false)}
            />
        );
    }

    // Show payment interface
    if (showPayment) {
        return (
            <PaymentInterface
                selectedProducts={cart.map(item => ({
                    ...item,
                    price: item.salePrice || item.originalPrice
                }))}
                customerInfo={customer}
                onBack={() => setShowPayment(false)}
                onPaymentComplete={handlePaymentComplete}
            />
        );
    }

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
            {/* Main Content */}
            <div className="w-full h-full bg-white animate-slide-in-right flex flex-col hide-scrollbar-x">
            {/* Header */}
            <div className="bg-gradient-to-br from-[#03486c] to-[#00324D] text-white p-6 shadow-lg flex-shrink-0">
                <div className="flex items-center justify-between">
                <div className="flex items-center space-x-4">
                    <div className="w-12 h-12 bg-white bg-opacity-20 rounded-full flex items-center justify-center">
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
                    </svg>
                    </div>
                    <div>
                    <h1 className="text-2xl font-bold">Gợi ý sản phẩm</h1>
                    <p className="text-blue-100">
                        Xin chào {customer?.firstName} {customer?.lastName}! 
                        {customer?.isLoyal && <span className="ml-2 px-2 py-1 bg-yellow-400 text-yellow-900 rounded-full text-xs font-semibold">VIP</span>}
                    </p>
                    </div>
                </div>
                
                <div className="flex items-center space-x-4">
                    {/* Purchase History Button */}
                    <button
                        onClick={() => setShowHistory(true)}
                        className="px-4 py-2 bg-amber-600 hover:bg-amber-700 text-white rounded-lg font-medium transition-colors text-sm flex items-center space-x-2"
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
                        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v0a2 2 0 002 2h2m0 0h2a2 2 0 012 2v0a2 2 0 01-2 2H9m0-4h2m-2 4h2m2-4V9a2 2 0 00-2-2M7 5V3a2 2 0 012-2h6a2 2 0 012 2v2M7 5h10" />
                        </svg>
                        <span>Lịch sử</span>
                    </button>

                    {/* Demo Payment Button */}
                    <button
                        onClick={() => {
                            setCart([
                                {
                                    id: 1,
                                    name: 'iPhone 15 Pro Max',
                                    image: 'https://cdn2.fptshop.com.vn/unsafe/768x0/filters:format(webp):quality(75)/2023_9_14_638302874057113482_so-sanh-iphone-15-pro-va-iphone-15-pro-max-12.jpg',
                                    originalPrice: 34990000,
                                    salePrice: 31990000,
                                    quantity: 1
                                },
                                {
                                    id: 3,
                                    name: 'MacBook Pro M3',
                                    image: '/api/placeholder/200/200',
                                    originalPrice: 52990000,
                                    salePrice: 49990000,
                                    quantity: 1
                                }
                            ]);
                            setShowPayment(true);
                        }}
                        className="px-4 py-2 bg-amber-600 hover:bg-amber-700 text-white rounded-lg font-medium transition-colors text-sm flex items-center space-x-2"
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
                        Demo Thanh Toán
                    </button>

                    {/* Cart Icon */}
                    <button
                        onClick={() => setShowPayment(true)}
                        className="relative p-2 hover:bg-white hover:bg-opacity-20 rounded-full transition-colors"
                        disabled={cart.length === 0}
                        title={cart.length === 0 ? "Giỏ hàng trống" : `${cart.reduce((sum, item) => sum + item.quantity, 0)} sản phẩm trong giỏ`}
                    >
                        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 3h2l.4 2M7 13h10l4-8H5.4m0 0L7 13m0 0l-2.5 5L17 18" />
                        </svg>
                        <span className={`absolute -top-1 -right-1 text-white text-xs rounded-full w-6 h-6 flex items-center justify-center ${
                            cart.length > 0 ? 'bg-red-500' : 'bg-gray-400'
                        }`}>
                            {cart.reduce((sum, item) => sum + item.quantity, 0)}
                        </span>
                    </button>

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

                {/* Search Bar */}
                <div className="mt-6 relative">
                <div className="relative">
                    <input
                    type="text"
                    placeholder="Tìm kiếm sản phẩm..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="w-full pl-12 pr-4 py-3 bg-white bg-opacity-20 border border-white border-opacity-30 rounded-lg text-white placeholder-blue-100 focus:outline-none focus:ring-2 focus:ring-white focus:bg-opacity-30 transition-all"
                    />
                    <svg className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-blue-100" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                </div>
                </div>
            </div>

            {/* Products Grid */}
            <div className="flex-1 flex flex-col bg-gray-50 min-h-0">
                <div className="p-6 pb-4 flex-shrink-0">
                    <div className="flex items-center justify-between">
                        <h2 className="text-lg font-semibold text-gray-800">
                        {searchQuery 
                            ? `Kết quả tìm kiếm cho "${searchQuery}" (${getFilteredProducts().length} sản phẩm)`
                            : `Đề xuất sản phẩm (${getFilteredProducts().length} sản phẩm)`
                        }
                        </h2>
                        
                        {/* Priority Info */}
                        {/* <div className="flex items-center space-x-2 text-xs text-gray-500">
                            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            <span>Được sắp xếp theo độ ưu tiên</span>
                        </div> */}
                    </div>
                    
                    {/* Priority Legend */}
                    {/* <div className="mt-3 flex flex-wrap gap-2 text-xs">
                        <div className="flex items-center space-x-1">
                            <span className="w-2 h-2 bg-blue-500 rounded-full"></span>
                            <span className="text-gray-600">Kết quả tìm kiếm</span>
                        </div>
                        <div className="flex items-center space-x-1">
                            <span className="w-2 h-2 bg-yellow-500 rounded-full"></span>
                            <span className="text-gray-600">Sản phẩm yêu thích</span>
                        </div>
                        <div className="flex items-center space-x-1">
                            <span className="w-2 h-2 bg-red-500 rounded-full"></span>
                            <span className="text-gray-600">Khuyến mãi hot</span>
                        </div>
                        <div className="flex items-center space-x-1">
                            <span className="w-2 h-2 bg-purple-500 rounded-full"></span>
                            <span className="text-gray-600">Ưu đãi VIP</span>
                        </div>
                    </div> */}
                </div>

                {/* Scrollable Products Container */}
                <div className="flex-1 px-6 pb-6 overflow-y-auto custom-scrollbar">
                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5 gap-4 pb-4">
                    {getFilteredProducts().map((product, index) => (
                    <div
                    key={product.id}
                    className="product-card bg-white rounded-xl shadow-lg overflow-hidden cursor-pointer animate-fade-in"
                    style={{ animationDelay: `${index * 0.1}s` }}
                    onClick={() => handleProductClick(product)}
                    >
                    {/* Product Image */}
                    <div className="relative">
                        <img
                        src={product.image}
                        alt={product.name}
                        className="w-full h-48 object-cover"
                        />
                        
                        {/* Badges */}
                        <div className="absolute top-0 left-0 flex flex-col space-y-1 ">
                            {/* Discount Badge */}
                            {product.discount && (
                                <div className="flex items-center justify-center">
                                    <svg
                                        viewBox="0 0 48 48"
                                        width="40"
                                        height="40"
                                    >
                                        <g>
                                            <path
                                                d="M45.93 26.39a3.2 3.2 0 0 0-.76 3.79 3.21 3.21 0 0 1-1.83 4.42 3.19 3.19 0 0 0-2.15 3v.39a3.21 3.21 0 0 1-3.4 3.2 3.19 3.19 0 0 0-3.21 2.14 3.2 3.2 0 0 1-4.42 1.83 3.2 3.2 0 0 0-3.79.76 3.2 3.2 0 0 1-4.78 0 3.2 3.2 0 0 0-3.79-.76 3.2 3.2 0 0 1-4.42-1.83 3.18 3.18 0 0 0-3.21-2.14 3.2 3.2 0 0 1-3.37-3.38 3.19 3.19 0 0 0-2.14-3.21 3.2 3.2 0 0 1-1.83-4.42 3.2 3.2 0 0 0-.76-3.79 3.2 3.2 0 0 1 0-4.78 3.2 3.2 0 0 0 .76-3.79 3.2 3.2 0 0 1 1.83-4.42 3.18 3.18 0 0 0 2.14-3.21 3.2 3.2 0 0 1 3.3-3.39h.29a3.19 3.19 0 0 0 3-2.15 3.21 3.21 0 0 1 4.42-1.83 3.2 3.2 0 0 0 3.79-.76 3.2 3.2 0 0 1 4.78 0 3.21 3.21 0 0 0 3.79.76 3.2 3.2 0 0 1 4.43 1.84 3.19 3.19 0 0 0 3 2.15h.39a3.21 3.21 0 0 1 3.2 3.4 3.19 3.19 0 0 0 2.14 3.21 3.19 3.19 0 0 1 2.15 3c0 1.29-.64 1.52-.64 2.79C44.85 21.68 47 21.53 47 24a3.19 3.19 0 0 1-1.07 2.39z"
                                                fill="#db5669"
                                            />
                                            <path
                                                d="M45.93 26.39a3.2 3.2 0 0 0-.76 3.79 3.12 3.12 0 0 1 .18 2.3c0 .1-.76 1.28-.82 1.38a3.08 3.08 0 0 1-1.19.74 3.19 3.19 0 0 0-2.15 3v.29C27.32 51.18 4 41.37 4 22a21.9 21.9 0 0 1 6.1-15.2 3.2 3.2 0 0 0 3.3-2.14c.38-1.13 1-1.39 2.11-2a2.89 2.89 0 0 1 .91-.14c1.29 0 1.52.64 2.79.64C21.68 3.15 21.53 1 24 1a3.19 3.19 0 0 1 2.39 1.07 3.21 3.21 0 0 0 3.79.76 3.2 3.2 0 0 1 4.42 1.83 3.18 3.18 0 0 0 3.21 2.14 3.2 3.2 0 0 1 3.39 3.39 3.19 3.19 0 0 0 2.14 3.21 3.2 3.2 0 0 1 1.83 4.42 3.2 3.2 0 0 0 .76 3.79 3.2 3.2 0 0 1 0 4.78z"
                                                fill="#f26674"
                                            />
                                            <path
                                                d="M41 24a17 17 0 0 1-17 17C8.17 41 1 21.21 13 11c10.87-9.18 28-1.64 28 13z"
                                                fill="#c4455e"
                                            />
                                            <path
                                                d="M41 24a16.91 16.91 0 0 1-4 11 16.91 16.91 0 0 1-11 4C11.38 39 3.81 21.88 13 11c10.87-9.18 28-1.64 28 13z"
                                                fill="#db5669"
                                            />
                                            <text
                                                x="24"
                                                y="25"
                                                textAnchor="middle"
                                                dominantBaseline="middle"
                                                fontSize="10"
                                                fontFamily="Arial, sans-serif"
                                                fontWeight="bold"
                                                fill="#ffffff"
                                                stroke="#ffde76"
                                                strokeWidth="0.3"
                                            >
                                                -{product.discount}
                                            </text>
                                        </g>
                                    </svg>
                                </div>
                            )}

                            {/* VIP Badge */}
                            {product.isVipOnly && (
                                <div className="flex items-center justify-center">
                                    <svg 
                                        width="40" 
                                        height="40" 
                                        viewBox="0 0 115 115" 
                                        className="drop-shadow-sm"
                                    >
                                        <style>{`
                                            .st0{fill:#ffeead}
                                            .st3{fill:#ff6f69}
                                            .st7{fill:#71a58a}
                                            .st8{fill:#ffcc5c}
                                            .st11{fill:#e05858}
                                        `}</style>
                                        <g id="premium_product_1_">
                                            <path className="st3" d="M114.343 59.086a2.243 2.243 0 0 0 0-3.172l-7.01-7.01a2.244 2.244 0 0 1-.485-2.448l3.81-9.153a2.242 2.242 0 0 0-1.209-2.932l-9.253-3.851a2.243 2.243 0 0 1-1.381-2.07V18.427a2.243 2.243 0 0 0-2.243-2.243h-9.914a2.242 2.242 0 0 1-2.073-1.388L80.807 5.63a2.243 2.243 0 0 0-2.928-1.219L68.613 8.23c-.837.345-1.8.153-2.441-.488L59.085.655a2.243 2.243 0 0 0-3.172 0l-7.01 7.01a2.244 2.244 0 0 1-2.448.485l-9.153-3.81a2.242 2.242 0 0 0-2.932 1.209l-3.851 9.253a2.243 2.243 0 0 1-2.07 1.381H18.427a2.243 2.243 0 0 0-2.243 2.243v9.914c0 .908-.548 1.727-1.388 2.073L5.63 34.191a2.243 2.243 0 0 0-1.219 2.928l3.819 9.266c.345.837.153 1.8-.488 2.44L.655 55.912a2.243 2.243 0 0 0 0 3.172l7.01 7.01c.642.642.834 1.609.485 2.448l-3.81 9.153a2.242 2.242 0 0 0 1.209 2.932l9.253 3.851a2.243 2.243 0 0 1 1.381 2.071v10.022a2.243 2.243 0 0 0 2.243 2.243h9.914c.908 0 1.727.548 2.073 1.388l3.778 9.166a2.243 2.243 0 0 0 2.928 1.219l9.266-3.819a2.243 2.243 0 0 1 2.441.488l7.087 7.087a2.243 2.243 0 0 0 3.172 0l7.01-7.01a2.244 2.244 0 0 1 2.448-.485l9.153 3.81a2.242 2.242 0 0 0 2.932-1.209l3.851-9.253a2.243 2.243 0 0 1 2.071-1.381h10.022a2.243 2.243 0 0 0 2.243-2.243v-9.914c0-.909.548-1.727 1.388-2.073l9.166-3.778a2.243 2.243 0 0 0 1.219-2.928l-3.819-9.266a2.243 2.243 0 0 1 .488-2.441l7.086-7.086z"/>
                                            <circle className="st7" cx="57.5" cy="57.5" r="45.079"/>
                                            <path d="M88.551 52.503a3.452 3.452 0 0 0-3.452 3.452c0 .661.195 1.272.517 1.797-.334.421-.78.893-1.399 1.343-.714.519-1.638 1.003-2.824 1.325a11.93 11.93 0 0 1-2.735.393c-2.075.068-4.674-.298-7.915-1.399-5.901-2.004-9.521-5.832-11.714-9.408a25.436 25.436 0 0 1-2.902-6.813c.979-.869 1.608-2.122 1.608-3.534a4.742 4.742 0 1 0-9.486 0c0 1.426.643 2.691 1.64 3.56a24.082 24.082 0 0 1-.57 1.871 25.714 25.714 0 0 1-1.569 3.59c-2.081 3.916-5.832 8.479-12.472 10.734-3.241 1.1-5.84 1.467-7.915 1.399-.046-.002-.083-.01-.129-.012a11.816 11.816 0 0 1-2.342-.327 9.838 9.838 0 0 1-1.365-.426 7.684 7.684 0 0 1-2.014-1.19 6.972 6.972 0 0 1-1.416-1.524 3.452 3.452 0 1 0-3.192 2.144l.023-.002 3.796 9.233h-.068l.809 1.834h.013l3.464 8.425a3.048 3.048 0 0 0-2.515 2.988v1.269a3.051 3.051 0 0 0 3.042 3.042h55.083a3.051 3.051 0 0 0 3.042-3.042v-1.269a3.047 3.047 0 0 0-2.515-2.988l3.464-8.425h.013l.809-1.834h-.068l3.849-9.362a3.446 3.446 0 0 0 2.857-3.392 3.451 3.451 0 0 0-3.452-3.452z" fill="#639376"/>
                                            <path className="st0" d="M57.5 11.025c-25.627 0-46.476 20.849-46.476 46.475 0 25.627 20.849 46.476 46.476 46.476s46.476-20.849 46.476-46.476c0-25.626-20.849-46.475-46.476-46.475zm0 90.158c-24.088 0-43.683-19.596-43.683-43.683 0-24.086 19.596-43.682 43.683-43.682 24.088 0 43.683 19.596 43.683 43.682 0 24.087-19.596 43.683-43.683 43.683z"/>
                                            <circle cx="57.5" cy="57.5" r="32.127" fill="#96ceb4"/>
                                            <path className="st7" d="M89.25 52.574a3.452 3.452 0 0 0-4.151 3.381c0 .661.195 1.272.517 1.797-.334.421-.78.893-1.399 1.343-.714.519-1.638 1.003-2.824 1.326a11.93 11.93 0 0 1-2.735.393c-2.075.069-4.674-.298-7.915-1.399-5.901-2.004-9.521-5.832-11.714-9.408a25.48 25.48 0 0 1-2.903-6.813c.979-.869 1.608-2.122 1.608-3.534a4.743 4.743 0 1 0-9.486 0c0 1.427.643 2.691 1.64 3.56a24.082 24.082 0 0 1-.57 1.871 25.714 25.714 0 0 1-1.569 3.59c-2.081 3.916-5.833 8.479-12.472 10.733-3.241 1.101-5.84 1.467-7.915 1.399-.046-.002-.083-.009-.129-.011a12.09 12.09 0 0 1-1.71-.204c1.079 11.275 7.984 20.843 17.671 25.67h28.608a32.244 32.244 0 0 0 9.533-7.23c-.086-.023-.168-.054-.257-.069l3.464-8.425h.013l.809-1.834h-.068l3.849-9.362c.149-.026.291-.071.433-.116a32.139 32.139 0 0 0-.328-6.658z"/>
                                            <path className="st8" d="M91.169 53.388s-2.691 7.338-15.654 2.935c-11.803-4.008-14.48-15.312-14.866-17.305h-5.735c-.385 1.993-3.063 13.296-14.866 17.305-12.963 4.403-15.654-2.935-15.654-2.935l-3.424 1.223 9.05 22.013h55.522l9.05-22.013-3.423-1.223z"/>
                                            <path className="st0" d="M91.169 53.388s-2.691 7.338-15.654 2.935c-11.803-4.008-14.48-15.312-14.866-17.305h-5.735c-.385 1.993-3.063 13.296-14.866 17.305-12.963 4.403-15.654-2.935-15.654-2.935l-3.424 1.223.6 1.458 2.825-1.009s2.69 7.338 15.654 2.935C51.852 53.986 54.53 42.683 54.915 40.69h5.735c.385 1.993 3.063 13.296 14.866 17.305C88.479 62.397 91.17 55.06 91.17 55.06l2.825 1.009.599-1.458-3.425-1.223zM27.608 70.754l.754 1.834h58.84l.755-1.834zM25.429 65.617l.808 1.835h63.09l.809-1.835z"/>
                                            <path className="st11" d="M85.324 75.823H30.241a3.051 3.051 0 0 0-3.042 3.042v1.268a3.051 3.051 0 0 0 3.042 3.042h55.083a3.051 3.051 0 0 0 3.042-3.042v-1.268a3.051 3.051 0 0 0-3.042-3.042z"/>
                                            <circle className="st8" cx="21.678" cy="52.935" r="3.452"/>
                                            <circle className="st8" cx="93.322" cy="52.864" r="3.452"/>
                                            <circle className="st8" cx="57.763" cy="36.568" r="4.743"/>
                                            <circle className="st0" cx="94.355" cy="51.797" r=".917"/>
                                            <circle className="st0" cx="59.178" cy="34.571" r="1.039"/>
                                            <circle className="st0" cx="22.506" cy="52.174" r=".917"/>
                                            <ellipse className="st11" cx="57.535" cy="61.961" rx="5.901" ry="6.489"/>
                                            <ellipse className="st3" cx="58.846" cy="59.015" rx="2.623" ry="2.204"/>
                                        </g>
                                    </svg>
                                </div>
                            )}   

                            {/* Promotion Badge */}
                            {product.isPromotion && (
                                <div className="flex items-center justify-center">
                                    <svg 
                                        width="40" 
                                        height="40" 
                                        viewBox="0 0 48 48" 
                                        className="drop-shadow-sm"
                                    >
                                        <style>{`
                                            .cls-1{fill:#db5669}
                                            .cls-4{fill:#ffde76}
                                            .cls-5{fill:#edebf2}
                                        `}</style>
                                        <g id="sale_splash_tag_" data-name="sale (splash tag)">
                                            <path className="cls-1" d="M45.93 26.39a3.2 3.2 0 0 0-.76 3.79 3.21 3.21 0 0 1-1.83 4.42 3.19 3.19 0 0 0-2.15 3v.39a3.21 3.21 0 0 1-3.4 3.2 3.19 3.19 0 0 0-3.21 2.14 3.2 3.2 0 0 1-4.42 1.83 3.2 3.2 0 0 0-3.79.76 3.2 3.2 0 0 1-4.78 0 3.2 3.2 0 0 0-3.79-.76 3.2 3.2 0 0 1-4.42-1.83 3.18 3.18 0 0 0-3.21-2.14 3.2 3.2 0 0 1-3.37-3.38 3.19 3.19 0 0 0-2.14-3.21 3.2 3.2 0 0 1-1.83-4.42 3.2 3.2 0 0 0-.76-3.79 3.2 3.2 0 0 1 0-4.78 3.2 3.2 0 0 0 .76-3.79 3.2 3.2 0 0 1 1.83-4.42 3.18 3.18 0 0 0 2.14-3.21 3.2 3.2 0 0 1 3.3-3.39h.29a3.19 3.19 0 0 0 3-2.15 3.21 3.21 0 0 1 4.42-1.83 3.2 3.2 0 0 0 3.79-.76 3.2 3.2 0 0 1 4.78 0 3.21 3.21 0 0 0 3.79.76 3.2 3.2 0 0 1 4.43 1.84 3.19 3.19 0 0 0 3 2.15h.39a3.21 3.21 0 0 1 3.2 3.4 3.19 3.19 0 0 0 2.14 3.21 3.19 3.19 0 0 1 2.15 3c0 1.29-.64 1.52-.64 2.79C44.85 21.68 47 21.53 47 24a3.19 3.19 0 0 1-1.07 2.39z"/>
                                            <path d="M45.93 26.39a3.2 3.2 0 0 0-.76 3.79 3.12 3.12 0 0 1 .18 2.3c0 .1-.76 1.28-.82 1.38a3.08 3.08 0 0 1-1.19.74 3.19 3.19 0 0 0-2.15 3v.29C27.32 51.18 4 41.37 4 22a21.9 21.9 0 0 1 6.1-15.2 3.2 3.2 0 0 0 3.3-2.14c.38-1.13 1-1.39 2.11-2a2.89 2.89 0 0 1 .91-.14c1.29 0 1.52.64 2.79.64C21.68 3.15 21.53 1 24 1a3.19 3.19 0 0 1 2.39 1.07 3.21 3.21 0 0 0 3.79.76 3.2 3.2 0 0 1 4.42 1.83 3.18 3.18 0 0 0 3.21 2.14 3.2 3.2 0 0 1 3.39 3.39 3.19 3.19 0 0 0 2.14 3.21 3.2 3.2 0 0 1 1.83 4.42 3.2 3.2 0 0 0 .76 3.79 3.2 3.2 0 0 1 0 4.78z" fill="#f26674"/>
                                            <path d="M41 24a17 17 0 0 1-17 17C8.17 41 1 21.21 13 11c10.87-9.18 28-1.64 28 13z" fill="#c4455e"/>
                                            <path className="cls-1" d="M41 24a16.91 16.91 0 0 1-4 11 16.91 16.91 0 0 1-11 4C11.38 39 3.81 21.88 13 11c10.87-9.18 28-1.64 28 13z"/>
                                            <path className="cls-4" d="M31.77 16.23a11 11 0 0 0-15.54 0 1 1 0 0 1-1.42-1.42 13 13 0 0 1 18.38 0 1 1 0 0 1-1.42 1.42zM14.81 33.19a1 1 0 0 1 1.42-1.42 11 11 0 0 0 15.54 0 1 1 0 0 1 1.42 1.42 13 13 0 0 1-18.38 0z"/>
                                            <path className="cls-5" d="M13 21h2a1 1 0 0 0 0-2h-2a3 3 0 0 0 0 6 1 1 0 0 1 0 2h-2a1 1 0 0 0 0 2h2a3 3 0 0 0 0-6 1 1 0 0 1 0-2zM21.94 19.65a1 1 0 0 0-1.88 0l-3 8a1 1 0 0 0 1.88.7l.5-1.35h3.12l.5 1.35a1 1 0 0 0 1.88-.7zM20.19 25l.81-2.15.81 2.15zM30 27h-2v-7a1 1 0 0 0-2 0v8a1 1 0 0 0 1 1h3a1 1 0 0 0 0-2zM37 25a1 1 0 0 0 0-2h-3v-2h3a1 1 0 0 0 0-2h-4a1 1 0 0 0-1 1v8a1 1 0 0 0 1 1h4a1 1 0 0 0 0-2h-3v-2z"/>
                                        </g>
                                    </svg>
                                </div>
                            )}                        
                        </div>
                        {/* Stock Status */}
                        <div className="absolute top-2 right-2">
                        <span className={`px-2 py-1 rounded-md text-xs font-semibold ${
                            product.stock > 10 ? 'bg-[#98FB98] text-[#0B6623]' :
                            product.stock > 5 ? 'bg-[#fbf978] text-[#7d6a00]' :
                            'bg-[#fb9797] text-[#6B0000]'
                        }`}>
                            {product.stock > 10 ? 'Còn nhiều' : product.stock > 5 ? `Còn ${product.stock}` : 'Sắp hết'}
                        </span>
                        </div>
                    </div>

                    {/* Product Info */}
                    <div className="p-4">
                        <div className="flex items-start justify-between mb-2">
                        <h3 className="font-semibold text-gray-800 text-sm line-clamp-2 flex-1">
                            {product.name}
                        </h3>
                        {product.rating && (
                            <div className="flex items-center ml-2">
                            <svg className="w-4 h-4 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                            </svg>
                            <span className="text-xs text-gray-600 ml-1">{product.rating}</span>
                            </div>
                        )}
                        </div>

                        {/* Priority Labels */}
                        {getPriorityLabel(product).length > 0 && (
                            <div className="flex flex-wrap gap-1 mb-2">
                                {getPriorityLabel(product).map((label, idx) => (
                                    <span 
                                        key={idx}
                                        className={`flex items-center space-x-1 px-2 py-1 rounded-full text-xs font-medium ${label.color}`}
      >
                                        {label.icon}
                                        {label.text}
                                    </span>
                                ))}
                            </div>
                        )}

                        <p className="text-xs text-gray-500 mb-3 line-clamp-2">
                        {product.description}
                        </p>

                        {/* Pricing */}
                        <div className="space-y-2">
                        {product.voucherPrice ? (
                            // VIP Voucher Pricing
                            <div>
                            <div className="flex items-center justify-between">
                                <span className="text-xs text-gray-500 line-through">
                                {formatPrice(product.originalPrice)}
                                </span>
                                <span className="text-xs text-purple-600 font-semibold">
                                {product.voucherDiscount}
                                </span>
                            </div>
                            <div className="text-lg font-bold text-purple-600">
                                {formatPrice(product.voucherPrice)}
                            </div>
                            </div>
                        ) : product.salePrice && product.salePrice !== product.originalPrice ? (
                            // Sale Pricing
                            <div>
                            <span className="text-xs text-gray-500 line-through">
                                {formatPrice(product.originalPrice)}
                            </span>
                            <div className="text-lg font-bold text-red-600">
                                {formatPrice(product.salePrice)}
                            </div>
                            </div>
                        ) : (
                            // Regular Pricing
                            <div className="text-lg font-bold text-gray-800">
                            {formatPrice(product.originalPrice)}
                            </div>
                        )}
                        </div>

                        {/* Location */}
                        <div className="flex items-center mt-3 text-xs text-gray-500">
                        <svg className="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                        </svg>
                        {product.location}
                        </div>
                    </div>
                    </div>
                ))}
                    </div>

                    {getFilteredProducts().length === 0 && (
                    <div className="text-center py-12">
                        <svg className="w-24 h-24 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                        </svg>
                        <h3 className="text-xl font-semibold text-gray-400">Không tìm thấy sản phẩm nào</h3>
                        <p className="text-gray-500 mt-2">Thử tìm kiếm với từ khóa khác</p>
                    </div>
                    )}
                </div>
            </div>

            {/* Product Detail Modal */}
            {selectedProduct && (
            <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-60 p-4">
                <div className="bg-white rounded-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto animate-fade-in">
                {/* Modal Header */}
                <div className="sticky top-0 bg-white border-b p-6 flex items-center justify-between">
                    <h2 className="text-xl font-bold text-gray-800">Chi tiết sản phẩm</h2>
                    <button
                    onClick={closeProductDetail}
                    className="p-2 hover:bg-gray-100 rounded-full transition-colors"
                    >
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                    </svg>
                    </button>
                </div>

                {/* Modal Content */}
                <div className="p-6">
                    <div className="grid md:grid-cols-2 gap-6">
                    {/* Product Image */}
                    <div>
                        <img
                        src={selectedProduct.image}
                        alt={selectedProduct.name}
                        className="w-full h-64 object-cover rounded-lg"
                        />
                    </div>

                    {/* Product Details */}
                    <div className="space-y-4">
                        <div>
                        <h3 className="text-2xl font-bold text-gray-800">{selectedProduct.name}</h3>
                        <p className="text-gray-600 text-sm mt-1">{selectedProduct.category}</p>
                        </div>

                        {/* Rating */}
                        {selectedProduct.rating && (
                        <div className="flex items-center">
                            <div className="flex items-center">
                            {[...Array(5)].map((_, i) => (
                                <svg
                                key={i}
                                className={`w-5 h-5 ${i < Math.floor(selectedProduct.rating) ? 'text-yellow-400' : 'text-gray-300'}`}
                                fill="currentColor"
                                viewBox="0 0 20 20"
                                >
                                <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                                </svg>
                            ))}
                            </div>
                            <span className="ml-2 text-gray-600">({selectedProduct.rating}/5)</span>
                        </div>
                        )}

                        {/* Price */}
                        <div className="space-y-2">
                        {selectedProduct.voucherPrice ? (
                            <div>
                            <div className="flex items-center justify-between">
                                <span className="text-gray-500 line-through">
                                {formatPrice(selectedProduct.originalPrice)}
                                </span>
                                <span className="text-purple-600 font-semibold">
                                {selectedProduct.voucherDiscount}
                                </span>
                            </div>
                            <div className="text-2xl font-bold text-purple-600">
                                {formatPrice(selectedProduct.voucherPrice)}
                            </div>
                            </div>
                        ) : selectedProduct.salePrice && selectedProduct.salePrice !== selectedProduct.originalPrice ? (
                            <div>
                            <span className="text-gray-500 line-through">
                                {formatPrice(selectedProduct.originalPrice)}
                            </span>
                            <div className="text-2xl font-bold text-red-600">
                                {formatPrice(selectedProduct.salePrice)}
                            </div>
                            <span className="text-green-600 font-semibold">
                                Tiết kiệm: {formatPrice(selectedProduct.originalPrice - selectedProduct.salePrice)}
                            </span>
                            </div>
                        ) : (
                            <div className="text-2xl font-bold text-gray-800">
                            {formatPrice(selectedProduct.originalPrice)}
                            </div>
                        )}
                        </div>

                        {/* Stock */}
                        <div className="flex items-center space-x-2">
                        <span className="text-gray-700 font-medium">Tình trạng:</span>
                        <span className={`px-3 py-1 rounded-full text-sm font-semibold ${
                            selectedProduct.stock > 10 ? 'bg-[#98FB98] text-[#0B6623]' :
                            selectedProduct.stock > 5 ? 'bg-[#FFFD9C] text-[#7D6A00]' :
                            'bg-[#FB9797] text-[#6B0000]'
                        }`}>
                            {selectedProduct.stock > 10 ? 'Còn hàng' : 
                            selectedProduct.stock > 5 ? `Còn ${selectedProduct.stock} sản phẩm` : 
                            'Sắp hết hàng'}
                        </span>
                        </div>

                        {/* Location */}
                        <div className="flex items-center space-x-2">
                        <svg className="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                        </svg>
                        <span className="text-gray-700">
                            <span className="font-medium">Vị trí:</span> {selectedProduct.location}
                        </span>
                        </div>
                    </div>
                    </div>

                    {/* Description */}
                    <div className="mt-6">
                    <h4 className="text-lg font-semibold text-gray-800 mb-3">Mô tả sản phẩm</h4>
                    <p className="text-gray-600 leading-relaxed">
                        {selectedProduct.description}
                    </p>
                    </div>

                    {/* Action Buttons */}
                    <div className="mt-6 flex space-x-4">
                    <button 
                        onClick={() => addToCart(selectedProduct)}
                        className="flex-1 bg-[#03486c] hover:bg-[#00324D] text-white py-3 px-6 rounded-lg font-semibold transition-colors"
                    >
                        Thêm vào giỏ hàng
                    </button>
                    <button 
                        onClick={() => buyNow(selectedProduct)}
                        className="flex-1 bg-[#03486c] hover:bg-[#00324D] text-white py-3 px-6 rounded-lg font-semibold transition-colors"
                    >
                        Mua ngay
                    </button>
                    </div>
                </div>
                </div>
            </div>
            )}
            </div>
        </div>
        </>
    );
};

export default ProductRecommendation;