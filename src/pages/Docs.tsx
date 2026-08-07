import { BookOpen, Cpu, Database, Shield, ExternalLink, HardDrive, FileCode2, GitBranch, ArrowRight } from "lucide-react";
import { SiteNav, SiteFooter, PageHeader, serif, WIKI_URL, LIVE_REPO, LIVE_RELEASES } from "@/components/site-shared";

const wikiPages = [
  { title: "Home", desc: "Project overview, philosophy, and quick orientation.", href: `${WIKI_URL}` },
  { title: "Installation", desc: "From sideloading the IPA to building from source.", href: `${WIKI_URL}/Installation` },
  { title: "Features", desc: "Every capability, explained in detail.", href: `${WIKI_URL}/Features` },
  { title: "Architecture", desc: "MVVM layering, services, and the navigation graph.", href: `${WIKI_URL}/Architecture` },
  { title: "Data Models", desc: "SwiftData schema: Trip, PackingItem, Outfit, Template and more.", href: `${WIKI_URL}/Data-Models` },
  { title: "Vision and Privacy", desc: "How on-device Vision works and what never leaves the phone.", href: `${WIKI_URL}/Vision-and-Privacy` },
  { title: "Build and Release", desc: "The IPA pipeline, validation, and release process.", href: `${WIKI_URL}/Build-and-Release` },
  { title: "Troubleshooting", desc: "Known issues and fixes — including sideload errors.", href: `${WIKI_URL}/Troubleshooting` },
  { title: "Changelog", desc: "Version history and notable fixes.", href: `${WIKI_URL}/Changelog` },
];

const pillars = [
  {
    icon: Shield,
    title: "Privacy model",
    desc: "No accounts, no tracking, no telemetry. All data stays in SwiftData on your device. Vision analysis never leaves the phone.",
  },
  {
    icon: HardDrive,
    title: "Offline-first",
    desc: "The app is fully usable without a network. Local storage, local notifications, local recommendations.",
  },
  {
    icon: Cpu,
    title: "On-device intelligence",
    desc: "Rule-based suggestions and Apple Vision classification run locally. No external AI APIs, no paid services.",
  },
  {
    icon: Database,
    title: "Backup-safe data",
    desc: "SwiftData models with automatic migration. Export any trip as JSON to move or share it.",
  },
];

export default function Docs() {
  return (
    <div className="min-h-screen bg-background text-foreground">
      <SiteNav />
      <main id="main">
        <PageHeader
          kicker="Documentation"
          title="Read the docs — understand the build"
          desc="PackWise is an open-source, self-hostable project. The GitHub Wiki is the canonical documentation; the pages below are mirrored here for quick access. The IPA remains the product."
        />

        <section className="max-w-[1180px] mx-auto px-6 pb-10">
          <div className="grid md:grid-cols-2 gap-4">
            {pillars.map((p) => (
              <div key={p.title} className="rounded-2xl border border-border bg-card p-5">
                <div className="size-9 rounded-xl bg-secondary grid place-items-center border border-border/50">
                  <p.icon className="size-[18px]" aria-hidden />
                </div>
                <div className="font-semibold mt-3.5 text-[15px]" style={serif}>
                  {p.title}
                </div>
                <div className="text-[13.5px] leading-[22px] text-muted-foreground mt-1.5">{p.desc}</div>
              </div>
            ))}
          </div>

          <div className="mt-10">
            <div className="text-[11px] font-mono uppercase tracking-[0.14em] text-muted-foreground">GitHub Wiki</div>
            <h2 className="mt-2 text-[28px] sm:text-[32px] leading-none tracking-[-0.02em]" style={serif}>
              Wiki pages
            </h2>
            <p className="text-sm text-muted-foreground mt-2">Nine pages, synced from <span className="font-mono">wiki/</span> on every push to main.</p>
          </div>
          <div className="mt-6 grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {wikiPages.map((w) => (
              <a
                key={w.title}
                href={w.href}
                target="_blank"
                rel="noreferrer"
                className="group rounded-2xl border border-border bg-card p-5 hover:shadow-[0_8px_30px_-12px_oklch(0.3_0.05_42/0.2)] hover:-translate-y-0.5 transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
              >
                <div className="flex items-center justify-between">
                  <BookOpen className="size-4 text-muted-foreground" aria-hidden />
                  <ExternalLink
                    className="size-3.5 text-muted-foreground opacity-0 group-hover:opacity-100 group-focus-visible:opacity-100 transition"
                    aria-hidden
                  />
                </div>
                <div className="font-semibold mt-3 text-[15px]" style={serif}>
                  {w.title}
                </div>
                <div className="text-[13px] leading-[20px] text-muted-foreground mt-1">{w.desc}</div>
                <div className="mt-3 inline-flex items-center gap-1 text-xs font-medium text-muted-foreground group-hover:text-foreground">
                  Open <ArrowRight className="size-3" aria-hidden />
                </div>
              </a>
            ))}
          </div>

          <div className="mt-8 rounded-2xl border border-border bg-card p-5 flex flex-wrap items-center gap-x-6 gap-y-3 text-sm text-muted-foreground">
            <a
              href={LIVE_REPO}
              target="_blank"
              rel="noreferrer"
              className="inline-flex items-center gap-2 hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring rounded-full px-1"
            >
              <GitBranch className="size-4" aria-hidden /> Source: Alot1z/packwise
            </a>
            <a
              href={LIVE_RELEASES}
              target="_blank"
              rel="noreferrer"
              className="inline-flex items-center gap-2 hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring rounded-full px-1"
            >
              <FileCode2 className="size-4" aria-hidden /> Releases & artifacts
            </a>
            <a
              href={`${WIKI_URL}/Architecture`}
              target="_blank"
              rel="noreferrer"
              className="inline-flex items-center gap-2 hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring rounded-full px-1"
            >
              <Cpu className="size-4" aria-hidden /> Architecture deep dive
            </a>
            <span className="ml-auto text-xs font-mono">MIT license · No paid APIs · Self-hostable</span>
          </div>
        </section>
      </main>

      <SiteFooter />
    </div>
  );
}
