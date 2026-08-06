import { motion } from "framer-motion";
import { Link } from "react-router";
import { ArrowRight, Check, Layers, Shirt, Search, Sparkles, Shield, Cpu, HardDrive, Scan, Library, Eye } from "lucide-react";

const serif = { fontFamily: "Instrument Serif, Cormorant Garamond, serif" } as const;

export default function Landing() {
  return (
    <div className="min-h-screen bg-background text-foreground selection:bg-[oklch(0.62_0.115_38/0.18)]">
      {/* Nav */}
      <nav className="sticky top-0 z-30 backdrop-blur-xl bg-background/75 border-b border-border/60">
        <div className="max-w-[1180px] mx-auto px-6 h-[58px] flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="size-8 rounded-[10px] bg-primary text-primary-foreground grid place-items-center">
              <Scan className="size-[15px]" />
            </div>
            <span className="text-[16px] font-semibold tracking-[-0.02em]" style={serif}>PackWise</span>
            <span className="hidden sm:inline text-[11px] font-mono tracking-[0.12em] uppercase text-muted-foreground border border-border rounded-full px-2.5 py-0.5 ml-1">Private · On-Device · Offline-First</span>
          </div>
          <div className="flex items-center gap-2">
            <Link to="/dashboard" className="hidden sm:inline text-sm font-medium px-4 py-2 rounded-full hover:bg-secondary transition">Open workspace</Link>
            <Link to="/dashboard" className="text-sm font-medium px-5 py-2 rounded-full bg-primary text-primary-foreground hover:opacity-90 transition inline-flex items-center gap-1.5">
              Start packing <ArrowRight className="size-3.5" />
            </Link>
          </div>
        </div>
      </nav>

      {/* Hero */}
      <section className="max-w-[1180px] mx-auto px-6 pt-12 sm:pt-16 pb-10">
        <div className="grid lg:grid-cols-[1.06fr_0.94fr] gap-10 items-start">
          <div>
            <div className="inline-flex items-center gap-2 text-[11px] tracking-[0.14em] font-mono uppercase text-muted-foreground">
              <span className="size-1.5 rounded-full bg-[oklch(0.62_0.115_38)]" /> Clean · Premium · Technical — Built for one
            </div>
            <h1 className="mt-4 text-[42px] sm:text-[56px] leading-[0.94] tracking-[-0.03em]" style={serif}>
              Pack smarter.<br />
              <span className="italic font-light">Dress for every</span> day.
            </h1>
            <p className="mt-4 text-[15px] leading-6 text-muted-foreground max-w-[54ch]">
              PackWise is a premium, privacy-focused travel companion for iPhone. Intelligent packing lists, outfit planning, and trip organization — all processed and stored directly on your device. No account required, no cloud dependency, and fully useful offline.
            </p>
            <div className="mt-7 flex flex-wrap gap-3">
              <Link to="/dashboard" className="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-primary text-primary-foreground text-sm font-medium hover:opacity-90 transition">
                Open PackWise <ArrowRight className="size-4" />
              </Link>
              <a href="#capabilities" className="inline-flex items-center gap-2 px-6 py-3 rounded-full border border-border bg-card text-sm font-medium hover:bg-secondary transition">
                View capabilities
              </a>
            </div>
            <div className="mt-6 flex flex-wrap items-center gap-4 text-xs text-muted-foreground">
              <span className="inline-flex items-center gap-1.5"><Shield className="size-3.5" /> Private by design</span>
              <span className="inline-flex items-center gap-1.5"><HardDrive className="size-3.5" /> Local storage</span>
              <span className="inline-flex items-center gap-1.5"><Check className="size-3.5" /> Works offline</span>
            </div>
            <div className="mt-3 text-[11px] font-mono tracking-[0.08em] uppercase text-muted-foreground/70">
              Stores on device: trips · lists · items · outfits · templates · photos · notes · progress
            </div>
          </div>

          {/* Preview panel */}
          <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.55 }} className="athena-paper rounded-[28px] p-5 sm:p-6 border border-white/60 shadow-[0_20px_60px_-24px_oklch(0.3_0.05_42/0.25)]">
            <div className="flex items-center justify-between">
              <span className="text-[11px] font-mono uppercase tracking-[0.14em] text-muted-foreground">Your workspace</span>
              <span className="rounded-full bg-white border border-border px-2.5 py-1 text-[11px] font-medium inline-flex items-center gap-1.5"><span className="size-1.5 rounded-full bg-emerald-500" /> On device</span>
            </div>

            <div className="mt-4 grid grid-cols-3 gap-3">
              {[
                { city: "Kyoto", date: "Apr 12 — 18", status: "packing", prog: 62 },
                { city: "Lisbon", date: "May 03 — 07", status: "planning", prog: 18 },
                { city: "Hudson", date: "Jun 14 — 16", status: "ready", prog: 100 },
              ].map((t) => (
                <div key={t.city} className={`rounded-2xl p-3 border ${t.status==="ready" ? "bg-primary text-primary-foreground border-primary" : "bg-white border-border/70"}`}>
                  <div className="text-[11px] font-mono uppercase tracking-widest opacity-60">{t.status}</div>
                  <div className="text-[16px] font-semibold mt-1" style={serif}>{t.city}</div>
                  <div className="text-xs opacity-60">{t.date}</div>
                  <div className="mt-3 h-1.5 rounded-full bg-black/10 overflow-hidden"><div className="h-full bg-[oklch(0.62_0.115_38)]" style={{ width: `${t.prog}%` }} /></div>
                </div>
              ))}
            </div>

            <div className="mt-5 rounded-2xl bg-white border border-border p-4">
              <div className="flex items-center gap-2 text-xs font-medium">
                <span className="size-6 rounded-full bg-secondary grid place-items-center"><Shirt className="size-3.5" /></span>
                Outfit: Arrival — Day 1 · 4 items
                <span className="ml-auto text-[11px] font-mono uppercase tracking-widest text-muted-foreground">Detail view</span>
              </div>
              <div className="mt-3 grid grid-cols-5 gap-2">
                {["Linen shirt","Wool trouser","Loafer","Silk scarf","Trench"].map(n=>(
                  <div key={n} className="rounded-xl athena-stone p-2 text-center">
                    <div className="size-10 mx-auto rounded-lg bg-white border border-border grid place-items-center text-muted-foreground">
                      <Eye className="size-4" />
                    </div>
                    <div className="text-[10px] leading-tight mt-1.5 line-clamp-2">{n}</div>
                  </div>
                ))}
              </div>
              <div className="mt-3 flex items-center gap-2 text-[11px] font-mono text-muted-foreground">
                <Cpu className="size-3" /> Local intelligence · No network needed
              </div>
            </div>
          </motion.div>
        </div>
      </section>

      {/* Capabilities */}
      <section id="capabilities" className="max-w-[1180px] mx-auto px-6 pb-10">
        <div className="athena-rule mb-8" />
        <div className="flex items-end justify-between gap-4 mb-6">
          <h2 className="text-[26px] leading-none" style={serif}>Calm, technical, <span className="italic font-light">precisely organized</span></h2>
          <span className="hidden sm:inline text-xs font-mono uppercase tracking-[0.14em] text-muted-foreground">Capabilities</span>
        </div>
        <div className="grid md:grid-cols-3 gap-4">
          {[
            { icon: Layers, title: "Intelligent packing lists", desc: "Create structured lists by category — Essentials, Clothing, Tech, Documents — with quantities, notes, and priority. Suggestions stay on device." },
            { icon: Eye, title: "Item detail pages", desc: "Each item has its own detail view with photos, notes, and status. Tap to inspect, edit, and track exactly what is packed." },
            { icon: Shirt, title: "Outfit planning", desc: "Compose outfits directly from your packing list. Assign looks to days and identify gaps before departure." },
            { icon: Search, title: "Browse and search", desc: "Instant search and precise filtering across trips and items. Find anything by name, category, or essentials." },
            { icon: Library, title: "Personal dashboard", desc: "A single, private dashboard for all trips. Progress, upcoming departures, and packing status at a glance." },
            { icon: HardDrive, title: "Local creation and upload", desc: "Add custom items, photos, lists, and notes directly on device. Everything is stored locally and remains yours." },
          ].map(f=>(
            <div key={f.title} className="rounded-2xl bg-card border border-border p-5">
              <div className="size-8 rounded-lg bg-secondary grid place-items-center"><f.icon className="size-4" /></div>
              <div className="font-semibold mt-3" style={serif}>{f.title}</div>
              <div className="text-sm leading-6 text-muted-foreground mt-1">{f.desc}</div>
            </div>
          ))}
        </div>

        {/* Technical strip */}
        <div className="mt-6 grid md:grid-cols-3 gap-4">
          {[
            { k:"Architecture", v:"SwiftUI · Local database · Offline operation · Fast launch" },
            { k:"Privacy", v:"No mandatory login · No required APIs · Complete local ownership" },
            { k:"Performance", v:"On-device processing · Free local intelligence · Works without internet" },
          ].map(s=>(
            <div key={s.k} className="rounded-2xl athena-stone p-4">
              <div className="text-[11px] font-mono uppercase tracking-widest text-muted-foreground">{s.k}</div>
              <div className="text-sm leading-6 mt-1">{s.v}</div>
            </div>
          ))}
        </div>
      </section>

      {/* How it works */}
      <section className="max-w-[1180px] mx-auto px-6 pb-14">
        <div className="rounded-[28px] border border-border bg-white p-6 sm:p-8">
          <div className="flex flex-wrap items-end justify-between gap-4">
            <h2 className="text-[28px] leading-none" style={serif}>From idea to <span className="italic font-light">departure</span></h2>
            <span className="text-xs font-mono uppercase tracking-[0.14em] text-muted-foreground">Workflow</span>
          </div>
          <div className="grid md:grid-cols-3 gap-6 mt-6">
            {[
              { n:"01", t:"Plan the trip", p:"Add destination, dates, and purpose. PackWise prepares a structured, reusable foundation." },
              { n:"02", t:"Pack with clarity", p:"Add items and photos, track progress, and refine by category or priority. Your list stays orderly." },
              { n:"03", t:"Coordinate every day", p:"Build outfits from what you packed and review each day with confidence before you leave." },
            ].map(s=>(
              <div key={s.n} className="rounded-2xl athena-stone p-5">
                <div className="text-xs font-mono tracking-widest text-muted-foreground">{s.n}</div>
                <div className="font-semibold mt-1" style={serif}>{s.t}</div>
                <div className="text-sm text-muted-foreground mt-1 leading-6">{s.p}</div>
              </div>
            ))}
          </div>
          <div className="mt-6 flex flex-wrap gap-3">
            <Link to="/dashboard" className="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-primary text-primary-foreground text-sm font-medium hover:opacity-90 transition">
              Open your PackWise workspace <ArrowRight className="size-4" />
            </Link>
            <span className="inline-flex items-center gap-2 text-xs text-muted-foreground px-2">
              <Sparkles className="size-3.5" /> Premium utility, not a marketing experiment. Quietly reliable.
            </span>
          </div>
        </div>
      </section>

      <section className="max-w-[1180px] mx-auto px-6 pb-10">
        <div className="rounded-[24px] border border-border bg-card p-6 sm:p-7 flex flex-wrap items-center justify-between gap-4">
          <div>
            <div className="font-semibold" style={serif}>iOS build — unsigned IPA via GitHub Actions</div>
            <p className="text-sm leading-6 text-muted-foreground mt-1 max-w-[62ch]">The native SwiftUI app is fully on-device (SwiftData, offline-first, no mandatory login). A macOS runner builds an unsigned IPA on every push — usable for sideloading with AltStore, Sideloadly, or TrollStore. No IPA is claimed as downloadable until the workflow succeeds; TestFlight is not claimed until a signed build is actually processed by Apple.</p>
            <p className="text-xs font-mono text-muted-foreground mt-2">Workflow: <span className="font-medium">.github/workflows/ios.yml</span> · Artifact: <span className="font-medium">PackWise-unsigned-ipa</span> · Local: <span className="font-medium">ios/build.sh</span></p>
          </div>
          <a href="https://github.com" target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-border bg-white text-sm font-medium hover:bg-secondary transition">View Actions &amp; Releases <ArrowRight className="size-4" /></a>
        </div>
      </section>

      <footer className="border-t border-border/70">
        <div className="max-w-[1180px] mx-auto px-6 py-8 flex flex-wrap items-center justify-between gap-4 text-sm text-muted-foreground">
          <span>PackWise — a private, on-device reinterpretation. Your trips and lists remain on your device.</span>
          <Link to="/dashboard" className="inline-flex items-center gap-1.5 font-medium text-foreground">Go to workspace <ArrowRight className="size-4" /></Link>
        </div>
      </footer>
    </div>
  );
}
