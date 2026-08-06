import { useState } from "react";
import { Link } from "react-router";
import { Check, Copy, ExternalLink, Github, Terminal, Smartphone, ArrowRight, AlertTriangle, Sparkles, HardDrive, Repeat } from "lucide-react";
import { toast } from "sonner";

const serif = { fontFamily: "Instrument Serif, Cormorant Garamond, serif" } as const;

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

        <div className="mt-6 rounded-[28px] border border-amber-200 bg-amber-50 p-5 sm:p-6 flex gap-4">
          <AlertTriangle className="size-5 text-amber-700 shrink-0 mt-0.5" />
          <div>
            <div className="font-semibold text-amber-900" style={serif}>No macOS here — the IPA must be built on macOS.</div>
            <p className="text-sm leading-6 text-amber-800 mt-1">
              This preview runs on <span className="font-medium">Linux (Debian)</span>. <code className="font-mono">xcodebuild</code> exists only on <span className="font-medium">macOS + Xcode</span> and returns <code className="font-mono">not found</code> here. This is an Apple platform restriction, not a missing dependency I can install.
              The fix: push to a host that <em>does</em> run macOS — <span className="font-medium">GitHub, Gitea, or your own Mac via <span className="font-mono">act</span></span> — all fully FOSS and producing the same <span className="font-mono">PackWise-unsigned.ipa</span>.
            </p>
          </div>
        </div>

        <h1 className="mt-8 text-[34px] leading-none tracking-[-0.02em]" style={serif}>
          Build the IPA — <span className="italic font-light">choose your host, same artifact</span>
        </h1>
        <p className="mt-3 text-sm leading-6 text-muted-foreground max-w-[76ch]">
          The workflows at <span className="font-mono">.github/workflows/ios.yml</span> and <span className="font-mono">.gitea/workflows/ios.yml</span> are mirrors. Push anywhere — GitHub stabilizes, Gitea keeps you self-hosted, <span className="font-mono">act</span> keeps you fully offline. All three run the same <span className="font-mono">xcodebuild archive</span> and zip <span className="font-mono">Payload/PackWise.app</span>. See <a href="https://docs.gitea.io/en-us/usage/actions/comparison/" target="_blank" rel="noreferrer" className="underline underline-offset-4">Gitea vs GitHub Actions comparison</a> and <a href="https://github.com/nektos/act" target="_blank" rel="noreferrer" className="underline underline-offset-4">nektos/act</a>.
        </p>

        <div className="mt-6 grid lg:grid-cols-3 gap-4">
          <HostCard
            title="GitHub Actions — free"
            desc="No Mac needed on your side. Push to main → macos-15 runner tests + archives → artifact PackWise-unsigned-ipa."
            href="https://github.com/new"
            cta="Create GitHub repo"
            note="Public or private — Actions free tier works for both. Or: Actions → iOS — PackWise → Run workflow."
          />
          <HostCard
            title="Gitea Actions — self-hosted"
            desc="FOSS forge. Enable [actions] in Gitea, add a macOS runner labeled macos, mirror this repo."
            href="https://about.gitea.com/"
            cta="Self-host Gitea"
            note="Docs: about.gitea.com + docs.gitea.io/en-us/usage/actions/act-runner/"
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
            <span className="font-medium text-foreground">Mirroring is easier than rewriting YAML.</span> The two workflow files are intentionally identical in build steps. <span className="font-mono">git remote add gitea https://YOUR_GITEA/YOU/packwise.git</span> and <span className="font-mono">git push gitea main</span> — same build, different host. If one host has an outage, the other still produces the same IPA.
          </div>
        </div>

        <div className="mt-6 rounded-2xl border border-border bg-white p-5 sm:p-6">
          <div className="text-xs font-mono uppercase tracking-widest text-muted-foreground flex items-center gap-2">
            <Terminal className="size-3.5" /> Push to any host — same commands
          </div>
          <p className="text-sm text-muted-foreground mt-2">From your local clone (after exporting/unzipping this project):</p>
          <div className="mt-3">
            <CopyBlock
              label="GitHub"
              text={`git init
git add .
git commit -m "PackWise — native iOS + docs"
git branch -M main
git remote add origin https://github.com/YOU/packwise.git
git push -u origin main
# GitHub → Actions → iOS — PackWise → Run workflow (or auto on push)`}
            />
          </div>
          <div className="mt-3">
            <CopyBlock
              label="Gitea (self-hosted) — add as second remote"
              text={`git remote add gitea https://YOUR_GITEA_HOST/YOU/packwise.git
git push gitea main
# Gitea → Actions → iOS — PackWise (Gitea) → Run`}
            />
          </div>
          <div className="mt-3">
            <CopyBlock
              label="Local act on your Mac (no cloud at all)"
              text={`brew install act
# run the same workflow on this Mac (needs Xcode):
act -W .github/workflows/ios.yml -P macos-15=-self-hosted -P macos=-self-hosted
# or simply:
./ios/build.sh   # → ios/build/PackWise-unsigned.ipa`}
            />
          </div>
          <p className="text-xs text-muted-foreground mt-3">Linux <span className="font-mono">act</span> can lint but cannot compile IPAs — <span className="font-mono">xcodebuild</span> only exists on macOS. This is true for Gitea and GitHub self-hosted runners as well: the runner must be a Mac.</p>
        </div>

        <div className="mt-6 grid md:grid-cols-2 gap-6">
          <div className="rounded-2xl border border-border bg-card p-5">
            <div className="font-semibold flex items-center gap-2" style={serif}><Smartphone className="size-4" /> Sideload (all hosts, same IPA)</div>
            <div className="mt-2 space-y-2 text-sm text-muted-foreground">
              <div><span className="font-medium text-foreground">AltStore:</span> AltServer on Mac/PC → AltStore → My Apps → + → select IPA.</div>
              <div><span className="font-medium text-foreground">Sideloadly:</span> Drag IPA → enter Apple ID for local signing.</div>
              <div><span className="font-medium text-foreground">TrollStore:</span> Open → + → select IPA (where compatible, no re-sign).</div>
            </div>
          </div>
          <div className="rounded-2xl border border-border bg-white p-5">
            <div className="font-semibold flex items-center gap-2" style={serif}><HardDrive className="size-4" /> Verify</div>
            <div className="mt-2 rounded-xl bg-[#1a1a1e] text-zinc-100 p-3 font-mono text-xs leading-5">
              unzip -l PackWise-unsigned.ipa | head<br />
              ls -lh ios/build/PackWise-unsigned.ipa
            </div>
            <p className="text-xs text-muted-foreground mt-3">All hosts produce a zip of <span className="font-mono">Payload/PackWise.app</span>. Verify before distributing.</p>
          </div>
        </div>

        <div className="mt-6 rounded-2xl border border-dashed border-border bg-card p-4 text-xs leading-5 text-muted-foreground">
          <span className="font-medium text-foreground">Why not a browser button that &quot;creates the repo&quot; here?</span> Git/GitHub commands are blocked inside Freebuff by design. The buttons above open the real creation pages; the <span className="font-mono">.actrc</span> and <span className="font-mono">.gitea/workflows</span> in this repo mean you can truly self-host with Gitea or <span className="font-mono">act</span> as FOSS alternatives to GitHub — all documented at the links you shared.
        </div>

        <div className="mt-8 flex flex-wrap gap-3">
          <a href="https://github.com/new" target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-primary text-primary-foreground text-sm font-medium hover:opacity-90 transition">
            <Github className="size-4" /> Create GitHub repo
          </a>
          <a href="https://about.gitea.com/" target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-6 py-3 rounded-full border border-border bg-card text-sm font-medium hover:bg-secondary transition">
            Self-host with Gitea <ExternalLink className="size-3.5" />
          </a>
          <Link to="/#install" className="inline-flex items-center gap-2 px-5 py-3 rounded-full border border-border bg-white text-sm font-medium">
            Back to install docs <ArrowRight className="size-4" />
          </Link>
        </div>
      </div>
    </div>
  );
}
