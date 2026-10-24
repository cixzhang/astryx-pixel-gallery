import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

// Builds only the comparison page (spike).
export default defineConfig({
  root: __dirname,
  base: './',
  plugins: [react()],
  build: { outDir: 'dist', emptyOutDir: true, rollupOptions: { input: 'compare.html' } },
})
