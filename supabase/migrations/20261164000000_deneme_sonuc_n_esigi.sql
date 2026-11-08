-- Migration: 20261164000000
-- GÖR-095 karar (1): get_exam_public_results için n >= 5 eşiği.
--   Bir sınıfta 5'ten az tamamlanmış deneme varsa o sınıfın istatistiği (ortalama,
--   en yüksek/düşük, puan dağılımı, katılımcı sayısı) herkese açık dönüşe girmez.
--   Böylece n=1–4 sınıfta tek bir öğrencinin puanı açığa çıkmaz.
--   Giriş yapmış öğrencinin KENDİ puanı her zaman döner. Ancak küçük sınıfta
--   kendi sıra/yüzdelik/katılımcı alanları null olur: sıra, başkasının puanını
--   dolaylı olarak açıklar (n=2'de "2. / 2" diğer öğrencinin daha yüksek olduğunu söyler).
--   Yayın bayrağı eklenmedi (ürün kararı gerektirir).
--   Dayanak: 20261020000400 (önceki tanım). Yalnız get_exam_public_results değişir;
--   get_exam_topic_breakdown dokunulmadı.

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

  -- Sınıf bazlı istatistikler + puan dağılımı (yalnız n >= 5 olan sınıflar)
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
      having count(*) >= 5
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

    -- Küçük sınıfta sıralama ve yüzdelik, başkalarının puanını açıklar: gizle
    if v_kendi is not null and (v_kendi->>'sinif_katilimci')::int < 5 then
      v_kendi := v_kendi || jsonb_build_object(
        'sira', null,
        'yuzdelik', null,
        'sinif_katilimci', null
      );
    end if;
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
