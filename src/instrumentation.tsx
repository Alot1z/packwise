import { Button } from "@/components/ui/button";
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from "@/components/ui/collapsible";
import {
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Dialog } from "@radix-ui/react-dialog";
import { ChevronDown, ExternalLink } from "lucide-react";
import React, { useEffect, useState } from "react";

type SyncError = {
  error: string;
  stack: string;
  filename: string;
  lineno: number;
  colno: number;
};

type AsyncError = {
  error: string;
  stack: string;
};

type GenericError = SyncError | AsyncError;

async function reportErrorToVly(errorData: {
  error: string;
  stackTrace?: string;
  filename?: string;
  lineno?: number;
  colno?: number;
}) {
  if (!import.meta.env.VITE_VLY_APP_ID) return;
  try {
    await fetch(import.meta.env.VITE_VLY_MONITORING_URL as string, {
      method: "POST",
      body: JSON.stringify({
        ...errorData,
        url: window.location.href,
        projectSemanticIdentifier: import.meta.env.VITE_VLY_APP_ID,
      }),
    });
  } catch {
    // never throw from reporting
  }
}

function isChunkLoadError(msg: string) {
  return /Failed to fetch dynamically imported module|Importing a module script failed|MIME type|ChunkLoadError|Loading chunk/i.test(
    msg,
  );
}

function ErrorDialog({
  error,
  setError,
}: {
  error: GenericError;
  setError: (error: GenericError | null) => void;
}) {
  const isChunk = isChunkLoadError(error.error + " " + error.stack);
  return (
    <Dialog
      defaultOpen={true}
      onOpenChange={() => {
        setError(null);
      }}
    >
      <DialogContent className={isChunk ? "bg-card text-foreground max-w-[520px]" : "bg-red-700 text-white max-w-4xl"}>
        <DialogHeader>
          <DialogTitle>{isChunk ? "PackWise is updating" : "Runtime Error"}</DialogTitle>
        </DialogHeader>
        {isChunk ? (
          <div className="text-sm leading-6 text-muted-foreground">
            A new version was just deployed and your browser cached an old chunk. Hard-refresh with
            <span className="font-mono text-foreground"> Ctrl+Shift+R</span> (or add <span className="font-mono">?v=1</span> to the URL).
            The preview is rebuilding — reload in a few seconds.
          </div>
        ) : (
          <div className="text-sm opacity-90">A runtime error occurred. Open the editor to debug.</div>
        )}
        <div className="mt-4">
          <Collapsible>
            <CollapsibleTrigger>
              <div className="flex items-center font-bold cursor-pointer text-sm">
                See error details <ChevronDown className="ml-1 size-4" />
              </div>
            </CollapsibleTrigger>
            <CollapsibleContent className="max-w-[520px]">
              <div className="mt-2 p-3 bg-neutral-900 rounded text-white text-sm overflow-x-auto max-h-60 max-w-full">
                <pre className="whitespace-pre-wrap break-words text-xs leading-5">{error.stack || error.error}</pre>
              </div>
            </CollapsibleContent>
          </Collapsible>
        </div>
        <DialogFooter>
          {isChunk ? (
            <Button onClick={() => window.location.reload()}>Reload</Button>
          ) : (
            <a href={`https://freebuff.com/project/${import.meta.env.VITE_VLY_APP_ID}`} target="_blank" rel="noreferrer">
              <Button>
                <ExternalLink className="mr-2 size-4" /> Open editor
              </Button>
            </a>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

type ErrorBoundaryState = { hasError: boolean; error: GenericError | null };

class ErrorBoundary extends React.Component<{ children: React.ReactNode }, ErrorBoundaryState> {
  constructor(props: { children: React.ReactNode }) {
    super(props);
    this.state = { hasError: false, error: null };
  }
  static getDerivedStateFromError() {
    return { hasError: true };
  }
  componentDidCatch(error: Error, info: React.ErrorInfo) {
    reportErrorToVly({ error: error.message, stackTrace: error.stack });
    this.setState({
      hasError: true,
      error: { error: error.message, stack: info.componentStack ?? error.stack ?? "" },
    });
  }
  render() {
    if (this.state.hasError) return <ErrorDialog error={this.state.error ?? { error: "An error occurred", stack: "" }} setError={() => {}} />;
    return this.props.children;
  }
}

export function InstrumentationProvider({ children }: { children: React.ReactNode }) {
  const [error, setError] = useState<GenericError | null>(null);
  useEffect(() => {
    const handleError = async (event: ErrorEvent) => {
      // Don't block the UI with chunk errors — main.tsx AppErrorBoundary handles them nicer
      if (isChunkLoadError(event.message)) {
        event.preventDefault();
        return;
      }
      setError({
        error: event.message,
        stack: (event.error as Error | undefined)?.stack || "",
        filename: event.filename || "",
        lineno: event.lineno,
        colno: event.colno,
      });
      if (import.meta.env.VITE_VLY_APP_ID) {
        await reportErrorToVly({
          error: event.message,
          stackTrace: (event.error as Error | undefined)?.stack,
          filename: event.filename,
          lineno: event.lineno,
          colno: event.colno,
        });
      }
    };
    const handleRejection = async (event: PromiseRejectionEvent) => {
      const msg = (event.reason as Error | undefined)?.message ?? String(event.reason ?? "");
      if (isChunkLoadError(msg)) {
        event.preventDefault?.();
        return;
      }
      setError({ error: msg, stack: (event.reason as Error | undefined)?.stack ?? "" });
      if (import.meta.env.VITE_VLY_APP_ID) {
        await reportErrorToVly({ error: msg, stackTrace: (event.reason as Error | undefined)?.stack });
      }
    };
    window.addEventListener("error", handleError);
    window.addEventListener("unhandledrejection", handleRejection);
    return () => {
      window.removeEventListener("error", handleError);
      window.removeEventListener("unhandledrejection", handleRejection);
    };
  }, []);
  return (
    <>
      <ErrorBoundary>{children}</ErrorBoundary>
      {error && <ErrorDialog error={error} setError={setError} />}
    </>
  );
}
