# Travel App

Collaborative trip-planning PWA for two users. Pin spots, group into days, route between them, ask AI for advice. Must work in China.

Phase-by-phase scope lives in `/Plan/`. This file is the durable spec — read before any non-trivial change.

## Constraints

1. **China without VPN MUST work for:** viewing all trip data, the map (pre-cached tiles), pre-computed routes, local edits.
2. **China without VPN MAY fail for:** AI assistant, live sync, computing new routes, first-time install.
3. **Offline-first.** IndexedDB is the source of truth on device. Sync opportunistic. Last-write-wins per field by `updated_at`.
4. **Mobile-first PWA.** No app store. Two collaborators per trip; opens to public sign-up at Phase 10.

## Stack

- Next.js (App Router) + TypeScript strict + Tailwind
- MapLibre GL JS, Amap tiles + Directions API (China), OSM/OSRM elsewhere
- Supabase: Postgres + Auth (Google OAuth + magic links) + Realtime + RLS
- Dexie (IndexedDB) for local store; service worker for tile + shell cache
- Anthropic SDK (Claude) for the AI assistant, server-side only

## Data model (canonical)

- `trips` — id, name, owner_id, start_date, end_date
- `trip_members` — trip_id, user_id, display_name, colour, role, status
- `spots` — id, trip_id, created_by, name, lat, lng, category, notes, website_url, in_itinerary, day_id, order_in_day, updated_at
- `days` — id, trip_id, date, position, notes
- `routes` — id, trip_id, from_spot_id, to_spot_id, mode, distance_m, duration_s, geometry, computed_at

Spot states: **wishlist** (`in_itinerary=false`) → **unassigned** (`in_itinerary=true`, `day_id=null`) → **scheduled** (`day_id` + `order_in_day` set).

## Coordinates (footgun — read this)

- **Storage: WGS-84, always.** Postgres, IndexedDB, route geometry.
- **Render on Amap:** convert WGS-84 → GCJ-02 at draw time.
- **Render on OSM/MapLibre default:** no conversion.
- **Input from Amap (clicks, POI search):** convert GCJ-02 → WGS-84 before save.
- **Input from GPS / OSM:** already WGS-84, save as-is.
- All conversions go through `lib/coords.ts` (uses `coordtransform`). Components never call raw conversion functions.

## UI invariants

- **Pin colour = author** (`trip_members.colour` of `created_by`). Map legend in corner.
- **Category = pin icon** (independent of colour).
- **Wishlist = muted** (lower opacity); itinerary = solid.
- **Pending route = dashed grey** + badge, when route not yet computed.

## Coding guidelines

These exist to keep the codebase boring and changeable. Re-read before opening a PR.

### Architecture

- **Server components by default.** `"use client"` only for stateful UI (map, forms, drag, chat).
- **One Map client component.** All MapLibre calls live there. Other components manipulate the map only via props/context, never by reaching into MapLibre directly.
- **Repository pattern for Supabase.** Components call `spotsRepo.list(tripId)`, never `supabase.from('spots')`. Repo functions live in `lib/repos/`.
- **Local-first reads.** UI reads from Dexie. Repos write to Dexie first, then enqueue Supabase sync. Never await network in a click handler.
- **Server-only secrets.** Anthropic key, Supabase service-role key, never reach the browser bundle. Enforce by importing only inside `app/api/**` or files marked `server-only`.

### TypeScript

- Strict mode on. `noUncheckedIndexedAccess` on.
- **No `any`.** If unavoidable, comment why. Prefer `unknown` + a narrow.
- **No type assertions** (`as Foo`) except at well-defined boundaries (parsing JSON, third-party libs without types). Comment each one.
- DB types are generated from Supabase (`supabase gen types`). Don't hand-write them.
- Domain types (`Spot`, `Day`, `Route`) live in `lib/types/`. Repos translate DB rows → domain types at the edge.

### Code smell guardrails

- **No premature abstractions.** Three similar lines beats a wrong abstraction. Extract on the third real duplicate, not the second imagined one.
- **No "just in case" code.** No options/flags/params with no current caller. No dead branches. No commented-out code.
- **No defensive error handling inside trusted boundaries.** Validate at the edge (route handlers, form parsing); trust internals. Don't try/catch-and-log to swallow bugs.
- **No comments that restate code.** Comments explain *why* (a constraint, an invariant, a workaround). Names explain *what*.
- **No backwards-compat shims** while we're pre-launch. Migrations rewrite. Delete unused code immediately.
- **No feature flags.** Don't ship half-finished features hidden behind a flag. Either it's done or it's on a branch.
- **No god files.** A file does one thing. If a `utils.ts` is forming, the things in it belong in named modules.

### Functions & files

- **Pure functions in `lib/`.** No side effects, no I/O. I/O lives in repos and route handlers.
- **One responsibility per file.** Co-locate test/types beside source: `spot.ts` + `spot.test.ts` + (if needed) `spot.types.ts`.
- **Small functions.** If a function exceeds ~40 lines or 3 levels of indentation, it's doing too much.
- **No default exports** except for Next.js page/layout/route files where the framework requires them.

### State & side effects

- **No `useEffect` for derived state.** Compute it in render or with `useMemo`.
- **No global mutable state** outside React context or a single, scoped store. No module-level `let`s.
- **Realtime + sync queue** are owned by `lib/sync/`. Components don't subscribe to Supabase Realtime directly.

### Errors & loading

- **Every async UI surface has a loading and an error state.** No bare spinners that never resolve. No silent failures.
- **Error boundaries** wrap each route. They render a recoverable UI, not a blank screen.
- **Toast for transient failures** (sync conflict, retryable network), inline message for terminal failures (RLS denied, validation).

### Security

- **RLS is the source of truth for access.** App code may add UX checks; it must never be the only check.
- **Never use the service-role key from a user-reachable endpoint.** Service-role lives in cron jobs and migrations only.
- **All user input passes through a Zod schema** at the boundary (form action, route handler).

### Testing

- Unit-test `lib/` (pure logic — coord conversion, sync conflict resolution, ordering math).
- Don't unit-test components; rely on manual phone testing per phase exit criteria.
- One end-to-end smoke test per phase added to a Playwright file before that phase exits.

## Out of scope (until called for)

Public/discoverable trips, social features, booking integrations, expense tracking, custom roles, orgs/teams, billing.
