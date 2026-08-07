import { Link } from "react-router";
import { ArrowRight, Smartphone, Box, BookOpen, Download, Terminal, ExternalLink } from "lucide-react";
const serif = { fontFamily: "Instrument Serif, Cormorant Garamond, serif" } as const;
const LIVE_RELEASE_LATEST = "https://github.com/Alot1z/packwise/releases/latest";
const LIVE_ACTIONS = "https://github.com/Alot1z/packwise/actions";
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
            Packing, trips, library, scanning, and outfit planning all happen inside the native iOS app — built from the Xcode project and delivered as <span className="font-mono">PackWise-unsigned.ipa</span> from <span className="font-mono">Alot1z/packwise</span> Releases. This website does not replicate the app.
          </p>
          <div className="mt-6 flex flex-wrap gap-3">
            <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-primary text-primary-foreground text-sm font-medium">Download IPA <Download className="size-4" /></a>
            <Link to="/setup" className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-border bg-white text-sm font-medium">Build guide <Terminal className="size-4" /></Link>
          </div>
          <div className="mt-6 grid sm:grid-cols-3 gap-3 text-sm">
            <Link to="/" className="rounded-xl athena-stone p-4 flex items-center gap-2"><BookOpen className="size-4" /> Documentation home</Link>
            <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="rounded-xl border border-border bg-white p-4 flex items-center gap-2">Live builds <ExternalLink className="size-3.5" /></a>
            <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="rounded-xl border border-dashed border-border bg-card p-4 flex items-center gap-2"><Smartphone className="size-4" /> Get IPA</a>
          </div>
          <p className="mt-6 text-xs text-muted-foreground">IPA is the product. Downloads live at <span className="font-mono">github.com/Alot1z/packwise/releases</span> and in Actions artifacts.</p>
        </div>
      </div>
    </div>
  );
}
