# Phase 1 — Scaffolding

## Goal

Empty, runnable SwiftUI Multiplatform app with the chosen stack wired up. No features, no data — just bones.

## Deliverables

- Xcode project at `TravelApp.xcodeproj` with a **SwiftUI Multiplatform** target (`TravelApp`) that builds and runs on:
  - iOS Simulator (iOS 17+)
  - macOS (macOS 14+)
- Folder layout under `TravelApp/`:
  - `Sources/App/` — `TravelAppApp.swift` (entry), `RootView.swift`
  - `Sources/Models/` — placeholder for SwiftData `@Model` classes (Phase 3+)
  - `Sources/Repos/` — placeholder for Supabase repository functions (Phase 3+)
  - `Sources/Lib/` — pure helpers (empty for now)
  - `Sources/Sync/` — placeholder for sync queue + Realtime (Phase 7)
  - `Resources/` — assets, Info.plist values
- **Swift Package Manager dependencies** added (compile only, no usage yet):
  - `supabase-swift` (https://github.com/supabase-community/supabase-swift)
- **Config plumbing** for secrets via `Config.xcconfig` (gitignored) + a checked-in `Config.example.xcconfig`. Keys:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
- A typed `AppConfig` struct in `Sources/Lib/AppConfig.swift` that reads these from `Bundle.main.infoDictionary` (populated via xcconfig → Info.plist substitution).
- `RootView` renders "Travel app — hello" on both platforms.
- `.gitignore` covering `xcuserdata/`, `*.xcuserstate`, `DerivedData/`, `.swiftpm/`, `Config.xcconfig`, `.DS_Store`.

## Out of scope

- Map rendering (Phase 2)
- Auth (Phase 3)
- Any DB tables, RLS, or SwiftData models (Phase 3)
- Sign in with Apple capability (Phase 3)

## Exit criteria

- `xcodebuild -scheme TravelApp -destination 'platform=iOS Simulator,name=iPhone 17' build` succeeds
- `xcodebuild -scheme TravelApp -destination 'platform=macOS' build` succeeds
- App launches in iOS Simulator and shows the hello screen
- App launches on macOS and shows the hello screen

## Manual steps

- **Apple Developer Program**: enrol at https://developer.apple.com ($99/yr). Required later for Sign in with Apple, TestFlight, and App Store. Not strictly needed to build/run in the simulator, but you'll need it before Phase 3.
- **Xcode 15+** installed from the App Store. After install: `sudo xcode-select -s /Applications/Xcode.app` and accept the licence (`sudo xcodebuild -license accept`).
- **Supabase project** in the **`ap-northeast-1` (Tokyo)** region. Create at https://supabase.com → New Project → Region: `Northeast Asia (Tokyo)`. (Supabase doesn't offer Hong Kong; Tokyo is the closest unfiltered AWS region from mainland China without a VPN.) Copy the project URL and **publishable key** (`sb_publishable_...`, formerly called the `anon` key) into `Config.xcconfig` as `SUPABASE_URL` and `SUPABASE_ANON_KEY`. The **secret key** (`sb_secret_...`, formerly `service_role`) is **not** added to the app — it lives only in Edge Function env vars later.
- **Anthropic API key**: sign up at https://console.anthropic.com, create an API key. Don't add to the app — store it in your password manager for Phase 9 when it goes into a Supabase Edge Function secret.
- Copy `Config.example.xcconfig` → `Config.xcconfig` and fill in the values above.
