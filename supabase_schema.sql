-- PickPackPro Leads Dashboard — Supabase schema
-- Run this in your Supabase project's SQL Editor (Project > SQL Editor > New query).
-- Safe to re-run: it drops/recreates policies so you can run it again after changes.

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

-- Row Level Security: only signed-in sessions may read/write.
-- The app signs everyone in with ONE shared account (team@pickpackpro.internal)
-- after they type the correct password on the login screen — see README.
alter table leads enable row level security;
alter table leads_bin enable row level security;
alter table app_settings enable row level security;

drop policy if exists "anon full access leads" on leads;
drop policy if exists "anon full access leads_bin" on leads_bin;
drop policy if exists "anon full access app_settings" on app_settings;

drop policy if exists "authenticated full access leads" on leads;
create policy "authenticated full access leads" on leads
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "authenticated full access leads_bin" on leads_bin;
create policy "authenticated full access leads_bin" on leads_bin
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "authenticated full access app_settings" on app_settings;
create policy "authenticated full access app_settings" on app_settings
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- Realtime: broadcast row changes so every open browser updates live.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'leads'
  ) then
    alter publication supabase_realtime add table leads;
  end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'leads_bin'
  ) then
    alter publication supabase_realtime add table leads_bin;
  end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'app_settings'
  ) then
    alter publication supabase_realtime add table app_settings;
  end if;
end $$;
