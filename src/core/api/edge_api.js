const getEdgeBaseUrl = () => {
  const fromEnv = import.meta.env.VITE_EDGE_API_BASE;
  if (fromEnv && typeof fromEnv === "string") return fromEnv.replace(/\/$/, "");
  return "";
};

const edgeBaseUrl = getEdgeBaseUrl();

async function request(path, options = {}) {
  const url = `${edgeBaseUrl}${path}`;
  const resp = await fetch(url, options);

  const contentType = resp.headers.get("content-type") || "";

  if (!resp.ok) {
    // try to parse message from json if need
    let detail = "";
    try {
      if (contentType.includes("application/json")) {
        const err = await resp.json();
        detail = err?.message || JSON.stringify(err);
      } else {
        detail = await resp.text();
      }
    } catch {
      detail = "";
    }
    throw new Error(`EDGE HTTP ${resp.status}${detail ? ` - ${detail}` : ""}`);
  }

  if (resp.status === 204) return null;
  if (contentType.includes("application/json")) return resp.json();
  return resp.text();
}

export const edgeApi = {
  // Edge infer: reply {gender, age, emotion, ...}
  FaceAnalysis: async (file) => {
    const formData = new FormData();
    formData.append("file", file);
    return request("/face/analysis", { method: "POST", body: formData });
  },

  health: () => request("/health"),
};
