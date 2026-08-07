import { Link } from "react-router";
import { motion } from "framer-motion";
import {
  Shield, HardDrive, Scan, Eye, Shirt, Library,
  Layers, Search, CalendarDays, Bell, Box, Cpu, Github,
  Download, Wrench, BookOpen, Check, Terminal, Smartphone, FileText, ExternalLink, Zap, Lock, Sparkles, Package, AlertTriangle, BadgeCheck,
} from "lucide-react";
import {
  SiteNav, SiteFooter, SectionTitle, serif,
  LIVE_REPO, LIVE_RELEASES, LIVE_RELEASE_LATEST, LIVE_RELEASE_DEV, LIVE_ACTIONS,
} from "@/components/site-shared";

function FeatureCard({ icon: Icon, title, desc }: { icon: typeof Scan; title: string; desc: string }) {
  return (
    <motion.div
      whileHover={{ y: -2 }}
      transition={{ duration: 0.2 }}
      className="rounded-2xl bg-card border border-border p-5 hover:shadow-[0_8px_30px_-12px_oklch(0.3_0.05_42/0.2)] transition-shadow"
    >
      <div className="size-9 rounded-xl bg-secondary grid place-items-center border border-border/50"><Icon className="size-[18px]" /></div>
      <div className="font-semibold mt-3.5 text-[15px]" style={serif}>{title}</div>
      <div className="text-[13.5px] leading-[22px] text-muted-foreground mt-1.5">{desc}</div>
    </motion.div>
  );
}

export default function Landing() {
  return (
    <div className="min-h-screen bg-background text-foreground selection:bg-[oklch(0.62_0.115_38/0.18)]">
      <SiteNav />

      {/* ── HERO — NATIVE iOS · SWIFTUI · SWIFTDATA · VISION · ON DEVICE ── */}
      <section className="max-w-[1180px] mx-auto px-6 pt-10 sm:pt-14 pb-6">
        <div className="grid lg:grid-cols-[1.06fr_0.94fr] gap-8 items-start">
          <div>
            <div className="inline-flex items-center gap-2 text-[11px] font-mono uppercase tracking-[0.14em] text-muted-foreground">
              <span className="size-1.5 rounded-full bg-[oklch(0.62_0.115_38)] animate-pulse" />
              Native iOS — SwiftUI · SwiftData · Vision · On device
            </div>
            <h1 className="mt-3 text-[40px] sm:text-[54px] leading-[0.9] tracking-[-0.03em]" style={serif}>
              PackWise for iPhone.<br />
              <span className="italic font-light">Your trips, on device.</span>
            </h1>
            <p className="mt-4 text-[15px] leading-6 text-muted-foreground max-w-[58ch]">
              A premium, privacy-first travel packing assistant. Every trip, packing list, photo, outfit, template and reminder lives on your iPhone and works offline. No account. No cloud. No tracking.
            </p>

            <div className="mt-2 inline-flex items-center gap-2 rounded-full bg-white border border-border px-3 py-1 text-xs">
              <Box className="size-3.5 text-muted-foreground" />
              <span className="font-medium">This website is documentation only.</span>
              <span className="hidden sm:inline text-muted-foreground">The IPA is the application.</span>
            </div>

            <div className="mt-6 flex flex-wrap gap-3">
              <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-primary text-primary-foreground text-sm font-medium hover:opacity-90 transition shadow-[0_8px_24px_-12px_oklch(0.25_0.05_42/0.5)]">
                <Download className="size-4" /> Download IPA — Latest Release
              </a>
              <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-5 py-3 rounded-full border border-border bg-card text-sm font-medium hover:bg-secondary transition">
                <Terminal className="size-4" /> View builds
              </a>
              <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-5 py-3 rounded-full border border-border bg-white text-sm font-medium hover:bg-secondary transition">
                <Zap className="size-4" /> dev — latest main
              </a>
            </div>
            <p className="text-[11px] text-muted-foreground mt-2 font-mono">
              <a href={LIVE_REPO} target="_blank" rel="noreferrer" className="underline underline-offset-4">Alot1z/packwise</a> · <Link to="/build" className="underline underline-offset-4">Build guide →</Link> · <a href={LIVE_RELEASES} target="_blank" rel="noreferrer" className="underline underline-offset-4">All Releases</a>
            </p>

            <div className="mt-5 flex flex-wrap gap-2.5 text-xs text-muted-foreground">
              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-card border border-border"><Shield className="size-3.5" /> Private by design</span>
              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-card border border-border"><HardDrive className="size-3.5" /> SwiftData on device</span>
              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-card border border-border"><Eye className="size-3.5" /> Vision on device</span>
              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-card border border-border"><Lock className="size-3.5" /> Offline-first</span>
            </div>
          </div>

          {/* IOS — NATIVE SWIFTUI card (3D hero art) */}
          <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.55, ease: "easeOut" }} className="athena-paper rounded-[28px] p-5 sm:p-6 border border-white/60 shadow-[0_20px_60px_-24px_oklch(0.3_0.05_42/0.25)]">
            <div className="flex items-center justify-between text-[10px] font-mono uppercase tracking-widest text-muted-foreground">
              <span className="inline-flex items-center gap-1.5">
                <span className="size-1.5 rounded-full bg-emerald-500 animate-pulse" />
                Built & verified · latest on main
              </span>
              <span>iOS 17+ · iPad</span>
            </div>
            <img src="/assets/packwise-hero.svg" alt="PackWise — isometric suitcase with packing layers" className="mt-3 w-full rounded-[18px] border border-white/60 shadow-sm" loading="eager" />
            <div className="mt-4 grid grid-cols-2 gap-3">
              <div className="rounded-2xl bg-white border border-border p-3">
                <div className="text-[11px] font-mono uppercase tracking-widest text-muted-foreground">Dashboard</div>
                <div className="text-sm font-medium mt-1" style={serif}>Upcoming · Progress · Missing</div>
                <div className="mt-3 h-1.5 rounded-full bg-black/10 overflow-hidden"><div className="h-full w-[62%] bg-[oklch(0.62_0.115_38)]" /></div>
                <div className="text-[11px] text-muted-foreground mt-1">Kyoto · 62% packed</div>
              </div>
              <div className="rounded-2xl bg-primary text-primary-foreground p-3">
                <div className="text-[11px] font-mono uppercase tracking-widest opacity-70">Vision Scanner</div>
                <div className="text-sm font-medium mt-1" style={serif}>Local suggestions</div>
                <div className="text-xs opacity-80 mt-1">Confirm before add — no silent changes</div>
              </div>
            </div>
            <div className="mt-3 grid grid-cols-3 gap-2 text-center">
              {[
                { k: "Trips", v: "Destination, dates, activities, climate" },
                { k: "Lists", v: "Categories, qty, packed, progress" },
                { k: "Outfits", v: "Day-by-day, from packed items" },
              ].map((b) => (
                <div key={b.k} className="rounded-xl bg-white border border-border p-2.5">
                  <div className="text-xs font-semibold" style={serif}>{b.k}</div>
                  <div className="text-[10px] leading-tight text-muted-foreground mt-1">{b.v}</div>
                </div>
              ))}
            </div>
            <div className="mt-4 rounded-xl bg-white border border-border p-3 flex items-center gap-2 text-xs">
              <Cpu className="size-3.5" /> On-device recommendations — no external AI
              <span className="ml-auto font-mono text-[11px] text-muted-foreground">MVVM · SwiftData</span>
            </div>
            <div className="mt-3 flex gap-2">
              <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="flex-1 inline-flex items-center justify-center gap-1.5 text-xs font-medium px-3 py-2 rounded-full bg-primary text-primary-foreground">Download IPA <ExternalLink className="size-3" /></a>
              <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-2 rounded-full border border-border bg-white">Build logs <Terminal className="size-3" /></a>
            </div>
            <div className="mt-2 text-[11px] text-center text-muted-foreground font-mono">
              Art is code — <span className="underline underline-offset-4">assets/packwise-hero.svg</span> · Inspected by build, not assumed
            </div>
          </motion.div>
        </div>
      </section>

      {/* ── SIDELOAD FIX STATUS — full root-cause diagnosis, verified-by-inspection ── */}
      <section className="max-w-[1180px] mx-auto px-6 pb-4">
        <div className="rounded-2xl border border-emerald-200 bg-emerald-50/90 p-4">
          <div className="flex gap-2.5">
            <BadgeCheck className="size-4 text-emerald-700 shrink-0 mt-0.5" />
            <div className="text-xs leading-5 text-emerald-900">
              <span className="font-semibold">“Bad file descriptor” — root cause found and fixed.</span>{" "}
              We inspected the published IPA byte-for-byte: the earlier dev build had{" "}
              <em>no main executable at all</em> (only <span className="font-mono">Info.plist</span>,{" "}
              <span className="font-mono">Assets.car</span> and injected test bundles). That is exactly why sideloaders
              failed with <span className="font-mono">Failed to map …/PackWise: Bad file descriptor</span> — the file is not there.
              The pipeline now builds a real device arm64 binary and <em>refuses to publish</em> unless{" "}
              <span className="font-mono">Payload/PackWise.app/PackWise</span> exists, is non-empty, and is an arm64 device
              Mach-O with <span className="font-mono">LC_BUILD_VERSION platform 2</span>. Every published IPA is re-verified
              by inspection before this page claims it works. The next green build replaces the old artifact at{" "}
              <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="font-medium underline underline-offset-4">releases/tag/dev</a>.
            </div>
          </div>
        </div>
      </section>

      {/* ── PRIMARY DELIVERY TARGET band ── */}
      <section className="max-w-[1180px] mx-auto px-6 pb-10">
        <div className="rounded-2xl border border-border bg-card p-5 grid md:grid-cols-[auto_1fr] gap-5 items-center">
          <div>
            <div className="flex items-center gap-2 text-[11px] font-mono uppercase tracking-widest text-muted-foreground"><Package className="size-3.5" /> Primary delivery target</div>
            <div className="mt-1 font-mono text-lg font-medium">PackWise-unsigned.ipa</div>
          </div>
          <div className="text-[13px] leading-6 text-muted-foreground md:border-l md:border-border md:pl-5">
            Available via <a href={LIVE_RELEASES} target="_blank" rel="noreferrer" className="underline underline-offset-4 font-medium text-foreground">GitHub Releases</a> (<a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="underline underline-offset-4">dev</a> + <span className="font-mono">v*</span>) and Actions artifacts. Also reproducible via Gitea Actions,{" "}
            <a href="https://github.com/nektos/act" target="_blank" rel="noreferrer" className="underline underline-offset-4">act</a> (self-hosted), or <span className="font-mono">ios/build.sh</span>. Same validated artifact on every host.
          </div>
        </div>
      </section>

      {/* ── INSIDE THE IPA ── */}
      <section id="features" className="max-w-[1180px] mx-auto px-6 pb-10">
        <div className="athena-rule mb-8" />
        <SectionTitle kicker="Inside the IPA" title="Every feature lives in the native app" desc="No essential capability depends on this website. The list below describes what ships inside PackWise-unsigned.ipa." />
        <div className="mt-6 grid md:grid-cols-3 gap-4">
          <FeatureCard icon={CalendarDays} title="Trip management" desc="Create, edit, delete, set destination/dates/activities/climate, categorize, view history, duplicate, apply templates." />
          <FeatureCard icon={Layers} title="Smart packing lists" desc="Categories (Clothing, Electronics, Toiletries, Documents, Medical, Accessories, Outdoor + custom), quantities, packed state, progress, search/sort/filter." />
          <FeatureCard icon={Library} title="Personal item library" desc="Create items with photos, notes, category, favorites — reuse across trips. Library lives on device." />
          <FeatureCard icon={Eye} title="On-device Vision" desc="Import or scan a photo → local Vision (VNClassifyImageRequest) suggests items → you confirm. No cloud, no silent adds." />
          <FeatureCard icon={Shirt} title="Outfit planner" desc="Compose outfits from packed items, assign to trip days, preview and reuse across trips." />
          <FeatureCard icon={Search} title="Global search" desc="Search trips, items, categories, outfits, templates — with filtering, sorting, favorites. Fully local." />
          <FeatureCard icon={Box} title="Dashboard" desc="Upcoming trips, packing progress, missing essentials, recent activity, quick actions — all local." />
          <FeatureCard icon={FileText} title="Templates" desc="Weekend, Business, Beach, Hiking, International + custom. Create, edit, duplicate, apply to any trip." />
          <FeatureCard icon={Bell} title="Reminders" desc="Local UserNotifications for packing and trip preparation. Quiet, on-device scheduling." />
        </div>
      </section>

      {/* ── ARCHITECTURE + LOCAL DATA MODELS ── */}
      <section id="architecture" className="max-w-[1180px] mx-auto px-6 pb-10">
        <SectionTitle kicker="Architecture" title="Native Apple stack, built for longevity" desc="Clean separation of UI, business logic, and persistence. Designed for maintainability and testability." />
        <div className="mt-6">
          <img src="/assets/architecture.svg" alt="PackWise architecture — SwiftUI to On Device pipeline" className="w-full rounded-2xl border border-border bg-white" loading="lazy" />
        </div>
        <div className="mt-4 grid lg:grid-cols-[1.15fr_0.85fr] gap-4">
          <div className="rounded-2xl border border-border bg-card p-5">
            <div className="text-xs font-mono uppercase tracking-widest text-muted-foreground">Stack</div>
            <div className="mt-3 grid grid-cols-2 gap-3 text-sm">
              {[
                ["Swift + SwiftUI", "All screens native"],
                ["SwiftData / Core Data", "Offline persistence + migrations"],
                ["Vision + VisionKit", "On-device image analysis"],
                ["Photos + Camera", "Import and capture"],
                ["UserNotifications", "Local reminders"],
                ["WidgetKit (optional)", "Future extension"],
              ].map(([a, b]) => (
                <div key={a} className="rounded-xl athena-stone p-3"><div className="font-medium text-sm">{a}</div><div className="text-xs text-muted-foreground mt-0.5">{b}</div></div>
              ))}
            </div>
            <div className="mt-4 rounded-xl bg-secondary/40 border border-border p-3 font-mono text-xs leading-5">
              PackWise/Models · Services/VisionService · Services/NotificationService · Services/RecommendationService · Views/Dashboard → Trip Detail → Packing List → Item Detail → Scanner → Outfit → Templates → Settings
            </div>
          </div>
          <div className="rounded-2xl border border-border bg-white p-5">
            <div className="text-xs font-mono uppercase tracking-widest text-muted-foreground">Local data models</div>
            <ul className="mt-3 space-y-1.5 text-sm">
              {[
                "Trip — title, destination, dates, activities, climate, category, status",
                "PackingList (via Trip.items) + PackingItem (qty, packed, essential, photo, notes)",
                "PersonalItem (library, favorites, reuse)",
                "Outfit (day assignment, preview)",
                "PackCategory (built-in + custom)",
                "PackTemplate / TemplateItem, Reminder, UserPreference",
              ].map((t) => (
                <li key={t} className="flex gap-2"><Check className="size-3.5 mt-0.5 text-emerald-600 shrink-0" /><span className="text-muted-foreground text-[13px]">{t}</span></li>
              ))}
            </ul>
            <div className="mt-4 text-xs text-muted-foreground">All models persist locally, work offline, and are backup-safe. No CloudKit required for core use.</div>
          </div>
        </div>
      </section>

      {/* ── PREVIEW ── */}
      <section className="max-w-[1180px] mx-auto px-6 pb-10">
        <SectionTitle kicker="Preview" title="Screenshots (from the native app)" desc="Real captures go under ios/screenshots/ — shown as placeholders here." />
        <div className="mt-6 grid sm:grid-cols-3 gap-4">
          {[1, 2, 3].map((i) => (
            <div key={i} className="rounded-2xl border border-dashed border-border bg-card p-6 text-center hover:border-primary/30 transition-colors">
              <div className="size-10 mx-auto rounded-xl bg-secondary grid place-items-center"><Smartphone className="size-5" /></div>
              <div className="text-sm font-medium mt-3" style={serif}>Screen {i}</div>
              <div className="text-xs text-muted-foreground">Place PNG at ios/screenshots/{i}.png</div>
            </div>
          ))}
        </div>
      </section>

      {/* ── INSTALL ── */}
      <section id="install" className="max-w-[1180px] mx-auto px-6 pb-10">
        <div className="rounded-[24px] border border-border bg-white p-6 sm:p-7 shadow-sm">
          <SectionTitle kicker="Install" title="Install PackWise-unsigned.ipa" desc="The IPA is built automatically from the live repo — no Apple Developer account required to generate it." />
          <div className="mt-6 grid md:grid-cols-2 gap-6">
            <div className="rounded-2xl athena-stone p-5">
              <div className="font-semibold flex items-center gap-2" style={serif}><Download className="size-4" /> Get the artifact</div>
              <ol className="mt-3 space-y-2 text-sm leading-6 text-muted-foreground list-decimal list-inside">
                <li>Open <a href={LIVE_RELEASES} target="_blank" rel="noreferrer" className="font-medium underline underline-offset-4">Releases</a> (or <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="underline underline-offset-4">Actions → iOS — PackWise</a>).</li>
                <li>Download <span className="font-mono">PackWise-unsigned.ipa</span> from the latest Release (or artifact).</li>
                <li>Every push to <span className="font-mono">main</span> rebuilds automatically — sync is already wired, no manual clone.</li>
                <li>No release is advertised as downloadable until a workflow has succeeded.</li>
              </ol>
              <div className="mt-4 flex flex-wrap gap-2">
                <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-primary text-primary-foreground text-sm font-medium">Download latest IPA <ExternalLink className="size-3.5" /></a>
                <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-border bg-white text-sm font-medium">dev — direct .ipa</a>
              </div>
            </div>
            <div className="rounded-2xl border border-border bg-card p-5">
              <div className="font-semibold" style={serif}>Sideload (choose one)</div>
              <div className="mt-3 space-y-3 text-sm">
                <div><span className="font-medium">AltStore:</span> <span className="text-muted-foreground">Install AltServer on Mac/PC → connect iPhone → AltStore → My Apps → + → select the <span className="font-mono">.ipa</span>.</span></div>
                <div><span className="font-medium">Sideloadly:</span> <span className="text-muted-foreground">Drag the <span className="font-mono">.ipa</span> onto Sideloadly, enter Apple ID for local signing, install.</span></div>
                <div><span className="font-medium">TrollStore (where compatible):</span> <span className="text-muted-foreground">Open TrollStore → + → select <span className="font-mono">.ipa</span> — no re-signing needed on supported versions.</span></div>
              </div>
              <div className="mt-4 text-xs text-muted-foreground border-t border-border pt-3">
                Unsigned IPAs require re-signing via the chosen tool. They are not App Store signed.
                <div className="mt-1 font-mono text-[11px]">unzip -l PackWise-unsigned.ipa | head</div>
              </div>
            </div>
          </div>

          {/* zip vs ipa clarity */}
          <div className="mt-4 rounded-xl border border-amber-200 bg-amber-50/90 p-4">
            <div className="flex gap-2.5">
              <AlertTriangle className="size-4 text-amber-700 shrink-0 mt-0.5" />
              <div className="text-xs leading-5 text-amber-900">
                <span className="font-semibold">Downloaded a <span className="font-mono">.zip</span> from Actions?</span> That&apos;s GitHub&apos;s artifact container — the real <span className="font-mono">PackWise-unsigned.ipa</span> is inside (<span className="font-mono">unzip PackWise-unsigned-ipa.zip</span> once). For a direct <span className="font-mono">.ipa</span> with no unwrap, use <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="font-medium underline underline-offset-4">Releases</a> or <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="font-medium underline underline-offset-4">dev</a>.
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── BUILD ── */}
      <section id="build" className="max-w-[1180px] mx-auto px-6 pb-10">
        <div className="rounded-[24px] border border-border bg-card p-6 sm:p-7">
          <SectionTitle kicker="Build" title="Build from source (reproducible)" />
          <div className="mt-6 grid lg:grid-cols-2 gap-6">
            <div>
              <div className="text-xs font-mono uppercase tracking-widest text-muted-foreground">Prerequisites</div>
              <p className="text-sm text-muted-foreground mt-1">Xcode 16+, iOS 17+, Swift 5.9, <span className="font-mono">brew install xcodegen</span>.</p>
              <div className="mt-4 rounded-xl bg-[#1a1a1e] text-zinc-100 border border-border p-3 font-mono text-xs leading-5">
                <div className="text-zinc-400"># Generate Xcode project</div>
                <div>cd ios && xcodegen generate && open PackWise.xcodeproj</div>
                <div className="mt-2 text-zinc-400"># Tests</div>
                <div>xcodebuild test -project PackWise.xcodeproj -scheme PackWise -destination "platform=iOS Simulator,name=iPhone 16"</div>
                <div className="mt-2 text-zinc-400"># Unsigned IPA (same as CI)</div>
                <div>./ios/build.sh  # → ios/build/PackWise-unsigned.ipa</div>
                <div className="mt-2 text-zinc-400"># Verify</div>
                <div>unzip -l ios/build/PackWise-unsigned.ipa | grep Payload</div>
              </div>
              <div className="mt-3 flex flex-wrap gap-2">
                <Link to="/build" className="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-full bg-primary text-primary-foreground hover:opacity-90 transition">Full build guide — GitHub / Gitea / act <ExternalLink className="size-3" /></Link>
                <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-full border border-border bg-white">Live build logs <ExternalLink className="size-3" /></a>
              </div>
            </div>
            <div className="rounded-2xl athena-stone p-5">
              <div className="font-semibold flex items-center gap-2" style={serif}><Wrench className="size-4" /> Verification & honesty</div>
              <ul className="mt-3 space-y-1.5 text-sm text-muted-foreground">
                {[
                  "xcodebuild build + test must pass",
                  "Build is device-first (iphoneos, arm64) — never a simulator binary",
                  "Executable validated: Payload/PackWise.app/PackWise must exist before publish",
                  "IPA verified: file + unzip -l + shasum -a 256 on every Release",
                  "No TestFlight / App Store claimed — requires Apple signing",
                ].map((t) => <li key={t} className="flex gap-2"><Check className="size-3.5 mt-0.5 text-emerald-600 shrink-0" />{t}</li>)}
              </ul>
              <div className="mt-4 text-xs text-muted-foreground">Source: <span className="font-mono">ios/README.md</span> · License: MIT · Live logs: <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="underline underline-offset-4">Alot1z/packwise Actions</a></div>
            </div>
          </div>
        </div>
      </section>

      {/* ── CHANGELOG + TROUBLESHOOTING ── */}
      <section id="changelog" className="max-w-[1180px] mx-auto px-6 pb-10 grid lg:grid-cols-2 gap-6">
        <div className="rounded-2xl border border-border bg-card p-6">
          <div className="flex items-center gap-2"><BookOpen className="size-4" /><span className="font-semibold" style={serif}>Changelog</span></div>
          <div className="mt-3 space-y-3 text-sm">
            <div>
              <div className="font-mono text-xs text-muted-foreground">1.0.0 — Native iOS</div>
              <div className="text-muted-foreground">Initial native release: Dashboard, Trips, Packing Lists, Library, Vision Scanner, Outfit Planner, Global Search, Templates, Reminders. SwiftData persistence, on-device Vision, local notifications. Unsigned IPA via GitHub Actions macos-15.</div>
            </div>
            <div className="border-t border-border pt-3">
              <div className="font-mono text-xs text-muted-foreground">Sideload fix</div>
              <div className="text-muted-foreground">Executable-validated build pipeline (device arm64, no test bundles, no missing binary). XcodeGen scheme isolates tests from archive. Direct .ipa on <span className="font-mono">dev</span> release every main push.</div>
            </div>
          </div>
          <Link to="/changelog" className="mt-4 inline-flex items-center gap-1.5 text-xs font-medium text-muted-foreground hover:text-foreground">Full changelog <ExternalLink className="size-3" /></Link>
        </div>
        <div className="rounded-2xl border border-border bg-white p-6">
          <div className="font-semibold" style={serif}>Troubleshooting</div>
          <ul className="mt-3 space-y-2 text-sm text-muted-foreground">
            <li><span className="font-medium text-foreground">“Failed to map …/PackWise: Bad file descriptor”?</span> — The IPA was built before the fix. Grab the next <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="underline underline-offset-4">dev</a> build (or build locally with <span className="font-mono">./ios/build.sh</span>) — the binary is now validated before publishing.</li>
            <li><span className="font-medium text-foreground">Got a .zip not a .ipa?</span> — Use <a href={LIVE_RELEASES} target="_blank" rel="noreferrer" className="underline underline-offset-4">Releases</a> / <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="underline underline-offset-4">dev</a> for the direct <span className="font-mono">.ipa</span>.</li>
            <li><span className="font-medium text-foreground">No IPA at all?</span> — <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="underline underline-offset-4">Actions logs</a> → the build step now fails loudly with diagnostics if the executable is missing.</li>
            <li><span className="font-medium text-foreground">Install fails?</span> — Unsigned IPAs must be re-signed via AltStore/Sideloadly or TrollStore on supported versions.</li>
            <li className="pt-2 border-t border-border text-xs">TestFlight / App Store are never claimed without real Apple signing and App Store Connect processing.</li>
          </ul>
          <Link to="/troubleshooting" className="mt-3 inline-flex items-center gap-1.5 text-xs font-medium text-muted-foreground hover:text-foreground">More troubleshooting <ExternalLink className="size-3" /></Link>
        </div>
      </section>

      {/* Polish band */}
      <section className="max-w-[1180px] mx-auto px-6 pb-10">
        <div className="rounded-2xl border border-border bg-card p-4 flex flex-wrap items-center gap-3 text-xs">
          <span className="inline-flex items-center gap-1.5 font-medium"><Sparkles className="size-3.5 text-[oklch(0.62_0.115_38)]" /> Clean · Premium · Technical</span>
          <span className="text-border">·</span>
          <span className="text-muted-foreground">Apple-quality calm utility — not a loud marketing site, not a chatbot.</span>
          <span className="ml-auto inline-flex items-center gap-1.5 font-mono"><Zap className="size-3.5" /> Fast startup · Offline · No mandatory login</span>
        </div>
      </section>

      <SiteFooter />
    </div>
  );
}
