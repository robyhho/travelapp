# Phase 4 — Spots (full CRUD)

## Goal

Spots are first-class. You can add, edit, categorise, annotate, and triage them between wishlist and itinerary. Pin colour reflects who added them.

## Deliverables

- **Add spot flow:**
  - Tap on the map → temporary marker → sheet opens (`AddSpotSheet`) with name, category, notes, website, in_itinerary toggle (defaults to wishlist)
  - Or: search via `MKLocalSearch` → tap result → sheet opens with name + WGS-84 coords prefilled
- **Edit spot:** tap pin → detail sheet → edit any field
- **Delete spot:** in detail sheet, with confirmation alert
- **Categories** with distinct SF Symbols: `fork.knife` (restaurant), `figure.hiking` (hike), `camera` (photo), `building.columns` (sight), `bed.double` (hotel), `mappin` (other)
- **Markdown notes**: render mode uses `Text(AttributedString(markdown:))`; edit mode is a plain `TextEditor`. No rich editor.
- **Website URL** field with an "Open" button that uses `Link` / `NSWorkspace.shared.open` to launch the system browser
- **Wishlist vs itinerary** toggle on each spot. Wishlist pins render at lower opacity. A filter chip in the sidebar shows/hides wishlist pins.
- **Author colour** rendering: pin fill colour = `trip_members.colour` of `created_by`. Map legend overlay maps colour → display_name.
- **Sidebar list** shows all spots, grouped by `wishlist | itinerary`, sorted by `created_at` desc. Tap to focus on map.

## Out of scope

- Days / `day_id` assignment (Phase 5 — column exists, UI doesn't expose it yet)
- Routes between spots (Phase 6)
- Drag-and-drop (Phase 5)
- Photo uploads
- Realtime sync of edits between users (Phase 7)
- Local-first / SwiftData persistence (Phase 7)

## Exit criteria

- Add a restaurant pin via map tap; edit its notes; toggle to itinerary; relaunch — all persists
- Add a hike pin via `MKLocalSearch`; verify the coord lands correctly on the MapLibre map (no offset, including inside China — MapKit returns WGS-84)
- Open the trip on a second account (manually-added partner) and verify their pins show in their colour, mine show in mine
- Wishlist filter chip hides/shows muted pins

## Manual steps

- Verify your second test account is added as a `trip_members` row for the same trip (still manual until Phase 8). Sign in as them on a second simulator or device to test author colours.
- For `MKLocalSearch` to return results inside mainland China, the device's locale doesn't need to be Chinese — Apple's data is location-aware. You may want to test from a real device set to a Chinese region for a realistic check.
