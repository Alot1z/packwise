import { Link } from "react-router";
const serif = { fontFamily: "Instrument Serif, Cormorant Garamond, serif" } as const;
export default function NotFound() {
  return (
    <div className="min-h-screen grid place-items-center bg-background px-6">
      <div className="text-center max-w-md">
        <div className="text-[13px] font-mono uppercase tracking-[0.16em] text-muted-foreground">PackWise</div>
        <h1 className="text-[44px] leading-none mt-2" style={serif}>Page not found</h1>
        <p className="text-sm leading-6 text-muted-foreground mt-3">The page you were looking for does not exist. Return to your private workspace or the overview.</p>
        <div className="mt-6 flex justify-center gap-3">
          <Link to="/dashboard" className="px-5 py-2.5 rounded-full bg-primary text-primary-foreground text-sm font-medium">Open workspace</Link>
          <Link to="/" className="px-5 py-2.5 rounded-full border border-border bg-card text-sm font-medium">Overview</Link>
        </div>
      </div>
    </div>
  );
}
