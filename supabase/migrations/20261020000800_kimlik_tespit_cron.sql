-- =====================================================================
-- Faz 4: admin_detect_identity_duplicates() için günlük zamanlanmış iş (pg_cron)
-- Her gün 03:30 (Europe/Istanbul = 00:30 UTC) çalışır; on conflict do nothing olduğu
-- için tekrar çalıştırma aday kaydını çoğaltmaz.
-- pg_cron kullanılamazsa migration bilerek hata verir: sessiz atlanmaz.
-- =====================================================================

create extension if not exists pg_cron with schema pg_catalog;

do $$
begin
  if not exists (select 1 from cron.job where jobname = 'kimlik-tekillestirme-tespit') then
    perform cron.schedule(
      'kimlik-tekillestirme-tespit',
      '30 0 * * *',
      'select public.admin_detect_identity_duplicates()'
    );
  end if;
end
$$;
