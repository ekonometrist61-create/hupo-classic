-- =====================================================================
-- Admin: karakter kataloğu (salt okunur)
--   * 40 karakterin tanımı + kaç öğrencinin kazandığı
--   * Web-panel ekranı bu dalgada YOK (ayrı oturumun web-panel/src
--     üzerinde eşzamanlı çalışması nedeniyle dosya çakışmasından kaçınıldı);
--     RPC hazır, admin ekranı ayrı bir işte eklenecek (docs/mobil-yeniden-
--     tasarim/PLAN.md §5 senkron matrisi).
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function public.admin_list_characters()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.require_admin();

  return coalesce((
    select jsonb_agg(row_to_json(t) order by t.sinif_sira, t.karakter_sira)
      from (
        select cd.kod,
               cd.ad,
               cd.sinif,
               cd.sinif_sira,
               cd.karakter_sira,
               cd.kosul_turu,
               cd.kosul_deger,
               count(uc.student_id)::integer as kazanan_sayisi
          from public.character_definitions cd
          left join public.user_characters uc on uc.karakter_kod = cd.kod
         group by cd.kod, cd.ad, cd.sinif, cd.sinif_sira, cd.karakter_sira,
                  cd.kosul_turu, cd.kosul_deger
      ) t
  ), '[]'::jsonb);
end;
$$;

revoke execute on function public.admin_list_characters() from public, anon;
grant  execute on function public.admin_list_characters() to authenticated;
