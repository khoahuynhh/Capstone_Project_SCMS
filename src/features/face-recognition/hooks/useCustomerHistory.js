import { useState, useEffect } from 'react';
import { serverApi } from '../../../core/api/server_api'; // Chỉnh lại đường dẫn import cho đúng

export const useCustomerHistory = (customerId) => {
    const [historyInvoices, setHistoryInvoices] = useState([]);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState(null);

    useEffect(() => {
        if (!customerId) {
            setHistoryInvoices([]);
            return;
        }

        const fetchHistory = async () => {
            setIsLoading(true);
            try {
                // Gọi API lấy lịch sử mua hàng của khách
                // server_api.js của bạn đã có hàm purchaseHistory(id, options)
                const data = await serverApi.purchaseHistory(customerId, { limitInvoices: 20 });
                
                // Lưu dữ liệu vào state
                setHistoryInvoices(data || []);
            } catch (err) {
                console.error("Lỗi tải lịch sử mua hàng:", err);
                setError(err);
            } finally {
                setIsLoading(false);
            }
        };

        fetchHistory();
    }, [customerId]);

    return { historyInvoices, isLoading, error };
};