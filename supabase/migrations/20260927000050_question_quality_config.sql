-- =====================================================================
--  KURTARMA: public.question_quality_config (tek satırlık ayar tablosu)
--  Proje : ccozfrpnvyrnktpffkwo — Öğrenci Hazırlık / Hupo
--  Tarih : 2026-09-27
--
--  DURUM: ⚠️ KISMİ KURTARMA — kolonlar canlıdaki koddan çıkarıldı, tam
--  tablo tanımı (kısıt/index/ek kolon) henüz canlıdan ALINMADI.
--  TODO(kurtarma): `supabase db pull` sonrası bu dosyayı canlı tanımla
--  birebir karşılaştır ve farkı düzelt (bkz. supabase/KURTARMA_DURUMU.md §4.1).
--
--  KAYNAK (canlı fonksiyon gövdesi, TAHMİN YOK):
--    kurtarilan/cikti-bagimlilik.csv:31 — _refresh_question_flag gövdesi:
--      select rapor_esigi, otomatik_gizle into v_cfg
--        from public.question_quality_config where id;
--      v_aktif := v_n >= coalesce(v_cfg.rapor_esigi, 3);
--      ... coalesce(v_cfg.otomatik_gizle, false) ...
--
--  KANIT ÇIKARIMI (üç kolon, hepsi gövdeden):
--    * `where id`  → id boolean bir koşul (PostgreSQL boolean bekler)
--                    ⇒ tek satırlık ayar tablosunun klasik deseni
--    * rapor_esigi  integer (v_n integer ile karşılaştırılıyor)
--    * otomatik_gizle boolean (boolean bağlamında kullanılıyor)
--
--  NEDEN GEREKLİ:
--    _refresh_question_flag() bu tabloyu OKUR; tablo yoksa
--    report_question(...) çağrısı hata verir.
--
--  GÜVENLİK: Tablo yalnızca SECURITY DEFINER fonksiyonlar tarafından okunur.
--  İstemciye hiçbir yetki verilmez (fail-closed, 20260927000030 ile aynı desen).
-- =====================================================================

create table if not exists public.question_quality_config (
  id             boolean primary key default true,
  rapor_esigi    integer not null default 3,
  otomatik_gizle boolean not null default false,

  -- Tek satır kuralı: id yalnızca true olabilir ⇒ yalnızca bir ayar satırı
  constraint question_quality_config_tek_satir check (id)
);

comment on table public.question_quality_config is
  'Soru kalite eşikleri (tek satır). _refresh_question_flag() buradan eşikleri okur.';
comment on column public.question_quality_config.id is
  'Tek satır kuralı için boolean anahtar; yalnızca true kabul edilir.';
comment on column public.question_quality_config.rapor_esigi is
  'Aynı soruyu kaç FARKLI kişi bildirirse soru incelemeye düşer (varsayılan 3).';
comment on column public.question_quality_config.otomatik_gizle is
  'Eşik aşıldığında onaylı soru otomatik "beklemede"ye çekilsin mi (varsayılan kapalı).';

-- Varsayılan satır: değerler fonksiyonun kendi yedek değerleriyle aynıdır
-- (coalesce(rapor_esigi, 3) ve coalesce(otomatik_gizle, false)), böylece satır
-- silinse/boş kalsa da davranış değişmez. Canlıdaki gerçek değerler §4.1 ile
-- doğrulanana kadar en güvenli (fail-closed) değerler kullanılır.
insert into public.question_quality_config (id)
values (true)
on conflict (id) do nothing;

-- RLS + yetkiler: yalnızca SECURITY DEFINER fonksiyonlar erişebilir
alter table public.question_quality_config enable row level security;

revoke all on public.question_quality_config from anon;
revoke all on public.question_quality_config from authenticated;
