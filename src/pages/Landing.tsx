import { motion } from "framer-motion";
import { Link } from "react-router";
import { ArrowRight, Check, Layers, Sparkles, Sun, Luggage, Shirt, CalendarDays, Share2, Search, Download } from "lucide-react";

const serif = { fontFamily: "Instrument Serif, Cormorant Garamond, serif" } as const;

export default function Landing() {
  return (
    <div className="min-h-screen bg-background text-foreground selection:bg-[oklch(0.62_0.115_38/0.18)]">
      {/* Nav */}
      <nav className="sticky top-0 z-30 backdrop-blur-xl bg-background/70 border-b border-border/60">
        <div className="max-w-[1180px] mx-auto px-6 h-[58px] flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="size-8 rounded-lg bg-primary text-primary-foreground grid place-items-center">
              <Luggage className="size-[15px]" />
            </div>
            <span className="text-[15px] font-semibold tracking-tight" style={serif}>FULLPACK</span>
            <span className="hidden sm:inline text-xs text-muted-foreground border border-border rounded-full px-2 py-0.5 ml-1">Open · Self-hostable</span>
          </div>
          <div className="flex items-center gap-2">
            <Link to="/auth" className="text-sm font-medium px-4 py-2 rounded-full hover:bg-secondary transition">Sign in</Link>
            <Link to="/auth" className="text-sm font-medium px-5 py-2 rounded-full bg-primary text-primary-foreground hover:opacity-90 transition flex items-center gap-1.5">
              Open packs <ArrowRight className="size-3.5" />
            </Link>
          </div>
        </div>
      </nav>

      {/* Hero */}
      <section className="max-w-[1180px] mx-auto px-6 pt-12 pb-10">
        <div className="grid lg:grid-cols-[1.05fr_0.95fr] gap-10 items-start">
          <div>
            <div className="inline-flex items-center gap-2 text-[11px] tracking-[0.14em] font-mono uppercase text-muted-foreground">
              <span className="size-1.5 rounded-full bg-[oklch(0.62_0.115_38)]" /> Athena Edition — Calm packing, composed
            </div>
            <h1 className="mt-4 text-[44px] sm:text-[56px] leading-[0.95] tracking-[-0.03em]" style={serif}>
              Pack <span className="italic font-light">with</span> intention.<br />
              Dress the <span className="italic font-light">days</span> ahead.
            </h1>
            <p className="mt-4 text-[15px] leading-6 text-muted-foreground max-w-[52ch]">
              An open, original reimagining of the FullPack workflow — trips, capsules, checklists and outfits in one calm workspace. No proprietary assets, just the habits that make travel effortless.
            </p>
            <div className="mt-7 flex flex-wrap gap-3">
              <Link to="/auth" className="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-primary text-primary-foreground text-sm font-medium hover:opacity-90 transition">
                Start packing <ArrowRight className="size-4" />
              </Link>
              <a href="#features" className="inline-flex items-center gap-2 px-6 py-3 rounded-full border border-border bg-card text-sm font-medium hover:bg-secondary transition">
                Explore features
              </a>
            </div>
            <div className="mt-6 flex items-center gap-5 text-xs text-muted-foreground">
              <span className="inline-flex items-center gap-1.5"><Check className="size-3.5" /> Offline-friendly</span>
              <span className="inline-flex items-center gap-1.5"><Check className="size-3.5" /> Export · Import</span>
              <span className="inline-flex items-center gap-1.5"><Check className="size-3.5" /> Templates</span>
            </div>
          </div>

          {/* Hero card collage — Warm Athena paper */}
          <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.6 }} className="athena-paper rounded-[28px] p-5 sm:p-6 border border-white/60 shadow-[0_20px_60px_-24px_oklch(0.3_0.05_42/0.25)]">
            <div className="flex items-center justify-between text-xs tracking-wide">
              <span className="font-mono uppercase tracking-[0.14em] text-muted-foreground">Upcoming</span>
              <span className="rounded-full bg-white border border-border px-2.5 py-1 text-[11px] font-medium">3 trips · 68% packed</span>
            </div>
            <div className="mt-4 grid grid-cols-3 gap-3">
              {[
                { city: "Kyoto", date: "Apr 12 — 18", status: "packing", tone: "bg-white" },
                { city: "Lisbon", date: "May 03 — 07", status: "planning", tone: "bg-white" },
                { city: "Hudson Valley", date: "Jun 14 — 16", status: "ready", tone: "bg-primary text-primary-foreground" },
              ].map((t) => (
                <div key={t.city} className={`rounded-2xl p-3 border border-border/70 ${t.tone}`}>
                  <div className="text-[11px] font-mono uppercase tracking-widest opacity-60">{t.status}</div>
                  <div className="text-[16px] font-semibold mt-1" style={serif}>{t.city}</div>
                  <div className="text-xs opacity-60">{t.date}</div>
                  <div className="mt-3 h-1.5 rounded-full bg-black/10 overflow-hidden"><div className="h-full bg-[oklch(0.62_0.115_38)]" style={{ width: t.status === "ready" ? "100%" : t.status === "packing" ? "62%" : "18%" }} /></div>
                </div>
              ))}
            </div>
            <div className="mt-5 rounded-2xl bg-white border border-border p-4">
              <div className="flex items-center gap-2 text-xs font-medium">
                <div className="size-6 rounded-full bg-secondary grid place-items-center"><Shirt className="size-3.5" /></div>
                Capsule — 12 items · 5 outfits
                <span className="ml-auto text-[11px] font-mono uppercase tracking-widest text-muted-foreground">Athena system</span>
              </div>
              <div className="mt-3 grid grid-cols-5 gap-2">
                {["Linen shirt","Wool trouser","Loafer","Silk scarf","Trench"].map(n=>(
                  <div key={n} className="rounded-xl athena-stone p-2 text-center">
                    <div className="size-10 mx-auto rounded-lg bg-white border border-border grid place-items-center text-muted-foreground">
                      <Shirt className="size-4" />
                    </div>
                    <div className="text-[10px] leading-tight mt-1.5 line-clamp-2">{n}</div>
                  </div>
                ))}
              </div>
            </div>
          </motion.div>
        </div>
      </section>

      {/* Feature grid */}
      <section id="features" className="max-w-[1180px] mx-auto px-6 pb-10">
        <div className="athena-rule mb-8" />
        <div className="grid md:grid-cols-3 gap-4">
          {[
            { icon: Layers, k: "Lists & categories", d: "Organise by Essentials, Clothing, Tech, Toiletries. Quantities, notes, reorder — fast capture." },
            { icon: Shirt, k: "Outfits from items", d: "Compose day-by-day looks from your checklist. See what's unworn, spot gaps before you go." },
            { icon: Sparkles, k: "Templates", d: "Save any trip as a reusable template. Weekend, work, summer — apply in one tap." },
            { icon: Search, k: "Search & filter", d: "Find anything instantly. Filter by packed, essential, or category." },
            { icon: Share2, k: "Share & sync", d: "Share a read-only link or export JSON. Self-hostable and portable." },
            { icon: Download, k: "Import · Export", d: "Bring lists in, take them out. Your data stays yours." },
          ].map(f=>(
            <div key={f.k} className="rounded-2xl bg-card border border-border p-5">
              <div className="size-8 rounded-lg bg-secondary grid place-items-center"><f.icon className="size-4" /></div>
              <div className="font-semibold mt-3" style={serif}>{f.k}</div>
              <div className="text-sm leading-6 text-muted-foreground mt-1">{f.d}</div>
            </div>
          ))}
        </div>
      </section>

      {/* How it works */}
      <section className="max-w-[1180px] mx-auto px-6 pb-14">
        <div className="rounded-[28px] border border-border bg-white p-6 sm:p-8">
          <div className="flex flex-wrap items-end justify-between gap-4">
            <h2 className="text-[28px] leading-none" style={serif}>Three moves, <span className="italic font-light">travel ready</span></h2>
            <span className="text-xs font-mono uppercase tracking-[0.14em] text-muted-foreground">Workflow</span>
          </div>
          <div className="grid md:grid-cols-3 gap-6 mt-6">
            {[
              { n: "01", t: "Create a trip", p: "Title, destination, dates, purpose. Choose a cover tone." },
              { n: "02", t: "Pack & compose", p: "Add items, tick packed, bundle outfits for each day." },
              { n: "03", t: "Carry it with you", p: "Track progress, share or export. Duplicate for next time." },
            ].map(s=>(
              <div key={s.n} className="rounded-2xl athena-stone p-5">
                <div className="text-xs font-mono tracking-widest text-muted-foreground">{s.n}</div>
                <div className="font-semibold mt-1" style={serif}>{s.t}</div>
                <div className="text-sm text-muted-foreground mt-1">{s.p}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      <footer className="border-t border-border/70">
        <div className="max-w-[1180px] mx-auto px-6 py-8 flex flex-wrap items-center justify-between gap-4 text-sm text-muted-foreground">
          <span>Original open implementation — inspired by FullPack workflows, not its branding or assets.</span>
          <Link to="/auth" className="inline-flex items-center gap-1.5 font-medium text-foreground">Go to workspace <ArrowRight className="size-4" /></Link>
        </div>
      </footer>
    </div>
  );
}
