# Phase 5 — Days & itinerary

## Goal

The itinerary takes shape. Days exist with dates; spots can be assigned to them and ordered within them. There's a clear "unassigned itinerary" pool.

## Deliverables

- **Schema additions:**
  - `days` (id, trip_id, date, position, notes)
  - Enforce that days fall within `trips.start_date` / `trips.end_date`
- **Days view** in the sidebar (`DaysView`, alongside `SpotsView`):
  - One card per day, in date order
  - Each card lists assigned spots in `order_in_day` order
  - "Unassigned" pseudo-card at the top for `in_itinerary = true && day_id = null` spots
  - Wishlist spots NOT shown here
- **Assign / reassign:** SwiftUI `.draggable` / `.dropDestination` to move a spot between day cards or within a day (reorder). Use `.dragHandle` affordance on iPad/macOS, long-press on iOS.
- **Quick-assign menu** as a fallback: tap a spot → context menu → "Move to day…" → pick a day. Touch users who hate drag get a working alternative.
- **Map highlights** the currently-selected day's spots; others fade.
- **Day notes** (markdown) per day card.
- Editing a trip's date range prunes/warns about days that fall out of range.

## Out of scope

- Routes between spots within a day (Phase 6)
- AI suggesting reorders (Phase 9)
- Multi-day spot (e.g. a hotel spanning nights) — single `day_id` for now

## Exit criteria

- Create a 5-day trip; add 10 itinerary spots; assign them across days; reorder within a day — relaunch, everything persists
- Drag works smoothly on iPhone (touch), iPad (touch + Pencil), macOS (mouse)
- Removing a spot from a day puts it back in the unassigned pool, doesn't delete it

## Manual steps

- Apply the new `days` migration to Supabase (and update RLS policies for the new table). Re-run `supabase gen types swift --linked > TravelApp/Sources/Repos/Database.swift`.
- Test drag on a real iPhone — Simulator drag-and-drop has a different feel and timing from device.
