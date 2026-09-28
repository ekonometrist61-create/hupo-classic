-- =====================================================================
--  KURTARMA: kupon + kampanya kümesi (veli indirim/ücretsiz erişim)
--  Proje : ccozfrpnvyrnktpffkwo — Öğrenci Hazırlık / Hupo
--  Tarih : 2026-09-27
--
--  NE EKSİKTİ?
--    Canlıda var olan, diskte HİÇ olmayan 3 tablo ve 14 fonksiyon:
--      tablolar      : public.campaigns, public.coupons, public.coupon_redemptions
--      fonksiyonlar  : _kupon_kod_temizle, _kupon_dogrula, _kupon_mesaj,
--                      _kupon_deneme_sayisi, _kupon_deneme_kaydet, _kupon_degerlendir,
--                      admin_upsert_coupon, admin_list_coupons, admin_generate_coupon_codes,
--                      admin_set_coupon_active, admin_coupon_stats, coupon_preview,
--                      admin_upsert_campaign, admin_list_campaigns
--
--  KAYNAK
--    [OK] BIREBIR kopya (canli govdeler, kurtarilan/parcalar/*.sql):
--        admin_upsert_coupon.sql, admin_list_coupons.sql, admin_generate_coupon_codes.sql,
--        admin_set_coupon_active.sql, admin_coupon_stats.sql, coupon_preview.sql,
--        admin_upsert_campaign.sql, admin_list_campaigns.sql
--      Yetkiler (kurtarilan/parcalar/_ozet.txt):
--        admin_* + coupon_preview -> "anon: false | auth: true | servis: true"
--    [OK] TABLOLAR KULLANIMDAN GERI KURULDU: canli katalog dokumunde tablo kolonlari
--      yok (information_schema dokumu alinmamis). Kolon adlari YALNIZCA canli
--      govdelerde gecen adlardan alindi; tip/kisitlar mevcut sema desenine
--      (plans/subscriptions/payments, 20260920000900) uyduruldu.
--    [TAHMIN] Govdesi dokumde YOK: _kupon_kod_temizle, _kupon_dogrula,
--      _kupon_mesaj, _kupon_deneme_sayisi, _kupon_deneme_kaydet, _kupon_degerlendir.
--      Bunlarin cagri sozlesmesi (imza + donus anahtarlari) canli govdelerden
--      BIREBIR biliniyor, ic mantigi ise cagri yerlerinden turetildi.
--      Her turetilmis fonksiyonun basinda TODO(kurtarma) ve dogrulama sorgusu var.
--    [TAHMIN] public.coupon_attempts tablosu tamamen TURETILMISTIR
--      (_kupon_deneme_sayisi/_kupon_deneme_kaydet ciftinin deposu).
--
--  DOGRULAMA SORGULARI (canlidan alinip bu dosya tazelenmeli):
--    select pg_get_functiondef('public._kupon_kod_temizle(text)'::regprocedure);
--    select pg_get_functiondef('public._kupon_mesaj(text)'::regprocedure);
--    select pg_get_functiondef('public._kupon_deneme_sayisi(uuid)'::regprocedure);
--    select pg_get_functiondef('public._kupon_deneme_kaydet(uuid)'::regprocedure);
--    select pg_get_functiondef('public._kupon_degerlendir(uuid,text,text,boolean)'::regprocedure);
--    select table_name, column_name, data_type, is_nullable, column_default
--      from information_schema.columns
--     where table_schema = 'public'
--       and table_name in ('campaigns','coupons','coupon_redemptions')
--     order by table_name, ordinal_position;
--    select c.relname from pg_class c join pg_namespace n on n.oid = c.relnamespace
--     where n.nspname = 'public' and (c.relname like '%coupon%' or c.relname like '%kupon%');
--
--  GUVENLIK
--    Tablolar yalnizca SECURITY DEFINER fonksiyonlarca okunur/yazilir; istemciye
--    hicbir yetki verilmez (fail-closed, 20260927000050 ile ayni desen).
--    Kupon tutari ve indirim HER ZAMAN public.plans.fiyat_kurus'tan hesaplanir;
--    istemciden gelen tutara guvenilmez (AGENTS.md 5.4).
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. campaigns — kampanya şemsiyesi (kuponları gruplar)
-- ---------------------------------------------------------------------
create table if not exists public.campaigns (
  id         uuid primary key default gen_random_uuid(),
  ad         text not null,
  aciklama   text,
  baslangic  timestamptz,
  bitis      timestamptz,
  aktif      boolean not null default true,
  created_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),

  constraint campaigns_ad_uzunluk check (char_length(btrim(ad)) between 2 and 80),
  constraint campaigns_tarih_sira  check (baslangic is null or bitis is null or bitis > baslangic)
);

comment on table public.campaigns is
  'Kampanya şemsiyesi. admin_upsert_campaign() yazar, admin_list_campaigns() okur.';

-- ---------------------------------------------------------------------
-- 2. coupons — kupon kodları
--   `kod` üzerinde UNIQUE zorunlu: admin_generate_coupon_codes()
--   "on conflict (kod) do nothing" kullanıyor.
-- ---------------------------------------------------------------------
create table if not exists public.coupons (
  id               uuid primary key default gen_random_uuid(),
  kod              text not null unique,
  campaign_id      uuid references public.campaigns (id) on delete set null,
  tur              text not null,
  deger            integer not null default 0,
  plan_kodlari     text[],
  min_tutar_kurus  integer not null default 0,
  maks_kullanim    integer,
  kullanici_basina integer not null default 1,
  baslangic        timestamptz,
  bitis            timestamptz,
  aktif            boolean not null default true,
  yeni_uye_only    boolean not null default false,
  ucretsiz_izin    boolean not null default false,
  created_by       uuid references public.profiles (id) on delete set null,
  created_at       timestamptz not null default now(),

  -- admin_upsert_coupon() aynı kuralı fonksiyon içinde de denetler (3-24)
  constraint coupons_kod_format check (kod ~ '^[A-Z0-9-]{3,24}$'),
  constraint coupons_tur_check  check (tur in ('yuzde', 'tutar', 'ucretsiz')),
  constraint coupons_deger_check check (
    (tur = 'yuzde'    and deger between 1 and 100) or
    (tur = 'tutar'    and deger >= 100) or
    (tur = 'ucretsiz' and deger = 0)
  ),
  constraint coupons_min_tutar_check        check (min_tutar_kurus >= 0),
  constraint coupons_maks_kullanim_check    check (maks_kullanim is null or maks_kullanim > 0),
  constraint coupons_kullanici_basina_check check (kullanici_basina is null or kullanici_basina > 0),
  constraint coupons_tarih_sira check (baslangic is null or bitis is null or bitis > baslangic)
);

create index if not exists coupons_campaign_idx on public.coupons (campaign_id);
create index if not exists coupons_aktif_idx    on public.coupons (aktif, created_at desc);

comment on table public.coupons is
  'İndirim/ücretsiz kupon kodları. Kodlar yalnızca panelden üretilir; veli kodu önizlerken coupon_preview() kullanır.';
comment on column public.coupons.plan_kodlari is
  'Kuponun geçerli olduğu plan kodları (null/boş = tüm planlar).';
comment on column public.coupons.ucretsiz_izin is
  'Yönetici bu kuponun ücretsiz (plan bedeli 0) sonuçlanmasına açıkça izin verdi mi.';

-- ---------------------------------------------------------------------
-- 3. coupon_redemptions — kim, hangi kuponu, ne zaman, kaç lira indirimle
--   Okuma deseni (canlı gövdelerden BİREBİR):
--     durum = 'kullanildi'                        → gerçek kullanım
--     durum = 'rezerve' and rezerve_bitis > now() → süresi geçmemiş rezerv
--   'iptal' durumu: ödeme iptalinde rezervin serbest bırakılması için.
-- ---------------------------------------------------------------------
create table if not exists public.coupon_redemptions (
  id            uuid primary key default gen_random_uuid(),
  coupon_id     uuid not null references public.coupons (id) on delete cascade,
  veli_id       uuid not null references public.profiles (id) on delete cascade,
  durum         text not null default 'rezerve',
  indirim_kurus integer not null default 0,
  rezerve_bitis timestamptz,
  kullanildi_at timestamptz,
  created_at    timestamptz not null default now(),

  constraint coupon_redemptions_durum_check check (durum in ('rezerve', 'kullanildi', 'iptal')),
  constraint coupon_redemptions_indirim_check check (indirim_kurus >= 0)
);

create index if not exists coupon_redemptions_kupon_idx
  on public.coupon_redemptions (coupon_id, durum);
create index if not exists coupon_redemptions_veli_idx
  on public.coupon_redemptions (veli_id, created_at desc);

comment on table public.coupon_redemptions is
  'Kupon kullanım/rezerv kaydı. _kupon_degerlendir() limitleri buradan sayar.';

-- ---------------------------------------------------------------------
-- 4. coupon_attempts — kupon deneme sayacı (kötüye kullanım freni)
--   TODO(kurtarma): Bu tablo canlı katalog dökümünde YOK; _kupon_deneme_sayisi()
--   ve _kupon_deneme_kaydet() çiftinin deposu olarak TÜRETİLDİ. Canlıda tablo
--   adı/kolonu farklıysa (ör. coupon_tries, kupon_denemeleri) bu blok
--   değiştirilmeli. Doğrulama:
--     select c.relname from pg_class c join pg_namespace n on n.oid = c.relnamespace
--      where n.nspname = 'public' and c.relkind = 'r'
--        and (c.relname like '%deneme%' or c.relname like '%attempt%' or c.relname like '%try%');
-- ---------------------------------------------------------------------
create table if not exists public.coupon_attempts (
  id         uuid primary key default gen_random_uuid(),
  veli_id    uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now()
);

create index if not exists coupon_attempts_veli_idx
  on public.coupon_attempts (veli_id, created_at desc);

comment on table public.coupon_attempts is
  'Kupon kodu deneme kaydı. Saatte 10 denemeden fazlası "cok_deneme" ile reddedilir.';

-- ---------------------------------------------------------------------
-- 5. RLS + yetkiler (fail-closed)
--   Bu tabloları yalnızca SECURITY DEFINER fonksiyonlar kullanır; istemci
--   (anon/authenticated) hiçbir satırı doğrudan okuyamaz/yazamaz.
-- ---------------------------------------------------------------------
alter table public.campaigns           enable row level security;
alter table public.coupons             enable row level security;
alter table public.coupon_redemptions  enable row level security;
alter table public.coupon_attempts     enable row level security;

revoke all on table public.campaigns          from public, anon, authenticated;
revoke all on table public.coupons            from public, anon, authenticated;
revoke all on table public.coupon_redemptions from public, anon, authenticated;
revoke all on table public.coupon_attempts    from public, anon, authenticated;

-- =====================================================================
-- 6. TÜRETİLMİŞ YARDIMCI FONKSİYONLAR (_kupon_*)
--    Gövdeleri kurtarma dökümünde yok; imzalar ve dönüş sözleşmeleri canlı
--    gövdelerden birebir biliniyor:
--      admin_upsert_coupon        → _kupon_dogrula(9 argüman)
--      admin_generate_coupon_codes→ _kupon_dogrula(..., 1, 1, ...)
--      coupon_preview             → _kupon_deneme_sayisi / _kupon_deneme_kaydet /
--                                   _kupon_degerlendir / _kupon_mesaj
--    Dönüş anahtarları (coupon_preview'ın okudukları BİREBİR):
--      gecerli, neden, mesaj, plan_fiyat_kurus, indirim_kurus, odenecek_kurus,
--      ucretsiz, kupon_kod          · neden='plan_yok' → sayaç artmaz
--    Neden kodları (coupon_preview + üretim fonksiyonlarından BİREBİR):
--      plan_yok, cok_deneme
-- =====================================================================

-- ---------------------------------------------------------------------
-- 6.1 _kupon_kod_temizle — kullanıcının yazdığı kodu normalize et
--   TODO(kurtarma): Gövde türetildi. Kod formatı admin_upsert_coupon()'da
--   '^[A-Z0-9-]{3,24}$' olarak denetlendiği için burada da yalnızca büyük
--   harf/rakam/tire kalır; Türkçe karakterler ASCII karşılığına çevrilir.
--   Doğrulama: select pg_get_functiondef('public._kupon_kod_temizle(text)'::regprocedure);
-- ---------------------------------------------------------------------
create or replace function public._kupon_kod_temizle(p_kod text)
returns text
language sql
immutable
set search_path = ''
as $function$
  select nullif(
    upper(
      translate(
        regexp_replace(coalesce(p_kod, ''), '\s+', '', 'g'),
        'çğıöşüÇĞİÖŞÜ', 'cgiosucgiosu'
      )
    ), '');
$function$;

comment on function public._kupon_kod_temizle(text) is
  'Kupon kodunu büyük harfe çevirir, boşlukları atar, Türkçe harfleri ASCII karşılığına indirir.';

-- ---------------------------------------------------------------------
-- 6.2 _kupon_mesaj — neden kodunu velinin göreceği Türkçe metne çevirir
--   TODO(kurtarma): Metinler türetildi (APK metin dökümünde kupon metni yok,
--   panel web olduğu için metinleri dökümde bulunmuyor). Ton: 2. tekil şahıs,
--   samimi (AGENTS.md §1). Doğrulama:
--     select pg_get_functiondef('public._kupon_mesaj(text)'::regprocedure);
-- ---------------------------------------------------------------------
create or replace function public._kupon_mesaj(p_neden text)
returns text
language sql
immutable
set search_path = ''
as $function$
  select case coalesce(p_neden, '')
    when 'cok_deneme'       then 'Çok fazla kupon denedin, biraz sonra tekrar dene.'
    when 'kod_yok'          then 'Bu kupon kodu bulunamadı.'
    when 'pasif'            then 'Bu kupon artık geçerli değil.'
    when 'baslamadi'        then 'Bu kupon henüz başlamadı.'
    when 'suresi_gecti'     then 'Bu kuponun süresi doldu.'
    when 'plan_yok'         then 'Seçtiğin plan bulunamadı.'
    when 'plan_uygun_degil' then 'Bu kupon seçtiğin plan için geçerli değil.'
    when 'uygun_degil'      then 'Bu kuponu şu anda kullanamazsın.'
    when 'min_tutar'        then 'Bu kupon için tutar yetersiz.'
    when 'yeni_uye_degil'   then 'Bu kupon yalnızca yeni üyeler için.'
    when 'limit_doldu'      then 'Bu kuponun kullanım limiti doldu.'
    when 'kullanildi'       then 'Bu kuponu zaten kullandın.'
    when 'giris_gerekli'    then 'Kuponu kullanmak için giriş yapmalısın.'
    else 'Bu kupon şu anda kullanılamıyor.'
  end;
$function$;

comment on function public._kupon_mesaj(text) is
  'Kupon reddi nedenini kullanıcıya gösterilecek Türkçe metne çevirir.';

-- ---------------------------------------------------------------------
-- 6.3 _kupon_dogrula — kupon alanlarını kaydetmeden ÖNCE denetler
--   Çağrı sözleşmesi BİREBİR (canlı gövdelerden):
--     admin_upsert_coupon()        : (p_tur, p_deger, v_plans, p_min_tutar_kurus,
--                                     p_maks_kullanim, p_kullanici_basina,
--                                     p_baslangic, p_bitis, p_ucretsiz_izin)
--     admin_generate_coupon_codes(): (p_tur, p_deger, v_plans, p_min_tutar_kurus,
--                                     1, 1, p_baslangic, p_bitis, p_ucretsiz_izin)
--   TODO(kurtarma): Gövde türetildi; iki çağrı yerindeki argüman sırası kilit
--   nokta. Denetimler, üretilen kodların kısıtlarıyla (maks_kullanim=1,
--   kullanici_basina=1, kod 3-24) ve coupons tablosundaki CHECK'lerle uyumlu
--   tutuldu. Bilinçli olarak YAPILMAYAN denetim: "bitiş geçmişte olamaz" —
--   yönetici süresi dolmuş bir kuponu düzenleyebilmeli.
--   Doğrulama:
--     select pg_get_functiondef('public._kupon_dogrula(text,integer,text[],integer,integer,integer,timestamptz,timestamptz,boolean)'::regprocedure);
-- ---------------------------------------------------------------------
create or replace function public._kupon_dogrula(
  p_tur              text,
  p_deger            integer,
  p_plan_kodlari     text[],
  p_min_tutar_kurus  integer,
  p_maks_kullanim    integer,
  p_kullanici_basina integer,
  p_baslangic        timestamptz,
  p_bitis            timestamptz,
  p_ucretsiz_izin    boolean
)
returns void
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_tur text := lower(btrim(coalesce(p_tur, '')));
  v_yok integer;
begin
  if v_tur not in ('yuzde', 'tutar', 'ucretsiz') then
    raise exception 'Kupon türü yuzde, tutar veya ucretsiz olmalı' using errcode = '22023';
  end if;

  if v_tur = 'yuzde' then
    if p_deger is null or p_deger < 1 or p_deger > 100 then
      raise exception 'Yüzde indirim 1 ile 100 arasında olmalı' using errcode = '22023';
    end if;
  elsif v_tur = 'tutar' then
    if p_deger is null or p_deger < 100 then
      raise exception 'Tutar indirimi en az 1 TL (100 kuruş) olmalı' using errcode = '22023';
    end if;
  else
    if coalesce(p_deger, -1) <> 0 then
      raise exception 'Ücretsiz kuponda indirim değeri 0 olmalı' using errcode = '22023';
    end if;
    if not coalesce(p_ucretsiz_izin, false) then
      raise exception 'Ücretsiz kupon için "ücretsiz izni" işaretlenmeli' using errcode = '22023';
    end if;
  end if;

  if coalesce(p_min_tutar_kurus, 0) < 0 then
    raise exception 'En düşük tutar negatif olamaz' using errcode = '22023';
  end if;
  if p_maks_kullanim is not null and p_maks_kullanim < 1 then
    raise exception 'Kullanım limiti en az 1 olmalı' using errcode = '22023';
  end if;
  if p_kullanici_basina is not null and p_kullanici_basina < 1 then
    raise exception 'Kişi başı kullanım en az 1 olmalı' using errcode = '22023';
  end if;
  if p_baslangic is not null and p_bitis is not null and p_bitis <= p_baslangic then
    raise exception 'Bitiş tarihi başlangıçtan sonra olmalı' using errcode = '22023';
  end if;

  if p_plan_kodlari is not null and cardinality(p_plan_kodlari) > 0 then
    select count(*) into v_yok
      from unnest(p_plan_kodlari) as k
     where not exists (select 1 from public.plans p where p.kod = k);
    if v_yok > 0 then
      raise exception 'Geçersiz plan kodu seçildi' using errcode = '22023';
    end if;
  end if;
end;
$function$;

comment on function public._kupon_dogrula(text, integer, text[], integer, integer, integer, timestamptz, timestamptz, boolean) is
  'Kupon alanlarını kaydetmeden önce doğrular; geçersizse 22023 yükseltir.';

-- ---------------------------------------------------------------------
-- 6.4 _kupon_deneme_sayisi / _kupon_deneme_kaydet — deneme freni
--   coupon_preview: "if _kupon_deneme_sayisi(v_uid) >= 10 → cok_deneme".
--   Yalnızca BAŞARISIZ denemeler sayılır (coupon_preview sayacı yalnızca hata
--   dalında artırır, neden='plan_yok' olduğunda artırmaz).
--   TODO(kurtarma): Gövde + tablo (coupon_attempts) türetildi. Canlıda sayaç
--   başka bir tabloda tutuluyorsa bu iki fonksiyon ona çevrilmeli.
--   Doğrulama:
--     select pg_get_functiondef('public._kupon_deneme_sayisi(uuid)'::regprocedure);
--     select pg_get_functiondef('public._kupon_deneme_kaydet(uuid)'::regprocedure);
-- ---------------------------------------------------------------------
create or replace function public._kupon_deneme_sayisi(p_uid uuid)
returns integer
language sql
stable
security definer
set search_path = ''
as $function$
  select count(*)::integer
    from public.coupon_attempts a
   where a.veli_id = p_uid
     and a.created_at > now() - interval '1 hour';
$function$;

comment on function public._kupon_deneme_sayisi(uuid) is
  'Bir velinin son 1 saatteki başarısız kupon deneme sayısı.';

create or replace function public._kupon_deneme_kaydet(p_uid uuid)
returns void
language sql
security definer
set search_path = ''
as $function$
  insert into public.coupon_attempts (veli_id)
  select p_uid
   where p_uid is not null;
$function$;

comment on function public._kupon_deneme_kaydet(uuid) is
  'Başarısız kupon denemesini kaydeder (saatlik frene girdi sağlar).';

-- ---------------------------------------------------------------------
-- 6.5 _kupon_degerlendir — kuponu plan fiyatına göre değerlendirir
--   Dönüş anahtarları BİREBİR (coupon_preview bunları okuyor):
--     gecerli (bool), neden (text|null), mesaj (text|null),
--     plan_fiyat_kurus (int), indirim_kurus (int), odenecek_kurus (int),
--     ucretsiz (bool), kupon_kod (text)
--   neden kodları: plan_yok, kod_yok, pasif, baslamadi, suresi_gecti,
--     uygun_degil, plan_uygun_degil, min_tutar, yeni_uye_degil,
--     limit_doldu, kullanildi
--   Fiyat/kupon limitleri HER ZAMAN public.plans.fiyat_kurus'tan hesaplanır
--   (AGENTS.md §5.4); istemciden tutar alınmaz.
--   4. argüman (p_rezerve): canlı imzada boolean bir 4. parametre var ve
--   coupon_preview onu false geçiyor. true verilirse 30 dk'lık rezerv yazılır
--   (ödeme akışı RPC'sinin kullanması beklenir). 'yeni_uye_only' kontrolü
--   plansız/yeni velide payments.durum='basarili' kaydı yokluğuna bakar.
--   TODO(kurtarma): Gövde ve 4. parametrenin ADI canlıdan teyit edilmeli:
--     select pg_get_functiondef('public._kupon_degerlendir(uuid,text,text,boolean)'::regprocedure);
-- ---------------------------------------------------------------------
create or replace function public._kupon_degerlendir(
  p_uid      uuid,
  p_plan_kod text,
  p_kod      text,
  p_rezerve  boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_kod      text := public._kupon_kod_temizle(p_kod);
  v_kupon    public.coupons%rowtype;
  v_fiyat    integer;
  v_kullanim integer;
  v_kisi     integer;
  v_indirim  integer;
  v_odenecek integer;
  v_ucretsiz boolean;
  v_rez      uuid;
  v_neden    text;
begin
  select p.fiyat_kurus into v_fiyat from public.plans p where p.kod = p_plan_kod;
  if not found then
    return jsonb_build_object('gecerli', false, 'neden', 'plan_yok',
                              'mesaj', public._kupon_mesaj('plan_yok'),
                              'plan_fiyat_kurus', null, 'indirim_kurus', 0,
                              'odenecek_kurus', null, 'ucretsiz', false, 'kupon_kod', v_kod);
  end if;

  select * into v_kupon from public.coupons c where c.kod = v_kod;
  if not found then
    v_neden := 'kod_yok';
  elsif not v_kupon.aktif then
    v_neden := 'pasif';
  elsif v_kupon.baslangic is not null and v_kupon.baslangic > now() then
    v_neden := 'baslamadi';
  elsif v_kupon.bitis is not null and v_kupon.bitis < now() then
    v_neden := 'suresi_gecti';
  elsif v_kupon.tur = 'ucretsiz' and not v_kupon.ucretsiz_izin then
    v_neden := 'uygun_degil';
  elsif v_kupon.plan_kodlari is not null and cardinality(v_kupon.plan_kodlari) > 0
        and not (p_plan_kod = any (v_kupon.plan_kodlari)) then
    v_neden := 'plan_uygun_degil';
  elsif coalesce(v_kupon.min_tutar_kurus, 0) > v_fiyat then
    v_neden := 'min_tutar';
  elsif v_kupon.yeni_uye_only
        and exists (select 1 from public.payments p
                     where p.veli_id = p_uid and p.durum = 'basarili') then
    v_neden := 'yeni_uye_degil';
  end if;

  if v_neden is null then
    select count(*) into v_kullanim
      from public.coupon_redemptions r
     where r.coupon_id = v_kupon.id and r.durum = 'kullanildi';
    if v_kupon.maks_kullanim is not null and v_kullanim >= v_kupon.maks_kullanim then
      v_neden := 'limit_doldu';
    end if;
  end if;

  if v_neden is null then
    select count(*) into v_kisi
      from public.coupon_redemptions r
     where r.coupon_id = v_kupon.id
       and r.veli_id = p_uid
       and (r.durum = 'kullanildi' or (r.durum = 'rezerve' and r.rezerve_bitis > now()));
    if v_kisi >= greatest(coalesce(v_kupon.kullanici_basina, 1), 1) then
      v_neden := 'kullanildi';
    end if;
  end if;

  if v_neden is not null then
    return jsonb_build_object('gecerli', false, 'neden', v_neden,
                              'mesaj', public._kupon_mesaj(v_neden),
                              'plan_fiyat_kurus', v_fiyat, 'indirim_kurus', 0,
                              'odenecek_kurus', v_fiyat, 'ucretsiz', false, 'kupon_kod', v_kod);
  end if;

  v_indirim := case v_kupon.tur
                 when 'yuzde' then round(v_fiyat * v_kupon.deger / 100.0)::integer
                 when 'tutar' then least(v_kupon.deger, v_fiyat)
                 else v_fiyat
               end;
  v_indirim  := greatest(least(v_indirim, v_fiyat), 0);
  v_odenecek := greatest(v_fiyat - v_indirim, 0);
  v_ucretsiz := (v_kupon.tur = 'ucretsiz') or v_odenecek = 0;

  if coalesce(p_rezerve, false) and p_uid is not null then
    select r.id into v_rez
      from public.coupon_redemptions r
     where r.coupon_id = v_kupon.id and r.veli_id = p_uid
       and r.durum = 'rezerve' and r.rezerve_bitis > now()
     order by r.created_at desc
     limit 1;
    if v_rez is null then
      insert into public.coupon_redemptions (coupon_id, veli_id, durum, indirim_kurus, rezerve_bitis)
      values (v_kupon.id, p_uid, 'rezerve', v_indirim, now() + interval '30 minutes')
      returning id into v_rez;
    else
      update public.coupon_redemptions
         set indirim_kurus = v_indirim,
             rezerve_bitis = now() + interval '30 minutes'
       where id = v_rez;
    end if;
  end if;

  return jsonb_build_object(
    'gecerli', true, 'neden', null, 'mesaj', null,
    'kupon_id', v_kupon.id, 'kupon_kod', v_kupon.kod, 'tur', v_kupon.tur, 'deger', v_kupon.deger,
    'plan_fiyat_kurus', v_fiyat, 'indirim_kurus', v_indirim, 'odenecek_kurus', v_odenecek,
    'ucretsiz', v_ucretsiz, 'rezerve_id', v_rez);
end;
$function$;

comment on function public._kupon_degerlendir(uuid, text, text, boolean) is
  'Plana göre kuponu değerlendirir; indirimi plans.fiyat_kurus üzerinden hesaplar.';

-- =====================================================================
-- 7. CANLI GÖVDELER (BİREBİR) — kupon/kampanya yönetici RPC'leri
--    Kaynak: kurtarilan/parcalar/admin_*.sql, coupon_preview.sql
--    Yetki özeti (kurtarilan/parcalar/_ozet.txt): anon: false | auth: true | servis: true
-- =====================================================================

-- 7.1 admin_upsert_coupon
create or replace function public.admin_upsert_coupon(
  p_id uuid,
  p_kod text,
  p_tur text,
  p_deger integer,
  p_plan_kodlari text[] default null,
  p_min_tutar_kurus integer default 0,
  p_maks_kullanim integer default null,
  p_kullanici_basina integer default 1,
  p_baslangic timestamptz default null,
  p_bitis timestamptz default null,
  p_aktif boolean default true,
  p_yeni_uye_only boolean default false,
  p_ucretsiz_izin boolean default false,
  p_campaign_id uuid default null
)
returns uuid
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_id    uuid := p_id;
  v_kod   text := public._kupon_kod_temizle(p_kod);
  v_plans text[] := case when p_plan_kodlari is null or cardinality(p_plan_kodlari) = 0 then null else p_plan_kodlari end;
begin
  perform public.require_admin();
  perform public._kupon_dogrula(p_tur, p_deger, v_plans, p_min_tutar_kurus, p_maks_kullanim,
                                p_kullanici_basina, p_baslangic, p_bitis, p_ucretsiz_izin);
  if p_campaign_id is not null and not exists (select 1 from public.campaigns where id = p_campaign_id) then
    raise exception 'Kampanya bulunamadı' using errcode = 'P0002';
  end if;

  if v_id is null then
    if v_kod !~ '^[A-Z0-9-]{3,24}$' then
      raise exception 'Kupon kodu 3-24 karakter olmalı (yalnızca A-Z, 0-9 ve -)' using errcode = '22023';
    end if;
    begin
      insert into public.coupons (kod, campaign_id, tur, deger, plan_kodlari, min_tutar_kurus, maks_kullanim,
                                  kullanici_basina, baslangic, bitis, aktif, yeni_uye_only, ucretsiz_izin, created_by)
      values (v_kod, p_campaign_id, p_tur, p_deger, v_plans, coalesce(p_min_tutar_kurus, 0), p_maks_kullanim,
              coalesce(p_kullanici_basina, 1), p_baslangic, p_bitis, coalesce(p_aktif, true),
              coalesce(p_yeni_uye_only, false), coalesce(p_ucretsiz_izin, false), (select auth.uid()))
      returning id into v_id;
    exception when unique_violation then
      raise exception 'Bu kupon kodu zaten var' using errcode = '23505';
    end;
  else
    -- Kod değiştirilemez (dağıtılmış kodlar bozulmasın)
    update public.coupons set
      campaign_id = p_campaign_id, tur = p_tur, deger = p_deger, plan_kodlari = v_plans,
      min_tutar_kurus = coalesce(p_min_tutar_kurus, 0), maks_kullanim = p_maks_kullanim,
      kullanici_basina = coalesce(p_kullanici_basina, 1), baslangic = p_baslangic, bitis = p_bitis,
      aktif = coalesce(p_aktif, true), yeni_uye_only = coalesce(p_yeni_uye_only, false),
      ucretsiz_izin = coalesce(p_ucretsiz_izin, false)
     where id = v_id;
    if not found then
      raise exception 'Kupon bulunamadı' using errcode = 'P0002';
    end if;
  end if;

  perform public.log_admin_action('kupon_kaydedildi', jsonb_build_object(
    'kupon_id', v_id, 'tur', p_tur, 'deger', p_deger, 'yeni', p_id is null));
  return v_id;
end;
$function$;

-- 7.2 admin_list_coupons
create or replace function public.admin_list_coupons(
  p_aktif boolean default null,
  p_arama text default null,
  p_limit integer default 25,
  p_offset integer default 0,
  p_campaign_id uuid default null
)
returns jsonb
language plpgsql
stable security definer
set search_path to ''
as $function$
declare
  v_limit  integer := least(greatest(coalesce(p_limit, 25), 1), 100);
  v_offset integer := greatest(coalesce(p_offset, 0), 0);
  v_ara    text := nullif(public._kupon_kod_temizle(p_arama), '');
  v_toplam integer;
  v_satir  jsonb;
begin
  perform public.require_admin();

  select count(*)::integer into v_toplam
    from public.coupons c
   where (p_aktif is null or c.aktif = p_aktif)
     and (v_ara is null or position(v_ara in c.kod) > 0)
     and (p_campaign_id is null or c.campaign_id = p_campaign_id);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id), '[]'::jsonb) into v_satir
    from (
      select c.id, c.kod, c.campaign_id, k.ad as kampanya_ad, c.tur, c.deger, c.plan_kodlari,
             c.min_tutar_kurus, c.maks_kullanim, c.kullanici_basina, c.baslangic, c.bitis, c.aktif,
             c.yeni_uye_only, c.ucretsiz_izin, c.created_at,
             (select count(*) from public.coupon_redemptions r where r.coupon_id = c.id and r.durum = 'kullanildi')::integer as kullanim,
             (select count(*) from public.coupon_redemptions r
               where r.coupon_id = c.id and r.durum = 'rezerve' and r.rezerve_bitis > now())::integer as rezerve
        from public.coupons c
        left join public.campaigns k on k.id = c.campaign_id
       where (p_aktif is null or c.aktif = p_aktif)
         and (v_ara is null or position(v_ara in c.kod) > 0)
         and (p_campaign_id is null or c.campaign_id = p_campaign_id)
       order by c.created_at desc, c.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('toplam', v_toplam, 'satirlar', v_satir);
end;
$function$;

-- 7.3 admin_generate_coupon_codes
create or replace function public.admin_generate_coupon_codes(
  p_prefix text,
  p_adet integer,
  p_tur text,
  p_deger integer,
  p_plan_kodlari text[] default null,
  p_min_tutar_kurus integer default 0,
  p_baslangic timestamptz default null,
  p_bitis timestamptz default null,
  p_yeni_uye_only boolean default false,
  p_ucretsiz_izin boolean default false,
  p_campaign_id uuid default null
)
returns text[]
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_pre    text := public._kupon_kod_temizle(p_prefix);
  v_plans  text[] := case when p_plan_kodlari is null or cardinality(p_plan_kodlari) = 0 then null else p_plan_kodlari end;
  v_alf    constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';   -- karışan 0/O/1/I yok, 32 karakter
  v_kodlar text[] := '{}';
  v_kod    text;
  v_b      bytea;
  v_deneme integer := 0;
  v_i      integer;
  idx      integer[] := array[0, 1, 2, 3, 4, 5, 9, 10, 11, 12];
begin
  perform public.require_admin();
  if p_adet is null or p_adet < 1 or p_adet > 500 then
    raise exception 'Adet 1 ile 500 arasında olmalı' using errcode = '22023';
  end if;
  if v_pre !~ '^[A-Z0-9]{0,12}$' then
    raise exception 'Ön ek en fazla 12 karakter (A-Z, 0-9) olmalı' using errcode = '22023';
  end if;
  perform public._kupon_dogrula(p_tur, p_deger, v_plans, p_min_tutar_kurus, 1, 1, p_baslangic, p_bitis, p_ucretsiz_izin);
  if p_campaign_id is not null and not exists (select 1 from public.campaigns where id = p_campaign_id) then
    raise exception 'Kampanya bulunamadı' using errcode = 'P0002';
  end if;

  while cardinality(v_kodlar) < p_adet loop
    v_deneme := v_deneme + 1;
    if v_deneme > p_adet * 5 + 50 then
      raise exception 'Benzersiz kod üretilemedi, ön eki değiştir' using errcode = '54000';
    end if;
    v_b := uuid_send(gen_random_uuid());
    v_kod := '';
    for v_i in 1..10 loop
      v_kod := v_kod || substr(v_alf, (get_byte(v_b, idx[v_i]) % 32) + 1, 1);
    end loop;
    if v_pre <> '' then v_kod := v_pre || '-' || v_kod; end if;

    insert into public.coupons (kod, campaign_id, tur, deger, plan_kodlari, min_tutar_kurus, maks_kullanim,
                                kullanici_basina, baslangic, bitis, aktif, yeni_uye_only, ucretsiz_izin, created_by)
    values (v_kod, p_campaign_id, p_tur, p_deger, v_plans, coalesce(p_min_tutar_kurus, 0), 1, 1,
            p_baslangic, p_bitis, true, coalesce(p_yeni_uye_only, false), coalesce(p_ucretsiz_izin, false),
            (select auth.uid()))
    on conflict (kod) do nothing;
    if found then
      v_kodlar := v_kodlar || v_kod;
    end if;
  end loop;

  perform public.log_admin_action('kupon_toplu_uretildi', jsonb_build_object(
    'adet', p_adet, 'onek', v_pre, 'tur', p_tur, 'deger', p_deger, 'kampanya_id', p_campaign_id));
  return v_kodlar;
end;
$function$;

-- 7.4 admin_set_coupon_active
create or replace function public.admin_set_coupon_active(p_id uuid, p_aktif boolean)
returns void
language plpgsql
security definer
set search_path to ''
as $function$
begin
  perform public.require_admin();
  update public.coupons set aktif = coalesce(p_aktif, false) where id = p_id;
  if not found then
    raise exception 'Kupon bulunamadı' using errcode = 'P0002';
  end if;
  perform public.log_admin_action('kupon_durumu_degisti', jsonb_build_object('kupon_id', p_id, 'aktif', p_aktif));
end;
$function$;

-- 7.5 admin_coupon_stats
create or replace function public.admin_coupon_stats(p_id uuid)
returns jsonb
language plpgsql
stable security definer
set search_path to ''
as $function$
declare
  v_kod text;
begin
  perform public.require_admin();
  select kod into v_kod from public.coupons where id = p_id;
  if not found then
    raise exception 'Kupon bulunamadı' using errcode = 'P0002';
  end if;
  return jsonb_build_object(
    'kupon_id', p_id, 'kod', v_kod,
    'kullanim', (select count(*) from public.coupon_redemptions where coupon_id = p_id and durum = 'kullanildi'),
    'rezerve', (select count(*) from public.coupon_redemptions where coupon_id = p_id and durum = 'rezerve' and rezerve_bitis > now()),
    'toplam_indirim_kurus', coalesce((select sum(indirim_kurus) from public.coupon_redemptions
                                       where coupon_id = p_id and durum = 'kullanildi'), 0),
    'benzersiz_veli', (select count(distinct veli_id) from public.coupon_redemptions
                        where coupon_id = p_id and durum = 'kullanildi'));
end;
$function$;

-- 7.6 coupon_preview — veli uygulaması/paneli kupon önizlemesi
create or replace function public.coupon_preview(p_plan_kod text, p_kod text)
returns jsonb
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_uid   uuid := (select auth.uid());
  r       jsonb;
  v_fiyat integer;
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  if public.current_user_role() is distinct from 'veli' then
    raise exception 'Yalnızca veli hesabı kupon kullanabilir' using errcode = '42501';
  end if;

  if public._kupon_deneme_sayisi(v_uid) >= 10 then
    return jsonb_build_object('gecerli', false, 'neden', 'cok_deneme', 'mesaj', public._kupon_mesaj('cok_deneme'));
  end if;

  r := public._kupon_degerlendir(v_uid, p_plan_kod, p_kod, false);
  if (r ->> 'gecerli')::boolean then
    return jsonb_build_object('gecerli', true, 'neden', null, 'mesaj', null,
      'plan_fiyat_kurus', r -> 'plan_fiyat_kurus', 'indirim_kurus', r -> 'indirim_kurus',
      'odenecek_kurus', r -> 'odenecek_kurus', 'ucretsiz', r -> 'ucretsiz', 'kod', r -> 'kupon_kod');
  end if;

  if r ->> 'neden' is distinct from 'plan_yok' then
    perform public._kupon_deneme_kaydet(v_uid);
  end if;
  select fiyat_kurus into v_fiyat from public.plans where kod = p_plan_kod;
  return jsonb_build_object('gecerli', false, 'neden', r -> 'neden', 'mesaj', r -> 'mesaj',
    'plan_fiyat_kurus', v_fiyat, 'indirim_kurus', 0, 'odenecek_kurus', v_fiyat);
end;
$function$;

-- 7.7 admin_upsert_campaign
create or replace function public.admin_upsert_campaign(
  p_id uuid,
  p_ad text,
  p_aciklama text default null,
  p_baslangic timestamptz default null,
  p_bitis timestamptz default null,
  p_aktif boolean default true
)
returns uuid
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_id uuid := p_id;
begin
  perform public.require_admin();
  if p_ad is null or length(trim(p_ad)) < 2 or length(trim(p_ad)) > 80 then
    raise exception 'Kampanya adı 2-80 karakter olmalı' using errcode = '22023';
  end if;
  if p_baslangic is not null and p_bitis is not null and p_bitis <= p_baslangic then
    raise exception 'Bitiş tarihi başlangıçtan sonra olmalı' using errcode = '22023';
  end if;
  if v_id is null then
    insert into public.campaigns (ad, aciklama, baslangic, bitis, aktif, created_by)
    values (trim(p_ad), nullif(trim(coalesce(p_aciklama, '')), ''), p_baslangic, p_bitis,
            coalesce(p_aktif, true), (select auth.uid()))
    returning id into v_id;
  else
    update public.campaigns set ad = trim(p_ad), aciklama = nullif(trim(coalesce(p_aciklama, '')), ''),
           baslangic = p_baslangic, bitis = p_bitis, aktif = coalesce(p_aktif, true)
     where id = v_id;
    if not found then
      raise exception 'Kampanya bulunamadı' using errcode = 'P0002';
    end if;
  end if;
  perform public.log_admin_action('kampanya_kaydedildi', jsonb_build_object('kampanya_id', v_id, 'ad', trim(p_ad)));
  return v_id;
end;
$function$;

-- 7.8 admin_list_campaigns
create or replace function public.admin_list_campaigns()
returns jsonb
language plpgsql
stable security definer
set search_path to ''
as $function$
begin
  perform public.require_admin();
  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id)
      from (
        select k.id, k.ad, k.aciklama, k.baslangic, k.bitis, k.aktif, k.created_at,
               (select count(*) from public.coupons c where c.campaign_id = k.id)::integer as kupon_sayisi,
               (select count(*) from public.coupon_redemptions r join public.coupons c on c.id = r.coupon_id
                 where c.campaign_id = k.id and r.durum = 'kullanildi')::integer as kullanim,
               coalesce((select sum(r.indirim_kurus) from public.coupon_redemptions r join public.coupons c on c.id = r.coupon_id
                 where c.campaign_id = k.id and r.durum = 'kullanildi'), 0)::bigint as toplam_indirim_kurus
          from public.campaigns k
      ) x), '[]'::jsonb);
end;
$function$;

-- =====================================================================
-- 8. REVOKE / GRANT
--    Canlı yetki özeti (kurtarilan/parcalar/_ozet.txt) birebir:
--      admin_* + coupon_preview : anon: false | auth: true | servis: true
--      _kupon_* (yardımcı)      : canlı yetki kaydı yok → iç kullanım,
--                                 istemciye hiç verilmez (fail-closed)
-- =====================================================================
revoke execute on function public.admin_upsert_coupon(uuid, text, text, integer, text[], integer, integer, integer, timestamptz, timestamptz, boolean, boolean, boolean, uuid) from public, anon;
grant  execute on function public.admin_upsert_coupon(uuid, text, text, integer, text[], integer, integer, integer, timestamptz, timestamptz, boolean, boolean, boolean, uuid) to authenticated;

revoke execute on function public.admin_list_coupons(boolean, text, integer, integer, uuid) from public, anon;
grant  execute on function public.admin_list_coupons(boolean, text, integer, integer, uuid) to authenticated;

revoke execute on function public.admin_generate_coupon_codes(text, integer, text, integer, text[], integer, timestamptz, timestamptz, boolean, boolean, uuid) from public, anon;
grant  execute on function public.admin_generate_coupon_codes(text, integer, text, integer, text[], integer, timestamptz, timestamptz, boolean, boolean, uuid) to authenticated;

revoke execute on function public.admin_set_coupon_active(uuid, boolean) from public, anon;
grant  execute on function public.admin_set_coupon_active(uuid, boolean) to authenticated;

revoke execute on function public.admin_coupon_stats(uuid) from public, anon;
grant  execute on function public.admin_coupon_stats(uuid) to authenticated;

revoke execute on function public.coupon_preview(text, text) from public, anon;
grant  execute on function public.coupon_preview(text, text) to authenticated;

revoke execute on function public.admin_upsert_campaign(uuid, text, text, timestamptz, timestamptz, boolean) from public, anon;
grant  execute on function public.admin_upsert_campaign(uuid, text, text, timestamptz, timestamptz, boolean) to authenticated;

revoke execute on function public.admin_list_campaigns() from public, anon;
grant  execute on function public.admin_list_campaigns() to authenticated;

revoke execute on function public._kupon_kod_temizle(text) from public, anon, authenticated;
revoke execute on function public._kupon_mesaj(text) from public, anon, authenticated;
revoke execute on function public._kupon_dogrula(text, integer, text[], integer, integer, integer, timestamptz, timestamptz, boolean) from public, anon, authenticated;
revoke execute on function public._kupon_deneme_sayisi(uuid) from public, anon, authenticated;
revoke execute on function public._kupon_deneme_kaydet(uuid) from public, anon, authenticated;
revoke execute on function public._kupon_degerlendir(uuid, text, text, boolean) from public, anon, authenticated;
