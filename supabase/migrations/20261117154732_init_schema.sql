-- =====================================================================
-- Kizuvia — 0001 Skema awal
-- =====================================================================
create schema if not exists private;

create table public.families (
  id          uuid primary key default gen_random_uuid(),
  name        text not null check (char_length(name) between 1 and 80),
  created_by  uuid not null references auth.users(id),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table public.family_members (
  family_id     uuid not null references public.families(id) on delete cascade,
  user_id       uuid not null references auth.users(id) on delete cascade,
  role          text not null check (role in ('owner','caregiver','patient')),
  display_name  text check (char_length(display_name) <= 60),
  notify_missed boolean not null default true,
  joined_at     timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  primary key (family_id, user_id)
);

create table public.family_invites (
  id          uuid primary key default gen_random_uuid(),
  family_id   uuid not null references public.families(id) on delete cascade,
  code        text not null unique check (code ~ '^[A-Z2-9]{6}$'),
  role        text not null check (role in ('caregiver','patient')),
  created_by  uuid not null references auth.users(id),
  created_at  timestamptz not null default now(),
  expires_at  timestamptz not null default now() + interval '7 days',
  used_by     uuid references auth.users(id),
  used_at     timestamptz
);

create table public.patients (
  id          uuid primary key default gen_random_uuid(),
  family_id   uuid not null references public.families(id) on delete cascade,
  user_id     uuid references auth.users(id) on delete set null,
  name        text not null check (char_length(name) between 1 and 80),
  birth_year  int check (birth_year between 1900 and 2100),
  conditions  text[] not null default '{}',
  notes       text,
  photo_path  text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);

create table public.medications (
  id                    uuid primary key default gen_random_uuid(),
  patient_id            uuid not null references public.patients(id) on delete cascade,
  name                  text not null check (char_length(name) between 1 and 120),
  strength              text,
  form                  text check (form in ('tablet','kapsul','sirup','tetes','salep','injeksi','inhaler','lainnya')),
  instructions          text,
  meal_relation         text check (meal_relation in ('sebelum_makan','sesudah_makan','bersama_makan','bebas')),
  prescribed_by         text,
  stock_qty             numeric check (stock_qty >= 0),
  dose_qty              numeric not null default 1 check (dose_qty > 0),
  refill_threshold_days int not null default 3 check (refill_threshold_days >= 0),
  photo_path            text,
  start_date            date not null default current_date,
  end_date              date,
  is_prn                boolean not null default false,
  is_active             boolean not null default true,
  source                text not null default 'manual' check (source in ('manual','scan')),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  deleted_at            timestamptz,
  check (end_date is null or end_date >= start_date)
);

create table public.schedules (
  id             uuid primary key default gen_random_uuid(),
  medication_id  uuid not null references public.medications(id) on delete cascade,
  times          time[] not null check (cardinality(times) between 1 and 12),
  days_of_week   int[] not null default '{1,2,3,4,5,6,7}'
                 check (days_of_week <@ '{1,2,3,4,5,6,7}'::int[] and cardinality(days_of_week) >= 1),
  timezone       text not null default 'Asia/Jakarta',
  grace_minutes  int not null default 30 check (grace_minutes between 5 and 240),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  deleted_at     timestamptz
);

create table public.dose_logs (
  id            uuid primary key default gen_random_uuid(),
  schedule_id   uuid not null references public.schedules(id) on delete cascade,
  patient_id    uuid not null references public.patients(id) on delete cascade,
  scheduled_at  timestamptz not null,
  status        text not null check (status in ('taken','skipped','missed')),
  confirmed_by  uuid references auth.users(id) on delete set null,
  confirmed_at  timestamptz,
  source        text not null default 'device' check (source in ('device','server')),
  note          text,
  created_at    timestamptz not null default now(),
  unique (schedule_id, scheduled_at, status)
);

create table public.device_tokens (
  token       text primary key,
  user_id     uuid not null references auth.users(id) on delete cascade,
  platform    text check (platform in ('android','ios')),
  updated_at  timestamptz not null default now()
);

create table private.push_log (
  id          bigint generated always as identity primary key,
  patient_id  uuid not null,
  kind        text not null,
  ref_key     text not null,
  sent_at     timestamptz not null default now(),
  unique (kind, ref_key)
);

create index family_members_user_idx   on public.family_members (user_id);
create index family_invites_family_idx on public.family_invites (family_id);
create index patients_family_idx       on public.patients (family_id);
create index patients_updated_idx      on public.patients (updated_at);
create index medications_patient_idx   on public.medications (patient_id);
create index medications_updated_idx   on public.medications (updated_at);
create index schedules_medication_idx  on public.schedules (medication_id);
create index schedules_updated_idx     on public.schedules (updated_at);
create index dose_logs_patient_idx     on public.dose_logs (patient_id, scheduled_at desc);
create index dose_logs_created_idx     on public.dose_logs (created_at);
create index dose_logs_confirmed_by_idx on public.dose_logs (confirmed_by);
create index device_tokens_user_idx    on public.device_tokens (user_id);
create index families_created_by_idx   on public.families (created_by);
create index patients_user_idx         on public.patients (user_id);
create index family_invites_created_by_idx on public.family_invites (created_by);
create index family_invites_used_by_idx    on public.family_invites (used_by);

create or replace function private.touch_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger touch_families       before update on public.families       for each row execute function private.touch_updated_at();
create trigger touch_family_members before update on public.family_members for each row execute function private.touch_updated_at();
create trigger touch_patients       before update on public.patients       for each row execute function private.touch_updated_at();
create trigger touch_medications    before update on public.medications    for each row execute function private.touch_updated_at();
create trigger touch_schedules      before update on public.schedules      for each row execute function private.touch_updated_at();
create trigger touch_device_tokens  before update on public.device_tokens  for each row execute function private.touch_updated_at();

revoke all on all tables in schema public from anon, authenticated;

grant select, update, delete         on public.families       to authenticated;
grant select                         on public.family_members to authenticated;
grant update (display_name, notify_missed) on public.family_members to authenticated;
grant select                         on public.family_invites to authenticated;
grant select, insert, update, delete on public.patients       to authenticated;
grant select, insert, update, delete on public.medications    to authenticated;
grant select, insert, update, delete on public.schedules      to authenticated;
grant select, insert                 on public.dose_logs      to authenticated;
grant select, insert, update, delete on public.device_tokens  to authenticated;

grant all on all tables in schema public to service_role;
grant usage on schema private to authenticated, service_role;
grant all on private.push_log to service_role;
