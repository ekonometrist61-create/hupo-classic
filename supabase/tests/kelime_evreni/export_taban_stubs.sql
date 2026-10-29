-- GÖR-048: export_my_data gerçek kelime migrasyonlarıyla sınanırken gereken TABAN taklitleri.
-- Kelime tabloları (kelime_denemeleri, kelime_ustaliklari, kelime_kaydedilenler) burada YOK;
-- onlar gerçek migrasyonlardan (20261022000000) gelir. Yalnızca export'un okuduğu diğer tablolar.
-- Gerçek tanımlar: 20260920000000 (profiles), 20260920000700 (xp_events), 20260920000100 (student_stats),
-- consents ve kullanıcı tabloları ilgili migration'larda; burada çağrı sözleşmesi taklit edilir.

alter table public.profiles add column if not exists username text, add column if not exists okul text,
  add column if not exists sosyal_ozellikler_acik boolean, add column if not exists arkadas_ekleme_acik boolean;

create table if not exists public.consents (
  id uuid primary key default gen_random_uuid(),
  cocuk_id uuid, tur text, surum text, created_at timestamptz default now()
);

create table if not exists public.user_answers (student_id uuid, question_id uuid, secilen_sik text, dogru_mu boolean,
  deneme_sayisi integer, dogru_sayisi integer, son_cevap_tarihi timestamptz default now());
create table if not exists public.user_badges (student_id uuid, badge_code text, earned_at timestamptz default now());
create table if not exists public.notifications (alici_id uuid, tur text, baslik text, mesaj text, created_at timestamptz default now());
create table if not exists public.xp_events (student_id uuid, xp integer, created_at timestamptz default now());
