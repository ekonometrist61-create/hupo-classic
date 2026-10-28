set client_encoding = 'UTF8';

-- =====================================================================
--  ML eşik sayımı (H-GIE Faz 4, yalnız ölçüm)
--  Ön koşul: 20260920000900_admin_role_and_payments.sql (payments, subscriptions, require_admin)
--
--  BU DOSYA MODEL EĞİTMEZ. Yalnızca etiket sayılarını ve plan eşiklerini döndürür.
--  Eşikler H-GIE planındaki sezgisel önerilerdir (Faz 4); kesin değer değildir.
--  "esik_saglandi" bile olsa model eğitimi ayrı ve insan onaylı bir karardır.
--
--  Model B: 30 günde ücretli dönüşüm   -> ücretli (başarılı ödemesi olan) veli sayısı, eşik 500
--  Model C: iptal riski                -> iptal edilmiş abonelik sahibi veli sayısı (eşik 200)
--                                         ve en az 2 abonelik döngüsü olan veli sayısı (eşik 2)
--  Model D: LTV                        -> ilk başarılı ödemeden bugüne geçen ay (eşik 6)
--
--  GÜVENLİK: SECURITY DEFINER, search_path = '', İLK ifade require_admin().
-- =====================================================================

create or replace function public.admin_growth_ml_esik()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_odeme_veli   bigint;
  v_iptal_veli   bigint;
  v_cok_donem    bigint;
  v_ilk_odeme    timestamptz;
  v_ay           numeric;
begin
  perform public.require_admin();

  select count(distinct p.veli_id) into v_odeme_veli
    from public.payments p
   where p.durum = 'basarili' and p.veli_id is not null;

  select count(distinct s.veli_id) into v_iptal_veli
    from public.subscriptions s
   where s.durum = 'iptal';

  select count(*) into v_cok_donem
    from (select s.veli_id from public.subscriptions s group by s.veli_id having count(*) >= 2) x;

  select min(p.created_at) into v_ilk_odeme
    from public.payments p
   where p.durum = 'basarili';

  v_ay := case when v_ilk_odeme is null then 0
               else round(extract(epoch from (now() - v_ilk_odeme)) / (30.4375 * 86400), 1) end;

  return jsonb_build_object(
    'uretildi', now(),
    'modeller', jsonb_build_array(
      jsonb_build_object(
        'model', 'B', 'ad', '30 günde ücretli dönüşüm',
        'mevcut', v_odeme_veli, 'esik', 500,
        'durum', case when v_odeme_veli >= 500 then 'esik_saglandi' else 'bekliyor' end),
      jsonb_build_object(
        'model', 'C', 'ad', 'Abone iptal riski',
        'mevcut_iptal', v_iptal_veli, 'esik_iptal', 200,
        'yenileme_donemi', v_cok_donem, 'esik_donem', 2,
        'durum', case when v_iptal_veli >= 200 and v_cok_donem >= 2 then 'esik_saglandi' else 'bekliyor' end),
      jsonb_build_object(
        'model', 'D', 'ad', 'Yaşam boyu değer (LTV)',
        'gelir_gecmisi_ay', v_ay, 'esik_ay', 6,
        'durum', case when v_ay >= 6 then 'esik_saglandi' else 'bekliyor' end)
    ),
    'not', 'Eşikler sezgiseldir (H-GIE Faz 4). Eşik sağlansa bile model eğitimi insan onaylı ayrı bir karardır.'
  );
end;
$function$;

revoke execute on function public.admin_growth_ml_esik() from public, anon;
grant  execute on function public.admin_growth_ml_esik() to authenticated, service_role;
