import { Link } from "react-router";
import { Download, Github, ExternalLink, ArrowRight } from "lucide-react";

/** Shared constants — every download button on the site points here. */
export const LIVE_REPO = "https://github.com/Alot1z/packwise";
export const LIVE_RELEASES = "https://github.com/Alot1z/packwise/releases";
export const LIVE_RELEASE_LATEST = "https://github.com/Alot1z/packwise/releases/latest";
export const LIVE_RELEASE_DEV = "https://github.com/Alot1z/packwise/releases/tag/dev";
export const LIVE_ACTIONS = "https://github.com/Alot1z/packwise/actions";
export const WIKI_URL = "https://github.com/Alot1z/packwise/wiki";

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

export function SiteNav() {
  return (
    <nav className="sticky top-0 z-30 backdrop-blur-xl bg-background/80 border-b border-border/60">
      <div className="max-w-[1180px] mx-auto px-6 h-[58px] flex items-center gap-5">
        <Link to="/" className="flex items-center gap-2.5 shrink-0">
          <span className="size-8 rounded-[10px] bg-primary text-primary-foreground grid place-items-center">
            <Download className="size-4" />
          </span>
          <span className="text-[15px] font-semibold tracking-[-0.02em]" style={serif}>PackWise</span>
          <span className="hidden lg:inline text-[10px] font-mono uppercase tracking-[0.12em] text-muted-foreground border border-border rounded-full px-2.5 py-0.5 ml-1">
            Docs · IPA is the product
          </span>
        </Link>
        <div className="hidden lg:flex items-center gap-0.5 text-[13px]">
          {NAV_LINKS.map((l) => (
            <Link key={l.to} to={l.to} className="px-2.5 py-1.5 rounded-full hover:bg-secondary transition text-muted-foreground hover:text-foreground">
              {l.label}
            </Link>
          ))}
        </div>
        <div className="ml-auto flex items-center gap-2">
          <a
            href={LIVE_RELEASE_LATEST}
            target="_blank"
            rel="noreferrer"
            className="hidden sm:inline-flex text-sm font-medium px-4 py-2 rounded-full bg-primary text-primary-foreground hover:opacity-90 transition items-center gap-1.5"
          >
            <Download className="size-3.5" /> Download IPA
          </a>
          <a
            href={LIVE_REPO}
            target="_blank"
            rel="noreferrer"
            className="inline-flex items-center gap-1.5 text-sm font-medium px-3 py-2 rounded-full border border-border bg-card hover:bg-secondary transition"
          >
            <Github className="size-3.5" /> <span className="hidden sm:inline">Alot1z/packwise</span> <ExternalLink className="size-3" />
          </a>
        </div>
      </div>
    </nav>
  );
}

export function SiteFooter() {
  return (
    <footer className="border-t border-border/70">
      <div className="max-w-[1180px] mx-auto px-6 py-8 flex flex-wrap items-center justify-between gap-4 text-sm text-muted-foreground">
        <span>
          PackWise — <a href={LIVE_REPO} target="_blank" rel="noreferrer" className="underline underline-offset-4">Alot1z/packwise</a> · Native iOS is the product. This site documents the project.
        </span>
        <span className="inline-flex items-center gap-2 flex-wrap">
          <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 font-medium text-foreground">
            Download IPA <Download className="size-4" />
          </a>
          <span className="text-border">·</span>
          <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="font-mono text-xs underline underline-offset-4">dev</a>
          <span className="text-border">·</span>
          <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1">Build logs <ExternalLink className="size-3" /></a>
          <span className="text-border">·</span>
          <Link to="/build" className="inline-flex items-center gap-1">Build guide <ArrowRight className="size-3" /></Link>
        </span>
      </div>
    </footer>
  );
}

export function SectionTitle({ kicker, title, desc }: { kicker: string; title: string; desc?: string }) {
  return (
    <div>
      <div className="text-[11px] font-mono uppercase tracking-[0.14em] text-muted-foreground">{kicker}</div>
      <h2 className="mt-2 text-[28px] sm:text-[32px] leading-none tracking-[-0.02em]" style={serif}>{title}</h2>
      {desc && <p className="mt-2.5 text-[14px] leading-6 text-muted-foreground max-w-[70ch]">{desc}</p>}
    </div>
  );
}

export function PageHeader({ kicker, title, desc }: { kicker: string; title: string; desc: string }) {
  return (
    <section className="max-w-[1180px] mx-auto px-6 pt-12 pb-8">
      <div className="text-[11px] font-mono uppercase tracking-[0.14em] text-muted-foreground">{kicker}</div>
      <h1 className="mt-3 text-[38px] sm:text-[50px] leading-[0.95] tracking-[-0.03em]" style={serif}>{title}</h1>
      <p className="mt-4 text-[15px] leading-6 text-muted-foreground max-w-[70ch]">{desc}</p>
    </section>
  );
}
