-- DriveNut performance indexes for existing installations.
-- Safe to run more than once in Supabase SQL Editor.
create index if not exists follows_followed_id_idx on public.follows(followed_id);
create index if not exists post_likes_user_id_idx on public.post_likes(user_id);
create index if not exists community_members_user_id_idx on public.community_members(user_id);
create index if not exists community_posts_recent_idx on public.community_posts(community_id,created_at desc);
create index if not exists post_reports_status_created_idx on public.post_reports(status,created_at desc);
create index if not exists post_reports_post_id_idx on public.post_reports(post_id);
