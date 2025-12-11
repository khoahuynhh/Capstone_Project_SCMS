const getEdgeBaseUrl = () => {
  const fromEnv = import.meta.env.VITE_EDGE_API_BASE;
  if (fromEnv && typeof fromEnv === 'string') {
    return fromEnv.replace(/\/$/, '');
  }
  return '';
};

const edgeBaseUrl = getEdgeBaseUrl();

async function request(path, options = {}) {
  const url = `${edgeBaseUrl}${path}`;
  const resp = await fetch(url, options);

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

export const edgeApi = {
  // gọi /face/identify (multipart/form-data với file ảnh)
  identifyFace: async (file) => {
    const formData = new FormData();
    formData.append('file', file);

    return request('/face/identify', {
      method: 'POST',
      body: formData,
    });
  },

  health: () => request('/health'),
};
