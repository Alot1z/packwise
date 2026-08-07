import { vlyPlugin } from "@vly-ai/integrations";
import tailwindcss from "@tailwindcss/vite";
import react from "@vitejs/plugin-react";
import path from "path";
import { defineConfig } from "vite";

// https://vite.dev/config/
export default defineConfig({
  plugins: [vlyPlugin(), react(), tailwindcss()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  build: {
    sourcemap: false,
    rollupOptions: {
      output: {
        // Docs pages (Landing/Setup) are eager in src/main.tsx so "/" never needs a lazy chunk.
        // Keep vendor splitting minimal to avoid stale-hash 404s on the preview CDN.
        manualChunks: {
          "react-vendor": ["react", "react-dom", "react-router"],
          "convex-vendor": ["convex", "@convex-dev/auth/react"],
          "radix": [
            "@radix-ui/react-dialog",
            "@radix-ui/react-dropdown-menu",
            "@radix-ui/react-tabs",
            "@radix-ui/react-tooltip",
          ],
          motion: ["framer-motion"],
        },
        chunkFileNames: "assets/[name]-[hash].js",
        entryFileNames: "assets/[name]-[hash].js",
        assetFileNames: "assets/[name]-[hash].[ext]",
      },
    },
    chunkSizeWarningLimit: 1000,
    target: "esnext",
    minify: "esbuild",
  },
  optimizeDeps: {
    include: ["react", "react-dom", "react-router", "@convex-dev/auth/react"],
  },
  // Freebuff requires HMR disabled
  server: {
    hmr: false,
  },
});
