-- DriveNut real communities (run in Supabase SQL Editor)
create table if not exists public.communities (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  description text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.community_members (
  community_id uuid not null references public.communities(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('member','moderator','admin')),
  joined_at timestamptz not null default now(),
  primary key (community_id, user_id)
);

create table if not exists public.community_posts (
  id uuid primary key default gen_random_uuid(),
  community_id uuid not null references public.communities(id) on delete cascade,
  author_id uuid not null references auth.users(id) on delete cascade,
  content text not null check (char_length(trim(content)) between 1 and 2000),
  created_at timestamptz not null default now()
);

alter table public.communities enable row level security;
alter table public.community_members enable row level security;
alter table public.community_posts enable row level security;

drop policy if exists "Communities are visible to everyone" on public.communities;
create policy "Communities are visible to everyone"
on public.communities for select to authenticated using (true);

drop policy if exists "Members can view community memberships" on public.community_members;
create policy "Members can view community memberships"
on public.community_members for select to authenticated using (true);

drop policy if exists "Users can join as themselves" on public.community_members;
create policy "Users can join as themselves"
on public.community_members for insert to authenticated
with check (auth.uid() = user_id and role = 'member');

drop policy if exists "Users can leave communities" on public.community_members;
create policy "Users can leave communities"
on public.community_members for delete to authenticated using (auth.uid() = user_id);

drop policy if exists "Members can read community posts" on public.community_posts;
create policy "Members can read community posts"
on public.community_posts for select to authenticated
using (exists (
  select 1 from public.community_members m
  where m.community_id = community_posts.community_id and m.user_id = auth.uid()
));

drop policy if exists "Members can create community posts" on public.community_posts;
create policy "Members can create community posts"
on public.community_posts for insert to authenticated
with check (
  auth.uid() = author_id and exists (
    select 1 from public.community_members m
    where m.community_id = community_posts.community_id and m.user_id = auth.uid()
  )
);

drop policy if exists "Authors can delete own community posts" on public.community_posts;
create policy "Authors can delete own community posts"
on public.community_posts for delete to authenticated
using (auth.uid() = author_id);

insert into public.communities (name, slug, description) values
('Road Safety Circle','road-safety','Share responsible driving habits, road awareness and safety discussions.'),
('City & Route Updates','city-routes','Discuss traffic, routes, road conditions and helpful local updates.'),
('Driver Stories','driver-stories','Share experiences, lessons and memorable moments from the road.'),
('New Drivers Corner','new-drivers','Ask beginner questions and learn in a welcoming community.')
on conflict (slug) do nothing;

-- Keep member and discussion lookups responsive as communities grow.
create index if not exists community_members_user_id_idx on public.community_members(user_id);
create index if not exists community_posts_recent_idx on public.community_posts(community_id,created_at desc);
