# Phase 6 — Routes

## Goal

Each day has a visual route connecting its spots in order. Routes are real (Amap-computed), persisted (so they survive offline), and switchable by transport mode.

## Deliverables

- **Schema:**
  - `routes` (id, trip_id, from_spot_id, to_spot_id, mode: walk|drive|transit|cycle, distance_m, duration_s, geometry (GeoJSON LineString), computed_at)
  - Unique constraint on (from_spot_id, to_spot_id, mode)
- **Compute trigger:** when a spot is added to a day, or its order changes, or its coords change → enqueue route computations for the affected segments. Background job style — don't block the UI.
- **Amap Directions API** wrapper in `lib/amap/directions.ts`. Input: WGS-84 from + to + mode. Output: distance, duration, GeoJSON in WGS-84 (convert from GCJ-02 response).
- **Render:** for the selected day, draw a polyline through the day's spots using stored route geometry. Colour reflects mode (or stays neutral; tbd at build time). Stops at each spot.
- **Mode toggle** per day: walk / drive / transit. Switching mode triggers re-computation if that mode's route doesn't exist yet.
- **Pending state:** if a segment has no stored route yet (e.g. just added offline in China), render a dashed grey line + "pending" badge on the segment.
- **Day summary:** total distance + total duration shown on the day card.

## Out of scope

- Multi-modal routes (e.g. walk + transit + walk) — pick one mode per segment
- Time-of-day-aware transit
- Route avoidance preferences (toll roads, etc.)
- AI route comparison (Phase 9)

## Exit criteria

- A 4-spot day shows 3 polylines connecting them in order, with realistic distances
- Reordering a day re-computes the affected segments (and only those)
- Switching mode to "walk" updates the line and totals
- Killing the network and reloading still shows the previously-computed routes (because they're persisted)
