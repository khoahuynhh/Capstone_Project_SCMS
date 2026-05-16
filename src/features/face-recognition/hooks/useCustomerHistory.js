import { useState, useEffect } from 'react';
import { serverApi } from '../../../core/api/server_api';

export const useCustomerHistory = (customerId, refreshKey = 0) => {
    const [historyInvoices, setHistoryInvoices] = useState([]);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState(null);

    useEffect(() => {
        if (!customerId) {
            setHistoryInvoices([]);
            setError(null);
            return undefined;
        }

        let cancelled = false;

        const fetchHistory = async () => {
            setIsLoading(true);
            setError(null);

            try {
                const data = await serverApi.purchaseHistory(customerId, { limitInvoices: 20 });
                if (!cancelled) {
                    setHistoryInvoices(Array.isArray(data) ? data : []);
                }
            } catch (err) {
                if (!cancelled) {
                    console.error('Loi tai lich su mua hang:', err);
                    setError(err);
                    setHistoryInvoices([]);
                }
            } finally {
                if (!cancelled) {
                    setIsLoading(false);
                }
            }
        };

        fetchHistory();

        return () => {
            cancelled = true;
        };
    }, [customerId, refreshKey]);

    return { historyInvoices, isLoading, error };
};
