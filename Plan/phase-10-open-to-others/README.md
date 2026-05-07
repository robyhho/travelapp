# Phase 10 — Launch

## Goal

Ship it. Deploy to Vercel, harden for real users beyond the original two, add the cost and legal guardrails needed to keep public sign-up safe.

## Deliverables

### Deploy
- Vercel project linked; production deploy from `main`
- Custom domain configured
- All env vars set in Vercel (Supabase, Amap, Anthropic) for both Preview and Production
- Supabase project moved to a paid tier if free-tier limits look tight; daily backups verified
- PWA install verified on production URL on iOS + Android

### Public sign-up
- Supabase Auth opened to anyone (no email allowlist)
- Sign-up flow polished (welcome screen, "create your first trip" prompt)

### Cost guards
- Per-user daily AI message cap (e.g. 20)
- Per-user trip cap (e.g. 10 active trips)
- Storage cap per trip (if photos are added later)
- Anthropic + Amap usage dashboards monitored; alerts at 70% of monthly budget

### Legal & operational
- ToS page
- Privacy Policy page (what we collect, why, retention, deletion)
- Account deletion flow (`DELETE /api/account` cascades to all owned trips)
- Basic transactional emails (welcome, invite) styled

### Polish pass
- All loading states and empty states reviewed
- Error boundaries on every page
- 404 / 500 pages
- Lighthouse PWA audit ≥ 90
- Accessibility pass (keyboard nav, alt text, contrast)

## Exit criteria

- A new user, never seen the app before, can: sign up → create a trip → add a spot → install the PWA → use it offline → invite a friend. End-to-end, on production, on a phone, with no help.
- Cost dashboards show per-user limits being enforced (manually verify by exceeding a cap on a test account).
