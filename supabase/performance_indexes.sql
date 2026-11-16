-- DriveNut performance indexes for existing installations.
-- Safe to run more than once; absent optional feature tables are skipped.
do $$
begin
  if to_regclass('public.follows') is not null then
    execute 'create index if not exists follows_followed_id_idx on public.follows(followed_id)';
  end if;
  if to_regclass('public.post_likes') is not null then
    execute 'create index if not exists post_likes_user_id_idx on public.post_likes(user_id)';
  end if;
  if to_regclass('public.community_members') is not null then
    execute 'create index if not exists community_members_user_id_idx on public.community_members(user_id)';
  end if;
  if to_regclass('public.community_posts') is not null then
    execute 'create index if not exists community_posts_recent_idx on public.community_posts(community_id,created_at desc)';
  end if;
  if to_regclass('public.post_reports') is not null then
    execute 'create index if not exists post_reports_status_created_idx on public.post_reports(status,created_at desc)';
    execute 'create index if not exists post_reports_post_id_idx on public.post_reports(post_id)';
  end if;
end
$$;
