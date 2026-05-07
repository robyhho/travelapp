# Phase 2 — UI skeleton

## Goal

The main map page exists and feels right. Map renders, sidebar holds info, searchbar accepts input. All data is mocked / in-memory — no Supabase yet.

## Deliverables

- `/` route is the main map page (single-screen layout for now)
- **Map**: MapLibre GL JS rendering Amap raster tiles, centred on a default city (e.g. Shanghai). Pinch/pan/zoom works on mobile.
- **Sidebar**: collapsible panel that lives over the map on mobile (bottom-sheet style) and beside the map on wider screens. Holds:
  - Search input
  - List of spots (mocked, hardcoded array of 5–10 example spots)
  - Spot detail view (when a pin is selected)
- **Searchbar**: visually present, wired to filter the in-memory spot list. POI search comes later.
- **Pins**: render mocked spots on the map with category icons. Clicking a pin highlights its sidebar entry; clicking a sidebar entry pans the map and pops a marker.
- **No data persistence.** Everything is React state. Refresh wipes it.
- Loading and empty states in the sidebar.
- Responsive: works on a phone first, desktop second.

## Out of scope

- Auth, Supabase, real spots
- Adding/editing pins via UI (Phase 4)
- Days / itinerary panel (Phase 5)
- Routes between pins (Phase 6)
- Coord conversion correctness (use a hard-coded `lib/coords.ts` call site, but don't worry about edge cases yet — the Amap render path needs WGS-84 → GCJ-02 from day one though)

## Exit criteria

- On localhost (or via tunnel to phone), see the map, see the sidebar, see mock pins, can tap a pin and see its detail
- Sidebar collapses out of the way to reveal the map
- Search input filters the visible spots
- No console errors
