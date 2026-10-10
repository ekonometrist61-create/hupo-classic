-- =====================================================================
-- Deneme sınavı: teslim türü + süre dolunca otomatik bitirme
--   teslim_turu:
--     'elle'       öğrenci süre içinde teslim etti
--     'sure_doldu' süre dolduktan sonra teslim edildi (istemci ya da cevap yolu)
--     'otomatik'   öğrenci teslim etmedi; sistem süre sonunda cevapları kaydetti
--   deneme_sure_dolanlari_kapat(): süresi dolmuş bitmemiş denemeleri bitirir (pg_cron, her dakika).
--   submit_mock_exam_answer: süre dolunca bitirip RAISE ETMEZ. Raise, bitişi
--     aynı transaction'da geri alıyordu.
-- =====================================================================

alter table public.deneme_sinavi_denemeleri
  add column if not exists teslim_turu text
  check (teslim_turu in ('elle', 'sure_doldu', 'otomatik'));

update public.deneme_sinavi_denemeleri
   set teslim_turu = 'elle'
 where bitis_zamani is not null and teslim_turu is null;

drop function if exists public._deneme_sinavi_bitir(uuid);

create or replace function public._deneme_sinavi_bitir(p_deneme_id uuid, p_teslim_turu text default null)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_deneme  public.deneme_sinavi_denemeleri%rowtype;
  v_exam    public.deneme_sinavlari%rowtype;
  v_toplam  integer;
  v_dogru   integer;
  v_yanlis  integer;
  v_bos     integer;
  v_puan    numeric(5, 2);
  v_supheli boolean := false;
  v_teslim  text;
  v_sira    bigint;
begin
  select * into v_deneme
    from public.deneme_sinavi_denemeleri
   where id = p_deneme_id
     for update;

  if not found then
    raise exception 'Deneme bulunamadı' using errcode = 'P0002';
  end if;

  if v_deneme.bitis_zamani is not null then
    return jsonb_build_object(
      'dogru_sayisi',  v_deneme.dogru_sayisi,
      'yanlis_sayisi', v_deneme.yanlis_sayisi,
      'bos_sayisi',    v_deneme.bos_sayisi,
      'puan',          v_deneme.puan,
      'teslim_turu',   v_deneme.teslim_turu
    );
  end if;

  select * into v_exam from public.deneme_sinavlari where id = v_deneme.exam_id;

  v_teslim := coalesce(
    p_teslim_turu,
    case when now() >= public._deneme_bitis_zamani(v_exam) then 'sure_doldu' else 'elle' end
  );

  if v_deneme.started_at is not null and now() - v_deneme.started_at < interval '30 seconds' then
    v_supheli := true;
  end if;

  select count(*) into v_toplam
    from public.deneme_sinavi_sorulari
   where exam_id = v_deneme.exam_id and sinif = v_deneme.sinif;

  select count(*) filter (where dogru),
         count(*) filter (where not dogru and secilen_sik is not null)
    into v_dogru, v_yanlis
    from public.deneme_sinavi_cevaplari
   where deneme_id = p_deneme_id;

  v_dogru  := coalesce(v_dogru, 0);
  v_yanlis := coalesce(v_yanlis, 0);
  v_bos    := greatest(v_toplam - v_dogru - v_yanlis, 0);
  v_puan   := case when v_toplam > 0 then round(v_dogru * 100.0 / v_toplam, 2) else 0 end;

  update public.deneme_sinavi_denemeleri
     set bitis_zamani  = now(),
         dogru_sayisi  = v_dogru,
         yanlis_sayisi = v_yanlis,
         bos_sayisi    = v_bos,
         puan          = v_puan,
         supheli       = v_supheli,
         teslim_turu   = v_teslim
   where id = p_deneme_id;

  select count(*) filter (where d2.puan > v_puan) + 1
    into v_sira
    from public.deneme_sinavi_denemeleri d2
   where d2.exam_id  = v_deneme.exam_id
     and d2.sinif    = v_deneme.sinif
     and d2.bitis_zamani is not null
     and d2.id != p_deneme_id;

  insert into public.olay_kutusu (tur, payload)
  values (
    'deneme_sonuc_bildirimi',
    jsonb_build_object(
      'exam_id',     v_deneme.exam_id,
      'student_id',  v_deneme.student_id,
      'puan',        v_puan,
      'sira',        v_sira,
      'supheli',     v_supheli,
      'teslim_turu', v_teslim
    )
  );

  return jsonb_build_object(
    'dogru_sayisi',  v_dogru,
    'yanlis_sayisi', v_yanlis,
    'bos_sayisi',    v_bos,
    'puan',          v_puan,
    'teslim_turu',   v_teslim
  );
end;
$$;

revoke execute on function public._deneme_sinavi_bitir(uuid, text) from public, anon, authenticated, service_role;

create or replace function public.submit_mock_exam_answer(p_deneme_id uuid, p_question_id uuid, p_secilen_sik text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := (select auth.uid());
  v_deneme public.deneme_sinavi_denemeleri%rowtype;
  v_exam  public.deneme_sinavlari%rowtype;
  v_dogru_sik text;
  v_dogru boolean;
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;

  select * into v_deneme from public.deneme_sinavi_denemeleri where id = p_deneme_id;
  if not found or v_deneme.student_id <> v_uid then
    raise exception 'Deneme bulunamadı' using errcode = 'P0002';
  end if;
  if v_deneme.bitis_zamani is not null then
    raise exception 'Bu deneme zaten bitti' using errcode = '42501';
  end if;

  select * into v_exam from public.deneme_sinavlari where id = v_deneme.exam_id;
  if now() >= public._deneme_bitis_zamani(v_exam) then
    perform public._deneme_sinavi_bitir(p_deneme_id, 'sure_doldu');
    return;
  end if;

  if not exists (
    select 1 from public.deneme_sinavi_sorulari
     where exam_id = v_deneme.exam_id and sinif = v_deneme.sinif and question_id = p_question_id
  ) then
    raise exception 'Bu soru bu sınavda yok' using errcode = '22023';
  end if;

  select dogru_sik into v_dogru_sik from public.questions where id = p_question_id;
  v_dogru := p_secilen_sik is not null and p_secilen_sik = v_dogru_sik;

  insert into public.deneme_sinavi_cevaplari (deneme_id, question_id, secilen_sik, dogru)
  values (p_deneme_id, p_question_id, p_secilen_sik, v_dogru)
  on conflict (deneme_id, question_id)
  do update set secilen_sik = excluded.secilen_sik, dogru = excluded.dogru, cevap_zamani = now();
end;
$$;

revoke execute on function public.submit_mock_exam_answer(uuid, uuid, text) from public, anon;
grant  execute on function public.submit_mock_exam_answer(uuid, uuid, text) to authenticated, service_role;

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
          'teslim_turu', d.teslim_turu,
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

create or replace function public.deneme_sure_dolanlari_kapat()
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  r record;
  n integer := 0;
begin
  for r in
    select d.id
      from public.deneme_sinavi_denemeleri d
      join public.deneme_sinavlari e on e.id = d.exam_id
     where d.bitis_zamani is null
       and now() >= public._deneme_bitis_zamani(e)
     order by e.baslangic_zamani
     limit 200
       for update of d skip locked
  loop
    perform public._deneme_sinavi_bitir(r.id, 'otomatik');
    n := n + 1;
  end loop;
  return n;
end;
$$;

revoke execute on function public.deneme_sure_dolanlari_kapat() from public, anon, authenticated, service_role;

do $$
begin
  if not exists (select 1 from cron.job where jobname = 'deneme-sure-dolanlari-kapat') then
    perform cron.schedule(
      'deneme-sure-dolanlari-kapat',
      '* * * * *',
      'select public.deneme_sure_dolanlari_kapat()'
    );
  end if;
end
$$;
