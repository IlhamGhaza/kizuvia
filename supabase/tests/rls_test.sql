-- RLS / RPC tests (pgTAP). docs/09-TESTING.md §3.
--
-- No local Supabase/Docker: run this whole file against the cloud DEV project
-- (MCP `execute_sql`, or psql with the dev DB URL). It creates fake users and
-- data, and ends with a DO block that RAISES an exception carrying the TAP
-- report, so everything is rolled back and nothing is left behind.
-- Read the report from the error message: every line must start with "ok".

create temp table t (line text);
grant all on t to public;
create temp table v (k text primary key, val text);
grant all on v to public;

select no_plan();

create function pg_temp.as_user(uid uuid) returns void language plpgsql as $$
begin
  reset role;
  perform set_config('request.jwt.claims',
    json_build_object('sub', uid, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
end $$;

create function pg_temp.as_anon() returns void language plpgsql as $$
begin
  reset role;
  perform set_config('request.jwt.claims', '{"role":"anon"}', true);
  perform set_config('role', 'anon', true);
end $$;

create function pg_temp.as_service() returns void language plpgsql as $$
begin
  reset role;
  perform set_config('request.jwt.claims', '{"role":"service_role"}', true);
  perform set_config('role', 'service_role', true);
end $$;

-- Rows affected by a DML statement (data-modifying CTEs are not allowed in subselects).
create function pg_temp.affected(sql text) returns int language plpgsql as $$
declare n int;
begin
  execute sql;
  get diagnostics n = row_count;
  return n;
end $$;

create function pg_temp.as_admin() returns void language plpgsql as $$
begin
  reset role;
end $$;


-- ---------------------------------------------------------------- users
select pg_temp.as_admin();
insert into auth.users (id, email, aud, role) values
  ('a0000000-0000-0000-0000-00000000000a', 'a@test.local', 'authenticated', 'authenticated'),
  ('b0000000-0000-0000-0000-00000000000b', 'b@test.local', 'authenticated', 'authenticated'),
  ('c0000000-0000-0000-0000-00000000000c', 'c@test.local', 'authenticated', 'authenticated');

-- ------------------------------------------------- A: family, patient, med
select pg_temp.as_user('a0000000-0000-0000-0000-00000000000a');
insert into v select 'famA', public.create_family('Keluarga A', 'Ayah');

insert into t select lives_ok(format(
  $q$insert into public.patients (id, family_id, name)
     values ('11111111-1111-1111-1111-111111111111', %L, 'Budi')$q$,
  (select val from v where k = 'famA')), 'A: tambah pasien');

insert into t select lives_ok($q$
  insert into public.medications (id, patient_id, name, start_date, stock_qty)
  values ('22222222-2222-2222-2222-222222222222',
          '11111111-1111-1111-1111-111111111111', 'Amlodipine', '2026-01-01', 10)$q$,
  'A: tambah obat');

insert into t select lives_ok($q$
  insert into public.schedules (id, medication_id, times)
  values ('33333333-3333-3333-3333-333333333333',
          '22222222-2222-2222-2222-222222222222', '{07:00,13:00,19:00}')$q$,
  'A: tambah jadwal');

insert into v select 'codeCg', public.create_invite((select val::uuid from v where k = 'famA'), 'caregiver');
insert into t select is(length((select val from v where k = 'codeCg')), 6, 'A: kode undangan 6 karakter');

insert into t select is((select count(*)::int from public.patients), 1, 'A: melihat pasien sendiri');

-- ----------------------------------------------- B: other family, isolation
select pg_temp.as_user('b0000000-0000-0000-0000-00000000000b');
insert into v select 'famB', public.create_family('Keluarga B', 'Budi B');

insert into t select is((select count(*)::int from public.patients), 0, 'B: tidak melihat pasien keluarga A');
insert into t select is((select count(*)::int from public.medications), 0, 'B: tidak melihat obat keluarga A');
insert into t select is((select count(*)::int from public.schedules), 0, 'B: tidak melihat jadwal keluarga A');
insert into t select is((select count(*)::int from public.dose_logs), 0, 'B: tidak melihat log dosis keluarga A');
insert into t select is((select count(*)::int from public.families), 1, 'B: hanya melihat keluarga sendiri');
insert into t select is((select count(*)::int from public.family_members), 1, 'B: hanya melihat anggota keluarga sendiri');
insert into t select is((select count(*)::int from public.my_families()), 1, 'B: my_families hanya milik sendiri');
insert into t select is((select count(*)::int from public.family_invites), 0, 'B: tidak melihat undangan A');

insert into t select throws_ok(format(
  $q$insert into public.patients (family_id, name) values (%L, 'Penyusup')$q$,
  (select val from v where k = 'famA')), '42501', null, 'B: tidak bisa insert pasien ke keluarga A');

insert into t select is(pg_temp.affected($q$update public.patients set name = 'Diubah' where id = '11111111-1111-1111-1111-111111111111'$q$), 0, 'B: tidak bisa mengubah pasien keluarga A');

insert into t select is(pg_temp.affected($q$delete from public.medications where id = '22222222-2222-2222-2222-222222222222'$q$), 0, 'B: tidak bisa menghapus obat keluarga A');

insert into t select throws_ok(format(
  $q$select public.create_invite(%L::uuid, 'caregiver')$q$,
  (select val from v where k = 'famA')), '42501', null, 'B: bukan owner A, tidak bisa membuat undangan');

insert into t select throws_ok($q$select public.accept_invite('ZZZZZZ')$q$,
  'P0002', null, 'B: kode undangan palsu ditolak');

insert into t select throws_ok(
  $q$select * from public.expand_occurrences(now(), now() + interval '1 day')$q$,
  '42501', null, 'B: expand_occurrences hanya untuk service_role');
insert into t select throws_ok($q$select * from public.find_missed_doses()$q$,
  '42501', null, 'B: find_missed_doses hanya untuk service_role');

-- ------------------------------------------------- C: caregiver of family A
select pg_temp.as_user('c0000000-0000-0000-0000-00000000000c');
insert into t select lives_ok(format($q$select public.accept_invite(%L, 'Ibu')$q$,
  (select val from v where k = 'codeCg')), 'C: accept_invite berhasil');
insert into t select throws_ok(format($q$select public.accept_invite(%L)$q$,
  (select val from v where k = 'codeCg')), 'P0002', null, 'C: kode sekali pakai (sudah terpakai)');
insert into t select is((select count(*)::int from public.patients), 1, 'C: caregiver melihat pasien');
insert into t select is((select count(*)::int from public.family_members), 2, 'C: melihat 2 anggota');

insert into t select lives_ok($q$
  insert into public.dose_logs (schedule_id, patient_id, scheduled_at, status, confirmed_by)
  values ('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111',
          '2026-03-02 00:00:00+00', 'taken', 'c0000000-0000-0000-0000-00000000000c')$q$,
  'C: caregiver bisa mencatat dosis atas nama pasien');

insert into t select throws_ok($q$
  insert into public.dose_logs (schedule_id, patient_id, scheduled_at, status)
  values ('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111',
          '2026-03-02 00:00:00+00', 'taken')$q$, '23505', null, 'C: log duplikat ditolak (unique)');

insert into t select throws_ok($q$
  insert into public.dose_logs (schedule_id, patient_id, scheduled_at, status)
  values ('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111',
          '2026-03-02 06:00:00+00', 'missed')$q$, '42501', null, 'C: klien tidak bisa menulis status missed');

insert into t select throws_ok($q$
  insert into public.dose_logs (schedule_id, patient_id, scheduled_at, status, source)
  values ('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111',
          '2026-03-02 06:00:00+00', 'taken', 'server')$q$, '42501', null, 'C: klien tidak bisa memalsukan source=server');

insert into t select throws_ok($q$
  insert into public.dose_logs (schedule_id, patient_id, scheduled_at, status, confirmed_by)
  values ('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111',
          '2026-03-02 06:00:00+00', 'taken', 'b0000000-0000-0000-0000-00000000000b')$q$,
  '42501', null, 'C: tidak bisa memalsukan confirmed_by');

insert into t select throws_ok($q$
  update public.dose_logs set status = 'skipped'$q$, '42501', null, 'C: dose_logs tidak bisa di-update (append-only)');
insert into t select throws_ok($q$delete from public.dose_logs$q$, '42501', null,
  'C: dose_logs tidak bisa dihapus (append-only)');

insert into t select throws_ok(format(
  $q$select public.create_invite(%L::uuid, 'caregiver')$q$,
  (select val from v where k = 'famA')), '42501', null, 'C: non-owner tidak bisa membuat undangan');
insert into t select throws_ok(format(
  $q$select public.set_member_role(%L::uuid, 'a0000000-0000-0000-0000-00000000000a', 'patient')$q$,
  (select val from v where k = 'famA')), '42501', null, 'C: non-owner tidak bisa mengubah peran');
insert into t select throws_ok(format(
  $q$select public.remove_member(%L::uuid, 'a0000000-0000-0000-0000-00000000000a')$q$,
  (select val from v where k = 'famA')), '42501', null, 'C: non-owner tidak bisa mengeluarkan owner');

insert into t select is(pg_temp.affected($q$update public.families set name = 'Dibajak'$q$), 0, 'C: non-owner tidak bisa mengubah keluarga');

insert into t select lives_ok($q$
  update public.patients set notes = 'catatan caregiver'
  where id = '11111111-1111-1111-1111-111111111111'$q$, 'C: caregiver boleh mengubah data pasien');

insert into t select lives_ok($q$
  insert into public.device_tokens (token, user_id, platform)
  values ('token-c', 'c0000000-0000-0000-0000-00000000000c', 'android')$q$, 'C: simpan token sendiri');
insert into t select throws_ok($q$
  insert into public.device_tokens (token, user_id, platform)
  values ('token-spoof', 'a0000000-0000-0000-0000-00000000000a', 'android')$q$,
  '42501', null, 'C: tidak bisa menyimpan token atas nama user lain');

-- ------------------------------------------------- A: owner rules
select pg_temp.as_user('a0000000-0000-0000-0000-00000000000a');
insert into t select lives_ok($q$
  insert into public.device_tokens (token, user_id, platform)
  values ('token-a', 'a0000000-0000-0000-0000-00000000000a', 'android')$q$, 'A: simpan token sendiri');
insert into t select is((select count(*)::int from public.device_tokens), 1, 'A: hanya melihat token sendiri');

insert into t select throws_ok(format(
  $q$select public.remove_member(%L::uuid, 'a0000000-0000-0000-0000-00000000000a')$q$,
  (select val from v where k = 'famA')), '23514', null, 'A: owner terakhir tidak boleh keluar');
insert into t select throws_ok(format(
  $q$select public.set_member_role(%L::uuid, 'a0000000-0000-0000-0000-00000000000a', 'caregiver')$q$,
  (select val from v where k = 'famA')), '23514', null, 'A: owner terakhir tidak boleh diturunkan');

insert into t select lives_ok(format(
  $q$select public.set_member_role(%L::uuid, 'c0000000-0000-0000-0000-00000000000c', 'owner')$q$,
  (select val from v where k = 'famA')), 'A: promosikan C menjadi owner');
insert into t select lives_ok(format(
  $q$select public.remove_member(%L::uuid, 'a0000000-0000-0000-0000-00000000000a')$q$,
  (select val from v where k = 'famA')), 'A: keluar setelah ada owner lain');
insert into t select is((select count(*)::int from public.patients), 0, 'A: setelah keluar tidak melihat data keluarga lagi');

-- expired invite
select pg_temp.as_user('b0000000-0000-0000-0000-00000000000b');
insert into v select 'codeOld', public.create_invite((select val::uuid from v where k = 'famB'), 'caregiver');
select pg_temp.as_admin();
update public.family_invites set expires_at = now() - interval '1 minute'
 where code = (select val from v where k = 'codeOld');
select pg_temp.as_user('a0000000-0000-0000-0000-00000000000a');
insert into t select throws_ok(format($q$select public.accept_invite(%L)$q$,
  (select val from v where k = 'codeOld')), 'P0002', null, 'A: kode kedaluwarsa ditolak');

-- ------------------------------------------------- anon
select pg_temp.as_anon();
insert into t select throws_ok($q$select * from public.patients$q$, '42501', null, 'anon: tidak bisa membaca pasien');
insert into t select throws_ok($q$select public.create_family('x')$q$, '42501', null, 'anon: tidak bisa memanggil create_family');

-- ------------------------------------------------- service_role (Edge Functions)
select pg_temp.as_admin();
update public.medications set created_at = now() - interval '30 days'
 where id = '22222222-2222-2222-2222-222222222222';

select pg_temp.as_service();
insert into t select is((select count(*)::int from public.expand_occurrences(
    '2026-03-01 17:00:00+00', '2026-03-03 17:00:00+00')
    where medication_id = '22222222-2222-2222-2222-222222222222'),
  6, 'expand_occurrences: 3x sehari selama 48 jam = 6 (zona Asia/Jakarta)');

-- missed-dose: schedule in UTC, medication old enough
select pg_temp.as_admin();
insert into public.medications (id, patient_id, name, start_date, created_at)
values ('44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111',
        'Obat Lama', current_date - 3, now() - interval '10 days'),
       ('55555555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111',
        'Obat Baru', current_date - 3, now());
insert into public.schedules (id, medication_id, times, timezone) values
  ('66666666-6666-6666-6666-666666666666', '44444444-4444-4444-4444-444444444444', '{00:00,12:00}', 'UTC'),
  ('77777777-7777-7777-7777-777777777777', '55555555-5555-5555-5555-555555555555', '{00:00,12:00}', 'UTC');

select pg_temp.as_service();
insert into v select 'missed0',
  (select count(*) from public.find_missed_doses('3 days')
    where medication_id = '44444444-4444-4444-4444-444444444444')::text;
insert into t select ok((select val::int from v where k = 'missed0') >= 4,
  'find_missed_doses: obat lama menghasilkan dosis terlewat');
insert into t select is((select count(*)::int from public.find_missed_doses('3 days')
    where medication_id = '55555555-5555-5555-5555-555555555555'), 0,
  'find_missed_doses: dosis sebelum obat dibuat tidak dihitung');

insert into public.dose_logs (schedule_id, patient_id, scheduled_at, status, source)
select schedule_id, patient_id, scheduled_at, 'taken', 'device'
from public.find_missed_doses('3 days')
where medication_id = '44444444-4444-4444-4444-444444444444'
order by scheduled_at limit 1;
insert into t select is((select count(*)::int from public.find_missed_doses('3 days')
    where medication_id = '44444444-4444-4444-4444-444444444444'),
  (select val::int from v where k = 'missed0') - 1,
  'find_missed_doses: dosis yang sudah dikonfirmasi tidak dihitung');

insert into t select is(public.record_push('missed', 'k1', '11111111-1111-1111-1111-111111111111'), true,
  'record_push: pertama kali = true');
insert into t select is(public.record_push('missed', 'k1', '11111111-1111-1111-1111-111111111111'), false,
  'record_push: duplikat = false (tanpa push ganda)');
insert into t select is((select count(*)::int from public.push_recipients('11111111-1111-1111-1111-111111111111')), 1,
  'push_recipients: hanya anggota yang masih ada (C), bukan A yang sudah keluar');

select pg_temp.as_admin();
select finish();

-- Report + rollback. Failing lines start with "not ok".
do $$
begin
  raise exception E'TAP REPORT\n%',
    (select string_agg(line, E'\n' order by ctid) from pg_temp.t);
end $$;
