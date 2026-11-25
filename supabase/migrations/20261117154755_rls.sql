create or replace function private.is_family_member(fid uuid)
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.family_members
    where family_id = fid and user_id = (select auth.uid())
  );
$$;

create or replace function private.is_family_owner(fid uuid)
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.family_members
    where family_id = fid and user_id = (select auth.uid()) and role = 'owner'
  );
$$;

create or replace function private.patient_family(pid uuid)
returns uuid
language sql stable security definer
set search_path = ''
as $$
  select family_id from public.patients where id = pid;
$$;

create or replace function private.medication_family(mid uuid)
returns uuid
language sql stable security definer
set search_path = ''
as $$
  select p.family_id
  from public.medications m
  join public.patients p on p.id = m.patient_id
  where m.id = mid;
$$;

create or replace function private.schedule_patient(sid uuid)
returns uuid
language sql stable security definer
set search_path = ''
as $$
  select m.patient_id
  from public.schedules s
  join public.medications m on m.id = s.medication_id
  where s.id = sid;
$$;

create or replace function private.try_uuid(txt text)
returns uuid
language plpgsql immutable
set search_path = ''
as $$
begin
  return txt::uuid;
exception when others then
  return null;
end;
$$;

revoke all on all functions in schema private from public, anon;
grant execute on function
  private.is_family_member(uuid),
  private.is_family_owner(uuid),
  private.patient_family(uuid),
  private.medication_family(uuid),
  private.schedule_patient(uuid),
  private.try_uuid(text)
to authenticated, service_role;

alter table public.families       enable row level security;
alter table public.family_members enable row level security;
alter table public.family_invites enable row level security;
alter table public.patients       enable row level security;
alter table public.medications    enable row level security;
alter table public.schedules      enable row level security;
alter table public.dose_logs      enable row level security;
alter table public.device_tokens  enable row level security;
alter table private.push_log      enable row level security;

create policy "families: anggota bisa melihat"
  on public.families for select to authenticated
  using ((select private.is_family_member(id)));

create policy "families: owner bisa mengubah"
  on public.families for update to authenticated
  using ((select private.is_family_owner(id)))
  with check ((select private.is_family_owner(id)));

create policy "families: owner bisa menghapus"
  on public.families for delete to authenticated
  using ((select private.is_family_owner(id)));

create policy "family_members: anggota bisa melihat sesama anggota"
  on public.family_members for select to authenticated
  using ((select private.is_family_member(family_id)));

create policy "family_members: ubah profil sendiri"
  on public.family_members for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy "family_invites: owner bisa melihat"
  on public.family_invites for select to authenticated
  using ((select private.is_family_owner(family_id)));

create policy "patients: anggota bisa melihat"
  on public.patients for select to authenticated
  using ((select private.is_family_member(family_id)));

create policy "patients: anggota bisa menambah"
  on public.patients for insert to authenticated
  with check ((select private.is_family_member(family_id)));

create policy "patients: anggota bisa mengubah"
  on public.patients for update to authenticated
  using ((select private.is_family_member(family_id)))
  with check ((select private.is_family_member(family_id)));

create policy "patients: anggota bisa menghapus"
  on public.patients for delete to authenticated
  using ((select private.is_family_member(family_id)));

create policy "medications: anggota bisa melihat"
  on public.medications for select to authenticated
  using ((select private.is_family_member(private.patient_family(patient_id))));

create policy "medications: anggota bisa menambah"
  on public.medications for insert to authenticated
  with check ((select private.is_family_member(private.patient_family(patient_id))));

create policy "medications: anggota bisa mengubah"
  on public.medications for update to authenticated
  using ((select private.is_family_member(private.patient_family(patient_id))))
  with check ((select private.is_family_member(private.patient_family(patient_id))));

create policy "medications: anggota bisa menghapus"
  on public.medications for delete to authenticated
  using ((select private.is_family_member(private.patient_family(patient_id))));

create policy "schedules: anggota bisa melihat"
  on public.schedules for select to authenticated
  using ((select private.is_family_member(private.medication_family(medication_id))));

create policy "schedules: anggota bisa menambah"
  on public.schedules for insert to authenticated
  with check ((select private.is_family_member(private.medication_family(medication_id))));

create policy "schedules: anggota bisa mengubah"
  on public.schedules for update to authenticated
  using ((select private.is_family_member(private.medication_family(medication_id))))
  with check ((select private.is_family_member(private.medication_family(medication_id))));

create policy "schedules: anggota bisa menghapus"
  on public.schedules for delete to authenticated
  using ((select private.is_family_member(private.medication_family(medication_id))));

create policy "dose_logs: anggota bisa melihat"
  on public.dose_logs for select to authenticated
  using ((select private.is_family_member(private.patient_family(patient_id))));

create policy "dose_logs: anggota bisa mencatat dosis"
  on public.dose_logs for insert to authenticated
  with check (
    source = 'device'
    and status in ('taken','skipped')
    and (confirmed_by is null or confirmed_by = (select auth.uid()))
    and private.schedule_patient(schedule_id) = patient_id
    and (select private.is_family_member(private.patient_family(patient_id)))
  );

create policy "device_tokens: milik sendiri (select)"
  on public.device_tokens for select to authenticated
  using (user_id = (select auth.uid()));

create policy "device_tokens: milik sendiri (insert)"
  on public.device_tokens for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy "device_tokens: milik sendiri (update)"
  on public.device_tokens for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy "device_tokens: milik sendiri (delete)"
  on public.device_tokens for delete to authenticated
  using (user_id = (select auth.uid()));
