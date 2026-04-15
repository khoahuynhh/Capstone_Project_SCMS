import React, { useEffect, useState } from 'react';
import { serverApi } from '../../../core/api/server_api';
import { 
  User, Mail, Phone, Award, Package, Venus, Mars,
  Calendar, ChevronRight, Clock, Receipt, Edit3, Save, X
} from 'lucide-react';
import '../css/CustomerProfile.css';

const CustomerProfile = ({ customer }) => {
    const [history, setHistory] = useState([]);
    const [loading, setLoading] = useState(true);
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [formData, setFormData] = useState({ ...customer });

    useEffect(() => {
        const fetchHistory = async () => {
            try {
                const res = await serverApi.purchaseHistory(customer.customer_id);
                setHistory(res);
            } catch (err) {
                console.error("Lỗi lấy lịch sử:", err);
            } finally {
                setLoading(false);
            }
        };
        if (customer?.customer_id) fetchHistory();
    }, [customer]);

    useEffect(() => {
        if (customer) {
            setFormData({ ...customer });
        }
    }, [customer]);

    const handleSave = async () => {
        try {
            await serverApi.updateProfile(formData);
            alert("Cập nhật thông tin thành công!");
        } catch (err) {
            console.error(err);
            alert("Lỗi khi lưu thông tin");
        }
    };

    if (!customer) return <div className="loader">Đang tải dữ liệu...</div>;

    return (
        <div className="profile-wrapper animate-slide-up">
            {/* TRÁI: THÔNG TIN CÁ NHÂN */}
            <div className="profile-sidebar">
                <div className="glass-card profile-main-card">
                    <button 
                        className="edit-toggle-btn"
                        onClick={() => setIsModalOpen(true)}
                    >
                        {/* <Edit3 size={50} /> */}
                        <span>Chỉnh sửa</span>
                    </button>

                    <div className="avatar-large">
                        {customer.first_name?.charAt(0)}
                    </div>

                    <h2 className="profile-name">{formData.last_name} {formData.first_name}</h2>

                    <div className={`tier-pill ${customer.tier?.toLowerCase() || 'silver'}`}>
                        <Award size={14} /> {customer.tier || 'Thành viên'}
                    </div>
                    
                    <div className="profile-divider" />
                    
                    <div className="contact-info">
                        <div className="info-row">
                            <Mail size={16} /> 
                                <span>{formData.email || 'N/A'}</span>
                        </div>
                        <div className="info-row">
                            <Phone size={16} /> 
                                <span>{formData.phone || 'N/A'}</span>
                        </div>
                        <div className="info-row">
                            <Calendar size={16} /> 
                            <span>Tuổi: {customer.age}</span>
                        </div>
                        <div className="info-row">
                            {customer.gender === 'Male' ? (
                                <Mars size={16} />
                            ) : (
                                <Venus size={16} />
                            )}
                            <span>Giới tính: {customer.gender === 'Male' ? 'Nam' : 'Nữ'}</span>
                        </div>
                    </div>
                </div>

                <div className="stat-grid-container">
                    <div className="glass-card stat-box">
                        <Package size={20} className="icon-blue" />
                        <label>Đơn hàng</label>
                        <p>{history.length}</p>
                    </div>
                    <div className="glass-card stat-box">
                        <Award size={20} className="icon-gold" />
                        <label>Tích lũy</label>
                        <p>1.2k</p>
                    </div>
                </div>
            </div>

            {/* PHẢI: LỊCH SỬ MUA HÀNG */}
            <div className="profile-main-content">
                <div className="glass-card history-card">
                    <div className="card-header">
                        <h3 className="card-title"><Receipt size={20} /> Lịch sử giao dịch</h3>
                        <span className="count-tag">{history.length} hóa đơn</span>
                    </div>

                    <div className="history-list">
                        {loading ? (
                            <div className="loading-placeholder">Đang tải dữ liệu...</div>
                        ) : history.length > 0 ? (
                            history.map((inv) => (
                                <div key={inv.transaction_id} className="history-item">
                                    <div className="item-icon-wrapper">
                                        <Clock size={18} />
                                    </div>
                                    <div className="item-details">
                                        <div className="detail-top">
                                            <span className="txn-id">#{inv.transaction_id}</span>
                                            <span className="txn-price">{inv.total_amount?.toLocaleString()}đ</span>
                                        </div>
                                        <div className="detail-bottom">
                                            <span>{new Date(inv.timestamp).toLocaleDateString('vi-VN')}</span>
                                            <span className="separator-dot">•</span>
                                            <span>{inv.items_count} sản phẩm</span>
                                        </div>
                                    </div>
                                    <ChevronRight size={18} className="action-arrow" />
                                </div>
                            ))
                        ) : (
                            <div className="empty-history">
                                <Package size={48} />
                                <p>Chưa có giao dịch nào.</p>
                            </div>
                        )}
                    </div>
                </div>
            </div>
            {isModalOpen && (
                <div className="modal-overlay">
                    <div className="modal-content glass-card animate-scale-in">
                        <div className="modal-header">
                            <h3>Chỉnh sửa thông tin</h3>
                            <button onClick={() => setIsModalOpen(false)}>
                                <X size={18} />
                            </button>
                        </div>

                        <div className="modal-body">
                            <input 
                                placeholder="Họ"
                                value={formData.last_name || ''}
                                onChange={e => setFormData({...formData, last_name: e.target.value})}
                            />
                            <input 
                                placeholder="Tên"
                                value={formData.first_name || ''}
                                onChange={e => setFormData({...formData, first_name: e.target.value})}
                            />
                            <input 
                                placeholder="Giới tính"
                                value={formData.gender || ''}
                                onChange={e => setFormData({...formData, gender: e.target.value})}
                            />
                            <input 
                                placeholder="Email"
                                value={formData.email || ''}
                                readOnly
                            />
                            <input 
                                placeholder="Số điện thoại"
                                value={formData.phone || ''}
                                onChange={e => setFormData({...formData, phone: e.target.value})}
                            />
                        </div>

                        <div className="modal-footer">
                            <button 
                                className="btn-cancel"
                                onClick={() => setIsModalOpen(false)}
                            >
                                Hủy
                            </button>

                            <button 
                                className="btn-save-profile"
                                onClick={async () => {
                                    await handleSave();
                                    setIsModalOpen(false);
                                }}
                            >
                                <Save size={16} /> Lưu thay đổi
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default CustomerProfile;
