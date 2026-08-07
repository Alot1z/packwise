import { Link } from "react-router";
import { motion } from "framer-motion";
import {
  ArrowRight, Shield, HardDrive, Scan, Eye, Shirt, Library,
  Layers, Search, CalendarDays, Bell, Box, Cpu, Github,
  Download, Wrench, BookOpen, Check, Terminal, Smartphone, FileText, ExternalLink
} from "lucide-react";

const serif = { fontFamily: "Instrument Serif, Cormorant Garamond, serif" } as const;
const LIVE_REPO = "https://github.com/Alot1z/packwise";
const LIVE_RELEASES = "https://github.com/Alot1z/packwise/releases";
const LIVE_RELEASE_LATEST = "https://github.com/Alot1z/packwise/releases/latest";
const LIVE_ACTIONS = "https://github.com/Alot1z/packwise/actions";

function SectionTitle({ kicker, title, desc }: { kicker: string; title: string; desc?: string }) {
  return (
    <div>
      <div className="text-[11px] font-mono uppercase tracking-[0.14em] text-muted-foreground">{kicker}</div>
      <h2 className="mt-2 text-[28px] leading-none tracking-[-0.02em]" style={serif}>{title}</h2>
      {desc && <p className="mt-2 text-sm leading-6 text-muted-foreground max-w-[68ch]">{desc}</p>}
    </div>
  );
}

export default function Landing() {
  return (
    <div className="min-h-screen bg-background text-foreground selection:bg-[oklch(0.62_0.115_38/0.18)]">
      {/* Nav */}
      <nav className="sticky top-0 z-30 backdrop-blur-xl bg-background/80 border-b border-border/60">
        <div className="max-w-[1180px] mx-auto px-6 h-[58px] flex items-center gap-6">
          <Link to="/" className="flex items-center gap-2.5 shrink-0">
            <span className="size-8 rounded-[10px] bg-primary text-primary-foreground grid place-items-center"><Scan className="size-4" /></span>
            <span className="text-[15px] font-semibold tracking-[-0.02em]" style={serif}>PackWise</span>
            <span className="hidden lg:inline text-[11px] font-mono uppercase tracking-[0.12em] text-muted-foreground border border-border rounded-full px-2.5 py-0.5 ml-1">Docs · IPA is the product</span>
          </Link>
          <div className="hidden md:flex items-center gap-1 text-sm">
            <a href="#features" className="px-3 py-1.5 rounded-full hover:bg-secondary transition">Features</a>
            <a href="#architecture" className="px-3 py-1.5 rounded-full hover:bg-secondary transition">Architecture</a>
            <a href="#install" className="px-3 py-1.5 rounded-full hover:bg-secondary transition">Install</a>
            <a href="#build" className="px-3 py-1.5 rounded-full hover:bg-secondary transition">Build</a>
            <a href="#changelog" className="px-3 py-1.5 rounded-full hover:bg-secondary transition">Changelog</a>
          </div>
          <div className="ml-auto flex items-center gap-2">
            <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="hidden sm:inline-flex text-sm font-medium px-4 py-2 rounded-full bg-primary text-primary-foreground hover:opacity-90 transition items-center gap-1.5">
              <Download className="size-3.5" /> Download IPA
            </a>
            <Link to="/setup" className="hidden lg:inline-flex text-sm font-medium px-4 py-2 rounded-full border border-border bg-card hover:bg-secondary transition">Build guide</Link>
            <a href={LIVE_REPO} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 text-sm font-medium px-3 py-2 rounded-full border border-border bg-card hover:bg-secondary transition">
              <Github className="size-3.5" /> <span className="hidden sm:inline">Alot1z/packwise</span> <ExternalLink className="size-3" />
            </a>
          </div>
        </div>
      </nav>

      {/* Hero */}
      <section className="max-w-[1180px] mx-auto px-6 pt-10 sm:pt-14 pb-8">
        <div className="grid lg:grid-cols-[1.08fr_0.92fr] gap-8 items-start">
          <div>
            <div className="inline-flex items-center gap-2 text-[11px] font-mono uppercase tracking-[0.14em] text-muted-foreground">
              <span className="size-1.5 rounded-full bg-[oklch(0.62_0.115_38)]" /> Native iOS — SwiftUI · SwiftData · Vision · On device
            </div>
            <h1 className="mt-3 text-[40px] sm:text-[52px] leading-[0.92] tracking-[-0.03em]" style={serif}>
              PackWise for iPhone.<br />
              <span className="italic font-light">Your trips, on device.</span>
            </h1>
            <p className="mt-4 text-[15px] leading-6 text-muted-foreground max-w-[58ch]">
              A premium, privacy-first travel packing assistant. Every trip, packing list, photo, outfit, template and reminder lives on your iPhone and works offline. No account. No cloud. No tracking.
            </p>
            <div className="mt-2 inline-flex items-center gap-2 rounded-full bg-amber-50 border border-amber-200 px-3 py-1 text-xs">
              <Box className="size-3.5 text-amber-700" />
              <span className="font-medium text-amber-900">This website is documentation only.</span>
              <span className="hidden sm:inline text-amber-800">The IPA is the application.</span>
            </div>

            <div className="mt-6 flex flex-wrap gap-3">
              <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-primary text-primary-foreground text-sm font-medium hover:opacity-90 transition">
                <Download className="size-4" /> Download IPA — Latest Release
              </a>
              <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-6 py-3 rounded-full border border-border bg-card text-sm font-medium hover:bg-secondary transition">
                <Terminal className="size-4" /> View builds
              </a>
            </div>
            <p className="text-xs text-muted-foreground mt-2">
              Live repo: <a href={LIVE_REPO} target="_blank" rel="noreferrer" className="underline underline-offset-4 font-mono">Alot1z/packwise</a> · Releases are the download source — no clone needed. <Link to="/setup" className="underline underline-offset-4">Build guide →</Link>
            </p>

            <div className="mt-5 flex flex-wrap gap-3 text-xs text-muted-foreground">
              <span className="inline-flex items-center gap-1.5"><Shield className="size-3.5" /> Private by design</span>
              <span className="inline-flex items-center gap-1.5"><HardDrive className="size-3.5" /> SwiftData on device</span>
              <span className="inline-flex items-center gap-1.5"><Eye className="size-3.5" /> Vision on device</span>
              <span className="inline-flex items-center gap-1.5"><Check className="size-3.5" /> Offline-first</span>
            </div>

            <div className="mt-4 rounded-2xl border border-border bg-card p-4">
              <div className="text-xs font-mono uppercase tracking-widest text-muted-foreground">Primary delivery target</div>
              <div className="mt-1 font-mono text-sm">PackWise-unsigned.ipa</div>
              <div className="text-xs text-muted-foreground">Available via <a href={LIVE_RELEASES} target="_blank" rel="noreferrer" className="underline underline-offset-4">GitHub Releases</a> and Actions artifacts. Also reproducible via <a href="https://about.gitea.com" target="_blank" rel="noreferrer" className="underline underline-offset-4">Gitea Actions</a>, <a href="https://github.com/nektos/act" target="_blank" rel="noreferrer" className="underline underline-offset-4">act</a> (self-hosted), or <span className="font-mono">ios/build.sh</span>. Same artifact on every host.</div>
            </div>
          </div>

          <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.5 }} className="athena-paper rounded-[28px] p-5 sm:p-6 border border-white/60 shadow-[0_20px_60px_-24px_oklch(0.3_0.05_42/0.25)]">
            <div className="flex items-center justify-between">
              <span className="text-[11px] font-mono uppercase tracking-[0.14em] text-muted-foreground">iOS — Native SwiftUI</span>
              <span className="rounded-full bg-white border border-border px-2.5 py-1 text-[11px] font-medium inline-flex items-center gap-1"><Smartphone className="size-3" /> iOS 17+ · iPad</span>
            </div>
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
              ].map(b => (
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
          </motion.div>
        </div>
      </section>

      {/* Features */}
      <section id="features" className="max-w-[1180px] mx-auto px-6 pb-10">
        <div className="athena-rule mb-8" />
        <SectionTitle kicker="Inside the IPA" title="Every feature lives in the native app" desc="No essential capability depends on this website. The list below describes what ships inside PackWise-unsigned.ipa." />
        <div className="mt-6 grid md:grid-cols-3 gap-4">
          {[
            { icon: CalendarDays, title: "Trip management", desc: "Create, edit, delete, set destination/dates/activities/climate, categorize, view history, duplicate, apply templates." },
            { icon: Layers, title: "Smart packing lists", desc: "Categories (Clothing, Electronics, Toiletries, Documents, Medical, Accessories, Outdoor + custom), quantities, packed state, progress, search/sort/filter." },
            { icon: Library, title: "Personal item library", desc: "Create items with photos, notes, category, favorites — reuse across trips. Library lives on device." },
            { icon: Eye, title: "On-device Vision", desc: "Import or scan a photo → local Vision (VNClassifyImageRequest) suggests items → you confirm. No cloud, no silent adds." },
            { icon: Shirt, title: "Outfit planner", desc: "Compose outfits from packed items, assign to trip days, preview and reuse across trips." },
            { icon: Search, title: "Global search", desc: "Search trips, items, categories, outfits, templates — with filtering, sorting, favorites. Fully local." },
            { icon: Box, title: "Dashboard", desc: "Upcoming trips, packing progress, missing essentials, recent activity, quick actions — all local." },
            { icon: FileText, title: "Templates", desc: "Weekend, Business, Beach, Hiking, International + custom. Create, edit, duplicate, apply to any trip." },
            { icon: Bell, title: "Reminders", desc: "Local UserNotifications for packing and trip preparation. Quiet, on-device scheduling." },
          ].map(f => (
            <div key={f.title} className="rounded-2xl bg-card border border-border p-5">
              <div className="size-8 rounded-lg bg-secondary grid place-items-center"><f.icon className="size-4" /></div>
              <div className="font-semibold mt-3" style={serif}>{f.title}</div>
              <div className="text-sm leading-6 text-muted-foreground mt-1">{f.desc}</div>
            </div>
          ))}
        </div>
      </section>

      {/* Architecture */}
      <section id="architecture" className="max-w-[1180px] mx-auto px-6 pb-10">
        <SectionTitle kicker="Architecture" title="Native Apple stack, built for longevity" desc="Clean separation of UI, business logic, and persistence. Designed for maintainability and testability." />
        <div className="mt-6 grid lg:grid-cols-[1.2fr_0.8fr] gap-4">
          <div className="rounded-2xl border border-border bg-card p-5">
            <div className="text-xs font-mono uppercase tracking-widest text-muted-foreground">Stack</div>
            <div className="mt-2 grid grid-cols-2 gap-3 text-sm">
              {[
                ["Swift + SwiftUI", "All screens native"],
                ["SwiftData / Core Data", "Offline persistence + migrations"],
                ["Vision + VisionKit", "On-device image analysis"],
                ["Photos + Camera", "Import and capture"],
                ["UserNotifications", "Local reminders"],
                ["WidgetKit (optional)", "Future extension"],
              ].map(([a,b])=>(
                <div key={a} className="rounded-xl athena-stone p-3"><div className="font-medium">{a}</div><div className="text-xs text-muted-foreground">{b}</div></div>
              ))}
            </div>
            <div className="mt-4 rounded-xl bg-secondary/40 border border-border p-3 font-mono text-xs leading-5">
              PackWise/Models · Services/VisionService · Services/NotificationService · Services/RecommendationService · Views/Dashboard → Trip Detail → Packing List → Item Detail → Scanner → Outfit → Templates → Settings
            </div>
          </div>
          <div className="rounded-2xl border border-border bg-white p-5">
            <div className="text-xs font-mono uppercase tracking-widest text-muted-foreground">Local data models</div>
            <ul className="mt-3 space-y-1.5 text-sm">
              {["Trip — title, destination, dates, activities, climate, category, status", "PackingList (via Trip.items) + PackingItem (qty, packed, essential, photo, notes)", "PersonalItem (library, favorites, reuse)", "Outfit (day assignment, preview)", "PackCategory (built-in + custom)", "PackTemplate / TemplateItem, Reminder, UserPreference"].map(t=>(
                <li key={t} className="flex gap-2"><Check className="size-3.5 mt-0.5 text-emerald-600 shrink-0" /><span className="text-muted-foreground">{t}</span></li>
              ))}
            </ul>
            <div className="mt-4 text-xs text-muted-foreground">All models persist locally, work offline, and are backup-safe. No CloudKit required for core use.</div>
          </div>
        </div>
      </section>

      {/* Screenshots */}
      <section className="max-w-[1180px] mx-auto px-6 pb-10">
        <SectionTitle kicker="Preview" title="Screenshots (from the native app)" desc="Add real device captures under ios/screenshots/ — shown here as placeholders." />
        <div className="mt-6 grid sm:grid-cols-3 gap-4">
          {[1,2,3].map(i=>(
            <div key={i} className="rounded-2xl border border-dashed border-border bg-card p-6 text-center">
              <div className="size-10 mx-auto rounded-xl bg-secondary grid place-items-center"><Smartphone className="size-5" /></div>
              <div className="text-sm font-medium mt-3" style={serif}>Screen {i}</div>
              <div className="text-xs text-muted-foreground">Place PNG at ios/screenshots/{i}.png</div>
            </div>
          ))}
        </div>
      </section>

      {/* Install */}
      <section id="install" className="max-w-[1180px] mx-auto px-6 pb-10">
        <div className="rounded-[24px] border border-border bg-white p-6 sm:p-7">
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
                <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 text-sm font-medium px-3 py-2 rounded-full border border-border bg-white">Build logs</a>
              </div>
            </div>
            <div className="rounded-2xl border border-border bg-card p-5">
              <div className="font-semibold" style={serif}>Sideload (choose one)</div>
              <div className="mt-3 space-y-3 text-sm">
                <div><span className="font-medium">AltStore:</span> <span className="text-muted-foreground">Install AltServer on Mac/PC → connect iPhone → open AltStore → My Apps → + → select the IPA.</span></div>
                <div><span className="font-medium">Sideloadly:</span> <span className="text-muted-foreground">Drag the IPA onto Sideloadly, enter Apple ID for local signing, install.</span></div>
                <div><span className="font-medium">TrollStore (where compatible):</span> <span className="text-muted-foreground">Open TrollStore → + → select IPA — no re-signing needed on supported versions.</span></div>
              </div>
              <div className="mt-4 text-xs text-muted-foreground border-t border-border pt-3">Unsigned IPAs require re-signing via the chosen tool. They are not App Store signed. Verify: <span className="font-mono">unzip -l PackWise-unsigned.ipa | head</span></div>
            </div>
          </div>
        </div>
      </section>

      {/* Build */}
      <section id="build" className="max-w-[1180px] mx-auto px-6 pb-10">
        <div className="rounded-[24px] border border-border bg-card p-6 sm:p-7">
          <SectionTitle kicker="Build" title="Build from source (reproducible)" />
          <div className="mt-6 grid lg:grid-cols-2 gap-6">
            <div>
              <div className="text-xs font-mono uppercase tracking-widest text-muted-foreground">Prerequisites</div>
              <p className="text-sm text-muted-foreground mt-1">Xcode 16+, iOS 17+, Swift 5.9, <span className="font-mono">brew install xcodegen</span>.</p>
              <div className="mt-4 rounded-xl bg-white border border-border p-3 font-mono text-xs leading-5">
                <div className="text-muted-foreground"># Generate Xcode project</div>
                <div>cd ios && xcodegen generate && open PackWise.xcodeproj</div>
                <div className="mt-2 text-muted-foreground"># Tests</div>
                <div>xcodebuild test -project PackWise.xcodeproj -scheme PackWise -destination "platform=iOS Simulator,name=iPhone 16"</div>
                <div className="mt-2 text-muted-foreground"># Unsigned IPA (same as CI)</div>
                <div>./ios/build.sh  # → ios/build/PackWise-unsigned.ipa</div>
              </div>
              <div className="mt-3 flex flex-wrap gap-2">
                <Link to="/setup" className="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-full bg-primary text-primary-foreground hover:opacity-90 transition">Full build guide — GitHub / Gitea / act <ArrowRight className="size-3" /></Link>
                <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-full border border-border bg-white">Live build logs <ExternalLink className="size-3" /></a>
              </div>
            </div>
            <div className="rounded-2xl athena-stone p-5">
              <div className="font-semibold flex items-center gap-2" style={serif}><Wrench className="size-4" /> Verification</div>
              <ul className="mt-3 space-y-1.5 text-sm text-muted-foreground">
                {[
                  "xcodebuild build + test must pass",
                  "archive now falls back to DerivedData build — never silent no-ipa",
                  "ipa is zip of Payload/PackWise.app + .sha256",
                  "artifact verifiable: unzip -l + shasum",
                ].map(t=> <li key={t} className="flex gap-2"><Check className="size-3.5 mt-0.5 text-emerald-600" />{t}</li>)}
              </ul>
              <div className="mt-4 text-xs text-muted-foreground">Source: <span className="font-mono">ios/README.md</span> · License: MIT · No paid APIs. Live logs: <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="underline underline-offset-4">Alot1z/packwise Actions</a></div>
            </div>
          </div>
        </div>
      </section>

      {/* Changelog */}
      <section id="changelog" className="max-w-[1180px] mx-auto px-6 pb-10 grid lg:grid-cols-2 gap-6">
        <div className="rounded-2xl border border-border bg-card p-6">
          <div className="flex items-center gap-2"><BookOpen className="size-4" /><span className="font-semibold" style={serif}>Changelog</span></div>
          <div className="mt-3 space-y-3 text-sm">
            <div><div className="font-mono text-xs text-muted-foreground">1.0.0 — Native iOS</div><div className="text-muted-foreground">Initial native release: Dashboard, Trips, Packing Lists, Library, Vision Scanner, Outfit Planner, Global Search, Templates, Reminders. SwiftData persistence, on-device Vision, local notifications. Unsigned IPA via GitHub Actions macos-15 with archive+fallback.</div></div>
            <div className="border-t border-border pt-3"><div className="font-mono text-xs text-muted-foreground">Build</div><div className="text-muted-foreground">XcodeGen, unit + UI tests, artifact + Release upload, sha256. Mirror for Gitea and local act.</div></div>
          </div>
        </div>
        <div className="rounded-2xl border border-border bg-white p-6">
          <div className="font-semibold" style={serif}>Troubleshooting</div>
          <ul className="mt-3 space-y-2 text-sm text-muted-foreground">
            <li><span className="font-medium text-foreground">No IPA artifact?</span> — Open <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="underline underline-offset-4">Actions logs</a> → <span className="font-mono">Archive — unsigned IPA</span> now prints fallback diagnostics (see fix above).</li>
            <li><span className="font-medium text-foreground">Install fails?</span> — Unsigned IPAs must be re-signed via AltStore/Sideloadly or via TrollStore on supported versions.</li>
            <li><span className="font-medium text-foreground">Vision finds nothing?</span> — Try a clearer, well-lit photo; Vision is on device and conservative.</li>
            <li className="pt-2 border-t border-border text-xs">TestFlight / App Store are never claimed without real Apple signing and App Store Connect processing.</li>
          </ul>
        </div>
      </section>

      <footer className="border-t border-border/70">
        <div className="max-w-[1180px] mx-auto px-6 py-8 flex flex-wrap items-center justify-between gap-4 text-sm text-muted-foreground">
          <span>PackWise — <a href={LIVE_REPO} target="_blank" rel="noreferrer" className="underline underline-offset-4">Alot1z/packwise</a> · Native iOS is the product. This site documents the project.</span>
          <span className="inline-flex items-center gap-2">
            <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 font-medium text-foreground">Download IPA <Download className="size-4" /></a>
            <span className="text-border">·</span>
            <Link to="/setup" className="inline-flex items-center gap-1">Build guide <ArrowRight className="size-3" /></Link>
          </span>
        </div>
      </footer>
    </div>
  );
}
