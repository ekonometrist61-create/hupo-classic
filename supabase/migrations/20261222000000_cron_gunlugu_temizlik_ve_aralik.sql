-- =====================================================================
--  pg_cron günlüğü temizliği ve dakikalık işlerin seyreltilmesi
--  Tarih : 2026-11-13
--  Neden : Disk IO bütçesi tükeniyordu (Supabase uyarısı). cron.job_run_details hiç
--          temizlenmediği için 10 Ekim'den beri 146 bin satır birikmişti; dakikalık
--          3 iş günde ~4300 yeni satır yazıyordu.
--
--  NE YAPIYOR?
--    1. duyuru-inbox-yayinla ve kampanya-push-gonder: her dakika yerine 5 dakikada bir.
--       Yönetici tarafından planlanan duyuru/kampanya dağıtımıdır; 5 dk gecikme kabul edildi.
--       deneme-sure-dolanlari-kapat dakikalık KALIR (sınav bitişini geciktirmesin).
--    2. cron-gunlugu-temizle: her gün 03:20'de 7 günden eski çalışma kayıtlarını siler.
--  Eski kayıtların yerel yedeği: scripts/cron-gunluk/arsivle.ps1 (git dışı, C:\Dev\hupo-yedek).
--  Geri alma: cron.alter_job ile iki işi '* * * * *' yap; cron-gunlugu-temizle'yi cron.unschedule et.
-- =====================================================================

do $$
declare
  v_ad text;
begin
  foreach v_ad in array array['duyuru-inbox-yayinla', 'kampanya-push-gonder'] loop
    if exists (select 1 from cron.job where jobname = v_ad) then
      perform cron.alter_job(
        job_id   => (select jobid from cron.job where jobname = v_ad),
        schedule => '*/5 * * * *'
      );
    end if;
  end loop;

  if not exists (select 1 from cron.job where jobname = 'cron-gunlugu-temizle') then
    perform cron.schedule(
      'cron-gunlugu-temizle',
      '20 3 * * *',
      $c$delete from cron.job_run_details where start_time < now() - interval '7 days'$c$
    );
  end if;
end
$$;
