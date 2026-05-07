# Implementation plan

Phased build of the travel app. Each phase has its own folder with a `README.md` describing scope, deliverables, and exit criteria.

Build phases sequentially. Don't ship phase N+1 work while phase N's exit criteria aren't met — but small refactors that prepare for later phases are fine.

| #  | Phase                | One-line goal                                                                |
|----|----------------------|------------------------------------------------------------------------------|
| 01 | Scaffolding          | Empty SwiftUI Multiplatform app builds and runs on iOS Simulator + macOS.    |
| 02 | UI skeleton          | Map screen with sidebar, search field, mock pins. No backend yet.            |
| 03 | Auth & trip          | Sign in with Apple, create a trip, persist pins to Supabase with RLS.        |
| 04 | Spots                | Full spot CRUD: categories, notes, website, wishlist toggle, author colour.  |
| 05 | Days                 | Days with dates; assign spots to days; reorder within a day.                 |
| 06 | Routes               | Compute and persist routes via `MKDirections`; render polylines; mode toggle.|
| 07 | Offline & sync       | SwiftData local-first; sync queue; Realtime in. (Map basemap stays online.)  |
| 08 | Invites              | Email invites + shareable tokens via Universal Links; member list; remove.   |
| 09 | AI assistant         | Chat panel; Claude via Edge Function; trip-context cache; route tools.       |
| 10 | Launch               | TestFlight → App Store; public sign-up; per-user quotas; ToS/privacy.        |

Until Phase 10, distribution is via Xcode (run on simulator or device) and ad-hoc TestFlight builds for the partner.

## Phase exit criteria — general

Before moving on, every phase must:

- Build clean for iOS and macOS (`xcodebuild build` succeeds with no warnings)
- Have its happy path manually verified end-to-end on iPhone Simulator and a real iPhone (and macOS where relevant)
- Not regress earlier phases' exit criteria
