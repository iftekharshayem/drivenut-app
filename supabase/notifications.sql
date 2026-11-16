-- DriveNut notifications: run once in Supabase SQL Editor.
-- Trigger functions create notifications server-side; clients cannot forge them.
create or replace function public.notify_post_like()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare post_owner uuid;
begin
  select author_id into post_owner from public.posts where id = new.post_id;
  if post_owner is not null and post_owner <> new.user_id then
    insert into public.notifications(recipient_id, actor_id, notification_type, post_id)
    values (post_owner, new.user_id, 'like', new.post_id);
  end if;
  return new;
end;
$$;

create or replace function public.notify_post_comment()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare post_owner uuid;
begin
  select author_id into post_owner from public.posts where id = new.post_id;
  if post_owner is not null and post_owner <> new.author_id then
    insert into public.notifications(recipient_id, actor_id, notification_type, post_id)
    values (post_owner, new.author_id, 'comment', new.post_id);
  end if;
  return new;
end;
$$;

create or replace function public.notify_new_follow()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.notifications(recipient_id, actor_id, notification_type)
  values (new.followed_id, new.follower_id, 'follow');
  return new;
end;
$$;

drop trigger if exists on_post_like_notify on public.post_likes;
create trigger on_post_like_notify after insert on public.post_likes
for each row execute function public.notify_post_like();

drop trigger if exists on_post_comment_notify on public.comments;
create trigger on_post_comment_notify after insert on public.comments
for each row execute function public.notify_post_comment();

drop trigger if exists on_new_follow_notify on public.follows;
create trigger on_new_follow_notify after insert on public.follows
for each row execute function public.notify_new_follow();
