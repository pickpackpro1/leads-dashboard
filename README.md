# Leads Dashboard

A single-page lead-tracking dashboard for PickPackPro, synced live to Supabase (Postgres) so all data is shared and updates in real time across everyone using it.

## Access control
Gated by a shared passcode (no accounts/emails). The passcode is hashed and stored in Postgres; the app checks it via a `check_app_passcode` database function that the browser can call but can never use to read the hash back out. Once entered correctly on a device, that device stays unlocked for 30 days (stored locally, not the passcode itself).

## Setup
1. Run `supabase_schema.sql` in the SQL Editor (safe to re-run) — creates the tables, turns on Realtime broadcasting, and sets up the passcode function.
2. In that file, find the line `values (true, crypt('CHANGE_ME', gen_salt('bf')))` — replace `CHANGE_ME` with your chosen passcode before running (or re-run just that block later to change it).
3. Open the live page, enter the passcode once — everyone connected sees the same data update live as anyone adds, edits, or deletes a lead.

## Notes
- The Supabase anon key in `index.html` is meant to be public (Supabase's design — sensitive access is controlled server-side, not by hiding the key).
- Table-level access (`leads`, `leads_bin`, `app_settings`) is currently open to anyone holding the anon key, same as the passcode gate's own reach — anyone who gets past the passcode screen (or who has the anon key and knows to call the API directly) can read/write. This is the practical ceiling for a passcode-only, no-accounts static site. If real per-person access control is ever needed, that requires actual user accounts (Supabase Auth) instead of one shared passcode.
- To change the passcode later, re-run the `insert into app_auth ...` block in `supabase_schema.sql` with a new value.
