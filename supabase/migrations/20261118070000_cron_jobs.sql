-- Cron wiring for the Edge Functions (T2.7, T2.8).
--
-- Secrets live in Vault and are created OUT OF BAND (not in this file):
--   vault.create_secret('<random>',                       'cron_secret')
--   vault.create_secret('https://<ref>.supabase.co',       'project_url')
-- Edge Functions run with verify_jwt = false and check the `x-cron-secret`
-- header against get_cron_secret().

create or replace function public.get_cron_secret()
returns text
language sql stable security definer
set search_path = ''
as $$
  select decrypted_secret from vault.decrypted_secrets where name = 'cron_secret';
$$;

revoke all on function public.get_cron_secret() from public, anon, authenticated;
grant execute on function public.get_cron_secret() to service_role;

create or replace function private.call_edge(fn text)
returns void
language plpgsql security definer
set search_path = ''
as $$
declare
  v_base text;
  v_secret text;
begin
  select decrypted_secret into v_base from vault.decrypted_secrets where name = 'project_url';
  select decrypted_secret into v_secret from vault.decrypted_secrets where name = 'cron_secret';
  if v_base is null or v_secret is null then
    return; -- not configured yet
  end if;
  perform net.http_post(
    url := v_base || '/functions/v1/' || fn,
    headers := jsonb_build_object('Content-Type', 'application/json', 'x-cron-secret', v_secret),
    body := '{}'::jsonb,
    timeout_milliseconds := 20000
  );
end;
$$;

revoke all on function private.call_edge(text) from public, anon, authenticated;

select cron.schedule('missed-dose-check', '*/5 * * * *', $$select private.call_edge('missed-dose-check')$$);
-- 01:00 UTC = 08:00 WIB
select cron.schedule('low-stock-check', '0 1 * * *', $$select private.call_edge('low-stock-check')$$);
