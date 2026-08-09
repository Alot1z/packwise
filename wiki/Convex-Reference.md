# Convex Reference Card

> The PackWise web app (React + Vite) uses [Convex](https://docs.convex.dev) as its
> backend: schema, auth, queries, and mutations. This card is the fast reference —
> verified against current official docs (docs.convex.dev, github.com/get-convex/convex-auth).

## Backend layout (`src/convex/`)

| File | Role |
|---|---|
| `schema.ts` | `defineSchema` with `authTables` + app tables, `v` validators, indexes |
| `auth.ts` | `convexAuth({ providers: [emailOtp, Anonymous] })` — exports `auth, signIn, signOut, store, isAuthenticated` |
| `auth/emailOtp.ts` | `Email` provider (6-digit OTP, 15 min TTL) → `auth.freebuff.app/send_otp` |
| `auth.config.ts` | OIDC issuer (`CONVEX_SITE_URL`) + Freebuff `customJwt` provider (RS256, JWKS) |
| `http.ts` | `httpRouter()` + `auth.addHttpRoutes(http)` — serves auth OIDC endpoints |
| `users.ts` / `packing.ts` | `query` / `mutation` handlers (trips, items, templates, outfits) |

## Schema (`convex/server` + `convex/values`)

```ts
import { defineSchema, defineTable } from "convex/server";
import { authTables } from "@convex-dev/auth/server";
import { Infer, v } from "convex/values";

const schema = defineSchema({
  ...authTables,               // auth accounts/sessions/verification tables
  trips: defineTable({
    userId: v.id("users"),
    title: v.string(),
    status: v.union(v.literal("planning"), v.literal("packing"),
                    v.literal("ready"), v.literal("archived")),
    cover: v.optional(v.string()),
  })
    .index("by_user", ["userId"])
    .index("by_user_updated", ["userId", "updatedAt"]),
}, { schemaValidation: false });  // compile-time types only — see gotchas

export default schema;
```

- Validators: `v.string()`, `v.number()`, `v.boolean()`, `v.id("table")`,
  `v.optional(...)`, `v.union(...)`, `v.literal(...)`, `v.array(...)`, `v.object({...})`.
- `Infer<typeof validator>` derives the TS type (used for `Role` etc.).
- Indexes: `.index("name", ["field", ...])` — required before `.withIndex("name", ...)` works.

## Auth (`@convex-dev/auth`)

```ts
// server
import { convexAuth } from "@convex-dev/auth/server";
import { getAuthUserId } from "@convex-dev/auth/server";   // Id<"users"> | null

export const { auth, signIn, signOut, store, isAuthenticated } = convexAuth({
  providers: [emailOtp, Anonymous],
});

// inside a query/mutation — never trust the client; check the user
const userId = await getAuthUserId(ctx);
if (!userId) throw new Error("Not authenticated");
```

```tsx
// client — main.tsx wraps the tree in ConvexAuthProvider (NOT ConvexProvider)
import { ConvexAuthProvider } from "@convex-dev/auth/react";
import { ConvexReactClient } from "convex/react";
const convex = new ConvexReactClient(import.meta.env.VITE_CONVEX_URL);
<ConvexAuthProvider client={convex}>{/* app */}</ConvexAuthProvider>
```

```tsx
// hooks — use-auth.ts
import { useAuthActions } from "@convex-dev/auth/react";
import { useConvexAuth, useQuery } from "convex/react";
const { isLoading, isAuthenticated } = useConvexAuth();
const user = useQuery(api.users.currentUser);
const { signIn, signOut } = useAuthActions();
```

- Email provider options used by `emailOtp.ts`: `id`, `maxAge` (seconds),
  `generateVerificationToken()`, `sendVerificationRequest({ identifier, token })`.
- **Env var:** the email-send key is `FB_EMAIL_API_KEY` (was hardcoded, now removed).
  Set it with `npx convex env set FB_EMAIL_API_KEY <key>` — sending throws a clear error if missing.

## Server functions (`./_generated/server`)

```ts
import { mutation, query, MutationCtx, QueryCtx } from "./_generated/server";
import { v } from "convex/values";

export const listTrips = query({ args: {}, handler: async (ctx) => { /* read */ } });

export const createTrip = mutation({
  args: { title: v.string() },
  handler: async (ctx, args) => { /* write */ },
});
```

- `ctx.db` API: `get(id)`, `insert(table, doc)`, `patch(id, partial)`, `delete(id)`,
  `query(table).withIndex("name", q => q.eq("field", value)).order("desc").collect()`.
- `MutationCtx` = writable db, `QueryCtx` = read-only. Type helper params explicitly
  (e.g. `requireUser(ctx: MutationCtx)` — never `any`).
- `getAuthUserId` requires the auth middleware from `auth.ts` to be mounted.

## Gotchas (this codebase)

1. **`VITE_CONVEX_URL` gates everything** — `main.tsx` only constructs
   `ConvexReactClient` when it's set; without it the app renders with **no backend**
   (auth + dashboard dead). See `.env.example`.
2. **`{ schemaValidation: false }`** disables runtime validation of documents —
   types are enforced at compile time only. Confirm this is intentional.
3. **Auth tables** come from `...authTables` in the schema — do not define
   `authAccounts`/`authSessions` yourself.
4. **`auth.ts` is read-only** — new providers follow the `emailOtp` pattern
   (`auth/emailOtp.ts`), registered in `convexAuth({ providers })`.

## Commands

```bash
npx convex dev                  # local backend + watch, regenerates _generated/
npx convex env set FB_EMAIL_API_KEY <key>   # set a server env var
npx convex deploy               # push functions + schema to the deployment
```
