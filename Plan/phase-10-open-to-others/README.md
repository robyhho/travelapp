# Phase 10 — Launch

## Goal

Ship it. Distribute via TestFlight first, then App Store. Harden for real users beyond the original two, add the cost and legal guardrails needed for public sign-up.

## Deliverables

### Distribution
- **TestFlight** beta with at least 5 external testers (friends/family) for two weeks
- **App Store Connect** record created with metadata, screenshots (iPhone 6.7", iPhone 5.5", iPad 12.9", Mac), preview video, description, keywords
- **App Store submission** for iOS + iPadOS + macOS (Mac App Store) from the same Multiplatform target
- Privacy nutrition labels filled in honestly (data collected: account info, location during use, content created)
- Production deploy of:
  - Supabase project on a paid tier (daily backups verified, point-in-time recovery enabled)
  - Universal Links domain serving correct `apple-app-site-association`
  - Resend (or chosen email) sending domain verified
  - All Edge Functions deployed with production secrets

### Public sign-up
- Supabase Auth opened to anyone (no email allowlist)
- Sign-up flow polished: welcome screen, "create your first trip" prompt, sample data optional

### Cost guards
- **Per-user daily AI message cap** (e.g. 20)
- **Per-user trip cap** (e.g. 10 active trips)
- **Per-user MapTiler tile budget** (soft cap, tracked server-side)
- Anthropic + MapTiler usage dashboards monitored; alerts at 70% of monthly budget

### Legal & operational
- Privacy Policy page (what we collect, why, retention, deletion) — App Store requires URL
- Terms of Service page — App Store requires URL
- **Account deletion flow** (`DELETE /account` Edge Function cascades to all owned trips) — App Store **mandatory** since iOS 16
- Support email or contact form
- Transactional email templates polished (welcome, invite, password reset)

### Polish pass
- All loading and empty states reviewed
- Error views on every screen
- Accessibility pass (VoiceOver labels, Dynamic Type, contrast)
- Localisation pass (English first; Simplified Chinese a stretch goal)
- Crash reporting via Apple's MetricKit + a thin Edge Function endpoint to log to Supabase

## Exit criteria

- A new user, never seen the app before, can: install from App Store → Sign in with Apple → create a trip → add a spot → use it offline in airplane mode → invite a friend. End-to-end, on production, on a phone, with no help.
- Cost dashboards show per-user limits being enforced (manually verify by exceeding a cap on a test account).
- App Store review passed on first submission (or at most one round of changes).

## Manual steps

- **App Store Connect setup** (https://appstoreconnect.apple.com):
  - Create the app record matching your bundle ID
  - Upload screenshots and preview video for every required device size
  - Fill in description, keywords, support URL, marketing URL
  - Fill privacy nutrition labels accurately
- **Pricing**: free, with no in-app purchases (for now). Decide before submission.
- **TestFlight**: invite external testers; iterate on feedback for ~2 weeks before App Store submission
- **Apple's required URLs**: Privacy Policy and (optionally) Terms must be live at stable URLs before submission. A simple static site works.
- **Supabase**: upgrade to Pro if free-tier limits are tight. Verify daily backups. Set production SMTP (Resend or similar) for transactional email.
- **Universal Links domain**: ensure DNS, HTTPS, and `apple-app-site-association` are all serving correctly in production
- **Anthropic / MapTiler budgets**: set monthly spend caps and 70% / 100% alert emails on both consoles
- **Mac App Store**: the same archive can submit to both App Stores; verify signing with **Developer ID** vs **Apple Distribution** as needed
- **Legal text**: actually write the ToS and Privacy Policy (not generated boilerplate). Have a human review.
- **App Store review notes**: in the review-notes field, give a working test account (Sign in with Apple uses Hide-My-Email, so create a dedicated reviewer account)
- **iOS storage purge / 7-day stale**: not applicable to native apps — gone with the PWA constraint
- **Lighthouse / PWA audit**: not applicable — native app
