import { Link } from "react-router";
import { ArrowRight, Smartphone, Box, BookOpen, Download, Terminal, ExternalLink, Package, Zap } from "lucide-react";
const serif = { fontFamily: "Instrument Serif, Cormorant Garamond, serif" } as const;
const LIVE_RELEASE_LATEST = "https://github.com/Alot1z/packwise/releases/latest";
const LIVE_RELEASE_DEV = "https://github.com/Alot1z/packwise/releases/tag/dev";
const LIVE_ACTIONS = "https://github.com/Alot1z/packwise/actions";
export default function Dashboard() {
  return (
    <div className="min-h-screen bg-background">
      <div className="max-w-[760px] mx-auto px-6 py-16">
        <div className="rounded-[24px] border border-border bg-card p-8 shadow-sm">
          <div className="inline-flex items-center gap-2 text-[11px] font-mono uppercase tracking-[0.14em] text-muted-foreground">
            <Box className="size-3.5" /> Documentation only
          </div>
          <h1 className="mt-3 text-[30px] leading-none tracking-[-0.02em]" style={serif}>PackWise lives on your iPhone.</h1>
          <p className="mt-3 text-sm leading-6 text-muted-foreground">
            Packing, trips, library, scanning, and outfit planning all happen inside the native iOS app — built from the Xcode project and delivered as <span className="font-mono">PackWise-unsigned.ipa</span> from <span className="font-mono">Alot1z/packwise</span> Releases. This website does not replicate the app.
          </p>
          <div className="mt-2 rounded-xl border border-amber-200 bg-amber-50 px-3 py-2.5 flex gap-2 text-xs leading-5 text-amber-800">
            <Package className="size-3.5 shrink-0 mt-0.5 text-amber-700" />
            <span>Got a <span className="font-mono">.zip</span> from Actions? That&apos;s the outer container — unzip it to get the <span className="font-mono">.ipa</span>. Direct <span className="font-mono">.ipa</span> (no unwrap): <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="underline underline-offset-4 font-medium">Releases → Latest</a> or <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="underline underline-offset-4 font-medium">dev</a>.</span>
          </div>
          <div className="mt-6 flex flex-wrap gap-3">
            <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-primary text-primary-foreground text-sm font-medium shadow-sm">Download IPA <Download className="size-4" /></a>
            <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 px-4 py-2.5 rounded-full border border-border bg-white text-sm font-medium"><Zap className="size-4" /> dev</a>
            <Link to="/setup" className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-border bg-white text-sm font-medium">Build guide <Terminal className="size-4" /></Link>
          </div>
          <div className="mt-6 grid sm:grid-cols-3 gap-3 text-sm">
            <Link to="/" className="rounded-xl athena-stone p-4 flex items-center gap-2 hover:shadow-sm transition-shadow"><BookOpen className="size-4" /> Docs home</Link>
            <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="rounded-xl border border-border bg-white p-4 flex items-center gap-2 hover:bg-secondary/50 transition-colors">Live builds <ExternalLink className="size-3.5" /></a>
            <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="rounded-xl border border-dashed border-border bg-card p-4 flex items-center gap-2 hover:border-primary/30 transition-colors"><Smartphone className="size-4" /> Get .ipa (dev)</a>
          </div>
          <p className="mt-6 text-xs text-muted-foreground leading-5">IPA is the product. Direct <span className="font-mono">.ipa</span>: <span className="font-mono">releases/latest</span> + <span className="font-mono">releases/tag/dev</span> · Artifact: <span className="font-mono">PackWise-unsigned-ipa.zip</span> (unwrap). <Link to="/#install" className="underline underline-offset-4">Install guide →</Link></p>
          <div className="mt-3 flex gap-2">
            <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="text-xs font-mono underline underline-offset-4 text-muted-foreground">releases/latest</a>
            <span className="text-border text-xs">·</span>
            <Link to="/" className="text-xs inline-flex items-center gap-1">Overview <ArrowRight className="size-3" /></Link>
          </div>
        </div>
      </div>
    </div>
  );
}
