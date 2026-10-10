-- =====================================================================
-- Paket tipleri (landing kolonları) veritabanına taşınıyor.
--   plan_tipleri : kolon tanımı — ad, özellikler, buton metni, vurgu, sıra
--   plans.tip_kod: her paket bir tipe bağlı (Premium / Aile / yeni tip)
-- Landing list_plan_tipleri() ile tipleri ve altındaki aktif paketleri alır.
-- Mevcut paketler tip_kod'a göre ataşılır: adında/kodunda aile|family → family, diğerleri premium.
-- =====================================================================

create table if not exists public.plan_tipleri (
  kod           text primary key,
  ad            text not null,
  ad_en         text,
  aciklama      text,
  ozellikler    text[] not null default '{}',
  ozellikler_en text[] not null default '{}',
  cta_metni     text not null default 'Başla',
  cta_en        text,
  vurgulu       boolean not null default false,
  sira          integer not null default 0,
  aktif         boolean not null default true,

  constraint plan_tipleri_kod_format check (kod ~ '^[a-z0-9_]{2,30}$'),
  constraint plan_tipleri_ad_uzunluk check (char_length(btrim(ad)) between 2 and 60)
);

alter table public.plan_tipleri enable row level security;
revoke all on public.plan_tipleri from public, anon, authenticated;

insert into public.plan_tipleri
  (kod, ad, ad_en, ozellikler, ozellikler_en, cta_metni, cta_en, vurgulu, sira)
values
  ('free', 'Ücretsiz', 'Free',
   array['Temel ders içerikleri', 'Günde 1 tekrar turu', 'Temel karakter koleksiyonu', 'Temel gelişim takibi'],
   array['Basic course content', '1 review session per day', 'Basic character collection', 'Basic progress tracking'],
   'Ücretsiz Başla', 'Start Free', false, 1),
  ('premium', 'Premium', 'Premium',
   array['Tüm derslere sınırsız erişim', 'Kişiselleştirilmiş öğrenme planı', 'Akıllı tekrar sistemi', 'Tüm karakter koleksiyonu', 'Ligler ve etkinlikler', 'Detaylı gelişim takibi', 'Veli paneli', 'Deneme sınavları', 'Reklamsız, güvenli ortam'],
   array['Unlimited access to all courses', 'Personalized learning plan', 'Smart review system', 'Complete character collection', 'Leagues and events', 'Detailed progress tracking', 'Parent dashboard', 'Practice exams', 'Ad-free, secure environment'],
   'Premium''a Geç', 'Upgrade to Premium', true, 2),
  ('family', 'Aile Planı', 'Family Plan',
   array['Premium''daki tüm özellikler', '6 aile üyesine kadar erişim', 'Her çocuk için ayrı profil', 'Aile raporları', 'Öncelikli müşteri desteği', 'Özel aile etkinlikleri', 'Daha ekonomik'],
   array['All Premium features', 'Access for up to 6 family members', 'Separate profile for each child', 'Family reports', 'Priority customer support', 'Special family events', 'More economical'],
   'Aile Planı Seç', 'Choose Family Plan', false, 3)
on conflict (kod) do nothing;

alter table public.plans
  add column if not exists tip_kod text references public.plan_tipleri (kod) on update cascade;

update public.plans
   set tip_kod = case when (kod || ' ' || ad) ~* 'aile|family' then 'family' else 'premium' end
 where tip_kod is null;

alter table public.plans alter column tip_kod set not null;

create index if not exists plans_tip_idx on public.plans (tip_kod);

-- Landing: aktif tipler + her tipin aktif paketleri
create or replace function public.list_plan_tipleri()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(jsonb_agg(jsonb_build_object(
    'kod',           t.kod,
    'ad',            t.ad,
    'ad_en',         t.ad_en,
    'aciklama',      t.aciklama,
    'ozellikler',    to_jsonb(t.ozellikler),
    'ozellikler_en', to_jsonb(t.ozellikler_en),
    'cta_metni',     t.cta_metni,
    'cta_en',        t.cta_en,
    'vurgulu',       t.vurgulu,
    'planlar', coalesce((
      select jsonb_agg(jsonb_build_object(
               'kod', p.kod, 'ad', p.ad, 'fiyat_kurus', p.fiyat_kurus, 'sure_gun', p.sure_gun)
             order by p.sira, p.kod)
        from public.plans p
       where p.tip_kod = t.kod and p.aktif
    ), '[]'::jsonb)
  ) order by t.sira, t.kod), '[]'::jsonb)
  from public.plan_tipleri t
  where t.aktif;
$$;

revoke execute on function public.list_plan_tipleri() from public;
grant  execute on function public.list_plan_tipleri() to anon, authenticated;

create or replace function public.admin_list_plan_tipleri()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.require_admin();
  return coalesce((
    select jsonb_agg(to_jsonb(t) order by t.sira, t.kod) from public.plan_tipleri t
  ), '[]'::jsonb);
end;
$$;

revoke execute on function public.admin_list_plan_tipleri() from public, anon;
grant  execute on function public.admin_list_plan_tipleri() to authenticated;

create or replace function public.admin_upsert_plan_tipi(
  p_kod           text,
  p_ad            text,
  p_ad_en         text,
  p_aciklama      text,
  p_ozellikler    text[],
  p_ozellikler_en text[],
  p_cta_metni     text,
  p_cta_en        text,
  p_vurgulu       boolean,
  p_sira          integer,
  p_aktif         boolean
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.require_admin();
  if p_kod is null or p_kod !~ '^[a-z0-9_]{2,30}$' then
    raise exception 'Tip kodu 2-30 karakter, küçük harf/rakam/alt çizgi olmalı' using errcode = '22023';
  end if;
  insert into public.plan_tipleri
    (kod, ad, ad_en, aciklama, ozellikler, ozellikler_en, cta_metni, cta_en, vurgulu, sira, aktif)
  values
    (p_kod, trim(p_ad), nullif(trim(coalesce(p_ad_en, '')), ''), nullif(trim(coalesce(p_aciklama, '')), ''),
     coalesce(p_ozellikler, '{}'), coalesce(p_ozellikler_en, '{}'), coalesce(nullif(trim(p_cta_metni), ''), 'Başla'),
     nullif(trim(coalesce(p_cta_en, '')), ''), coalesce(p_vurgulu, false), coalesce(p_sira, 0), coalesce(p_aktif, true))
  on conflict (kod) do update
    set ad            = excluded.ad,
        ad_en         = excluded.ad_en,
        aciklama      = excluded.aciklama,
        ozellikler    = excluded.ozellikler,
        ozellikler_en = excluded.ozellikler_en,
        cta_metni     = excluded.cta_metni,
        cta_en        = excluded.cta_en,
        vurgulu       = excluded.vurgulu,
        sira          = excluded.sira,
        aktif         = excluded.aktif;
  perform public.log_admin_action('plan_tipi_kaydedildi', jsonb_build_object('kod', p_kod));
end;
$$;

revoke execute on function public.admin_upsert_plan_tipi(text, text, text, text, text[], text[], text, text, boolean, integer, boolean) from public, anon;
grant  execute on function public.admin_upsert_plan_tipi(text, text, text, text, text[], text[], text, text, boolean, integer, boolean) to authenticated;

drop function if exists public.admin_upsert_plan(text, text, text, integer, integer, boolean);

create function public.admin_upsert_plan(
  p_kod          text,
  p_ad           text,
  p_aciklama     text,
  p_fiyat_kurus  integer,
  p_sure_gun     integer,
  p_aktif        boolean default true,
  p_tip_kod      text default 'premium'
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.require_admin();
  if p_kod is null or p_kod !~ '^[a-z0-9_]{2,30}$' then
    raise exception 'Plan kodu 2-30 karakter, küçük harf/rakam/alt çizgi olmalı' using errcode = '22023';
  end if;
  insert into public.plans (kod, ad, aciklama, fiyat_kurus, sure_gun, aktif, tip_kod)
  values (p_kod, trim(p_ad), nullif(trim(coalesce(p_aciklama, '')), ''), p_fiyat_kurus, p_sure_gun,
          coalesce(p_aktif, true), coalesce(p_tip_kod, 'premium'))
  on conflict (kod) do update
    set ad = excluded.ad, aciklama = excluded.aciklama, fiyat_kurus = excluded.fiyat_kurus,
        sure_gun = excluded.sure_gun, aktif = excluded.aktif, tip_kod = excluded.tip_kod;
  perform public.log_admin_action('plan_kaydedildi',
    jsonb_build_object('kod', p_kod, 'fiyat_kurus', p_fiyat_kurus, 'tip_kod', p_tip_kod));
end;
$$;

revoke execute on function public.admin_upsert_plan(text, text, text, integer, integer, boolean, text) from public, anon;
grant  execute on function public.admin_upsert_plan(text, text, text, integer, integer, boolean, text) to authenticated;
