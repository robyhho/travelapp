# Phase 7 — PWA & offline

## Goal

Install the app to your home screen. Open it in China without VPN. See your whole trip — spots, days, notes, routes, map — without a network. Edits made offline sync when you come back online.

## iPhone-first

iOS is the primary PWA target — both my partner and I are on iPhone, and Safari's PWA support is the most restrictive. Anything that works on iOS Safari will work on Android Chrome; the reverse isn't true. Build, test, and verify exit criteria on iPhone first.

iOS PWA gotchas to design for upfront:
- **Storage cap is ~50 MB** for IndexedDB + Cache Storage on iOS Safari (varies by version, sometimes higher with `navigator.storage.persist()`). Tile pre-cache must fit inside this — pick zoom range and bbox accordingly, and warn the user before exceeding budget. Track usage via `navigator.storage.estimate()`.
- **No background sync, no push notifications** in iOS PWAs (some support landed in iOS 16.4 but is fragile). Sync runs on app open, not in the background. Don't design any feature that depends on background work.
- **No silent install prompt.** Users add via Share → "Add to Home Screen". Build a one-screen instructions page (`/install`) with a tap-through guide for iOS, plus a separate path for Android.
- **Safari purges storage** for PWAs not used in ~7 days. The app must handle "I lost my IndexedDB" gracefully — re-fetch from Supabase on next online launch, don't crash.
- **`apple-touch-icon`** must be set in `<head>` for the home-screen icon to look right.
- **Status bar / notch:** use `viewport-fit=cover` and CSS env() safe-area insets so the map and sidebar don't sit under the notch.
- **Service worker scope** must be `/`. Don't nest the SW under a path.
- **No `beforeinstallprompt` event** on iOS. Don't write code that assumes it exists.

## Deliverables

- **PWA manifest** (`/public/manifest.webmanifest`): name, icons (192, 512, maskable), theme colour, display: standalone, start_url.
- **Service worker** (via `next-pwa` or hand-rolled with Workbox):
  - App shell precache (HTML, JS, CSS bundles)
  - Runtime cache for Amap tile requests (cache-first, with quota — see below)
  - Runtime cache for Supabase REST responses (network-first, falls back to cache)
- **Tile pre-cache UI:** "Download offline maps" button on the trip page. User picks a bounding box (defaults to the bounds of all current spots) and zoom range (e.g. 8–16). App walks the tile grid and stores tiles via the service worker. Progress bar.
- **Local-first data layer:**
  - **Dexie / IndexedDB** stores `trips`, `spots`, `days`, `routes` for the current trip
  - All reads come from IndexedDB (instant)
  - All writes go to IndexedDB first, then enqueue a sync job
- **Sync queue:** persistent queue in IndexedDB. On reconnect, replay queued mutations to Supabase. On success, mark synced; on conflict, last-write-wins per field by `updated_at`.
- **Realtime in:** subscribe to Supabase Realtime on the current trip; merge inbound changes into IndexedDB. (This is what makes partner edits appear.)
- **Offline indicator:** small badge in the UI showing online/offline state and "X changes pending sync".
- **AI / new-route gating:** when offline, AI input is disabled with a tooltip ("requires network"). Adding a spot to a day still works; its routes appear as "pending".

## Out of scope

- Full conflict resolution UI (just LWW)
- Background sync via SW (foreground sync on app open is fine)
- Photo offline storage

## Exit criteria

All criteria below are verified on iPhone first; Android second.

- Install the app to home screen via Share → "Add to Home Screen" on iOS; verify icon, splash, status bar, no Safari chrome
- Open the trip, hit "Download offline maps" — tile cache populates within iOS storage budget; usage shown to user
- Turn on airplane mode — relaunch the app from the home screen — see all spots, days, routes, and map tiles for the trip area
- Edit a note offline → re-enable network → edit appears in Supabase
- Partner edits a spot online → my offline app picks it up next time I'm online
- Don't open the app for 7+ days, then open it offline: app handles purged storage gracefully (shows a "needs to re-sync" message when next online, doesn't crash)
