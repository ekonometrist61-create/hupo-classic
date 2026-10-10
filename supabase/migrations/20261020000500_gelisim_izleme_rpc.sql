-- Migration: 20261020000500
-- Gelişim izleme RPC'leri (Faz 3)
--   get_my_exam_progress()   → tamamladığım tüm sınavların özet trendi
--   get_my_topic_trends()    → konu bazlı çoklu sınav trendi

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. get_my_exam_progress
--    Authenticated öğrencinin tamamladığı tüm sınavları tarih sırasıyla döner.
--    Döner: [{sinav_id, sinav_ad, tarih, sinif, puan, dogru, yanlis, bos, sira, yuzdelik}]
-- ─────────────────────────────────────────────────────────────────────────────
create or replace function public.get_my_exam_progress()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;

  return coalesce((
    select jsonb_agg(row_data order by (row_data->>'tarih'))
      from (
        select jsonb_build_object(
          'sinav_id',   e.id,
          'sinav_ad',   e.ad,
          'tarih',      e.baslangic_zamani,
          'sinif',      d.sinif,
          'puan',       d.puan,
          'dogru',      d.dogru_sayisi,
          'yanlis',     d.yanlis_sayisi,
          'bos',        d.bos_sayisi,
          'sira', (
            select count(*) + 1
              from public.deneme_sinavi_denemeleri d2
             where d2.exam_id = d.exam_id
               and d2.sinif = d.sinif
               and d2.bitis_zamani is not null
               and d2.puan > d.puan
          ),
          'sinif_katilimci', (
            select count(*)
              from public.deneme_sinavi_denemeleri d3
             where d3.exam_id = d.exam_id
               and d3.sinif = d.sinif
               and d3.bitis_zamani is not null
          ),
          'yuzdelik', (
            select case
              when count(*) = 0 then null
              else round(
                count(*) filter (where puan <= d.puan) * 100.0 / count(*),
                1)
            end
              from public.deneme_sinavi_denemeleri d4
             where d4.exam_id = d.exam_id
               and d4.sinif = d.sinif
               and d4.bitis_zamani is not null
          )
        ) as row_data
          from public.deneme_sinavi_denemeleri d
          join public.deneme_sinavlari e on e.id = d.exam_id
         where d.student_id = v_uid
           and d.bitis_zamani is not null
      ) t
  ), '[]'::jsonb);
end;
$$;

revoke execute on function public.get_my_exam_progress() from public, anon, authenticated, service_role;
grant  execute on function public.get_my_exam_progress() to authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. get_my_topic_trends
--    Authenticated öğrencinin konu bazlı toplam doğru/yanlış/toplam (tüm sınavlar).
--    Döner: [{ders, konu, dogru, yanlis, bos, toplam, oran}]
-- ─────────────────────────────────────────────────────────────────────────────
create or replace function public.get_my_topic_trends()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;

  return coalesce((
    select jsonb_agg(row_data order by row_data->>'ders', row_data->>'konu')
      from (
        select jsonb_build_object(
          'ders',   q.ders,
          'konu',   q.konu,
          'dogru',  count(*) filter (where c.dogru),
          'yanlis', count(*) filter (where not c.dogru and c.secilen_sik is not null),
          'bos',    count(*) filter (where c.secilen_sik is null),
          'toplam', count(*),
          'oran',   case when count(*) > 0
                    then round(count(*) filter (where c.dogru) * 100.0 / count(*), 1)
                    else 0 end
        ) as row_data
          from public.deneme_sinavi_cevaplari c
          join public.deneme_sinavi_denemeleri d on d.id = c.deneme_id
          join public.questions q on q.id = c.question_id
         where d.student_id = v_uid
           and d.bitis_zamani is not null
         group by q.ders, q.konu
      ) t
  ), '[]'::jsonb);
end;
$$;

revoke execute on function public.get_my_topic_trends() from public, anon, authenticated, service_role;
grant  execute on function public.get_my_topic_trends() to authenticated;
