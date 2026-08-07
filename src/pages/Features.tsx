import { motion, useReducedMotion } from "framer-motion";
import { Shield, HardDrive, Eye, Shirt, Library, Layers, Search, CalendarDays, Bell, Box, FileText, Download } from "lucide-react";
import { SiteNav, SiteFooter, PageHeader, serif, LIVE_RELEASE_LATEST } from "@/components/site-shared";

const features = [
  {
    icon: CalendarDays,
    title: "Trip management",
    desc: "Create, edit, and delete trips with destination, dates, activities, climate notes, and a category. View trip history, duplicate a past trip for a repeat journey, and apply a template in one tap. Trip status moves from planning → packing → ready → archived as you prepare.",
  },
  {
    icon: Layers,
    title: "Smart packing lists",
    desc: "Per-trip lists grouped by category: Clothing, Electronics, Toiletries, Documents, Medical, Accessories, Outdoor, plus custom categories. Each item carries a quantity, packed state, essential flag, and notes. Search, sort, and filter by category or packed status; watch progress fill in.",
  },
  {
    icon: Library,
    title: "Personal item library",
    desc: "A private library of your own gear: add photos, notes, a category, and favorites. Any library item can be copied into any trip, so your hiking boots appear in every hiking trip without retyping. Everything stays on device.",
  },
  {
    icon: Eye,
    title: "On-device Vision scanning",
    desc: "Import a photo or scan gear with the camera. Apple Vision runs locally on the phone (VNClassifyImageRequest) and suggests packing items with a confidence score. You review every suggestion and confirm before anything is added — no cloud processing, no silent changes.",
  },
  {
    icon: Shirt,
    title: "Outfit planner",
    desc: "Compose outfits from the items already on your packing list, assign them to trip days, and preview them later. Reuse an outfit on another day or on a future trip. Planning happens against what you actually packed.",
  },
  {
    icon: Search,
    title: "Global search",
    desc: "One local search across trips, items, categories, outfits, library items, and templates. Filter and sort results, jump straight to the detail screen. Works fully offline.",
  },
  {
    icon: Box,
    title: "Dashboard",
    desc: "Your home screen: upcoming trips, packing progress bars, missing essentials, recent activity, and quick actions. Local recommendations surface items you might have forgotten — all computed on device from your trip data.",
  },
  {
    icon: FileText,
    title: "Templates",
    desc: "Starter templates for a weekend city trip, business travel, beach vacation, hiking, and international travel — plus your own custom templates. Create, edit, duplicate, and apply any template to a trip to seed its packing list.",
  },
  {
    icon: Bell,
    title: "Reminders",
    desc: "Local notifications via Apple UserNotifications: packing reminders, preparation reminders before departure, and custom reminders. Scheduled quietly on device — no server involved.",
  },
];

export default function Features() {
  const reduceMotion = useReducedMotion();
  return (
    <div className="min-h-screen bg-background text-foreground">
      <SiteNav />
      <main id="main">
        <PageHeader
          kicker="Inside the IPA"
          title="Every feature lives in the native app"
          desc="None of this depends on this website or any server. The complete product is PackWise-unsigned.ipa — install it and every capability below is on your iPhone, offline."
        />

        <section className="max-w-[1180px] mx-auto px-6 pb-10">
          <div className="grid md:grid-cols-2 gap-4">
            {features.map((f) => (
              <motion.div
                key={f.title}
                whileHover={reduceMotion ? undefined : { y: -2 }}
                transition={{ duration: reduceMotion ? 0 : 0.2 }}
                className="rounded-2xl bg-card border border-border p-5 hover:shadow-[0_8px_30px_-12px_oklch(0.3_0.05_42/0.2)] transition-shadow"
              >
                <div className="size-9 rounded-xl bg-secondary grid place-items-center border border-border/50">
                  <f.icon className="size-[18px]" aria-hidden />
                </div>
                <div className="font-semibold mt-3.5 text-[15px]" style={serif}>
                  {f.title}
                </div>
                <div className="text-[13.5px] leading-[22px] text-muted-foreground mt-1.5">{f.desc}</div>
              </motion.div>
            ))}
          </div>

          <div className="mt-8 rounded-2xl border border-border bg-card p-5 flex flex-wrap items-center gap-4">
            <div className="flex items-center gap-2 text-sm text-muted-foreground">
              <Shield className="size-4" aria-hidden /> Private by design
            </div>
            <div className="flex items-center gap-2 text-sm text-muted-foreground">
              <HardDrive className="size-4" aria-hidden /> SwiftData on device
            </div>
            <div className="flex items-center gap-2 text-sm text-muted-foreground">
              <Eye className="size-4" aria-hidden /> Vision on device
            </div>
            <a
              href={LIVE_RELEASE_LATEST}
              target="_blank"
              rel="noreferrer"
              className="ml-auto inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-primary text-primary-foreground text-sm font-medium hover:opacity-90 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
            >
              <Download className="size-4" aria-hidden /> Download IPA — Latest
            </a>
          </div>
        </section>
      </main>

      <SiteFooter />
    </div>
  );
}
