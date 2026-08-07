import { Link } from "react-router";
import { motion } from "framer-motion";
import {
  ArrowRight, Shield, HardDrive, Scan, Eye, Shirt, Library,
  Layers, Search, CalendarDays, Bell, Box, Cpu, Github,
  Download, Wrench, BookOpen, Check, Terminal, Smartphone, FileText, ExternalLink, Zap, Lock, Sparkles, Package
} from "lucide-react";

const serif = { fontFamily: "Instrument Serif, Cormorant Garamond, serif" } as const;
const LIVE_REPO = "https://github.com/Alot1z/packwise";
const LIVE_RELEASES = "https://github.com/Alot1z/packwise/releases";
const LIVE_RELEASE_LATEST = "https://github.com/Alot1z/packwise/releases/latest";
const LIVE_RELEASE_DEV = "https://github.com/Alot1z/packwise/releases/tag/dev";
const LIVE_ACTIONS = "https://github.com/Alot1z/packwise/actions";

function SectionTitle({ kicker, title, desc }: { kicker: string; title: string; desc?: string }) {
  return (
    <div>
      <div className="text-[11px] font-mono uppercase tracking-[0.14em] text-muted-foreground">{kicker}</div>
      <h2 className="mt-2 text-[28px] sm:text-[32px] leading-none tracking-[-0.02em]" style={serif}>{title}</h2>
      {desc && <p className="mt-2.5 text-[14px] leading-6 text-muted-foreground max-w-[70ch]">{desc}</p>}
    </div>
  );
}

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
        <div className="grid lg:grid-cols-[1.06fr_0.94fr] gap-8 items-start">
          <div>
            <div className="inline-flex items-center gap-2 text-[11px] font-mono uppercase tracking-[0.14em] text-muted-foreground">
              <span className="size-1.5 rounded-full bg-[oklch(0.62_0.115_38)] animate-pulse" /> Native iOS — SwiftUI · SwiftData · Vision · On device
            </div>
            <h1 className="mt-3 text-[40px] sm:text-[54px] leading-[0.9] tracking-[-0.03em]" style={serif}>
              PackWise for iPhone.<br />
              <span className="italic font-light">Your trips, on device.</span>
            </h1>
            <p className="mt-4 text-[15px] leading-6 text-muted-foreground max-w-[58ch]">
              A premium, privacy-first travel packing assistant. Every trip, packing list, photo, outfit, template and reminder lives on your iPhone and works offline. No account. No cloud. No tracking.
            </p>

            {/* What is .ipa? + zip vs ipa clarity — FIX B */}
            <div className="mt-4 rounded-2xl border border-amber-200 bg-amber-50/90 p-4">
              <div className="flex gap-2.5">
                <Package className="size-4 text-amber-700 shrink-0 mt-0.5" />
                <div className="text-xs leading-5 text-amber-900">
                  <span className="font-semibold">Did your download arrive as a <span className="font-mono">.zip</span>?</span> That&apos;s GitHub&apos;s artifact container — not the PackWise build. Inside <span className="font-mono">PackWise-unsigned-ipa.zip</span> is the real <span className="font-mono">PackWise-unsigned.ipa</span>.
                  For a direct <span className="font-mono">.ipa</span> (1 click, no unwrap): use <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="font-medium underline underline-offset-4">Releases → Latest</a> or <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="font-medium underline underline-offset-4">dev (latest main)</a> — every push to <span className="font-mono">main</span> now publishes it.
                  <div className="mt-2 font-mono text-[11px] bg-white/80 border border-amber-200 rounded-lg px-2.5 py-1.5">file PackWise-unsigned.ipa → Zip archive data · unzip -l PackWise-unsigned.ipa → Payload/PackWise.app/</div>
                </div>
              </div>
            </div>

            <div className="mt-2 inline-flex items-center gap-2 rounded-full bg-white border border-border px-3 py-1 text-xs">
              <Box className="size-3.5 text-muted-foreground" />
              <span className="font-medium">This website is documentation only.</span>
              <span className="hidden sm:inline text-muted-foreground">The IPA is the application.</span>
            </div>

            <div className="mt-6 flex flex-wrap gap-3">
              <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-primary text-primary-foreground text-sm font-medium hover:opacity-90 transition shadow-[0_8px_24px_-12px_oklch(0.25_0.05_42/0.5)]">
                <Download className="size-4" /> Download IPA — Latest
              </a>
              <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-5 py-3 rounded-full border border-border bg-card text-sm font-medium hover:bg-secondary transition">
                <Zap className="size-4" /> dev — latest main
              </a>
              <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-5 py-3 rounded-full border border-border bg-white text-sm font-medium hover:bg-secondary transition">
                <Terminal className="size-4" /> Builds
              </a>
            </div>
            <p className="text-[11px] text-muted-foreground mt-2 font-mono">
              <a href={LIVE_REPO} target="_blank" rel="noreferrer" className="underline underline-offset-4">Alot1z/packwise</a> · <Link to="/setup" className="underline underline-offset-4">Build guide →</Link> · <a href={LIVE_RELEASES} target="_blank" rel="noreferrer" className="underline underline-offset-4">All Releases</a>
            </p>

            <div className="mt-5 flex flex-wrap gap-2.5 text-xs text-muted-foreground">
              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-card border border-border"><Shield className="size-3.5" /> Private by design</span>
              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-card border border-border"><HardDrive className="size-3.5" /> SwiftData</span>
              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-card border border-border"><Eye className="size-3.5" /> Vision on-device</span>
              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-card border border-border"><Lock className="size-3.5" /> Offline-first</span>
            </div>

            <div className="mt-4 rounded-2xl border border-border bg-card p-4">
              <div className="flex items-center gap-2 text-xs font-mono uppercase tracking-widest text-muted-foreground"><Package className="size-3.5" /> Primary delivery target</div>
              <div className="mt-1 font-mono text-sm font-medium">PackWise-unsigned.ipa</div>
              <div className="text-xs text-muted-foreground mt-1 leading-5">Direct <span className="font-mono">.ipa</span> on <a href={LIVE_RELEASES} target="_blank" rel="noreferrer" className="underline underline-offset-4">Releases</a> (<a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="underline underline-offset-4">dev</a> + <span className="font-mono">v*</span>). Artifact is an outer zip — unwrap to get the same <span className="font-mono">.ipa</span>. Also via <a href="https://about.gitea.com" target="_blank" rel="noreferrer" className="underline underline-offset-4">Gitea</a> / <a href="https://github.com/nektos/act" target="_blank" rel="noreferrer" className="underline underline-offset-4">act</a> / <span className="font-mono">ios/build.sh</span>.</div>
            </div>
          </div>

          <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.55, ease: "easeOut" }} className="athena-paper rounded-[28px] p-5 sm:p-6 border border-white/60 shadow-[0_20px_60px_-24px_oklch(0.3_0.05_42/0.25)]">
            {/* Programmatic 3D hero — imported from assets so README + site share the same art */}
            <img src="/assets/packwise-hero.svg" alt="PackWise — isometric suitcase with packing layers" className="w-full rounded-[18px] border border-white/60 shadow-sm" loading="eager" />
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
            <div className="mt-2 text-[11px] text-center text-muted-foreground font-mono">Art is code — <span className="underline underline-offset-4">assets/packwise-hero.svg</span></div>
          </motion.div>
        </div>
      </section>

      {/* Polish band */}
      <section className="max-w-[1180px] mx-auto px-6 pb-6">
        <div className="rounded-2xl border border-border bg-card p-4 flex flex-wrap items-center gap-3 text-xs">
          <span className="inline-flex items-center gap-1.5 font-medium"><Sparkles className="size-3.5 text-[oklch(0.62_0.115_38)]" /> Clean · Premium · Technical</span>
          <span className="text-border">·</span>
          <span className="text-muted-foreground">Apple-quality calm utility — not a loud marketing site, not a chatbot.</span>
          <span className="ml-auto inline-flex items-center gap-1.5 font-mono"><Zap className="size-3.5" /> Fast startup · Offline · No mandatory login</span>
        </div>
      </section>

      {/* Features */}
      <section id="features" className="max-w-[1180px] mx-auto px-6 pb-10">
        <div className="athena-rule mb-8" />
        <SectionTitle kicker="Inside the IPA" title="Every feature lives in the native app" desc="No essential capability depends on this website. What you see below ships inside PackWise-unsigned.ipa." />
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

      {/* Architecture */}
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
              ].map(([a,b])=>(
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
              {["Trip — title, destination, dates, activities, climate, category, status", "PackingList (via Trip.items) + PackingItem (qty, packed, essential, photo, notes)", "PersonalItem (library, favorites, reuse)", "Outfit (day assignment, preview)", "PackCategory (built-in + custom)", "PackTemplate / TemplateItem, Reminder, UserPreference"].map(t=>(
                <li key={t} className="flex gap-2"><Check className="size-3.5 mt-0.5 text-emerald-600 shrink-0" /><span className="text-muted-foreground text-[13px]">{t}</span></li>
              ))}
            </ul>
            <div className="mt-4 text-xs text-muted-foreground">All models persist locally, work offline, and are backup-safe. No CloudKit required for core use.</div>
          </div>
        </div>
      </section>

      {/* Screenshots */}
      <section className="max-w-[1180px] mx-auto px-6 pb-10">
        <SectionTitle kicker="Preview" title="Screenshots (from the native app)" desc="Real captures go under ios/screenshots/ — shown as tasteful placeholders here." />
        <div className="mt-6 grid sm:grid-cols-3 gap-4">
          {[1,2,3].map(i=>(
            <div key={i} className="rounded-2xl border border-dashed border-border bg-card p-6 text-center hover:border-primary/30 transition-colors">
              <div className="size-10 mx-auto rounded-xl bg-secondary grid place-items-center"><Smartphone className="size-5" /></div>
              <div className="text-sm font-medium mt-3" style={serif}>Screen {i}</div>
              <div className="text-xs text-muted-foreground">Place PNG at ios/screenshots/{i}.png</div>
            </div>
          ))}
        </div>
      </section>

      {/* Install — with concrete zip vs ipa guidance */}
      <section id="install" className="max-w-[1180px] mx-auto px-6 pb-10">
        <div className="rounded-[24px] border border-border bg-white p-6 sm:p-7 shadow-sm">
          <SectionTitle kicker="Install" title="Install PackWise-unsigned.ipa" desc="The IPA is built automatically — no Apple Developer account required to generate it. Choose the direct .ipa path below." />
          <div className="mt-6 grid md:grid-cols-2 gap-6">
            <div className="rounded-2xl athena-stone p-5">
              <div className="font-semibold flex items-center gap-2" style={serif}><Download className="size-4" /> Get the file (direct .ipa)</div>
              <ol className="mt-3 space-y-2 text-sm leading-6 text-muted-foreground list-decimal list-inside">
                <li>Open <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="font-medium underline underline-offset-4">Releases → Latest</a> or <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="font-medium underline underline-offset-4">dev (latest main)</a> → <span className="font-mono">PackWise-unsigned.ipa</span>.</li>
                <li>Prefer Actions? — <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="underline underline-offset-4">Actions → iOS — PackWise</a> → artifact <span className="font-mono">PackWise-unsigned-ipa.zip</span> → unzip → <span className="font-mono">.ipa</span> inside.</li>
                <li>Every push to <span className="font-mono">main</span> rebuilds automatically — <span className="font-mono">dev</span> updates in place.</li>
              </ol>
              <div className="mt-4 flex flex-wrap gap-2">
                <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-primary text-primary-foreground text-sm font-medium">Latest IPA <ExternalLink className="size-3.5" /></a>
                <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-border bg-white text-sm font-medium">dev — direct .ipa</a>
              </div>
              <div className="mt-3 rounded-xl bg-white border border-border p-2.5 font-mono text-[11px] leading-4">
                <div className="text-muted-foreground">Direct download (no unwrap):</div>
                <div className="mt-1">gh release download dev -R Alot1z/packwise -p &quot;PackWise-unsigned.ipa&quot;</div>
              </div>
            </div>
            <div className="rounded-2xl border border-border bg-card p-5">
              <div className="font-semibold" style={serif}>Sideload (choose one)</div>
              <div className="mt-3 space-y-3 text-sm">
                <div><span className="font-medium">AltStore:</span> <span className="text-muted-foreground">Install AltServer on Mac/PC → connect iPhone → AltStore → My Apps → + → select the <span className="font-mono">.ipa</span>.</span></div>
                <div><span className="font-medium">Sideloadly:</span> <span className="text-muted-foreground">Drag the <span className="font-mono">.ipa</span> onto Sideloadly, enter Apple ID for local signing, install.</span></div>
                <div><span className="font-medium">TrollStore (where compatible):</span> <span className="text-muted-foreground">Open TrollStore → + → select <span className="font-mono">.ipa</span> — no re-sign on supported versions.</span></div>
              </div>
              <div className="mt-4 text-xs text-muted-foreground border-t border-border pt-3 space-y-1">
                <div>Verify: <span className="font-mono">file PackWise-unsigned.ipa</span> → <span className="font-mono">Zip archive data</span> (expected)</div>
                <div><span className="font-mono">unzip -l PackWise-unsigned.ipa | head</span> → <span className="font-mono">Payload/PackWise.app/</span></div>
              </div>
            </div>
          </div>
          <div className="mt-4 rounded-xl border border-border bg-secondary/30 p-3 text-xs leading-5 text-muted-foreground">
            <span className="font-medium text-foreground">Heads-up:</span> If you downloaded <span className="font-mono">PackWise-unsigned-ipa.zip</span> from Actions, that&apos;s the <em>container</em>. Unzip it once — the inner <span className="font-mono">PackWise-unsigned.ipa</span> is what you sideload. Releases give you the inner file directly.
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
                <div className="mt-2 text-muted-foreground"># Tests (non-blocking in CI)</div>
                <div>xcodebuild test -project PackWise.xcodeproj -scheme PackWise -destination &quot;platform=iOS Simulator,name=iPhone 16&quot;</div>
                <div className="mt-2 text-muted-foreground"># Unsigned IPA (same as CI)</div>
                <div>./ios/build.sh  # → ios/build/PackWise-unsigned.ipa + .sha256</div>
                <div className="mt-2 text-muted-foreground"># Verify</div>
                <div>file ios/build/PackWise-unsigned.ipa && unzip -l ios/build/PackWise-unsigned.ipa | head</div>
              </div>
              <div className="mt-3 flex flex-wrap gap-2">
                <Link to="/setup" className="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-full bg-primary text-primary-foreground hover:opacity-90 transition">Full build guide — GitHub / Gitea / act <ArrowRight className="size-3" /></Link>
                <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-full border border-border bg-white">Live build logs <ExternalLink className="size-3" /></a>
              </div>
            </div>
            <div className="rounded-2xl athena-stone p-5">
              <div className="font-semibold flex items-center gap-2" style={serif}><Wrench className="size-4" /> Verification & honesty</div>
              <ul className="mt-3 space-y-1.5 text-sm text-muted-foreground">
                {[
                  "xcodebuild build + test — must pass locally",
                  "archive → DerivedData fallback — never silent no-ipa",
                  "IPA validated: file + unzip -l must show Payload/PackWise.app/",
                  "shasum -a 256 published alongside .ipa on every Release",
                  "No TestFlight / App Store claimed — requires Apple signing",
                ].map(t=> <li key={t} className="flex gap-2"><Check className="size-3.5 mt-0.5 text-emerald-600 shrink-0" />{t}</li>)}
              </ul>
              <div className="mt-4 text-xs text-muted-foreground">Source: <span className="font-mono">ios/README.md</span> · License: MIT · Live logs: <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="underline underline-offset-4">Alot1z/packwise Actions</a></div>
            </div>
          </div>
        </div>
      </section>

      {/* Changelog */}
      <section id="changelog" className="max-w-[1180px] mx-auto px-6 pb-10 grid lg:grid-cols-2 gap-6">
        <div className="rounded-2xl border border-border bg-card p-6">
          <div className="flex items-center gap-2"><BookOpen className="size-4" /><span className="font-semibold" style={serif}>Changelog</span></div>
          <div className="mt-3 space-y-3 text-sm">
            <div><div className="font-mono text-xs text-muted-foreground">1.0.0 — Native iOS</div><div className="text-muted-foreground">Initial native release: Dashboard, Trips, Packing Lists, Library, Vision Scanner, Outfit Planner, Global Search, Templates, Reminders. SwiftData persistence, on-device Vision, local notifications. Unsigned IPA via GitHub Actions macos-15 with archive+fallback + file validation.</div></div>
            <div className="border-t border-border pt-3"><div className="font-mono text-xs text-muted-foreground">Build</div><div className="text-muted-foreground">XcodeGen, unit + UI tests, artifact + <span className="font-mono">dev</span> prerelease + versioned Release, sha256. Mirror for Gitea and local act. Every main push now has a direct <span className="font-mono">.ipa</span>.</div></div>
          </div>
        </div>
        <div className="rounded-2xl border border-border bg-white p-6">
          <div className="font-semibold" style={serif}>Troubleshooting</div>
          <ul className="mt-3 space-y-2 text-sm text-muted-foreground">
            <li><span className="font-medium text-foreground">Got a .zip not a .ipa?</span> — Use <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="underline underline-offset-4">Releases</a> / <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="underline underline-offset-4">dev</a> for the direct <span className="font-mono">.ipa</span>. Artifacts are outer zips — unwrap once.</li>
            <li><span className="font-medium text-foreground">No IPA at all?</span> — <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="underline underline-offset-4">Actions logs</a> → <span className="font-mono">Archive — unsigned IPA</span> now prints <span className="font-mono">file</span> + <span className="font-mono">unzip -l</span>. Check that <span className="font-mono">Payload/PackWise.app/</span> is present.</li>
            <li><span className="font-medium text-foreground">Install fails?</span> — Unsigned IPAs must be re-signed via AltStore/Sideloadly or TrollStore on supported versions.</li>
            <li><span className="font-medium text-foreground">Vision finds nothing?</span> — Clearer, well-lit photo; Vision is on-device and conservative.</li>
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
            <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="font-mono text-xs underline underline-offset-4">dev</a>
            <span className="text-border">·</span>
            <Link to="/setup" className="inline-flex items-center gap-1">Build guide <ArrowRight className="size-3" /></Link>
          </span>
        </div>
      </footer>
    </div>
  );
}
