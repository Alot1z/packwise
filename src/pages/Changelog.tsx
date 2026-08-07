import { BadgeCheck, Wrench, Box, GitBranch, ExternalLink } from "lucide-react";
import { SiteNav, SiteFooter, PageHeader, serif, LIVE_ACTIONS, LIVE_RELEASE_DEV, WIKI_URL } from "@/components/site-shared";

const entries = [
  {
    tag: "Sideload fix",
    date: "Pipeline",
    icon: Wrench,
    items: [
      "Root cause fixed: published IPA was missing its main executable (the “Failed to map …/PackWise: Bad file descriptor” sideload error).",
      "Pipeline now builds device-first (xcodebuild build -sdk iphoneos, arm64) and validates the executable before publishing: presence, non-empty, Mach-O arm64, iOS device platform (LC_BUILD_VERSION 2).",
      "Test bundles (PlugIns/*.xctest) and XCTest frameworks are stripped before packaging — never shipped in a release.",
      "XcodeGen scheme updated: test targets are test-action only; they can no longer be injected into an archived app.",
      "Strict publish gate: an IPA without Payload/PackWise.app/PackWise fails the workflow — no more broken “success”.",
      "UI tests fixed to complete onboarding before asserting tabs (tests now pass on fresh install).",
      "Direct .ipa on the dev prerelease every push to main (no outer-zip unwrap).",
    ],
  },
  {
    tag: "1.0.0",
    date: "Native iOS",
    icon: Box,
    items: [
      "Dashboard: upcoming trips, packing progress, missing essentials, recent activity, quick actions.",
      "Trips: create, edit, delete, duplicate, status flow, destination, dates, activities, climate, category, export/share as JSON.",
      "Smart packing lists: categories, quantities, packed state, essential flags, search, sort, filter.",
      "Personal item library with photos, favorites, and reuse across trips.",
      "On-device Vision scanner (VNClassifyImageRequest) with explicit user confirmation.",
      "Outfit planner per trip day, composed from packed items.",
      "Global local search across trips, items, outfits, library, templates.",
      "Starter + custom templates, apply to any trip.",
      "Local reminders via UserNotifications.",
      "SwiftData persistence, offline-first, no login, no cloud, no tracking.",
    ],
  },
  {
    tag: "Infrastructure",
    date: "CI / Release",
    icon: GitBranch,
    items: [
      "GitHub Actions (macos-15) + Gitea Actions mirror + local ios/build.sh — same validated artifact on every host.",
      "Artifact upload (debug) + dev prerelease on every main push + versioned Release on tag v*.",
      "sha256 published alongside every .ipa.",
      "Non-blocking tests: a flaky test can never block the IPA.",
      "Wiki (9 pages) + README with programmatic 3D SVG art — assets/ shared between README and this site.",
    ],
  },
];

export default function Changelog() {
  return (
    <div className="min-h-screen bg-background text-foreground">
      <SiteNav />
      <PageHeader
        kicker="Changelog"
        title="What changed, and when"
        desc="Version history with honest status. The most important entry is the sideload fix — it explains why earlier IPAs failed to install and what changed."
      />

      <section className="max-w-[960px] mx-auto px-6 pb-10 space-y-6">
        {entries.map((e) => (
          <div key={e.tag} className="rounded-2xl border border-border bg-card p-5 sm:p-6">
            <div className="flex flex-wrap items-center gap-3">
              <div className="size-9 rounded-xl bg-secondary grid place-items-center border border-border/50"><e.icon className="size-[18px]" /></div>
              <div className="font-mono text-sm font-semibold">{e.tag}</div>
              <div className="text-xs text-muted-foreground font-mono">{e.date}</div>
              {e.tag === "Sideload fix" && (
                <span className="ml-auto inline-flex items-center gap-1.5 text-[10px] font-mono uppercase tracking-widest px-2.5 py-1 rounded-full border border-emerald-300 bg-emerald-50 text-emerald-700">
                  <BadgeCheck className="size-3" /> Live in pipeline
                </span>
              )}
            </div>
            <ul className="mt-4 space-y-2">
              {e.items.map((i) => (
                <li key={i} className="flex gap-2.5 text-[13.5px] leading-[22px] text-muted-foreground">
                  <span className="text-[oklch(0.62_0.115_38)] mt-0.5">▸</span>
                  <span>{i}</span>
                </li>
              ))}
            </ul>
          </div>
        ))}

        <div className="rounded-2xl border border-dashed border-border bg-card p-5 flex flex-wrap items-center gap-4 text-sm text-muted-foreground">
          <span>Latest build: <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="font-medium text-foreground underline underline-offset-4">releases/tag/dev</a></span>
          <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 hover:text-foreground">Live build logs <ExternalLink className="size-3" /></a>
          <a href={`${WIKI_URL}/Changelog`} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 hover:text-foreground">Wiki changelog <ExternalLink className="size-3" /></a>
        </div>
      </section>

      <SiteFooter />
    </div>
  );
}
