set client_encoding = 'UTF8';

-- =====================================================================
--  Growth yaşam döngüsü: aktivasyon, lifecycle kuralları, sağlık ve churn skoru
--  Tarih : 2026-11-04 (W2, docs/growth-crm/TAMAMLAMA_PLANI_2026-10-27.md)
--  Ön koşul: 20260920000000 (user_answers, subscriptions)
--            20261014000000 (growth_* tablolar, enum'lar, skor kolonları)
--            20261016000000 (parent_link_codes)
--            20261027000000 (_growth_olay_yaz, growth_musteri_no_seq)
--
--  NE EKLİYOR?
--   1. growth_households.activated_at, growth_households.health_score.
--   2. growth_hane_aktif_gunleri: hanenin cevap verdiği takvim günleri (hane, gün).
--      Cevap içeriği, soru veya çocuk adı TUTULMAZ.
--   3. user_answers AFTER INSERT: çocuğun İLK cevabı → activated_at (bir kez),
--      lifecycle 'activated' (yalnız önceki değer registered/lead/trial ise),
--      olay 'ilk_soru_cozuldu' (bir kez). AFTER UPDATE: yalnız aktif gün kaydı.
--      submit_answer gövdesi DEĞİŞTİRİLMEDİ; tetikleyiciler üzerinden çalışır.
--   4. parent_link_codes AFTER INSERT → 'eslestirme_kodu_uretildi' (kod değeri yazılmaz).
--   5. subscriptions.durum → 'iptal' → 'abonelik_iptal'. payload.iptal_nedeni:
--      çekirdek abonelikte neden alanı yok, bu yüzden null (ileride eklenirse okunur).
--   6. growth_yasam_dongusu_hesapla(): saatlik sweep (pg_cron varsa). Lifecycle + skorlar.
--      Yalnız service_role / postgres çalıştırabilir.
--
--  LIFECYCLE KURALLARI (sweep; öncelik sırasıyla)
--   a. Aktif ücretli abonelik varsa → paid (geri alınmış churned/at_risk/winback dahil)
--   b. Abonelik süresi dolmuş, yenilenmemiş (aktif abonelik ve beklemede yok) ve
--      lifecycle trial/activated/engaged/paid/at_risk/winback → churned
--   c. activated, son 14 günde ≥3 farklı aktif gün → engaged
--   d. activated/engaged, son aktif günden ≥14 gün → at_risk
--   e. at_risk, son 1 günde (dün veya bugün) aktivite → winback
--   f. winback, son 14 günde ≥3 aktif gün → engaged; ≥14 gün sessiz → at_risk
--   g. paid: engagement kuralları UYGULANMAZ (paid geri çevrilmez; ayrılma yalnız
--      abonelik bitişiyle olur). Bu, 20261027 _growth_abonelik_esle sırasıyla çelişmez.
--   Kayıt/ziyaretçi/deneme aşamaları bu sweep'te değişmez (deneme bitişi (b) ile churned olur).
--
--  SKOR FORMÜLLERİ (0-100, kural tabanlı, LLM yok)
--   Tanımlar (Türkiye günü, UTC+3):
--     a14 = son 14 gün (bugün dahil) içindeki farklı aktif gün sayısı
--     d_son = bugün - son aktif gün (hiç aktivite yoksa null)
--     d_kayit = bugün - hane kayıt günü
--   health_score = min(100, etkinlik + tazelik + abonelik)
--     etkinlik : min(a14, 7) * 50 / 7                     (0-50)
--     tazelik  : d_son <= 1 → 25; <= 6 → 15; <= 13 → 5; aksi 0 (aktivite yoksa 0)  (0-25)
--     abonelik : aktif ücretli → 25; aktif deneme → 10; yok → 0                  (0-25)
--   churn_score  = lifecycle churned ise 100; değilse min(100, hareketsizlik + deneme + hic_cevap)
--     hareketsizlik : (d_son yoksa d_kayit) >= 14 → 50; >= 7 → 30; >= 3 → 10   (0-50)
--     deneme        : aktif deneme 3 gün içinde bitiyor → 20                     (0-20)
--     hic_cevap     : hiç aktif gün yok ve kayıttan >= 7 gün → 20                (0-20)
--
--  GÜVENLİK
--   * Tüm fonksiyonlar SECURITY DEFINER + set search_path = ''; gövdedeki nesneler public. ile nitelenir.
--   * Yeni tablo RLS açık, politika yok; PUBLIC / anon / authenticated revoke.
--   * Sweep ve tetikleyici fonksiyonları PUBLIC / anon / authenticated'a kapalı.
--   * Yeni bayrak yok: sweep yalnız iç veriyi günceller, dışarıya mesaj göndermez.
--   * Olay payload'larında PII yok (e-posta, ad, kod yazılmaz).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Kolonlar ve indeks
-- ---------------------------------------------------------------------
alter table public.growth_households
  add column if not exists activated_at timestamptz,
  add column if not exists health_score int not null default 0 check (health_score between 0 and 100);

-- Tetikleyici ve sweep, hane'yi core_parent_user_id ile arar; indeks yoktu.
create index if not exists growth_households_core_parent_idx
  on public.growth_households (core_parent_user_id)
  where core_parent_user_id is not null;

-- ---------------------------------------------------------------------
-- 2. Hane aktif günleri (yalnız hane + takvim günü)
-- ---------------------------------------------------------------------
create table if not exists public.growth_hane_aktif_gunleri (
  household_id uuid not null references public.growth_households (id) on delete cascade,
  gun          date not null,
  primary key (household_id, gun)
);
alter table public.growth_hane_aktif_gunleri enable row level security;
revoke all on table public.growth_hane_aktif_gunleri from public, anon, authenticated;

-- Türkiye takvim günü: UTC+3 sabit ofset (Türkiye 2016'dan beri yaz saati uygulamaz).
create or replace function public._growth_gun(p_an timestamptz)
returns date
language sql
immutable
set search_path = ''
as $f$
  select ((p_an at time zone 'UTC') + interval '3 hours')::date;
$f$;

create or replace function public._growth_bugun()
returns date
language sql
stable
set search_path = ''
as $f$
  select public._growth_gun(now());
$f$;

-- ---------------------------------------------------------------------
-- 3. İç yardımcılar (istemciye kapalı)
-- ---------------------------------------------------------------------

-- Çocuk → veli → hane. Çocuk profili veli'ye bağlı değilse null.
create or replace function public._growth_ogrenci_hanesi(p_ogrenci uuid)
returns uuid
language sql
stable
security definer
set search_path = ''
as $f$
  select h.id
    from public.profiles p
    join public.growth_households h on h.core_parent_user_id = p.parent_id
   where p.id = p_ogrenci
     and p.role = 'ogrenci'
     and p.parent_id is not null
   order by h.created_at, h.id
   limit 1;
$f$;

create or replace function public._growth_aktif_gun_yaz(p_hane uuid)
returns void
language sql
security definer
set search_path = ''
as $f$
  insert into public.growth_hane_aktif_gunleri (household_id, gun)
  select p_hane, public._growth_bugun()
   where p_hane is not null
  on conflict (household_id, gun) do nothing;
$f$;

-- İlk cevap: bir kez. activated_at boşken çalışır; ikinci cevap olay üretmez.
-- Lifecycle yalnız registered / lead / trial'den activated'a çevrilir; paid vb. geri çevrilmez.
create or replace function public._growth_ilk_cevap_isle(p_hane uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $f$
begin
  update public.growth_households h set
    activated_at = now(),
    lifecycle = case when h.lifecycle in ('registered', 'lead', 'trial') then 'activated'
                     else h.lifecycle end
   where h.id = p_hane
     and h.activated_at is null;

  if found then
    perform public._growth_olay_yaz(p_hane, 'ilk_soru_cozuldu', '{}'::jsonb);
  end if;
end;
$f$;

-- ---------------------------------------------------------------------
-- 4. Tetikleyici fonksiyonları (hata asıl işlemi bozmaz; 20261027 kalıbı)
-- ---------------------------------------------------------------------

create or replace function public._growth_tetik_cevap_ilk()
returns trigger
language plpgsql
security definer
set search_path = ''
as $f$
declare
  v_hane uuid;
begin
  begin
    v_hane := public._growth_ogrenci_hanesi(new.student_id);
    if v_hane is null then
      return null;
    end if;
    perform public._growth_aktif_gun_yaz(v_hane);
    perform public._growth_ilk_cevap_isle(v_hane);
  exception when others then
    raise warning 'growth ilk cevap senkron: %', sqlerrm;
  end;
  return null;
end;
$f$;

create or replace function public._growth_tetik_cevap_guncelle()
returns trigger
language plpgsql
security definer
set search_path = ''
as $f$
begin
  begin
    perform public._growth_aktif_gun_yaz(public._growth_ogrenci_hanesi(new.student_id));
  exception when others then
    raise warning 'growth cevap gun senkron: %', sqlerrm;
  end;
  return null;
end;
$f$;

create or replace function public._growth_tetik_abonelik_iptal()
returns trigger
language plpgsql
security definer
set search_path = ''
as $f$
declare
  v_hane uuid;
begin
  begin
    select h.id into v_hane
      from public.growth_households h
     where h.core_parent_user_id = new.veli_id
     order by h.created_at, h.id
     limit 1;
    -- Çekirdek subscriptions tablosunda iptal nedeni alanı yok; null yazılır.
    perform public._growth_olay_yaz(v_hane, 'abonelik_iptal',
      jsonb_build_object('iptal_nedeni', null::text, 'plan_kod', new.plan_kod));
  exception when others then
    raise warning 'growth abonelik iptal senkron: %', sqlerrm;
  end;
  return null;
end;
$f$;

create or replace function public._growth_tetik_eslestirme_kodu()
returns trigger
language plpgsql
security definer
set search_path = ''
as $f$
declare
  v_hane uuid;
begin
  begin
    select h.id into v_hane
      from public.growth_households h
     where h.core_parent_user_id = new.veli_id
     order by h.created_at, h.id
     limit 1;
    -- Kod değeri olaya yazılmaz (gizli bilgi).
    perform public._growth_olay_yaz(v_hane, 'eslestirme_kodu_uretildi', '{}'::jsonb);
  exception when others then
    raise warning 'growth eslestirme kodu senkron: %', sqlerrm;
  end;
  return null;
end;
$f$;

drop trigger if exists growth_cevap_ilk on public.user_answers;
create trigger growth_cevap_ilk
  after insert on public.user_answers
  for each row execute function public._growth_tetik_cevap_ilk();

drop trigger if exists growth_cevap_guncelle on public.user_answers;
create trigger growth_cevap_guncelle
  after update on public.user_answers
  for each row execute function public._growth_tetik_cevap_guncelle();

drop trigger if exists growth_abonelik_iptal on public.subscriptions;
create trigger growth_abonelik_iptal
  after update of durum on public.subscriptions
  for each row when (old.durum is distinct from new.durum and new.durum = 'iptal')
  execute function public._growth_tetik_abonelik_iptal();

drop trigger if exists growth_eslestirme_kodu on public.parent_link_codes;
create trigger growth_eslestirme_kodu
  after insert on public.parent_link_codes
  for each row execute function public._growth_tetik_eslestirme_kodu();

-- ---------------------------------------------------------------------
-- 5. Yaşam döngüsü sweep'i (saatlik; service_role / postgres)
--    Tüm hanelerin lifecycle ve skorlarını yeniden hesaplar. Değişmeyen satıra yazmaz.
--    Döner: {bugun, guncellenen, gecis}
-- ---------------------------------------------------------------------
create or replace function public.growth_yasam_dongusu_hesapla()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $f$
declare
  v_bugun        date := public._growth_bugun();
  v_guncellenen  int;
  v_gecis        int;
begin
  with abn as (
    -- Abonelik özeti (hane başına). Tüm değerler abonelik tablosundan türetilir.
    select h.id as hane,
           coalesce(bool_or(sb.durum = 'aktif' and sb.bitis > now() and pl.fiyat_kurus > 0), false) as paid_aktif,
           coalesce(bool_or(sb.durum = 'aktif' and sb.bitis > now() and pl.fiyat_kurus = 0), false) as deneme_aktif,
           coalesce(bool_or(sb.durum = 'aktif' and sb.bitis > now() and pl.fiyat_kurus = 0
                            and sb.bitis <= now() + interval '3 days'), false) as deneme_bitiyor,
           coalesce(bool_or(sb.durum = 'beklemede'), false) as bekleyen,
           coalesce(bool_or(sb.durum = 'suresi_doldu' or (sb.durum = 'aktif' and sb.bitis <= now())), false) as suresi_dolmus
      from public.growth_households h
      left join public.subscriptions sb on sb.veli_id = h.core_parent_user_id
      left join public.plans pl on pl.kod = sb.plan_kod
     group by h.id
  ),
  aktivite as (
    select a.household_id as hane,
           count(*) filter (where a.gun >= v_bugun - 13)::int as a14,
           max(a.gun) as son_gun
      from public.growth_hane_aktif_gunleri a
     group by a.household_id
  ),
  m as (
    select h.id as hane,
           h.lifecycle as eski,
           h.created_at,
           coalesce(ak.a14, 0) as a14,
           ak.son_gun,
           coalesce(ab.paid_aktif, false) as paid_aktif,
           coalesce(ab.deneme_aktif, false) as deneme_aktif,
           coalesce(ab.deneme_bitiyor, false) as deneme_bitiyor,
           (coalesce(ab.suresi_dolmus, false) and not coalesce(ab.bekleyen, false)
              and not coalesce(ab.paid_aktif, false) and not coalesce(ab.deneme_aktif, false)) as sub_bitti
      from public.growth_households h
      left join aktivite ak on ak.hane = h.id
      left join abn ab on ab.hane = h.id
  ),
  d as (
    select m.*,
           (v_bugun - m.son_gun) as d_son,
           (v_bugun - public._growth_gun(m.created_at)) as d_kayit
      from m
  ),
  y as (
    select d.*,
           (case
              when d.paid_aktif then 'paid'
              when d.sub_bitti and d.eski in ('trial', 'activated', 'engaged', 'paid', 'at_risk', 'winback') then 'churned'
              when d.eski = 'activated' and d.a14 >= 3 then 'engaged'
              when d.eski in ('activated', 'engaged') and d.d_son >= 14 then 'at_risk'
              when d.eski = 'at_risk' and d.d_son <= 1 then 'winback'
              when d.eski = 'winback' and d.a14 >= 3 then 'engaged'
              when d.eski = 'winback' and d.d_son >= 14 then 'at_risk'
              else d.eski::text
            end)::public.growth_lifecycle_stage as yeni
      from d
  ),
  z as (
    select y.hane, y.eski, y.yeni, y.sub_bitti,
           least(100, round(
             least(y.a14, 7) * 50.0 / 7
             + case when y.d_son is null then 0
                    when y.d_son <= 1 then 25
                    when y.d_son <= 6 then 15
                    when y.d_son <= 13 then 5
                    else 0 end
             + case when y.paid_aktif then 25
                    when y.deneme_aktif then 10
                    else 0 end
           ))::int as saglik,
           (case when y.yeni = 'churned' then 100
                 else least(100,
                   case when coalesce(y.d_son, y.d_kayit) >= 14 then 50
                        when coalesce(y.d_son, y.d_kayit) >= 7 then 30
                        when coalesce(y.d_son, y.d_kayit) >= 3 then 10
                        else 0 end
                   + case when y.deneme_bitiyor then 20 else 0 end
                   + case when y.d_son is null and y.d_kayit >= 7 then 20 else 0 end)
            end)::int as churn
      from y
  ),
  upd as (
    update public.growth_households h
       set lifecycle = z.yeni,
           health_score = z.saglik,
           churn_score = z.churn
      from z
     where h.id = z.hane
       and (h.lifecycle is distinct from z.yeni
            or h.health_score is distinct from z.saglik
            or h.churn_score is distinct from z.churn)
    returning z.hane, z.eski, z.yeni, z.sub_bitti
  ),
  olay as (
    insert into public.growth_events (household_id, event_name, source, properties)
    select u.hane, 'yasam_asamasi_degisti', 'server',
           jsonb_build_object(
             'onceki', u.eski,
             'yeni', u.yeni,
             'neden', case when u.yeni = 'churned' and u.sub_bitti then 'abonelik_suresi_doldu'
                           when u.yeni = 'paid' then 'abonelik_aktif'
                           else 'etkinlik' end)
      from upd u
     where u.eski is distinct from u.yeni
    returning 1
  )
  select count(*)::int, (select count(*)::int from olay)
    into v_guncellenen, v_gecis
    from upd;

  return jsonb_build_object('bugun', v_bugun, 'guncellenen', v_guncellenen, 'gecis', v_gecis);
end;
$f$;

-- ---------------------------------------------------------------------
-- 6. Yetkiler
-- ---------------------------------------------------------------------
revoke execute on function
  public._growth_gun(timestamptz),
  public._growth_bugun(),
  public._growth_ogrenci_hanesi(uuid),
  public._growth_aktif_gun_yaz(uuid),
  public._growth_ilk_cevap_isle(uuid),
  public._growth_tetik_cevap_ilk(),
  public._growth_tetik_cevap_guncelle(),
  public._growth_tetik_abonelik_iptal(),
  public._growth_tetik_eslestirme_kodu()
  from public, anon, authenticated;

revoke execute on function public.growth_yasam_dongusu_hesapla() from public, anon, authenticated;
grant  execute on function public.growth_yasam_dongusu_hesapla() to service_role;

-- ---------------------------------------------------------------------
-- 7. Zamanlayıcı: saatlik. pg_cron yoksa atlanır (hatasız); eklenti kurulu ortamda iş kurulur.
-- ---------------------------------------------------------------------
do $cron$
begin
  if exists (select 1 from pg_available_extensions where name = 'pg_cron') then
    execute 'create extension if not exists pg_cron with schema pg_catalog';
    if not exists (select 1 from cron.job where jobname = 'growth-yasam-dongusu-hesapla') then
      perform cron.schedule('growth-yasam-dongusu-hesapla', '0 * * * *',
                            'select public.growth_yasam_dongusu_hesapla()');
    end if;
  else
    raise notice 'pg_cron kullanilamiyor: growth-yasam-dongusu-hesapla zamanlayicisi atlandi';
  end if;
end;
$cron$;
