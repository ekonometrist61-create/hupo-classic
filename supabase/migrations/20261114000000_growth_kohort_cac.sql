set client_encoding = 'UTF8';

-- =====================================================================
--  Growth kohort (D1/D7/D30 elde tutma) ve CAC (H-GIE Faz 1)
--  Ön koşul: 20261105000000_growth_analitik_huni.sql  (_growth_gizle, _growth_yuzde)
--            20261104000000_growth_yasam_dongusu.sql  (growth_hane_aktif_gunleri)
--            20261113000000_growth_harcama.sql        (growth_harcama)
--
--  KARARLAR
--    * Kohort: "kayıtlı hane" = lifecycle visitor/lead DIŞINDA olan hane.
--      Lead varsayılan başlangıç aşamasıdır; kayıt olmamış aday kohorta girmez.
--    * Kohort günü: hanenin created_at değerinin Europe/Istanbul takvim günü (kg).
--    * D_N: hane, kg + N gününde en az bir aktif gün (growth_hane_aktif_gunleri) kaydetti mi.
--      Klasik tanım: tam N. gün; "N ve sonrası" değil.
--    * Olgunluk: kg + N gününden önce bugün değilse hane o N için paydaya girmez.
--      Yani D30, 30 günü dolmamış hanelerle hesaplanmaz.
--    * Gizlilik: 5'in altındaki her sayı null; oran için pay veya payda 5'in altındaysa null.
--    * CAC = para birimi başına harcama / kayıtlı hane sayısı (pencere içinde).
--      Para birimleri ayrı; TRY ve USD birbirine çevrilmez.
--      KANAL BAZLI CAC YOK: hane kanal atfı (UTM) harcama kanalı ile eşleşmiyor.
--      Yalnız toplam CAC hesaplanır.
--
--  GÜVENLİK
--    * Her public fonksiyon SECURITY DEFINER + set search_path = '' ve İLK ifadesi require_admin().
--    * Yardımcı yalnızca bu dosyadaki fonksiyonlardan çağrılır; anon ve authenticated çalıştıramaz.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. YARDIMCI: kayıtlı hane tanımı
-- ---------------------------------------------------------------------
create or replace function public._growth_kayitli_hane(p_lifecycle public.growth_lifecycle_stage)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select p_lifecycle not in ('visitor', 'lead')
$$;

revoke execute on function public._growth_kayitli_hane(public.growth_lifecycle_stage) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 1. KOHORT: D1 / D7 / D30 (özet ve haftalık)
--    Tek sorgu: haftalık sayımlar bir kez hesaplanır; özet bu satırların toplamıdır.
-- ---------------------------------------------------------------------
create or replace function public.admin_growth_kohort(p_gun int default 90)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_gun      int := least(greatest(coalesce(p_gun, 90), 1), 365);
  v_bugun    date := (now() at time zone 'Europe/Istanbul')::date;
  v_haftalik jsonb;
  u1 bigint; t1 bigint;
  u7 bigint; t7 bigint;
  u30 bigint; t30 bigint;
begin
  perform public.require_admin();

  with k as (
    select h.id,
           (h.created_at at time zone 'Europe/Istanbul')::date as kg
      from public.growth_households h
     where h.created_at >= now() - make_interval(days => v_gun)
       and public._growth_kayitli_hane(h.lifecycle)
  ),
  s as (
    select k.id, k.kg,
           (k.kg + 1  <= v_bugun) as m1,
           (k.kg + 7  <= v_bugun) as m7,
           (k.kg + 30 <= v_bugun) as m30,
           exists (select 1 from public.growth_hane_aktif_gunleri a
                    where a.household_id = k.id and a.gun = k.kg + 1)  as r1,
           exists (select 1 from public.growth_hane_aktif_gunleri a
                    where a.household_id = k.id and a.gun = k.kg + 7)  as r7,
           exists (select 1 from public.growth_hane_aktif_gunleri a
                    where a.household_id = k.id and a.gun = k.kg + 30) as r30
      from k
  ),
  w as (
    select date_trunc('week', s.kg)::date as hafta,
           count(*) as boyut,
           count(*) filter (where s.m1)  as u1,
           count(*) filter (where s.m1 and s.r1)  as t1,
           count(*) filter (where s.m7)  as u7,
           count(*) filter (where s.m7 and s.r7)  as t7,
           count(*) filter (where s.m30) as u30,
           count(*) filter (where s.m30 and s.r30) as t30
      from s
     group by 1
  )
  select coalesce((select jsonb_agg(jsonb_build_object(
                     'hafta', w.hafta,
                     'boyut', public._growth_gizle(w.boyut),
                     'd1_oran', public._growth_yuzde(w.t1, w.u1),
                     'd7_oran', public._growth_yuzde(w.t7, w.u7),
                     'd30_oran', public._growth_yuzde(w.t30, w.u30)
                   ) order by w.hafta) from w), '[]'::jsonb),
         coalesce((select sum(w.u1)  from w), 0), coalesce((select sum(w.t1)  from w), 0),
         coalesce((select sum(w.u7)  from w), 0), coalesce((select sum(w.t7)  from w), 0),
         coalesce((select sum(w.u30) from w), 0), coalesce((select sum(w.t30) from w), 0)
    into v_haftalik, u1, t1, u7, t7, u30, t30;

  return jsonb_build_object(
    'gun', v_gun,
    'bugun', v_bugun,
    'ozet', jsonb_build_array(
      jsonb_build_object('gun', 1,  'uygun_hane', public._growth_gizle(u1),  'tutulan', public._growth_gizle(t1),  'oran', public._growth_yuzde(t1,  u1)),
      jsonb_build_object('gun', 7,  'uygun_hane', public._growth_gizle(u7),  'tutulan', public._growth_gizle(t7),  'oran', public._growth_yuzde(t7,  u7)),
      jsonb_build_object('gun', 30, 'uygun_hane', public._growth_gizle(u30), 'tutulan', public._growth_gizle(t30), 'oran', public._growth_yuzde(t30, u30))
    ),
    'haftalik', v_haftalik
  );
end;
$function$;

-- ---------------------------------------------------------------------
-- 2. CAC: para birimi başına toplam harcama / kayıtlı hane
-- ---------------------------------------------------------------------
create or replace function public.admin_growth_cac(p_gun int default 90)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_gun      int := least(greatest(coalesce(p_gun, 90), 1), 365);
  v_bugun    date := (now() at time zone 'Europe/Istanbul')::date;
  v_n        bigint;
  v_satirlar jsonb;
begin
  perform public.require_admin();

  select count(*) into v_n
    from public.growth_households h
   where h.created_at >= now() - make_interval(days => v_gun)
     and public._growth_kayitli_hane(h.lifecycle);

  select coalesce(jsonb_agg(jsonb_build_object(
           'para_birimi', x.para_birimi,
           'harcama', x.harcama,
           'yeni_hane', public._growth_gizle(v_n),
           'cac', case when public._growth_gizle(v_n) is null then null
                       else round(x.harcama / v_n, 2) end,
           'durum', case when public._growth_gizle(v_n) is null then 'veri_az' else 'hesaplandi' end
         ) order by x.para_birimi), '[]'::jsonb)
    into v_satirlar
    from (
      select h.para_birimi, sum(h.tutar) as harcama
        from public.growth_harcama h
       where h.tarih >= v_bugun - v_gun
         and h.tarih <= v_bugun
       group by h.para_birimi
    ) x;

  return jsonb_build_object(
    'gun', v_gun,
    'yeni_hane', public._growth_gizle(v_n),
    'satirlar', v_satirlar,
    'durum', case when jsonb_array_length(v_satirlar) = 0 then 'harcama_yok' else 'ok' end
  );
end;
$function$;

revoke execute on function public.admin_growth_kohort(int) from public, anon;
revoke execute on function public.admin_growth_cac(int)    from public, anon;
grant  execute on function public.admin_growth_kohort(int) to authenticated, service_role;
grant  execute on function public.admin_growth_cac(int)    to authenticated, service_role;
