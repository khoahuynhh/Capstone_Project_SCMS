import { dirname } from 'node:path'
import { fileURLToPath } from 'node:url'
import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig(({ mode }) => {
  const rootDir = dirname(fileURLToPath(import.meta.url))
  const env = loadEnv(mode, rootDir, '')

  // BE trung tâm
  const serverTarget =
    env.VITE_SERVER_API_BASE ||
    env.VITE_API_BASE_URL ||          // fallback cho tương thích cũ
    'http://localhost:8000'

  // BE edge device
  const edgeTarget =
    env.VITE_EDGE_API_BASE || 'http://localhost:8001'

  return {
    plugins: [react()],
    server: {
      host: true,
      port: 5173,
      proxy: {
        // gọi /api/... → đi tới BE server trung tâm
        '/api': {
          target: serverTarget,
          changeOrigin: true,
        },
        '/health': {
          target: serverTarget,
          changeOrigin: true,
        },

        // gọi /edge-api/... → đi tới BE edge device
        '/edge-api': {
          target: edgeTarget,
          changeOrigin: true,
        },
        '/edge-health': {
          target: edgeTarget,
          changeOrigin: true,
        },
      },
    },
  }
})
