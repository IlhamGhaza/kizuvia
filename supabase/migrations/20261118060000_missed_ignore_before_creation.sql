-- A medication created at 14:00 must not make caregivers get a "missed" push for
-- today's 08:00 dose: start_date is only a date, so also require the occurrence
-- to be after the row was created on the server.
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
  join public.medications m on m.id = o.medication_id
  where o.scheduled_at + make_interval(mins => o.grace_minutes) <= now()
    and o.scheduled_at >= m.created_at
    and not exists (
      select 1 from public.dose_logs l
      where l.schedule_id = o.schedule_id and l.scheduled_at = o.scheduled_at
    );
$$;

revoke all on function public.find_missed_doses(interval) from public, anon, authenticated;
grant execute on function public.find_missed_doses(interval) to service_role;
