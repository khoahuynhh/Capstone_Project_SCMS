import { useState, useEffect } from 'react';
import { serverApi } from '../../../core/api/server_api'; 

export const useProducts = () => {
    const [products, setProducts] = useState([]);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState(null);

    useEffect(() => {
        const fetchProducts = async () => {
            setIsLoading(true);
            try {
                // Sử dụng hàm products đã định nghĩa trong server_api.js
                // Bạn có thể truyền limit lớn hơn để lấy nhiều sản phẩm
                const data = await serverApi.products({ limit: 200 });
                
                // Giả sử API trả về mảng sản phẩm trực tiếp
                // Nếu API trả về dạng { data: [...] } thì sửa thành setProducts(data.data)
                setProducts(data || []); 
            } catch (err) {
                console.error("Lỗi tải sản phẩm:", err);
                setError(err);
            } finally {
                setIsLoading(false);
            }
        };

        fetchProducts();
    }, []);

    return { products, isLoading, error };
};