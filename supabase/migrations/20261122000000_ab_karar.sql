set client_encoding = 'UTF8';

-- =====================================================================
--  A/B motoru A3: karar kaydı (H-GIE Faz 6)
--  Ön koşul: 20261121000000_ab_deney.sql (ab_deney, require_admin, log_admin_action)
--
--  KURALLAR
--    * Karar yalnız bitiş tarihi geçmiş deneyde verilir (ara bakış yasak).
--      Tek istisna: 'guardrail_ihlali'; bu, deney durdurulmuşken yazılabilir.
--    * Deney başına en fazla bir karar (unique).
--    * 'karar_hazir' için birincil sonuç zorunludur.
--    * Sayılar yönetici tarafından, toplulaştırılmış analiz çıktısından girilir.
--      Bu tablo sayıları YENİDEN HESAPLAMAZ: deney olaylarının veritabanına alınması
--      (dönüşüm verisi) ayrı bir iştir ve henüz yoktur. Kayıt, analiz kaydıdır.
--    * Karar, deneyi 'bitti' durumuna geçirir (guardrail hariç; o zaten durdurulmuştur).
-- =====================================================================

create table if not exists public.ab_karar (
  id            uuid primary key default gen_random_uuid(),
  deney_id      uuid not null unique references public.ab_deney (id) on delete cascade,
  sonuc_durum   text not null
                  check (sonuc_durum in ('srm_gecersiz', 'yetersiz_ornek', 'guardrail_ihlali', 'karar_hazir')),
  birincil      jsonb,
  guardrail     jsonb not null default '[]'::jsonb,
  srm_p         numeric check (srm_p is null or (srm_p >= 0 and srm_p <= 1)),
  neden         text not null check (char_length(btrim(neden)) between 3 and 500),
  karar         text check (karar in ('kazan_deney', 'kazan_kontrol', 'uygulama_yok', 'tekrarla')),
  karar_veren   uuid,
  karar_zaman   timestamptz not null default now(),
  constraint ab_karar_birincil_zorunlu check (sonuc_durum <> 'karar_hazir' or birincil is not null),
  constraint ab_karar_karar_hazir_sonrasi check (sonuc_durum <> 'karar_hazir' or karar is not null)
);

alter table public.ab_karar enable row level security;
revoke all on public.ab_karar from public, anon, authenticated;

create or replace function public.admin_ab_karar_kaydet(
  p_deney       uuid,
  p_sonuc_durum text,
  p_birincil    jsonb,
  p_guardrail   jsonb,
  p_srm_p       numeric,
  p_neden       text,
  p_karar       text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_durum text;
  v_bitis date;
  v_bugun date := (now() at time zone 'Europe/Istanbul')::date;
  v_id    uuid;
begin
  perform public.require_admin();

  select d.durum, d.bitis into v_durum, v_bitis from public.ab_deney d where d.id = p_deney for update;
  if v_durum is null then
    raise exception 'Deney bulunamadı' using errcode = 'P0002';
  end if;
  if exists (select 1 from public.ab_karar k where k.deney_id = p_deney) then
    raise exception 'Bu deney için karar zaten kayıtlı' using errcode = '22023';
  end if;

  if p_sonuc_durum = 'guardrail_ihlali' then
    if v_durum <> 'durduruldu' then
      raise exception 'Guardrail kararı için önce deney durdurulmalı (durum: %)', v_durum using errcode = '22023';
    end if;
  else
    if v_durum not in ('yayinda', 'durduruldu') then
      raise exception 'Karar için deney yayında olmalı (durum: %)', v_durum using errcode = '22023';
    end if;
    if v_bugun <= v_bitis then
      raise exception 'Karar bitiş tarihinden sonra verilebilir (ara bakış yasak)' using errcode = '22023';
    end if;
  end if;

  insert into public.ab_karar (deney_id, sonuc_durum, birincil, guardrail, srm_p, neden, karar, karar_veren)
  values (p_deney, p_sonuc_durum, p_birincil, coalesce(p_guardrail, '[]'::jsonb), p_srm_p, p_neden, p_karar, auth.uid())
  returning id into v_id;

  if v_durum = 'yayinda' then
    update public.ab_deney set durum = 'bitti' where id = p_deney;
  end if;

  perform public.log_admin_action('ab_karar_kaydet',
    jsonb_build_object('deney_id', p_deney, 'sonuc', p_sonuc_durum, 'karar', p_karar));
  return v_id;
end;
$function$;

create or replace function public.admin_ab_karar_getir(p_deney uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
begin
  perform public.require_admin();
  return (
    select jsonb_build_object(
      'sonuc_durum', k.sonuc_durum, 'birincil', k.birincil, 'guardrail', k.guardrail,
      'srm_p', k.srm_p, 'neden', k.neden, 'karar', k.karar, 'karar_zaman', k.karar_zaman)
      from public.ab_karar k where k.deney_id = p_deney
  );
end;
$function$;

revoke execute on function public.admin_ab_karar_kaydet(uuid, text, jsonb, jsonb, numeric, text, text) from public, anon;
revoke execute on function public.admin_ab_karar_getir(uuid) from public, anon;
grant  execute on function public.admin_ab_karar_kaydet(uuid, text, jsonb, jsonb, numeric, text, text) to authenticated, service_role;
grant  execute on function public.admin_ab_karar_getir(uuid) to authenticated, service_role;
