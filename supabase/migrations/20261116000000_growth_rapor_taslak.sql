set client_encoding = 'UTF8';

-- =====================================================================
--  Growth haftalık rapor taslağı ve insan onayı (H-GIE Faz 2, dilim 1)
--  Ön koşul: 20261114000000_growth_kohort_cac.sql     (admin_growth_kohort, admin_growth_cac)
--            20261115000000_growth_veri_kalitesi.sql  (admin_growth_veri_kalitesi)
--            20260920000900_admin_role_and_payments.sql (log_admin_action)
--
--  BU DOSYA GÖNDERİM YAPMAZ. Rapor yalnızca taslak olarak kaydedilir.
--  Dağıtım (e-posta, iç bildirim) ayrı bir adımdır ve yalnızca onaylı rapor
--  için, ayrı bir onayla açılır. Bu tabloda gönderim durumu yoktur.
--
--  KARARLAR
--    * Dönem anahtarı (ISO hafta, Europe/Istanbul): aynı hafta için tek taslak.
--      Tekrar çağrı yeni satır açmaz; mevcut kaydı döndürür (idempotent).
--    * Taslak yalnızca bir kez karara bağlanır: onayla veya reddet. Karar geri alınmaz.
--    * İçerik, mevcut yönetici RPC'lerinin gizlilik eşiğinden geçmiş çıktısıdır;
--      ham kişi verisi içermez.
--    * LLM yok. Metin üretilmez; yalnız sayılar.
--
--  GÜVENLİK
--    * Tüm public fonksiyonlar SECURITY DEFINER + set search_path = '' ve İLK ifadesi require_admin().
--    * Tablo RLS açık, politikasız; anon ve authenticated doğrudan erişemez.
-- =====================================================================

create table if not exists public.growth_rapor_taslagi (
  id              uuid primary key default gen_random_uuid(),
  donem_anahtari  text not null unique,
  tip             text not null default 'haftalik' check (tip in ('haftalik')),
  durum           text not null default 'taslak' check (durum in ('taslak', 'onaylandi', 'reddedildi')),
  icerik          jsonb not null,
  olusturan       uuid,
  olusturma       timestamptz not null default now(),
  karar_veren     uuid,
  karar_zamani    timestamptz,
  karar_notu      text check (char_length(karar_notu) <= 300),
  constraint growth_rapor_karar_tutarli check (
    (durum = 'taslak' and karar_zamani is null) or (durum <> 'taslak' and karar_zamani is not null)
  )
);

alter table public.growth_rapor_taslagi enable row level security;
revoke all on public.growth_rapor_taslagi from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 1. Taslak üret (ISO hafta başına bir kez)
-- ---------------------------------------------------------------------
create or replace function public.admin_rapor_taslak_olustur()
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_donem text := 'haftalik-' || to_char(now() at time zone 'Europe/Istanbul', 'IYYY-"W"IW');
  v_id uuid;
  v_icerik jsonb;
begin
  perform public.require_admin();

  select r.id into v_id from public.growth_rapor_taslagi r where r.donem_anahtari = v_donem;
  if v_id is not null then
    return v_id;
  end if;

  v_icerik := jsonb_build_object(
    'kohort', public.admin_growth_kohort(30),
    'cac', public.admin_growth_cac(30),
    'veri_kalitesi', public.admin_growth_veri_kalitesi(),
    'uretildi', now()
  );

  insert into public.growth_rapor_taslagi (donem_anahtari, icerik, olusturan)
  values (v_donem, v_icerik, auth.uid())
  on conflict (donem_anahtari) do nothing
  returning id into v_id;

  -- Eşzamanlı çağrıda ikinci insert boş döner; mevcut kaydı al.
  if v_id is null then
    select r.id into v_id from public.growth_rapor_taslagi r where r.donem_anahtari = v_donem;
  end if;

  perform public.log_admin_action('rapor_taslak_olustur', jsonb_build_object('id', v_id, 'donem', v_donem));
  return v_id;
end;
$function$;

-- ---------------------------------------------------------------------
-- 2. Karar: onayla veya reddet (yalnız taslaktan; bir kez)
-- ---------------------------------------------------------------------
create or replace function public.admin_rapor_karar(p_id uuid, p_karar text, p_not text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_durum text;
  v_yeni text;
begin
  perform public.require_admin();

  if p_karar not in ('onayla', 'reddet') then
    raise exception 'Karar geçersiz: onayla veya reddet' using errcode = '22023';
  end if;
  v_yeni := case when p_karar = 'onayla' then 'onaylandi' else 'reddedildi' end;

  select r.durum into v_durum from public.growth_rapor_taslagi r where r.id = p_id for update;
  if v_durum is null then
    raise exception 'Rapor bulunamadı' using errcode = 'P0002';
  end if;
  if v_durum <> 'taslak' then
    raise exception 'Rapor zaten karara bağlanmış (%)', v_durum using errcode = '22023';
  end if;

  update public.growth_rapor_taslagi
     set durum = v_yeni,
         karar_veren = auth.uid(),
         karar_zamani = now(),
         karar_notu = nullif(btrim(coalesce(p_not, '')), '')
   where id = p_id;

  perform public.log_admin_action('rapor_karar', jsonb_build_object('id', p_id, 'karar', v_yeni));
end;
$function$;

-- ---------------------------------------------------------------------
-- 3. Listele (en yeni önce)
-- ---------------------------------------------------------------------
create or replace function public.admin_rapor_listele(p_limit int default 20)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_limit int := least(greatest(coalesce(p_limit, 20), 1), 100);
begin
  perform public.require_admin();

  return coalesce((
    select jsonb_agg(jsonb_build_object(
             'id', r.id, 'donem', r.donem_anahtari, 'durum', r.durum,
             'olusturma', r.olusturma, 'karar_zamani', r.karar_zamani,
             'karar_notu', r.karar_notu, 'icerik', r.icerik)
           order by r.olusturma desc)
      from (select * from public.growth_rapor_taslagi order by olusturma desc limit v_limit) r
  ), '[]'::jsonb);
end;
$function$;

revoke execute on function public.admin_rapor_taslak_olustur()             from public, anon;
revoke execute on function public.admin_rapor_karar(uuid, text, text)      from public, anon;
revoke execute on function public.admin_rapor_listele(int)                 from public, anon;
grant  execute on function public.admin_rapor_taslak_olustur()             to authenticated, service_role;
grant  execute on function public.admin_rapor_karar(uuid, text, text)      to authenticated, service_role;
grant  execute on function public.admin_rapor_listele(int)                 to authenticated, service_role;
