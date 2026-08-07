import { Toaster } from "@/components/ui/sonner";
import { RequireAuth } from "@/components/RequireAuth";
import { InstrumentationProvider } from "@/instrumentation.tsx";
import { ConvexAuthProvider } from "@convex-dev/auth/react";
import { ConvexReactClient } from "convex/react";
import React, { StrictMode, useEffect, lazy, Suspense, useState } from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter, Route, Routes, useLocation } from "react-router";
import Landing from "./pages/Landing.tsx";
import Setup from "./pages/Setup.tsx";
import Features from "./pages/Features.tsx";
import Download from "./pages/Download.tsx";
import Docs from "./pages/Docs.tsx";
import Troubleshooting from "./pages/Troubleshooting.tsx";
import Changelog from "./pages/Changelog.tsx";
import "./index.css";
import "./types/global.d.ts";

// Vly side-effect is optional — never let it crash prod
void import("@vly-ai/integrations").catch(() => null);

// Keep heavy pages lazy, but docs pages eager so "/" never needs a lazy chunk fetch
// (fixes stale-deploy "text/html is not valid JS MIME for Landing-*.js")
const AuthPage = lazy(() => import("./pages/Auth.tsx"));
const Dashboard = lazy(() => import("./pages/Dashboard.tsx"));
const NotFound = lazy(() => import("./pages/NotFound.tsx"));

function RouteLoading() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-background">
      <div className="flex flex-col items-center gap-3">
        <div className="size-8 rounded-full border-2 border-muted-foreground/20 border-t-foreground/60 animate-spin" />
        <div className="text-sm text-muted-foreground">Loading PackWise…</div>
      </div>
    </div>
  );
}

function MaybeVlyToolbar() {
  const [Comp, setComp] = useState<React.ComponentType | null>(null);
  useEffect(() => {
    let cancelled = false;
    import(/* @vite-ignore */ "../vly-toolbar-readonly.tsx")
      .then((m: unknown) => {
        if (cancelled) return;
        const mod = m as Record<string, unknown>;
        const C =
          (mod.VlyToolbar as React.ComponentType) ??
          (mod.default as React.ComponentType) ??
          null;
        if (C) setComp(() => C);
      })
      .catch(() => {});
    return () => {
      cancelled = true;
    };
  }, []);
  if (!Comp) return null;
  return <Comp />;
}

const convexUrl = import.meta.env.VITE_CONVEX_URL as string | undefined;
const convex = convexUrl ? new ConvexReactClient(convexUrl) : null;

function RouteSyncer() {
  const location = useLocation();
  useEffect(() => {
    window.parent.postMessage({ type: "iframe-route-change", path: location.pathname }, "*");
  }, [location.pathname]);
  useEffect(() => {
    function handleMessage(event: MessageEvent) {
      if (event.data?.type === "navigate") {
        if (event.data.direction === "back") window.history.back();
        if (event.data.direction === "forward") window.history.forward();
      }
    }
    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);
  return null;
}

function AppRoutes() {
  return (
    <Routes>
      <Route path="/" element={<Landing />} />
      <Route path="/setup" element={<Setup />} />
      <Route path="/build" element={<Setup />} />
      <Route path="/features" element={<Features />} />
      <Route path="/download" element={<Download />} />
      <Route path="/docs" element={<Docs />} />
      <Route path="/troubleshooting" element={<Troubleshooting />} />
      <Route path="/changelog" element={<Changelog />} />
      <Route
        path="/auth"
        element={
          <Suspense fallback={<RouteLoading />}>
            <AuthPage redirectAfterAuth="/dashboard" />
          </Suspense>
        }
      />
      <Route
        path="/dashboard"
        element={
          <Suspense fallback={<RouteLoading />}>
            <RequireAuth>
              <Dashboard />
            </RequireAuth>
          </Suspense>
        }
      />
      <Route
        path="*"
        element={
          <Suspense fallback={<RouteLoading />}>
            <NotFound />
          </Suspense>
        }
      />
    </Routes>
  );
}

function ChunkErrorFallback({ error, reset }: { error: Error; reset: () => void }) {
  const isChunkError =
    /Failed to fetch dynamically imported module|Importing a module script failed|MIME type|ChunkLoadError/i.test(
      error.message,
    );
  return (
    <div className="min-h-screen flex items-center justify-center p-6 bg-background">
      <div className="max-w-[520px] w-full rounded-2xl border border-border bg-card p-6 text-center">
        <div className="text-lg font-semibold">PackWise is updating</div>
        <p className="text-sm text-muted-foreground mt-2">
          {isChunkError
            ? "A new version was just deployed and your browser cached an old chunk. Hard-refresh (Ctrl+Shift+R) to load the fresh app."
            : error.message}
        </p>
        <div className="mt-5 flex justify-center gap-3">
          <button
            onClick={() => {
              reset();
              window.location.reload();
            }}
            className="px-5 py-2.5 rounded-full bg-primary text-primary-foreground text-sm font-medium"
          >
            Reload
          </button>
          <a href="/" className="px-5 py-2.5 rounded-full border border-border bg-white text-sm font-medium">
            Go home
          </a>
        </div>
      </div>
    </div>
  );
}

class AppErrorBoundary extends React.Component<
  { children: React.ReactNode },
  { hasError: boolean; error: Error | null }
> {
  constructor(props: { children: React.ReactNode }) {
    super(props);
    this.state = { hasError: false, error: null };
  }
  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }
  componentDidCatch(error: Error) {
    console.error("App chunk error", error);
  }
  render() {
    if (this.state.hasError && this.state.error) {
      return (
        <ChunkErrorFallback
          error={this.state.error}
          reset={() => this.setState({ hasError: false, error: null })}
        />
      );
    }
    return this.props.children;
  }
}

const rootEl = document.getElementById("root");
if (!rootEl) throw new Error("Root element not found");

function App() {
  const inner = (
    <BrowserRouter>
      <RouteSyncer />
      <AppErrorBoundary>
        <AppRoutes />
      </AppErrorBoundary>
      <Toaster />
    </BrowserRouter>
  );
  if (convex) {
    return <ConvexAuthProvider client={convex}>{inner}</ConvexAuthProvider>;
  }
  return inner;
}

createRoot(rootEl).render(
  <StrictMode>
    <Suspense fallback={null}>
      <MaybeVlyToolbar />
    </Suspense>
    <InstrumentationProvider>
      <App />
    </InstrumentationProvider>
  </StrictMode>,
);
