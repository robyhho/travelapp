# Phase 3 — Auth & trip foundation

## Goal

Real users sign in, a trip exists in Postgres, and the app reads/writes only the trip's data through RLS-protected Supabase calls.

## Deliverables

- **Supabase Auth** configured: **Sign in with Apple** + email magic links. Session lifetime extended to 30 days (China VPN consideration).
- **Schema** (initial migration):
  - `trips` (id, name, owner_id, start_date, end_date, created_at)
  - `trip_members` (trip_id, user_id, display_name, colour, role: owner|member, status: active|pending, joined_at)
  - `spots` (id, trip_id, created_by, name, lat, lng, category, notes, website_url, in_itinerary, day_id, order_in_day, created_at, updated_at)
  - (`days`, `routes` come in Phase 5/6)
- **RLS policies** on all three tables. Tested by attempting cross-trip access from a different signed-in user and verifying it's blocked.
- **Auth screen** (`AuthView`): "Sign in with Apple" button (`SignInWithAppleButton` from `AuthenticationServices`) and an email magic-link form. Post-login routes to `TripsListView`.
- **Trips list** (`TripsListView`): list of trips the signed-in user belongs to + "Create trip" button.
- **Trip screen** (`TripView`): the screen from Phase 2, but now reads/writes spots from Supabase scoped to the trip id.
- **Repository layer** in `Sources/Repos/`:
  - `AuthRepo` — sign-in, sign-out, session observation
  - `TripsRepo` — list, create, get
  - `SpotsRepo` — list, create, delete (full CRUD lands in Phase 4)
  - Views/VMs never touch `supabase.from(...)` directly
- Mock data from Phase 2 deleted.

## Out of scope

- Inviting another user (Phase 8 — for now, manually add yourself + partner via SQL or Supabase dashboard)
- Editing spots beyond create + delete (Phase 4 covers full CRUD UX)
- Wishlist toggle UI (Phase 4)
- Author colours rendered visually (Phase 4)
- Local-first / SwiftData persistence (Phase 7 — for now, repo reads go straight to Supabase)

## Exit criteria

- Sign in with Apple on iOS Simulator → land on `TripsListView`
- Create a trip → land on `TripView` with empty map
- Tap on map (or a "+ pin" button) → spot persists to Supabase → relaunch app → spot still there
- Manually verify (e.g. via Supabase SQL editor with a different user JWT) that another user cannot read this trip's spots
- Magic-link flow works on a real device (deep-link returns user to the app authed)
- macOS build can also sign in (Sign in with Apple works natively on macOS)

## Manual steps

- **Sign in with Apple capability**:
  - In Xcode → target → Signing & Capabilities → **+ Capability → Sign In with Apple** for both iOS and macOS targets.
  - In https://developer.apple.com/account → **Identifiers** → enable Sign In with Apple on the app's bundle ID.
  - In Supabase → **Authentication → Providers → Apple**: enable, paste your Services ID, Team ID, Key ID, and the private key `.p8` file. Apple's docs are linked from the Supabase provider page — follow them precisely.
- **Magic links**: in Supabase → **Authentication → Providers → Email**, enable email + magic link sign-in. For dev, Supabase's built-in SMTP is fine; production SMTP comes in Phase 10.
- **Auth URL config**: in Supabase → **Authentication → URL Configuration**, add a **redirect URL** matching the app's URL scheme (e.g. `travelapp://auth-callback`). Register the matching URL Type in Xcode → target → Info → URL Types.
- **Session expiry**: Supabase → Authentication → set **JWT expiry** to 30 days.
- **Partner account**: have your partner sign in once so their `auth.users` row exists, then in the Supabase SQL editor insert them into `trip_members` as `member` / `active` for your test trip. (Phase 8 replaces this with a real invite UI.)
- **Migrations**: apply the initial migration via `supabase db push` (or the SQL editor). Re-generate types: `supabase gen types swift --linked > TravelApp/Sources/Repos/Database.swift`.
