create schema if not exists extensions;
create extension if not exists pgcrypto with schema extensions;
create extension if not exists postgis with schema extensions;

create table if not exists public.users (
  id uuid primary key default extensions.gen_random_uuid(),
  device_id text unique not null,
  username text not null,
  coins integer not null default 0,
  gems integer not null default 0,
  xp integer not null default 0,
  level integer not null default 1,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.player_locations (
  id uuid primary key default extensions.gen_random_uuid(),
  user_id uuid references public.users(id) on delete cascade,
  location extensions.geography(Point, 4326) not null,
  accuracy_meters numeric,
  speed_mps numeric,
  heading_degrees numeric,
  created_at timestamptz default now()
);

create table if not exists public.treasures (
  id uuid primary key default extensions.gen_random_uuid(),
  artifact_name text not null,
  artifact_description text not null,
  rarity text not null check (rarity in ('common', 'uncommon', 'rare', 'epic', 'legendary')),
  coin_value integer not null,
  xp_value integer not null,
  location extensions.geography(Point, 4326) not null,
  h3_cell text,
  spawned_at timestamptz default now(),
  expires_at timestamptz not null,
  collected_at timestamptz,
  collector_id uuid references public.users(id),
  created_at timestamptz default now()
);

create table if not exists public.treasure_collections (
  id uuid primary key default extensions.gen_random_uuid(),
  user_id uuid references public.users(id) on delete cascade,
  treasure_id uuid references public.treasures(id) on delete cascade,
  artifact_name text not null,
  rarity text not null,
  coins_awarded integer not null,
  xp_awarded integer not null,
  collection_location extensions.geography(Point, 4326),
  collected_at timestamptz default now(),
  unique(user_id, treasure_id)
);

create table if not exists public.h3_cells (
  h3_cell text primary key,
  resolution integer not null,
  center_location extensions.geography(Point, 4326),
  target_common_count integer default 20,
  target_uncommon_count integer default 10,
  target_rare_count integer default 5,
  target_epic_count integer default 2,
  target_legendary_count integer default 1,
  last_spawned_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.spawn_jobs (
  id uuid primary key default extensions.gen_random_uuid(),
  h3_cell text,
  status text not null default 'pending',
  spawned_count integer default 0,
  error text,
  created_at timestamptz default now(),
  completed_at timestamptz
);

create table if not exists public.anti_cheat_events (
  id uuid primary key default extensions.gen_random_uuid(),
  user_id uuid references public.users(id) on delete cascade,
  event_type text not null,
  details jsonb,
  location extensions.geography(Point, 4326),
  created_at timestamptz default now()
);

create index if not exists treasures_location_idx on public.treasures using gist (location);
create index if not exists treasures_h3_cell_idx on public.treasures (h3_cell);
create index if not exists treasures_active_idx on public.treasures (expires_at, collected_at);
create index if not exists player_locations_user_created_idx on public.player_locations (user_id, created_at desc);
create index if not exists player_locations_location_idx on public.player_locations using gist (location);
create index if not exists treasure_collections_user_idx on public.treasure_collections (user_id, collected_at desc);
create index if not exists anti_cheat_events_user_idx on public.anti_cheat_events (user_id, created_at desc);

create or replace function public.nearby_treasures(
  p_lat double precision,
  p_lng double precision,
  p_radius_meters double precision
)
returns table (
  id uuid,
  artifact_name text,
  artifact_description text,
  rarity text,
  coin_value integer,
  xp_value integer,
  lat double precision,
  lng double precision,
  distance_meters double precision
)
language sql
stable
as $$
  select
    treasures.id,
    treasures.artifact_name,
    treasures.artifact_description,
    treasures.rarity,
    treasures.coin_value,
    treasures.xp_value,
    extensions.ST_Y(treasures.location::extensions.geometry) as lat,
    extensions.ST_X(treasures.location::extensions.geometry) as lng,
    extensions.ST_Distance(
      treasures.location,
      extensions.ST_SetSRID(extensions.ST_MakePoint(p_lng, p_lat), 4326)::extensions.geography
    ) as distance_meters
  from public.treasures
  where treasures.collected_at is null
    and treasures.expires_at > now()
    and extensions.ST_DWithin(
      treasures.location,
      extensions.ST_SetSRID(extensions.ST_MakePoint(p_lng, p_lat), 4326)::extensions.geography,
      p_radius_meters
    )
  order by distance_meters asc
  limit 75;
$$;

create or replace function public.collect_treasure_atomic(
  p_user_id uuid,
  p_treasure_id uuid,
  p_lat double precision,
  p_lng double precision
)
returns table (
  id uuid,
  artifact_name text,
  artifact_description text,
  rarity text,
  coin_value integer,
  xp_value integer
)
language sql
volatile
as $$
  update public.treasures
  set
    collected_at = now(),
    collector_id = p_user_id
  where treasures.id = p_treasure_id
    and treasures.collected_at is null
    and treasures.expires_at > now()
    and extensions.ST_DWithin(
      treasures.location,
      extensions.ST_SetSRID(extensions.ST_MakePoint(p_lng, p_lat), 4326)::extensions.geography,
      25
    )
  returning
    treasures.id,
    treasures.artifact_name,
    treasures.artifact_description,
    treasures.rarity,
    treasures.coin_value,
    treasures.xp_value;
$$;

create or replace function public.record_player_location_update(
  p_user_id uuid,
  p_lat double precision,
  p_lng double precision,
  p_accuracy_meters numeric,
  p_speed_mps numeric,
  p_heading_degrees numeric
)
returns void
language plpgsql
volatile
as $$
declare
  previous_location record;
  current_location extensions.geography(Point, 4326);
  distance_meters double precision;
  elapsed_seconds double precision;
  calculated_speed double precision;
begin
  current_location := extensions.ST_SetSRID(extensions.ST_MakePoint(p_lng, p_lat), 4326)::extensions.geography;

  select id, location, created_at
  into previous_location
  from public.player_locations
  where user_id = p_user_id
  order by created_at desc
  limit 1;

  insert into public.player_locations (
    user_id,
    location,
    accuracy_meters,
    speed_mps,
    heading_degrees
  )
  values (
    p_user_id,
    current_location,
    p_accuracy_meters,
    p_speed_mps,
    p_heading_degrees
  );

  if previous_location.id is not null then
    distance_meters := extensions.ST_Distance(previous_location.location, current_location);
    elapsed_seconds := greatest(extract(epoch from (now() - previous_location.created_at)), 1);
    calculated_speed := distance_meters / elapsed_seconds;

    if calculated_speed > 75 then
      insert into public.anti_cheat_events (
        user_id,
        event_type,
        details,
        location
      )
      values (
        p_user_id,
        'impossible_travel',
        jsonb_build_object(
          'distanceMeters', distance_meters,
          'elapsedSeconds', elapsed_seconds,
          'calculatedSpeedMps', calculated_speed,
          'reportedSpeedMps', p_speed_mps
        ),
        current_location
      );
    end if;
  end if;
end;
$$;

