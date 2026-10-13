-- =====================================================================
-- V2 (web): ziyaretçi olayları ve UTM ilk temas bağlama
--   * growth_web_olay_kaydet : anonim ziyaretçi olayı (growth_events, source='web').
--                              Olay adı ve UTM alanları beyaz listeli; serbest metin / PII yok.
--   * growth_web_kimlik_bagla: formla birlikte oluşan müşteri kartına ziyaretçiyi bağlar.
--                              Yalnızca son 15 dakikada oluşan kartlara; UTM ilk temas olarak
--                              yalnızca karttaki boş alanlara yazılır.
--   Uyarı: iki RPC de anonimdir (kayıt öncesi ziyaretçi). Captcha / hız sınırı henüz yok;
--          veli_adayi_olustur ile aynı açık. Bkz. TASKS.md.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function public.growth_web_olay_kaydet(
  p_anonymous_id text,
  p_event_name   text,
  p_utm          jsonb default '{}'::jsonb
)
returns void
language plpgsql
security definer
set search_path = ''
as $f$
declare
  v_vid text := nullif(btrim(coalesce(p_anonymous_id, '')), '');
  v_utm jsonb := '{}'::jsonb;
begin
  if v_vid is null or v_vid !~ '^[A-Za-z0-9_-]{8,64}$' then
    raise exception 'Geçersiz ziyaretçi kimliği' using errcode = '22023';
  end if;

  -- Beyaz liste: yalnızca bu olay adları kaydedilir.
  if p_event_name is null or p_event_name not in ('erken_erisim_gonderildi') then
    raise exception 'Geçersiz olay adı' using errcode = '22023';
  end if;

  if p_utm is not null and jsonb_typeof(p_utm) = 'object' then
    select coalesce(jsonb_object_agg(x.k, left(x.v, 100)), '{}'::jsonb)
      into v_utm
      from (
        select e.key as k, btrim(e.value) as v
          from jsonb_each_text(p_utm) as e(key, value)
         where e.key in ('utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content')
           and e.value is not null
           and btrim(e.value) <> ''
      ) x;
  end if;

  insert into public.growth_events (anonymous_id, event_name, source, utm)
  values (v_vid, p_event_name, 'web', nullif(v_utm, '{}'::jsonb));
end;
$f$;

create or replace function public.growth_web_kimlik_bagla(
  p_anonymous_id text,
  p_eposta       text
)
returns void
language plpgsql
security definer
set search_path = ''
as $f$
declare
  v_vid   text := nullif(btrim(coalesce(p_anonymous_id, '')), '');
  v_email text := lower(btrim(coalesce(p_eposta, '')));
  v_hane  uuid;
  v_utm   jsonb;
begin
  if v_vid is null or v_vid !~ '^[A-Za-z0-9_-]{8,64}$' then
    raise exception 'Geçersiz ziyaretçi kimliği' using errcode = '22023';
  end if;
  if v_email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    return;
  end if;

  -- Yalnızca yeni oluşmuş kartlar: eski bir kartın geçmişine sonradan ziyaretçi eklenemez.
  select h.id into v_hane
    from public.growth_households h
   where lower(h.email) = v_email
     and h.created_at > now() - interval '15 minutes'
   limit 1;
  if v_hane is null then
    return;
  end if;

  insert into public.growth_identity_links (anonymous_id, household_id)
  values (v_vid, v_hane)
  on conflict (anonymous_id, household_id) do nothing;

  update public.growth_events
     set household_id = v_hane
   where anonymous_id = v_vid
     and household_id is null;

  -- İlk temas UTM'si: ziyaretçinin en eski UTM'li olayı; karttaki boş alanlara yazılır.
  select ge.utm into v_utm
    from public.growth_events ge
   where ge.anonymous_id = v_vid
     and ge.utm is not null
   order by ge.occurred_at
   limit 1;

  if v_utm is not null then
    update public.growth_households h set
      utm_source   = coalesce(h.utm_source,   v_utm ->> 'utm_source'),
      utm_medium   = coalesce(h.utm_medium,   v_utm ->> 'utm_medium'),
      utm_campaign = coalesce(h.utm_campaign, v_utm ->> 'utm_campaign')
     where h.id = v_hane;
  end if;
end;
$f$;

revoke execute on function public.growth_web_olay_kaydet(text, text, jsonb)  from public;
revoke execute on function public.growth_web_kimlik_bagla(text, text)        from public;
grant  execute on function public.growth_web_olay_kaydet(text, text, jsonb)  to anon, authenticated;
grant  execute on function public.growth_web_kimlik_bagla(text, text)        to anon, authenticated;
