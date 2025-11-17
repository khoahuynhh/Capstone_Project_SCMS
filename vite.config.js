import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  const target = env.VITE_PROXY_TARGET || env.VITE_API_BASE_URL || 'http://cloud-server:8000'

  return {
    plugins: [react()],
    server: {
      host: true,
      port: 5173,
      proxy: {
        '/api': {
          target,
          changeOrigin: true,
        },
        '/health': {
          target,
          changeOrigin: true,
        },
      },
    },
  }
})
