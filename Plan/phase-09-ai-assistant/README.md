# Phase 9 — AI assistant

## Goal

A chat panel scoped to the current trip. Ask questions about ordering, feasibility, alternatives. The AI proposes; the user accepts.

## Deliverables

- **Chat UI** in the sidebar (new tab/section). Streamed responses rendered as they arrive. Threads persisted per trip in SwiftData (`AIThread`, `AIMessage` `@Model` classes), mirrored to Supabase for cross-device.
- **Supabase Edge Function** at `chat`:
  - Verifies the caller is a member of the trip (RLS-style check using the JWT)
  - Builds a structured trip-context block (spots with coords/category/notes, days, ordering)
  - Calls Claude (Anthropic SDK) with **prompt caching** on the trip-context block
  - Streams the response back to the client (Server-Sent Events)
- **Tools the model can call** (executed server-side, model loops):
  - `get_route(from_spot_id, to_spot_id, mode)` — reuses the Phase 6 route logic; if a route exists in DB, return it; otherwise enqueue compute
  - `compare_orderings(day_id, orderings: spot_id[][])` — calls `get_route` for each pair, returns totals
  - `nearby_search(lat, lng, radius_m, category)` — proxies to `MKLocalSearch` results pre-fetched by the client (the function itself can't call MapKit; pattern is "client provides recent search context, AI references it")
- **Suggestion acceptance:** if the model proposes a reorder, the response includes a structured "proposal" block (JSON in a fenced section). The UI renders it as a card with "Apply" / "Dismiss" buttons. Apply triggers the same code path as a manual reorder.
- **Offline behaviour:** chat input disabled with "AI requires network" tooltip when offline.
- **Cost guard:** soft per-trip cap on monthly tokens; warn at 80%, block at 100%.

## Out of scope

- AI editing spots / writing notes
- Voice input
- Background jobs (e.g. nightly itinerary review)

## Exit criteria

- Ask "is A → B → C → D shorter than A → C → D → B?" → AI calls `compare_orderings` → returns a clear comparison
- Ask "swap days 2 and 3" → AI proposes the change → "Apply" updates the itinerary
- Disconnect network → input is disabled with the right message
- Streaming feels live (tokens appear within ~1s of generation)

## Manual steps

- **Anthropic console** (https://console.anthropic.com): top up credit and set a **monthly spend limit**. Configure usage alerts at 70% and 100%.
- **Pick a default model** (e.g. `claude-sonnet-4-6`) and store it as a Supabase Edge Function env var so swapping is one config change.
- **Edge Function deploy**:
  - `supabase functions new chat`
  - `supabase secrets set ANTHROPIC_API_KEY=…`
  - `supabase functions deploy chat`
- **Streaming on iOS**: confirm `URLSession.bytes(for:)` works against the Edge Function's SSE response. (It does, but verify on device — proxies sometimes buffer.)
- **Cost cap config**: decide and document the per-trip monthly token cap as an Edge Function env var (e.g. `AI_MONTHLY_TOKEN_CAP=200000`).
