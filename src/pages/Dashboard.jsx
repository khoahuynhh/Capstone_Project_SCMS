import { startTransition, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Activity,
  BarChart3,
  BrainCircuit,
  Building2,
  CircleAlert,
  Cpu,
  ExternalLink,
  Gauge,
  LogOut,
  MonitorCog,
  Package,
  RefreshCcw,
  Search,
  ShieldAlert,
  ShieldCheck,
  Sparkles,
  TrendingUp,
  UserRound,
  Users,
  Wallet,
} from 'lucide-react';

import { useAuth } from '../core/auth/useAuth';
import { serverApi } from '../core/api/server_api';

import './Dashboard.css';

const REFRESH_INTERVAL_MS = 15000;
const HISTORY_LIMIT = 10;
const GRAFANA_EMBED_URL = import.meta.env.VITE_GRAFANA_EMBED_URL || '';
const ANALYTICS_DAY_OPTIONS = [7, 30, 90];
const MAX_VISIBLE = 30;

const currencyFormatter = new Intl.NumberFormat('vi-VN', {
  style: 'currency',
  currency: 'VND',
  maximumFractionDigits: 0,
});

const numberFormatter = new Intl.NumberFormat('vi-VN');

const formatCurrency = (value) => currencyFormatter.format(Number(value) || 0);
const formatNumber = (value) => numberFormatter.format(Number(value) || 0);

const formatPercent = (value) => `${Number(value || 0).toFixed(1)}%`;

const formatDateTime = (value) => {
  if (!value) return '--';
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) return '--';
  return parsed.toLocaleString('vi-VN');
};

const relativeTimeFromNow = (value) => {
  if (!value) return '--';
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) return '--';

  const diffMs = Date.now() - parsed.getTime();
  const diffMinutes = Math.max(0, Math.floor(diffMs / 60000));
  if (diffMinutes < 1) return 'vừa xong';
  if (diffMinutes < 60) return `${diffMinutes} phút trước`;
  const diffHours = Math.floor(diffMinutes / 60);
  if (diffHours < 24) return `${diffHours} giờ trước`;
  return `${Math.floor(diffHours / 24)} ngày trước`;
};

const buildSnapshot = ({ overview }) => ({
  createdAt: new Date().toISOString(),
  revenue: overview?.kpis?.revenue?.value ?? 0,
  transactions: overview?.kpis?.transactions?.value ?? 0,
  latestTransactionAt: new Date().toISOString(),
});

const formatPeriodLabel = (days) => `${days} ngày`;
const ASSOCIATION_JOB_STORAGE_KEY = 'dashboard.associationJobId';
const RECOMMENDATION_ALGORITHM_LABELS = {
  purchase_history_sort: 'Lịch sử mua',
  attribute_ai: 'AI khuôn mặt',
  association_rules: 'Luật kết hợp',
  seed_hybrid: 'Dữ liệu mẫu tổng hợp',
  unknown: 'Không xác định',
};

const normalizeSearchText = (value) => String(value ?? '')
  .normalize('NFD')
  .replace(/[\u0300-\u036f]/g, '')
  .toLowerCase();

const matchesSearch = (query, values) => {
  const normalizedQuery = normalizeSearchText(query).trim();
  if (!normalizedQuery) return true;
  return values.some((value) => normalizeSearchText(value).includes(normalizedQuery));
};

const getAssociationJobStatusLabel = (status) => {
  const labels = {
    idle: 'Chưa chạy',
    pending: 'Đang chờ',
    running: 'Đang chạy',
    success: 'Hoàn tất',
    failed: 'Thất bại',
  };
  return labels[status] || status || '--';
};

const getInventoryStatusLabel = (status) => {
  const labels = {
    out_of_stock: 'Hết hàng',
    low_stock: 'Sắp hết',
    in_stock: 'Còn hàng',
  };
  return labels[status] || status || '--';
};

function MetricCard({ icon, label, value, hint, tone = 'default' }) {
  const IconComponent = icon;

  return (
    <article className={`metric-card tone-${tone}`}>
      <div className="metric-card__icon">
        <IconComponent size={18} />
      </div>
      <div className="metric-card__body">
        <span className="metric-card__label">{label}</span>
        <strong className="metric-card__value">{value}</strong>
        <span className="metric-card__hint">{hint}</span>
      </div>
    </article>
  );
}

function StatusPill({ ok, label, neutral = false }) {
  const className = neutral ? 'status-pill neutral' : ok ? 'status-pill ok' : 'status-pill down';
  return <span className={className}>{label}</span>;
}

function lastNDays(points = [], n = 30) {
  if (!Array.isArray(points) || points.length === 0) return [];
  const sorted = [...points].sort((a, b) => new Date(a.date) - new Date(b.date));
  return sorted.slice(Math.max(0, sorted.length - n));
}

const getSystemSummary = ({ health, overview }) => {
  const cloudConnected = !!health;
  const mqttHealthy = !!health?.mqtt;
  const deviceStatus = overview?.device_status || {};
  const offlineDevices = Number(deviceStatus.offline_devices || 0);
  const errorDevices = Number(deviceStatus.error_devices || 0);

  if (cloudConnected && mqttHealthy && offlineDevices === 0 && errorDevices === 0) {
    return {
      status: 'ok',
      title: 'Hệ thống kinh doanh và hạ tầng đang hoạt động ổn định',
      description:
        'Cloud API, MQTT broker và các edge device đều đang phản hồi tốt. Dữ liệu dashboard được đồng bộ bình thường.',
    };
  }

  if (cloudConnected || mqttHealthy) {
    return {
      status: 'warning',
      title: 'Hệ thống đang hoạt động nhưng có điểm cần theo dõi',
      description:
        'Một phần hạ tầng hoặc thiết bị đang gián đoạn. Bạn nên kiểm tra tab Giám sát kỹ thuật để xem chi tiết.',
    };
  }

  return {
    status: 'down',
    title: 'Hệ thống đang có sự cố kết nối',
    description:
      'Cloud API hoặc MQTT broker chưa phản hồi. Dữ liệu overview có thể không còn mới.',
  };
};

const fetchDashboardPayload = async ({ days, branchId }) => {
  const [
    health,
    recommendationPerformance,
    model,
    branchesResponse,
    transactions,
    overview,
    revenueTrendResponse,
    topProductsResponse,
    branchPerformanceResponse,
    inventoryAlertsResponse,
    branchInventoryResponse,
    customerSegmentsResponse,
  ] = await Promise.all([
    serverApi.health().catch(() => null),
    serverApi.recommendationPerformance({ days }).catch(() => null),
    serverApi.currentModel().catch(() => null),
    serverApi.branches().catch(() => ({ branches: [] })),
    serverApi.transactions({ limit: 12 }).catch(() => []),
    serverApi.analyticsDashboardOverview({ days, branchId }).catch(() => null),
    serverApi.analyticsRevenueTrend({ days, branchId }).catch(() => null),
    serverApi.analyticsTopProducts({ days, branchId, limit: 10 }).catch(() => null),
    serverApi.analyticsBranchPerformance({ days }).catch(() => null),
    serverApi.analyticsInventoryAlerts({ branchId, threshold: 5 }).catch(() => null),
    serverApi.analyticsBranchInventory({ branchId, threshold: 5, limit: 12 }).catch(() => null),
    serverApi.analyticsCustomerSegments({ branchId }).catch(() => null),
  ]);

  const branchIds = Array.isArray(branchesResponse?.branches) ? branchesResponse.branches : [];
  const orderedTransactions = Array.isArray(transactions)
    ? [...transactions].sort((left, right) => new Date(right.timestamp) - new Date(left.timestamp))
    : [];

  return {
    loading: false,
    refreshing: false,
    error: '',
    health,
    recommendationPerformance,
    model,
    branches: branchIds,
    transactions: orderedTransactions,
    overview,
    revenueTrendResponse,
    topProductsResponse,
    branchPerformanceResponse,
    inventoryAlertsResponse,
    branchInventoryResponse,
    customerSegmentsResponse,
    lastUpdatedAt: new Date().toISOString(),
  };
};

const DashboardPage = () => {
  const { user, setUser } = useAuth();
  const navigate = useNavigate();

  const [dashboardState, setDashboardState] = useState({
    loading: true,
    refreshing: false,
    error: '',
    health: null,
    recommendationPerformance: null,
    model: null,
    branches: [],
    transactions: [],
    overview: null,
    revenueTrendResponse: null,
    topProductsResponse: null,
    branchPerformanceResponse: null,
    inventoryAlertsResponse: null,
    branchInventoryResponse: null,
    customerSegmentsResponse: null,
    lastUpdatedAt: '',
  });

  const [history, setHistory] = useState([]);
  const [showLogoutConfirm, setShowLogoutConfirm] = useState(false);
  const [activeTab, setActiveTab] = useState('overview');
  const [selectedBranchId, setSelectedBranchId] = useState('');
  const [selectedDays, setSelectedDays] = useState(30);
  const [listSearch, setListSearch] = useState({
    inventoryBranches: '',
    inventoryItems: '',
    algorithms: '',
    topProducts: '',
    branches: '',
    customerSegments: '',
    inventoryAlerts: '',
    categories: '',
  });
  const [associationJob, setAssociationJob] = useState({
    running: Boolean(window.localStorage.getItem(ASSOCIATION_JOB_STORAGE_KEY)),
    jobId: window.localStorage.getItem(ASSOCIATION_JOB_STORAGE_KEY) || '',
    status: 'idle',
    result: null,
    error: '',
  });

  const customer = user?.customer ?? null;
  const account = user?.account ?? null;

  useEffect(() => {
    let active = true;
    setHistory([]);

    const loadDashboard = async ({ silent = false } = {}) => {
      if (!active) return;

      setDashboardState((current) => ({
        ...current,
        loading: current.lastUpdatedAt ? current.loading : !silent,
        refreshing: silent || !!current.lastUpdatedAt,
        error: '',
      }));

      try {
        const nextState = await fetchDashboardPayload({
          days: selectedDays,
          branchId: selectedBranchId || undefined,
        });
        if (!active) return;

        startTransition(() => {
          setDashboardState(nextState);
          setHistory((current) => {
            const next = [...current, buildSnapshot({ overview: nextState.overview })];
            return next.slice(-HISTORY_LIMIT);
          });
        });
      } catch (error) {
        if (!active) return;
        setDashboardState((current) => ({
          ...current,
          loading: false,
          refreshing: false,
          error: error?.message || 'Không tải được dữ liệu dashboard',
        }));
      }
    };

    loadDashboard();
    const timer = window.setInterval(() => loadDashboard({ silent: true }), REFRESH_INTERVAL_MS);

    return () => {
      active = false;
      window.clearInterval(timer);
    };
  }, [selectedBranchId, selectedDays]);

  useEffect(() => {
    if (!associationJob.jobId) return undefined;
    if (!associationJob.running && associationJob.status !== 'idle') return undefined;

    let active = true;
    const pollJob = async () => {
      try {
        const job = await serverApi.productAssociationJob(associationJob.jobId);
        if (!active) return;

        setAssociationJob((current) => ({
          ...current,
          running: job.status === 'pending' || job.status === 'running',
          status: job.status,
          result: job.result ?? current.result,
          error: job.error || '',
        }));
      } catch (error) {
        if (!active) return;
        setAssociationJob((current) => ({
          ...current,
          running: false,
          status: 'failed',
          error: error?.message || 'Khong the kiem tra trang thai job',
        }));
      }
    };

    pollJob();
    const timer = window.setInterval(pollJob, 2500);

    return () => {
      active = false;
      window.clearInterval(timer);
    };
  }, [associationJob.running, associationJob.jobId, associationJob.status]);

  const latestTransaction = dashboardState.transactions?.[0] ?? null;

  const derived = useMemo(() => {
    const health = dashboardState.health;
    const recommendation = dashboardState.recommendationPerformance;
    const model = dashboardState.model;
    const overview = dashboardState.overview;
    const revenueTrend = dashboardState.revenueTrendResponse?.data;
    const topProducts = dashboardState.topProductsResponse?.items;
    const branchPerformance = dashboardState.branchPerformanceResponse?.items;
    const inventoryAlerts = dashboardState.inventoryAlertsResponse?.items;
    const branchInventory = dashboardState.branchInventoryResponse;
    const customerSegments = dashboardState.customerSegmentsResponse?.items;
    const filteredBranchPerformance = Array.isArray(branchPerformance)
      ? branchPerformance.filter((branch) => !selectedBranchId || branch.branch_id === selectedBranchId)
      : [];
    const resolvedBranchPerformance = filteredBranchPerformance.length
      ? filteredBranchPerformance
      : (overview?.branch_performance ?? []);

    return {
      totalTransactions: overview?.kpis?.transactions?.value ?? 0,
      totalRevenue: overview?.kpis?.revenue?.value ?? 0,
      avgOrderValue: overview?.kpis?.avg_order_value?.value ?? 0,
      uniqueCustomers: overview?.kpis?.unique_customers?.value ?? 0,
      recommendationCtr: overview?.kpis?.recommendation_ctr?.value ?? 0,
      recommendationAcceptance: overview?.kpis?.recommendation_acceptance_rate?.value
        ?? recommendation?.acceptance_rate
        ?? 0,
      footTraffic: overview?.kpis?.foot_traffic?.value ?? 0,
      conversionRate: overview?.kpis?.conversion_rate?.value ?? 0,
      activeBranches: resolvedBranchPerformance.length || dashboardState.branches.length,
      totalRecommendations:
        overview?.recommendation_summary?.total_recommendations
        ?? recommendation?.total_recommendations
        ?? 0,
      recommendationAlgorithmPerformance: overview?.recommendation_algorithm_performance ?? [],
      avgItemsRecommended: recommendation?.avg_items_recommended ?? 0,
      modelVersion: model?.version ?? 'N/A',
      modelAccuracy: model?.accuracy ?? 0,
      cloudConnected: !!health,
      mqttHealthy: !!health?.mqtt,
      branchPerformance: resolvedBranchPerformance,
      topProducts: Array.isArray(topProducts) && topProducts.length
        ? topProducts
        : (overview?.top_products ?? []),
      categoryBreakdown: overview?.category_breakdown ?? [],
      inventoryAlerts: Array.isArray(inventoryAlerts) && inventoryAlerts.length
        ? inventoryAlerts
        : (overview?.inventory_alerts ?? []),
      branchInventoryTotals: branchInventory?.totals ?? {
        sku_count: 0,
        total_stock: 0,
        total_reserved: 0,
        total_available: 0,
        low_stock_items: 0,
        out_of_stock_items: 0,
      },
      branchInventoryBranches: Array.isArray(branchInventory?.branches)
        ? branchInventory.branches
        : [],
      branchInventoryItems: Array.isArray(branchInventory?.items)
        ? branchInventory.items
        : [],
      customerSegments: Array.isArray(customerSegments) && customerSegments.length
        ? customerSegments
        : (overview?.customer_segments ?? []),
      deviceStatus: overview?.device_status ?? null,
      revenueTrend: lastNDays(
        Array.isArray(revenueTrend) && revenueTrend.length
          ? revenueTrend
          : (overview?.revenue_trend ?? []),
        MAX_VISIBLE,
      ),
    };
  }, [dashboardState, selectedBranchId]);

  const filteredLists = useMemo(() => ({
    inventoryBranches: derived.branchInventoryBranches.filter((branch) => matchesSearch(
      listSearch.inventoryBranches,
      [branch.branch_name, branch.branch_id],
    )),
    inventoryItems: derived.branchInventoryItems.filter((item) => matchesSearch(
      listSearch.inventoryItems,
      [item.product_name, item.category, item.branch_name, item.branch_id, item.product_id, item.status],
    )),
    algorithms: derived.recommendationAlgorithmPerformance.filter((item) => matchesSearch(
      listSearch.algorithms,
      [RECOMMENDATION_ALGORITHM_LABELS[item.algorithm], item.algorithm],
    )),
    topProducts: derived.topProducts.filter((product) => matchesSearch(
      listSearch.topProducts,
      [product.product_name, product.category, product.product_id],
    )),
    branches: derived.branchPerformance.filter((branch) => matchesSearch(
      listSearch.branches,
      [branch.branch_name, branch.branch_id],
    )),
    customerSegments: derived.customerSegments.filter((segment) => matchesSearch(
      listSearch.customerSegments,
      [segment.segment],
    )),
    inventoryAlerts: derived.inventoryAlerts.filter((item) => matchesSearch(
      listSearch.inventoryAlerts,
      [item.product_name, item.branch_name, item.branch_id, item.status],
    )),
    categories: derived.categoryBreakdown.filter((category) => matchesSearch(
      listSearch.categories,
      [category.category],
    )),
  }), [derived, listSearch]);

  const handleListSearchChange = (key) => (event) => {
    setListSearch((current) => ({
      ...current,
      [key]: event.target.value,
    }));
  };

  const renderSearchInput = (key, placeholder) => (
    <label className="list-search">
      <Search size={16} />
      <input
        type="search"
        value={listSearch[key]}
        onChange={handleListSearchChange(key)}
        placeholder={placeholder}
        aria-label={placeholder}
      />
    </label>
  );

  const topBranch = derived.branchPerformance?.[0] ?? null;
  const inventoryScopeLabel = selectedBranchId || 'Toàn chuỗi';

  const systemSummary = useMemo(
    () =>
      getSystemSummary({
        health: dashboardState.health,
        overview: dashboardState.overview,
      }),
    [dashboardState.health, dashboardState.overview],
  );

  const revenuePeak = Math.max(...history.map((item) => item.revenue), 1);
  const trendPeak = Math.max(...derived.revenueTrend.map((item) => item.revenue || 0), 1);

  const handleRefreshNow = async () => {
    setDashboardState((current) => ({ ...current, refreshing: true, error: '' }));
    try {
      const nextState = await fetchDashboardPayload({
        days: selectedDays,
        branchId: selectedBranchId || undefined,
      });
      setDashboardState(nextState);
      setHistory((current) => {
        const next = [...current, buildSnapshot({ overview: nextState.overview })];
        return next.slice(-HISTORY_LIMIT);
      });
    } catch (error) {
      setDashboardState((current) => ({
        ...current,
        refreshing: false,
        error: error?.message || 'Không thể làm mới dữ liệu',
      }));
    }
  };

  const handleConfirmLogout = async () => {
    try {
      await serverApi.logout();
    } catch (error) {
      console.error(error);
    } finally {
      setUser(null);
      navigate('/login', { replace: true });
    }
  };

  const handleGenerateProductAssociations = async () => {
    setAssociationJob((current) => ({
      ...current,
      running: true,
      error: '',
    }));

    try {
      const job = await serverApi.generateProductAssociations();
      window.localStorage.setItem(ASSOCIATION_JOB_STORAGE_KEY, job.job_id);
      setAssociationJob({
        running: job.status === 'pending' || job.status === 'running',
        jobId: job.job_id,
        status: job.status,
        result: job.result,
        error: '',
      });
    } catch (error) {
      setAssociationJob((current) => ({
        ...current,
        running: false,
        status: 'failed',
        error: error?.message || 'Không thể tạo lại luật gợi ý sản phẩm',
      }));
    }
  };

  return (
    <div className="ops-dashboard">
      <header className="ops-header">
        <div className="ops-header__lead">
          <div className="ops-badge">
            <ShieldCheck size={16} />
            <span>Realtime System Watch</span>
          </div>
          <h1>Admin Dashboard</h1>
          <p>
            Theo dõi tổng quan kinh doanh chuỗi bán lẻ, doanh thu, khách hàng, hiệu suất AI
            và trạng thái hệ thống theo thời gian thực.
          </p>
        </div>

        <div className="ops-header__actions">
          <div className="session-card">
            <div className="session-card__avatar">
              <UserRound size={18} />
            </div>
            <div>
              <strong>{customer ? `${customer.first_name ?? ''} ${customer.last_name ?? ''}`.trim() : 'Tài khoản'}</strong>
              <span>{account?.email || customer?.email || 'Phiên theo dõi từ xa'}</span>
            </div>
          </div>

          <div className="toolbar-actions">
            <button
              type="button"
              className="dashboard-btn dashboard-btn--ghost btn-unified"
              onClick={handleRefreshNow}
              disabled={dashboardState.refreshing}
            >
              <RefreshCcw size={16} className={dashboardState.refreshing ? 'spin' : ''} />
              <span>{dashboardState.refreshing ? 'Đang đồng bộ' : 'Làm mới'}</span>
            </button>
            <button
              type="button"
              className="dashboard-btn dashboard-btn--danger btn-unified"
              onClick={() => setShowLogoutConfirm(true)}
            >
              <LogOut size={16} />
              <span>Đăng xuất</span>
            </button>
          </div>
        </div>
      </header>

      <main className="ops-main">
        <section className="dashboard-tabs">
          <button
            type="button"
            className={`dashboard-tab ${activeTab === 'overview' ? 'is-active' : ''}`}
            onClick={() => setActiveTab('overview')}
          >
            <BarChart3 size={16} />
            <span>Tổng quan kinh doanh</span>
          </button>
          <button
            type="button"
            className={`dashboard-tab ${activeTab === 'monitoring' ? 'is-active' : ''}`}
            onClick={() => setActiveTab('monitoring')}
          >
            <MonitorCog size={16} />
            <span>Giám sát kỹ thuật</span>
          </button>
        </section>

        <section className="hero-panel">
          <div className="hero-panel__primary">
            <div className="dashboard-filters">
              <label className="dashboard-filter">
                <span>Khoảng thời gian</span>
                <select
                  value={selectedDays}
                  onChange={(event) => setSelectedDays(Number(event.target.value))}
                >
                  {ANALYTICS_DAY_OPTIONS.map((days) => (
                    <option key={days} value={days}>
                      {formatPeriodLabel(days)}
                    </option>
                  ))}
                </select>
              </label>

              <label className="dashboard-filter">
                <span>Chi nhánh</span>
                <select
                  value={selectedBranchId}
                  onChange={(event) => setSelectedBranchId(event.target.value)}
                >
                  <option value="">Tất cả chi nhánh</option>
                  {dashboardState.branches.map((branchId) => (
                    <option key={branchId} value={branchId}>
                      {branchId}
                    </option>
                  ))}
                </select>
              </label>
            </div>
            <div className="hero-panel__meta">
              <span>Cập nhật cuối: {dashboardState.loading ? 'Đang tải...' : formatDateTime(dashboardState.lastUpdatedAt)}</span>
              <span>Tự động đồng bộ mỗi {REFRESH_INTERVAL_MS / 1000} giây</span>
            </div>
          </div>

          <div className="hero-panel__highlights">
            <div>
              <span className="eyebrow">{`Chi nhánh tốt nhất ${formatPeriodLabel(selectedDays)}`}</span>
              <strong>{topBranch?.branch_name || topBranch?.branch_id || '--'}</strong>
              <span>{topBranch ? formatCurrency(topBranch.revenue) : 'Chưa có dữ liệu'}</span>
            </div>
            <div>
              <span className="eyebrow">Các giao dịch gần nhất</span>
              <strong>{latestTransaction?.transaction_id || '--'}</strong>
              <span>{latestTransaction ? relativeTimeFromNow(latestTransaction.timestamp) : 'Chưa ghi nhận'}</span>
            </div>
          </div>
        </section>

        {dashboardState.error ? (
          <section className="dashboard-alert">
            <CircleAlert size={18} />
            <span>{dashboardState.error}</span>
          </section>
        ) : null}

        {activeTab === 'overview' ? (
          <>
            <section className="metrics-grid">
              <MetricCard
                icon={Wallet}
                label="Doanh thu"
                value={formatCurrency(derived.totalRevenue)}
                hint={`Giá trị đơn TB: ${formatCurrency(derived.avgOrderValue)}`}
                tone="amber"
              />
              <MetricCard
                icon={Activity}
                label="Số giao dịch"
                value={formatNumber(derived.totalTransactions)}
                hint={`Tỷ lệ chuyển đổi: ${formatPercent(derived.conversionRate)}`}
                tone="teal"
              />
              <MetricCard
                icon={Users}
                label="Khách hàng"
                value={formatNumber(derived.uniqueCustomers)}
                hint={`Lượt ghé cửa hàng: ${formatNumber(derived.footTraffic)}`}
                tone="blue"
              />
              <MetricCard
                icon={Sparkles}
                label="Tỷ lệ chấp nhận gợi ý"
                value={formatPercent(derived.recommendationAcceptance)}
                hint={`${formatNumber(derived.totalRecommendations)} lượt gợi ý`}
                tone="rose"
              />
            </section>

            <section className="panel-card inventory-command-card">
              <div className="panel-card__header">
                <div>
                  <span className="eyebrow">Branch inventory</span>
                  <h2>Tồn kho theo chi nhánh</h2>
                </div>
                <StatusPill
                  ok={Number(derived.branchInventoryTotals.out_of_stock_items || 0) === 0}
                  neutral={
                    Number(derived.branchInventoryTotals.out_of_stock_items || 0) === 0
                    && Number(derived.branchInventoryTotals.low_stock_items || 0) > 0
                  }
                  label={inventoryScopeLabel}
                />
              </div>

              <div className="inventory-summary-strip">
                <div className="inventory-summary-item">
                  <span>SKU đang theo dõi</span>
                  <strong>{formatNumber(derived.branchInventoryTotals.sku_count)}</strong>
                </div>
                <div className="inventory-summary-item">
                  <span>Tổng tồn</span>
                  <strong>{formatNumber(derived.branchInventoryTotals.total_stock)}</strong>
                </div>
                <div className="inventory-summary-item">
                  <span>Khả dụng</span>
                  <strong>{formatNumber(derived.branchInventoryTotals.total_available)}</strong>
                </div>
                <div className="inventory-summary-item">
                  <span>Đang giữ</span>
                  <strong>{formatNumber(derived.branchInventoryTotals.total_reserved)}</strong>
                </div>
                <div className="inventory-summary-item is-warning">
                  <span>Sắp hết</span>
                  <strong>{formatNumber(derived.branchInventoryTotals.low_stock_items)}</strong>
                </div>
                <div className="inventory-summary-item is-danger">
                  <span>Hết hàng</span>
                  <strong>{formatNumber(derived.branchInventoryTotals.out_of_stock_items)}</strong>
                </div>
              </div>

              <div className="inventory-layout">
                <div className="inventory-branch-list">
                  {renderSearchInput('inventoryBranches', 'Tìm chi nhánh')}
                  {filteredLists.inventoryBranches.length ? filteredLists.inventoryBranches.map((branch) => (
                    <div key={branch.branch_id} className="inventory-branch-row">
                      <div>
                        <strong>{branch.branch_name || branch.branch_id}</strong>
                        <span>{formatNumber(branch.sku_count)} SKU • khả dụng {formatNumber(branch.total_available)}</span>
                      </div>
                      <div>
                        <span>{formatNumber(branch.low_stock_items)} sắp hết</span>
                        <strong>{formatNumber(branch.out_of_stock_items)} hết hàng</strong>
                      </div>
                    </div>
                  )) : (
                    <div className="empty-state">Chưa có dữ liệu tồn kho theo chi nhánh.</div>
                  )}
                </div>

                <div className="inventory-table">
                  {renderSearchInput('inventoryItems', 'Tìm sản phẩm, danh mục, chi nhánh')}
                  <div className="inventory-table__head">
                    <span>Sản phẩm</span>
                    <span>Chi nhánh</span>
                    <span>Tồn</span>
                    <span>Giữ</span>
                    <span>Khả dụng</span>
                    <span>Trạng thái</span>
                  </div>

                  {filteredLists.inventoryItems.length ? filteredLists.inventoryItems.map((item) => (
                    <div key={`${item.branch_id}-${item.product_id}`} className="inventory-table__row">
                      <span>
                        <strong>{item.product_name}</strong>
                        <small>{item.category || 'Chưa phân loại'}</small>
                      </span>
                      <span>{item.branch_name || item.branch_id}</span>
                      <span>{formatNumber(item.stock)}</span>
                      <span>{formatNumber(item.reserved)}</span>
                      <span>{formatNumber(item.available)}</span>
                      <span>
                        <span className={`inventory-status is-${item.status}`}>
                          {getInventoryStatusLabel(item.status)}
                        </span>
                      </span>
                    </div>
                  )) : (
                    <div className="empty-state">Không có sản phẩm tồn kho cần ưu tiên hiển thị.</div>
                  )}
                </div>
              </div>
            </section>

            <section className="panel-card recommendation-algorithm-card">
              <div className="panel-card__header">
                <div>
                  <span className="eyebrow">Recommendation performance</span>
                  <h2>Hiệu suất thuật toán gợi ý</h2>
                </div>
              </div>

              <div className="recommendation-table">
                {renderSearchInput('algorithms', 'Tìm thuật toán')}
                <div className="recommendation-table__head">
                  <span>Thuật toán</span>
                  <span>Impressions</span>
                  <span>Clicks</span>
                  <span>Accepts</span>
                  <span>CTR</span>
                  <span>Acceptance</span>
                </div>

                {filteredLists.algorithms.length ? (
                  filteredLists.algorithms.map((item) => (
                    <div key={item.algorithm} className="recommendation-table__row">
                      <span>{RECOMMENDATION_ALGORITHM_LABELS[item.algorithm] || item.algorithm}</span>
                      <span>{formatNumber(item.impressions)}</span>
                      <span>{formatNumber(item.clicks)}</span>
                      <span>{formatNumber(item.accepted)}</span>
                      <span>{formatPercent(item.ctr)}</span>
                      <span>{formatPercent(item.acceptance_rate)}</span>
                    </div>
                  ))
                ) : (
                  <div className="empty-state">Chưa có dữ liệu recommendation events.</div>
                )}
              </div>
            </section>

            <section className="dashboard-grid dashboard-grid--top">
              <article className="panel-card overview-health-card">
                <div className="panel-card__header">
                  <div>
                    <span className="eyebrow">Executive status</span>
                    <h2>Tình trạng toàn hệ thống</h2>
                  </div>
                  <StatusPill
                    ok={systemSummary.status === 'ok'}
                    neutral={systemSummary.status === 'warning'}
                    label={
                      systemSummary.status === 'ok'
                        ? 'Ổn định'
                        : systemSummary.status === 'warning'
                        ? 'Cảnh báo'
                        : 'Sự cố'
                    }
                  />
                </div>

                <div className={`overview-health-banner is-${systemSummary.status}`}>
                  <div className="overview-health-banner__icon">
                    <ShieldCheck size={18} />
                  </div>
                  <div className="overview-health-banner__content">
                    <strong>{systemSummary.title}</strong>
                    <p>{systemSummary.description}</p>
                  </div>
                </div>

                <div className="overview-health-stats">
                  <div className="insight-box">
                    <span>Model version</span>
                    <strong>{derived.modelVersion}</strong>
                  </div>
                  <div className="insight-box">
                    <span>Độ chính xác model</span>
                    <strong>{`${((derived.modelAccuracy || 0) * 100).toFixed(1)}%`}</strong>
                  </div>
                  <div className="insight-box">
                    <span>CTR gợi ý</span>
                    <strong>{formatPercent(derived.recommendationCtr)}</strong>
                  </div>
                </div>
              </article>

              <article className="panel-card">
                <div className="panel-card__header">
                  <div>
                    <span className="eyebrow">Realtime snapshot</span>
                    <h2>Biến động theo từng lần đồng bộ</h2>
                  </div>
                </div>

                <div className="sparkline-bars">
                  {history.length ? history.map((point) => (
                    <div key={point.createdAt} className="sparkline-bars__item">
                      <div
                        className="sparkline-bars__bar"
                        style={{ height: `${Math.max(12, (point.revenue / revenuePeak) * 100)}%` }}
                        title={`${formatCurrency(point.revenue)} • ${formatNumber(point.transactions)} giao dịch`}
                      />
                      <span>{new Date(point.createdAt).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })}</span>
                    </div>
                  )) : (
                    <div className="empty-state">Chưa đủ dữ liệu lịch sử để hiển thị.</div>
                  )}
                </div>
              </article>
            </section>

            <section className="dashboard-grid dashboard-grid--bottom">
              <article className="panel-card">
                <div className="panel-card__header">
                  <div>
                    <span className="eyebrow">Revenue trend</span>
                    <h2>Doanh thu theo ngày</h2>
                  </div>
                </div>

                <div className="revenue-trend-chart">
                  <div className="revenue-trend-chart__meta">
                    <span>30 ngày gần nhất</span>
                    <strong>{formatCurrency(derived.totalRevenue)}</strong>
                  </div>
                  {derived.revenueTrend.length ? derived.revenueTrend.map((point) => (
                    <div
                      key={point.date}
                      className="revenue-trend-chart__item"
                      title={`${point.date} • ${formatCurrency(point.revenue)} • ${formatNumber(point.transactions)} giao dịch`}
                    >
                      <div
                        className="revenue-trend-chart__bar"
                        style={{ height: `${Math.max(12, ((point.revenue || 0) / trendPeak) * 100)}%` }}
                        title={`${point.date} • ${formatCurrency(point.revenue)} • ${formatNumber(point.transactions)} giao dịch`}
                      />
                      <span className="revenue-trend-chart__label">
                        {new Date(point.date).toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit' })}
                      </span>
                    </div>
                  )) : (
                    <div className="empty-state">Chưa có dữ liệu doanh thu theo ngày.</div>
                  )}
                </div>
              </article>

              <article className="panel-card">
                <div className="panel-card__header">
                  <div>
                    <span className="eyebrow">Products</span>
                    <h2>Top sản phẩm bán chạy</h2>
                  </div>
                </div>

                <div className="transaction-feed">
                  {renderSearchInput('topProducts', 'Tìm sản phẩm hoặc danh mục')}
                  {filteredLists.topProducts.length ? filteredLists.topProducts.map((product) => (
                    <div key={product.product_id} className="transaction-row">
                      <div>
                        <strong>{product.product_name}</strong>
                        <span>{product.category || 'Chưa phân loại'} • {formatNumber(product.quantity_sold)} sản phẩm</span>
                      </div>
                      <div className="transaction-row__meta">
                        <Package size={16} />
                        <strong>{formatCurrency(product.revenue)}</strong>
                      </div>
                    </div>
                  )) : (
                    <div className="empty-state">Chưa có dữ liệu sản phẩm.</div>
                  )}
                </div>
              </article>
            </section>

            <section className="dashboard-grid dashboard-grid--bottom">
              <article className="panel-card">
                <div className="panel-card__header">
                  <div>
                    <span className="eyebrow">Branches</span>
                    <h2>Bảng điều hành chi nhánh</h2>
                  </div>
                </div>

                <div className="branch-table">
                  {renderSearchInput('branches', 'Tìm chi nhánh')}
                  <div className="branch-table__head">
                    <span>Chi nhánh</span>
                    <span>Giao dịch</span>
                    <span>Doanh thu</span>
                    <span>Tỷ lệ chuyển đổi</span>
                  </div>

                  {filteredLists.branches.length ? filteredLists.branches.map((branch) => (
                    <div key={branch.branch_id} className="branch-table__row">
                      <span>{branch.branch_name || branch.branch_id}</span>
                      <span>{formatNumber(branch.transactions)}</span>
                      <span>{formatCurrency(branch.revenue)}</span>
                      <span>{formatPercent(branch.conversion_rate)}</span>
                    </div>
                  )) : (
                    <div className="empty-state">Chưa có thống kê chi nhánh.</div>
                  )}
                </div>
              </article>

              <article className="panel-card">
                <div className="panel-card__header">
                  <div>
                    <span className="eyebrow">Customers</span>
                    <h2>Phân khúc khách hàng</h2>
                  </div>
                </div>

                <div className="transaction-feed">
                  {renderSearchInput('customerSegments', 'Tìm phân khúc khách hàng')}
                  {filteredLists.customerSegments.length ? filteredLists.customerSegments.map((segment, index) => (
                    <div key={`${segment.segment}-${index}`} className="transaction-row">
                      <div>
                        <strong>{segment.segment}</strong>
                        <span>Nhóm khách hàng</span>
                      </div>
                      <div className="transaction-row__meta">
                        <Users size={16} />
                        <strong>{formatNumber(segment.customers)}</strong>
                      </div>
                    </div>
                  )) : (
                    <div className="empty-state">Chưa có dữ liệu phân khúc khách hàng.</div>
                  )}
                </div>
              </article>
            </section>

            <section className="dashboard-grid dashboard-grid--bottom">
              <article className="panel-card">
                <div className="panel-card__header">
                  <div>
                    <span className="eyebrow">Inventory alerts</span>
                    <h2>Cảnh báo tồn kho</h2>
                  </div>
                </div>

                <div className="transaction-feed">
                  {renderSearchInput('inventoryAlerts', 'Tìm sản phẩm hoặc chi nhánh')}
                  {filteredLists.inventoryAlerts.length ? filteredLists.inventoryAlerts.map((item) => (
                    <div key={`${item.branch_id}-${item.product_id}`} className="transaction-row">
                      <div>
                        <strong>{item.product_name}</strong>
                        <span>{item.branch_name || item.branch_id} • khả dụng {formatNumber(item.available)}</span>
                      </div>
                      <div className="transaction-row__meta">
                        <ShieldAlert size={16} />
                        <strong>{item.status === 'out_of_stock' ? 'Hết hàng' : 'Sắp hết'}</strong>
                      </div>
                    </div>
                  )) : (
                    <div className="empty-state">Chưa có cảnh báo tồn kho.</div>
                  )}
                </div>
              </article>

              <article className="panel-card">
                <div className="panel-card__header">
                  <div>
                    <span className="eyebrow">Categories</span>
                    <h2>Doanh thu theo danh mục</h2>
                  </div>
                </div>

                <div className="transaction-feed">
                  {renderSearchInput('categories', 'Tìm danh mục')}
                  {filteredLists.categories.length ? filteredLists.categories.map((category, index) => (
                    <div key={`${category.category}-${index}`} className="transaction-row">
                      <div>
                        <strong>{category.category}</strong>
                        <span>{formatNumber(category.quantity_sold)} sản phẩm đã bán</span>
                      </div>
                      <div className="transaction-row__meta">
                        <TrendingUp size={16} />
                        <strong>{formatCurrency(category.revenue)}</strong>
                      </div>
                    </div>
                  )) : (
                    <div className="empty-state">Chưa có dữ liệu danh mục.</div>
                  )}
                </div>
              </article>
            </section>
          </>
        ) : (
          <>
            <section className="metrics-grid">
              <MetricCard
                icon={Activity}
                label={`Giao dịch ${formatPeriodLabel(selectedDays)}`}
                value={formatNumber(derived.totalTransactions)}
                hint="Theo dữ liệu dashboard hiện tại"
                tone="teal"
              />
              <MetricCard
                icon={Building2}
                label="Chi nhánh đang hoạt động"
                value={formatNumber(derived.activeBranches)}
                hint={dashboardState.branches.length ? dashboardState.branches.join(' • ') : 'Chưa có dữ liệu chi nhánh'}
                tone="blue"
              />
              <MetricCard
                icon={Sparkles}
                label="Tỷ lệ chấp nhận gợi ý"
                value={formatPercent(derived.recommendationAcceptance)}
                hint={`${formatNumber(derived.totalRecommendations)} lượt gợi ý trong ${formatPeriodLabel(selectedDays)}`}
                tone="rose"
              />
              <MetricCard
                icon={Cpu}
                label="Thiết bị lỗi / offline"
                value={formatNumber(
                  Number(dashboardState.overview?.device_status?.offline_devices || 0)
                  + Number(dashboardState.overview?.device_status?.error_devices || 0),
                )}
                hint="Từ analytics dashboard"
                tone="amber"
              />
            </section>

            <section className="monitoring-layout">
              <article className="panel-card">
                <div className="panel-card__header">
                  <div>
                    <span className="eyebrow">Advanced monitoring</span>
                    <h2>ServerStatus kỹ thuật</h2>
                  </div>
                </div>

                <div className="status-list">
                  <div className="status-row">
                    <div className="status-row__label">
                      <Gauge size={16} />
                      <span>Cloud API</span>
                    </div>
                    <StatusPill ok={derived.cloudConnected} label={derived.cloudConnected ? 'Online' : 'Offline'} />
                  </div>
                  <div className="status-row">
                    <div className="status-row__label">
                      <Cpu size={16} />
                      <span>MQTT broker</span>
                    </div>
                    <StatusPill ok={derived.mqttHealthy} label={derived.mqttHealthy ? 'Ổn định' : 'Gián đoạn'} />
                  </div>
                  <div className="status-row">
                    <div className="status-row__label">
                      <BrainCircuit size={16} />
                      <span>Recommendation model</span>
                    </div>
                    <StatusPill ok neutral label={derived.modelVersion} />
                  </div>
                </div>

                <div className="monitoring-grid">
                  <div className="insight-box">
                    <span>Cloud sync</span>
                    <strong>{dashboardState.refreshing ? 'Đang đồng bộ' : 'Ổn định'}</strong>
                  </div>
                  <div className="insight-box">
                    <span>Last update</span>
                    <strong>{dashboardState.lastUpdatedAt ? formatDateTime(dashboardState.lastUpdatedAt) : '--'}</strong>
                  </div>
                  <div className="insight-box">
                    <span>Recommendations 7 ngày</span>
                    <strong>{formatNumber(derived.totalRecommendations)}</strong>
                  </div>
                  <div className="insight-box">
                    <span>Acceptance rate</span>
                    <strong>{formatPercent(derived.recommendationAcceptance)}</strong>
                  </div>
                </div>
              </article>

              <article className="panel-card">
                <div className="panel-card__header">
                  <div>
                    <span className="eyebrow">Grafana</span>
                    <h2>Giám sát nâng cao</h2>
                  </div>
                  {GRAFANA_EMBED_URL ? (
                    <a className="monitoring-link" href={GRAFANA_EMBED_URL} target="_blank" rel="noreferrer">
                      <ExternalLink size={16} />
                      <span>Mở Grafana</span>
                    </a>
                  ) : null}
                </div>

                {GRAFANA_EMBED_URL ? (
                  <div className="grafana-embed">
                    <iframe
                      title="Grafana Monitoring"
                      src={GRAFANA_EMBED_URL}
                      className="grafana-embed__frame"
                    />
                  </div>
                ) : (
                  <div className="empty-state empty-state--large">
                    Chưa cấu hình `VITE_GRAFANA_EMBED_URL`. Khi thêm biến môi trường này, tab này sẽ nhúng Grafana trực tiếp.
                  </div>
                )}
              </article>

              <article className="panel-card">
                <div className="panel-card__header">
                  <div>
                    <span className="eyebrow">Recommendation rules</span>
                    <h2>Luật gợi ý sản phẩm</h2>
                  </div>
                  <button
                    type="button"
                    className="dashboard-btn dashboard-btn--ghost btn-unified"
                    onClick={handleGenerateProductAssociations}
                    disabled={associationJob.running || !account?.is_admin}
                    title={!account?.is_admin ? 'Chỉ admin được tạo lại luật gợi ý' : undefined}
                  >
                    <BrainCircuit size={16} className={associationJob.running ? 'spin' : ''} />
                    <span>{associationJob.running ? 'Đang tạo luật' : 'Tạo lại luật'}</span>
                  </button>
                </div>

                <div className="association-rule-panel">
                  <p>
                    Tính năng này sẽ chạy thuật toán trên dữ liệu giao dịch lịch sử để tạo ra các luật gợi ý sản phẩm. Tùy vào khối lượng dữ liệu, quá trình này có thể mất vài phút và sẽ chạy nền để không ảnh hưởng đến hiệu suất hệ thống.
                  </p>

                  {associationJob.jobId ? (
                    <div className="association-job-meta">
                      <StatusPill
                        ok={associationJob.status === 'success'}
                        neutral={associationJob.status === 'pending' || associationJob.status === 'running'}
                        label={getAssociationJobStatusLabel(associationJob.status)}
                      />
                      <span>Job: {associationJob.jobId}</span>
                    </div>
                  ) : null}

                  {associationJob.error ? (
                    <div className="dashboard-alert dashboard-alert--inline">
                      <CircleAlert size={18} />
                      <span>{associationJob.error}</span>
                    </div>
                  ) : null}

                  {associationJob.result ? (
                    <div className="monitoring-grid">
                      <div className="insight-box">
                        <span>Transactions</span>
                        <strong>{formatNumber(associationJob.result.transactions_used)}</strong>
                      </div>
                      <div className="insight-box">
                        <span>Itemsets</span>
                        <strong>{formatNumber(associationJob.result.frequent_itemsets)}</strong>
                      </div>
                      <div className="insight-box">
                        <span>Rules 1 -&gt; 1</span>
                        <strong>{formatNumber(associationJob.result.one_to_one_rules ?? 0)}</strong>
                      </div>
                      <div className="insight-box">
                        <span>Rules cart</span>
                        <strong>{formatNumber(associationJob.result.cart_rules ?? 0)}</strong>
                      </div>
                      <div className="insight-box">
                        <span>Raw rules</span>
                        <strong>{formatNumber(associationJob.result.raw_rules_inserted ?? associationJob.result.rules_inserted)}</strong>
                      </div>
                    </div>
                  ) : associationJob.running ? (
                    <div className="empty-state">Job đang chạy nền. Dashboard sẽ tự cập nhật kết quả khi hoàn tất.</div>
                  ) : (
                    <div className="empty-state">Chưa chạy tạo lại luật gợi ý trong phiên này.</div>
                  )}
                </div>
              </article>

              <article className="panel-card">
                <div className="panel-card__header">
                  <div>
                    <span className="eyebrow">Branches live</span>
                    <h2>Chi nhánh và tải giao dịch</h2>
                  </div>
                </div>

                <div className="branch-table">
                  <div className="branch-table__head">
                    <span>Chi nhánh</span>
                    <span>Giao dịch</span>
                    <span>Doanh thu</span>
                    <span>Trạng thái</span>
                  </div>

                  {derived.branchPerformance.length ? derived.branchPerformance.map((branch) => (
                    <div key={branch.branch_id} className="branch-table__row">
                      <span>{branch.branch_name || branch.branch_id}</span>
                      <span>{formatNumber(branch.transactions)}</span>
                      <span>{formatCurrency(branch.revenue)}</span>
                      <span>{branch.transactions > 0 ? 'Có hoạt động' : 'Chưa ghi nhận'}</span>
                    </div>
                  )) : (
                    <div className="empty-state">Chưa có dữ liệu giám sát chi nhánh.</div>
                  )}
                </div>
              </article>
            </section>
          </>
        )}
      </main>

      {showLogoutConfirm ? (
        <div className="dashboard-modal">
          <div className="dashboard-modal__card">
            <div className="dashboard-modal__icon">
              <LogOut size={22} />
            </div>
            <h3>Bạn thật sự muốn đăng xuất?</h3>
            <p>Bạn sẽ cần đăng nhập lại để tiếp tục xem trạng thái của hệ thống.</p>
            <div className="dashboard-modal__actions">
              <button type="button" className="dashboard-btn dashboard-btn--ghost" onClick={() => setShowLogoutConfirm(false)}>
                Hủy
              </button>
              <button type="button" className="dashboard-btn dashboard-btn--danger" onClick={handleConfirmLogout}>
                Đăng xuất
              </button>
            </div>
          </div>
        </div>
      ) : null}
    </div>
  );
};

export default DashboardPage;
