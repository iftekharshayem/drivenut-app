-- DriveNut post reporting
create table if not exists public.post_reports (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  reporter_id uuid not null references auth.users(id) on delete cascade,
  reason text not null check (reason in ('spam','harassment','unsafe','inappropriate','other')),
  details text,
  status text not null default 'pending' check (status in ('pending','reviewed','dismissed','actioned')),
  created_at timestamptz not null default now(),
  unique (post_id, reporter_id)
);

alter table public.post_reports enable row level security;

drop policy if exists "Users can submit their own post reports" on public.post_reports;
create policy "Users can submit their own post reports"
on public.post_reports for insert to authenticated
with check (reporter_id = auth.uid());

drop policy if exists "Users can view their own post reports" on public.post_reports;
create policy "Users can view their own post reports"
on public.post_reports for select to authenticated
using (reporter_id = auth.uid());
