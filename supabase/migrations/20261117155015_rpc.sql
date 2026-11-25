create or replace function public.create_family(p_name text, p_display_name text default null)
returns uuid
language plpgsql security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_family_id uuid;
begin
  if v_uid is null then
    raise exception 'Harus login' using errcode = '42501';
  end if;

  insert into public.families (name, created_by)
  values (trim(p_name), v_uid)
  returning id into v_family_id;

  insert into public.family_members (family_id, user_id, role, display_name)
  values (v_family_id, v_uid, 'owner', p_display_name);

  return v_family_id;
end;
$$;

create or replace function public.create_invite(p_family_id uuid, p_role text default 'caregiver')
returns text
language plpgsql security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_alphabet constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  v_code text;
  v_active int;
begin
  if not private.is_family_owner(p_family_id) then
    raise exception 'Hanya owner yang bisa mengundang' using errcode = '42501';
  end if;
  if p_role not in ('caregiver','patient') then
    raise exception 'Role tidak valid: %', p_role using errcode = '22023';
  end if;

  select count(*) into v_active
  from public.family_invites
  where family_id = p_family_id and used_at is null and expires_at > now();
  if v_active >= 20 then
    raise exception 'Terlalu banyak undangan aktif' using errcode = '54000';
  end if;

  loop
    select string_agg(substr(v_alphabet, 1 + floor(random() * length(v_alphabet))::int, 1), '')
      into v_code
    from generate_series(1, 6);
    exit when not exists (select 1 from public.family_invites where code = v_code);
  end loop;

  insert into public.family_invites (family_id, code, role, created_by)
  values (p_family_id, v_code, p_role, v_uid);

  return v_code;
end;
$$;

create or replace function public.accept_invite(p_code text, p_display_name text default null)
returns uuid
language plpgsql security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_inv public.family_invites%rowtype;
begin
  if v_uid is null then
    raise exception 'Harus login' using errcode = '42501';
  end if;

  select * into v_inv
  from public.family_invites
  where code = upper(trim(p_code))
  for update;

  if not found or v_inv.used_at is not null or v_inv.expires_at <= now() then
    raise exception 'Kode undangan tidak valid atau sudah kedaluwarsa' using errcode = 'P0002';
  end if;

  if exists (select 1 from public.family_members where family_id = v_inv.family_id and user_id = v_uid) then
    raise exception 'Kamu sudah menjadi anggota keluarga ini' using errcode = '23505';
  end if;

  insert into public.family_members (family_id, user_id, role, display_name)
  values (v_inv.family_id, v_uid, v_inv.role, p_display_name);

  update public.family_invites
     set used_by = v_uid, used_at = now()
   where id = v_inv.id;

  return v_inv.family_id;
end;
$$;

create or replace function public.set_member_role(p_family_id uuid, p_user_id uuid, p_role text)
returns void
language plpgsql security definer
set search_path = ''
as $$
begin
  if not private.is_family_owner(p_family_id) then
    raise exception 'Hanya owner yang bisa mengubah peran' using errcode = '42501';
  end if;
  if p_role not in ('owner','caregiver','patient') then
    raise exception 'Role tidak valid: %', p_role using errcode = '22023';
  end if;

  if p_role <> 'owner'
     and (select role from public.family_members where family_id = p_family_id and user_id = p_user_id) = 'owner'
     and (select count(*) from public.family_members where family_id = p_family_id and role = 'owner') <= 1 then
    raise exception 'Keluarga harus punya minimal satu owner' using errcode = '23514';
  end if;

  update public.family_members
     set role = p_role
   where family_id = p_family_id and user_id = p_user_id;

  if not found then
    raise exception 'Anggota tidak ditemukan' using errcode = 'P0002';
  end if;
end;
$$;

create or replace function public.remove_member(p_family_id uuid, p_user_id uuid)
returns void
language plpgsql security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_target_role text;
begin
  if not (private.is_family_owner(p_family_id) or p_user_id = v_uid) then
    raise exception 'Tidak diizinkan' using errcode = '42501';
  end if;

  select role into v_target_role
  from public.family_members
  where family_id = p_family_id and user_id = p_user_id;

  if not found then
    raise exception 'Anggota tidak ditemukan' using errcode = 'P0002';
  end if;

  if v_target_role = 'owner'
     and (select count(*) from public.family_members where family_id = p_family_id and role = 'owner') <= 1 then
    raise exception 'Owner terakhir tidak bisa keluar. Jadikan anggota lain owner dulu, atau hapus keluarga.'
      using errcode = '23514';
  end if;

  delete from public.family_members
  where family_id = p_family_id and user_id = p_user_id;
end;
$$;

create or replace function public.my_families()
returns table (family_id uuid, name text, role text, member_count bigint)
language sql stable security definer
set search_path = ''
as $$
  select f.id, f.name, fm.role,
         (select count(*) from public.family_members x where x.family_id = f.id)
  from public.family_members fm
  join public.families f on f.id = fm.family_id
  where fm.user_id = (select auth.uid())
  order by f.created_at;
$$;

create or replace function public.delete_my_account_data()
returns void
language plpgsql security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then
    raise exception 'Harus login' using errcode = '42501';
  end if;

  delete from public.families f
  where exists (select 1 from public.family_members m where m.family_id = f.id and m.user_id = v_uid)
    and not exists (select 1 from public.family_members m where m.family_id = f.id and m.user_id <> v_uid);

  delete from public.family_members where user_id = v_uid;
  delete from public.device_tokens where user_id = v_uid;
end;
$$;

create or replace function public.expand_occurrences(p_from timestamptz, p_to timestamptz)
returns table (
  schedule_id   uuid,
  medication_id uuid,
  patient_id    uuid,
  family_id     uuid,
  scheduled_at  timestamptz,
  grace_minutes int
)
language sql stable security definer
set search_path = ''
as $$
  select s.id, m.id, p.id, p.family_id, occ.at, s.grace_minutes
  from public.schedules s
  join public.medications m on m.id = s.medication_id
  join public.patients p    on p.id = m.patient_id
  cross join lateral generate_series(
      ((p_from at time zone s.timezone)::date - 1)::timestamp,
      ((p_to   at time zone s.timezone)::date)::timestamp,
      interval '1 day'
  ) as d(day)
  cross join lateral unnest(s.times) as t(tm)
  cross join lateral (select ((d.day + t.tm) at time zone s.timezone) as at) as occ
  where s.deleted_at is null
    and m.deleted_at is null
    and p.deleted_at is null
    and m.is_active
    and not m.is_prn
    and extract(isodow from d.day)::int = any (s.days_of_week)
    and d.day::date >= m.start_date
    and (m.end_date is null or d.day::date <= m.end_date)
    and occ.at >= p_from
    and occ.at <  p_to;
$$;

create or replace function public.find_missed_doses(p_lookback interval default interval '6 hours')
returns table (
  schedule_id   uuid,
  medication_id uuid,
  patient_id    uuid,
  family_id     uuid,
  scheduled_at  timestamptz
)
language sql stable security definer
set search_path = ''
as $$
  select o.schedule_id, o.medication_id, o.patient_id, o.family_id, o.scheduled_at
  from public.expand_occurrences(now() - p_lookback, now()) o
  where o.scheduled_at + make_interval(mins => o.grace_minutes) <= now()
    and not exists (
      select 1 from public.dose_logs l
      where l.schedule_id = o.schedule_id and l.scheduled_at = o.scheduled_at
    );
$$;

create or replace function public.find_low_stock()
returns table (
  medication_id uuid,
  patient_id    uuid,
  family_id     uuid,
  medication_name text,
  patient_name  text,
  stock_qty     numeric,
  days_left     numeric
)
language sql stable security definer
set search_path = ''
as $$
  with per_day as (
    select m.id as medication_id,
           sum(cardinality(s.times) * cardinality(s.days_of_week) / 7.0) * m.dose_qty as qty_per_day
    from public.medications m
    join public.schedules s on s.medication_id = m.id and s.deleted_at is null
    where m.deleted_at is null and m.is_active and not m.is_prn and m.stock_qty is not null
      and (m.end_date is null or m.end_date >= current_date)
    group by m.id, m.dose_qty
  )
  select m.id, p.id, p.family_id, m.name, p.name, m.stock_qty,
         round(m.stock_qty / nullif(pd.qty_per_day, 0), 1)
  from per_day pd
  join public.medications m on m.id = pd.medication_id
  join public.patients p on p.id = m.patient_id and p.deleted_at is null
  where pd.qty_per_day > 0
    and m.stock_qty / pd.qty_per_day <= m.refill_threshold_days;
$$;

revoke all on function
  public.create_family(text, text),
  public.create_invite(uuid, text),
  public.accept_invite(text, text),
  public.set_member_role(uuid, uuid, text),
  public.remove_member(uuid, uuid),
  public.my_families(),
  public.delete_my_account_data(),
  public.expand_occurrences(timestamptz, timestamptz),
  public.find_missed_doses(interval),
  public.find_low_stock()
from public, anon, authenticated;

grant execute on function
  public.create_family(text, text),
  public.create_invite(uuid, text),
  public.accept_invite(text, text),
  public.set_member_role(uuid, uuid, text),
  public.remove_member(uuid, uuid),
  public.my_families(),
  public.delete_my_account_data()
to authenticated;

grant execute on function
  public.expand_occurrences(timestamptz, timestamptz),
  public.find_missed_doses(interval),
  public.find_low_stock()
to service_role;
