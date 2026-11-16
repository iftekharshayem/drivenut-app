-- DriveNut image storage setup
-- Run once in Supabase Dashboard > SQL Editor > New query.
-- Public images can be viewed by anyone with the URL. Never upload private/sensitive images.
alter table public.profiles add column if not exists avatar_url text;
alter table public.posts add column if not exists image_url text;
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('drivenut-media','drivenut-media',true,5242880,array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public=true,file_size_limit=5242880,allowed_mime_types=array['image/jpeg','image/png','image/webp'];
drop policy if exists "DriveNut media is publicly viewable" on storage.objects;
create policy "DriveNut media is publicly viewable" on storage.objects for select using (bucket_id='drivenut-media');
drop policy if exists "DriveNut users upload own media" on storage.objects;
create policy "DriveNut users upload own media" on storage.objects for insert to authenticated with check (bucket_id='drivenut-media' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists "DriveNut users update own media" on storage.objects;
create policy "DriveNut users update own media" on storage.objects for update to authenticated using (bucket_id='drivenut-media' and (storage.foldername(name))[1]=auth.uid()::text) with check (bucket_id='drivenut-media' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists "DriveNut users delete own media" on storage.objects;
create policy "DriveNut users delete own media" on storage.objects for delete to authenticated using (bucket_id='drivenut-media' and (storage.foldername(name))[1]=auth.uid()::text);
