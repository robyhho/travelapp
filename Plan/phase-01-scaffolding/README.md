# Phase 1 — Scaffolding

## Goal

Empty, deployable Next.js app with the chosen stack wired up. No features, no data — just bones.

## Deliverables

- `npx create-next-app` with App Router, TypeScript, Tailwind, ESLint
- Folder layout: `app/`, `components/`, `lib/`, `Plan/`, `CLAUDE.md` already at root
- `lib/coords.ts` stub with WGS-84 ↔ GCJ-02 helpers (using `coordtransform`)
- `lib/supabase/` typed client wrapper stub (server + browser variants)
- `.gitignore` covering `node_modules/`, `.next/`, `.env*` (except `.env.local.example`), `.DS_Store`, IDE folders, build artifacts, Supabase local dev files
- `.env.local.example` listing required env vars (Supabase URL/anon key, Amap key, Anthropic key)
- Supabase project created (empty schema), Anthropic API key obtained, Amap dev key obtained
- A single `/` route that renders "Travel app — hello"
- `package.json` scripts: `dev`, `build`, `lint`, `typecheck`

## Out of scope

- Map rendering (Phase 2)
- Auth (Phase 3)
- Any DB tables (Phase 3)

## Exit criteria

- `npm run dev` works locally and shows the hello page
- `npm run build && npm run typecheck && npm run lint` all pass
