set client_encoding = 'UTF8';

-- =====================================================================
--  Growth analitik: huni, UTM atfı, DAU/WAU/MAU ve "aktif öğrenci" düzeltmesi
--  Tarih : 2026-10-27
--  Ön koşul: 20260920000900_admin_role_and_payments.sql  (require_admin, is_admin)
--            20260920000200_parent_dashboard.sql         (answer_events, user_answers -> answer_events trigger'ı)
--            20261014000000_growth_crm_core.sql          (growth_households, growth_events, growth_identity_links)
--            20261028000000_growth_web_olaylari.sql      (UTM ilk temas, ziyaretçi -> hane bağı)
--            20261007000030_anket_otomasyon_analitik_ve_mutabakat.sql (admin_analitik_ozet; bu dosya onu yeniden tanımlar)
--  Opsiyonel: growth_households.activated_at (20261104000000_growth_yasam_dongusu.sql). Yoksa
--             huni "ilk soru" adımı user_answers tabanlı yedekle hesaplanır.
--
--  NE EKLİYOR?
--    yardımcı   : _growth_gizle (n<5 -> null), _growth_yuzde (pay veya payda <5 -> null)
--    huni       : admin_growth_funnel(p_gun)
--    UTM atfı   : admin_growth_utm_atif(p_gun)
--    aktiflik   : admin_growth_aktiflik(p_gun)           DAU / WAU / MAU + günlük seri
--    düzeltme   : admin_analitik_ozet(p_gun)              aktif_7_gun, doğruluk, tekrar: p_gun penceresi
--                                                         imza ve dönüş şekli aynen korunur
--
--  KARARLAR
--    * Aktiflik ve "aktif öğrenci" answer_events'ten sayılır. Bu tablo user_answers'a
--      AFTER INSERT/UPDATE trigger'ı ile her cevabı zaman damgasıyla yazar. user_answers yalnızca
--      her soru için SON cevap zamanını tutar; günlük aktifliği eksik sayardı.
--      Takvim günü Europe/Istanbul'a göre hesaplanır. XP / streak (student_stats) kullanılmaz.
--    * Huni adımları birbirinin alt kümesi değildir; her adım kendi ölçütüyle sayılır.
--      Yüzde hem önceki adıma (onceki_yuzde) hem kayıtlara (kayit_yuzde) göre verilir.
--    * Gizlilik: 5'in altındaki her sayı null döner. Bir yüzde, pay veya payda 5'in altındaysa null.
--      UTM'de 5'ten az ziyaretçisi olan kampanyalar "(diğer)" satırında toplanır.
--    * UTM ilk temas: ziyaretçinin en eski UTM'li olayı (kimlik bağlama RPC'siyle aynı kural).
--      Ziyaretçi, ilk temas penceredeyse kohorta girer; kayıt ve ücretli sayıları bu ziyaretçilere bağlıdır.
--
--  GÜVENLİK
--    * Her public fonksiyon SECURITY DEFINER + set search_path = '' ve İLK ifadesi public.require_admin().
--    * Yardımcılar yalnızca bu dosyadaki fonksiyonlardan çağrılır; anon ve authenticated çalıştıramaz.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. YARDIMCILAR (gizlilik eşiği)
-- ---------------------------------------------------------------------

-- 5'in altındaki sayı null (gizli). Null girişi null döner.
create or replace function public._growth_gizle(p_n bigint)
returns int
language sql
immutable
set search_path = ''
as $$
  select case when p_n is null or p_n < 5 then null else p_n::int end
$$;

-- Yüzde: pay veya payda 5'in altındaysa null (küçük hücre pay üzerinden çözülmesin).
create or replace function public._growth_yuzde(p_pay bigint, p_payda bigint)
returns numeric
language sql
immutable
set search_path = ''
as $$
  select case
           when p_pay is null or p_payda is null or p_pay < 5 or p_payda < 5 then null
           else round(100.0 * p_pay / p_payda, 1)
         end
$$;

revoke execute on function public._growth_gizle(bigint)            from public, anon, authenticated;
revoke execute on function public._growth_yuzde(bigint, bigint)    from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 1. HUNİ
-- ---------------------------------------------------------------------

-- Kohort: p_gun penceresinde kayıt olan haneler (growth_households.created_at).
-- Adımlar: kayit -> cocuk_bagli -> ilk_soru -> deneme_basladi -> ucretli; ayrıca churn (ayrıldı).
-- ilk_soru: growth_households.activated_at (W2) varsa o; yoksa çocuğun user_answers kaydı.
create or replace function public.admin_growth_funnel(p_gun int default 30)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_gun      int := least(greatest(coalesce(p_gun, 30), 1), 365);
  v_bas      timestamptz := now() - make_interval(days => least(greatest(coalesce(p_gun, 30), 1), 365));
  v_act      boolean;
  v_kayit    int;
  v_cocuk    int;
  v_ilk      int;
  v_deneme   int;
  v_ucretli  int;
  v_churn    int;
begin
  perform public.require_admin();

  select exists (
    select 1 from information_schema.columns
     where table_schema = 'public' and table_name = 'growth_households' and column_name = 'activated_at'
  ) into v_act;

  select count(*)::int,
         count(*) filter (where h.core_parent_user_id is not null and exists (
           select 1 from public.profiles c where c.parent_id = h.core_parent_user_id))::int,
         count(*) filter (where h.trial_started_at is not null)::int,
         count(*) filter (where h.core_parent_user_id is not null and exists (
           select 1 from public.payments pa
            where pa.veli_id = h.core_parent_user_id and pa.durum = 'basarili'))::int,
         count(*) filter (where h.lifecycle = 'churned')::int
    into v_kayit, v_cocuk, v_deneme, v_ucretli, v_churn
    from public.growth_households h
   where h.created_at >= v_bas;

  -- Kolon varlığına göre dal. Kolon yoksa bu dal hiç çalışmaz (plpgsql ifadeleri ilk çalışmada planlanır).
  if v_act then
    select count(*) filter (where h.activated_at is not null)::int
      into v_ilk
      from public.growth_households h
     where h.created_at >= v_bas;
  else
    select count(*) filter (where h.core_parent_user_id is not null and exists (
             select 1 from public.profiles c
               join public.user_answers ua on ua.student_id = c.id
              where c.parent_id = h.core_parent_user_id))::int
      into v_ilk
      from public.growth_households h
     where h.created_at >= v_bas;
  end if;

  return jsonb_build_object(
    'gun', v_gun,
    'esik', 5,
    'ilk_soru_kaynagi', case when v_act then 'activated_at' else 'user_answers' end,
    'adimlar', jsonb_build_array(
      jsonb_build_object('adim', 'kayit',
        'sayi', public._growth_gizle(v_kayit),
        'onceki_yuzde', null,
        'kayit_yuzde', public._growth_yuzde(v_kayit, v_kayit)),
      jsonb_build_object('adim', 'cocuk_bagli',
        'sayi', public._growth_gizle(v_cocuk),
        'onceki_yuzde', public._growth_yuzde(v_cocuk, v_kayit),
        'kayit_yuzde', public._growth_yuzde(v_cocuk, v_kayit)),
      jsonb_build_object('adim', 'ilk_soru',
        'sayi', public._growth_gizle(v_ilk),
        'onceki_yuzde', public._growth_yuzde(v_ilk, v_cocuk),
        'kayit_yuzde', public._growth_yuzde(v_ilk, v_kayit)),
      jsonb_build_object('adim', 'deneme_basladi',
        'sayi', public._growth_gizle(v_deneme),
        'onceki_yuzde', public._growth_yuzde(v_deneme, v_ilk),
        'kayit_yuzde', public._growth_yuzde(v_deneme, v_kayit)),
      jsonb_build_object('adim', 'ucretli',
        'sayi', public._growth_gizle(v_ucretli),
        'onceki_yuzde', public._growth_yuzde(v_ucretli, v_deneme),
        'kayit_yuzde', public._growth_yuzde(v_ucretli, v_kayit))
    ),
    'churn', jsonb_build_object(
      'sayi', public._growth_gizle(v_churn),
      'kayit_yuzde', public._growth_yuzde(v_churn, v_kayit))
  );
end;
$function$;

-- ---------------------------------------------------------------------
-- 2. UTM ATFI (ziyaretçi -> kayıt -> ücretli)
-- ---------------------------------------------------------------------

-- Kohort: p_gun penceresinde ilk UTM teması olan anonim ziyaretçiler.
-- Kayıt: ziyaretçinin growth_identity_links ile bağlı haneleri (tekil).
-- Ücretli: bu haneler için durumu 'basarili' olan en az bir ödeme (payments.veli_id = core_parent_user_id).
-- 5'ten az ziyaretçili kampanyalar "(diğer)" satırında toplanır; sayılar 5'in altındaysa null.
create or replace function public.admin_growth_utm_atif(p_gun int default 30)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_gun    int := least(greatest(coalesce(p_gun, 30), 1), 365);
  v_bas    timestamptz := now() - make_interval(days => least(greatest(coalesce(p_gun, 30), 1), 365));
  v_sonuc  jsonb;
begin
  perform public.require_admin();

  with ilk as (
    select distinct on (ge.anonymous_id)
           ge.anonymous_id, ge.utm, ge.occurred_at
      from public.growth_events ge
     where ge.anonymous_id is not null
       and ge.utm is not null
     order by ge.anonymous_id, ge.occurred_at, ge.id
  ),
  zn as (
    select i.anonymous_id,
           coalesce(nullif(i.utm ->> 'utm_source', ''),   '(belirsiz)') as kanal,
           coalesce(nullif(i.utm ->> 'utm_medium', ''),   '(belirsiz)') as ortam,
           coalesce(nullif(i.utm ->> 'utm_campaign', ''), '(belirsiz)') as kampanya
      from ilk i
     where i.occurred_at >= v_bas
  ),
  baglanan as (
    select distinct z.kanal, z.ortam, z.kampanya, il.household_id
      from zn z
      join public.growth_identity_links il on il.anonymous_id = z.anonymous_id
  ),
  odeme as (
    select h.id as household_id,
           exists (
             select 1 from public.payments pa
              where pa.veli_id = h.core_parent_user_id and pa.durum = 'basarili'
           ) as ucretli
      from public.growth_households h
     where h.id in (select b.household_id from baglanan b)
  ),
  grup as (
    select z.kanal, z.ortam, z.kampanya, count(*)::bigint as ziyaretci
      from zn z
     group by z.kanal, z.ortam, z.kampanya
  ),
  bgrup as (
    select b.kanal, b.ortam, b.kampanya,
           count(distinct b.household_id)::bigint as kayit,
           count(distinct b.household_id) filter (where o.ucretli)::bigint as ucretli
      from baglanan b
      left join odeme o on o.household_id = b.household_id
     group by b.kanal, b.ortam, b.kampanya
  ),
  satir as (
    select g.kanal, g.ortam, g.kampanya, g.ziyaretci,
           coalesce(b.kayit, 0) as kayit,
           coalesce(b.ucretli, 0) as ucretli
      from grup g
      left join bgrup b using (kanal, ortam, kampanya)
  ),
  nihai as (
    select s.kanal, s.ortam, s.kampanya, s.ziyaretci, s.kayit, s.ucretli, false as diger
      from satir s
     where s.ziyaretci >= 5
    union all
    select '(diğer)', '', '',
           sum(s.ziyaretci)::bigint, sum(s.kayit)::bigint, sum(s.ucretli)::bigint, true
      from satir s
     where s.ziyaretci < 5
     having count(*) > 0
  )
  select jsonb_build_object(
    'gun', v_gun,
    'esik', 5,
    'toplam', jsonb_build_object(
      'ziyaretci', public._growth_gizle((select count(*) from zn)),
      'kayit', public._growth_gizle((select count(distinct b.household_id) from baglanan b)),
      'ucretli', public._growth_gizle((
        select count(distinct b.household_id)
          from baglanan b
          join odeme o on o.household_id = b.household_id
         where o.ucretli))
    ),
    'satirlar', coalesce((
      select jsonb_agg(jsonb_build_object(
               'kanal', n.kanal,
               'ortam', nullif(n.ortam, ''),
               'kampanya', nullif(n.kampanya, ''),
               'diger', n.diger,
               'ziyaretci', public._growth_gizle(n.ziyaretci),
               'kayit', public._growth_gizle(n.kayit),
               'ucretli', public._growth_gizle(n.ucretli),
               'kayit_yuzde', public._growth_yuzde(n.kayit, n.ziyaretci),
               'ucretli_yuzde', public._growth_yuzde(n.ucretli, n.kayit))
             order by n.ziyaretci desc, n.kanal, n.kampanya)
        from nihai n
    ), '[]'::jsonb)
  )
    into v_sonuc;

  return v_sonuc;
end;
$function$;

-- ---------------------------------------------------------------------
-- 3. AKTİFLİK (DAU / WAU / MAU, benzersiz öğrenci)
-- ---------------------------------------------------------------------

-- Kaynak: answer_events (her cevabın zaman damgalı kaydı). Gün sınırı Europe/Istanbul.
-- dau: bugün; wau: son 7 takvim günü; mau: son 30 takvim günü.
-- seri: son p_gun gün için günlük benzersiz öğrenci sayısı (eski -> yeni).
create or replace function public.admin_growth_aktiflik(p_gun int default 30)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_gun        int := least(greatest(coalesce(p_gun, 30), 1), 365);
  v_bugun      date := (now() at time zone 'Europe/Istanbul')::date;
  v_bugun_bas  timestamptz := (date_trunc('day', now() at time zone 'Europe/Istanbul')) at time zone 'Europe/Istanbul';
  v_dau        int;
  v_wau        int;
  v_mau        int;
  v_seri       jsonb;
begin
  perform public.require_admin();

  select count(distinct ae.student_id) filter (where ae.created_at >= v_bugun_bas)::int,
         count(distinct ae.student_id) filter (where ae.created_at >= v_bugun_bas - interval '6 days')::int,
         count(distinct ae.student_id)::int
    into v_dau, v_wau, v_mau
    from public.answer_events ae
   where ae.created_at >= v_bugun_bas - interval '29 days';

  select coalesce(jsonb_agg(jsonb_build_object('gun', to_char(g.gun, 'YYYY-MM-DD'), 'aktif', coalesce(x.n, 0))
                            order by g.gun), '[]'::jsonb)
    into v_seri
    from (
      select (v_bugun - s.k) as gun
        from generate_series(0, v_gun - 1) as s(k)
    ) g
    left join (
      select (ae.created_at at time zone 'Europe/Istanbul')::date as gun,
             count(distinct ae.student_id)::int as n
        from public.answer_events ae
       where ae.created_at >= v_bugun_bas - make_interval(days => v_gun - 1)
       group by 1
    ) x on x.gun = g.gun;

  return jsonb_build_object(
    'gun', v_gun,
    'bugun', to_char(v_bugun, 'YYYY-MM-DD'),
    'dau', v_dau,
    'wau', v_wau,
    'mau', v_mau,
    'yapismazlik_yuzde', case when v_mau > 0 then round(100.0 * v_dau / v_mau, 1) end,
    'seri', v_seri
  );
end;
$function$;

-- ---------------------------------------------------------------------
-- 4. ANALİTİK ÖZETİ: "aktif öğrenci" ve pencere düzeltmesi (imza ve dönüş şekli aynı)
--    aktif_7_gun : student_stats.last_active_date (XP/streak) yerine answer_events, son 7 takvim günü
--    dogruluk_yuzde : answer_events, p_gun penceresi (önceden tüm zamanın user_answers toplamıydı)
--    tekrar_zamani_gelen : son cevabı p_gun penceresinde olan ve tekrar zamanı gelmiş kayıtlar
-- ---------------------------------------------------------------------
create or replace function public.admin_analitik_ozet(p_gun integer default 30)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_gun      integer := least(greatest(coalesce(p_gun, 30), 1), 365);
  v_bas      timestamptz;
  v_bugun_bas timestamptz := (date_trunc('day', now() at time zone 'Europe/Istanbul')) at time zone 'Europe/Istanbul';
  v_kayit    integer;
  v_cocuk    integer;
  v_ogrenme  integer;
  v_ucretli  integer;
  v_kohort   jsonb;
  v_ogr      integer;
  v_aktif7   integer;
  v_dogruluk numeric;
  v_tekrar   integer;
begin
  perform public.require_admin();
  v_bas := now() - make_interval(days => v_gun);

  with c as (
    select p.id
      from public.profiles p
     where p.role = 'veli' and p.created_at >= v_bas
  )
  select (select count(*) from c)::integer,
         (select count(*) from c where exists (select 1 from public.profiles k where k.parent_id = c.id))::integer,
         (select count(*) from c where exists (
            select 1 from public.profiles k join public.user_answers ua on ua.student_id = k.id
             where k.parent_id = c.id))::integer,
         (select count(*) from c where exists (
            select 1 from public.payments pa where pa.veli_id = c.id and pa.durum = 'basarili'))::integer
    into v_kayit, v_cocuk, v_ogrenme, v_ucretli;

  with hafta as (
    select date_trunc('week', now()) - make_interval(weeks => i) as bas
      from generate_series(0, 4) as i
  ),
  kohort as (
    select h.bas, p.id as ogr
      from hafta h
      join public.profiles p
        on p.role = 'ogrenci' and p.created_at >= h.bas and p.created_at < h.bas + interval '7 days'
  ),
  boyut as (
    select h.bas, count(k.ogr) as n
      from hafta h left join kohort k on k.bas = h.bas
     group by h.bas
  ),
  hucre as (
    select b.bas, g.k,
           case
             when b.n = 0 or b.bas + make_interval(weeks => g.k) > now() then null
             else round(100.0 * (
                    select count(distinct ua.student_id)
                      from public.answer_events ua
                      join kohort ko on ko.ogr = ua.student_id and ko.bas = b.bas
                     where ua.created_at >= b.bas + make_interval(weeks => g.k)
                       and ua.created_at <  b.bas + make_interval(weeks => g.k + 1)
                  ) / b.n)
           end as pct
      from boyut b cross join generate_series(0, 4) as g(k)
  )
  select coalesce(jsonb_agg(jsonb_build_object(
           'hafta', to_char(b.bas, 'DD.MM'), 'boyut', b.n,
           'tutma', (select jsonb_agg(hu.pct order by hu.k) from hucre hu where hu.bas = b.bas)
         ) order by b.bas), '[]'::jsonb)
    into v_kohort
    from boyut b;

  select count(*)::integer into v_ogr from public.profiles where role = 'ogrenci';

  select count(distinct ae.student_id)::integer into v_aktif7
    from public.answer_events ae
   where ae.created_at >= v_bugun_bas - interval '6 days';

  select round(100.0 * count(*) filter (where ae.dogru_mu) / nullif(count(*), 0), 1) into v_dogruluk
    from public.answer_events ae
   where ae.created_at >= v_bas;

  select count(*)::integer into v_tekrar
    from public.user_answers ua
   where ua.sonraki_tekrar_tarihi <= now()
     and ua.son_cevap_tarihi >= v_bas;

  return jsonb_build_object(
    'gun', v_gun,
    'huni', jsonb_build_object('kayit', v_kayit, 'cocuk_bagladi', v_cocuk,
                               'ilk_ogrenme', v_ogrenme, 'ucretli', v_ucretli),
    'kohort', v_kohort,
    'ogrenme', jsonb_build_object(
      'ogrenci', v_ogr, 'aktif_7_gun', v_aktif7, 'dogruluk_yuzde', v_dogruluk,
      'tekrar_zamani_gelen', v_tekrar)
  );
end;
$function$;

-- ---------------------------------------------------------------------
-- 5. REVOKE / GRANT
-- ---------------------------------------------------------------------
revoke execute on function public.admin_growth_funnel(int)        from public, anon;
revoke execute on function public.admin_growth_utm_atif(int)      from public, anon;
revoke execute on function public.admin_growth_aktiflik(int)      from public, anon;
revoke execute on function public.admin_analitik_ozet(integer)    from public, anon;

grant execute on function public.admin_growth_funnel(int)         to authenticated;
grant execute on function public.admin_growth_utm_atif(int)       to authenticated;
grant execute on function public.admin_growth_aktiflik(int)       to authenticated;
grant execute on function public.admin_analitik_ozet(integer)     to authenticated;
