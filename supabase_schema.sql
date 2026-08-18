-- PickPackPro Leads Dashboard — Supabase schema
-- Run this in your Supabase project's SQL Editor (Project > SQL Editor > New query).
-- Safe to re-run.

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

alter table leads enable row level security;
alter table leads_bin enable row level security;
alter table app_settings enable row level security;

drop policy if exists "anon full access leads" on leads;
drop policy if exists "authenticated full access leads" on leads;
drop policy if exists "team account full access leads" on leads;
create policy "app full access leads" on leads for all using (true) with check (true);

drop policy if exists "anon full access leads_bin" on leads_bin;
drop policy if exists "authenticated full access leads_bin" on leads_bin;
drop policy if exists "team account full access leads_bin" on leads_bin;
create policy "app full access leads_bin" on leads_bin for all using (true) with check (true);

drop policy if exists "anon full access app_settings" on app_settings;
drop policy if exists "authenticated full access app_settings" on app_settings;
drop policy if exists "team account full access app_settings" on app_settings;
create policy "app full access app_settings" on app_settings for all using (true) with check (true);

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

-- ============ PASSCODE GATE ============
-- The passcode itself is never stored or sent in plain text after this step —
-- it's hashed in the database and checked server-side via a function that
-- the anon key can call but cannot use to read the hash back out.
create extension if not exists pgcrypto;

create table if not exists app_auth (
  id boolean primary key default true check (id),
  passcode_hash text not null
);

-- No RLS policies on app_auth at all = nobody (not even signed-in users) can
-- read this table directly through the API, only through the function below.
alter table app_auth enable row level security;

-- Set (or change) the shared passcode: replace 'CHANGE_ME' and run this block.
insert into app_auth (id, passcode_hash)
values (true, crypt('CHANGE_ME', gen_salt('bf')))
on conflict (id) do update set passcode_hash = excluded.passcode_hash;

create or replace function check_app_passcode(input_code text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  stored_hash text;
begin
  select passcode_hash into stored_hash from app_auth where id = true;
  if stored_hash is null then
    return false;
  end if;
  return stored_hash = crypt(input_code, stored_hash);
end;
$$;

grant execute on function check_app_passcode(text) to anon, authenticated;
