import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import {
  InputOTP,
  InputOTPGroup,
  InputOTPSlot,
} from "@/components/ui/input-otp";
import { useAuth } from "@/hooks/use-auth";
import { ArrowRight, Loader2, Mail, Shield, Scan } from "lucide-react";
import { Suspense, useEffect, useState } from "react";
import { useNavigate, useSearchParams, Link } from "react-router";

interface AuthProps {
  redirectAfterAuth?: string;
}

function resolveRedirectAfterAuth(
  returnTo: string | null,
  fallback = "/dashboard",
) {
  if (returnTo?.startsWith("/") && !returnTo.startsWith("//")) return returnTo;
  return fallback;
}

const serif = { fontFamily: "Instrument Serif, Cormorant Garamond, serif" } as const;

function Auth({ redirectAfterAuth }: AuthProps = {}) {
  const { isLoading: authLoading, isAuthenticated, signIn } = useAuth();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const redirect = resolveRedirectAfterAuth(
    searchParams.get("returnTo"),
    redirectAfterAuth,
  );
  const [step, setStep] = useState<"signIn" | { email: string }>("signIn");
  const [otp, setOtp] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!authLoading && isAuthenticated) navigate(redirect);
  }, [authLoading, isAuthenticated, navigate, redirect]);

  const handleEmailSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setIsLoading(true);
    setError(null);
    try {
      const formData = new FormData(event.currentTarget);
      await signIn("email-otp", formData);
      setStep({ email: formData.get("email") as string });
      setIsLoading(false);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Could not send a code. Please try again.");
      setIsLoading(false);
    }
  };

  const handleOtpSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setIsLoading(true);
    setError(null);
    try {
      const formData = new FormData(event.currentTarget);
      await signIn("email-otp", formData);
      navigate(redirect);
    } catch {
      setError("The code you entered is not correct.");
      setIsLoading(false);
      setOtp("");
    }
  };

  const handleGuestLogin = async () => {
    setIsLoading(true);
    setError(null);
    try {
      await signIn("anonymous");
      navigate(redirect);
    } catch (err) {
      setError(`Could not open your workspace: ${err instanceof Error ? err.message : "Unknown error"}`);
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <div className="max-w-[1180px] mx-auto px-6 h-[58px] flex items-center justify-between border-b border-border/60">
        <Link to="/" className="flex items-center gap-2.5">
          <span className="size-8 rounded-[10px] bg-primary text-primary-foreground grid place-items-center"><Scan className="size-4" /></span>
          <span className="text-[15px] font-semibold tracking-[-0.02em]" style={serif}>PackWise</span>
          <span className="hidden sm:inline text-[11px] font-mono uppercase tracking-[0.12em] text-muted-foreground ml-1">Private · On Device</span>
        </Link>
        <Link to="/" className="text-sm text-muted-foreground hover:text-foreground">Back to overview</Link>
      </div>

      <div className="min-h-[calc(100vh-58px)] grid lg:grid-cols-[1.05fr_0.95fr]">
        <div className="hidden lg:flex flex-col justify-center px-10 xl:px-16 athena-paper border-r border-border/60">
          <div className="max-w-[520px]">
            <div className="inline-flex items-center gap-2 text-[11px] font-mono uppercase tracking-[0.14em] text-muted-foreground">
              <Shield className="size-3.5" /> Your private workspace
            </div>
            <h1 className="mt-3 text-[42px] leading-[0.95] tracking-[-0.03em]" style={serif}>
              Travel stays <span className="italic font-light">yours</span>.
            </h1>
            <p className="mt-4 text-[15px] leading-6 text-muted-foreground">
              PackWise is designed to live on your device. Trips, packing lists, outfit plans, photos, notes, and preferences are stored locally and remain fully usable offline. No mandatory account is required to begin.
            </p>
            <div className="mt-6 space-y-3 text-sm">
              <div className="flex gap-3 p-3 rounded-2xl bg-white border border-border"><span className="size-7 rounded-full bg-secondary grid place-items-center shrink-0 text-xs font-mono">01</span><div><div className="font-medium" style={serif}>Continue without an account</div><div className="text-muted-foreground text-xs leading-5">Open the workspace immediately. Ideal for the premium, personal flow PackWise is built for.</div></div></div>
              <div className="flex gap-3 p-3 rounded-2xl bg-white border border-border"><span className="size-7 rounded-full bg-secondary grid place-items-center shrink-0 text-xs font-mono">02</span><div><div className="font-medium" style={serif}>Use email only if you prefer</div><div className="text-muted-foreground text-xs leading-5">Create a lightweight credential when you want to revisit the same browser profile later.</div></div></div>
            </div>
            <p className="mt-6 text-[11px] font-mono uppercase tracking-widest text-muted-foreground">Clean · Premium · Technical — no cloud dependency for the core experience</p>
          </div>
        </div>

        <div className="flex items-center justify-center p-6 sm:p-10">
          <Card className="w-full max-w-[420px] rounded-[20px] border-border shadow-none overflow-hidden">
            {step === "signIn" ? (
              <>
                <CardHeader className="text-center pb-3">
                  <CardTitle className="text-[22px]" style={serif}>Open your workspace</CardTitle>
                  <CardDescription className="text-sm leading-5">
                    Start immediately, or sign in with email if you prefer a returning credential. Either way, your data remains private.
                  </CardDescription>
                </CardHeader>
                <CardContent className="pt-0">
                  <Button type="button" className="w-full rounded-full h-11 gap-2 text-[15px]" onClick={handleGuestLogin} disabled={isLoading}>
                    {isLoading ? <Loader2 className="size-4 animate-spin" /> : <Scan className="size-4" />} Continue without an account
                  </Button>
                  <p className="text-center text-[11px] font-mono uppercase tracking-widest text-muted-foreground mt-3">Recommended — private and offline-first</p>

                  <div className="relative my-6">
                    <div className="absolute inset-0 flex items-center"><span className="w-full border-t" /></div>
                    <div className="relative flex justify-center text-[11px] font-mono uppercase tracking-widest"><span className="bg-card px-3 text-muted-foreground">Or use email</span></div>
                  </div>

                  <form onSubmit={handleEmailSubmit} className="space-y-3">
                    <div className="relative">
                      <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                      <Input name="email" placeholder="you@example.com" type="email" className="pl-9 h-11 rounded-full" disabled={isLoading} required />
                    </div>
                    <Button type="submit" variant="outline" className="w-full rounded-full h-11" disabled={isLoading}>
                      {isLoading ? <Loader2 className="h-4 w-4 animate-spin" /> : <>Send sign-in code <ArrowRight className="ml-2 h-4 w-4" /></>}
                    </Button>
                    {error && <p className="text-sm text-destructive text-center">{error}</p>}
                    <p className="text-xs text-center text-muted-foreground leading-5">Email is optional. PackWise does not require an account or paid services to function.</p>
                  </form>
                </CardContent>
              </>
            ) : (
              <>
                <CardHeader className="text-center mt-2">
                  <CardTitle style={serif}>Check your email</CardTitle>
                  <CardDescription>We sent a six-digit code to {step.email}. It is valid for a short time.</CardDescription>
                </CardHeader>
                <form onSubmit={handleOtpSubmit}>
                  <CardContent className="pb-4">
                    <input type="hidden" name="email" value={step.email} />
                    <input type="hidden" name="code" value={otp} />
                    <div className="flex justify-center">
                      <InputOTP value={otp} onChange={setOtp} maxLength={6} disabled={isLoading} onKeyDown={(e) => {
                        if (e.key === "Enter" && otp.length === 6 && !isLoading) (e.target as HTMLElement).closest("form")?.requestSubmit();
                      }}>
                        <InputOTPGroup>{Array.from({ length: 6 }).map((_, i) => <InputOTPSlot key={i} index={i} />)}</InputOTPGroup>
                      </InputOTP>
                    </div>
                    {error && <p className="mt-3 text-sm text-destructive text-center">{error}</p>}
                    <p className="text-sm text-muted-foreground text-center mt-4">Did not receive it? <Button variant="link" className="p-0 h-auto" onClick={() => setStep("signIn")}>Try again</Button></p>
                  </CardContent>
                  <CardFooter className="flex-col gap-2">
                    <Button type="submit" className="w-full rounded-full" disabled={isLoading || otp.length !== 6}>
                      {isLoading ? <><Loader2 className="mr-2 h-4 w-4 animate-spin" /> Verifying</> : <>Verify and continue <ArrowRight className="ml-2 h-4 w-4" /></>}
                    </Button>
                    <Button type="button" variant="ghost" onClick={() => setStep("signIn")} disabled={isLoading} className="w-full rounded-full">Use a different email</Button>
                  </CardFooter>
                </form>
              </>
            )}
            <div className="py-3 px-6 text-xs text-center text-muted-foreground bg-muted/60 border-t">Secured by <a href="https://freebuff.com" target="_blank" rel="noopener noreferrer" className="underline hover:text-primary">freebuff.com</a> · PackWise keeps core data on device</div>
          </Card>
        </div>
      </div>
    </div>
  );
}

export default function AuthPage(props: AuthProps) {
  return <Suspense><Auth {...props} /></Suspense>;
}
