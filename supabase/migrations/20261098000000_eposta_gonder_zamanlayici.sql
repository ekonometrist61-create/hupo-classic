-- =====================================================================
-- eposta_outbox gönderici worker'ı için zamanlayıcı (Edge Function: eposta-gonder)
--   * pg_cron 5 dakikada bir eposta-gonder fonksiyonunu pg_net ile POST'lar.
--   * Paylaşılan gizli metin Supabase Vault'ta 'olay_worker_secret' adıyla tutulur
--     (olay-kutusu-gonder ile aynı değer; repoya yazılmaz). Fonksiyon bu değeri
--     x-webhook-secret başlığında OLAY_WORKER_SECRET ile karşılaştırır.
--   * Vault'ta secret yoksa başlık boş gider ve fonksiyon 401 döner (fail-closed).
--   * Aynı jobname varsa iş yeniden oluşturulmaz (idempotent).
-- =====================================================================

create extension if not exists pg_cron with schema pg_catalog;
create extension if not exists pg_net;

do $$
begin
  if not exists (select 1 from cron.job where jobname = 'eposta-outbox-gonder') then
    perform cron.schedule(
      'eposta-outbox-gonder',
      '*/5 * * * *',
      $job$
      select net.http_post(
        url := 'https://ccozfrpnvyrnktpffkwo.supabase.co/functions/v1/eposta-gonder',
        headers := jsonb_build_object(
          'content-type', 'application/json',
          'x-webhook-secret', coalesce(
            (select ds.decrypted_secret from vault.decrypted_secrets ds where ds.name = 'olay_worker_secret' limit 1),
            ''
          )
        ),
        body := '{}'::jsonb
      );
      $job$
    );
  end if;
end
$$;
