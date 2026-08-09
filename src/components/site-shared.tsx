import { Link, useLocation } from "react-router";
import { useEffect, useState } from "react";
import { Download, Github, ExternalLink, ArrowRight, Menu, X, Package, Sparkles } from "lucide-react";

/** Shared constants — every download button on the site points here. */
export const LIVE_REPO = "https://github.com/Alot1z/packwise";
export const LIVE_RELEASES = "https://github.com/Alot1z/packwise/releases";
export const LIVE_RELEASE_LATEST = "https://github.com/Alot1z/packwise/releases/latest";
export const LIVE_RELEASE_DEV = "https://github.com/Alot1z/packwise/releases/tag/dev";
export const LIVE_ACTIONS = "https://github.com/Alot1z/packwise/actions";
export const WIKI_URL = "https://github.com/Alot1z/packwise/wiki";

export type ReleasePointer = {
  tag: string;
  sha256?: string;
  verified_by_build?: boolean;
  published_at?: string;
};

type ManifestState = "loading" | "verified" | "unavailable";

/**
 * Live release status straight from the GitHub REST API.
 *
 * Why the REST API and not `releases/download/...`? The download endpoints do
 * not send CORS headers, so a browser fetch is blocked (ERR_FAILED) and the
 * site could never show a verified state. api.github.com sends
 * `Access-Control-Allow-Origin: *` for public repos, so it works in the
 * browser. `dev` is published on every successful main push (freshest signal);
 * `latest` only exists once a v* release is published.
 *
 * Truthfulness contract: when no releases exist (or the API is unreachable),
 * the state is `unavailable` — callers must show an explicit unavailable
 * state, never pretend a download exists.
 *
 * The result is cached 5 minutes and shared across hook instances (SiteNav +
 * page + footer all call this), so one page load = one API call, well inside
 * the unauthenticated rate limit (60/hr per IP).
 */
type ManifestResult = { latest: ReleasePointer | null; dev: ReleasePointer | null };
let manifestCache: { at: number; promise: Promise<ManifestResult> } | null = null;
const MANIFEST_TTL_MS = 5 * 60 * 1000;

function fetchReleasePointers(): Promise<ManifestResult> {
  return fetch("https://api.github.com/repos/Alot1z/packwise/releases?per_page=6", { cache: "no-store" })
    .then((r) => (r.ok ? r.json() : null))
    .then((list: unknown) => {
      if (!Array.isArray(list) || list.length === 0) return { latest: null, dev: null };
      const toPointer = (rel: { tag_name: string; published_at?: string | null }): ReleasePointer => ({
        tag: rel.tag_name,
        published_at: rel.published_at ?? undefined,
      });
      // Truthfulness: a release only counts as verified if it actually carries
      // a real IPA asset (the workflow attaches it only after the publish gate
      // passes). A bare release tag with no ipa, or a broken shell, must not
      // light up the green "verified" UI.
      const hasIpa = (rel: { assets?: Array<{ name?: string; size?: number }> }) =>
        (rel?.assets ?? []).some((a) => a.name === "PackWise-unsigned.ipa" && (a.size ?? 0) > 100_000);
      const dev = list.find((r) => r?.tag_name === "dev");
      const latest = list.find((r) => r && !r.prerelease) ?? null;
      return {
        dev: dev && hasIpa(dev) ? toPointer(dev) : null,
        latest: latest && hasIpa(latest) ? toPointer(latest) : null,
      };
    })
    .catch(() => ({ latest: null, dev: null }));
}

export function useManifest() {
  const [state, setState] = useState<ManifestState>("loading");
  const [latest, setLatest] = useState<ReleasePointer | null>(null);
  const [dev, setDev] = useState<ReleasePointer | null>(null);
  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const now = Date.now();
      if (!manifestCache || now - manifestCache.at > MANIFEST_TTL_MS) {
        manifestCache = { at: now, promise: fetchReleasePointers() };
      }
      const result = await manifestCache.promise;
      if (cancelled) return;
      setDev(result.dev);
      setLatest(result.latest);
      setState(result.dev || result.latest ? "verified" : "unavailable");
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, []);
  return { state, latest, dev };
}

export const serif = { fontFamily: "Instrument Serif, Cormorant Garamond, serif" } as const;

export const NAV_LINKS = [
  { to: "/", label: "Home" },
  { to: "/features", label: "Features" },
  { to: "/download", label: "Download" },
  { to: "/build", label: "Build" },
  { to: "/docs", label: "Docs" },
  { to: "/troubleshooting", label: "Troubleshooting" },
  { to: "/changelog", label: "Changelog" },
];

function isActivePath(current: string, target: string) {
  if (target === "/") return current === "/";
  return current === target || current.startsWith(target + "/");
}

export function SiteNav() {
  const location = useLocation();
  const [open, setOpen] = useState(false);
  const manifest = useManifest();
  const ready = manifest.state === "verified";
  return (
    <>
      <a
        href="#main"
        className="sr-only focus:not-sr-only focus:fixed focus:top-2 focus:left-2 focus:z-[100] focus:px-4 focus:py-2 focus:rounded-full focus:bg-primary focus:text-primary-foreground focus:text-sm focus:font-medium focus:shadow-lg"
      >
        Skip to content
      </a>
      <nav
        aria-label="Primary"
        className="sticky top-0 z-30 backdrop-blur-xl bg-background/80 border-b border-border/60 supports-[backdrop-filter]:bg-background/70"
      >
        <div className="max-w-[1180px] mx-auto px-6 h-[58px] flex items-center gap-5">
          <Link to="/" className="flex items-center gap-2.5 shrink-0 group" aria-label="PackWise home">
            <span className="size-8 rounded-[10px] bg-primary text-primary-foreground grid place-items-center shadow-sm group-hover:shadow-md transition-shadow" aria-hidden>
              <Download className="size-4" />
            </span>
            <span className="text-[15px] font-semibold tracking-[-0.02em]" style={serif}>
              PackWise
            </span>
            <span className="hidden lg:inline-flex items-center gap-1 text-[10px] font-mono uppercase tracking-[0.12em] text-muted-foreground border border-border rounded-full px-2.5 py-0.5 ml-1">
              <Sparkles className="size-3" aria-hidden /> Docs · IPA is the product
            </span>
          </Link>

          <div className="hidden lg:flex items-center gap-0.5 text-[13px]" role="list">
            {NAV_LINKS.map((l) => {
              const active = isActivePath(location.pathname, l.to);
              return (
                <Link
                  key={l.to}
                  to={l.to}
                  aria-current={active ? "page" : undefined}
                  className={`px-2.5 py-1.5 rounded-full transition text-sm ${
                    active
                      ? "bg-secondary text-foreground font-medium shadow-sm border border-border/60"
                      : "text-muted-foreground hover:text-foreground hover:bg-secondary/70"
                  }`}
                >
                  {l.label}
                </Link>
              );
            })}
          </div>

          <div className="ml-auto flex items-center gap-2">
            <a
              href={ready ? LIVE_RELEASE_LATEST : LIVE_RELEASES}
              target="_blank"
              rel="noreferrer"
              className="hidden sm:inline-flex text-sm font-medium px-4 py-2 rounded-full bg-primary text-primary-foreground hover:opacity-90 transition items-center gap-1.5 shadow-sm hover:shadow focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
            >
              <Download className="size-3.5" aria-hidden /> {ready ? "Download IPA" : "View Releases"}
            </a>
            <a
              href={LIVE_REPO}
              target="_blank"
              rel="noreferrer"
              className="inline-flex items-center gap-1.5 text-sm font-medium px-3 py-2 rounded-full border border-border bg-card hover:bg-secondary transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
            >
              <Github className="size-3.5" aria-hidden /> <span className="hidden sm:inline">Alot1z/packwise</span>{" "}
              <ExternalLink className="size-3 opacity-60" aria-hidden />
            </a>
            <button
              type="button"
              aria-label={open ? "Close menu" : "Open menu"}
              aria-expanded={open}
              aria-controls="mobile-nav"
              onClick={() => setOpen((v) => !v)}
              className="lg:hidden inline-flex size-9 items-center justify-center rounded-full border border-border bg-card hover:bg-secondary transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
            >
              {open ? <X className="size-4" aria-hidden /> : <Menu className="size-4" aria-hidden />}
            </button>
          </div>
        </div>

        {/* Mobile drawer */}
        <div
          id="mobile-nav"
          className={`lg:hidden border-t border-border/60 overflow-hidden transition-[max-height,opacity] duration-200 ${open ? "max-h-[420px] opacity-100" : "max-h-0 opacity-0"}`}
          aria-hidden={!open}
        >
          <div className="px-6 py-4 bg-background/95 backdrop-blur">
            <div className="grid gap-1">
              {NAV_LINKS.map((l) => {
                const active = isActivePath(location.pathname, l.to);
                return (
                  <Link
                    key={l.to}
                    to={l.to}
                    onClick={() => setOpen(false)}
                    aria-current={active ? "page" : undefined}
                    className={`px-3 py-2.5 rounded-xl text-[14px] transition flex items-center justify-between ${
                      active ? "bg-secondary font-medium border border-border" : "hover:bg-secondary/60 text-muted-foreground hover:text-foreground"
                    }`}
                  >
                    {l.label} <ArrowRight className={`size-3.5 transition ${active ? "opacity-100" : "opacity-0"}`} aria-hidden />
                  </Link>
                );
              })}
            </div>
            <div className="mt-4 grid grid-cols-2 gap-2">
              <a
                href={ready ? LIVE_RELEASE_LATEST : LIVE_RELEASES}
                target="_blank"
                rel="noreferrer"
                className="inline-flex items-center justify-center gap-1.5 px-3 py-2.5 rounded-full bg-primary text-primary-foreground text-sm font-medium"
              >
                <Download className="size-4" aria-hidden /> {ready ? "Latest IPA" : "View Releases"}
              </a>
              <a
                href={LIVE_RELEASE_DEV}
                target="_blank"
                rel="noreferrer"
                className="inline-flex items-center justify-center gap-1.5 px-3 py-2.5 rounded-full border border-border bg-white text-sm font-medium"
              >
                <Package className="size-4" aria-hidden /> dev
              </a>
            </div>
            <p className="text-[11px] font-mono text-muted-foreground mt-3 text-center">
              Unsigned IPA · sideload via AltStore / Sideloadly · iOS 17+
            </p>
          </div>
        </div>
      </nav>
    </>
  );
}

export function SiteFooter() {
  const manifest = useManifest();
  const ready = manifest.state === "verified";
  return (
    <footer className="border-t border-border/70 bg-card/40">
      <div className="max-w-[1180px] mx-auto px-6 py-8 flex flex-col sm:flex-row gap-4 sm:items-center sm:justify-between text-sm text-muted-foreground">
        <span className="leading-6">
          PackWise —{" "}
          <a href={LIVE_REPO} target="_blank" rel="noreferrer" className="underline underline-offset-4 hover:text-foreground transition">
            Alot1z/packwise
          </a>{" "}
          · Native iOS is the product. This site documents the project.
          <br className="sm:hidden" />
          <span className="font-mono text-xs"> MIT · No tracking · Offline-first</span>
        </span>
        <span className="inline-flex items-center gap-2 flex-wrap">
          <a
            href={ready ? LIVE_RELEASE_LATEST : LIVE_RELEASES}
            target="_blank"
            rel="noreferrer"
            className="inline-flex items-center gap-1.5 font-medium text-foreground hover:underline underline-offset-4"
          >
            {ready ? "Download IPA" : "View Releases"} <Download className="size-4" aria-hidden />
          </a>
          <span className="text-border" aria-hidden>
            ·
          </span>
          <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="font-mono text-xs underline underline-offset-4 hover:text-foreground">
            dev
          </a>
          <span className="text-border" aria-hidden>
            ·
          </span>
          <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1 hover:text-foreground">
            Build logs <ExternalLink className="size-3" aria-hidden />
          </a>
          <span className="text-border" aria-hidden>
            ·
          </span>
          <Link to="/build" className="inline-flex items-center gap-1 hover:text-foreground">
            Build guide <ArrowRight className="size-3" aria-hidden />
          </Link>
        </span>
      </div>
      <div className="max-w-[1180px] mx-auto px-6 pb-6">
        <div className="rounded-xl border border-border bg-background p-3 flex flex-wrap items-center gap-2 text-xs text-muted-foreground">
          <span className="font-mono">PackWise-unsigned.ipa</span>
          <span className="text-border" aria-hidden>
            ·
          </span>
          <span>Validated before every publish · executable · arm64 · no test bundles</span>
          <span className="ml-auto inline-flex items-center gap-1.5">
            {ready ? (
              <>
                <span className="size-1.5 rounded-full bg-emerald-500" aria-hidden /> Verified build available
              </>
            ) : (
              <>
                <span className="size-1.5 rounded-full bg-amber-500" aria-hidden /> Status: unavailable — see{" "}
                <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="underline underline-offset-4 hover:text-foreground">
                  Actions
                </a>
              </>
            )}
          </span>
        </div>
      </div>
    </footer>
  );
}

export function SectionTitle({ kicker, title, desc }: { kicker: string; title: string; desc?: string }) {
  return (
    <div>
      <div className="text-[11px] font-mono uppercase tracking-[0.14em] text-muted-foreground">{kicker}</div>
      <h2 className="mt-2 text-[28px] sm:text-[32px] leading-none tracking-[-0.02em]" style={serif}>
        {title}
      </h2>
      {desc && <p className="mt-2.5 text-[14px] leading-6 text-muted-foreground max-w-[70ch]">{desc}</p>}
    </div>
  );
}

export function PageHeader({ kicker, title, desc }: { kicker: string; title: string; desc: string }) {
  return (
    <section id="main" className="max-w-[1180px] mx-auto px-6 pt-12 pb-8 scroll-mt-24">
      <div className="text-[11px] font-mono uppercase tracking-[0.14em] text-muted-foreground">{kicker}</div>
      <h1 className="mt-3 text-[38px] sm:text-[50px] leading-[0.95] tracking-[-0.03em]" style={serif}>
        {title}
      </h1>
      <p className="mt-4 text-[15px] leading-6 text-muted-foreground max-w-[70ch]">{desc}</p>
    </section>
  );
}
