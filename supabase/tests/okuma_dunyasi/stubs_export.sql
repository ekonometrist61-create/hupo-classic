-- export_my_data sınaması için yalnız çağrı sözleşmesini taklit eden tablolar (gerçek tanımlar ilgili migration'larda).
alter table public.consents add column if not exists surum text;
alter table public.profiles add column if not exists username text, add column if not exists okul text,
  add column if not exists sosyal_ozellikler_acik boolean, add column if not exists arkadas_ekleme_acik boolean;
create table public.user_answers (student_id uuid, question_id uuid, secilen_sik text, dogru_mu boolean,
  deneme_sayisi integer, dogru_sayisi integer, son_cevap_tarihi timestamptz default now());
create table public.user_badges (student_id uuid, badge_code text, earned_at timestamptz default now());
create table public.notifications (alici_id uuid, tur text, baslik text, mesaj text, created_at timestamptz default now());
create table public.xp_events (student_id uuid, xp integer, created_at timestamptz default now());
create table public.kelime_denemeleri (ogrenci_id uuid, soru_id uuid, anlam_id uuid, secilen_indeks integer,
  dogru_mu boolean, ipucu_kullanildi boolean, kazanilan_xp integer, created_at timestamptz default now());
create table public.kelime_ustaliklari (ogrenci_id uuid, anlam_id uuid, beceri text, basari_seviyesi integer,
  sonraki_tekrar_tarihi date, son_cevap_tarihi timestamptz, guncellendi timestamptz default now());
create table public.kelime_kaydedilenler (ogrenci_id uuid, anlam_id uuid, created_at timestamptz default now());