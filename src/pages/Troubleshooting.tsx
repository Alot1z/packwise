import { AlertTriangle, CheckCircle2, ExternalLink, Package, Smartphone, Wrench, Eye, Terminal } from "lucide-react";
import { SiteNav, SiteFooter, PageHeader, serif, LIVE_ACTIONS, LIVE_RELEASE_DEV, LIVE_RELEASES, WIKI_URL } from "@/components/site-shared";

const entries = [
  {
    icon: Smartphone,
    title: "“Failed to map …/PackWise: Bad file descriptor” when sideloading (LiveContainer, AltStore, Sideloadly)",
    severity: "Fixed in pipeline",
    body: [
      "This error means the app bundle inside the IPA has no executable at <span class='font-mono'>Payload/PackWise.app/PackWise</span> — the sideloader cannot map a file that does not exist.",
      "Root cause: the earlier pipeline used <span class='font-mono'>xcodebuild archive</span> with signing disabled, which on Xcode 16 can emit an app shell (Info.plist + assets, no binary) — and the workflow validated only the presence of <span class='font-mono'>Payload/PackWise.app/</span>, so a broken bundle was published as “success”.",
      "Fix: the pipeline now builds with <span class='font-mono'>xcodebuild build -sdk iphoneos -destination generic/platform=iOS</span> (device arm64, never simulator), validates that the executable exists, is non-empty, is arm64, and is an iOS device Mach-O (platform 2, not 7), strips test bundles, and refuses to publish otherwise.",
      "If you still have an old IPA: download the latest <a class='font-medium underline underline-offset-4' target='_blank' rel='noreferrer' href='https://github.com/Alot1z/packwise/releases/tag/dev'>dev build</a> or build locally with <span class='font-mono'>./ios/build.sh</span>.",
    ],
  },
  {
    icon: Package,
    title: "I downloaded a .zip, not a .ipa",
    severity: "Expected",
    body: [
      "From Actions, GitHub wraps the uploaded <span class='font-mono'>.ipa</span> in an outer container zip named <span class='font-mono'>PackWise-unsigned-ipa.zip</span>. Unzip once — the inner <span class='font-mono'>PackWise-unsigned.ipa</span> is the file to sideload.",
      "For a direct <span class='font-mono'>.ipa</span> with no unwrap, use <a class='font-medium underline underline-offset-4' target='_blank' rel='noreferrer' href='https://github.com/Alot1z/packwise/releases'>Releases</a> (<span class='font-mono'>dev</span> updates on every main push).",
      "Note: an <span class='font-mono'>.ipa</span> IS a zip renamed — <span class='font-mono'>file *.ipa</span> showing <span class='font-mono'>Zip archive data</span> is correct.",
    ],
  },
  {
    icon: AlertTriangle,
    title: "No IPA artifact in the run",
    severity: "Diagnose",
    body: [
      "Open <a class='font-medium underline underline-offset-4' target='_blank' rel='noreferrer' href='https://github.com/Alot1z/packwise/actions'>Actions → iOS — PackWise</a> and expand the “Build unsigned IPA” step. It now fails loudly with diagnostics if the executable is missing, if the binary is a simulator build, or if test bundles remain.",
      "Tests are non-blocking: a flaky test will never block the IPA.",
    ],
  },
  {
    icon: Wrench,
    title: "Install fails after sideloading (app won't launch / crashes)",
    severity: "Re-sign",
    body: [
      "Unsigned IPAs must be re-signed by the sideload tool. AltStore and Sideloadly do this automatically with your Apple ID; TrollStore needs no re-signing on supported versions.",
      "Verify the bundle first: <span class='font-mono'>unzip -l PackWise-unsigned.ipa | grep -E \"Payload/PackWise.app/PackWise|Info.plist\"</span>.",
    ],
  },
  {
    icon: Eye,
    title: "Vision scanner finds nothing",
    severity: "Expected",
    body: [
      "Classification is conservative and runs on device. Use a clear, well-lit photo of a single object. Suggestions always require your confirmation — nothing is added silently.",
    ],
  },
  {
    icon: Terminal,
    title: "Build fails on my Mac",
    severity: "Environment",
    body: [
      "Requires Xcode 16+ and <span class='font-mono'>brew install xcodegen</span>. Run <span class='font-mono'>cd ios && xcodegen generate</span> first, then <span class='font-mono'>./build.sh</span>. Full guide in the <a class='font-medium underline underline-offset-4' target='_blank' rel='noreferrer' href='https://github.com/Alot1z/packwise/wiki/Build-and-Release'>Wiki — Build and Release</a>.",
    ],
  },
];

export default function Troubleshooting() {
  return (
    <div className="min-h-screen bg-background text-foreground">
      <SiteNav />
      <PageHeader
        kicker="Troubleshooting"
        title="Problems, causes, fixes"
        desc="Honest status over marketing. If something is broken, it is listed here with the actual cause and the fix — including the sideload failure that shipped before the validation fix."
      />

      <section className="max-w-[1180px] mx-auto px-6 pb-10">
        <div className="space-y-4">
          {entries.map((e) => (
            <div key={e.title} className="rounded-2xl border border-border bg-card p-5 sm:p-6">
              <div className="flex flex-wrap items-center gap-3">
                <div className="size-9 rounded-xl bg-secondary grid place-items-center border border-border/50"><e.icon className="size-[18px]" /></div>
                <h2 className="text-[16px] leading-snug font-semibold" style={serif}>{e.title}</h2>
                <span className={`ml-auto text-[10px] font-mono uppercase tracking-widest px-2.5 py-1 rounded-full border ${e.severity === "Fixed in pipeline" ? "border-emerald-300 bg-emerald-50 text-emerald-700" : "border-border bg-secondary text-muted-foreground"}`}>
                  {e.severity}
                </span>
              </div>
              <ul className="mt-4 space-y-2.5">
                {e.body.map((b, i) => (
                  <li key={i} className="flex gap-2.5 text-[13.5px] leading-[22px] text-muted-foreground" dangerouslySetInnerHTML={{ __html: b }} />
                ))}
              </ul>
            </div>
          ))}
        </div>

        <div className="mt-8 rounded-2xl border border-dashed border-border bg-card p-5 flex flex-wrap items-center gap-x-6 gap-y-3 text-sm text-muted-foreground">
          <span className="inline-flex items-center gap-2"><CheckCircle2 className="size-4 text-emerald-600" /> TestFlight / App Store are never claimed without real Apple signing + App Store Connect processing.</span>
          <a href={`${WIKI_URL}/Troubleshooting`} target="_blank" rel="noreferrer" className="ml-auto inline-flex items-center gap-1.5 hover:text-foreground">Wiki troubleshooting <ExternalLink className="size-3" /></a>
          <a href={LIVE_ACTIONS} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 hover:text-foreground">Live build logs <ExternalLink className="size-3" /></a>
        </div>
      </section>

      <SiteFooter />
    </div>
  );
}
