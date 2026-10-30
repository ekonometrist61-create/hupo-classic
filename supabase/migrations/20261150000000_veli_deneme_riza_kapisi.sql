-- =====================================================================
-- Veli rıza kapısı, deneme RPC'leri (AGENTS.md §5.3).
-- get_student_dashboard / get_student_badges ile aynı kural: veli onayı
-- ('veli_acik_riza') yoksa ya da geri çekildiyse çocuğa ait deneme verisi
-- dönmez. Veli-çocuk bağı kontrolü korunur.
--
-- Değişiklik yalnızca iki fonksiyonun gövdesinde; grant'ler create or replace
-- ile korunur. Telefon alanı (get_upcoming_mock_exams_for_child) bilerek
-- kaldırılmadı: DenemeKaydiKarti.tsx formu bu alanla ön doldurur ve alan
-- yalnızca çağıran velinin kendi telefonudur.
-- =====================================================================

-- ---------------------------------------------------------------------
-- get_child_exam_history: rıza yoksa boş liste
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

  if public._veli_riza_durumu(p_cocuk_id) <> 'verildi' then
    return '[]'::jsonb;
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
-- get_upcoming_mock_exams_for_child: rıza yoksa boş liste
-- ---------------------------------------------------------------------
create or replace function public.get_upcoming_mock_exams_for_child(p_cocuk_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid  uuid := (select auth.uid());
  v_sinif smallint;
  v_ana  uuid := public.deneme_ana_profil(p_cocuk_id);
begin
  if v_uid is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'Yalnızca çocuğun velisi görüntüleyebilir' using errcode = '42501';
  end if;

  if public._veli_riza_durumu(p_cocuk_id) <> 'verildi' then
    return '[]'::jsonb;
  end if;

  select sinif into v_sinif from public.profiles where id = p_cocuk_id;

  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.baslangic_zamani)
      from (
        select e.id, e.ad, e.baslangic_zamani, e.sure_dakika,
               (k.id is not null) as kayitli,
               coalesce(k.telefon, p.telefon, '') as telefon
          from public.deneme_sinavlari e
          left join public.deneme_sinavi_katilimlari k
                 on k.exam_id = e.id and k.student_id = v_ana
          left join public.profiles p on p.id = v_ana
         where e.aktif
           and e.baslangic_zamani > now()
           and v_sinif = any (e.siniflar)
      ) x
  ), '[]'::jsonb);
end;
$$;
