# Phase 9 — AI assistant

## Goal

A chat panel scoped to the current trip. Ask questions about ordering, feasibility, alternatives. The AI proposes; the user accepts.

## Deliverables

- **Chat UI** in the sidebar (new tab). Streamed responses. Persists thread per trip in `ai_threads` / `ai_messages` tables (or just IndexedDB — pick at build time).
- **Server route** `/api/chat`:
  - Verifies the user is a member of the trip
  - Builds a structured trip-context block (spots with coords/category/notes, days, ordering)
  - Calls Claude (Anthropic SDK) with prompt caching on the trip-context block
  - Streams response back to client
- **Tools the model can call** (server-side execution, model loops):
  - `get_route(from_spot_id, to_spot_id, mode)` → reuses Phase 6 route logic
  - `compare_orderings(day_id, orderings: spot_id[][])` → calls `get_route` for each pair, returns totals
  - `nearby_search(lat, lng, radius_m, category)` → Amap POI search
- **Suggestion acceptance:** if the model proposes a reorder, the response includes a structured "proposal" block. The UI renders it as a card with "Apply" / "Dismiss" buttons. Apply triggers the same code path as a manual reorder.
- **Offline behaviour:** chat input disabled with "AI requires network" tooltip when offline.
- **Cost guard:** soft per-trip cap on monthly tokens; warn at 80%, block at 100%.

## Out of scope

- AI editing spots / writing notes
- Voice input
- Background jobs (e.g. nightly itinerary review)

## Exit criteria

- Ask "is A → B → C → D shorter than A → C → D → B?" → AI calls `compare_orderings` → returns a clear comparison
- Ask "swap days 2 and 3" → AI proposes the change → "Apply" button updates the itinerary
- Disconnect network → input is disabled with the right message
