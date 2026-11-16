-- DriveNut database foundation (Supabase / PostgreSQL)
-- Run in Supabase SQL Editor after creating a project.
create extension if not exists pgcrypto;

create type public.account_role as enum ('rider','driver','admin');
create type public.ride_status as enum ('requested','accepted','in_progress','completed','cancelled');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  phone text,
  role public.account_role not null default 'rider',
  created_at timestamptz not null default now()
);

create table public.rides (
  id uuid primary key default gen_random_uuid(),
  rider_id uuid not null references public.profiles(id),
  driver_id uuid references public.profiles(id),
  pickup text not null,
  destination text not null,
  ride_date date not null,
  ride_type text not null default 'Standard',
  status public.ride_status not null default 'requested',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.rides enable row level security;

create policy "Users can read own profile" on public.profiles
 for select to authenticated using (id = auth.uid());
create policy "Users can create own profile" on public.profiles
 for insert to authenticated with check (id = auth.uid());
create policy "Users can update own profile" on public.profiles
 for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

create policy "Riders can view own rides" on public.rides
 for select to authenticated using (rider_id = auth.uid() or driver_id = auth.uid());
create policy "Riders can request rides" on public.rides
 for insert to authenticated with check (rider_id = auth.uid());
create policy "Riders can cancel own requested rides" on public.rides
 for update to authenticated using (rider_id = auth.uid() and status = 'requested')
 with check (rider_id = auth.uid());
create policy "Drivers can accept open rides" on public.rides
 for update to authenticated using (driver_id is null and status = 'requested')
 with check (driver_id = auth.uid() and status in ('accepted','in_progress','completed'));
