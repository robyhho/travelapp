# Phase 3 — Auth & trip foundation

## Goal

Real users log in, a trip exists in Postgres, and the app reads/writes only the trip's data through RLS-protected Supabase calls.

## Deliverables

- **Supabase Auth** configured: Google OAuth + magic links. Session lifetime extended to 30 days (China VPN consideration).
- **Schema** (initial migration):
  - `trips` (id, name, owner_id, start_date, end_date, created_at)
  - `trip_members` (trip_id, user_id, display_name, colour, role: owner|member, status: active|pending, joined_at)
  - `spots` (id, trip_id, created_by, name, lat, lng, category, notes, website_url, in_itinerary, day_id, order_in_day, created_at, updated_at)
  - (days, routes tables come in Phase 5/6 — leave out for now)
- **RLS policies** on all three tables. Tested by attempting cross-trip access and verifying it's blocked.
- **Auth pages**: `/login` with two buttons (Google, magic link). Post-login redirect to `/trips`.
- **Trips index** `/trips`: list of trips the user belongs to + "Create trip" button.
- **Trip page** `/trips/[id]`: this is the page from Phase 2, but now reads/writes spots from Supabase scoped to the trip id.
- **Typed Supabase client wrapper** in `lib/supabase/`. Components don't call `supabase.from()` directly — they go through repository functions (`spotsRepo.list()`, `spotsRepo.create()`, etc.).
- Mock data from Phase 2 deleted.

## Out of scope

- Inviting another user (Phase 8 — for now, manually add yourself + partner via SQL or Supabase dashboard)
- Editing spots beyond create + delete (Phase 4 covers full CRUD UX)
- Wishlist toggle UI (Phase 4)
- Author colours rendered visually (Phase 4)

## Exit criteria

- Sign in with Google locally → land on `/trips`
- Create a trip → land on `/trips/[id]` with empty map
- Tap on map (or a "+ pin" button) → spot persists to Supabase → reload page → spot still there
- Manually verify (e.g. via Supabase SQL editor with a different user JWT) that another user cannot read this trip's spots
