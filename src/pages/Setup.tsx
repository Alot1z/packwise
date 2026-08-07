import { useState } from "react";
import { Link } from "react-router";
import { Check, Copy, ExternalLink, Github, Terminal, Smartphone, ArrowRight, AlertTriangle, HardDrive, Repeat, Download, Eye, Package, Zap } from "lucide-react";
import { toast } from "sonner";

const serif = { fontFamily: "Instrument Serif, Cormorant Garamond, serif" } as const;
const LIVE_REPO = "https://github.com/Alot1z/packwise";
const LIVE_RELEASES = "https://github.com/Alot1z/packwise/releases";
const LIVE_RELEASE_LATEST = "https://github.com/Alot1z/packwise/releases/latest";
const LIVE_RELEASE_DEV = "https://github.com/Alot1z/packwise/releases/tag/dev";
const LIVE_ACTIONS = "https://github.com/Alot1z/packwise/actions";

function CopyBlock({ text, label }: { text: string; label?: string }) {
  const [copied, setCopied] = useState(false);
  return (
    <div className="rounded-xl bg-[#1a1a1e] text-zinc-100 p-3 font-mono text-xs leading-5 relative overflow-hidden">
      {label && <div className="text-[10px] uppercase tracking-widest text-zinc-400 mb-1">{label}</div>}
      <pre className="whitespace-pre-wrap break-all pr-10 text-[11px]">{text}</pre>
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
    <div className="rounded-2xl border border-border bg-card p-5 hover:shadow-sm transition-shadow">
      <div className="font-semibold" style={serif}>{title}</div>
      <p className="text-sm leading-6 text-muted-foreground mt-1.5">{desc}</p>
      <a href={href} target="_blank" rel="noreferrer" className="mt-4 inline-flex items-center gap-2 px-4 py-2 rounded-full bg-primary text-primary-foreground text-sm font-medium hover:opacity-90 transition">
        {cta} <ExternalLink className="size-3.5" />
      </a>
      {note && <p className="text-xs text-muted-foreground mt-2.5 leading-4">{note}</p>}
    </div>
  );
}

export default function Setup() {
  return (
    <div className="min-h-screen bg-background">
      <div className="max-w-[1040px] mx-auto px-6 py-8">
        <Link to="/" className="text-sm text-muted-foreground hover:text-foreground inline-flex items-center gap-1.5">
          <ArrowRight className="size-3.5 rotate-180" /> Back to docs
        </Link>

        <div className="mt-6 rounded-[24px] border border-emerald-200 bg-emerald-50 p-5 sm:p-6 flex gap-4">
          <Download className="size-5 text-emerald-700 shrink-0 mt-0.5" />
          <div>
            <div className="font-semibold text-emerald-900" style={serif}>Your live repo is the download source — no clone needed.</div>
            <p className="text-sm leading-6 text-emerald-800 mt-1">
              All builds come from <a href={LIVE_REPO} target="_blank" rel="noreferrer" className="font-mono underline underline-offset-4">Alot1z/packwise</a>. Every push to <span className="font-mono">main</span> rebuilds — check <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="underline underline-offset-4">Actions</a> for logs and <a href={LIVE_RELEASES} target="_blank" rel="noreferrer" className="underline underline-offset-4">Releases</a> for the direct <span className="font-mono">.ipa</span> (<a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="underline underline-offset-4">dev</a> updates on every main push).
            </p>
          </div>
        </div>

        {/* Zip vs IPA — the core of fix B */}
        <div className="mt-4 rounded-[20px] border border-amber-200 bg-amber-50 p-5">
          <div className="flex gap-3">
            <Package className="size-5 text-amber-700 shrink-0 mt-0.5" />
            <div>
              <div className="font-semibold text-amber-900 text-sm" style={serif}>Why you got a <span className="font-mono">.zip</span> — and where the direct <span className="font-mono">.ipa</span> is</div>
              <p className="text-xs leading-5 text-amber-800 mt-1.5">
                <span className="font-medium">PackWise always builds a true <span className="font-mono">PackWise-unsigned.ipa</span></span> (a <span className="font-mono">Payload/PackWise.app</span> zip renamed to <span className="font-mono">.ipa</span> — Apple spec). GitHub&apos;s <span className="font-mono">upload-artifact</span> then wraps that file in an outer container zip for download. So <span className="font-mono">PackWise-unsigned-ipa.zip</span> from Actions <em>contains</em> the <span className="font-mono">.ipa</span> — unwrap once to sideload.
              </p>
              <div className="mt-3 grid sm:grid-cols-2 gap-3 text-xs">
                <div className="rounded-xl bg-white border border-amber-200 p-3">
                  <div className="font-semibold text-amber-900 flex items-center gap-1.5"><Zap className="size-3.5" /> Direct .ipa (no unwrap)</div>
                  <div className="mt-1 text-amber-800"><a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="underline underline-offset-4 font-medium">Releases → Latest</a> (<span className="font-mono">v*</span>) or <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="underline underline-offset-4 font-medium">releases/tag/dev</a> (auto on every main push).</div>
                  <div className="mt-2 font-mono bg-amber-50 border border-amber-200 rounded-lg px-2 py-1">gh release download dev -R Alot1z/packwise -p &quot;*.ipa&quot;</div>
                </div>
                <div className="rounded-xl bg-white border border-amber-200 p-3">
                  <div className="font-semibold text-amber-900">Artifact .ipa (unwrap once)</div>
                  <div className="mt-1 text-amber-800"><a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="underline underline-offset-4 font-medium">Actions → iOS — PackWise</a> → <span className="font-mono">PackWise-unsigned-ipa.zip</span> → unzip → <span className="font-mono">PackWise-unsigned.ipa</span> inside.</div>
                  <div className="mt-2 font-mono bg-amber-50 border border-amber-200 rounded-lg px-2 py-1">unzip PackWise-unsigned-ipa.zip && unzip -l PackWise-unsigned.ipa | head</div>
                </div>
              </div>
              <p className="text-[11px] text-amber-700 mt-2">Verify any <span className="font-mono">.ipa</span>: <span className="font-mono">file *.ipa</span> → <span className="font-mono">Zip archive data</span> (correct) · <span className="font-mono">unzip -l *.ipa</span> → <span className="font-mono">Payload/PackWise.app/</span></p>
            </div>
          </div>
        </div>

        <div className="mt-4 rounded-[20px] border border-border bg-card p-4 flex gap-3">
          <AlertTriangle className="size-4 text-muted-foreground shrink-0 mt-0.5" />
          <p className="text-xs leading-5 text-muted-foreground">
            Preview runs on <span className="font-medium text-foreground">Linux</span> — <code className="font-mono">xcodebuild</code> only exists on <span className="font-medium text-foreground">macOS + Xcode</span> (Apple restriction). Real builds run on <span className="font-mono">macos-15</span> (GitHub) / <span className="font-mono">macos</span> (Gitea) / your Mac via <span className="font-mono">act</span>.
          </p>
        </div>

        <h1 className="mt-8 text-[34px] leading-none tracking-[-0.02em]" style={serif}>
          Get & build PackWise — <span className="italic font-light">from the live repo</span>
        </h1>
        <p className="mt-3 text-sm leading-6 text-muted-foreground max-w-[78ch]">
          All download buttons link to <span className="font-mono">{LIVE_RELEASES}</span> (<span className="font-mono">latest</span> + <span className="font-mono">dev</span>). Workflows at <span className="font-mono">.github/workflows/ios.yml</span> and <span className="font-mono">.gitea/workflows/ios.yml</span> are mirrors — <span className="font-mono">xcodebuild archive + DerivedData fallback</span> → <span className="font-mono">Payload/PackWise.app</span> → <span className="font-mono">PackWise-unsigned.ipa</span> + <span className="font-mono">file</span>/<span className="font-mono">unzip -l</span> validation + <span className="font-mono">shasum</span>. See <a href="https://docs.gitea.io/en-us/usage/actions/comparison/" target="_blank" rel="noreferrer" className="underline underline-offset-4">Gitea vs GitHub</a> + <a href="https://github.com/nektos/act" target="_blank" rel="noreferrer" className="underline underline-offset-4">nektos/act</a>.
        </p>

        <div className="mt-6 flex flex-wrap gap-3">
          <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-primary text-primary-foreground text-sm font-medium hover:opacity-90 transition shadow-sm">
            <Download className="size-4" /> Download IPA — Latest
          </a>
          <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-5 py-3 rounded-full border border-border bg-card text-sm font-medium hover:bg-secondary transition">
            <Zap className="size-4" /> dev — direct .ipa
          </a>
          <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-5 py-3 rounded-full border border-border bg-white text-sm font-medium hover:bg-secondary transition">
            <Eye className="size-4" /> Build logs
          </a>
          <a href={LIVE_REPO} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-5 py-3 rounded-full border border-border bg-white text-sm font-medium">
            <Github className="size-4" /> Alot1z/packwise
          </a>
        </div>

        <div className="mt-6 grid lg:grid-cols-3 gap-4">
          <HostCard
            title="GitHub Actions — free"
            desc="Wired to Alot1z/packwise. Push to main → macos-15 tests + archive (+ fallback + file/unzip validation) → artifact (outer zip) + dev prerelease (direct .ipa). Tag v* → versioned Release."
            href={LIVE_ACTIONS}
            cta="Open Actions"
            note="Actions → iOS — PackWise → Run workflow also works."
          />
          <HostCard
            title="Gitea Actions — self-hosted"
            desc="FOSS forge. Enable [actions] in app.ini, add a macOS runner labeled macos, mirror this repo."
            href="https://about.gitea.com/"
            cta="Self-host Gitea"
            note="Workflow at .gitea/workflows/ios.yml — same build + validation."
          />
          <HostCard
            title="nektos/act — local"
            desc="Run the same YAML on your own Mac. 100% offline after clone. Requires macOS + Xcode locally."
            href="https://github.com/nektos/act"
            cta="Get act"
            note="brew install act → act -W .github/workflows/ios.yml -P macos-15=-self-hosted"
          />
        </div>

        <div className="mt-6 rounded-2xl athena-stone p-5 flex gap-3">
          <Repeat className="size-4 mt-0.5 shrink-0 text-muted-foreground" />
          <div className="text-sm leading-6 text-muted-foreground">
            <span className="font-medium text-foreground">Sync is already wired.</span> Buttons point at <span className="font-mono">{LIVE_RELEASES}</span> — when Actions finishes, the direct <span className="font-mono">.ipa</span> appears at <span className="font-mono">releases/tag/dev</span> instantly (and the artifact zip alongside it).
          </div>
        </div>

        <div className="mt-6 rounded-2xl border border-border bg-white p-5 sm:p-6">
          <div className="text-xs font-mono uppercase tracking-widest text-muted-foreground flex items-center gap-2">
            <Terminal className="size-3.5" /> Build & publish (already configured)
          </div>
          <div className="mt-3">
            <CopyBlock
              label="Push — auto-builds the live repo (artifact + dev .ipa)"
              text={`git push origin main\n# → Actions rebuilds → artifact PackWise-unsigned-ipa.zip + Releases/tag/dev PackWise-unsigned.ipa`}
            />
          </div>
          <div className="mt-3">
            <CopyBlock
              label="Direct .ipa download (no unwrap) — after any main push"
              text={`gh release download dev -R Alot1z/packwise -p "PackWise-unsigned.ipa"\n# or Latest versioned:\ngh release download -R Alot1z/packwise -p "*.ipa"\n# or curl:\ncurl -L -o PackWise-unsigned.ipa https://github.com/Alot1z/packwise/releases/download/dev/PackWise-unsigned.ipa`}
            />
          </div>
          <div className="mt-3">
            <CopyBlock
              label="Artifact path (unwrap once) — if you used Download artifact"
              text={`unzip PackWise-unsigned-ipa.zip   # outer container\nunzip -l PackWise-unsigned.ipa | head  # must show Payload/PackWise.app/\nfile PackWise-unsigned.ipa            # → Zip archive data (correct)`}
            />
          </div>
          <div className="mt-3">
            <CopyBlock
              label="Publish a versioned Release"
              text={`git tag v1.0.0\ngit push origin v1.0.0\n# → Release v1.0.0 with PackWise-unsigned.ipa + .sha256`}
            />
          </div>
          <div className="mt-3">
            <CopyBlock
              label="Local act on your Mac (no cloud)"
              text={`brew install act\nact -W .github/workflows/ios.yml -P macos-15=-self-hosted\n# or simply (Mac + Xcode):\n./ios/build.sh   # → ios/build/PackWise-unsigned.ipa + .sha256`}
            />
          </div>
          <p className="text-xs text-muted-foreground mt-3">Linux <span className="font-mono">act</span> can lint but cannot compile IPAs — <span className="font-mono">xcodebuild</span> only on macOS.</p>
        </div>

        <div className="mt-6 grid md:grid-cols-2 gap-6">
          <div className="rounded-2xl border border-border bg-card p-5">
            <div className="font-semibold flex items-center gap-2" style={serif}><Smartphone className="size-4" /> Sideload (same .ipa, all hosts)</div>
            <div className="mt-2 space-y-2 text-sm text-muted-foreground leading-6">
              <div><span className="font-medium text-foreground">AltStore:</span> AltServer on Mac/PC → AltStore → My Apps → + → select the <span className="font-mono">.ipa</span>.</div>
              <div><span className="font-medium text-foreground">Sideloadly:</span> Drag <span className="font-mono">.ipa</span> → Apple ID for local signing.</div>
              <div><span className="font-medium text-foreground">TrollStore:</span> Open → + → select <span className="font-mono">.ipa</span> (where compatible).</div>
            </div>
            <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="mt-4 inline-flex items-center gap-2 text-xs font-medium px-3 py-1.5 rounded-full bg-primary text-primary-foreground">Download IPA <Download className="size-3" /></a>
          </div>
          <div className="rounded-2xl border border-border bg-white p-5">
            <div className="font-semibold flex items-center gap-2" style={serif}><HardDrive className="size-4" /> Verify & inspect</div>
            <div className="mt-2 rounded-xl bg-[#1a1a1e] text-zinc-100 p-3 font-mono text-xs leading-5">
              file PackWise-unsigned.ipa<br />
              unzip -l PackWise-unsigned.ipa | head<br />
              shasum -a 256 PackWise-unsigned.ipa<br />
              ls -lh ios/build/PackWise-unsigned.ipa
            </div>
            <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="mt-3 inline-flex items-center gap-1.5 text-xs text-muted-foreground hover:text-foreground">Read live build logs <ExternalLink className="size-3" /></a>
          </div>
        </div>

        <div className="mt-6 rounded-2xl border border-dashed border-border bg-card p-4 text-xs leading-5 text-muted-foreground">
          <span className="font-medium text-foreground">Why this page exists.</span> Freebuff preview is on Linux — <span className="font-mono">xcodebuild</span> is Apple-only. So downloads point at the real host: <span className="font-mono">{LIVE_REPO}</span>. The Archive fallback + <span className="font-mono">file</span>/<span className="font-mono">unzip -l</span> validation are in the workflow + <span className="font-mono">ios/build.sh</span> — see <span className="font-mono">ios/README.md</span>.
        </div>

        <div className="mt-8 flex flex-wrap gap-3">
          <a href={LIVE_RELEASE_LATEST} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-primary text-primary-foreground text-sm font-medium hover:opacity-90 transition">
            <Download className="size-4" /> Download IPA
          </a>
          <a href={LIVE_RELEASE_DEV} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-5 py-3 rounded-full border border-border bg-white text-sm font-medium">
            <Zap className="size-4" /> dev — direct .ipa
          </a>
          <Link to="/#install" className="inline-flex items-center gap-2 px-5 py-3 rounded-full border border-border bg-white text-sm font-medium">
            Back to install docs <ArrowRight className="size-4" />
          </Link>
        </div>
      </div>
    </div>
  );
}
