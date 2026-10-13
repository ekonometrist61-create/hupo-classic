-- =====================================================================
-- Deneme sinavi: admin sonuc listesine supheli bayragi
--
-- admin_get_mock_exam_results RETURNS TABLE'a supheli (boolean) eklenir.
-- Kaynak: deneme_sinavi_denemeleri.supheli (20261020000700).
--
-- Not: RETURNS TABLE kolon seti degistigi icin CREATE OR REPLACE yetmez
-- (Postgres "cannot change return type" hatasi verir). Bu yuzden once DROP,
-- sonra ayni govde + yeni kolon ve yetki satirlari yeniden kurulur.
-- =====================================================================

set client_encoding = 'UTF8';

drop function if exists public.admin_get_mock_exam_results(uuid);

create function public.admin_get_mock_exam_results(p_exam_id uuid)
returns table (
  student_id uuid,
  ad_soyad text,
  sinif smallint,
  puan numeric,
  dogru_sayisi smallint,
  yanlis_sayisi smallint,
  bos_sayisi smallint,
  sira bigint,
  bitis_zamani timestamptz,
  supheli boolean
)
language plpgsql
security definer
set search_path to ''
as $function$
begin
  perform public.require_admin();

  return query
    select
      d.student_id,
      coalesce(p.full_name, ''),
      d.sinif,
      d.puan,
      d.dogru_sayisi,
      d.yanlis_sayisi,
      d.bos_sayisi,
      rank() over (partition by d.sinif order by d.puan desc, d.bitis_zamani asc),
      d.bitis_zamani,
      d.supheli
    from public.deneme_sinavi_denemeleri d
    join public.profiles p on p.id = d.student_id
   where d.exam_id = p_exam_id and d.bitis_zamani is not null
   order by d.sinif, d.puan desc, d.bitis_zamani asc;
end;
$function$;

comment on function public.admin_get_mock_exam_results(uuid) is
  'Bitmis denemeleri sinif ici siralamayla doner (sira: puan desc, bitis zamani asc). supheli: anti-hile bayragi.';

revoke execute on function public.admin_get_mock_exam_results(uuid) from public, anon;
grant  execute on function public.admin_get_mock_exam_results(uuid) to authenticated;
