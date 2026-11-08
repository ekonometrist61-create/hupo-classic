-- export_my_data sınaması için yalnız çağrı sözleşmesini taklit eden tablolar (gerçek tanımlar ilgili migration'larda).
alter table public.consents add column if not exists surum text;
alter table public.profiles add column if not exists username text, add column if not exists okul text,
  add column if not exists sosyal_ozellikler_acik boolean, add column if not exists arkadas_ekleme_acik boolean;
create table public.user_answers (student_id uuid, question_id uuid, secilen_sik text, dogru_mu boolean,
  deneme_sayisi integer, dogru_sayisi integer, son_cevap_tarihi timestamptz default now());
create table public.user_badges (student_id uuid, badge_code text, earned_at timestamptz default now());
create table public.notifications (alici_id uuid, tur text, baslik text, mesaj text, created_at timestamptz default now());
create table public.xp_events (student_id uuid, xp integer, created_at timestamptz default now());
-- Kelime tabloları (kelime_denemeleri, kelime_ustaliklari, kelime_kaydedilenler) burada TAKLİT EDİLMEZ:
-- gerçek tanımlar kos.mjs içinde 20261022000000 / 20261023000000 migrasyonlarından gelir (GÖR-048).
-- GÖR-048: export_my_data son tanımı (20261106 growth bölümü) yalnız bu tabloları okur; çağrı sözleşmesi taklidi.
-- (Gerçek tanımlar 20261014000000_growth_crm_core.sql içindedir; son tanım bu kolonlarla sınanır.)
create table public.growth_households (
  id uuid primary key default gen_random_uuid(), core_parent_user_id uuid, merged_into uuid,
  created_at timestamptz not null default now(), customer_no text, lifecycle text, plan text, subscription_status text);
create table public.growth_events (household_id uuid, event_name text, source text, occurred_at timestamptz default now());
create table public.growth_consent_bridge (household_id uuid, channel text, granted boolean, source text, changed_at timestamptz default now());
create table public.growth_message_log (household_id uuid, channel text, status text);
