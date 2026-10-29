-- =====================================================================
-- Deneme sinavi: 1-4. sinifta puan ve sinif ici sira sunucudan donmez
-- Tarih : 2026-10-29
--
-- Kural (docs/soru-uretim/SISTEM.md par.4): 1-4. sinif deneme sonucunda puan ve
-- sinif ici sira gosterilmez. Karar (proje sahibi, 2026-10-29): bu siniflarda
-- yalnizca dogru / yanlis / bos sayilari gosterilir.
--
-- Sozlesme: sinif < 5 ise `puan`, `sira`, `sinif_katilimci`/`katilimci`/`toplam`
-- alanlari NULL doner; dogru/yanlis/bos her zaman doner. Istemciler `puan is null`
-- ile ayirir. Siralama icin dahili puan kullanimi (rank, order by) degismez.
--
-- Etkilenen: list_my_exams, submit_mock_exam, _deneme_sinavi_bitir,
-- get_mock_exam_result, get_child_exam_history, admin_get_mock_exam_results,
-- deneme_bildirim_alici (veli e-postasi). Donus tipleri ayni; create or replace.
-- DAGITIM SIRASI: once olay-kutusu-gonder edge fonksiyonu, sonra bu migration.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function public._deneme_puan_gorunur(p_sinif smallint)
returns boolean
language sql
immutable
parallel safe
set search_path = ''
as $$ select coalesce(p_sinif, 0) >= 5 $$;

revoke execute on function public._deneme_puan_gorunur(smallint) from public, anon;
grant  execute on function public._deneme_puan_gorunur(smallint) to authenticated, service_role;

-- ---------------------------------------------------------------------
-- list_my_exams
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
          case when public._deneme_puan_gorunur(v_sinif) then coalesce(d.puan, 0) end as puan,
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

-- ---------------------------------------------------------------------
-- submit_mock_exam
-- ---------------------------------------------------------------------
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
    'puan',          case when public._deneme_puan_gorunur(v_deneme.sinif) then v_puan end,
    'gec_teslim',    now() > v_bitis + interval '30 seconds'
  );
end;
$$;

-- ---------------------------------------------------------------------
-- _deneme_sinavi_bitir (olay payload'indaki puan/sira da 1-4'te null)
-- ---------------------------------------------------------------------
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
  v_gorunur boolean;
begin
  select * into v_deneme
    from public.deneme_sinavi_denemeleri
   where id = p_deneme_id
     for update;

  if not found then
    raise exception 'Deneme bulunamadı' using errcode = 'P0002';
  end if;

  v_gorunur := public._deneme_puan_gorunur(v_deneme.sinif);

  if v_deneme.bitis_zamani is not null then
    return jsonb_build_object(
      'dogru_sayisi',  v_deneme.dogru_sayisi,
      'yanlis_sayisi', v_deneme.yanlis_sayisi,
      'bos_sayisi',    v_deneme.bos_sayisi,
      'puan',          case when v_gorunur then v_deneme.puan end,
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
      'puan',        case when v_gorunur then v_puan end,
      'sira',        case when v_gorunur then v_sira end,
      'supheli',     v_supheli,
      'teslim_turu', v_teslim
    )
  );

  return jsonb_build_object(
    'dogru_sayisi',  v_dogru,
    'yanlis_sayisi', v_yanlis,
    'bos_sayisi',    v_bos,
    'puan',          case when v_gorunur then v_puan end,
    'teslim_turu',   v_teslim
  );
end;
$$;

-- ---------------------------------------------------------------------
-- get_mock_exam_result
-- ---------------------------------------------------------------------
create or replace function public.get_mock_exam_result(p_exam_id uuid)
 returns jsonb
 language plpgsql
 security definer
 set search_path to ''
as $function$
declare
  v_uid    uuid := (select auth.uid());
  v_deneme public.deneme_sinavi_denemeleri%rowtype;
  v_sira   bigint;
  v_toplam bigint;
  v_onceki jsonb;
  v_gorunur boolean;
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;

  select * into v_deneme
    from public.deneme_sinavi_denemeleri
   where exam_id = p_exam_id and student_id = v_uid;
  if not found or v_deneme.bitis_zamani is null then
    raise exception 'Bu sınava ait tamamlanmış bir denemen bulunamadı' using errcode = 'P0002';
  end if;

  v_gorunur := public._deneme_puan_gorunur(v_deneme.sinif);

  select count(*) filter (where d.puan > v_deneme.puan) + 1, count(*)
    into v_sira, v_toplam
    from public.deneme_sinavi_denemeleri d
   where d.exam_id = p_exam_id and d.sinif = v_deneme.sinif and d.bitis_zamani is not null;

  -- Bir önceki deneme sınavı: bu sınavdan daha ÖNCE başlamış, öğrencinin
  -- tamamladığı en yakın deneme sınavı (karşılaştırma amaçlı).
  select jsonb_build_object(
           'ad',   e.ad,
           'puan', case when public._deneme_puan_gorunur(d.sinif) then d.puan end
         )
    into v_onceki
    from public.deneme_sinavi_denemeleri d
    join public.deneme_sinavlari e on e.id = d.exam_id
   where d.student_id = v_uid
     and d.bitis_zamani is not null
     and e.baslangic_zamani < (select baslangic_zamani from public.deneme_sinavlari where id = p_exam_id)
   order by e.baslangic_zamani desc
   limit 1;

  return jsonb_build_object(
    'puan',          case when v_gorunur then v_deneme.puan end,
    'dogru_sayisi',  v_deneme.dogru_sayisi,
    'yanlis_sayisi', v_deneme.yanlis_sayisi,
    'bos_sayisi',    v_deneme.bos_sayisi,
    'sira',          case when v_gorunur then v_sira end,
    'toplam',        case when v_gorunur then v_toplam end,
    'onceki_deneme', v_onceki
  );
end;
$function$;

-- ---------------------------------------------------------------------
-- get_child_exam_history (veli paneli)
-- ---------------------------------------------------------------------
create or replace function public.get_child_exam_history(p_cocuk_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_ana uuid := public.deneme_ana_profil(p_cocuk_id);
begin
  if v_uid is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'Yalnızca çocuğun velisi görüntüleyebilir' using errcode = '42501';
  end if;

  return coalesce((
    select jsonb_agg(row_data order by (row_data->>'tarih') desc)
      from (
        select jsonb_build_object(
          'sinav_id',        e.id,
          'sinav_ad',        e.ad,
          'tarih',           e.baslangic_zamani,
          'bitis_zamani',    d.bitis_zamani,
          'sinif',           d.sinif,
          'puan',            case when public._deneme_puan_gorunur(d.sinif) then d.puan end,
          'dogru',           d.dogru_sayisi,
          'yanlis',          d.yanlis_sayisi,
          'bos',             d.bos_sayisi,
          'teslim_turu',     d.teslim_turu,
          'sira', case when public._deneme_puan_gorunur(d.sinif) then (
            select count(*) + 1
              from public.deneme_sinavi_denemeleri d2
             where d2.exam_id = d.exam_id
               and d2.sinif = d.sinif
               and d2.bitis_zamani is not null
               and d2.puan > d.puan
          ) end,
          'sinif_katilimci', case when public._deneme_puan_gorunur(d.sinif) then (
            select count(*)
              from public.deneme_sinavi_denemeleri d3
             where d3.exam_id = d.exam_id
               and d3.sinif = d.sinif
               and d3.bitis_zamani is not null
          ) end
        ) as row_data
          from public.deneme_sinavi_denemeleri d
          join public.deneme_sinavlari e on e.id = d.exam_id
         where d.student_id = v_ana
           and d.bitis_zamani is not null
      ) t
  ), '[]'::jsonb);
end;
$$;

-- ---------------------------------------------------------------------
-- admin_get_mock_exam_results (kolon seti ayni; siralama dahili puanla)
-- ---------------------------------------------------------------------
create or replace function public.admin_get_mock_exam_results(p_exam_id uuid)
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
      case when public._deneme_puan_gorunur(d.sinif) then d.puan end,
      d.dogru_sayisi,
      d.yanlis_sayisi,
      d.bos_sayisi,
      case when public._deneme_puan_gorunur(d.sinif)
           then rank() over (partition by d.sinif order by d.puan desc, d.bitis_zamani asc) end,
      d.bitis_zamani,
      d.supheli
    from public.deneme_sinavi_denemeleri d
    join public.profiles p on p.id = d.student_id
   where d.exam_id = p_exam_id and d.bitis_zamani is not null
   order by d.sinif, d.puan desc, d.bitis_zamani asc;
end;
$function$;

comment on function public.admin_get_mock_exam_results(uuid) is
  'Bitmis denemeleri doner. 5+ sinifta puan ve sinif ici sira (puan desc, bitis zamani asc); 1-4. sinifta puan ve sira NULL. supheli: anti-hile bayragi.';

-- ---------------------------------------------------------------------
-- deneme_bildirim_alici (veli e-postasi; 1-4'te puan/sira/katilimci null)
-- ---------------------------------------------------------------------
create or replace function public.deneme_bildirim_alici(p_exam_id uuid, p_student_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_r record;
  v_gorunur boolean;
begin
  select p.full_name as cocuk_ad,
         p.username  as cocuk_kullanici,
         e.ad        as sinav_ad,
         d.puan,
         d.sinif,
         d.dogru_sayisi,
         d.yanlis_sayisi,
         d.bos_sayisi,
         d.teslim_turu,
         u.email     as veli_eposta,
         v.full_name as veli_ad
    into v_r
    from public.deneme_sinavi_denemeleri d
    join public.deneme_sinavlari e on e.id = d.exam_id
    join public.profiles p on p.id = d.student_id
    join public.profiles v on v.id = p.parent_id
    join auth.users u on u.id = v.id
   where d.exam_id = p_exam_id
     and d.student_id = p_student_id
     and d.bitis_zamani is not null;

  if not found or v_r.veli_eposta is null then
    return null;
  end if;

  v_gorunur := public._deneme_puan_gorunur(v_r.sinif);

  return jsonb_build_object(
    'veli_eposta', v_r.veli_eposta,
    'veli_ad',     v_r.veli_ad,
    'cocuk_ad',    coalesce(v_r.cocuk_ad, v_r.cocuk_kullanici, 'Çocuğunuz'),
    'sinav_ad',    v_r.sinav_ad,
    'puan',        case when v_gorunur then v_r.puan end,
    'dogru',       v_r.dogru_sayisi,
    'yanlis',      v_r.yanlis_sayisi,
    'bos',         v_r.bos_sayisi,
    'teslim_turu', v_r.teslim_turu,
    'sira', case when v_gorunur then (
      select count(*) + 1
        from public.deneme_sinavi_denemeleri d2
       where d2.exam_id = p_exam_id
         and d2.sinif = v_r.sinif
         and d2.bitis_zamani is not null
         and d2.puan > v_r.puan
    ) end,
    'katilimci', case when v_gorunur then (
      select count(*)
        from public.deneme_sinavi_denemeleri d3
       where d3.exam_id = p_exam_id
         and d3.sinif = v_r.sinif
         and d3.bitis_zamani is not null
    ) end
  );
end;
$$;
