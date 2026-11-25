-- Fungsi event trigger bawaan (auto-enable RLS) tidak perlu bisa dipanggil lewat API
revoke execute on function public.rls_auto_enable() from public, anon, authenticated;

-- Tabel & fungsi baru di public tidak otomatis terbuka ke anon/authenticated
alter default privileges for role postgres in schema public
  revoke select, insert, update, delete on tables from anon, authenticated;
alter default privileges for role postgres in schema public
  revoke execute on functions from public, anon, authenticated;
alter default privileges for role postgres in schema public
  revoke usage, select on sequences from anon, authenticated;
