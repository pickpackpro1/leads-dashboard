-- PickPackPro Leads Dashboard — Supabase schema
-- Run this once in your Supabase project's SQL Editor (Project > SQL Editor > New query)

create table if not exists leads (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists leads_bin (
  id text primary key,
  data jsonb not null,
  deleted_at timestamptz not null default now()
);

create table if not exists app_settings (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);

-- Row Level Security
alter table leads enable row level security;
alter table leads_bin enable row level security;
alter table app_settings enable row level security;

-- This app has no login system — it uses the public "anon" API key directly
-- from the browser, so anyone with the URL + anon key can read/write.
-- That's fine for a private internal tool whose URL you don't share, but
-- treat the anon key as "semi-public" — don't post it publicly, and if this
-- ever needs real access control, add Supabase Auth + tighter policies later.
create policy "anon full access leads" on leads
  for all using (true) with check (true);

create policy "anon full access leads_bin" on leads_bin
  for all using (true) with check (true);

create policy "anon full access app_settings" on app_settings
  for all using (true) with check (true);
