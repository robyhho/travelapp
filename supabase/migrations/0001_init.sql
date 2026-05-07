-- Initial schema: trips, trip_members, spots + RLS scoped to trip membership.

create extension if not exists "uuid-ossp";

-- TRIPS -----------------------------------------------------------------
create table public.trips (
    id          uuid primary key default uuid_generate_v4(),
    name        text not null check (length(name) between 1 and 120),
    owner_id    uuid not null references auth.users(id) on delete cascade,
    start_date  date,
    end_date    date,
    created_at  timestamptz not null default now()
);

create index trips_owner_id_idx on public.trips(owner_id);

-- TRIP MEMBERS ----------------------------------------------------------
create type trip_role   as enum ('owner', 'member');
create type trip_status as enum ('active', 'pending');

create table public.trip_members (
    trip_id      uuid not null references public.trips(id) on delete cascade,
    user_id      uuid not null references auth.users(id) on delete cascade,
    display_name text not null,
    colour       text not null default '#14b8a6',
    role         trip_role   not null default 'member',
    status       trip_status not null default 'active',
    joined_at    timestamptz not null default now(),
    primary key (trip_id, user_id)
);

create index trip_members_user_idx on public.trip_members(user_id);

-- SPOTS -----------------------------------------------------------------
create table public.spots (
    id            uuid primary key default uuid_generate_v4(),
    trip_id       uuid not null references public.trips(id) on delete cascade,
    created_by    uuid not null references auth.users(id) on delete restrict,
    name          text not null check (length(name) between 1 and 200),
    lat           double precision not null check (lat between -90 and 90),
    lng           double precision not null check (lng between -180 and 180),
    category      text not null default 'other',
    notes         text not null default '',
    website_url   text,
    in_itinerary  boolean not null default false,
    day_id        uuid,  -- forward reference; FK constraint added with the `days` table
    order_in_day  integer,
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now()
);

create index spots_trip_created_idx on public.spots(trip_id, created_at);

create or replace function public.touch_updated_at() returns trigger
language plpgsql as $$
begin
    new.updated_at := now();
    return new;
end $$;

create trigger spots_touch_updated_at
before update on public.spots
for each row execute function public.touch_updated_at();

-- AUTO-OWNER TRIGGER ----------------------------------------------------
-- Whenever a trip is inserted, add the owner as an active member.
create or replace function public.add_owner_as_member() returns trigger
language plpgsql security definer
set search_path = public, pg_temp
as $$
begin
    insert into public.trip_members (trip_id, user_id, display_name, role, status)
    values (
        new.id,
        new.owner_id,
        coalesce((select raw_user_meta_data->>'full_name' from auth.users where id = new.owner_id), 'Owner'),
        'owner',
        'active'
    );
    return new;
end $$;

create trigger trips_add_owner_as_member
after insert on public.trips
for each row execute function public.add_owner_as_member();

-- HELPER ----------------------------------------------------------------
create or replace function public.is_trip_member(_trip_id uuid) returns boolean
language sql stable security definer
set search_path = public, pg_temp
as $$
    select exists (
        select 1 from public.trip_members
        where trip_id = _trip_id
          and user_id = auth.uid()
          and status = 'active'
    );
$$;

-- RLS -------------------------------------------------------------------
alter table public.trips         enable row level security;
alter table public.trip_members  enable row level security;
alter table public.spots         enable row level security;

-- trips: members can read; only authed users can create (themselves as owner); only owner can update/delete.
create policy trips_select on public.trips
    for select using (public.is_trip_member(id));

create policy trips_insert on public.trips
    for insert with check (auth.uid() = owner_id);

create policy trips_update on public.trips
    for update using (auth.uid() = owner_id)
    with check (auth.uid() = owner_id);

create policy trips_delete on public.trips
    for delete using (auth.uid() = owner_id);

-- trip_members: members of a trip can see its membership; owner can manage.
create policy trip_members_select on public.trip_members
    for select using (public.is_trip_member(trip_id));

create policy trip_members_insert on public.trip_members
    for insert with check (
        exists (select 1 from public.trips t where t.id = trip_id and t.owner_id = auth.uid())
    );

create policy trip_members_update on public.trip_members
    for update using (
        exists (select 1 from public.trips t where t.id = trip_id and t.owner_id = auth.uid())
    );

create policy trip_members_delete on public.trip_members
    for delete using (
        exists (select 1 from public.trips t where t.id = trip_id and t.owner_id = auth.uid())
    );

-- spots: trip members can do everything within their trip.
create policy spots_select on public.spots
    for select using (public.is_trip_member(trip_id));

create policy spots_insert on public.spots
    for insert with check (public.is_trip_member(trip_id) and created_by = auth.uid());

create policy spots_update on public.spots
    for update using (public.is_trip_member(trip_id))
    with check (public.is_trip_member(trip_id));

create policy spots_delete on public.spots
    for delete using (public.is_trip_member(trip_id));
