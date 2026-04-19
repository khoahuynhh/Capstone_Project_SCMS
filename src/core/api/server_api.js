const getServerBaseUrl = () => {
  const fromEnv = import.meta.env.VITE_SERVER_API_BASE;
  if (fromEnv && typeof fromEnv === "string") {
    return fromEnv.replace(/\/$/, "");
  }
  return "";
};

const serverBaseUrl = getServerBaseUrl();

async function request(path, options = {}) {
  const url = `${serverBaseUrl}${path}`;

  const method = (options.method || "GET").toUpperCase();

  // Just set Content-Type when body has form (POST/PUT/PATCH) and body is JSON string/object
  const headers = {
    ...(options.headers || {}),
  };

  const hasBody = options.body !== undefined && options.body !== null;
  const isFormData = typeof FormData !== "undefined" && options.body instanceof FormData;
  if (hasBody && !isFormData && !headers["Content-Type"]) {
    headers["Content-Type"] = "application/json";
  }

  let resp;
  try {
    resp = await fetch(url, {
      credentials: "include", // Use cookie/session (if backend set httpOnly cookie)
      ...options,
      method,
      headers,
    });
  } catch (error) {
    throw new Error(
      `Không kết nối được Cloud API (${url}). Kiểm tra service cloud đang chạy, VITE_SERVER_API_BASE và CORS. ${error?.message || ""}`.trim()
    );
  }

  // Parse error message if response not ok
  if (!resp.ok) {
    const contentType = resp.headers.get("content-type") || "";
    let detail = "";
    try {
      if (contentType.includes("application/json")) {
        const errJson = await resp.json();
        if (Array.isArray(errJson?.detail)) {
          detail = errJson.detail
            .map((item) => item?.msg || JSON.stringify(item))
            .join(", ");
        } else {
          detail = errJson?.message || errJson?.detail || JSON.stringify(errJson);
        }
      } else {
        detail = await resp.text();
      }
    } catch {
      detail = "";
    }
    throw new Error(`HTTP ${resp.status}${detail ? ` - ${detail}` : ""}`);
  }

  // No content
  if (resp.status === 204) return null;

  const contentType = resp.headers.get("content-type") || "";
  if (contentType.includes("application/json")) {
    return resp.json();
  }
  return resp.text();
}

export const serverApi = {
  health: () => request("/health"),
  metricsSummary: () => request("/metrics/summary"),
  branches: () => request("/branches"),
  branchStats: (branchId, { days = 7 } = {}) =>
    request(`/branches/${encodeURIComponent(branchId)}/stats?days=${days}`),
  recommendationPerformance: ({ branchId, days = 7 } = {}) => {
    const params = new URLSearchParams();
    if (branchId) params.set("branch_id", branchId);
    params.set("days", String(days));
    return request(`/recommendations/performance?${params.toString()}`);
  },
  currentModel: () => request("/models/current"),
  generateProductAssociations: ({
    minSupport = 0.001,
    minConfidence = 0.03,
    minLift = 1,
    minItemsPerTransaction = 2,
    maxRules = 10000,
  } = {}) => {
    const params = new URLSearchParams();
    params.set("min_support", String(minSupport));
    params.set("min_confidence", String(minConfidence));
    params.set("min_lift", String(minLift));
    params.set("min_items_per_transaction", String(minItemsPerTransaction));
    params.set("max_rules", String(maxRules));
    return request(`/admin/product-associations/generate?${params.toString()}`, {
      method: "POST",
    });
  },
  productAssociationJob: (jobId) =>
    request(`/admin/product-associations/jobs/${encodeURIComponent(jobId)}`),
  register: (data) =>
  request("/register", {
    method: "POST",
    body: JSON.stringify(data),
    headers: { "Content-Type": "application/json" },
  }),
  me: () => request("/auth/me"),
  login: ({ email, password }) =>
    request("/auth/login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ email, password }),
    }),
  logout: () =>
    request("/auth/logout", {
      method: "POST",
    }),
  transactions: ({ branchId, startDate, endDate, limit = 20 } = {}) => {
    const params = new URLSearchParams();
    if (branchId) params.set("branch_id", branchId);
    if (startDate) params.set("start_date", startDate);
    if (endDate) params.set("end_date", endDate);
    if (limit) params.set("limit", String(limit));
    const query = params.toString();
    const path = query ? `/transactions?${query}` : "/transactions";
    return request(path);
  },
  createTransaction: (data) =>
    request("/transactions", {
      method: "POST",
      body: JSON.stringify(data), 
    }),
  purchaseHistory: (customerId, { limitInvoices = 10 } = {}) =>
  request(`/customers/${encodeURIComponent(customerId)}/purchase-history/grouped?limit_invoices=${limitInvoices}`),
  products: ({ q = "", category = "", limit = 50, offset = 0 } = {}) => {
    const params = new URLSearchParams();
    if (q) params.set("q", q);
    if (category) params.set("category", category);
    params.set("limit", String(limit));
    params.set("offset", String(offset));
    return request(`/products?${params.toString()}`);
  },
  relatedProducts: (productId, limit = 5) => {
    return request(`/products/${encodeURIComponent(productId)}/related?limit=${limit}`);
  },
  recommendationEvents: (events) =>
    request("/recommendation-events", {
      method: "POST",
      body: JSON.stringify({ events }),
    }),
  recommendationsByAttributes: ({ age, ageGroup, gender, emotion, branchId, topK = 20 } = {}) =>
    request("/recommendations/by-attributes", {
      method: "POST",
      body: JSON.stringify({
        age,
        age_group: ageGroup,
        gender,
        emotion,
        branch_id: branchId,
        top_k: topK,
      }),
    }),
  updateProfile: (data) =>
  request("/auth/me", {
    method: "PATCH",
    body: JSON.stringify(data),
  }),
  // Analytics endpoints
  analyticsDashboardOverview: ({ days = 7, branchId } = {}) => {
  const params = new URLSearchParams();
  params.set("days", String(days));
  if (branchId) params.set("branch_id", branchId);
  return request(`/api/v1/analytics/dashboard/overview?${params.toString()}`);
},

analyticsRevenueTrend: ({ days = 30, branchId } = {}) => {
  const params = new URLSearchParams();
  params.set("days", String(days));
  if (branchId) params.set("branch_id", branchId);
  return request(`/api/v1/analytics/dashboard/revenue-trend?${params.toString()}`);
},

analyticsTopProducts: ({ days = 30, branchId, limit = 10 } = {}) => {
  const params = new URLSearchParams();
  params.set("days", String(days));
  params.set("limit", String(limit));
  if (branchId) params.set("branch_id", branchId);
  return request(`/api/v1/analytics/dashboard/top-products?${params.toString()}`);
},

analyticsBranchPerformance: ({ days = 30 } = {}) => {
  const params = new URLSearchParams();
  params.set("days", String(days));
  return request(`/api/v1/analytics/dashboard/branch-performance?${params.toString()}`);
},

analyticsInventoryAlerts: ({ branchId, threshold = 5 } = {}) => {
  const params = new URLSearchParams();
  params.set("threshold", String(threshold));
  if (branchId) params.set("branch_id", branchId);
  return request(`/api/v1/analytics/dashboard/inventory-alerts?${params.toString()}`);
},

analyticsBranchInventory: ({ branchId, threshold = 5, limit = 15 } = {}) => {
  const params = new URLSearchParams();
  params.set("threshold", String(threshold));
  params.set("limit", String(limit));
  if (branchId) params.set("branch_id", branchId);
  return request(`/api/v1/analytics/dashboard/branch-inventory?${params.toString()}`);
},

analyticsCustomerSegments: ({ branchId } = {}) => {
  const params = new URLSearchParams();
  if (branchId) params.set("branch_id", branchId);
  const query = params.toString();
  return request(
    query
      ? `/api/v1/analytics/dashboard/customer-segments?${query}`
      : `/api/v1/analytics/dashboard/customer-segments`
  );
},
};
