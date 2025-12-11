const getServerBaseUrl = () => {
  const fromEnv = import.meta.env.VITE_SERVER_API_BASE;
  if (fromEnv && typeof fromEnv === 'string') {
    return fromEnv.replace(/\/$/, '');
  }
  return '';
};

const serverBaseUrl = getServerBaseUrl();

async function request(path, options = {}) {
  const url = `${serverBaseUrl}${path}`;
  const headers = {
    'Content-Type': 'application/json',
    ...(options.headers || {}),
  };

  const resp = await fetch(url, { ...options, headers });

  if (!resp.ok) {
    const text = await resp.text();
    throw new Error(`HTTP ${resp.status} - ${text}`);
  }

  const contentType = resp.headers.get('content-type') || '';
  if (contentType.includes('application/json')) {
    return resp.json();
  }
  return resp.text();
}

export const serverApi = {
  health: () => request('/health'),
  metricsSummary: () => request('/api/v1/metrics/summary'),
  branches: () => request('/api/v1/branches'),
  transactions: ({ branchId, startDate, endDate, limit = 20 } = {}) => {
    const params = new URLSearchParams();
    if (branchId) params.set('branch_id', branchId);
    if (startDate) params.set('start_date', startDate);
    if (endDate) params.set('end_date', endDate);
    if (limit) params.set('limit', String(limit));

    const query = params.toString();
    const path = query ? `/api/v1/transactions?${query}` : '/api/v1/transactions';
    return request(path);
  },
};
