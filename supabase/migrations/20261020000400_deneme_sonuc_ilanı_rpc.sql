-- Migration: 20261020000400
-- Deneme sınavı sonuç ilanı RPC'leri
--   get_exam_public_results(p_exam_id)  → herkese açık istatistik + kendi sonucu
--   get_exam_topic_breakdown(p_exam_id) → konu kırılımı (auth + premium)

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. get_exam_public_results
--    Herkese açık (anon + authenticated).
--    Döner:
--      sinav        : {id, ad, baslangic_zamani}
--      siniflar     : [{sinif, katilimci, ortalama, puan_dagilimi:[{aralik,sayi}]}]
--      en_iyi_sinif : [{sinif, puan, isim_kisa}] — anonim, ilk 3
--      kendi        : null | {puan, sira, sinif_katilimci, yuzdelik, sinif}
-- ─────────────────────────────────────────────────────────────────────────────
create or replace function public.get_exam_public_results(p_exam_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid    uuid := (select auth.uid());
  v_sinav  jsonb;
  v_siniflar jsonb;
  v_kendi  jsonb := null;
begin
  -- Sınav başlığı
  select jsonb_build_object('id', id, 'ad', ad, 'baslangic_zamani', baslangic_zamani)
    into v_sinav
    from public.deneme_sinavlari
   where id = p_exam_id;

  if not found then
    raise exception 'Sınav bulunamadı' using errcode = 'P0002';
  end if;

  -- Sınıf bazlı istatistikler + puan dağılımı
  select coalesce(jsonb_agg(sinif_row order by (sinif_row->>'sinif')::int), '[]')
    into v_siniflar
    from (
      select jsonb_build_object(
        'sinif', sinif,
        'katilimci', count(*),
        'ortalama', round(avg(puan)::numeric, 1),
        'en_yuksek', max(puan),
        'en_dusuk', min(puan),
        'puan_dagilimi', (
          select coalesce(jsonb_agg(d order by (d->>'aralik_baslangic')::int), '[]')
            from (
              select jsonb_build_object(
                'aralik_baslangic', band * 10,
                'aralik_bitis',     band * 10 + 9,
                'sayi', count(*)
              ) as d
                from (
                  select floor(puan2 / 10)::int as band
                    from (
                      select puan as puan2
                        from public.deneme_sinavi_denemeleri d2
                       where d2.exam_id = p_exam_id
                         and d2.sinif = outer_q.sinif
                         and d2.bitis_zamani is not null
                    ) sub
                ) bands
               group by band
            ) dist_rows
        )
      ) as sinif_row
        from public.deneme_sinavi_denemeleri outer_q
       where exam_id = p_exam_id
         and bitis_zamani is not null
       group by sinif
    ) sinif_agg;

  -- Kendi sonucu (authenticated ise)
  if v_uid is not null then
    select jsonb_build_object(
      'puan',           d.puan,
      'dogru_sayisi',   d.dogru_sayisi,
      'yanlis_sayisi',  d.yanlis_sayisi,
      'bos_sayisi',     d.bos_sayisi,
      'sinif',          d.sinif,
      'sinif_katilimci', (
        select count(*) from public.deneme_sinavi_denemeleri
         where exam_id = p_exam_id and sinif = d.sinif and bitis_zamani is not null
      ),
      'sira', (
        select count(*) + 1 from public.deneme_sinavi_denemeleri
         where exam_id = p_exam_id and sinif = d.sinif
           and bitis_zamani is not null and puan > d.puan
      ),
      'yuzdelik', case
        when (select count(*) from public.deneme_sinavi_denemeleri
               where exam_id = p_exam_id and sinif = d.sinif and bitis_zamani is not null) = 0
        then null
        else round(
          (select count(*) from public.deneme_sinavi_denemeleri
            where exam_id = p_exam_id and sinif = d.sinif
              and bitis_zamani is not null and puan <= d.puan)
          * 100.0 /
          (select count(*) from public.deneme_sinavi_denemeleri
            where exam_id = p_exam_id and sinif = d.sinif and bitis_zamani is not null),
          1)
      end
    ) into v_kendi
      from public.deneme_sinavi_denemeleri d
     where d.exam_id = p_exam_id and d.student_id = v_uid;
  end if;

  return jsonb_build_object(
    'sinav',    v_sinav,
    'siniflar', v_siniflar,
    'kendi',    v_kendi
  );
end;
$$;

revoke execute on function public.get_exam_public_results(uuid) from public, anon, authenticated, service_role;
grant  execute on function public.get_exam_public_results(uuid) to anon;
grant  execute on function public.get_exam_public_results(uuid) to authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. get_exam_topic_breakdown
--    Authenticated + premium kullanıcıya konu bazlı doğru/yanlış/toplam.
--    Döner: [{ders, konu, dogru, yanlis, toplam, oran}]
-- ─────────────────────────────────────────────────────────────────────────────
create or replace function public.get_exam_topic_breakdown(p_exam_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_deneme_id uuid;
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;

  if not public.is_premium(v_uid) then
    raise exception 'Bu özellik premium abonelere açıktır' using errcode = '42501';
  end if;

  select id into v_deneme_id
    from public.deneme_sinavi_denemeleri
   where exam_id = p_exam_id and student_id = v_uid and bitis_zamani is not null;

  if not found then
    raise exception 'Bu sınava ait tamamlanmış deneme bulunamadı' using errcode = 'P0002';
  end if;

  return coalesce((
    select jsonb_agg(row_data order by row_data->>'ders', row_data->>'konu')
      from (
        select jsonb_build_object(
          'ders',    q.ders,
          'konu',    q.konu,
          'dogru',   count(*) filter (where c.dogru),
          'yanlis',  count(*) filter (where not c.dogru and c.secilen_sik is not null),
          'bos',     count(*) filter (where c.secilen_sik is null),
          'toplam',  count(*),
          'oran',    case when count(*) > 0
                    then round(count(*) filter (where c.dogru) * 100.0 / count(*), 1)
                    else 0 end
        ) as row_data
          from public.deneme_sinavi_cevaplari c
          join public.questions q on q.id = c.question_id
         where c.deneme_id = v_deneme_id
         group by q.ders, q.konu
      ) t
  ), '[]'::jsonb);
end;
$$;

revoke execute on function public.get_exam_topic_breakdown(uuid) from public, anon, authenticated, service_role;
grant  execute on function public.get_exam_topic_breakdown(uuid) to authenticated;
