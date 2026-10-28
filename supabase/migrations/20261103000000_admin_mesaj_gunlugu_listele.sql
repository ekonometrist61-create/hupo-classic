set client_encoding = 'UTF8';

-- =====================================================================
--  Growth CRM: yönetim "Gönderim Günlüğü" listesi (salt okunur)
--  Tarih : 2026-10-27  (Plan: ILETISIM_EKSIKLERI_PLANI_2026-10-27 · P6 / E6)
--  Ön koşul: 20260920000900_admin_role_and_payments.sql  (require_admin)
--            20261014000000_growth_crm_core.sql           (growth_message_log,
--                                                          growth_households,
--                                                          growth_campaigns,
--                                                          growth_journeys)
--
--  NE EKLİYOR?
--    admin_mesaj_gunlugu_listele(p_kanal, p_durum, p_kampanya_id, p_limit, p_offset)
--
--  GİZLİLİK
--    * Hane için yalnızca hane_id, maskeli e-posta ve maskeli telefon döner.
--      Ham e-posta, telefon, veli adı ve çocuk adı (growth_students.nickname)
--      yanıta GİRMEZ.
--    * error serbest metindir (sağlayıcı yanıtı). Yanıtta e-posta ve telefon
--      desenleri [e-posta] / [telefon] ile değiştirilir.
--    * consent_snapshot ham olarak dönmez; yalnızca izin_verildi özeti döner
--      (true / false / null). null: anlık görüntü yok ya da biçimi tanınmıyor.
--      NOT: consent_snapshot biçimi şemada tanımlı değil. Aşağıdaki çıkarım üç
--      biçimi tanır: {"granted": bool}, {"<kanal>": bool} ve
--      {"<kanal>": {"granted": bool}}. Gönderim yazıcısının (P3) biçimi
--      kesinleşince bu çıkarım gözden geçirilmelidir.
--    * Salt okuma: log_admin_action yazılmaz (diğer liste RPC'leri gibi).
--
--  GÜVENLİK
--    * Fonksiyon SECURITY DEFINER + set search_path = '' ve İLK ifadesi
--      public.require_admin(). Tüm referanslar şema-nitelikli.
--    * growth_* tabloları RLS açık ve policy'sizdir; istemci doğrudan okuyamaz.
--
--  Liste yanıtı: { rows: [...], total: n }. limit en fazla 100, offset >= 0.
--  Sıralama: gönderim zamanı (sent_at, yoksa created_at) azalan.
-- =====================================================================

create or replace function public.admin_mesaj_gunlugu_listele(
  p_kanal        text default null,
  p_durum        text default null,
  p_kampanya_id  uuid default null,
  p_limit        int  default 50,
  p_offset       int  default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_limit    int  := least(greatest(coalesce(p_limit, 50), 1), 100);
  v_offset   int  := greatest(coalesce(p_offset, 0), 0);
  v_kanal    text := nullif(btrim(coalesce(p_kanal, '')), '');
  v_durum    text := nullif(btrim(coalesce(p_durum, '')), '');
  v_toplam   int;
  v_satirlar jsonb;
begin
  perform public.require_admin();

  select count(*)::int into v_toplam
    from public.growth_message_log m
   where (v_kanal is null or m.channel = v_kanal)
     and (v_durum is null or m.status = v_durum)
     and (p_kampanya_id is null or m.campaign_id = p_kampanya_id);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.zaman desc, x.id), '[]'::jsonb)
    into v_satirlar
    from (
      select m.id,
             coalesce(m.sent_at, m.created_at) as zaman,
             m.created_at,
             m.sent_at,
             m.channel,
             m.status,
             -- Sağlayıcı hata metni serbest metindir; içindeki e-posta ve telefon
             -- desenleri yanıta girmeden maskelenir (KVKK: ham kişisel veri yok).
             regexp_replace(
               regexp_replace(m.error,
                 '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', '[e-posta]', 'g'),
               '\+?[0-9][0-9 ()-]{8,}[0-9]', '[telefon]', 'g') as error,
             m.campaign_id,
             c.name as kampanya_adi,
             m.journey_id,
             j.name as journey_adi,
             m.household_id as hane_id,
             case
               when h.email is null or position('@' in h.email) = 0 then null
               else left(split_part(h.email, '@', 1), 1) || '***@' || split_part(h.email, '@', 2)
             end as hane_eposta_maskeli,
             case
               when length(regexp_replace(coalesce(h.phone, ''), '\D', '', 'g')) < 4 then null
               else '******' || right(regexp_replace(h.phone, '\D', '', 'g'), 2)
             end as hane_telefon_maskeli,
             case
               when jsonb_typeof(m.consent_snapshot) <> 'object' then null
               when m.consent_snapshot ? 'granted'
                 then (m.consent_snapshot ->> 'granted') = 'true'
               when m.consent_snapshot ? m.channel
                 then (jsonb_typeof(m.consent_snapshot -> m.channel) = 'boolean'
                        and (m.consent_snapshot ->> m.channel) = 'true')
                   or (jsonb_typeof(m.consent_snapshot -> m.channel) = 'object'
                        and (m.consent_snapshot -> m.channel ->> 'granted') = 'true')
               else null
             end as izin_verildi
        from public.growth_message_log m
        left join public.growth_households h on h.id = m.household_id
        left join public.growth_campaigns  c on c.id = m.campaign_id
        left join public.growth_journeys   j on j.id = m.journey_id
       where (v_kanal is null or m.channel = v_kanal)
         and (v_durum is null or m.status = v_durum)
         and (p_kampanya_id is null or m.campaign_id = p_kampanya_id)
       order by coalesce(m.sent_at, m.created_at) desc, m.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('rows', v_satirlar, 'total', v_toplam);
end;
$function$;

-- ---------------------------------------------------------------------
-- REVOKE / GRANT
-- ---------------------------------------------------------------------
revoke execute on function public.admin_mesaj_gunlugu_listele(text, text, uuid, int, int) from public, anon;
grant  execute on function public.admin_mesaj_gunlugu_listele(text, text, uuid, int, int) to authenticated;
