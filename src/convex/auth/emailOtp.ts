import { Email } from "@convex-dev/auth/providers/Email";
import axios from "axios";
import { RandomReader, generateRandomString } from "@oslojs/crypto/random";

// Freebuff email-send API key. Convex functions read process.env from the
// deployment's env vars (Convex dashboard → Environment Variables, or CLI):
//
//   npx convex env set FB_EMAIL_API_KEY <key>
//
// The old key was hardcoded in this file and is now revoked/rotated — never
// re-add a literal secret here. If the var is missing, sending fails with a
// clear message instead of silently sending a broken request.
const EMAIL_API_KEY = process.env.FB_EMAIL_API_KEY;

export const emailOtp = Email({
  id: "email-otp",
  maxAge: 60 * 15, // 15 minutes
  // This function can be asynchronous
  async generateVerificationToken() {
    const random: RandomReader = {
      read(bytes: Uint8Array) {
        crypto.getRandomValues(bytes);
      },
    };
    const alphabet = "0123456789";
    return generateRandomString(random, alphabet, 6);
  },
  async sendVerificationRequest({ identifier: email, token }) {
    if (!EMAIL_API_KEY) {
      throw new Error(
        "FB_EMAIL_API_KEY is not set — run: npx convex env set FB_EMAIL_API_KEY <key>",
      );
    }
    try {
      await axios.post(
        "https://auth.freebuff.app/send_otp",
        {
          to: email,
          otp: token,
          appName: process.env.VLY_APP_NAME || "PackWise",
        },
        {
          headers: {
            "x-api-key": EMAIL_API_KEY,
          },
        },
      );
    } catch (error) {
      throw new Error(JSON.stringify(error));
    }
  },
});
