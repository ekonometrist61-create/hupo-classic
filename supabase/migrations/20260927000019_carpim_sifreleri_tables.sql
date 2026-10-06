-- =====================================================================
--  Çarpım Tablosu Şifreleri — tablolar ve kısıtlar
--  Canlı Supabase'ten (ccozfrpnvyrnktpffkwo) birebir kurtarılmıştır.
--  Tarih: 2026-09-27
--
--  KAYNAK: pg_catalog (information_schema.columns, pg_constraint)
--  Bu migration, 20260927000010_carpim_sifreleri_rpc.sql'den ÖNCE çalışmalıdır
--  (RPC'ler bu tablolara referans verir).
-- =====================================================================
-- ---------------------------------------------------------------------
-- 1) carpim_sifreleri — şifre tanımları (içerik)
-- ---------------------------------------------------------------------
create table if not exists public.carpim_sifreleri (
  id uuid primary key default gen_random_uuid(),
  sira integer not null,
  anahtar text not null,
  isim text not null,
  ikon text not null,
  renk text not null,
  kapsam text not null,
  kesif text not null,
  tanim text not null,
  formul text not null,
  ornek jsonb not null,
  alistirma jsonb not null,
  test jsonb not null,
  created_at timestamptz not null default now(),
  -- Her şifrenin anahtarı ve sırası benzersiz (2'ler, 3'ler...)
  constraint carpim_sifreleri_anahtar_key unique (anahtar),
  constraint carpim_sifreleri_sira_key unique (sira),
  -- Tema rengi #RRGGBB biçiminde
  constraint carpim_sifreleri_renk_format check (renk ~ '^#[0-9A-Fa-f]{6}$'),
  -- Örnek, hem 'soru' hem 'adimlar' alanlarını içermeli
  constraint carpim_sifreleri_ornek_sekli check (
    ornek ? 'soru'
    and ornek ? 'adimlar'
  ),
  -- Alıştırma 2-5 soruluk dizi
  constraint carpim_sifreleri_alistirma_dizi check (
    jsonb_typeof(alistirma) = 'array'
    and jsonb_array_length(alistirma) between 2 and 5
  ),
  -- Kapalı test 2-5 soruluk dizi
  constraint carpim_sifreleri_test_dizi check (
    jsonb_typeof(test) = 'array'
    and jsonb_array_length(test) between 2 and 5
  )
);
comment on table public.carpim_sifreleri is 'Çarpım tablosu şifreleri. Her satır bir çarpım tablosudur (2''ler, 3''ler, ...).';
comment on column public.carpim_sifreleri.anahtar is 'Kısa tanımlayıcı anahtar (ornek: 2ler, 3ler, 5ler, karisik).';
comment on column public.carpim_sifreleri.kapsam is 'Bu şifrenin kapsadığı çarpım ifadeleri, insan dilinde.';
comment on column public.carpim_sifreleri.kesif is 'Kilitli test geçilmeden önce gösterilen keşif ipucu metni.';
comment on column public.carpim_sifreleri.ornek is 'JSON: {soru, adimlar[]}. Çözümün adım adım anlatımı.';
comment on column public.carpim_sifreleri.alistirma is 'JSON: [{soru, cevap, cozum[]}] — açık alıştırma soruları.';
comment on column public.carpim_sifreleri.test is 'JSON: [{soru, cevap, cozum[]}] — kapalı test soruları. CEVAP İSTEMCİYE GÖNDERİLMEZ.';
-- ---------------------------------------------------------------------
-- 2) carpim_ilerleme — öğrencinin şifre ilerlemesi
-- ---------------------------------------------------------------------
create table if not exists public.carpim_ilerleme (
  user_id uuid not null references public.profiles(id) on delete cascade,
  sifre_id uuid not null references public.carpim_sifreleri(id) on delete cascade,
  acik_bitti boolean not null default false,
  kapali_bitti boolean not null default false,
  kapali_yildiz integer not null default 0,
  kapali_ilk_denemede_doldu boolean not null default false,
  ogretti boolean not null default false,
  updated_at timestamptz not null default now(),
  constraint carpim_ilerleme_pkey primary key (user_id, sifre_id),
  constraint carpim_ilerleme_kapali_yildiz_check check (kapali_yildiz >= 0)
);
comment on table public.carpim_ilerleme is 'Öğrencinin çarpım şifresi ilerlemesi. Yıldız yalnızca KAPALI TESTTE ilk doğru cevapla kazanılır.';
comment on column public.carpim_ilerleme.kapali_ilk_denemede_doldu is 'Tüm kapalı test soruları ilk denemede doğru cevaplandıysa true. Tam rozet bunu kontrol eder.';
-- ---------------------------------------------------------------------
-- 3) carpim_deneme_log — her sorunun ilk denemesi (yıldız koruması)
-- ---------------------------------------------------------------------
create table if not exists public.carpim_deneme_log (
  user_id uuid not null references public.profiles(id) on delete cascade,
  sifre_id uuid not null references public.carpim_sifreleri(id) on delete cascade,
  asama text not null,
  soru_index integer not null,
  ilk_sonuc boolean not null,
  created_at timestamptz not null default now(),
  constraint carpim_deneme_log_pkey primary key (user_id, sifre_id, asama, soru_index),
  constraint carpim_deneme_log_asama_check check (asama in ('acik', 'kapali')),
  constraint carpim_deneme_log_soru_index_check check (soru_index >= 0)
);
comment on table public.carpim_deneme_log is 'Her (öğrenci, şifre, aşama, soru) için İLK deneme sonucu. Tekrar denemeler burada ezilmez; yıldız yalnızca ilk doğruda verilir.';
-- ---------------------------------------------------------------------
-- 4) RLS
--    carpim_* tabloları doğrudan istemciye AÇIK DEĞİLDİR: tüm erişim
--    SECURITY DEFINER RPC'ler üzerinden yapılır (bkz. 20260927000010).
-- ---------------------------------------------------------------------
alter table public.carpim_sifreleri enable row level security;
alter table public.carpim_ilerleme enable row level security;
alter table public.carpim_deneme_log enable row level security;
-- Bu tabloların doğrudan SELECT/INSERT/UPDATE/DELETE politikası YOKTUR.
-- RPC'ler (security definer + search_path to '') aracılığıyla erişilir.
-- Öğrenci kendi verisini yalnızca RPC üzerinden okur/yazar.
-- ---------------------------------------------------------------------
-- 5) Yardımcı indexler
-- ---------------------------------------------------------------------
-- Şifre listesini sıra numarasına göre almak için
create index if not exists carpim_sifreleri_sira_idx on public.carpim_sifreleri (sira);
-- "Bir şifreyi tamamladım mı?" sorgusunu hızlandırır
create index if not exists carpim_ilerleme_kapali_bitti_idx on public.carpim_ilerleme (user_id)
where kapali_bitti = true;
create index if not exists carpim_ilerleme_ogretti_idx on public.carpim_ilerleme (user_id)
where ogretti = true;
-- Yönetici: günlük soru havuzlarını listeler
create index if not exists daily_challenges_gun_anahtar_idx on public.daily_challenges (gun, anahtar);
-- Yönetici: açık bildirimleri sürebilir
create index if not exists question_reports_durum_idx on public.question_reports (durum, created_at desc);
-- Öğrenci: rozetlerini hızlıca okusun
create index if not exists user_badges_student_idx on public.user_badges (student_id);