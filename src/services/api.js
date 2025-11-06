const getBaseUrl = () => {
  const fromEnv = import.meta.env.VITE_API_BASE_URL;
  if (fromEnv && typeof fromEnv === 'string') {
    return fromEnv.replace(/\/$/, '');
  }
  return '';
};

const baseUrl = getBaseUrl();

async function request(path, options = {}) {
  const url = `${baseUrl}${path}`;
  const headers = {
    'Content-Type': 'application/json',
    ...(options.headers || {}),
  };
  const resp = await fetch(url, { ...options, headers });
  if (!resp.ok) {
    const text = await resp.text().catch(() => '');
    throw new Error(`API ${resp.status} ${resp.statusText}: ${text}`);
  }
  // Try JSON, fall back to text
  const contentType = resp.headers.get('content-type') || '';
  if (contentType.includes('application/json')) return resp.json();
  return resp.text();
}

// Public API
export const api = {
  health: () => request('/health'),
  metricsSummary: () => request('/api/v1/metrics/summary'),
  branches: () => request('/api/v1/branches'),
  transactions: ({ branchId, startDate, endDate, limit = 20 } = {}) => {
    const params = new URLSearchParams();
    if (branchId) params.set('branch_id', branchId);
    if (startDate) params.set('start_date', startDate);
    if (endDate) params.set('end_date', endDate);
    if (limit) params.set('limit', String(limit));
    return request(`/api/v1/transactions?${params.toString()}`);
  },
};

export default api;

