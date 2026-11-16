-- DriveNut Admin Moderation Permissions
-- Admins are identified by trusted Supabase Auth app_metadata:
-- { "role": "admin" }
-- Never use user_metadata for admin privileges.

drop policy if exists "Admins can view all post reports" on public.post_reports;
create policy "Admins can view all post reports"
on public.post_reports
for select to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Admins can update post reports" on public.post_reports;
create policy "Admins can update post reports"
on public.post_reports
for update to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
