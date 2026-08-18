# Leads Dashboard

A single-page lead-tracking dashboard for PickPackPro, synced live to Supabase (Postgres) so all data is shared and updates in real time across everyone using it — no "local only" data.

## Access control
The app is gated by a real Supabase Auth login (not just a UI popup). Everyone shares one login:
- Email: `team@pickpackpro.internal`
- Password: set by you in Supabase Dashboard → Authentication → Users → Add user (check "Auto Confirm User")

Database access (Row Level Security) requires that real signed-in session — the password isn't just a cosmetic gate, it's what unlocks actual read/write access to the data via Supabase Auth.

## Setup
1. Create the shared login: Supabase Dashboard → Authentication → Users → Add user → email `team@pickpackpro.internal`, your chosen password, check "Auto Confirm User".
2. Run `supabase_schema.sql` in the SQL Editor (safe to re-run any time) — creates the tables, locks them to authenticated-only access, and turns on Realtime broadcasting.
3. Open the live page, enter the password once — everyone connected sees the same data update live as anyone adds, edits, or deletes a lead.

## Notes
- The Supabase anon key in `index.html` is meant to be public (Supabase's design — access is controlled by Row Level Security, not by hiding the key).
- To change the shared password later, update it on the `team@pickpackpro.internal` user in Supabase Dashboard → Authentication → Users.
