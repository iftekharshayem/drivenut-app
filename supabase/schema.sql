-- DriveNut: driver social community database (Supabase PostgreSQL)
-- Run in Supabase SQL Editor. This adds community tables; it does not delete existing data.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  display_name text not null,
  driver_type text not null default 'Driver',
  bio text not null default '',
  avatar_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  content text not null check (char_length(content) between 1 and 3000),
  post_type text not null default 'story' check (post_type in ('story','tip','question','discussion')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  content text not null check (char_length(content) between 1 and 1000),
  created_at timestamptz not null default now()
);

create table if not exists public.post_likes (
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id,user_id)
);

create table if not exists public.follows (
  follower_id uuid not null references public.profiles(id) on delete cascade,
  followed_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id,followed_id),
  check (follower_id <> followed_id)
);

create table if not exists public.saved_posts (
  user_id uuid not null references public.profiles(id) on delete cascade,
  post_id uuid not null references public.posts(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id,post_id)
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid not null references public.profiles(id) on delete cascade,
  actor_id uuid references public.profiles(id) on delete set null,
  notification_type text not null check (notification_type in ('like','comment','follow')),
  post_id uuid references public.posts(id) on delete cascade,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists posts_created_at_idx on public.posts(created_at desc);
create index if not exists posts_author_id_idx on public.posts(author_id);
create index if not exists comments_post_id_idx on public.comments(post_id,created_at);
create index if not exists notifications_recipient_idx on public.notifications(recipient_id,created_at desc);

alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.comments enable row level security;
alter table public.post_likes enable row level security;
alter table public.follows enable row level security;
alter table public.saved_posts enable row level security;
alter table public.notifications enable row level security;

drop policy if exists "Community profiles are readable" on public.profiles;
create policy "Community profiles are readable" on public.profiles for select to authenticated using (true);
drop policy if exists "Users create own profile" on public.profiles;
create policy "Users create own profile" on public.profiles for insert to authenticated with check (id = auth.uid());
drop policy if exists "Users update own profile" on public.profiles;
create policy "Users update own profile" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists "Authenticated users read posts" on public.posts;
create policy "Authenticated users read posts" on public.posts for select to authenticated using (true);
drop policy if exists "Users create own posts" on public.posts;
create policy "Users create own posts" on public.posts for insert to authenticated with check (author_id = auth.uid());
drop policy if exists "Authors update own posts" on public.posts;
create policy "Authors update own posts" on public.posts for update to authenticated using (author_id = auth.uid()) with check (author_id = auth.uid());
drop policy if exists "Authors delete own posts" on public.posts;
create policy "Authors delete own posts" on public.posts for delete to authenticated using (author_id = auth.uid());

drop policy if exists "Authenticated users read comments" on public.comments;
create policy "Authenticated users read comments" on public.comments for select to authenticated using (true);
drop policy if exists "Users add own comments" on public.comments;
create policy "Users add own comments" on public.comments for insert to authenticated with check (author_id = auth.uid());
drop policy if exists "Authors delete own comments" on public.comments;
create policy "Authors delete own comments" on public.comments for delete to authenticated using (author_id = auth.uid());

drop policy if exists "Likes visible to members" on public.post_likes;
create policy "Likes visible to members" on public.post_likes for select to authenticated using (true);
drop policy if exists "Users manage own likes" on public.post_likes;
create policy "Users manage own likes" on public.post_likes for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "Users remove own likes" on public.post_likes;
create policy "Users remove own likes" on public.post_likes for delete to authenticated using (user_id = auth.uid());

drop policy if exists "Follows visible to members" on public.follows;
create policy "Follows visible to members" on public.follows for select to authenticated using (true);
drop policy if exists "Users follow others" on public.follows;
create policy "Users follow others" on public.follows for insert to authenticated with check (follower_id = auth.uid());
drop policy if exists "Users unfollow" on public.follows;
create policy "Users unfollow" on public.follows for delete to authenticated using (follower_id = auth.uid());

drop policy if exists "Users read own saved posts" on public.saved_posts;
create policy "Users read own saved posts" on public.saved_posts for select to authenticated using (user_id = auth.uid());
drop policy if exists "Users save posts" on public.saved_posts;
create policy "Users save posts" on public.saved_posts for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "Users unsave posts" on public.saved_posts;
create policy "Users unsave posts" on public.saved_posts for delete to authenticated using (user_id = auth.uid());

drop policy if exists "Users read own notifications" on public.notifications;
create policy "Users read own notifications" on public.notifications for select to authenticated using (recipient_id = auth.uid());
drop policy if exists "Users mark own notifications read" on public.notifications;
create policy "Users mark own notifications read" on public.notifications for update to authenticated using (recipient_id = auth.uid()) with check (recipient_id = auth.uid());

-- Note: Supabase Auth must be configured before the tables can be used by real members.
-- Never expose a Supabase service_role key in browser code.
-- Query-performance indexes for feed and relationship lookups.
create index if not exists follows_followed_id_idx on public.follows(followed_id);
create index if not exists post_likes_user_id_idx on public.post_likes(user_id);
