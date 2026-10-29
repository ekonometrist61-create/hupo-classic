set client_encoding = 'UTF8';

-- =====================================================================
--  Toplulaştırılmış öğrenme analitiği (H-GIE Faz 3)
--  Ön koşul: 20261050000000_okuma_dunyasi_tablolar.sql (okuma_oturumlari, okuma_hikayeleri)
--
--  AMAÇ: Sınıf ve hikâye bazında kullanım görünürlüğü. Büyüme (pazarlama) tarafına
--  yalnız bu toplu sayılar gider.
--
--  KAPSAM DIŞI (kesin):
--    * doğruluk, yanlış cevap, beceri, hedef, soru düzeyi      -> ürün modülünde kalır
--    * öğrenci kimliği, hane, çocuk adı, oturum kimliği         -> hiçbir çıktıda yok
--    * kişi bazlı satır                                          -> yok
--
--  KURAL: Her satırda en az 10 farklı öğrenci (esik) bulunmalı; altındaki satır hiç
--  döndürülmez (sayı dahil). Oranlar yalnız eşik üstü satırlarda vardır.
--  Not: Ardışık pencerelerin karşılaştırılmasıyla çıkarım riski, eşik ve pencere
--  sınırıyla sınırlıdır; ayrıntı ML/analitik belgesinde.
--
--  GÜVENLİK: SECURITY DEFINER + set search_path = '' ve İLK ifadesi require_admin().
-- =====================================================================

create or replace function public.admin_ogrenme_toplu(p_gun int default 30)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_gun   int := least(greatest(coalesce(p_gun, 30), 1), 365);
  v_bas   date := (now() at time zone 'Europe/Istanbul')::date - least(greatest(coalesce(p_gun, 30), 1), 365);
  v_esik  int := 10;
begin
  perform public.require_admin();

  return jsonb_build_object(
    'gun', v_gun,
    'esik', v_esik,
    'siniflar', coalesce((
      select jsonb_agg(jsonb_build_object(
               'sinif', s.sinif,
               'ogrenci', s.ogrenci,
               'oturum', s.oturum,
               'tamamlama_orani', round(100.0 * s.tam / s.oturum, 1)
             ) order by s.sinif)
        from (
          select o.sinif,
                 count(distinct o.ogrenci_id)::int as ogrenci,
                 count(*)::int as oturum,
                 count(*) filter (where o.tamamlandi_at is not null)::int as tam
            from public.okuma_oturumlari o
           where o.gun >= v_bas and o.sinif is not null
           group by o.sinif
        ) s
       where s.ogrenci >= v_esik
    ), '[]'::jsonb),
    'hikayeler', coalesce((
      select jsonb_agg(jsonb_build_object(
               'slug', h.slug,
               'ogrenci', s.ogrenci,
               'oturum', s.oturum,
               'tamamlama_orani', round(100.0 * s.tam / s.oturum, 1)
             ) order by s.ogrenci desc, h.slug)
        from (
          select o.hikaye_id,
                 count(distinct o.ogrenci_id)::int as ogrenci,
                 count(*)::int as oturum,
                 count(*) filter (where o.tamamlandi_at is not null)::int as tam
            from public.okuma_oturumlari o
           where o.gun >= v_bas
           group by o.hikaye_id
        ) s
        join public.okuma_hikayeleri h on h.id = s.hikaye_id
       where s.ogrenci >= v_esik
    ), '[]'::jsonb)
  );
end;
$function$;

revoke execute on function public.admin_ogrenme_toplu(int) from public, anon;
grant  execute on function public.admin_ogrenme_toplu(int) to authenticated, service_role;
