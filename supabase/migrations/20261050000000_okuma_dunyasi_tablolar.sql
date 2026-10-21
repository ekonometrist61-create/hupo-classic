-- =====================================================================
-- "Senin Hikâyen" / Okuma Dünyası — F1 veritabanı katmanı (1/4): tablolar, tetikleyiciler, iç yardımcılar
--
--   * Özellik bayrağı KAPALI gelir (okuma_ayarlari.aktif = false). Bu migration tek başına hiçbir
--     öğrenciye içerik göstermez.
--   * Tüm tablolarda RLS açık; istemci rollerinin doğrudan erişimi YOK (yalnız SECURITY DEFINER RPC).
--   * İçerik değişmez sürüm olarak tutulur (okuma_hikaye_surumleri.icerik). Sürümün içeriği hiçbir
--     durumda güncellenemez; yalnız durum / denetim / inceleyen alanları kuralla değişir.
--   * Cinsiyet hiçbir tabloda yoktur. Çocuk / aile / yoldaş adı hiçbir tabloda yoktur.
--   * Soru anahtarı (dogru, aciklama) yalnız sürüm içeriğinde durur ve istemciye hiçbir RPC ile çıkmaz.
--   * Ek-only: mevcut nesnelere dokunmaz. Dağıtım ayrı onayla yapılır.
-- Sonraki dosyalar: _yonetim (2/4), _ogrenci (3/4), _veli_ogretmen (4/4).
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Özellik bayrağı ve ayarlar (app_settings paylaşımlı beyaz liste olduğundan ayrı tablo)
-- ---------------------------------------------------------------------
create table public.okuma_ayarlari (
  anahtar        text primary key,
  deger          jsonb not null,
  guncelleyen_id uuid references public.profiles (id) on delete set null,
  guncellendi_at timestamptz not null default now()
);

insert into public.okuma_ayarlari (anahtar, deger) values
  ('aktif',                    'false'::jsonb),     -- genel bayrak (varsayılan KAPALI)
  ('pilot_siniflari',          '[]'::jsonb),        -- boş = tüm sınıflar; dolu = yalnız bu sınıflar
  ('izinli_kullanicilar',      '[]'::jsonb),        -- önizleme: 'incelemede' hikâyeleri yalnız bunlar görür
  ('okuma_gunluk_hikaye',      '1'::jsonb),         -- ücretsiz günlük hikâye kotası
  ('okuma_pdf_aylik_ucretsiz', '3'::jsonb),         -- ücretsiz aylık PDF hakkı
  ('xp_tamamlama',             '10'::jsonb),        -- award_xp_and_streak 10/20/30 adımları
  ('xp_dogru_bonus',           '10'::jsonb),
  ('dogru_orani_esik',         '67'::jsonb),        -- yüzde
  ('xp_gunluk_hikaye_tavani',  '2'::jsonb),         -- günde en çok N hikâyenin XP'si
  ('min_n',                    '5'::jsonb),         -- yönetim analitiği asgari örnek
  ('saatlik_baslatma_siniri',  '12'::jsonb);

-- ---------------------------------------------------------------------
-- 2. Kontrollü sözlük (tema, ders, Maarif değeri, çatı değer)
-- ---------------------------------------------------------------------
create table public.okuma_etiket_sozlugu (
  tur     text not null check (tur in ('tema', 'ders', 'deger', 'cati_deger')),
  anahtar text not null check (anahtar ~ '^[A-Za-z0-9_]{1,40}$'),
  ad      text not null check (length(ad) between 1 and 80),
  aktif   boolean not null default true,
  primary key (tur, anahtar)
);

insert into public.okuma_etiket_sozlugu (tur, anahtar, ad) values
  ('tema', 'dostluk',         'Dostluk ve arkadaşlık'),
  ('tema', 'aile',            'Aile ve ev'),
  ('tema', 'okul',            'Okul ve sınıf yaşamı'),
  ('tema', 'kesif',           'Keşif ve merak'),
  ('tema', 'gizem',           'Gizem ve ipucu çözme'),
  ('tema', 'doga',            'Doğa ve çevre'),
  ('tema', 'hayvanlar',       'Hayvanlar'),
  ('tema', 'bilim_teknoloji', 'Bilim ve teknoloji'),
  ('tema', 'sabir_emek',      'Sabır ve emek'),
  ('tema', 'dayanisma',       'Yardımlaşma ve dayanışma'),
  ('tema', 'kultur_miras',    'Kültür, gelenek ve miras'),
  ('tema', 'saglikli_yasam',  'Sağlıklı yaşam ve spor'),
  ('tema', 'guvenlik',        'Güvenlik ve sorumluluk'),
  ('tema', 'sanat_yaraticilik', 'Sanat ve yaratıcılık'),
  ('tema', 'okuma_kitap',     'Okuma ve kitap sevgisi'),
  ('tema', 'mizah',           'Mizah ve eğlence'),
  ('ders', 'turkce',          'Türkçe'),
  ('ders', 'matematik',       'Matematik'),
  ('ders', 'fen',             'Fen Bilimleri'),
  ('ders', 'sosyal',          'Sosyal Bilgiler'),
  ('ders', 'hayat_bilgisi',   'Hayat Bilgisi'),
  ('ders', 'ink_tarihi',      'T.C. İnkılap Tarihi ve Atatürkçülük'),
  ('deger', 'D1',  'Adalet'),
  ('deger', 'D2',  'Aile Bütünlüğü'),
  ('deger', 'D3',  'Çalışkanlık'),
  ('deger', 'D4',  'Dostluk'),
  ('deger', 'D5',  'Duyarlılık'),
  ('deger', 'D6',  'Dürüstlük'),
  ('deger', 'D7',  'Estetik'),
  ('deger', 'D8',  'Mahremiyet'),
  ('deger', 'D9',  'Merhamet'),
  ('deger', 'D10', 'Mütevazılık'),
  ('deger', 'D11', 'Özgürlük'),
  ('deger', 'D12', 'Sabır'),
  ('deger', 'D13', 'Sağlıklı Yaşam'),
  ('deger', 'D14', 'Saygı'),
  ('deger', 'D15', 'Sevgi'),
  ('deger', 'D16', 'Sorumluluk'),
  ('deger', 'D17', 'Tasarruf'),
  ('deger', 'D18', 'Temizlik'),
  ('deger', 'D19', 'Vatanseverlik'),
  ('deger', 'D20', 'Yardımseverlik'),
  ('cati_deger', 'adalet',     'Adalet'),
  ('cati_deger', 'saygi',      'Saygı'),
  ('cati_deger', 'sorumluluk', 'Sorumluluk');

-- ---------------------------------------------------------------------
-- 3. Hikâye kimliği ve DEĞİŞMEZ sürümler
-- ---------------------------------------------------------------------
create table public.okuma_hikayeleri (
  id            uuid primary key default gen_random_uuid(),
  slug          text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  olusturuldu_at timestamptz not null default now()
);

create table public.okuma_hikaye_surumleri (
  id               uuid primary key default gen_random_uuid(),
  hikaye_id        uuid not null references public.okuma_hikayeleri (id),
  surum_no         integer not null check (surum_no >= 1),
  durum            text not null default 'taslak' check (durum in ('taslak', 'incelemede', 'yayinda', 'arsiv')),
  -- Paketin tamamı (soru anahtarı dahil). Hiçbir RPC bunu olduğu gibi istemciye vermez.
  icerik           jsonb not null,
  sha256           text not null check (sha256 ~ '^[0-9a-f]{64}$'),
  min_motor_surumu integer not null default 1 check (min_motor_surumu >= 1),
  -- Katalog hızı için paket başlığından kopyalanan, değişmez alanlar
  baslik           text not null,
  tanitim          text,
  tur              text not null,
  konu             text not null,
  sinif_alt        smallint not null check (sinif_alt between 1 and 8),
  sinif_ust        smallint not null check (sinif_ust between 1 and 8),
  okuma_bandi      smallint not null check (okuma_bandi between 1 and 3),
  dunya_tipi       text not null check (dunya_tipi in ('gercekci', 'masalsi')),
  izinli_turler    text[] not null check (cardinality(izinli_turler) >= 1),
  deger_anahtarlari text[] not null default '{}' check (cardinality(deger_anahtarlari) <= 5),
  yetiskin_uygun   boolean not null,
  sayfa_sayisi     smallint not null,
  soru_sayisi      smallint not null check (soru_sayisi between 2 and 5),
  -- Yaşam döngüsü (değişebilen alanlar)
  olusturan_id     uuid references public.profiles (id) on delete set null,
  inceleyen_id     uuid references public.profiles (id) on delete set null,
  denetim          jsonb not null default '{"ajan_a":"pending","ajan_b":"pending","insan":"pending"}'::jsonb,
  paket_denetimi   jsonb,   -- pakette beyan edilen denetim (bilgi amaçlı; kapıda kullanılmaz)
  olusturuldu_at   timestamptz not null default now(),
  yayin_at         timestamptz,
  arsiv_at         timestamptz,
  constraint okuma_surum_hikaye_no_uq unique (hikaye_id, surum_no),
  constraint okuma_surum_hikaye_sha_uq unique (hikaye_id, sha256),
  constraint okuma_surum_sinif_aralik check (sinif_alt <= sinif_ust),
  constraint okuma_surum_denetim_sekil check (
    jsonb_typeof(denetim) = 'object'
    and denetim ->> 'ajan_a' in ('pending', 'pass', 'fail', 'review_needed')
    and denetim ->> 'ajan_b' in ('pending', 'pass', 'fail', 'review_needed')
    and denetim ->> 'insan' in ('pending', 'approved', 'rejected')
  ),
  -- Yayın kapısı (sunucuda ikinci kat): üç onay + dört göz
  constraint okuma_surum_yayin_kapisi check (
    durum <> 'yayinda'
    or (
      denetim ->> 'ajan_a' = 'pass'
      and denetim ->> 'ajan_b' = 'pass'
      and denetim ->> 'insan' = 'approved'
      and inceleyen_id is not null
      and inceleyen_id is distinct from olusturan_id
    )
  )
);

-- Hikâye başına tek yayında sürüm
create unique index okuma_surum_tek_yayinda_uidx
  on public.okuma_hikaye_surumleri (hikaye_id) where durum = 'yayinda';
create index okuma_surum_durum_idx on public.okuma_hikaye_surumleri (durum, hikaye_id);

-- Değişmezlik: içerik hiçbir koşulda değişmez; yalnız yaşam döngüsü alanları değişebilir.
create or replace function public._okuma_surum_koru()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_degisebilir text[] := array['durum', 'denetim', 'inceleyen_id', 'yayin_at', 'arsiv_at'];
begin
  if tg_op = 'DELETE' then
    if old.durum <> 'taslak' then
      raise exception 'SURUM_DEGISMEZ: yayınlanmış veya arşivlenmiş sürüm silinemez' using errcode = '55000';
    end if;
    return old;
  end if;

  if (to_jsonb(new) - v_degisebilir) is distinct from (to_jsonb(old) - v_degisebilir) then
    raise exception 'SURUM_DEGISMEZ: sürüm içeriği değiştirilemez; yeni sürüm olarak içe aktarın' using errcode = '55000';
  end if;

  if old.durum = 'yayinda' then
    -- Yayında sürümde yalnız arşive geçilebilir; denetim ve inceleyen sabit kalır.
    if new.durum not in ('yayinda', 'arsiv') then
      raise exception 'SURUM_DEGISMEZ: yayındaki sürüm yalnız arşive alınabilir' using errcode = '55000';
    end if;
    if new.denetim is distinct from old.denetim or new.inceleyen_id is distinct from old.inceleyen_id then
      raise exception 'SURUM_DEGISMEZ: yayındaki sürümün denetim kaydı değiştirilemez' using errcode = '55000';
    end if;
  elsif old.durum = 'arsiv' and new.durum = 'yayinda' then
    raise exception 'SURUM_DEGISMEZ: arşiv sürüm doğrudan yayına alınamaz' using errcode = '55000';
  end if;
  return new;
end;
$$;

create trigger okuma_surum_koru_trg
  before update or delete on public.okuma_hikaye_surumleri
  for each row execute function public._okuma_surum_koru();

-- ---------------------------------------------------------------------
-- 4. Etiketler (sürüm başına bir satır; sürümle birlikte değişmez)
-- ---------------------------------------------------------------------
create table public.okuma_hikaye_etiketleri (
  surum_id        uuid primary key references public.okuma_hikaye_surumleri (id) on delete cascade,
  hikaye_id       uuid not null references public.okuma_hikayeleri (id),
  ana_sinif       smallint not null check (ana_sinif between 1 and 8),
  okuma_zorlugu   smallint not null check (okuma_zorlugu between 1 and 5),
  kavram_zorlugu  smallint not null check (kavram_zorlugu between 1 and 5),
  -- Yalnız yumuşak sıralama için. Filtre değildir; istemciye dönmez. Çocuğun cinsiyeti tutulmaz.
  ilgi_egilimi    text not null default 'ortak' check (ilgi_egilimi in ('ortak', 'kiz_egilimli', 'erkek_egilimli')),
  temalar         text[] not null check (cardinality(temalar) between 1 and 4),
  ders_baglantisi text[] not null check (cardinality(ders_baglantisi) >= 1),
  ana_deger       text not null check (ana_deger ~ '^D([1-9]|1[0-9]|20)$'),
  yardimci_deger  text check (yardimci_deger ~ '^D([1-9]|1[0-9]|20)$' and yardimci_deger <> ana_deger),
  cati_degerler   text[] not null default '{}',
  kanit_duzeyi    char(1) not null check (kanit_duzeyi in ('A', 'B', 'C', 'D')),
  program_surumu  text not null,
  olculen         jsonb not null default '{}'::jsonb   -- kelime_sayisi, tahmini_sure_dk, ...
);
create index okuma_etiket_sinif_zorluk_idx on public.okuma_hikaye_etiketleri (ana_sinif, okuma_zorlugu);
create index okuma_etiket_temalar_idx on public.okuma_hikaye_etiketleri using gin (temalar);
create index okuma_etiket_ders_idx on public.okuma_hikaye_etiketleri using gin (ders_baglantisi);
create index okuma_etiket_deger_idx on public.okuma_hikaye_etiketleri (ana_deger);
create index okuma_etiket_hikaye_idx on public.okuma_hikaye_etiketleri (hikaye_id);

-- ---------------------------------------------------------------------
-- 5. Öğrenme hedefi kataloğu (dört göz) ve hikâye maruziyeti
-- ---------------------------------------------------------------------
create table public.okuma_ogrenme_hedefleri (
  id            text primary key check (id ~ '^[a-z0-9_]+$'),
  tur           text not null check (tur in ('lexeme', 'idiom', 'proverb', 'homonym', 'concept', 'fact', 'misconception', 'value')),
  etiket        text not null check (length(etiket) between 2 and 120),
  sinif         smallint check (sinif between 1 and 8),
  kanit_duzeyi  char(1) not null default 'C' check (kanit_duzeyi in ('A', 'B', 'C', 'D')),
  onayli        boolean not null default false,
  olusturan_id  uuid references public.profiles (id) on delete set null,
  onaylayan_id  uuid references public.profiles (id) on delete set null,
  onaylandi_at  timestamptz,
  constraint okuma_hedef_dort_goz check (
    not onayli or (onaylayan_id is not null and onaylayan_id is distinct from olusturan_id)
  )
);

create table public.okuma_hikaye_hedefleri (
  surum_id  uuid not null references public.okuma_hikaye_surumleri (id) on delete cascade,
  hedef_id  text not null references public.okuma_ogrenme_hedefleri (id),
  yuva      text,
  islev     text not null check (islev in ('first_hint', 'application', 'retrieval', 'transfer', 'background')),
  primary key (surum_id, hedef_id, islev)
);
create index okuma_hikaye_hedefleri_hedef_idx on public.okuma_hikaye_hedefleri (hedef_id);

-- Öğrenci–hedef durumu (takma kimlikli: yalnız profil kimliği; ad yok)
create table public.okuma_ogrenci_hedef_durumu (
  ogrenci_id     uuid not null references public.profiles (id) on delete cascade,
  hedef_id       text not null references public.okuma_ogrenme_hedefleri (id),
  durum          text not null default 'introduced'
    check (durum in ('not_seen', 'introduced', 'recognized', 'retrieved', 'transferred', 'refresh_due')),
  ilk_gorulme_at timestamptz not null default now(),
  son_dogru_at   timestamptz,
  tekrar_at      timestamptz,
  hata_turu      text check (hata_turu in ('hatirlama', 'cikarim', 'yorumlama', 'degerlendirme', 'sozcuk_baglami')),
  primary key (ogrenci_id, hedef_id)
);

-- ---------------------------------------------------------------------
-- 6. Veli değer tercihi (≤5 Maarif değeri)
-- ---------------------------------------------------------------------
create table public.okuma_cocuk_tercihleri (
  cocuk_id             uuid primary key references public.profiles (id) on delete cascade,
  degerler             text[] not null default '{}'
    check (cardinality(degerler) <= 5 and degerler <@ array['D1','D2','D3','D4','D5','D6','D7','D8','D9','D10',
      'D11','D12','D13','D14','D15','D16','D17','D18','D19','D20']),
  guncelleyen_veli_id  uuid references public.profiles (id) on delete set null,
  guncellendi_at       timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 7. Oturumlar, cevaplar, geri bildirim, PDF sayacı (AD KOLONU YOK)
-- ---------------------------------------------------------------------
create table public.okuma_oturumlari (
  id               uuid primary key default gen_random_uuid(),
  ogrenci_id       uuid not null references public.profiles (id) on delete cascade,
  hikaye_id        uuid not null references public.okuma_hikayeleri (id),
  surum_id         uuid not null references public.okuma_hikaye_surumleri (id),
  istemci_anahtari text not null check (istemci_anahtari ~ '^[A-Za-z0-9_-]{8,64}$'),
  kahraman_turu    text not null check (kahraman_turu in
    ('ben', 'anne', 'baba', 'kardes', 'arkadas', 'baska_biri', 'hayvan', 'arac', 'hayali', 'hazir')),
  yoldas_var       boolean not null default false,
  okuma_modu       text not null default 'zengin' check (okuma_modu in ('sade', 'zengin')),
  sinif            smallint,
  gun              date not null,                       -- İstanbul günü
  baslangic_at     timestamptz not null default now(),
  son_sayfa        smallint not null default 0 check (son_sayfa between 0 and 12),
  tamamlandi_at    timestamptz,
  soru_sayisi      smallint not null check (soru_sayisi >= 0),
  dogru_sayisi     smallint not null default 0 check (dogru_sayisi >= 0),
  beceri_sonuclari jsonb not null default '{}'::jsonb,
  dokunulan_hedefler text[] not null default '{}' check (cardinality(dokunulan_hedefler) <= 50),
  kazanilan_xp     integer not null default 0 check (kazanilan_xp between 0 and 30),
  xp_verildi       boolean not null default false,
  ilk_tamamlama    boolean not null default false,
  constraint okuma_oturum_anahtar_uq unique (ogrenci_id, istemci_anahtari)
);
create index okuma_oturum_ogrenci_gun_idx on public.okuma_oturumlari (ogrenci_id, gun);
create index okuma_oturum_ogrenci_zaman_idx on public.okuma_oturumlari (ogrenci_id, baslangic_at desc);
create index okuma_oturum_hikaye_idx on public.okuma_oturumlari (hikaye_id);
create index okuma_oturum_surum_idx on public.okuma_oturumlari (surum_id);
create unique index okuma_oturum_ilk_tamamlama_uidx
  on public.okuma_oturumlari (ogrenci_id, hikaye_id) where ilk_tamamlama;

create table public.okuma_cevaplari (
  oturum_id   uuid not null references public.okuma_oturumlari (id) on delete cascade,
  soru_id     text not null check (soru_id ~ '^s[0-9]+$'),
  secenek_id  text not null check (secenek_id in ('A', 'B', 'C', 'D')),
  dogru       boolean not null,
  beceri      text not null check (beceri in ('hatirlama', 'cikarim', 'yorumlama', 'degerlendirme', 'sozcuk_baglami')),
  hedef_id    text,
  olcme_turu  text check (olcme_turu in ('metin_kaniti', 'kavram_dogrulugu', 'transfer')),
  created_at  timestamptz not null default now(),
  primary key (oturum_id, soru_id)                      -- tek deneme
);

create table public.okuma_geri_bildirimleri (
  oturum_id           uuid primary key references public.okuma_oturumlari (id) on delete cascade,
  yildiz              smallint not null check (yildiz between 1 and 5),
  iyilestirme_kodlari text[] not null default '{}'
    check (cardinality(iyilestirme_kodlari) <= 8 and iyilestirme_kodlari <@ array[
      'daha_kisa', 'daha_uzun', 'daha_komik', 'daha_gizemli', 'daha_kolay', 'daha_zor',
      'daha_cok_macera', 'daha_cok_bilgi']),
  baska_kahraman      boolean not null default false,
  ayni_turden         boolean not null default false,
  sorun_kodlari       text[] not null default '{}'
    check (cardinality(sorun_kodlari) <= 8 and sorun_kodlari <@ array[
      'ad_yanlis_yazilmis', 'anlasilmayan_sozcuk', 'soru_hatali', 'cevap_hatali',
      'cok_zor', 'cok_kolay', 'yazi_hatasi', 'uygunsuz_icerik']),
  created_at          timestamptz not null default now()
);

create table public.okuma_pdf_kullanimlari (
  id           uuid primary key default gen_random_uuid(),
  kullanici_id uuid not null references public.profiles (id) on delete cascade,
  hikaye_id    uuid not null references public.okuma_hikayeleri (id),
  ay           date not null,                           -- İstanbul ayının ilk günü
  created_at   timestamptz not null default now(),
  constraint okuma_pdf_tekil unique (kullanici_id, hikaye_id, ay)
);

-- ---------------------------------------------------------------------
-- 8. RLS: açık; istemci rollerine doğrudan yetki yok. Yalnız is_admin() okuma politikası (atıl).
-- ---------------------------------------------------------------------
do $$
declare
  t text;
begin
  foreach t in array array[
    'okuma_ayarlari', 'okuma_etiket_sozlugu', 'okuma_hikayeleri', 'okuma_hikaye_surumleri',
    'okuma_hikaye_etiketleri', 'okuma_ogrenme_hedefleri', 'okuma_hikaye_hedefleri',
    'okuma_ogrenci_hedef_durumu', 'okuma_cocuk_tercihleri', 'okuma_oturumlari', 'okuma_cevaplari',
    'okuma_geri_bildirimleri', 'okuma_pdf_kullanimlari']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from public, anon, authenticated', t);
    execute format('create policy %I on public.%I for select to authenticated using (public.is_admin())',
                   t || '_admin_select', t);
  end loop;
end $$;

-- ---------------------------------------------------------------------
-- 9. İç yardımcılar (istemciye kapalı)
-- ---------------------------------------------------------------------
create or replace function public._okuma_ayar(p_anahtar text)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select deger from public.okuma_ayarlari where anahtar = p_anahtar;
$$;

create or replace function public._okuma_gun()
returns date
language sql
stable
set search_path = ''
as $$
  select (now() at time zone 'Europe/Istanbul')::date;
$$;

-- Çağıran öğrenci (veya önizleme için admin) değilse 42501.
create or replace function public._okuma_ogrenci()
returns uuid
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null or public.current_user_role() not in ('ogrenci', 'admin') then
    raise exception 'STUDENT_ONLY' using errcode = '42501';
  end if;
  return v_uid;
end;
$$;

-- Erişim: bayrak + pilot sınıf + izinli hesap. onizleme: 'incelemede' hikâyeleri görür.
create or replace function public._okuma_erisim(p_uid uuid)
returns table (erisim boolean, onizleme boolean)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_rol    text;
  v_sinif  smallint;
  v_aktif  boolean := coalesce((public._okuma_ayar('aktif'))::boolean, false);
  v_pilot  jsonb := coalesce(public._okuma_ayar('pilot_siniflari'), '[]'::jsonb);
  v_izinli jsonb := coalesce(public._okuma_ayar('izinli_kullanicilar'), '[]'::jsonb);
  v_onizleme boolean;
begin
  select p.role, p.sinif into v_rol, v_sinif from public.profiles p where p.id = p_uid;
  v_onizleme := v_rol = 'admin' or v_izinli ? p_uid::text;
  erisim := v_onizleme
    or (v_aktif and (jsonb_array_length(v_pilot) = 0 or v_pilot @> to_jsonb(coalesce(v_sinif, 0)::integer)));
  onizleme := v_onizleme;
  return next;
end;
$$;

-- Görünen sürüm: yayında; önizlemeli hesap için varsa en yeni 'incelemede'.
create or replace function public._okuma_gorunen_surum(p_hikaye_id uuid, p_onizleme boolean)
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select s.id
    from public.okuma_hikaye_surumleri s
   where s.hikaye_id = p_hikaye_id
     and (s.durum = 'yayinda' or (p_onizleme and s.durum = 'incelemede'))
   order by (s.durum = 'incelemede') desc, s.surum_no desc
   limit 1;
$$;

-- Ücretsiz kota yalnız premium_gating açık, premium değil ve deneme yoksa uygulanır.
create or replace function public._okuma_kota_sinirli(p_uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select (select g.aktif from public._gating() g)
     and not public.is_premium(p_uid)
     and not public._deneme_aktif(p_uid);
$$;

-- Bugün (İstanbul) başlatılan farklı hikâye sayısı
create or replace function public._okuma_kota_kullanilan(p_uid uuid)
returns integer
language sql
stable
security definer
set search_path = ''
as $$
  select count(distinct o.hikaye_id)::integer
    from public.okuma_oturumlari o
   where o.ogrenci_id = p_uid and o.gun = public._okuma_gun();
$$;

-- Kota doluysa ve bu hikâye bugün zaten başlatılmadıysa KOTA_DOLDU
create or replace function public._okuma_kota_kontrol(p_uid uuid, p_hikaye_id uuid)
returns void
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if public._okuma_kota_sinirli(p_uid)
     and public._okuma_kota_kullanilan(p_uid) >= coalesce((public._okuma_ayar('okuma_gunluk_hikaye'))::integer, 1)
     and not exists (select 1 from public.okuma_oturumlari o
                      where o.ogrenci_id = p_uid and o.gun = public._okuma_gun() and o.hikaye_id = p_hikaye_id)
  then
    raise exception 'KOTA_DOLDU' using errcode = '53400';
  end if;
end;
$$;

revoke execute on function
  public._okuma_surum_koru(), public._okuma_ayar(text), public._okuma_gun(), public._okuma_ogrenci(),
  public._okuma_erisim(uuid), public._okuma_gorunen_surum(uuid, boolean), public._okuma_kota_sinirli(uuid),
  public._okuma_kota_kullanilan(uuid), public._okuma_kota_kontrol(uuid, uuid)
  from public, anon, authenticated;
