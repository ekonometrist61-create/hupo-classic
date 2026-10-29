-- =====================================================================
--  P1 · ESNEK PAKET SİSTEMİ: modüller, paketler, matris, sürüm, has_access
--  Tarih : 2026-10-29
--  Tasarım: docs/paketler/ESNEK_PAKET_VE_ODEME_MIMARISI.md (§1, §2, §8 P1)
--  Ön koşul: 20260920000900 (plans, subscriptions, require_admin, log_admin_action),
--            20260920001100 (is_premium), 20261018010000 (_deneme_aktif)
--
--  NE DEĞİŞİYOR? (YALNIZ EKLEME; mevcut davranış korunur)
--    1) moduller      : modül kataloğu (taslak / yayinda / arsiv)
--    2) paketler      : paket tanımı (tür, çocuk sınırı, rapor kapsamı, yenileme, görünürlük)
--    3) paket_modul   : paket × modül matrisi (erişim + günlük kota); panelden düzenlenecek
--    4) paket_surum   : yayında alınan anlık görüntü (kazanılmış hak için)
--    5) plans.paket_kod, subscriptions.paket_surum: satış kalemi → paket; satın alma anındaki sürüm
--    6) has_access(uid, modul) (İÇ) ve my_access() (istemci)
--
--  ÖNEMLİ KURALLAR
--    * FAIL-CLOSED: matriste olmayan modül, taslak/arşiv modül, yayınlanmamış paket → erişim 'yok'.
--    * ESKİ PLANLAR KORUNUR: plans.paket_kod boş olan satış kalemi, bugünkü "premium" gibi davranır
--      (tüm yayındaki modüllere tam erişim). Böylece mevcut aboneler aynı erişimi korur.
--    * KAZANILMIŞ HAK: abonelik, satın alma anındaki paket sürümünü taşır. Sonradan yayınlanan yeni
--      modül eski sürümde yoktur → erişim 'yok' (mevcut aboneleri kapsama kararı P2'de).
--    * FİYAT YOK: bu migration hiçbir fiyat/plan satırı eklemez ("repoda fiyat uydurulmaz").
--    * Bu dilim istemci kodunu DEĞİŞTİRMEZ; is_premium / my_subscription_status aynen çalışır.
--      İstemci kapıları P4'tür. Tohum matrisi bu yüzden şimdilik etkisizdir (kimse okumuyor).
--  Rollback: önce paket_surum tetikleyicisi ve fonksiyonlar, sonra kolonlar ve tablolar düşürülür
--    (bu migration'a bağlı başka nesne yok).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Tablolar
-- ---------------------------------------------------------------------
create table if not exists public.moduller (
  kod          text primary key,
  ad           text not null,
  aciklama     text,
  durum        text not null default 'taslak',
  sira         integer not null default 0,
  yayin_tarihi timestamptz,
  created_at   timestamptz not null default now(),
  constraint moduller_kod_format check (kod ~ '^[a-z][a-z0-9_]{1,29}$'),
  constraint moduller_ad_uzunluk check (char_length(btrim(ad)) between 2 and 60),
  constraint moduller_durum check (durum in ('taslak', 'yayinda', 'arsiv'))
);

create table if not exists public.paketler (
  kod            text primary key,
  ad             text not null,
  aciklama       text,
  tur            text not null,
  cocuk_siniri   integer not null default 1,
  rapor_kapsami  text not null default 'modul',
  yenileme_modu  text not null default 'manuel',
  gorunur        boolean not null default true,
  vurgulu        boolean not null default false,
  sira           integer not null default 0,
  durum          text not null default 'taslak',
  surum          integer not null default 0,
  created_at     timestamptz not null default now(),
  constraint paketler_kod_format check (kod ~ '^[a-z][a-z0-9_]{1,29}$'),
  constraint paketler_ad_uzunluk check (char_length(btrim(ad)) between 2 and 60),
  constraint paketler_tur check (tur in ('ucretsiz', 'modul', 'tam', 'aile', 'kurum', 'deneme', 'beta')),
  constraint paketler_cocuk check (cocuk_siniri between 1 and 10),
  constraint paketler_rapor check (rapor_kapsami in ('ozet', 'modul', 'birlesik')),
  constraint paketler_yenileme check (yenileme_modu in ('manuel', 'otomatik')),
  constraint paketler_durum check (durum in ('taslak', 'yayinda', 'arsiv')),
  constraint paketler_surum check (surum >= 0)
);

create table if not exists public.paket_modul (
  paket_kod   text not null references public.paketler (kod) on update cascade on delete cascade,
  modul_kod   text not null references public.moduller (kod) on update cascade on delete cascade,
  erisim      text not null default 'yok',
  gunluk_kota integer,
  kisit       jsonb not null default '{}'::jsonb,
  primary key (paket_kod, modul_kod),
  constraint paket_modul_erisim check (erisim in ('yok', 'onizleme', 'sinirli', 'tam')),
  constraint paket_modul_kota check (gunluk_kota is null or gunluk_kota >= 0),
  constraint paket_modul_kisit check (jsonb_typeof(kisit) = 'object')
);

create table if not exists public.paket_surum (
  paket_kod     text not null references public.paketler (kod) on update cascade on delete cascade,
  surum         integer not null,
  matris        jsonb not null,
  cocuk_siniri  integer not null,
  rapor_kapsami text not null,
  yayin_tarihi  timestamptz not null default now(),
  primary key (paket_kod, surum),
  constraint paket_surum_surum check (surum >= 1),
  constraint paket_surum_matris check (jsonb_typeof(matris) = 'object')
);

alter table public.moduller    enable row level security;
alter table public.paketler    enable row level security;
alter table public.paket_modul enable row level security;
alter table public.paket_surum enable row level security;
-- Politika yok = istemciye kapalı (fail-closed). Yönetim ve okuma yalnız RPC ile.
revoke all on public.moduller, public.paketler, public.paket_modul, public.paket_surum
  from public, anon, authenticated;

-- Satış kalemi → paket; abonelik → satın alma anındaki paket sürümü
alter table public.plans
  add column if not exists paket_kod text references public.paketler (kod) on update cascade;
create index if not exists plans_paket_idx on public.plans (paket_kod);

alter table public.subscriptions
  add column if not exists paket_surum integer check (paket_surum is null or paket_surum >= 1);

-- ---------------------------------------------------------------------
-- 2. İç yardımcılar
-- ---------------------------------------------------------------------
create or replace function public._erisim_sira(p_erisim text)
returns integer
language sql
immutable
set search_path = ''
as $$
  select case p_erisim when 'tam' then 3 when 'sinirli' then 2 when 'onizleme' then 1 else 0 end;
$$;

-- Bir paket sürümünün tek modül hücresi: {erisim, gunluk_kota, kisit} ya da NULL
create or replace function public._paket_hucre(p_paket text, p_surum integer, p_modul text)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select ps.matris -> p_modul
    from public.paket_surum ps
   where ps.paket_kod = p_paket
     and ps.surum = coalesce(p_surum, (select k.surum from public.paketler k where k.kod = p_paket));
$$;

-- Yayınla: matristen anlık görüntü alır, sürümü artırır. Yalnız YAYINDAKİ modüller girer.
create or replace function public._paket_yayinla_ic(p_paket text)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_yeni   integer;
  v_matris jsonb;
begin
  if not exists (select 1 from public.paketler where kod = p_paket) then
    raise exception 'Paket bulunamadı: %', p_paket using errcode = 'P0002';
  end if;

  select coalesce(max(surum), 0) + 1 into v_yeni from public.paket_surum where paket_kod = p_paket;

  select coalesce(jsonb_object_agg(pm.modul_kod, jsonb_build_object(
           'erisim', pm.erisim, 'gunluk_kota', pm.gunluk_kota, 'kisit', pm.kisit)), '{}'::jsonb)
    into v_matris
    from public.paket_modul pm
    join public.moduller m on m.kod = pm.modul_kod
   where pm.paket_kod = p_paket and m.durum = 'yayinda';

  insert into public.paket_surum (paket_kod, surum, matris, cocuk_siniri, rapor_kapsami)
  select k.kod, v_yeni, v_matris, k.cocuk_siniri, k.rapor_kapsami
    from public.paketler k where k.kod = p_paket;

  update public.paketler set surum = v_yeni, durum = 'yayinda' where kod = p_paket;
  return v_yeni;
end;
$$;

-- Abonelik oluşurken, satın alma anındaki yayınlı paket sürümünü damgala
create or replace function public._abonelik_paket_surum()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_paket text;
  v_surum integer;
begin
  if new.paket_surum is null then
    select p.paket_kod into v_paket from public.plans p where p.kod = new.plan_kod;
    if v_paket is not null then
      select k.surum into v_surum from public.paketler k where k.kod = v_paket and k.durum = 'yayinda';
      new.paket_surum := nullif(v_surum, 0);
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists subscriptions_paket_surum on public.subscriptions;
create trigger subscriptions_paket_surum
  before insert on public.subscriptions
  for each row execute function public._abonelik_paket_surum();

-- ---------------------------------------------------------------------
-- 3. has_access (İÇ) ve my_access (istemci)
--    Kaynak sırası: abonelik(ler) + deneme + ücretsiz taban; en yüksek erişim kazanır,
--    eşitlikte daha geniş (NULL = sınırsız) kota kazanır.
-- ---------------------------------------------------------------------
create or replace function public.has_access(p_uid uuid, p_modul text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_durum   text;
  v_rol     text;
  v_sahip   uuid;
  v_hucre   jsonb;
  v_erisim  text;
  v_kota    integer;
  v_kaynak  text;
  v_paket   text;
  v_en_sira integer := 0;
  v_en_kota integer := -1;
  v_sonuc   jsonb := jsonb_build_object('erisim', 'yok', 'gunluk_kota', null, 'kaynak', 'yok', 'paket_kod', null);
  s         record;
  v_sira    integer;
  v_kcmp    integer;
begin
  select m.durum into v_durum from public.moduller m where m.kod = p_modul;
  if v_durum is null then
    return v_sonuc;                                   -- bilinmeyen modül: kapalı
  end if;

  select pr.role into v_rol from public.profiles pr where pr.id = p_uid;
  if v_rol = 'admin' then
    return jsonb_build_object('erisim', 'tam', 'gunluk_kota', null, 'kaynak', 'admin', 'paket_kod', null);
  end if;
  if v_durum <> 'yayinda' then
    return v_sonuc;                                   -- taslak / arşiv modül: kapalı
  end if;

  v_sahip := case v_rol
    when 'veli' then p_uid
    when 'ogrenci' then (select pr.parent_id from public.profiles pr where pr.id = p_uid)
    else null end;

  -- Aday listesi: (erişim, kota, kaynak, paket)
  for s in
    -- a) aktif abonelikler (hane sahibinin)
    select pl.paket_kod, sb.paket_surum, 'abonelik'::text as kaynak
      from public.subscriptions sb
      join public.plans pl on pl.kod = sb.plan_kod
     where v_sahip is not null and sb.veli_id = v_sahip and sb.durum = 'aktif' and sb.bitis > now()
    union all
    -- b) deneme
    select 'deneme'::text, null::integer, 'deneme'::text
     where public._deneme_aktif(p_uid)
    union all
    -- c) ücretsiz taban
    select 'ucretsiz'::text, null::integer, 'ucretsiz'::text
  loop
    if s.paket_kod is null then
      -- Eski plan (paket eşlemesi yok): bugünkü premium gibi, yayındaki her modüle tam
      v_erisim := 'tam'; v_kota := null; v_paket := null; v_kaynak := 'eski_plan';
    else
      v_hucre := public._paket_hucre(s.paket_kod, s.paket_surum, p_modul);
      v_erisim := coalesce(v_hucre ->> 'erisim', 'yok');
      v_kota := (v_hucre ->> 'gunluk_kota')::integer;
      v_paket := s.paket_kod; v_kaynak := s.kaynak;
    end if;

    v_sira := public._erisim_sira(v_erisim);
    v_kcmp := coalesce(v_kota, 2147483647);
    if v_sira > v_en_sira or (v_sira = v_en_sira and v_sira > 0 and v_kcmp > v_en_kota) then
      v_en_sira := v_sira; v_en_kota := v_kcmp;
      v_sonuc := jsonb_build_object('erisim', v_erisim, 'gunluk_kota', v_kota,
                                    'kaynak', v_kaynak, 'paket_kod', v_paket);
    end if;
  end loop;

  return v_sonuc;
end;
$$;

create or replace function public.my_access()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  return coalesce((
    select jsonb_object_agg(m.kod, public.has_access(v_uid, m.kod) order by m.kod)
      from public.moduller m
     where m.durum = 'yayinda'
  ), '{}'::jsonb);
end;
$$;

-- Yönetici: paketi yayınla (anlık görüntü + sürüm artışı). Düzenleme RPC'leri P3'te gelir.
create or replace function public.admin_paket_yayinla(p_paket text)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_surum integer;
begin
  perform public.require_admin();
  v_surum := public._paket_yayinla_ic(p_paket);
  perform public.log_admin_action('paket_yayinlandi',
    jsonb_build_object('paket', p_paket, 'surum', v_surum));
  return v_surum;
end;
$$;

revoke execute on function public._erisim_sira(text), public._paket_hucre(text, integer, text),
  public._paket_yayinla_ic(text), public._abonelik_paket_surum(), public.has_access(uuid, text)
  from public, anon, authenticated;
revoke execute on function public.my_access(), public.admin_paket_yayinla(text) from public, anon;
grant  execute on function public.my_access(), public.admin_paket_yayinla(text) to authenticated;

-- ---------------------------------------------------------------------
-- 4. Tohum: modüller, paketler, matris (HİÇ FİYAT YOK; hepsi panelden değişir)
--    Ücretsiz taban: soru-cevap günlük 20 (bugünkü premium_gating varsayılanı); diğerleri önizleme.
--    Deneme paketi: pazarlama planı "14 gün tam erişim"; bugünkü kod ise günlük 20 soru veriyor
--    (20261018010000). Bu fark AÇIK KARARDIR; istemci kapıları (P4) gelmeden etkisizdir.
-- ---------------------------------------------------------------------
insert into public.moduller (kod, ad, aciklama, durum, sira, yayin_tarihi) values
  ('okuma',         'Okuma',         'Okumayı sevdiren hikâyeler ve etkinlikler', 'yayinda', 1, now()),
  ('carpma',        'Çarpma',        'Çarpım tablosu pratiği ve oyunları',        'yayinda', 2, now()),
  ('soru_cevap',    'Soru-Cevap',    'Sınıfa ve kazanıma göre soru bankası',      'yayinda', 3, now()),
  ('deneme',        'Deneme',        'Deneme sınavları',                          'yayinda', 4, now()),
  ('kelime_evreni', 'Kelime Evreni', 'Eş anlamlı, zıt anlamlı, eş sesli oyunları','yayinda', 5, now())
on conflict (kod) do nothing;

insert into public.paketler (kod, ad, tur, cocuk_siniri, rapor_kapsami, vurgulu, sira) values
  ('ucretsiz', 'Ücretsiz',          'ucretsiz', 1, 'ozet',     false, 1),
  ('deneme',   'Deneme',            'deneme',   1, 'birlesik', false, 2),
  ('hupo_read','HupoRead',          'modul',    1, 'modul',    false, 3),
  ('soru',     'Soru',              'modul',    1, 'modul',    false, 4),
  ('tam',      'Tam',               'tam',      1, 'birlesik', true,  5),
  ('aile2',    'Aile (2 çocuk)',    'aile',     2, 'birlesik', false, 6),
  ('aile3',    'Aile (3 çocuk)',    'aile',     3, 'birlesik', false, 7)
on conflict (kod) do nothing;

-- Matris: (paket, modül, erişim, kota)
insert into public.paket_modul (paket_kod, modul_kod, erisim, gunluk_kota)
select v.paket, v.modul, v.erisim, v.kota
  from (values
    ('ucretsiz','okuma','onizleme',null::integer), ('ucretsiz','carpma','onizleme',null),
    ('ucretsiz','soru_cevap','sinirli',20),        ('ucretsiz','deneme','onizleme',null),
    ('ucretsiz','kelime_evreni','onizleme',null),
    ('deneme','okuma','tam',null), ('deneme','carpma','tam',null), ('deneme','soru_cevap','tam',null),
    ('deneme','deneme','tam',null), ('deneme','kelime_evreni','tam',null),
    ('hupo_read','okuma','tam',null),
    ('soru','soru_cevap','tam',null), ('soru','deneme','tam',null),
    ('tam','okuma','tam',null), ('tam','carpma','tam',null), ('tam','soru_cevap','tam',null),
    ('tam','deneme','tam',null), ('tam','kelime_evreni','tam',null),
    ('aile2','okuma','tam',null), ('aile2','carpma','tam',null), ('aile2','soru_cevap','tam',null),
    ('aile2','deneme','tam',null), ('aile2','kelime_evreni','tam',null),
    ('aile3','okuma','tam',null), ('aile3','carpma','tam',null), ('aile3','soru_cevap','tam',null),
    ('aile3','deneme','tam',null), ('aile3','kelime_evreni','tam',null)
  ) as v(paket, modul, erisim, kota)
on conflict (paket_kod, modul_kod) do nothing;

-- Tüm tohum paketleri sürüm 1 olarak yayınla (yalnız henüz yayınlanmamış olanlar)
do $$
declare
  r record;
begin
  for r in select kod from public.paketler where surum = 0 order by sira loop
    perform public._paket_yayinla_ic(r.kod);
  end loop;
end;
$$;
