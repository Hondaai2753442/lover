-- Schema proposal for the future online version.
-- Review and enable appropriate RLS policies before using with real users.

create extension if not exists pgcrypto;

create table if not exists public.card_categories (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title_ar text not null,
  sort_order int not null default 0,
  is_active boolean not null default true
);

create table if not exists public.game_cards (
  id uuid primary key default gen_random_uuid(),
  content_key text unique not null,
  category_slug text not null references public.card_categories(slug),
  card_type text not null check (card_type in ('سؤال', 'تحدّي')),
  level text not null default 'خفيف',
  text_ar text not null,
  purpose_ar text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.game_rooms (
  id uuid primary key default gen_random_uuid(),
  room_code text unique not null,
  status text not null default 'waiting'
    check (status in ('waiting', 'playing', 'finished', 'closed')),
  host_token_hash text,
  guest_token_hash text,
  current_card_index int not null default 0,
  selected_categories text[] not null default '{}',
  selected_card_type text not null default 'الكل',
  round_size int not null default 10,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '24 hours')
);

create table if not exists public.room_events (
  id bigint generated always as identity primary key,
  room_id uuid not null references public.game_rooms(id) on delete cascade,
  event_type text not null check (event_type in ('joined', 'card_revealed', 'card_skipped', 'card_completed', 'round_finished')),
  card_id uuid references public.game_cards(id),
  actor_role text not null check (actor_role in ('host', 'guest', 'system')),
  created_at timestamptz not null default now()
);

create index if not exists game_cards_category_type_idx
  on public.game_cards(category_slug, card_type) where is_active = true;
create index if not exists game_rooms_code_status_idx
  on public.game_rooms(room_code, status);
create index if not exists room_events_room_created_idx
  on public.room_events(room_id, created_at);

-- Seed categories. Run once; slug uniqueness makes this safe to re-run.
insert into public.card_categories (slug, title_ar, sort_order) values
  ('closeness', 'التقارب', 1),
  ('romance', 'الرومانسية', 2),
  ('fun', 'المرح', 3),
  ('understanding', 'التفاهم', 4)
on conflict (slug) do nothing;

-- Security note:
-- Do not enable anonymous table writes without carefully designed RLS.
-- For online rooms, prefer server-validated RPC/functions for joining,
-- moving turns, and recording events; never put a service_role key in a mobile app.
