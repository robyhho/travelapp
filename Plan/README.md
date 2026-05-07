# Implementation plan

Phased build of the travel app. Each phase has its own folder with a `README.md` describing scope, deliverables, and exit criteria.

Build phases sequentially. Don't ship phase N+1 work while phase N's exit criteria aren't met — but small refactors that prepare for later phases are fine.

| #  | Phase                | One-line goal                                                              |
|----|----------------------|----------------------------------------------------------------------------|
| 01 | Scaffolding          | Empty Next.js app deploys to Vercel and renders a hello page.              |
| 02 | UI skeleton          | Main map page with sidebar, searchbar, mock pins. No backend yet.          |
| 03 | Auth & trip          | Sign in, create a trip, persist pins to Supabase with RLS.                 |
| 04 | Spots                | Full spot CRUD: categories, notes, website, wishlist toggle, author colour.|
| 05 | Days                 | Days with dates; assign spots to days; reorder within a day.               |
| 06 | Routes               | Compute and persist routes via Amap; render polylines; mode toggle.        |
| 07 | PWA & offline        | Installable PWA; IndexedDB local-first; tile pre-cache; sync queue.        |
| 08 | Invites              | Email invites + shareable tokens; member list; remove member.              |
| 09 | AI assistant         | Chat panel; Claude route handler; trip-context cache; route tools.         |
| 10 | Launch               | Deploy to Vercel; public sign-up; per-user quotas; ToS/privacy; cost guards.|

Until Phase 10, the app runs locally only (`npm run dev`). Manual testing happens on the dev machine and on a phone via the local network URL or a tunnel (e.g. ngrok / Cloudflare Tunnel) when needed.

## Phase exit criteria — general

Before moving on, every phase must:

- Pass typecheck and lint
- Have its happy path manually verified end-to-end (locally)
- Not regress earlier phases' exit criteria
