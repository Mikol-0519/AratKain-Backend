-- ============================================================================
-- RLS HARDENING — public.users
-- Finding (verified live): any visitor holding the public anon key can read
-- the whole users directory via /rest/v1/users, e.g. emails + usernames.
-- Root cause: no row-level-security policy restricts the `anon` role.
--
-- How to run: Supabase Dashboard → SQL Editor. Run PART 0 first, review the
-- output, then run PART 1. Both parts are safe to re-run.
--
-- Every call the two apps make to this table uses the logged-in user's own
-- session token and filters on their own user_id, so "own row only" policies
-- preserve all features (register / login / profile / avatar upload).
-- ============================================================================


-- ============================================================================
-- PART 0 — DIAGNOSTICS (read-only; run alone first and inspect the output)
-- ============================================================================

-- Which tables does the public schema release, and is RLS even enabled?
select c.relname                as table_name,
       c.relrowsecurity         as rls_enabled,
       c.relforcerowsecurity    as rls_forced
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public' and c.relkind = 'r'
order by c.relname;

-- Existing policies on public tables
select schemaname, tablename, policyname, roles, cmd, qual, with_check
from pg_policies
where schemaname = 'public'
order by tablename;

-- Privileges currently granted to the anon / authenticated roles
select table_name, grantee, privilege_type
from information_schema.role_table_grants
where table_schema = 'public'
  and grantee in ('anon', 'authenticated')
order by table_name, grantee;

-- users table column types (policy compares auth.uid() to user_id)
select column_name, data_type, is_nullable
from information_schema.columns
where table_schema = 'public' and table_name = 'users'
order by ordinal_position;

-- Uniqueness guarantees currently in place
select indexname, indexdef
from pg_indexes
where schemaname = 'public' and tablename = 'users';

-- Does any user row exist with a duplicated username? (blocks a UNIQUE index
-- if we add one later; 0 rows is the goal)
select username, count(*) as occurrences
from public.users
group by username
having count(*) > 1
order by occurrences desc
limit 10;


-- ============================================================================
-- PART 1 — THE FIX (idempotent; safe to re-run)
-- ============================================================================

begin;

-- 1) The one anonymous read that must survive: the register form's
--    username-availability check. Expose it as a boolean RPC instead of raw
--    table access — cannot be used to scrape the directory.
create or replace function public.username_taken(username_to_check text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
    select exists (
        select 1
        from public.users u
        where lower(u.username) = lower(username_to_check)
        limit 1
    );
$$;

grant execute on function public.username_taken(text) to anon, authenticated;

-- 2) Turn on RLS (no-op if already enabled)
alter table public.users enable row level security;

-- 3) Self-row policies for signed-in users
drop policy if exists "users: authenticated select own row" on public.users;
drop policy if exists "users: authenticated insert own row" on public.users;
drop policy if exists "users: authenticated update own row" on public.users;

create policy "users: authenticated select own row"
    on public.users
    for select to authenticated
    using (auth.uid()::text = user_id::text);

create policy "users: authenticated insert own row"
    on public.users
    for insert to authenticated
    with check (auth.uid()::text = user_id::text);

create policy "users: authenticated update own row"
    on public.users
    for update to authenticated
    using (auth.uid()::text = user_id::text)
    with check (auth.uid()::text = user_id::text);

-- 4) Cut the anonymous role off the table entirely (no policy matches `anon`,
--    and we also drop the direct grants so PostgREST answers 403)
revoke all on public.users from anon;

-- 5) No client ever deletes profiles — remove the privilege outright
revoke delete on public.users from authenticated;

commit;


-- ============================================================================
-- AFTER RUNNING: verify
--   1. anon directory scrape is dead:
--      select count(*) from public.users; -- as postgres (bypasses RLS) still works
--      -- and from any HTTP client with only the anon key:
--      --   GET /rest/v1/users → error (permission denied), NO rows
--   2. register still works in web + Android (username check → new RPC)
--   3. login/profile/avatar flows behave as before
-- ============================================================================
