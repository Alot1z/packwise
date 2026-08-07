import { useState } from "react";
import {
  Check,
  Copy,
  Download as DownloadIcon,
  ExternalLink,
  Package,
  Zap,
  Terminal,
  Smartphone,
  AlertTriangle,
  BadgeCheck,
  Shield,
  ArrowRight,
} from "lucide-react";
import { toast } from "sonner";
import {
  SiteNav,
  SiteFooter,
  PageHeader,
  serif,
  LIVE_RELEASES,
  LIVE_RELEASE_LATEST,
  LIVE_RELEASE_DEV,
  LIVE_ACTIONS,
} from "@/components/site-shared";

function CopyBlock({ text, label }: { text: string; label?: string }) {
  const [copied, setCopied] = useState(false);
  return (
    <div className="rounded-xl bg-[#1a1a1e] text-zinc-100 p-3 font-mono text-xs leading-5 relative overflow-hidden border border-white/10">
      {label && <div className="text-[10px] uppercase tracking-widest text-zinc-400 mb-1">{label}</div>}
      <pre className="whitespace-pre-wrap break-all pr-10 text-[11px]">{text}</pre>
      <button
        onClick={async () => {
          await navigator.clipboard.writeText(text);
          setCopied(true);
          toast.success("Copied");
          setTimeout(() => setCopied(false), 1500);
        }}
        className="absolute top-3 right-3 size-7 rounded-lg bg-white/10 hover:bg-white/15 grid place-items-center transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/30"
        aria-label="Copy"
      >
        {copied ? <Check className="size-3.5" aria-hidden /> : <Copy className="size-3.5" aria-hidden />}
      </button>
    </div>
  );
}

export default function Download() {
  return (
    <div className="min-h-screen bg-background text-foreground">
      <SiteNav />
      <main id="main">
        <PageHeader
          kicker="Install"
          title="Get PackWise-unsigned.ipa"
          desc="The IPA is the product. It is built automatically by the live repo — no Apple Developer account is required to generate it. Pick the path below that matches how you prefer to download."
        />

        <section className="max-w-[1180px] mx-auto px-6 pb-10">
          {/* Status */}
          <div className="rounded-2xl border border-emerald-200 bg-emerald-50/90 p-4 flex gap-2.5">
            <BadgeCheck className="size-4 text-emerald-700 shrink-0 mt-0.5" aria-hidden />
            <div className="text-xs leading-5 text-emerald-900">
              <span className="font-semibold">Build status is verified, not assumed.</span> Every IPA is validated before publishing: the
              executable must exist inside <span className="font-mono">Payload/PackWise.app/</span>, be an arm64 device Mach-O, and contain
              no test bundles. If validation fails, the workflow fails — nothing broken is released.
            </div>
          </div>

          <div className="mt-6 grid lg:grid-cols-3 gap-4">
            {/* Direct .ipa */}
            <div className="rounded-2xl border border-border bg-card p-5 flex flex-col">
              <div className="flex items-center gap-2 text-xs font-mono uppercase tracking-widest text-muted-foreground">
                <Zap className="size-3.5" aria-hidden /> Direct .ipa — no unwrap
              </div>
              <div className="font-semibold mt-2" style={serif}>
                GitHub Releases
              </div>
              <p className="text-sm leading-6 text-muted-foreground mt-1.5">
                Every push to <span className="font-mono">main</span> publishes{" "}
                <span className="font-mono">PackWise-unsigned.ipa</span> to the <span className="font-mono">dev</span> prerelease. Tags (
                <span className="font-mono">v*</span>) create versioned Releases.
              </p>
              <div className="mt-4 flex flex-wrap gap-2">
                <a
                  href={LIVE_RELEASE_LATEST}
                  target="_blank"
                  rel="noreferrer"
                  className="inline-flex items-center gap-1.5 text-xs font-medium px-3.5 py-2 rounded-full bg-primary text-primary-foreground hover:opacity-90 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
                >
                  Latest IPA <ExternalLink className="size-3" aria-hidden />
                </a>
                <a
                  href={LIVE_RELEASE_DEV}
                  target="_blank"
                  rel="noreferrer"
                  className="inline-flex items-center gap-1.5 text-xs font-medium px-3.5 py-2 rounded-full border border-border bg-white hover:bg-secondary transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
                >
                  dev — direct <ExternalLink className="size-3" aria-hidden />
                </a>
              </div>
              <div className="mt-4">
                <CopyBlock label="Command line" text={`gh release download dev -R Alot1z/packwise -p "PackWise-unsigned.ipa"`} />
              </div>
            </div>

            {/* Artifact */}
            <div className="rounded-2xl border border-border bg-card p-5 flex flex-col">
              <div className="flex items-center gap-2 text-xs font-mono uppercase tracking-widest text-muted-foreground">
                <Package className="size-3.5" aria-hidden /> Artifact — unwrap once
              </div>
              <div className="font-semibold mt-2" style={serif}>
                Actions
              </div>
              <p className="text-sm leading-6 text-muted-foreground mt-1.5">
                GitHub wraps uploads in an outer <span className="font-mono">.zip</span> container. Download{" "}
                <span className="font-mono">PackWise-unsigned-ipa.zip</span>, unzip once — the inner file is the same{" "}
                <span className="font-mono">.ipa</span>.
              </p>
              <a
                href={LIVE_ACTIONS}
                target="_blank"
                rel="noreferrer"
                className="mt-4 inline-flex items-center gap-1.5 text-xs font-medium px-3.5 py-2 rounded-full border border-border bg-white hover:bg-secondary transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring w-fit"
              >
                Open Actions <ExternalLink className="size-3" aria-hidden />
              </a>
              <div className="mt-4">
                <CopyBlock label="Unwrap" text={`unzip PackWise-unsigned-ipa.zip\nunzip -l PackWise-unsigned.ipa | head`} />
              </div>
            </div>

            {/* Build yourself */}
            <div className="rounded-2xl border border-border bg-card p-5 flex flex-col">
              <div className="flex items-center gap-2 text-xs font-mono uppercase tracking-widest text-muted-foreground">
                <Terminal className="size-3.5" aria-hidden /> Build it yourself
              </div>
              <div className="font-semibold mt-2" style={serif}>
                From source
              </div>
              <p className="text-sm leading-6 text-muted-foreground mt-1.5">
                Reproducible on any Mac with Xcode 16+: same artifact as CI, via{" "}
                <span className="font-mono">ios/build.sh</span>, Gitea Actions, or <span className="font-mono">act</span>.
              </p>
              <a
                href="/build"
                className="mt-4 inline-flex items-center gap-1.5 text-xs font-medium px-3.5 py-2 rounded-full border border-border bg-white hover:bg-secondary transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring w-fit"
              >
                Build guide <ArrowRight className="size-3" aria-hidden />
              </a>
              <div className="mt-4">
                <CopyBlock label="Local build" text={`cd ios && ./build.sh\n# → ios/build/PackWise-unsigned.ipa + .sha256`} />
              </div>
            </div>
          </div>

          {/* Sideload */}
          <div className="mt-8 rounded-[24px] border border-border bg-white p-6 sm:p-7 shadow-sm">
            <div className="text-[11px] font-mono uppercase tracking-[0.14em] text-muted-foreground">Sideload</div>
            <h2 className="mt-2 text-[28px] sm:text-[32px] leading-none tracking-[-0.02em]" style={serif}>
              Install on your iPhone
            </h2>
            <div className="mt-6 grid md:grid-cols-3 gap-4 text-sm">
              <div className="rounded-2xl athena-stone p-5">
                <div className="font-semibold" style={serif}>
                  AltStore
                </div>
                <p className="text-[13px] leading-6 text-muted-foreground mt-2">
                  Install AltServer on a Mac or PC, connect your iPhone, open AltStore → My Apps → + and select the{" "}
                  <span className="font-mono">.ipa</span>. AltStore re-signs locally.
                </p>
              </div>
              <div className="rounded-2xl athena-stone p-5">
                <div className="font-semibold" style={serif}>
                  Sideloadly
                </div>
                <p className="text-[13px] leading-6 text-muted-foreground mt-2">
                  Drag the <span className="font-mono">.ipa</span> onto Sideloadly, enter your Apple ID for local signing, and install.
                  Works on Windows and macOS.
                </p>
              </div>
              <div className="rounded-2xl athena-stone p-5">
                <div className="font-semibold" style={serif}>
                  TrollStore
                </div>
                <p className="text-[13px] leading-6 text-muted-foreground mt-2">
                  Where compatible: open TrollStore → + and select the <span className="font-mono">.ipa</span>. No re-signing needed on
                  supported versions.
                </p>
              </div>
            </div>
            <div className="mt-5 rounded-xl border border-amber-200 bg-amber-50/90 p-4 flex gap-2.5">
              <AlertTriangle className="size-4 text-amber-700 shrink-0 mt-0.5" aria-hidden />
              <p className="text-xs leading-5 text-amber-900">
                Unsigned IPAs must be re-signed by the sideload tool you choose — they are not App Store signed. If a sideloader reports{" "}
                <span className="font-mono">Failed to map …/PackWise: Bad file descriptor</span>, the IPA predates the executable
                validation fix; download the latest{" "}
                <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="font-medium underline underline-offset-4">
                  dev
                </a>{" "}
                build or run <span className="font-mono">./ios/build.sh</span>.
              </p>
            </div>
            <div className="mt-4 rounded-xl bg-[#1a1a1e] text-zinc-100 p-3 font-mono text-xs leading-5 overflow-x-auto border border-white/10">
              <div className="text-zinc-400"># One command verifies ANY download — .ipa, Actions artifact .zip (auto-unwrap), or folder</div>
              <div className="text-emerald-300">
                ./scripts/verify-ipa.sh &lt;downloaded-file&gt; <span className="text-zinc-400"># → ✓ sideload-ready, or ✗ exactly why not</span>
              </div>
              <div className="text-zinc-500 mt-1"># …or manually:</div>
              <div>
                file PackWise-unsigned.ipa <span className="text-zinc-400"># → Zip archive data (correct — .ipa IS a zip of Payload/)</span>
              </div>
              <div>
                unzip -l PackWise-unsigned.ipa | head <span className="text-zinc-400"># → Payload/PackWise.app/PackWise must be listed</span>
              </div>
              <div>
                shasum -a 256 PackWise-unsigned.ipa <span className="text-zinc-400"># → compare with .sha256 from the Release</span>
              </div>
            </div>
            <div className="mt-4 flex flex-wrap gap-2">
              <a
                href={LIVE_RELEASE_LATEST}
                target="_blank"
                rel="noreferrer"
                className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-primary text-primary-foreground text-sm font-medium hover:opacity-90 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
              >
                <DownloadIcon className="size-4" aria-hidden /> Download latest IPA
              </a>
              <a
                href={LIVE_RELEASES}
                target="_blank"
                rel="noreferrer"
                className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-border bg-white text-sm font-medium hover:bg-secondary transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
              >
                All Releases <ExternalLink className="size-3.5" aria-hidden />
              </a>
            </div>
          </div>

          {/* Phone note */}
          <div className="mt-6 rounded-2xl border border-border bg-card p-4 flex gap-3 text-xs leading-5 text-muted-foreground">
            <Smartphone className="size-4 shrink-0 mt-0.5" aria-hidden />
            <span>
              Transfer the <span className="font-mono">.ipa</span> to your iPhone via AirDrop, Files, or a computer, then open it in your
              sideload tool. iOS 17 or later is required.
            </span>
          </div>

          {/* Algorithm picker — one JSON teaches any AI / script the project */}
          <div className="mt-4 rounded-2xl border border-border bg-card p-5">
            <div className="flex items-center gap-2 text-xs font-mono uppercase tracking-widest text-muted-foreground">
              <Package className="size-3.5" aria-hidden /> For scripts, tools, AI — one URL
            </div>
            <div className="font-semibold mt-2" style={serif}>
              Algorithm-friendly manifest
            </div>
            <p className="text-sm leading-6 text-muted-foreground mt-1.5">
              Every published release ships a <span className="font-mono">PackWise-releases.json</span> with the newest stable build, the
              freshest dev prerelease, and recent history. Any tool can fetch one URL — no scraping, no API key, no guesswork.
            </p>
            <div className="mt-3 grid sm:grid-cols-3 gap-2">
              <a
                href={LIVE_RELEASE_DEV + "/download/PackWise-releases.json"}
                target="_blank"
                rel="noreferrer"
                className="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-2 rounded-full border border-border bg-white hover:bg-secondary transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
              >
                dev manifest <ExternalLink className="size-3" aria-hidden />
              </a>
              <a
                href={LIVE_RELEASE_LATEST + "/download/PackWise-releases.json"}
                target="_blank"
                rel="noreferrer"
                className="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-2 rounded-full border border-border bg-white hover:bg-secondary transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
              >
                latest manifest <ExternalLink className="size-3" aria-hidden />
              </a>
              <a
                href="https://api.github.com/repos/Alot1z/packwise/releases"
                target="_blank"
                rel="noreferrer"
                className="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-2 rounded-full border border-border bg-white hover:bg-secondary transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
              >
                GitHub releases API <ExternalLink className="size-3" aria-hidden />
              </a>
            </div>
            <div className="mt-3">
              <CopyBlock
                label="Picker recipe (curl + jq)"
                text={`curl -fsSL https://github.com/Alot1z/packwise/releases/latest/download/PackWise-releases.json \\| jq -r '.latest | "tag=\\(.tag) sha=\\(.sha256) verified=\\(.verified_by_build) notes=\\(.release_notes_url)"'`}
              />
            </div>
          </div>

          {/* Trust band */}
          <div className="mt-4 rounded-xl border border-border bg-secondary/40 p-3 flex flex-wrap items-center gap-3 text-xs text-muted-foreground">
            <Shield className="size-3.5" aria-hidden /> No account · No cloud · No tracking · MIT
            <span className="text-border" aria-hidden>
              ·
            </span>
            <span>Validated before every publish</span>
            <a href="/troubleshooting" className="ml-auto inline-flex items-center gap-1 font-medium hover:text-foreground">
              Troubleshooting <ArrowRight className="size-3" aria-hidden />
            </a>
          </div>
        </section>
      </main>

      <SiteFooter />
    </div>
  );
}
