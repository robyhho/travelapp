# Travel App

Collaborative trip-planning app for two users on iPhone, iPad, and Mac. Pin spots, group into days, route between them, ask AI for advice. Must work in China.

Phase-by-phase scope lives in `/Plan/`. This file is the durable spec — read before any non-trivial change.

## Constraints

1. **China without VPN MUST work for:** viewing all trip data, pre-computed routes (as polylines on top of MapKit), local edits. Live MapKit tile fetches are expected to work in China (Apple licenses Amap), but require network.
2. **China without VPN MAY fail for:** AI assistant, live realtime sync, computing new routes, MKLocalSearch, MapKit basemap when fully offline (no signal in tunnels/rural), first-time install (TestFlight / App Store).
3. **Offline-first for trip data, network-required for map tiles.** SwiftData is the source of truth on device — spots, days, routes, notes are all available offline. The map basemap behind them needs a connection. If true offline maps become a real pain point in use, revisit by adding MapLibre + an offline tile provider in a later phase.
4. **Native first.** SwiftUI Multiplatform. iOS is the primary target; macOS support is shared and expected to work.
5. Two collaborators per trip; opens to public sign-up at Phase 10.

## Stack

- **SwiftUI Multiplatform** target (iOS 17+, macOS 14+)
- **SwiftData** for local persistence (single source of truth on device)
- **MapKit** for everything map-related — rendering (`Map` / `MKMapView`), routing (`MKDirections`), POI search (`MKLocalSearch`). Apple licenses Amap data inside China, so quality and availability are best-in-class without a VPN. Native on both iOS and macOS — no third-party map SDK.
- **Supabase** (Postgres + Auth + Realtime + RLS) hosted in `ap-northeast-1` (Tokyo) for low latency from China without VPN. Supabase doesn't offer Hong Kong; Tokyo is the next-best AWS region for unfiltered access from mainland China.
- **Sign in with Apple** + email magic link, via Supabase Auth
- **Anthropic SDK** for the AI assistant, called from a **Supabase Edge Function** so the API key never leaves the server

## Data model (canonical)

- `trips` — id, name, owner_id, start_date, end_date
- `trip_members` — trip_id, user_id, display_name, colour, role, status
- `spots` — id, trip_id, created_by, name, lat, lng, category, notes, website_url, in_itinerary, day_id, order_in_day, updated_at
- `days` — id, trip_id, date, position, notes
- `routes` — id, trip_id, from_spot_id, to_spot_id, mode, distance_m, duration_s, geometry, computed_at

Spot states: **wishlist** (`in_itinerary=false`) → **unassigned** (`in_itinerary=true`, `day_id=null`) → **scheduled** (`day_id` + `order_in_day` set).

## Coordinates

- **WGS-84 everywhere.** Postgres, SwiftData, route geometry, MapKit. No GCJ-02. No conversions.
- MapKit (`MKDirections`, `MKLocalSearch`, map view) returns WGS-84 in China too — Apple does the GCJ-02 wrangling internally.

## UI invariants

- **Pin colour = author** (`trip_members.colour` of `created_by`). Map legend in corner.
- **Category = pin icon (SF Symbol)** (independent of colour).
- **Wishlist = muted** (lower opacity); itinerary = solid.
- **Pending route = dashed grey** + badge, when route not yet computed.

## Coding guidelines

These exist to keep the codebase boring and changeable. Re-read before opening a PR.

### Architecture

- **MVVM with SwiftUI views as the V, `@Observable` view models as the VM, SwiftData models as the M.**
- **One `MapView` SwiftUI wrapper around MapKit.** All MapKit calls live there. Other views manipulate the map only via bindings, never by reaching into the underlying `MKMapView` directly. The wrapper is shared across iOS and macOS — MapKit is native on both.
- **Repository pattern for Supabase.** Views/VMs call `SpotsRepo.list(tripId:)`, never `supabase.from("spots")`. Repos live in `TravelApp/Sources/Repos/`.
- **Local-first reads.** UI reads from SwiftData (instant). Repos write to SwiftData first, then enqueue a `PendingMutation` for sync. Never `await` a network call in a button action.
- **Server-only secrets.** Anthropic key, Supabase service-role key never reach the device. They live in Supabase Edge Function env vars only.

### Swift

- **Swift 5.10+, strict concurrency.** `@MainActor` on view models that touch UI; actors or `Sendable` types for everything that crosses a thread.
- **No `Any`.** Prefer `some Protocol` or generics over type-erased boxes unless required.
- **Force-unwraps (`!`) are a code smell.** Use `guard let` / `if let`. Force-unwrap only when the invariant is provably true at the call site, and add a one-line comment saying why.
- **DB types** are generated from Supabase (`supabase gen types swift`). Don't hand-write them.
- **Domain types** (`Spot`, `Day`, `Route`) are SwiftData `@Model` classes in `TravelApp/Sources/Models/`. Repos translate Supabase rows ↔ domain models at the edge.

### Code smell guardrails

- **No premature abstractions.** Three similar lines beats a wrong abstraction. Extract on the third real duplicate, not the second imagined one.
- **No "just in case" code.** No options/flags/params with no current caller. No dead branches. No commented-out code.
- **No defensive error handling inside trusted boundaries.** Validate at the edge (form input, Edge Function entry, deep-link parse); trust internals. Don't `do { ... } catch { print(error) }` to swallow bugs.
- **No comments that restate code.** Comments explain *why* (a constraint, an invariant, a workaround). Names explain *what*.
- **No backwards-compat shims** while we're pre-launch. Migrations rewrite. Delete unused code immediately.
- **No feature flags.** Don't ship half-finished features hidden behind a flag. Either it's done or it's on a branch.
- **No god files.** A file does one thing. If a `Helpers.swift` is forming, the things in it belong in named modules.

### Functions & files

- **Pure functions in `Sources/Lib/`.** No side effects, no I/O. I/O lives in repos and Edge Functions.
- **One responsibility per file.** Co-locate test/types beside source: `Spot.swift` + `SpotTests.swift`.
- **Small functions.** If a function exceeds ~40 lines or 3 levels of indentation, it's doing too much.
- **File-private over internal where possible.** Default to the smallest access level that works.

### State & side effects

- **No derived `@State`.** Compute it in the view body, or via a computed property on the view model.
- **No global mutable state.** No top-level `var`s. Use `@Environment` injection or a single, scoped `@Observable` store.
- **Realtime + sync queue** are owned by `Sources/Sync/`. Views don't subscribe to Supabase Realtime directly.

### Errors & loading

- **Every async UI surface has a loading and an error state.** No bare `ProgressView`s that never resolve. No silent failures.
- **Error views** wrap each screen. They render a recoverable UI, not a blank screen.
- **Toast for transient failures** (sync conflict, retryable network), inline message for terminal failures (RLS denied, validation).

### Security

- **RLS is the source of truth for access.** App code may add UX checks; it must never be the only check.
- **Never use the service-role key from the client.** Service-role lives in Edge Functions and migrations only.
- **All user input passes through a validating decoder** at the boundary (form action, Edge Function handler) — typed Swift structs decoded from JSON, no untyped dictionaries crossing the wire.

### Testing

- Unit-test `Sources/Lib/` and `Sources/Sync/` (pure logic — sync conflict resolution, ordering math, mutation replay).
- Don't unit-test SwiftUI views; rely on manual device testing per phase exit criteria.
- One end-to-end UI test (XCUITest) per phase added before that phase exits.

## Out of scope (until called for)

Public/discoverable trips, social features, booking integrations, expense tracking, custom roles, orgs/teams, billing, Android, web.
