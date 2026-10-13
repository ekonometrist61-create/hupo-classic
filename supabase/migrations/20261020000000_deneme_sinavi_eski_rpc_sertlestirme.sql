-- =====================================================================
-- Eski öğrenci deneme RPC'lerinin sertleştirilmesi (mobil istemci imzası korunur)
--   start_mock_exam(uuid)        : sınav saati gelmeden başlatılamaz; süre dolunca açılmaz
--   submit_mock_exam(uuid,jsonb) : yalnızca bu sınavın soruları sayılır (puan şişirme yok);
--                                  süre + 30 sn tolerans sonrası cevap kabul edilmez
--
-- BİLİNÇLİ OLARAK YAPILMAYANLAR (TASKS.md §12.3):
--   * Veli kaydı (deneme_sinavi_katilimlari) kontrolü: istemcide kayıt yapan yol yok;
--     şimdi eklenirse hiçbir öğrenci giremez. Kayıt yolu çıkınca eklenecek.
--   * Puanlama: 3-7. sınıf için yüzde (0-100), negatif puan yok.
--     8. sınıf LGS hazırlığı için ileride ayrı sınav tipi eklenecek (TASKS.md §12.5).
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function public.start_mock_exam(p_sinav_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := (select auth.uid());
  v_sinif   smallint;
  v_sinav   public.deneme_sinavlari%rowtype;
  v_deneme  public.deneme_sinavi_denemeleri%rowtype;
  v_bitis   timestamptz;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Yalnızca öğrenciler sınava girebilir' using errcode = '42501';
  end if;

  select sinif into v_sinif from public.profiles where id = v_uid;

  select * into v_sinav from public.deneme_sinavlari where id = p_sinav_id;
  if not found then
    raise exception 'Sınav bulunamadı' using errcode = 'P0002';
  end if;
  if not v_sinav.aktif then
    raise exception 'Bu sınav artık aktif değil' using errcode = '22023';
  end if;
  if v_sinif is null or v_sinif <> all (v_sinav.siniflar) then
    raise exception 'Bu sınav senin sınıfın için değil' using errcode = '42501';
  end if;

  if now() < v_sinav.baslangic_zamani then
    raise exception 'Sınav henüz başlamadı: başlangıç %',
      to_char(v_sinav.baslangic_zamani at time zone 'Europe/Istanbul', 'DD.MM.YYYY HH24:MI')
      using errcode = '42501';
  end if;

  v_bitis := public._deneme_bitis_zamani(v_sinav);

  select * into v_deneme
    from public.deneme_sinavi_denemeleri
   where exam_id = p_sinav_id and student_id = v_uid;

  if found and v_deneme.bitis_zamani is not null then
    raise exception 'Bu sınavı zaten tamamladın' using errcode = '22023';
  end if;

  if now() >= v_bitis then
    raise exception 'Sınavın süresi doldu' using errcode = '22023';
  end if;

  if not found then
    insert into public.deneme_sinavi_denemeleri (exam_id, student_id, sinif)
    values (p_sinav_id, v_uid, v_sinif)
    returning * into v_deneme;
  end if;

  return jsonb_build_object(
    'deneme_id',        v_deneme.id,
    'sinav_id',         v_sinav.id,
    'ad',               v_sinav.ad,
    'sure_dakika',      v_sinav.sure_dakika,
    'baslangic_zamani', v_sinav.baslangic_zamani,
    'bitis_hedefi',     v_bitis,
    'sorular', coalesce((
      select jsonb_agg(row_to_json(s) order by s.sira)
        from (
          select q.id, q.soru_metni, q.konu, q.zorluk, q.siklar, dss.sira
            from public.deneme_sinavi_sorulari dss
            join public.questions q on q.id = dss.question_id
           where dss.exam_id = p_sinav_id and dss.sinif = v_sinif
           order by dss.sira
        ) s
    ), '[]'::jsonb)
  );
end;
$$;

create or replace function public.submit_mock_exam(p_deneme_id uuid, p_cevaplar jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := (select auth.uid());
  v_deneme  public.deneme_sinavi_denemeleri%rowtype;
  v_bitis   timestamptz;
  v_toplam  integer;
  v_dogru   integer;
  v_yanlis  integer;
  v_puan    numeric(5,2);
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Yalnızca öğrenciler sınav gönderebilir' using errcode = '42501';
  end if;

  select * into v_deneme
    from public.deneme_sinavi_denemeleri
   where id = p_deneme_id and student_id = v_uid
     for update;
  if not found then
    raise exception 'Deneme bulunamadı' using errcode = 'P0002';
  end if;
  if v_deneme.bitis_zamani is not null then
    raise exception 'Bu sınavı zaten tamamladın' using errcode = '22023';
  end if;

  select public._deneme_bitis_zamani(e) into v_bitis
    from public.deneme_sinavlari e
   where e.id = v_deneme.exam_id;

  if now() <= v_bitis + interval '30 seconds' then
    with g as (
      select distinct on (s.question_id)
             s.question_id,
             nullif(btrim(s.secilen_sik), '') as sik
        from jsonb_to_recordset(coalesce(p_cevaplar, '[]'::jsonb))
             as s(question_id uuid, secilen_sik text)
       order by s.question_id
    )
    insert into public.deneme_sinavi_cevaplari (deneme_id, question_id, secilen_sik, dogru, cevap_zamani)
    select p_deneme_id, g.question_id, g.sik, g.sik is not null and g.sik = q.dogru_sik, now()
      from g
      join public.deneme_sinavi_sorulari dss
        on dss.exam_id = v_deneme.exam_id and dss.sinif = v_deneme.sinif and dss.question_id = g.question_id
      join public.questions q on q.id = g.question_id
    on conflict (deneme_id, question_id)
      do update set secilen_sik = excluded.secilen_sik, dogru = excluded.dogru, cevap_zamani = now();
  end if;

  select count(*)::integer into v_toplam
    from public.deneme_sinavi_sorulari
   where exam_id = v_deneme.exam_id and sinif = v_deneme.sinif;

  select count(*) filter (where c.dogru)::integer,
         count(*) filter (where c.secilen_sik is not null and not c.dogru)::integer
    into v_dogru, v_yanlis
    from public.deneme_sinavi_cevaplari c
   where c.deneme_id = p_deneme_id;

  v_puan := case when v_toplam > 0 then round(v_dogru * 100.0 / v_toplam, 2) else 0 end;

  update public.deneme_sinavi_denemeleri
     set dogru_sayisi  = v_dogru,
         yanlis_sayisi = v_yanlis,
         bos_sayisi    = greatest(v_toplam - v_dogru - v_yanlis, 0),
         puan          = v_puan,
         bitis_zamani  = now()
   where id = p_deneme_id;

  return jsonb_build_object(
    'dogru_sayisi',  v_dogru,
    'yanlis_sayisi', v_yanlis,
    'bos_sayisi',    greatest(v_toplam - v_dogru - v_yanlis, 0),
    'toplam',        v_toplam,
    'puan',          v_puan,
    'gec_teslim',    now() > v_bitis + interval '30 seconds'
  );
end;
$$;

revoke execute on function public.start_mock_exam(uuid) from public, anon;
grant  execute on function public.start_mock_exam(uuid) to authenticated;

revoke execute on function public.submit_mock_exam(uuid, jsonb) from public, anon;
grant  execute on function public.submit_mock_exam(uuid, jsonb) to authenticated;
