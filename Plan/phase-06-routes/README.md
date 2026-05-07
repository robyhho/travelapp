# Phase 6 — Routes

## Goal

Each day has a visual route connecting its spots in order. Routes are real (`MKDirections`-computed), persisted (so they survive offline), and switchable by transport mode.

## Deliverables

- **Schema:**
  - `routes` (id, trip_id, from_spot_id, to_spot_id, mode: walk|drive|transit|cycle, distance_m, duration_s, geometry (GeoJSON LineString in WGS-84), computed_at)
  - Unique constraint on `(from_spot_id, to_spot_id, mode)`
- **Compute trigger:** when a spot is added to a day, or its order changes, or its coords change → enqueue `RouteJob`s for the affected segments. Run on a background `Task` — never block a UI thread.
- **`MKDirections` wrapper** in `Sources/Repos/RoutesRepo.swift`. Input: WGS-84 from + to + mode. Output: distance, duration, polyline coordinates, persisted via Supabase (and SwiftData mirror in Phase 7). MapKit Transport types: `.automobile`, `.walking`, `.transit`, `.cycling`.
- **Render**: for the selected day, draw a polyline through the day's spots using stored route geometry, as an `MLNPolyline` overlay. Stops at each spot.
- **Mode toggle** per day: walk / drive / transit / cycle. Switching mode triggers re-computation if that mode's route doesn't exist yet.
- **Pending state**: if a segment has no stored route yet (e.g. just added offline), render a dashed grey line + "pending" badge on the segment.
- **Day summary**: total distance + total duration shown on the day card.

## Out of scope

- Multi-modal routes (e.g. walk + transit + walk) — pick one mode per segment
- Time-of-day-aware transit
- Avoidance preferences (toll roads, etc.)
- AI route comparison (Phase 9)

## Exit criteria

- A 4-spot day shows 3 polylines connecting them in order, with realistic distances
- Reordering a day re-computes only the affected segments
- Switching mode to "walk" updates the line and totals
- Killing the network (airplane mode) and reloading still shows previously-computed routes (because they're persisted server-side; Phase 7 mirrors them locally for true offline)
- Routes computed inside China use Apple's licensed Amap data and look correct (hutong-level accuracy on a Beijing test trip)

## Manual steps

- No third-party routing key needed — `MKDirections` is free and bundled with iOS/macOS. No Amap, Google, or Mapbox dev account.
- Apple **rate-limits `MKDirections`** to ~50 requests/min per device. Build the job queue with a debounce so a bulk reorder doesn't burn through it. (Cost is $0; just don't get throttled.)
- Apple's **Transit** routing isn't available in every region. If a transit request fails with "no routes", fall back to surfacing the error inline on the day card rather than retrying.
- Apply the new `routes` migration to Supabase, including the unique constraint on `(from_spot_id, to_spot_id, mode)`. Re-run `supabase gen types swift`.
