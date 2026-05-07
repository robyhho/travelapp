# Phase 5 — Days & itinerary

## Goal

The itinerary takes shape. Days exist with dates; spots can be assigned to them and ordered within them. There's a clear "unassigned itinerary" pool.

## Deliverables

- **Schema additions:**
  - `days` (id, trip_id, date, position, notes)
  - `trips.start_date` / `trips.end_date` already exist from Phase 3 — enforce that days fall within range
- **Days panel** in the sidebar (new tab/section alongside the spots list):
  - One card per day, in date order
  - Each card lists assigned spots in `order_in_day` order
  - "Unassigned" pseudo-card at the top for `in_itinerary = true && day_id = null` spots
  - Wishlist spots NOT shown here (only in the spots panel)
- **Assign / reassign:** drag a spot from the unassigned pool onto a day card, or between day cards. Reorder within a day by drag. Use a touch-friendly drag library (`dnd-kit`).
- **Quick-assign menu** as a fallback for users who hate drag on mobile: tap a spot → "Move to day…" → pick a day.
- **Map highlights** the currently-selected day's spots; others fade.
- **Day notes** (markdown) per day card.
- Editing dates on a trip prunes/warns about days that fall out of range.

## Out of scope

- Routes between spots within a day (Phase 6)
- AI suggesting reorders (Phase 9)
- Multi-day spot (e.g. a hotel that spans nights) — single `day_id` for now is fine

## Exit criteria

- Create a 5-day trip; add 10 itinerary spots; assign them across days; reorder within a day — reload, everything persists
- Drag works on a phone with no jank
- Removing a spot from a day puts it back in the unassigned pool, doesn't delete it
