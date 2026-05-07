# Phase 8 — Invites

## Goal

The owner can invite their partner (and later, anyone) to a trip without using the Supabase dashboard.

## Deliverables

- **Members panel** in trip settings: list of `trip_members` with avatar, display_name, colour swatch, role, status, "remove" button (owner-only).
- **Invite by email:** owner enters an email → row inserted in `trip_members` with `status = pending` and an `invite_token`. Sends an email via Supabase Auth (or Resend) with a link `/accept-invite?token=…`.
- **Shareable invite link:** owner clicks "Get share link" → generates a single-use, 7-day token → copies to clipboard. Same `/accept-invite?token=…` route handles it.
- **Accept flow:** unauthenticated visitor → prompted to sign in → on success, token is consumed, `trip_members.status` flips to `active`, redirect to `/trips/[id]`.
- **Colour assignment:** on join, the new member is auto-assigned the next unused colour from a fixed palette of ~6.
- **Remove member:** owner-only. Removed user loses access (RLS does the work) but their pins remain (still attributed via `created_by`).

## Out of scope

- Roles beyond owner / member
- Re-inviting a removed user (just invite again)
- Per-member granular permissions

## Exit criteria

- Owner invites partner by email; partner clicks link, signs in, lands on the trip with their colour assigned
- Partner can add and edit spots; owner sees them in real time (via Phase 7 realtime)
- Owner removes partner; partner can no longer load the trip
