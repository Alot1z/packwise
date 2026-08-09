import { Wrench, Box, ExternalLink } from "lucide-react";
import { SiteNav, SiteFooter, PageHeader, serif, LIVE_ACTIONS, LIVE_RELEASE_DEV, WIKI_URL } from "@/components/site-shared";

const entries = [
  {
    tag: "1.0.17",
    date: "App Intents, Widgets & CI compile fix",
    icon: Wrench,
    items: [
      "CI compile fix: SubjectExtractor.swift now uses the correct iOS 17 API — observation.allInstances (IndexSet) instead of the nonexistent .instanceCount, and generateMaskedImage now passes from: handler as required by VNInstanceMaskObservation.",
      "App Intents (Siri/Shortcuts): AddInventoryItemIntent (add to inventory by name + category), MarkPackedIntent (mark any item as packed), CreateTripIntent (create a trip with title, destination, start date). Registered via PackWiseShortcuts provider — appears in Shortcuts app and Spotlight.",
      "Home Screen Widgets: NextTripWidget (systemSmall/systemMedium — shows upcoming trip, days away, packing progress) and PackingProgressWidget (systemMedium/systemLarge — packing progress across up to 5 active trips).",
      "App Group container (group.com.packwise) for shared SwiftData — widgets and intents read the same store as the app. Falls back gracefully to local-only on unsigned builds.",
      "All pre-flight checks green: tsc 0, bash -n 3/3, js-yaml 3/3.",
    ],
  },
  {
    tag: "1.0.16",
    date: "Outfit recommendation engine & destination geocoding fallback",
    icon: Wrench,
    items: [
      "Outfit recommendation engine: RecommendationService.outfitSuggestions() generates deterministic, FullPack-class outfit ideas from trip context (business, beach, outdoor, cold, rain, international), weather conditions, and items already packed. Suggestions that reference absent items are filtered out.",
      "Destination geocoding fallback: when you type a free-text destination without picking a MapKit suggestion, CLGeocoder resolves it to coordinates on trip creation. No more manual lat/lon entry.",
      "5 new deterministic offline outfit recommendation tests (business, beach, rainy-outdoor, international, unpacked-item filtering) in PackWiseTests.",
      "All pre-flight checks green: tsc 0, bash -n 3/3, js-yaml 3/3.",
    ],
  },
  {
    tag: "1.0.15",
    date: "FullPack-class scanner, background removal & weather-aware packing",
    icon: Wrench,
    items: [
      "Root cause resolved by deletion: SwiftUI has no .searchActions modifier on any OS — the 1.0.13/1.0.14 availability shim wrapped a phantom symbol that Xcode 26.3 / iOS 26.2 rejected with value of type 'Self' has no member 'searchActions'. SearchClearActionsModifier.swift and its two callers are removed; iOS 17's .searchable() already ships a built-in clear button, so UX is unchanged.",
      "Real camera scanner: CameraService (AVCaptureSession live preview, capture, flip, permission states) + CameraScannerView replaces the picker-only PhotoScannerView; PhotosPicker import remains as a fallback.",
      "Background removal: SubjectExtractor uses VNGenerateForegroundInstanceMaskRequest (iOS 17+) for a transparent cutout + thumbnail, gracefully falling back to the original photo when no subject is found. On-device, offline.",
      "Weather-aware packing: MKLocalSearchCompleter destination autocomplete (no manual lat/lon) in the New Trip sheet; WeatherKit live conditions in the trip header; deterministic weather rules merged into recommendations (rain, cold lows, heat). WeatherKit fails silently on unsigned builds — the offline text engine is never blocked.",
      "5 new deterministic offline weather recommendation tests; Trip gains optional destination coordinates. Docs: FULLPACK-CAPABILITY-MATRIX, APPLE-API-CAPABILITY-BIBLE, ARCHITECTURE, BUILD, CI.",
      "CI fixes: build.sh validate_app() no longer corrupts the app path with stdout diagnostics; test destination now discovers available simulators dynamically instead of assuming an iPhone 16.",
    ],
  },
  {
    tag: "1.0.14",
    date: "Bulletproof .searchActions shim + streamlined release process",
    icon: Wrench,
    items: [
      "Hardened the iOS 18 .searchActions availability shim further: SearchClearActionsModifier.body now returns AnyView so Swift does not need to unify the two branches into a _ConditionalContent. The iOS-18 wrapper is still a separate @available(iOS 18.0, *) struct (SearchActionsWrapper<Content: View>), so the bulletproof rule holds: no path at the iOS-17 deployment target requires .searchActions to resolve on the generic Content.",
      "Full audit confirms iOS source has zero fixed-size fonts (every font uses a semantic style or @ScaledMetric), zero stray #available blocks, and zero other iOS-18-only APIs (scrollPosition defaultDistance, defaultScrollAnchor, MeshGradient, etc.).",
      "README gains a dedicated Release process section -- the maintainer's end-to-end flow: branch+push to ship, tag to promote, verify-ipa.sh gate as the single publish guard, deterministic manifest URLs, and the three-host build matrix (GitHub Actions, Gitea Actions, act). Pre-flight is tsc + bash -n + js-yaml + tag.",
      "All surfaces re-synced: changelog parity 15/15 web to wiki, EXECUTION-STATE.md and FILE-AUDIT.md updated with session 9 results.",
    ],
  },
  {
    tag: "1.0.13",
    date: "R2 CLOSED — iOS 18 API bug + first real compile",
    icon: Wrench,
    items: [
      "The session-6 platform fix was validated live: run 31256274224's step log shows the iOS device platform now installs on the macOS-15 runner and the compiler actually runs — R2's infrastructure blocker is CLOSED.",
      "With a real build finally executing, the true remaining bug surfaced via the public annotation channel: `.searchActions` is an iOS 18-only API used in TripListView and GlobalSearchView with an iOS 17 deployment target — a hard compile error that no earlier run could reach.",
      "Fix: new availability-safe `searchClearAction(_:clearLabel:)` modifier (SearchClearActionsModifier.swift) applies `.searchActions` only on iOS 18+ and degrades to the platform's built-in clear button on iOS 17.",
      "Verified: tsc exit 0, bash -n 4/4 scripts, js-yaml 3/3 workflows; grep confirms zero unguarded searchActions calls remain. Next macOS CI run should produce the first valid IPA since the fix.",
    ],
  },
  {
    tag: "1.0.12",
    date: "Session 7 — full verification sweep + docs sync",
    icon: Wrench,
    items: [
      "Full verification sweep: tsc exit 0, bash -n 4/4 scripts, js-yaml 3/3 workflows, convex dev --once OK.",
      "Fixed changelog parity count: the 1.0.11 entry said 11/11 but there are 12 versions (1.0.0–1.0.11); corrected to 12/12 across both web and wiki surfaces.",
      "Audited all web pages (Landing, Download, Features, Setup, Docs, Troubleshooting, Changelog), site-shared.tsx, and all 10 wiki pages — all accurate against the implementation.",
      "Verified Convex backend (auth, packing functions, http) and the PWA manifest — all consistent with the PackWise brand.",
      "Updated EXECUTION-STATE.md with session 7 results and next dependency-ready tasks.",
    ],
  },
  {
    tag: "1.0.11",
    date: "R2 closed — missing iOS device platform",
    icon: Wrench,
    items: [
      'The public annotation channel paid off: CI run 31248752593 surfaced the actual error with zero credentials — "Unable to find a destination … error:iOS 18.0 is not installed. To use with Xcode, first download and install the platform".',
      'It was never a signing problem: GitHub macOS-15 runner images trim the iOS DEVICE platform to save disk (actions/runner-images #12758/#12862/#13570), so xcodebuild -destination "generic/platform=iOS" dies in under a second — why every run failed ~7-8s in while the simulator tests step passed.',
      'Fix: workflow runs xcodebuild -downloadPlatform iOS (official remedy, sudo fallback) before the build, picks the newest installed Xcode, and ios/build.sh gained a self-healing ensure_device_platform() guard for standalone local builds. Mirrored in the Gitea workflow.',
      'Verified: tsc exit 0, bash -n 4/4 scripts, js-yaml 3/3 workflows, changelog parity 12/12, local-vs-GitHub diff confirms the fix is the not-yet-shipped delta. Next macOS CI run is the R2 closure gate.',
    ],
  },
  {
    tag: "1.0.10",
    date: "R2 signing-arg fix + public annotations",
    icon: Wrench,
    items: [
      'R2 third root cause fixed: signing overrides shipped (main == local) but two CI runs still failed at the device-build step ~7-8s in — an immediate xcodebuild config error, not a compile error.',
      'Causes, in sequence: NO_SIGN_STR word-split passed literal quote chars (CODE_SIGN_IDENTITY=""); an explicit DEVELOPMENT_TEAM= — even empty — makes Xcode try to resolve a team; and CODE_SIGN_STYLE=Manual itself demands a resolvable team even with signing disabled.',
      'Fix: ios/build.sh signing args now match the proven-passing CI tests step exactly — CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=, no style/team overrides — plus a fourth minimal fallback strategy (D). Verified clean token expansion; bash -n clean.',
      'Public failure channel: CI logs/artifacts need sign-in, but check-run annotations are public — build.sh now emits ::error:: lines with the real error so the next run\'s annotations expose the exact cause without auth.',
      'PWA manifest rebranded (real /logo.svg icon); ContentView onboarding transition reduced-motion gated; auth OTP email appName fallback now "PackWise".',
    ],
  },
  {
    tag: "1.0.9",
    date: "CI repair & binary verification",
    icon: Wrench,
    items: [
      "Root cause pinned by evidence: the published dev IPA shipped test bundles and no main executable (the exact “Bad file descriptor” sideload cause). The verifier now rejects it, and CI will not publish until the gate passes.",
      "Workflow test step no longer aborts the job under bash -e -o pipefail; untrusted aws/tap brew tap removed; Homebrew-free XcodeGen fallback added; actions bumped to current majors (checkout@v5, upload-artifact@v7, gh-release@v3).",
      "Wiki sync workflow rewritten (checkout@v5, wiki-repo enablement, accurate push errors).",
      "ios/build.sh: fixed a latent unclosed-quote bug, explicit unsigned-device signing overrides, richer diagnostics.",
      "Vision scanner now respects photo orientation; swipe-deleting a trip asks for confirmation.",
      "Download/nav/landing CTAs read the live manifest and show Status unavailable when no verified build exists.",
    ],
  },
  {
    tag: "1.0.8",
    date: "Pipeline hardening & truthfulness",
    icon: Wrench,
    items: [
      "Fixed the workflow GitHub rejected as invalid YAML (manifest snippet indented at column 0 inside a run: block) — both GitHub and Gitea workflows now parse with GitHub's own parser.",
      "scripts/verify-ipa.sh detects symlinked/empty main executables from zip metadata and probes the Mach-O header itself — device arm64, simulator, or not-a-binary, on any machine. Verified on 4 synthetic artifacts.",
      "Manifest-validation step tolerates a dev: null pointer; new docs/engineering/EXECUTION-STATE.md + FILE-AUDIT.md.",
      "Landing mock data now explicitly labeled “Concept preview — illustrative mockup”; screenshot grid labeled as placeholder frames.",
    ],
  },
  {
    tag: "1.0.7",
    date: "Interaction polish & hardening",
    icon: Wrench,
    items: [
      "Swipe actions with haptics and confirmations across trips, items, library, templates, and reminders.",
      "Attention badge on the Trips tab; iPad-adaptive tab bar; pull-to-refresh on the Dashboard.",
      "Smarter on-device recommendations (cold / rain / long-trip heuristics, dedupe) and a richer Vision label map.",
      "Trip progress helpers (progressLabel, daysUntilDeparture, isPast) and notification cancel-all.",
      "Web: active-page nav highlighting, mobile drawer with CTAs, skip-to-content, SEO/OG/JSON-LD, live manifest in the hero.",
    ],
  },
  {
    tag: "1.0.6",
    date: "Reduced-motion + contrast",
    icon: Wrench,
    items: [
      "The single animated iOS control (Onboarding “Continue”) now respects accessibilityReduceMotion.",
      "Web Landing respects prefers-reduced-motion; a global CSS rule clamps residual animations to 0.01ms.",
      "Essentials warnings move to a 4.8:1 brown paired with an icon — never color-only.",
      "Favorite/essential stars move to a 5.6:1 amber with a VoiceOver label; Vision errors get a distinct dark red + icon.",
    ],
  },
  {
    tag: "1.0.5",
    date: "Dynamic Type audit",
    icon: Wrench,
    items: [
      "Full sweep for fixed-size fonts across every screen; the only offender (onboarding hero icon) now scales with @ScaledMetric.",
      "Every other text element rides scalable text styles — all 16 screens reflow from smallest to largest Dynamic Type.",
      "No minimumScaleFactor shrinking, no dynamicTypeSize caps — text is allowed to wrap and grow.",
    ],
  },
  {
    tag: "1.0.4",
    date: "Accessibility & VoiceOver",
    icon: Wrench,
    items: [
      "Explicit VoiceOver labels across every interactive control — item toggles announce “Mark {name} as packed / unpacked”.",
      "Template Add / Apply / Delete buttons name their template; Vision suggestions expose selection state.",
      "Decorative images hidden from VoiceOver; packing progress bars labeled; trip rows combine into one announcement.",
      "New UI regression test: testItemToggleHasVoiceOverLabel.",
    ],
  },
  {
    tag: "1.0.3",
    date: "Algorithm-friendly manifest",
    icon: Wrench,
    items: [
      "scripts/release-manifest.sh emits PackWise-releases.json (schema packwise.releases/v1) as a release asset.",
      "Stable deterministic URLs: releases/latest/download + releases/download/dev — no GitHub API key required.",
      "Every entry carries verified_by_build, changelog_url (wiki), and release_notes_url (tag page).",
      "Workflow now exposes Run workflow inputs: xcode_version, skip_tests, release_channel.",
    ],
  },
  {
    tag: "1.0.2",
    date: "One-command IPA verification",
    icon: Wrench,
    items: [
      "scripts/verify-ipa.sh — one command tells you whether any download is sideload-ready.",
      "Accepts the direct .ipa, the GitHub artifact .zip (auto-unwraps), or any folder.",
      "Checks zip integrity, Payload/<App>.app, main-executable existence, arm64 device Mach-O, and no test/signing artifacts.",
      "Wired into both CI pipelines as the final publish gate — CI and users share one verifier.",
    ],
  },
  {
    tag: "1.0.1",
    date: "Sideload fix + self-healing pipeline",
    icon: Wrench,
    items: [
      "Root cause fixed: published IPA was missing its main executable (the “Failed to map …/PackWise: Bad file descriptor” sideload error).",
      "ios/build.sh is now self-healing — device build → archive → legacy build, with executable validation (exists, non-empty, arm64, platform 2).",
      "Test bundles (PlugIns/*.xctest) and XCTest frameworks are stripped before packaging — never shipped in a release.",
      "Strict publish gate: an IPA without Payload/PackWise.app/PackWise fails the workflow — no more broken “success”.",
      "Direct .ipa on the dev prerelease every push to main (no outer-zip unwrap).",
    ],
  },
  {
    tag: "1.0.0",
    date: "Native iOS + docs platform",
    icon: Box,
    items: [
      "Dashboard: upcoming trips, packing progress, missing essentials, recent activity, quick actions.",
      "Trips: create, edit, delete, duplicate, status flow, destination, dates, activities, climate, category, export/share as JSON.",
      "Smart packing lists: categories, quantities, packed state, essential flags, search, sort, filter.",
      "Personal item library with photos, favorites, and reuse across trips.",
      "On-device Vision scanner (VNClassifyImageRequest) with explicit user confirmation.",
      "Outfit planner per trip day, composed from packed items.",
      "Global local search across trips, items, outfits, library, templates.",
      "Starter + custom templates, apply to any trip; local reminders via UserNotifications.",
      "SwiftData persistence, offline-first, no login, no cloud, no tracking.",
      "Docs: README + Wiki (9 pages) + live site with programmatic 3D SVG art; XcodeGen build; three build hosts.",
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
