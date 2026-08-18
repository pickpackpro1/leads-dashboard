# Leads Dashboard

A single-page lead-tracking dashboard for PickPackPro, synced to Supabase (Postgres) so data is shared across devices/browsers.

## Setup
1. Run `supabase_schema.sql` once in your Supabase project's SQL Editor to create the `leads`, `leads_bin`, and `app_settings` tables.
2. The app is already wired to the project's URL and anon key in `index.html`.
3. Open the live page — the app pulls from Supabase on load and pushes every change back automatically.

Note: the anon key embedded in `index.html` is meant to be public-readable per Supabase's design (access is controlled by Row Level Security policies), but this app currently has no login — anyone with the page URL can read/write the leads data. Don't share the URL publicly.
