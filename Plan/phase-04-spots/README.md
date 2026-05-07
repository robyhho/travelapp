# Phase 4 — Spots (full CRUD)

## Goal

Spots are first-class. You can add, edit, categorise, annotate, and triage them between wishlist and itinerary. Pin colour reflects who added them.

## Deliverables

- **Add spot flow:**
  - Tap on the map → temporary marker → form opens (name, category, notes, website, in_itinerary toggle defaulting to wishlist)
  - Or: search for a place via Amap POI search → tap result → form opens with name + coords prefilled
- **Edit spot:** tap pin → detail panel → edit any field
- **Delete spot:** in detail panel, with confirmation
- **Categories** with distinct icons: restaurant, hike, photo, sight, hotel, other
- **Markdown notes** rendering (read mode) + plain textarea (edit mode). Keep it simple; no rich editor.
- **Website URL** field with a "Open" button that launches in a new tab
- **Wishlist vs itinerary** toggle on each spot. Wishlist pins render muted (lower opacity). A filter chip in the sidebar shows/hides wishlist pins.
- **Author colour** rendering: pin colour = `trip_members.colour` of `created_by`. Legend in a corner of the map mapping colour → display_name.
- **Sidebar list** shows all spots, grouped by `wishlist | itinerary`, sorted by created_at desc. Tap to focus on map.
- **Coord conversion** used correctly everywhere: Amap clicks → WGS-84 before save; render → GCJ-02.

## Out of scope

- Days / day_id assignment (Phase 5 — `day_id` column exists but UI doesn't expose it yet)
- Routes between spots (Phase 6)
- Drag-and-drop (Phase 5)
- Photo uploads
- Realtime sync of edits between users (Phase 7's offline sync covers this)

## Exit criteria

- Add a restaurant pin via map tap; edit its notes; toggle to itinerary; reload — all persists
- Add a hike pin via Amap POI search; verify coord lands correctly on the map (no offset)
- Open the trip with a second user account (manually added member) and verify their pins show in their colour, mine show in mine
- Wishlist filter chip hides/shows muted pins
