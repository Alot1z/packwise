import { useState } from "react";
import { Link } from "react-router";
import { Check, Copy, ExternalLink, Github, Terminal, Smartphone, ArrowRight, Download, AlertTriangle, Sparkles } from "lucide-react";
import { toast } from "sonner";

const serif = { fontFamily: "Instrument Serif, Cormorant Garamond, serif" } as const;

function CopyBlock({ text, label }: { text: string; label?: string }) {
  const [copied, setCopied] = useState(false);
  return (
    <div className="rounded-xl bg-[#1a1a1e] text-zinc-100 p-3 font-mono text-xs leading-5 relative group">
      {label && <div className="text-[10px] uppercase tracking-widest text-zinc-400 mb-1">{label}</div>}
      <pre className="whitespace-pre-wrap break-all pr-10">{text}</pre>
      <button
        onClick={async () => {
          await navigator.clipboard.writeText(text);
          setCopied(true);
          toast.success("Copied to clipboard");
          setTimeout(() => setCopied(false), 1500);
        }}
        className="absolute top-3 right-3 size-7 rounded-lg bg-white/10 hover:bg-white/15 grid place-items-center transition"
        aria-label="Copy"
      >
        {copied ? <Check className="size-3.5" /> : <Copy className="size-3.5" />}
      </button>
    </div>
  );
}

export default function Setup() {
  const repoName = "packwise";
  const newRepoUrl = "https://github.com/new";
  const actionsUrlNote = "After you push, open your new repo → Actions → iOS — PackWise → Run workflow (or just push to main)";

  return (
    <div className="min-h-screen bg-background">
      <div className="max-w-[980px] mx-auto px-6 py-8">
        <Link to="/" className="text-sm text-muted-foreground hover:text-foreground inline-flex items-center gap-1.5">
          <ArrowRight className="size-3.5 rotate-180" /> Back to docs
        </Link>

        <div className="mt-6 rounded-[28px] border border-amber-200 bg-amber-50 p-5 sm:p-6 flex gap-4">
          <AlertTriangle className="size-5 text-amber-700 shrink-0 mt-0.5" />
          <div>
            <div className="font-semibold text-amber-900" style={serif}>I cannot build the IPA on this machine.</div>
            <p className="text-sm leading-6 text-amber-800 mt-1">
              This workspace is <span className="font-medium">Linux (Debian)</span>. iOS builds require <span className="font-medium">macOS + Xcode</span> (<code className="font-mono">xcodebuild</code>). That tool does not exist here — the command simply returns <code className="font-mono">not found</code>.
              I am not pretending otherwise. The honest path is: create a GitHub repo from this project, and let GitHub&apos;s <span className="font-mono">macos-15</span> runner build the unsigned IPA for you — for free, no Mac or Apple Developer account needed.
            </p>
          </div>
        </div>

        <h1 className="mt-8 text-[34px] leading-none tracking-[-0.02em]" style={serif}>
          Create your GitHub repo — <span className="italic font-light">one flow, then Actions builds the IPA</span>
        </h1>
        <p className="mt-3 text-sm leading-6 text-muted-foreground max-w-[70ch]">
          Use the button below to create the repo, then push this project to it. The included workflow <span className="font-mono">.github/workflows/ios.yml</span> will run on <span className="font-mono">macos-15 + Xcode 16</span>, run tests, and publish <span className="font-mono">PackWise-unsigned.ipa</span> as a downloadable artifact for AltStore / Sideloadly / TrollStore.
        </p>

        <div className="mt-6 grid lg:grid-cols-[1.2fr_0.8fr] gap-6 items-start">
          <div className="rounded-2xl border border-border bg-card p-5">
            <div className="text-xs font-mono uppercase tracking-widest text-muted-foreground">Step 1 — Create the repo</div>
            <p className="text-sm text-muted-foreground mt-2">
              Create an empty repo named <span className="font-mono font-medium text-foreground">{repoName}</span> (public or private — private works for Actions too).
            </p>
            <a
              href={newRepoUrl}
              target="_blank"
              rel="noreferrer"
              className="mt-4 inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-primary text-primary-foreground text-sm font-medium hover:opacity-90 transition"
            >
              <Github className="size-4" /> Create GitHub repo <ExternalLink className="size-3.5" />
            </a>
            <p className="text-xs text-muted-foreground mt-3">
              Name it <span className="font-mono">{repoName}</span>, leave it empty (no README/license), then copy its URL — it will look like <span className="font-mono">https://github.com/YOU/packwise.git</span>.
            </p>
          </div>

          <div className="rounded-2xl athena-stone p-5">
            <div className="font-semibold flex items-center gap-2" style={serif}><Sparkles className="size-4" /> What you get</div>
            <ul className="mt-3 space-y-2 text-sm text-muted-foreground">
              <li className="flex gap-2"><Check className="size-3.5 mt-0.5 text-emerald-600" />Unsigned IPA built on GitHub — no Mac needed on your side</li>
              <li className="flex gap-2"><Check className="size-3.5 mt-0.5 text-emerald-600" />Tests + archive run automatically</li>
              <li className="flex gap-2"><Check className="size-3.5 mt-0.5 text-emerald-600" />Sideload via AltStore / Sideloadly — re-sign locally</li>
              <li className="flex gap-2 text-xs pt-2 border-t border-border/40"><AlertTriangle className="size-3.5 mt-0.5 text-amber-600" />No TestFlight/App Store claim until real Apple signing is done.</li>
            </ul>
          </div>
        </div>

        <div className="mt-6 rounded-2xl border border-border bg-white p-5 sm:p-6">
          <div className="text-xs font-mono uppercase tracking-widest text-muted-foreground flex items-center gap-2">
            <Terminal className="size-3.5" /> Step 2 — Push this project to your new repo
          </div>
          <p className="text-sm text-muted-foreground mt-2">Run these from your local clone of this project (replace <span className="font-mono">YOU</span> with your GitHub username). If you exported this project as a zip, unzip it first.</p>

          <div className="mt-4 space-y-3">
            <CopyBlock
              label="Add remote and push (use the URL GitHub shows after creation)"
              text={`git init
git add .
git commit -m "PackWise — native iOS + docs"
git branch -M main
git remote add origin https://github.com/YOU/${repoName}.git
git push -u origin main`}
            />
            <div className="text-xs text-muted-foreground">
              Using SSH? Replace the URL with <span className="font-mono">git@github.com:YOU/{repoName}.git</span>.
            </div>
          </div>

          <div className="mt-6 rounded-xl bg-secondary/40 border border-border p-4 text-sm">
            <div className="font-medium flex items-center gap-2"><Github className="size-4" /> Step 3 — Trigger the IPA build</div>
            <p className="text-muted-foreground mt-1">{actionsUrlNote}</p>
            <ol className="mt-2 list-decimal list-inside space-y-1 text-muted-foreground">
              <li>Open your repo → <span className="font-medium text-foreground">Actions</span> tab.</li>
              <li>Select <span className="font-mono">iOS — PackWise</span> → <span className="font-medium text-foreground">Run workflow</span> (or just push to <span className="font-mono">main</span> — it triggers automatically).</li>
              <li>Wait for the <span className="font-mono">macos-15</span> job (tests → archive).</li>
              <li>Download artifact <span className="font-mono">PackWise-unsigned-ipa</span> → <span className="font-mono">PackWise-unsigned.ipa</span>.</li>
            </ol>
          </div>
        </div>

        <div className="mt-6 grid md:grid-cols-2 gap-6">
          <div className="rounded-2xl border border-border bg-card p-5">
            <div className="font-semibold flex items-center gap-2" style={serif}><Smartphone className="size-4" /> Sideload</div>
            <div className="mt-2 space-y-2 text-sm text-muted-foreground">
              <div><span className="font-medium text-foreground">AltStore:</span> AltServer on Mac/PC → connect iPhone → AltStore → My Apps → + → select IPA.</div>
              <div><span className="font-medium text-foreground">Sideloadly:</span> Drag IPA onto Sideloadly, enter Apple ID for local signing, install.</div>
              <div><span className="font-medium text-foreground">TrollStore:</span> Open → + → select IPA (no re-sign on supported versions).</div>
            </div>
          </div>
          <div className="rounded-2xl border border-border bg-white p-5">
            <div className="font-semibold" style={serif}>Local (if you have a Mac)</div>
            <CopyBlock
              text={`cd ios && xcodegen generate && open PackWise.xcodeproj
# or headless:
./ios/build.sh   # → ios/build/PackWise-unsigned.ipa`}
            />
            <p className="text-xs text-muted-foreground mt-3">Prereqs: Xcode 16+, <span className="font-mono">brew install xcodegen</span>. No Developer account needed for unsigned build.</p>
          </div>
        </div>

        <div className="mt-6 rounded-2xl border border-dashed border-border bg-card p-4 text-xs text-muted-foreground">
          <span className="font-medium text-foreground">Why a button cannot &quot;just create&quot; the repo inside Freebuff?</span> Git/GitHub commands are blocked by design — Freebuff manages version control itself. The flow above is the supported way: create the real GitHub repo in one click, push, and Actions does the macOS build you asked for. I also link this page from the homepage Install section and the <Link to="/#install" className="underline">docs</Link>.
        </div>

        <div className="mt-8 flex flex-wrap gap-3">
          <a href="https://github.com/new" target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-primary text-primary-foreground text-sm font-medium hover:opacity-90 transition">
            <Github className="size-4" /> Create repo on GitHub <ExternalLink className="size-3.5" />
          </a>
          <Link to="/#install" className="inline-flex items-center gap-2 px-6 py-3 rounded-full border border-border bg-card text-sm font-medium hover:bg-secondary transition">
            Back to installation guide <ArrowRight className="size-4" />
          </Link>
          <a href="https://github.com" target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 px-5 py-3 rounded-full border border-border bg-white text-sm font-medium">
            <Download className="size-4" /> View Actions after push
          </a>
        </div>
      </div>
    </div>
  );
}
