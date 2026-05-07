# Phase 2 — UI skeleton

## Goal

The main map screen exists and feels right. Map renders, sidebar holds info, search field accepts input. All data is mocked in-memory — no Supabase yet.

## Deliverables

- **Adaptive layout**:
  - **iOS (compact)**: full-screen map with a bottom sheet (`presentationDetents`) holding the sidebar content.
  - **iPad / macOS (regular)**: `NavigationSplitView` with sidebar on the leading edge and map on the detail.
- **Map**: SwiftUI wrapper (`MapView`) around MapKit. On both iOS and macOS, prefer SwiftUI's `Map` view (`MapKit` + `MapContentBuilder`) for declarative content. Fall back to `UIViewRepresentable` / `NSViewRepresentable` around `MKMapView` only if a feature isn't yet exposed in the SwiftUI API. Centred on a default city (e.g. Shanghai). Pinch/pan/zoom works.
- **Sidebar** holds:
  - Search field
  - List of spots (mocked, hardcoded array of 5–10 example spots in a `MockData` namespace)
  - Spot detail view (when a pin is selected)
- **Search field**: visually present, wired to filter the in-memory spot list. POI search comes later.
- **Pins**: render mocked spots on the map as `Annotation`s with category-based SF Symbol icons. Tapping a pin highlights its sidebar entry; tapping a sidebar entry pans the map to that spot.
- **No data persistence.** Everything is `@State` / `@Observable`. Killing the app wipes it.
- Loading and empty states in the sidebar.
- Works on iPhone and Mac in the same build.

## Out of scope

- Auth, Supabase, real spots
- Adding/editing pins via UI (Phase 4)
- Days / itinerary panel (Phase 5)
- Routes between pins (Phase 6)
- Sync (Phase 7)

## Exit criteria

- iOS Simulator: see the map, see the sidebar bottom sheet, see mock pins, tap a pin and see its detail
- Bottom sheet drags between detents to reveal the map
- Search field filters the visible spots
- macOS: same flows work via the split view
- No console warnings about missing tiles or auth errors

## Manual steps

- Add a small **NSLocationWhenInUseUsageDescription** entry to the Info.plist with copy like *"Travel App uses your location to centre the map on where you are."* — needed before MapKit can show the user-location dot. (Optional this phase if you skip the user-location feature.)
- Test on a real iPhone over LAN (Xcode → Product → Destination → your device) at least once to confirm pinch/pan feel — Simulator gestures don't represent the real thing.
