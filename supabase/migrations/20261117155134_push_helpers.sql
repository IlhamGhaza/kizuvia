-- Catat push yang dikirim server; true jika baru (belum pernah dikirim), false jika duplikat.
create or replace function public.record_push(p_kind text, p_ref_key text, p_patient_id uuid)
returns boolean
language plpgsql security definer
set search_path = ''
as $$
begin
  insert into private.push_log (kind, ref_key, patient_id)
  values (p_kind, p_ref_key, p_patient_id)
  on conflict (kind, ref_key) do nothing;
  return found;
end;
$$;

-- Penerima push untuk satu pasien: anggota keluarga (kecuali pasien itu sendiri)
-- yang mengaktifkan notifikasi, beserta token perangkatnya.
create or replace function public.push_recipients(p_patient_id uuid, p_only_notify_missed boolean default true)
returns table (user_id uuid, token text)
language sql stable security definer
set search_path = ''
as $$
  select fm.user_id, dt.token
  from public.patients p
  join public.family_members fm on fm.family_id = p.family_id
  join public.device_tokens dt on dt.user_id = fm.user_id
  where p.id = p_patient_id
    and (p.user_id is null or fm.user_id <> p.user_id)
    and (not p_only_notify_missed or fm.notify_missed);
$$;

revoke all on function public.record_push(text, text, uuid), public.push_recipients(uuid, boolean)
  from public, anon, authenticated;
grant execute on function public.record_push(text, text, uuid), public.push_recipients(uuid, boolean)
  to service_role;
