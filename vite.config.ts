import { vlyPlugin } from "@vly-ai/integrations";
import tailwindcss from "@tailwindcss/vite";
import react from "@vitejs/plugin-react";
import path from "path";
import { defineConfig } from "vite";

// https://vite.dev/config/
//
// Goal: keep the Freebuff preview site reliably loadable even when the
// CDN serves a fresh `index.html` against a partially-purged asset cache.
//
// Strategy:
//   1. Big pages (Landing/Setup/etc.) stay as their own hashed JS chunks
//      — changing one page does not invalidate the others.
//   2. Vendor code is split by family (react/convex/radix/motion) so the
//      largest slow-changing dependencies cache forever.
//   3. assetsInlineLimit inlines any JS/CSS under 16 KB into the HTML or
//      the importing chunk — this sweeps up tiny lucide-icon stubs, route
//      helpers, and the small `NotFound` chunk so the preview never has
//      to fetch a second file for the first paint.
//   4. CSS is bundled into a single file (no per-page CSS chunks) — one
//      fewer race against stale CDN entries.
//   5. CSS @import for Google Fonts lives at the top of `src/index.css`
//      (browser-side load — never cached build output that could rot).
export default defineConfig({
  plugins: [vlyPlugin(), react(), tailwindcss()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  build: {
    sourcemap: false,
    assetsInlineLimit: 16384,
    rollupOptions: {
      output: {
        manualChunks: {
          "react-vendor": [
            "react",
            "react-dom",
            "react-router",
            "scheduler",
          ],
          "convex-vendor": ["convex", "@convex-dev/auth/react"],
          "radix": [
            "@radix-ui/react-dialog",
            "@radix-ui/react-dropdown-menu",
            "@radix-ui/react-tooltip",
          ],
          "motion": ["framer-motion"],
        },
        chunkFileNames: "assets/[name]-[hash].js",
        entryFileNames: "assets/[name]-[hash].js",
        assetFileNames: "assets/[name]-[hash].[ext]",
      },
    },
    chunkSizeWarningLimit: 1200,
    target: "esnext",
    minify: "esbuild",
    cssCodeSplit: false,
    modulePreload: {
      polyfill: false,
    },
    reportCompressedSize: false,
  },
  optimizeDeps: {
    include: ["react", "react-dom", "react-router", "@convex-dev/auth/react"],
  },
  // Freebuff requires HMR disabled
  server: {
    hmr: false,
  },
});
