# Phase 7 — Offline & sync

## Goal

Open the app in China without VPN. See your whole trip — spots, days, notes, routes — even with a flaky connection. Edits made offline sync when you come back online. The MapKit basemap still needs network to fetch tiles, but everything overlaid on it (pins, route polylines, notes) renders from local SwiftData.

## iPhone-first

Both my partner and I are on iPhone. Build, test, and verify exit criteria on iPhone first; macOS second. iPad inherits the iOS build automatically — no extra work expected.

## Deliverables

- **SwiftData as the source of truth on device.** All domain models (`Trip`, `TripMember`, `Spot`, `Day`, `Route`) are `@Model` classes. Views read directly via `@Query`. Repos write to SwiftData first, then enqueue sync.
- **Sync queue** in SwiftData:
  - `@Model class PendingMutation` with `id`, `entity`, `entityId`, `op` (insert|update|delete), `payload: Data` (JSON), `createdAt`
  - On reconnect (or app foreground), `SyncEngine` drains the queue, applying each mutation against Supabase
  - On conflict: last-write-wins per field by `updated_at`
- **Realtime in:** Supabase Realtime subscription (via `supabase-swift`) on the current trip. Inbound changes merge into SwiftData on the main actor.
- **Routes mirrored to SwiftData** so trip viewing shows polylines without a network round-trip — even when the basemap behind them is loading.
- **Background sync** via `BGTaskScheduler` — when the app is launched in the background (e.g. from a push), drain pending mutations and pull recent changes.
- **Connectivity indicator**: small badge in the toolbar showing online/offline state and "X changes pending sync".
- **AI / new-route gating**: when offline, disable AI input with a tooltip ("requires network"). Adding a spot to a day still works; its routes appear as "pending".

## Out of scope

- **Offline map basemap.** MapKit fetches tiles from Apple servers; if there's no signal, the basemap is blank behind your pins and routes. Live with it for now. If real-world use shows this hurts (subway tunnels, rural areas), revisit by adding MapLibre + a tile provider in a later phase.
- Full conflict resolution UI (just LWW per field)
- Photo offline storage
- Cross-device handoff via `NSUserActivity`

## Exit criteria

All criteria below are verified on iPhone first; macOS second.

- Turn on airplane mode → relaunch the app → see all spots, days, route polylines, and notes for the trip (basemap may be blank/grey, that's expected)
- Edit a note offline → re-enable network → edit appears in Supabase within a few seconds
- Partner edits a spot online → my offline app picks it up via Realtime next time I'm online
- Force-quit + relaunch with bad network → app loads instantly from SwiftData, then reconciles in the background
- macOS: same flows work (sync on reconnect, offline data viewing)

## Manual steps

- **Background Modes capability**: Xcode → target → Signing & Capabilities → **+ Capability → Background Modes** → tick **Background fetch** and **Background processing** for the iOS target.
- **Register a `BGTaskScheduler` identifier** in Info.plist under `BGTaskSchedulerPermittedIdentifiers` (e.g. `co.travelapp.sync`).
- **Enable Supabase Realtime** on the `spots`, `days`, `routes`, and `trip_members` tables (Database → Replication → toggle for each).
- **Test on a real iPhone in airplane mode** at least once before claiming the phase done. Simulator's "network link conditioner" is a poor substitute for true offline.
