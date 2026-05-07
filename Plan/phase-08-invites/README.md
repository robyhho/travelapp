# Phase 8 — Invites

## Goal

The owner can invite their partner (and later, anyone) to a trip without using the Supabase dashboard.

## Deliverables

- **Members screen** in trip settings: list of `trip_members` with avatar, display_name, colour swatch, role, status, "remove" button (owner-only).
- **Invite by email:** owner enters an email → row inserted in `trip_members` with `status = pending` and an `invite_token`. Sends an email with a link `https://travelapp.example/accept-invite?token=…` (Universal Link).
- **Shareable invite link:** owner taps "Share invite link" → generates a single-use, 7-day token → opens the system share sheet (`ShareLink` on iOS, `NSSharingService` on macOS).
- **Accept flow:**
  - Tapping the link opens the app via Universal Links
  - If the user isn't signed in → `AuthView` first; on sign-in, finish the accept flow
  - Token consumed; `trip_members.status` flips to `active`; redirect to the trip
- **Colour assignment:** on join, the new member is auto-assigned the next unused colour from a fixed palette of ~6.
- **Remove member:** owner-only. Removed user loses access (RLS does the work) but their pins remain (still attributed via `created_by`).

## Out of scope

- Roles beyond owner / member
- Re-inviting a removed user (just invite again)
- Per-member granular permissions

## Exit criteria

- Owner invites partner by email; partner taps link in Mail app → app opens (or Auth → app) → lands on the trip with their colour assigned
- Partner can add and edit spots; owner sees them in real time (via Phase 7 Realtime)
- Owner removes partner; partner's app shows "you no longer have access" and can no longer load the trip

## Manual steps

- **Universal Links setup**:
  - Decide on a domain you control (e.g. `travelapp.example`). Cheap option for now: a Vercel-hosted static site at a domain you own.
  - Host an `apple-app-site-association` file at `https://travelapp.example/.well-known/apple-app-site-association` listing your team ID + bundle ID + the `/accept-invite` path. (Vercel can serve this from a `public/` folder with a `vercel.json` rewrite to ensure correct `application/json` content-type.)
  - In Xcode → target → Signing & Capabilities → **+ Capability → Associated Domains** → add `applinks:travelapp.example` for both iOS and macOS targets.
- **Email sender**: pick one and configure.
  - **Option A — Supabase built-in**: customise the invite/magic-link email templates in Supabase → **Authentication → Email Templates**. Fine for low volume.
  - **Option B — Resend** (recommended for production-quality deliverability): sign up at https://resend.com, verify a sending domain (DNS records: SPF, DKIM), create an API key. Add `RESEND_API_KEY` and `RESEND_FROM_EMAIL` as Supabase Edge Function secrets (`supabase secrets set ...`). Send invite emails from an Edge Function.
- Apply the migration that adds `invite_token`, `status`, and any audit columns to `trip_members`. Re-run `supabase gen types swift`.
