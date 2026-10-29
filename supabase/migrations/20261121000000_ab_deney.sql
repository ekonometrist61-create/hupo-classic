set client_encoding = 'UTF8';

-- =====================================================================
--  Gerçek A/B motoru, A1: deney tanımı ve atama (H-GIE Faz 6)
--  Spec: docs/growth-crm/specs/AB_MOTORU_SPEC.md
--  Ön koşul: 20260920000900_admin_role_and_payments.sql (require_admin, log_admin_action)
--
--  KURALLAR
--    * Deney yalnız tüm zorunlu alanlar dolu ve onay notu varken 'yayinda' olur (check).
--    * Deney kaydı başlamadan kayıtlıdır; sonradan değişmez (yalnız durdurulabilir).
--    * Atama deterministiktir: kol = hash(deney_id, kullanici_id) biti. Atama tablosu yoktur;
--      kullanıcı kimliği hiçbir yerde toplanmaz.
--    * Atama yalnız deney 'yayinda' ve tarih aralığındayken verilir; yalnız kendi kolunu
--      öğrenebilir (auth.uid()).
--    * Sonuç analizi (A2) bu dosyada değildir.
--
--  NOT: hashtext PostgreSQL içi, kriptografik değildir; yalnız kol dağılımı içindir.
--  abs() kullanılmaz (int4 en küçük değerinde taşar); bit maskesi kullanılır.
-- =====================================================================

create table if not exists public.ab_deney (
  id               uuid primary key default gen_random_uuid(),
  ad               text not null check (char_length(ad) between 3 and 120),
  hipotez          text not null check (char_length(hipotez) between 10 and 500),
  birincil_metrik  text not null check (char_length(birincil_metrik) between 3 and 80),
  guardrail        text[] not null check (cardinality(guardrail) >= 2),
  referans_orani   numeric not null check (referans_orani > 0 and referans_orani < 1),
  minimum_fark     numeric not null check (minimum_fark > 0 and minimum_fark < 1),
  alfa             numeric not null default 0.05 check (alfa > 0 and alfa < 0.5),
  guc              numeric not null default 0.8 check (guc > 0.5 and guc < 1),
  kol_basi_ornek   integer not null check (kol_basi_ornek >= 30),
  baslangic        date not null,
  bitis            date not null,
  sorumlu          text not null check (char_length(sorumlu) between 2 and 120),
  onay_notu        text check (char_length(onay_notu) <= 300),
  durum            text not null default 'taslak'
                     check (durum in ('taslak', 'yayinda', 'bitti', 'durduruldu')),
  olusturma        timestamptz not null default now(),
  constraint ab_tarih check (bitis > baslangic),
  constraint ab_yayin_onay check (
    durum = 'taslak' or (onay_notu is not null and char_length(btrim(onay_notu)) > 0)
  )
);

alter table public.ab_deney enable row level security;
revoke all on public.ab_deney from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Taslak kaydı (yalnız yönetici)
-- ---------------------------------------------------------------------
create or replace function public.admin_ab_deney_kaydet(
  p_ad text, p_hipotez text, p_birincil_metrik text, p_guardrail text[],
  p_referans_orani numeric, p_minimum_fark numeric, p_alfa numeric, p_guc numeric,
  p_kol_basi_ornek integer, p_baslangic date, p_bitis date, p_sorumlu text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_id uuid;
begin
  perform public.require_admin();
  insert into public.ab_deney (ad, hipotez, birincil_metrik, guardrail, referans_orani, minimum_fark,
                               alfa, guc, kol_basi_ornek, baslangic, bitis, sorumlu)
  values (p_ad, p_hipotez, p_birincil_metrik, p_guardrail, p_referans_orani, p_minimum_fark,
          coalesce(p_alfa, 0.05), coalesce(p_guc, 0.8), p_kol_basi_ornek, p_baslangic, p_bitis, p_sorumlu)
  returning id into v_id;
  perform public.log_admin_action('ab_deney_kaydet', jsonb_build_object('id', v_id));
  return v_id;
end;
$function$;

-- ---------------------------------------------------------------------
-- Başlatma: taslak -> yayinda (onay notu zorunlu; bitiş geçmemiş olmalı)
-- ---------------------------------------------------------------------
create or replace function public.admin_ab_deney_baslat(p_id uuid, p_onay_notu text)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_durum text;
  v_bitis date;
begin
  perform public.require_admin();
  if p_onay_notu is null or char_length(btrim(p_onay_notu)) = 0 then
    raise exception 'Onay notu zorunlu' using errcode = '22023';
  end if;

  select d.durum, d.bitis into v_durum, v_bitis from public.ab_deney d where d.id = p_id for update;
  if v_durum is null then
    raise exception 'Deney bulunamadı' using errcode = 'P0002';
  end if;
  if v_durum <> 'taslak' then
    raise exception 'Yalnız taslak deney başlatılabilir (durum: %)', v_durum using errcode = '22023';
  end if;
  if v_bitis <= (now() at time zone 'Europe/Istanbul')::date then
    raise exception 'Bitiş tarihi geçmiş' using errcode = '22023';
  end if;

  update public.ab_deney set durum = 'yayinda', onay_notu = btrim(p_onay_notu) where id = p_id;
  perform public.log_admin_action('ab_deney_baslat', jsonb_build_object('id', p_id));
end;
$function$;

-- ---------------------------------------------------------------------
-- Durdurma (guardrail ihlali): yalnız yayındaki deney
-- ---------------------------------------------------------------------
create or replace function public.admin_ab_deney_durdur(p_id uuid, p_neden text)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_durum text;
begin
  perform public.require_admin();
  select d.durum into v_durum from public.ab_deney d where d.id = p_id for update;
  if v_durum is null then
    raise exception 'Deney bulunamadı' using errcode = 'P0002';
  end if;
  if v_durum <> 'yayinda' then
    raise exception 'Yalnız yayındaki deney durdurulabilir (durum: %)', v_durum using errcode = '22023';
  end if;
  update public.ab_deney set durum = 'durduruldu', onay_notu = coalesce(onay_notu, '') || ' | DURDURULDU: ' || btrim(coalesce(p_neden, ''))
   where id = p_id;
  perform public.log_admin_action('ab_deney_durdur', jsonb_build_object('id', p_id));
end;
$function$;

-- ---------------------------------------------------------------------
-- Listele (yönetici): tanımlar ve durum; kullanıcı bilgisi yok
-- ---------------------------------------------------------------------
create or replace function public.admin_ab_deney_listele(p_limit int default 20)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
begin
  perform public.require_admin();
  return coalesce((
    select jsonb_agg(jsonb_build_object(
             'id', d.id, 'ad', d.ad, 'hipotez', d.hipotez, 'birincil_metrik', d.birincil_metrik,
             'guardrail', d.guardrail, 'referans_orani', d.referans_orani, 'minimum_fark', d.minimum_fark,
             'alfa', d.alfa, 'guc', d.guc, 'kol_basi_ornek', d.kol_basi_ornek,
             'baslangic', d.baslangic, 'bitis', d.bitis, 'sorumlu', d.sorumlu,
             'durum', d.durum, 'onay_notu', d.onay_notu)
           order by d.olusturma desc)
      from (select * from public.ab_deney order by olusturma desc limit least(greatest(coalesce(p_limit, 20), 1), 100)) d
  ), '[]'::jsonb);
end;
$function$;

-- ---------------------------------------------------------------------
-- Atama: giriş yapmış kullanıcının kendi kolu (yalnız yayındaki ve tarih aralığındaki deney)
-- ---------------------------------------------------------------------
create or replace function public.ab_kol(p_deney uuid)
returns text
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_durum text;
  v_bas   date;
  v_bit   date;
  v_bugun date := (now() at time zone 'Europe/Istanbul')::date;
begin
  if auth.uid() is null then
    return null;
  end if;
  select d.durum, d.baslangic, d.bitis into v_durum, v_bas, v_bit
    from public.ab_deney d where d.id = p_deney;
  if v_durum is distinct from 'yayinda' or v_bugun < v_bas or v_bugun > v_bit then
    return null;
  end if;
  return case when (hashtext(p_deney::text || ':' || auth.uid()::text) & 1) = 0
              then 'kontrol' else 'deney' end;
end;
$function$;

revoke execute on function public.admin_ab_deney_kaydet(text, text, text, text[], numeric, numeric, numeric, numeric, integer, date, date, text) from public, anon;
revoke execute on function public.admin_ab_deney_baslat(uuid, text) from public, anon;
revoke execute on function public.admin_ab_deney_durdur(uuid, text) from public, anon;
revoke execute on function public.admin_ab_deney_listele(int) from public, anon;
revoke execute on function public.ab_kol(uuid) from public, anon;
grant  execute on function public.admin_ab_deney_kaydet(text, text, text, text[], numeric, numeric, numeric, numeric, integer, date, date, text) to authenticated, service_role;
grant  execute on function public.admin_ab_deney_baslat(uuid, text) to authenticated, service_role;
grant  execute on function public.admin_ab_deney_durdur(uuid, text) to authenticated, service_role;
grant  execute on function public.admin_ab_deney_listele(int) to authenticated, service_role;
grant  execute on function public.ab_kol(uuid) to authenticated, service_role;
