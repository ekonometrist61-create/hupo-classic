-- =====================================================================
-- Hane kaynağı: kayıt anında oturum UTM'inin ilk temas olarak yazılması
--   Karar: docs/hupo-design-growth/decisions.md "Kanal ölçümü (2026-10-29)" önerisi.
--   * growth_households.utm_content eklenir (utm_source/medium/campaign zaten var).
--   * hane_ilk_temas_yaz(p_utm): oturum açmış velinin KENDİ hane kartına ilk temas UTM'ini yazar.
--       - Beyaz liste: utm_source, utm_medium, utm_campaign, utm_content.
--       - Değer deseni [A-Za-z0-9._~-]{1,100}; e-posta, boşluk, URL, serbest metin reddedilir (atlanır).
--       - Yalnızca BOŞ alanlara yazar (ilk temas ezilmez); first_touch_at'a dokunmaz.
--       - Çağıran yalnız kendi kartını etkiler (core_parent_user_id = auth.uid()).
--       - Rıza kapısı istemcidedir (AnalyticsProvider yalnız "Kabul et" sonrası UTM üretir);
--         sunucu rızayı doğrulayamaz, bu yüzden istemci rıza yokken bu RPC'yi çağırmamalıdır.
--       - Kart henüz yoksa (kayıt tetikleyicisi gecikmiş) false döner; istemci bir kez yeniden dener.
--   Not: anonim ziyaretçi olayları (growth_web_olay_kaydet) kapsam dışıdır; ölçüm PostHog'dadır.
-- =====================================================================

set client_encoding = 'UTF8';

alter table public.growth_households
  add column if not exists utm_content text;

create or replace function public.hane_ilk_temas_yaz(p_utm jsonb)
returns boolean
language plpgsql
security definer
set search_path = ''
as $f$
declare
  v_uid  uuid := auth.uid();
  v_hane uuid;
  v_src  text;
  v_med  text;
  v_cmp  text;
  v_cnt  text;
  re     constant text := '^[A-Za-z0-9._~-]{1,100}$';
begin
  if v_uid is null then
    raise exception 'Oturum gerekli' using errcode = '42501';
  end if;
  if p_utm is null or jsonb_typeof(p_utm) <> 'object' then
    return false;
  end if;

  -- Değer metin değilse (sayı, nesne, dizi) atlanır.
  v_src := case when jsonb_typeof(p_utm -> 'utm_source')   = 'string' then btrim(p_utm ->> 'utm_source')   end;
  v_med := case when jsonb_typeof(p_utm -> 'utm_medium')   = 'string' then btrim(p_utm ->> 'utm_medium')   end;
  v_cmp := case when jsonb_typeof(p_utm -> 'utm_campaign') = 'string' then btrim(p_utm ->> 'utm_campaign') end;
  v_cnt := case when jsonb_typeof(p_utm -> 'utm_content')  = 'string' then btrim(p_utm ->> 'utm_content')  end;

  v_src := case when v_src ~ re then v_src end;
  v_med := case when v_med ~ re then v_med end;
  v_cmp := case when v_cmp ~ re then v_cmp end;
  v_cnt := case when v_cnt ~ re then v_cnt end;

  if v_src is null and v_med is null and v_cmp is null and v_cnt is null then
    return false;
  end if;

  select h.id into v_hane
    from public.growth_households h
   where h.core_parent_user_id = v_uid
   limit 1;
  if v_hane is null then
    return false;
  end if;

  update public.growth_households h set
    utm_source   = coalesce(h.utm_source,   v_src),
    utm_medium   = coalesce(h.utm_medium,   v_med),
    utm_campaign = coalesce(h.utm_campaign, v_cmp),
    utm_content  = coalesce(h.utm_content,  v_cnt)
   where h.id = v_hane;

  return true;
end;
$f$;

revoke execute on function public.hane_ilk_temas_yaz(jsonb) from public, anon;
grant  execute on function public.hane_ilk_temas_yaz(jsonb) to authenticated;
