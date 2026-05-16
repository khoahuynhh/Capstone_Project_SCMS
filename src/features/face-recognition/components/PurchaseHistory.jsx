import React, { useState, useEffect } from 'react';
import { serverApi } from '../../../core/api/server_api';
import '../css/ProductRecommendation.css';

const PurchaseHistory = ({ customerId, isOpen, onClose }) => {
    const [history, setHistory] = useState([]);
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        if (!isOpen) return undefined;

        if (!customerId) {
            setHistory([]);
            setLoading(false);
            return undefined;
        }

        let cancelled = false;

        const fetchHistory = async () => {
            setLoading(true);
            try {
                const data = await serverApi.purchaseHistory(customerId, { limitInvoices: 10 });
                if (!cancelled) {
                    setHistory(Array.isArray(data) ? data : []);
                }
            } catch (error) {
                if (!cancelled) {
                    console.error('Loi khi tai lich su mua hang:', error);
                    setHistory([]);
                }
            } finally {
                if (!cancelled) {
                    setLoading(false);
                }
            }
        };

        fetchHistory();

        return () => {
            cancelled = true;
        };
    }, [customerId, isOpen]);

    if (!isOpen) return null;

    const formatCurrency = (amount) => (
        new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(Number(amount) || 0)
    );

    const formatDate = (dateStr) => {
        if (!dateStr) return '--';
        const date = new Date(dateStr);
        return `${date.toLocaleDateString('vi-VN')} ${date.toLocaleTimeString('vi-VN', {
            hour: '2-digit',
            minute: '2-digit',
        })}`;
    };

    return (
        <div className="recoOverlay" style={{ zIndex: 1000 }}>
            <div className="recoShell animate-fade-in" style={{ maxWidth: '800px', height: '85vh' }}>
                <header className="recoHeader">
                    <div className="flex items-center gap-4">
                        <div className="ai-status-icon" style={{ background: 'var(--c-primary)', color: 'white' }}>
                            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                        <div>
                            <h2 className="m-0">Lịch sử mua hàng</h2>
                            <span className="recoDetailCategory">ID khách hàng: {customerId || '--'}</span>
                        </div>
                    </div>
                    <button onClick={onClose} className="recoCloseBtn" type="button">x</button>
                </header>

                <div className="recoBody custom-scrollbar" style={{ padding: '24px', overflowY: 'auto' }}>
                    {loading ? (
                        <div className="flex flex-col items-center justify-center h-full gap-4">
                            <div className="w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full animate-spin" />
                            <p className="text-gray-500">Đang tải dữ liệu từ hệ thống...</p>
                        </div>
                    ) : history.length === 0 ? (
                        <div className="text-center py-20">
                            <p className="text-gray-400">Khách hàng này chưa có giao dịch nào.</p>
                        </div>
                    ) : (
                        <div className="grid gap-6">
                            {history.map((invoice) => (
                                <div key={invoice.transaction_id} className="recoCard" style={{ padding: '0', overflow: 'hidden', border: 'var(--glass-border)' }}>
                                    <div className="p-4 flex justify-between items-center" style={{ background: 'var(--bg-subtle)', borderBottom: '1px solid rgba(0,0,0,0.05)' }}>
                                        <div>
                                            <span className="font-bold text-blue-600">#{invoice.transaction_id}</span>
                                            <div className="text-xs text-gray-500">{formatDate(invoice.timestamp)} • {invoice.branch_id || '--'}</div>
                                        </div>
                                        <div className="text-right">
                                            <div className="font-black text-lg" style={{ color: 'var(--c-primary)' }}>
                                                {formatCurrency(invoice.total_amount)}
                                            </div>
                                            <span className="recoBadge" style={{ background: '#dcfce7', color: '#166534', fontSize: '10px' }}>Hoàn thành</span>
                                        </div>
                                    </div>

                                    <div className="p-4 space-y-3">
                                        {(invoice.items || []).map((item, idx) => (
                                            <div key={`${invoice.transaction_id}-${item.product_id}-${idx}`} className="flex items-center gap-3">
                                                <img
                                                    src={item.image_url || '/api/placeholder/40/40'}
                                                    alt={item.name}
                                                    className="w-10 h-10 rounded-md object-cover border"
                                                />
                                                <div className="flex-1">
                                                    <div className="text-sm font-medium">{item.name}</div>
                                                    <div className="text-xs text-gray-500">
                                                        {item.qty} x {formatCurrency(item.unit_price)}
                                                    </div>
                                                </div>
                                                <div className="text-sm font-semibold">
                                                    {formatCurrency(item.line_total)}
                                                </div>
                                            </div>
                                        ))}
                                    </div>

                                    <div className="p-3 bg-gray-50 flex justify-end gap-2">
                                        <button className="recoTab" style={{ fontSize: '12px', padding: '6px 12px' }} type="button">
                                            In lại
                                        </button>
                                        <button className="recoTab active" style={{ fontSize: '12px', padding: '6px 12px' }} type="button">
                                            Chi tiết
                                        </button>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </div>

                <footer className="p-6 border-t flex justify-center">
                    <button onClick={onClose} className="recoDetailAddBtn" style={{ maxWidth: '200px' }} type="button">
                        Đóng cửa sổ
                    </button>
                </footer>
            </div>
        </div>
    );
};

export default PurchaseHistory;
