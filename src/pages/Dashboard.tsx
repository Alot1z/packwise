import { Link } from "react-router";
import { ArrowRight, Smartphone, Box, BookOpen, Github } from "lucide-react";
const serif = { fontFamily: "Instrument Serif, Cormorant Garamond, serif" } as const;
export default function Dashboard() {
  return (
    <div className="min-h-screen bg-background">
      <div className="max-w-[760px] mx-auto px-6 py-16">
        <div className="rounded-[24px] border border-border bg-card p-8">
          <div className="inline-flex items-center gap-2 text-[11px] font-mono uppercase tracking-[0.14em] text-muted-foreground">
            <Box className="size-3.5" /> Documentation only
          </div>
          <h1 className="mt-3 text-[30px] leading-none" style={serif}>PackWise lives on your iPhone.</h1>
          <p className="mt-3 text-sm leading-6 text-muted-foreground">
            Packing, trips, library, scanning, and outfit planning all happen inside the native iOS app — built from the Xcode project and delivered as <span className="font-mono">PackWise-unsigned.ipa</span>. This website does not replicate the app.
          </p>
          <div className="mt-6 flex flex-wrap gap-3">
            <Link to="/#install" className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-primary text-primary-foreground text-sm font-medium">Install the IPA <ArrowRight className="size-4" /></Link>
            <Link to="/#build" className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-border bg-white text-sm font-medium">Build guide</Link>
          </div>
          <div className="mt-6 grid sm:grid-cols-3 gap-3 text-sm">
            <Link to="/" className="rounded-xl athena-stone p-4 flex items-center gap-2"><BookOpen className="size-4" /> Documentation home</Link>
            <a href="https://github.com" target="_blank" rel="noreferrer" className="rounded-xl border border-border bg-white p-4 flex items-center gap-2"><Github className="size-4" /> GitHub &amp; Actions</a>
            <span className="rounded-xl border border-dashed border-border bg-card p-4 flex items-center gap-2 text-muted-foreground"><Smartphone className="size-4" /> Get PackWise on iOS</span>
          </div>
          <p className="mt-6 text-xs text-muted-foreground">IPA is the product. This site explains the project, architecture, installation, and build process.</p>
        </div>
      </div>
    </div>
  );
}
