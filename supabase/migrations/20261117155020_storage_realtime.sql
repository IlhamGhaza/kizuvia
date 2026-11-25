insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('medication-photos', 'medication-photos', false, 5242880,
        array['image/jpeg','image/png','image/webp'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

create policy "medication-photos: anggota keluarga bisa melihat"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'medication-photos'
    and private.is_family_member(private.try_uuid((storage.foldername(name))[1]))
  );

create policy "medication-photos: anggota keluarga bisa upload"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'medication-photos'
    and private.is_family_member(private.try_uuid((storage.foldername(name))[1]))
  );

create policy "medication-photos: anggota keluarga bisa mengganti"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'medication-photos'
    and private.is_family_member(private.try_uuid((storage.foldername(name))[1]))
  )
  with check (
    bucket_id = 'medication-photos'
    and private.is_family_member(private.try_uuid((storage.foldername(name))[1]))
  );

create policy "medication-photos: anggota keluarga bisa menghapus"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'medication-photos'
    and private.is_family_member(private.try_uuid((storage.foldername(name))[1]))
  );

alter publication supabase_realtime add table
  public.patients,
  public.medications,
  public.schedules,
  public.dose_logs,
  public.family_members;
