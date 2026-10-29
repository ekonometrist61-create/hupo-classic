-- =====================================================================
-- Growth saklama süreleri ve günlük temizlik (W8b)
--
--   HUKUK ONAYI BEKLİYOR: aşağıdaki süreler taslaktır. Onay gelene kadar
--   bu dosya yalnızca bu sabitlerle çalışır; süre değişirse hem buradaki
--   değer hem de docs/growth-crm/OLAY_TAKSONOMISI.md güncellenir.
--
--   Süreler (gün):
--     SAKLAMA_WEB_GUN              = 400  growth_events, source='web' (ziyaretçi olayları)
--     SAKLAMA_ANONIM_GUN           = 180  growth_events, source='web', hane bağı yok ve
--                                         growth_identity_links'te kaydı yok
--     SAKLAMA_KULLANIM_GUN         = 400  kullanim_olaylari (ekran süresi)
--   Anında silinenler:
--     hane silinmiş / anonimleştirilmiş growth_events satırları
--     (household_id NULL ve source hane-bağlı bir kaynak: crm, payment,
--      support, automation, server). 'app' ve 'web' bilerek dışarıda; bkz. yorum.
--
--   ÇELİŞKİ (karar bekliyor): 20261066 kullanim_olaylari_temizle() kullanım
--   verisini 300 gün sonra siler ve 20261070 ile 03:15'te zamanlanır. Bu dosya
--   400 günü uygular ama 300 günlük eski temizlik önce çalıştığı için pratikte
--   etkisizdir. Mevcut migration değiştirilmedi. Hukuk 300 veya 400 derse
--   tek değer seçilmeli ve eski işin kaldırılması ayrıca kararlaştırılmalı.
--
--   Kapsam dışı: anonimleştirme/silme işlemi (KVKK silme, W4). Bu dosya yalnızca
--   süresi dolan veya hane bağı kopmuş satırları temizler.
--
--   Varsayım (W4 ile doğrulanacak): hane silme/anonimleştirme, growth_events
--   satırlarında household_id'yi NULL yapar. growth_events.household_id
--   ON DELETE CASCADE olduğundan hane tamamen silinince satırlar zaten gider.
-- =====================================================================

set client_encoding = 'UTF8';

-- Temizlik: yalnızca service_role (ve postgres sahibi) çalıştırır.
create or replace function public.growth_saklama_temizle()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $f$
declare
  -- HUKUK ONAYI BEKLİYOR: süreler
  c_web_gun       constant integer := 400;
  c_anonim_gun    constant integer := 180;
  c_kullanim_gun  constant integer := 400;

  v_web_eski      integer := 0;
  v_anonim_eski   integer := 0;
  v_hane_kopuk    integer := 0;
  v_kullanim      integer := 0;
begin
  -- 1) Ziyaretçi olayları: 400 gün (bağlı veya bağsız fark etmez)
  delete from public.growth_events e
   where e.source = 'web'
     and e.occurred_at < now() - make_interval(days => c_web_gun);
  get diagnostics v_web_eski = row_count;

  -- 2) Bağsız anonim ziyaretçi: 180 gün. Kimlik bağı (growth_identity_links) olan
  --    ziyaretçinin olayları bu kurala girmez; onlar 400 gün kuralıyla silinir.
  delete from public.growth_events e
   where e.source = 'web'
     and e.household_id is null
     and e.occurred_at < now() - make_interval(days => c_anonim_gun)
     and not exists (
       select 1 from public.growth_identity_links l
        where l.anonymous_id = e.anonymous_id
     );
  get diagnostics v_anonim_eski = row_count;

  -- 3) Hane bağı kopmuş (anonimleştirilmiş) olaylar: anında.
  --    'app' bilerek dışarıda: uygulama olayları hane girişinden önce anonim
  --    kimlikle gelebilir; bu kaynağın kuralı W3 funnel kararında yazılacak.
  delete from public.growth_events e
   where e.source in ('crm', 'payment', 'support', 'automation', 'server')
     and e.household_id is null;
  get diagnostics v_hane_kopuk = row_count;

  -- 4) Ekran süresi verisi: 400 gün (bkz. dosya başı çelişki notu)
  delete from public.kullanim_olaylari k
   where k.created_at < now() - make_interval(days => c_kullanim_gun);
  get diagnostics v_kullanim = row_count;

  return jsonb_build_object(
    'web_eski', v_web_eski,
    'anonim_eski', v_anonim_eski,
    'hane_kopuk', v_hane_kopuk,
    'kullanim_eski', v_kullanim
  );
end;
$f$;

comment on function public.growth_saklama_temizle() is
  'Growth saklama temizliği. Süreler HUKUK ONAYI BEKLİYOR. Yalnız service_role çalıştırır.';

revoke all on function public.growth_saklama_temizle() from public, anon, authenticated;
grant execute on function public.growth_saklama_temizle() to service_role;

-- Günlük zamanlayıcı: pg_cron kuruluysa her gün 03:30 UTC; değilse yalnız fonksiyon kalır.
-- Kalıp: 20261066 (kullanim_olaylari_temizle) ile aynı.
do $$
begin
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    begin
      perform cron.unschedule('growth_saklama_temizle');
    exception when others then null;
    end;
    perform cron.schedule('growth_saklama_temizle', '30 3 * * *', 'select public.growth_saklama_temizle()');
  else
    raise notice 'pg_cron yok: growth_saklama_temizle() günlük elle/harici zamanlayıcıyla çağrılmalı';
  end if;
end $$;
