-- =====================================================================
-- Deneme Sınavı — Öğrenci Akışı RPC'leri
--   * list_my_exams()         : sınıfa uygun aktif sınavları listele
--   * start_mock_exam()       : sınava başla, soruları getir
--   * submit_mock_exam()      : cevapları gönder, puanla, bitir
--
-- Güvenlik kararları:
--   * Cevap anahtarı istemciye HİÇBİR ZAMAN gönderilmez; puanlama sunucuda.
--   * Öğrenci başına tek deneme (unique exam_id+student_id); ikinci başlatma
--     zaten oluşan kaydı döner (idempotent).
--   * Bitmiş sınava submit_mock_exam çağrısı hata verir (idempotency).
--   * Sınav süresi kontrolü sunucuda: baslangic_zamani + sure_dakika geçmişse
--     son başlatma kabul edilmez (işaret bırakır ama cevap alamaz).
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- list_my_exams: öğrencinin sınıfına uygun aktif sınavlar
-- ---------------------------------------------------------------------
create or replace function public.list_my_exams()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid   uuid    := (select auth.uid());
  v_sinif smallint;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Yalnızca öğrenciler sınav listesini görebilir' using errcode = '42501';
  end if;

  select sinif into v_sinif from public.profiles where id = v_uid;

  return coalesce((
    select jsonb_agg(row_to_json(t) order by t.baslangic_zamani)
      from (
        select
          s.id,
          s.ad,
          s.baslangic_zamani,
          s.sure_dakika,
          coalesce(d.bitis_zamani is not null, false) as bitti,
          coalesce(d.puan,          0)       as puan,
          coalesce(d.dogru_sayisi,  0)       as dogru_sayisi,
          coalesce(d.yanlis_sayisi, 0)       as yanlis_sayisi,
          coalesce(d.bos_sayisi,    0)       as bos_sayisi,
          d.id                               as deneme_id
        from public.deneme_sinavlari s
        left join public.deneme_sinavi_denemeleri d
          on d.exam_id = s.id and d.student_id = v_uid
        where s.aktif
          and (v_sinif = any(s.siniflar) or array_length(s.siniflar, 1) = 0)
        order by s.baslangic_zamani desc
      ) t
  ), '[]'::jsonb);
end;
$$;

revoke execute on function public.list_my_exams() from public, anon;
grant  execute on function public.list_my_exams() to authenticated;

-- ---------------------------------------------------------------------
-- start_mock_exam: sınava başla — sorular + deneme kaydı
-- ---------------------------------------------------------------------
create or replace function public.start_mock_exam(p_sinav_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid    uuid     := (select auth.uid());
  v_sinif  smallint;
  v_sinav  record;
  v_deneme record;
  v_sure_bitti boolean;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Yalnızca öğrenciler sınava girebilir' using errcode = '42501';
  end if;

  select sinif into v_sinif from public.profiles where id = v_uid;

  select id, ad, baslangic_zamani, sure_dakika, aktif, siniflar
    into v_sinav
    from public.deneme_sinavlari
   where id = p_sinav_id;

  if not found then
    raise exception 'Sınav bulunamadı' using errcode = 'P0002';
  end if;

  if not v_sinav.aktif then
    raise exception 'Bu sınav artık aktif değil' using errcode = '22023';
  end if;

  if array_length(v_sinav.siniflar, 1) > 0 and not (v_sinif = any(v_sinav.siniflar)) then
    raise exception 'Bu sınav senin sınıfın için değil' using errcode = '42501';
  end if;

  -- Sınav süresi dolmuşsa başlatma
  v_sure_bitti := now() > v_sinav.baslangic_zamani + make_interval(mins => v_sinav.sure_dakika);
  if v_sure_bitti then
    raise exception 'Sınavın süresi dolmuş' using errcode = '22023';
  end if;

  -- Öğrenci başına tek deneme kaydı (idempotent)
  insert into public.deneme_sinavi_denemeleri (exam_id, student_id, sinif)
  values (p_sinav_id, v_uid, v_sinif)
  on conflict (exam_id, student_id) do nothing;

  select * into v_deneme
    from public.deneme_sinavi_denemeleri
   where exam_id = p_sinav_id and student_id = v_uid;

  if v_deneme.bitis_zamani is not null then
    raise exception 'Bu sınavı zaten tamamladın' using errcode = '22023';
  end if;

  -- Soruları getir (dogru_sik dahil edilmez)
  return jsonb_build_object(
    'deneme_id',      v_deneme.id,
    'sinav_id',       v_sinav.id,
    'ad',             v_sinav.ad,
    'sure_dakika',    v_sinav.sure_dakika,
    'baslangic_zamani', v_sinav.baslangic_zamani,
    'bitis_hedefi',   v_sinav.baslangic_zamani + make_interval(mins => v_sinav.sure_dakika),
    'sorular', coalesce((
      select jsonb_agg(row_to_json(s) order by s.sira)
        from (
          select
            q.id,
            q.soru_metni,
            q.konu,
            q.zorluk,
            q.siklar,
            dss.sira
          from public.deneme_sinavi_sorulari dss
          join public.questions q on q.id = dss.question_id
         where dss.exam_id = p_sinav_id
           and dss.sinif   = v_sinif
         order by dss.sira
        ) s
    ), '[]'::jsonb)
  );
end;
$$;

revoke execute on function public.start_mock_exam(uuid) from public, anon;
grant  execute on function public.start_mock_exam(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- submit_mock_exam: cevapları gönder, sunucuda puanla, kaydı bitir
-- p_cevaplar: jsonb array [{question_id, secilen_sik}]
-- ---------------------------------------------------------------------
create or replace function public.submit_mock_exam(
  p_deneme_id uuid,
  p_cevaplar  jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid         uuid := (select auth.uid());
  v_deneme      record;
  v_sinav       record;
  v_dogru_sayisi  smallint := 0;
  v_yanlis_sayisi smallint := 0;
  v_bos_sayisi    smallint := 0;
  v_toplam        smallint;
  v_puan          numeric;
  v_cevap         jsonb;
  v_dogru_sik     text;
  v_secilen_sik   text;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Yalnızca öğrenciler sınav gönderebilir' using errcode = '42501';
  end if;

  select * into v_deneme
    from public.deneme_sinavi_denemeleri
   where id = p_deneme_id and student_id = v_uid;

  if not found then
    raise exception 'Deneme bulunamadı' using errcode = 'P0002';
  end if;

  if v_deneme.bitis_zamani is not null then
    raise exception 'Bu sınavı zaten tamamladın' using errcode = '22023';
  end if;

  select * into v_sinav from public.deneme_sinavlari where id = v_deneme.exam_id;

  -- Sınav süresi aşılmışsa da kabul et ama kaydet (öğrenci haklı teslim)
  -- Her cevabı kontrol et
  v_toplam := jsonb_array_length(p_cevaplar);

  for v_cevap in select jsonb_array_elements(p_cevaplar)
  loop
    select dogru_sik into v_dogru_sik
      from public.questions
     where id = (v_cevap->>'question_id')::uuid;

    v_secilen_sik := v_cevap->>'secilen_sik';

    if v_secilen_sik is null or v_secilen_sik = '' then
      v_bos_sayisi := v_bos_sayisi + 1;
    elsif v_secilen_sik = v_dogru_sik then
      v_dogru_sayisi := v_dogru_sayisi + 1;
    else
      v_yanlis_sayisi := v_yanlis_sayisi + 1;
    end if;
  end loop;

  -- Puanlama: doğru 4 puan, yanlış -1 puan (YKS stili), boş 0
  v_puan := greatest(0, v_dogru_sayisi * 4 - v_yanlis_sayisi)::numeric;

  update public.deneme_sinavi_denemeleri
     set dogru_sayisi  = v_dogru_sayisi,
         yanlis_sayisi = v_yanlis_sayisi,
         bos_sayisi    = v_bos_sayisi,
         puan          = v_puan,
         bitis_zamani  = now()
   where id = p_deneme_id;

  return jsonb_build_object(
    'dogru_sayisi',  v_dogru_sayisi,
    'yanlis_sayisi', v_yanlis_sayisi,
    'bos_sayisi',    v_bos_sayisi,
    'toplam',        v_toplam,
    'puan',          v_puan
  );
end;
$$;

revoke execute on function public.submit_mock_exam(uuid, jsonb) from public, anon;
grant  execute on function public.submit_mock_exam(uuid, jsonb) to authenticated;
