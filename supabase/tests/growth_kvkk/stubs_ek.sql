-- Test harness: 20261106 migration'ının ek bağımlılıkları (yalnız test; gerçek tanımlar ilgili migration'larda).
-- Temel Supabase/Hupolingo taklitleri ../musteri_360/stubs.sql dosyasından gelir.

-- Denetim: gerçek tanım 20260920000900_admin_role_and_payments.sql.
create table if not exists public.admin_audit_log (
  id          uuid primary key default gen_random_uuid(),
  admin_id    uuid references public.profiles (id) on delete set null,
  islem       text not null,
  detay       jsonb not null default '{}'::jsonb,
  created_at  timestamptz not null default clock_timestamp()
);

create or replace function public.log_admin_action(p_islem text, p_detay jsonb default '{}'::jsonb)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.admin_audit_log (admin_id, islem, detay)
  values ((select auth.uid()), p_islem, coalesce(p_detay, '{}'::jsonb));
$$;

-- export_my_data bağımlılıkları (yalnız çağrı sözleşmesi: kolon adları export gövdesiyle birebir).
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
create table if not exists public.kelime_denemeleri (ogrenci_id uuid, soru_id uuid, anlam_id uuid, secilen_indeks integer,
  dogru_mu boolean, ipucu_kullanildi boolean, kazanilan_xp integer, created_at timestamptz default now());
create table if not exists public.kelime_ustaliklari (ogrenci_id uuid, anlam_id uuid, beceri text, basari_seviyesi integer,
  sonraki_tekrar_tarihi timestamptz, son_cevap_tarihi timestamptz, guncellendi timestamptz default now());
create table if not exists public.kelime_kaydedilenler (ogrenci_id uuid, anlam_id uuid, created_at timestamptz default now());

create table if not exists public.okuma_hikayeleri (id uuid primary key default gen_random_uuid(), slug text);
create table if not exists public.okuma_oturumlari (id uuid primary key default gen_random_uuid(), ogrenci_id uuid, hikaye_id uuid,
  kahraman_turu text, yoldas_var boolean, okuma_modu text, sinif smallint, gun int, baslangic_at timestamptz,
  son_sayfa int, tamamlandi_at timestamptz, soru_sayisi int, dogru_sayisi int, beceri_sonuclari jsonb,
  dokunulan_hedefler jsonb, kazanilan_xp int);
create table if not exists public.okuma_cevaplari (oturum_id uuid, soru_id uuid, secenek_id text, dogru boolean,
  beceri text, hedef_id uuid, olcme_turu text, created_at timestamptz default now());
create table if not exists public.okuma_geri_bildirimleri (oturum_id uuid, yildiz int, iyilestirme_kodlari jsonb,
  baska_kahraman boolean, ayni_turden boolean, sorun_kodlari jsonb, created_at timestamptz default now());
create table if not exists public.okuma_ogrenci_hedef_durumu (ogrenci_id uuid, hedef_id uuid, durum text,
  ilk_gorulme_at timestamptz, son_dogru_at timestamptz, tekrar_at timestamptz, hata_turu text);
create table if not exists public.okuma_pdf_kullanimlari (kullanici_id uuid, hikaye_id uuid, ay text, created_at timestamptz default now());
create table if not exists public.okuma_cocuk_tercihleri (cocuk_id uuid primary key, degerler jsonb, guncellendi_at timestamptz);
