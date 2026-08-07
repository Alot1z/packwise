import { useState } from "react";
import { Link } from "react-router";
import { Check, Copy, ExternalLink, Github, Terminal, Smartphone, ArrowRight, AlertTriangle, HardDrive, Repeat, Download, Eye } from "lucide-react";
import { toast } from "sonner";

const serif = { fontFamily: "Instrument Serif, Cormorant Garamond, serif" } as const;
const LIVE_REPO = "https://github.com/Alot1z/packwise";
const LIVE_RELEASES = "https://github.com/Alot1z/packwise/releases";
const LIVE_RELEASE_LATEST = "https://github.com/Alot1z/packwise/releases/latest";
const LIVE_ACTIONS = "https://github.com/Alot1z/packwise/actions";

function CopyBlock({ text, label }: { text: string; label?: string }) {
  const [copied, setCopied] = useState(false);
  return (
    <div className="rounded-xl bg-[#1a1a1e] text-zinc-100 p-3 font-mono text-xs leading-5 relative">
      {label && <div className="text-[10px] uppercase tracking-widest text-zinc-400 mb-1">{label}</div>}
      <pre className="whitespace-pre-wrap break-all pr-10">{text}</pre>
      <button
        onClick={async () => { await navigator.clipboard.writeText(text); setCopied(true); toast.success("Copied"); setTimeout(() => setCopied(false), 1500); }}
        className="absolute top-3 right-3 size-7 rounded-lg bg-white/10 hover:bg-white/15 grid place-items-center transition"
        aria-label="Copy"
      >
        {copied ? <Check className="size-3.5" /> : <Copy className="size-3.5" />}
      </button>
    </div>
  );
}

function HostCard({ title, desc, href, cta, note }: { title: string; desc: string; href: string; cta: string; note?: string }) {
  return (
    <div className="rounded-2xl border border-border bg-card p-5">
      <div className="font-semibold" style={serif}>{title}</div>
      <p className="text-sm leading-6 text-muted-foreground mt-1">{desc}</p>
      <a href={href} target="_blank" rel="noreferrer" className="mt-4 inline-flex items-center gap-2 px-4 py-2 rounded-full bg-primary text-primary-foreground text-sm font-medium hover:opacity-90 transition">
        {cta} <ExternalLink className="size-3.5" />
      </a>
      {note && <p className="text-xs text-muted-foreground mt-2">{note}</p>}
    </div>
  );
}

export default function Setup() {
  return (
    <div className="min-h-screen bg-background">
      <div className="max-w-[1020px] mx-auto px-6 py-8">
        <Link to="/" className="text-sm text-muted-foreground hover:text-foreground inline-flex items-center gap-1.5">
          <ArrowRight className="size-3.5 rotate-180" /> Back to docs
        </Link>

        <div className="mt-6 rounded-[28px] border border-emerald-200 bg-emerald-50 p-5 sm:p-6 flex gap-4">
          <Download className="size-5 text-emerald-700 shrink-0 mt-0.5" />
          <div>
            <div className="font-semibold text-emerald-900" style={serif}>Your live repo is the download source — no clone needed.</div>
            <p className="text-sm leading-6 text-emerald-800 mt-1">
              All builds and downloads come from <a href={LIVE_REPO} target="_blank" rel="noreferrer" className="font-mono underline underline-offset-4">Alot1z/packwise</a>. Every push to <span className="font-mono">main</span> rebuilds automatically and syncs to the site’s download buttons. Check <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="underline underline-offset-4">Actions</a> for live logs and <a href={LIVE_RELEASES} target="_blank" rel="noreferrer" className="underline underline-offset-4">Releases</a> for the IPA.
            </p>
          </div>
        </div>

        <div className="mt-4 rounded-[20px] border border-amber-200 bg-amber-50 p-4 flex gap-3">
          <AlertTriangle className="size-4 text-amber-700 shrink-0 mt-0.5" />
          <p className="text-xs leading-5 text-amber-800">
            This preview runs on <span className="font-medium">Linux (Debian)</span> — <code className="font-mono">xcodebuild</code> exists only on <span className="font-medium">macOS + Xcode</span> and returns <code className="font-mono">not found</code> here. Apple restriction, not a missing dependency. The live GitHub/Gitea/<span className="font-mono">act</span> runners below are macOS and do the real build.
          </p>
        </div>

        <h1 className="mt-8 text-[34px] leading-none tracking-[-0.02em]" style={serif}>
          Get & build PackWise — <span className="italic font-light">from the live repo</span>
        </h1>
        <p className="mt-3 text-sm leading-6 text-muted-foreground max-w-[76ch]">
          The download buttons everywhere on this site link to <span className="font-mono">{LIVE_RELEASE_LATEST}</span>. The workflows at <span className="font-mono">.github/workflows/ios.yml</span> and <span className="font-mono">.gitea/workflows/ios.yml</span> are mirrors — same <span className="font-mono">xcodebuild archive + DerivedData fallback</span> → <span className="font-mono">Payload/PackWise.app</span> → <span className="font-mono">PackWise-unsigned.ipa</span>. See <a href="https://docs.gitea.io/en-us/usage/actions/comparison/" target="_blank" rel="noreferrer" className="underline underline-offset-4">Gitea vs GitHub Actions</a> and <a href="https://github.com/nektos/act" target="_blank" rel="noreferrer" className="underline underline-offset-4">nektos/act</a>.
        </p>

        <div className="mt-6 flex flex-wrap gap-3">
          <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-primary text-primary-foreground text-sm font-medium hover:opacity-90 transition">
            <Download className="size-4" /> Download IPA — Latest Release
          </a>
          <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-6 py-3 rounded-full border border-border bg-card text-sm font-medium hover:bg-secondary transition">
            <Eye className="size-4" /> View live build logs
          </a>
          <a href={LIVE_REPO} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-5 py-3 rounded-full border border-border bg-white text-sm font-medium">
            <Github className="size-4" /> Alot1z/packwise
          </a>
        </div>

        <div className="mt-6 grid lg:grid-cols-3 gap-4">
          <HostCard
            title="GitHub Actions — free"
            desc="Already wired to Alot1z/packwise. Push to main → macos-15 runner tests + archives (with fallback) → artifact + Release on tag v*."
            href={LIVE_ACTIONS}
            cta="Open Actions"
            note="Runs on every push to main. Or: Actions → iOS — PackWise → Run workflow."
          />
          <HostCard
            title="Gitea Actions — self-hosted"
            desc="FOSS forge. Enable [actions] in Gitea, add a macOS runner labeled macos, mirror this repo."
            href="https://about.gitea.com/"
            cta="Self-host Gitea"
            note="Workflow at .gitea/workflows/ios.yml — same build steps."
          />
          <HostCard
            title="nektos/act — local"
            desc="Run the same YAML on your own Mac. 100% offline after clone. Requires macOS + Xcode locally."
            href="https://github.com/nektos/act"
            cta="Get act"
            note="On Mac: brew install act → act -W .github/workflows/ios.yml -P macos-15=-self-hosted"
          />
        </div>

        <div className="mt-6 rounded-2xl athena-stone p-5 flex gap-3">
          <Repeat className="size-4 mt-0.5 shrink-0 text-muted-foreground" />
          <div className="text-sm leading-6 text-muted-foreground">
            <span className="font-medium text-foreground">Sync is already wired.</span> The site’s download buttons point at <span className="font-mono">{LIVE_RELEASES}</span>. When GitHub Actions finishes, the new IPA appears there instantly — no manual sync or second repo. Gitea is just a mirror if you want to self-host.
          </div>
        </div>

        <div className="mt-6 rounded-2xl border border-border bg-white p-5 sm:p-6">
          <div className="text-xs font-mono uppercase tracking-widest text-muted-foreground flex items-center gap-2">
            <Terminal className="size-3.5" /> Build & publish (already configured)
          </div>
          <div className="mt-3">
            <CopyBlock
              label="Push — auto-builds the live repo"
              text={`git push origin main
# → Actions on Alot1z/packwise rebuilds → artifact PackWise-unsigned-ipa`}
            />
          </div>
          <div className="mt-3">
            <CopyBlock
              label="Publish a Release (so the site's Download button has a new file)"
              text={`git tag v1.0.0
git push origin v1.0.0
# → GitHub Release v1.0.0 with PackWise-unsigned.ipa + .sha256 attached`}
            />
          </div>
          <div className="mt-3">
            <CopyBlock
              label="Local act on your Mac (no cloud at all)"
              text={`brew install act
act -W .github/workflows/ios.yml -P macos-15=-self-hosted -P macos=-self-hosted
# or simply (on a Mac with Xcode):
./ios/build.sh   # → ios/build/PackWise-unsigned.ipa`}
            />
          </div>
          <p className="text-xs text-muted-foreground mt-3">Linux <span className="font-mono">act</span> can lint but cannot compile IPAs — <span className="font-mono">xcodebuild</span> only exists on macOS. Same for self-hosted runners: the runner must be a Mac.</p>
        </div>

        <div className="mt-6 grid md:grid-cols-2 gap-6">
          <div className="rounded-2xl border border-border bg-card p-5">
            <div className="font-semibold flex items-center gap-2" style={serif}><Smartphone className="size-4" /> Sideload (same IPA, all hosts)</div>
            <div className="mt-2 space-y-2 text-sm text-muted-foreground">
              <div><span className="font-medium text-foreground">AltStore:</span> AltServer on Mac/PC → AltStore → My Apps → + → select IPA.</div>
              <div><span className="font-medium text-foreground">Sideloadly:</span> Drag IPA → enter Apple ID for local signing.</div>
              <div><span className="font-medium text-foreground">TrollStore:</span> Open → + → select IPA (where compatible).</div>
            </div>
            <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="mt-4 inline-flex items-center gap-2 text-xs font-medium px-3 py-1.5 rounded-full bg-primary text-primary-foreground">Download IPA <Download className="size-3" /></a>
          </div>
          <div className="rounded-2xl border border-border bg-white p-5">
            <div className="font-semibold flex items-center gap-2" style={serif}><HardDrive className="size-4" /> Verify & inspect</div>
            <div className="mt-2 rounded-xl bg-[#1a1a1e] text-zinc-100 p-3 font-mono text-xs leading-5">
              unzip -l PackWise-unsigned.ipa | head<br />
              shasum -a 256 PackWise-unsigned.ipa<br />
              ls -lh ios/build/PackWise-unsigned.ipa
            </div>
            <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="mt-3 inline-flex items-center gap-1.5 text-xs text-muted-foreground hover:text-foreground">Read live build logs <ExternalLink className="size-3" /></a>
          </div>
        </div>

        <div className="mt-6 rounded-2xl border border-dashed border-border bg-card p-4 text-xs leading-5 text-muted-foreground">
          <span className="font-medium text-foreground">Why this page exists.</span> The live site (Freebuff preview) cannot run <span className="font-mono">xcodebuild</span> — that’s an Apple platform limit. So all downloads point at the real build host: <span className="font-mono">{LIVE_REPO}</span>. The fix for “Archive did not produce an app bundle” is in the workflow: <span className="font-mono">archive</span> now falls back to a <span className="font-mono">DerivedData build</span> and prints diagnostics — read the full explanation in <span className="font-mono">ios/README.md</span>.
        </div>

        <div className="mt-8 flex flex-wrap gap-3">
          <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-primary text-primary-foreground text-sm font-medium hover:opacity-90 transition">
            <Download className="size-4" /> Download IPA
          </a>
          <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-6 py-3 rounded-full border border-border bg-card text-sm font-medium hover:bg-secondary transition">
            <Terminal className="size-4" /> Live Actions
          </a>
          <Link to="/#install" className="inline-flex items-center gap-2 px-5 py-3 rounded-full border border-border bg-white text-sm font-medium">
            Back to install docs <ArrowRight className="size-4" />
          </Link>
        </div>
      </div>
    </div>
  );
}
