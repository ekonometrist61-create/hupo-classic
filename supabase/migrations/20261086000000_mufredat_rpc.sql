-- =====================================================================
--  Müfredat RPC'leri (WP2) — docs/mufredat/PLAN_HAFTA_ETIKETLEME.md §4.2, §4.3
--  Proje : Hupo · 2026-10-24
--  Öğrenci (SECURITY INVOKER, yalnız authenticated):
--    get_mufredat_haritasi(p_ders, p_tarih)
--    get_mufredat_sorulari(p_ders, p_mod, p_hafta, p_kazanim_kodlari, p_limit, p_tarih)
--  Yönetim (SECURITY DEFINER, require_admin, yalnız authenticated):
--    admin_set_question_kazanim(p_ids, p_kod)
--    admin_kazanim_kapsam(p_ders, p_sinif)
--    admin_kazanimsiz_sorular(p_ders, p_sinif, p_limit, p_offset)
--  Not: p_tarih parametresi (sözleşmenin dışında, sonda, default null) test için eklendi;
--  null ise bugünkü Europe/Istanbul tarihi kullanılır.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. Kolon yetkisi: invoker RPC'ler questions.kazanim_kodu / kazanim_metni okur.
--    Canlıda authenticated yalnız REFERENCES'a sahip (SELECT yok). Kazanım kodu
--    öğrenciye zaten harita ekranında gösterilir; satır filtresi RLS ile kalır.
--    dogru_sik için yetki eklenmez (20260920000300).
-- ---------------------------------------------------------------------
grant select (kazanim_kodu, kazanim_metni) on public.questions to authenticated;

-- ---------------------------------------------------------------------
-- 1. get_mufredat_haritasi
-- ---------------------------------------------------------------------
create or replace function public.get_mufredat_haritasi(p_ders text, p_tarih date default null)
returns jsonb
language plpgsql
stable
security invoker
set search_path = ''
as $$
declare
  v_uid   uuid := (select auth.uid());
  v_sinif smallint := public.my_sinif();
  v_mders text;
  v_bugun smallint;
  v_plan  boolean;
  v_sonuc jsonb;
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı' using errcode = '42501';
  end if;
  if v_sinif is null then
    raise exception 'Sınıf bilgisi bulunamadı. Profilini kontrol et.' using errcode = '22023';
  end if;
  if nullif(btrim(coalesce(p_ders, '')), '') is null then
    raise exception 'Ders seçilmedi' using errcode = '22023';
  end if;

  select e.mufredat_ders into v_mders
    from public.mufredat_ders_eslesme e
   where e.soru_ders = p_ders;
  if v_mders is null then
    raise exception 'Bu ders için müfredat eşlemesi yok' using errcode = '22023';
  end if;

  v_bugun := public.mufredat_bugun_hafta(p_tarih);

  select exists (
    select 1 from public.mufredat_hafta h
     where h.ders = v_mders and h.sinif = v_sinif and h.kaynak_yili = '2026-2027'
  ) into v_plan;

  with kazanim as (
    select o.kazanim_kodu, o.kazanim_metni, o.ilk_hafta
      from public.mufredat_kazanim_ozet o
     where o.ders = v_mders and o.sinif = v_sinif
  ),
  soru as (
    select q.kazanim_kodu,
           count(distinct q.id)           as soru_sayisi,
           count(ua.id)                   as cevaplanan,
           count(ua.id) filter (where ua.dogru_mu) as dogru
      from public.questions q
      left join public.user_answers ua
        on ua.question_id = q.id and ua.student_id = v_uid
     where q.ders = p_ders
       and q.sinif = v_sinif
       and q.onay_durumu = 'onaylandi'
       and q.kazanim_kodu is not null
       and q.kazanim_kodu <> ''
     group by q.kazanim_kodu
  ),
  kazanim_json as (
    select k.ilk_hafta, k.kazanim_kodu,
           jsonb_build_object(
             'kod', k.kazanim_kodu,
             'metin', k.kazanim_metni,
             'ilk_hafta', k.ilk_hafta,
             'soru_sayisi', coalesce(s.soru_sayisi, 0),
             'cevaplanan', coalesce(s.cevaplanan, 0),
             'dogru', coalesce(s.dogru, 0),
             -- Oran yalnız en az 6 cevapta ve 5. sınıf ve üzerinde (GÖR-058)
             'oran', case when coalesce(s.cevaplanan, 0) >= 6 and v_sinif >= 5
                          then round(100.0 * s.dogru / s.cevaplanan)::int
                          else null end
           ) as j
      from kazanim k
      left join soru s on s.kazanim_kodu = k.kazanim_kodu
  )
  select jsonb_build_object(
           'sinif', v_sinif,
           'ders', p_ders,
           'mufredat_ders', v_mders,
           'bugun_hafta', v_bugun,
           'plan_var', v_plan,
           'haftalar', coalesce((
             select jsonb_agg(w.j order by w.baslangic)
               from (
                 select t.baslangic,
                        case when t.tatil_mi then
                          jsonb_build_object(
                            'hafta', null,
                            'baslangic', t.baslangic,
                            'bitis', t.bitis,
                            'tatil', true,
                            'aciklama', t.aciklama,
                            'unite_tema', null,
                            'konular', '[]'::jsonb,
                            'kazanimlar', '[]'::jsonb)
                        else
                          jsonb_build_object(
                            'hafta', t.hafta,
                            'baslangic', t.baslangic,
                            'bitis', t.bitis,
                            'tatil', false,
                            'aciklama', null,
                            'unite_tema', (
                              select min(h.unite_tema) from public.mufredat_hafta h
                               where h.ders = v_mders and h.sinif = v_sinif
                                 and h.kaynak_yili = '2026-2027' and h.hafta = t.hafta),
                            'konular', coalesce((
                              select jsonb_agg(z.konu order by z.konu) from (
                                select distinct h.konu from public.mufredat_hafta h
                                 where h.ders = v_mders and h.sinif = v_sinif
                                   and h.kaynak_yili = '2026-2027' and h.hafta = t.hafta
                                   and h.konu is not null) z), '[]'::jsonb),
                            'kazanimlar', coalesce((
                              select jsonb_agg(kj.j order by kj.kazanim_kodu)
                                from kazanim_json kj
                               where kj.ilk_hafta = t.hafta), '[]'::jsonb)
                          ) end as j
                   from public.mufredat_takvim t
               ) w
          ), '[]'::jsonb)
         )
    into v_sonuc;

  return v_sonuc;
end;
$$;

revoke execute on function public.get_mufredat_haritasi(text, date) from public, anon;
grant  execute on function public.get_mufredat_haritasi(text, date) to authenticated;

-- ---------------------------------------------------------------------
-- 2. get_mufredat_sorulari
--    p_mod: bu_hafta | bugune_kadar | hafta | kazanim
--    Tüm modlar yalnız işlenmiş kazanımları döndürür (ilk_hafta <= bugünkü hafta);
--    'hafta' modunda ilk_hafta <= min(p_hafta, bugünkü hafta).
-- ---------------------------------------------------------------------
create or replace function public.get_mufredat_sorulari(
  p_ders            text,
  p_mod             text,
  p_hafta           int default null,
  p_kazanim_kodlari text[] default null,
  p_limit           int default 10,
  p_tarih           date default null
)
returns setof jsonb
language plpgsql
stable
security invoker
set search_path = ''
as $$
declare
  v_uid    uuid := (select auth.uid());
  v_sinif  smallint := public.my_sinif();
  v_mders  text;
  v_bugun  smallint;
  v_ust    integer;
  v_limit  integer := least(greatest(coalesce(p_limit, 10), 1), 30);
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı' using errcode = '42501';
  end if;
  if v_sinif is null then
    raise exception 'Sınıf bilgisi bulunamadı. Profilini kontrol et.' using errcode = '22023';
  end if;
  if nullif(btrim(coalesce(p_ders, '')), '') is null then
    raise exception 'Ders seçilmedi' using errcode = '22023';
  end if;
  if p_mod is null or p_mod not in ('bu_hafta', 'bugune_kadar', 'hafta', 'kazanim') then
    raise exception 'Geçersiz mod: %', coalesce(p_mod, '(boş)') using errcode = '22023';
  end if;
  if p_mod = 'hafta' and (p_hafta is null or p_hafta < 1 or p_hafta > 37) then
    raise exception 'Hafta 1 ile 37 arasında olmalı' using errcode = '22023';
  end if;
  if p_mod = 'kazanim' and (p_kazanim_kodlari is null or cardinality(p_kazanim_kodlari) = 0) then
    raise exception 'Kazanım kodu seçilmedi' using errcode = '22023';
  end if;

  select e.mufredat_ders into v_mders
    from public.mufredat_ders_eslesme e
   where e.soru_ders = p_ders;
  if v_mders is null then
    raise exception 'Bu ders için müfredat eşlemesi yok' using errcode = '22023';
  end if;

  v_bugun := public.mufredat_bugun_hafta(p_tarih);
  v_ust := case when p_mod = 'hafta' then least(p_hafta, v_bugun) else v_bugun end;

  return query
    select jsonb_build_object(
             'id', q.id,
             'ders', q.ders,
             'konu', q.konu,
             'alt_konu', q.alt_konu,
             'zorluk', q.zorluk,
             'soru_metni', q.soru_metni,
             'siklar', q.siklar,
             'kazanim_kodu', q.kazanim_kodu,
             'hafta', o.ilk_hafta)
      from public.questions q
      join public.mufredat_kazanim_ozet o
        on o.kazanim_kodu = q.kazanim_kodu and o.ders = v_mders and o.sinif = v_sinif
      left join public.user_answers ua
        on ua.question_id = q.id and ua.student_id = v_uid
     where q.ders = p_ders
       and q.sinif = v_sinif
       and q.onay_durumu = 'onaylandi'
       and q.kazanim_kodu is not null
       and q.kazanim_kodu <> ''
       and o.ilk_hafta <= v_ust
       and (p_mod <> 'bu_hafta' or o.ilk_hafta = v_bugun)
       and (p_mod <> 'kazanim' or o.kazanim_kodu = any (p_kazanim_kodlari))
     order by case when ua.id is null then 1
                   when ua.sonraki_tekrar_tarihi <= now() then 0
                   else 2 end,
              random()
     limit v_limit;
end;
$$;

revoke execute on function public.get_mufredat_sorulari(text, text, int, text[], int, date) from public, anon;
grant  execute on function public.get_mufredat_sorulari(text, text, int, text[], int, date) to authenticated;

-- ---------------------------------------------------------------------
-- 3. admin_set_question_kazanim — kazanımı toplu ata / kaldır (p_kod null)
--    Kod, sorunun sınıfı + eşlenmiş dersi için müfredatta yoksa HATA (hiçbiri yazılmaz).
--    Değişiklik question_revisions'a (moderasyon izi) yazılır.
-- ---------------------------------------------------------------------
create or replace function public.admin_set_question_kazanim(p_ids uuid[], p_kod text)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_kod   text := nullif(btrim(coalesce(p_kod, '')), '');
  v_rec   record;
  v_say   bigint;
  v_metin text;
  v_adet  integer := 0;
begin
  perform public.require_admin();

  if p_ids is null or cardinality(p_ids) = 0 then
    raise exception 'Soru seçilmedi' using errcode = '22023';
  end if;

  for v_rec in
    select q.id, q.ders, q.sinif, q.kazanim_kodu, q.kazanim_metni, to_jsonb(q) as eski
      from public.questions q
     where q.id = any (p_ids)
  loop
    v_metin := null;
    if v_kod is not null then
      select count(*), min(h.kazanim_metni) into v_say, v_metin
        from public.mufredat_ders_eslesme e
        join public.mufredat_hafta h
          on h.ders = e.mufredat_ders and h.sinif = v_rec.sinif
         and h.kaynak_yili = '2026-2027' and h.kazanim_kodu = v_kod
       where e.soru_ders = v_rec.ders;

      if v_say = 0 then
        raise exception 'Kazanım % bu soru için müfredatta yok (sınıf %, ders %)',
          v_kod, v_rec.sinif, v_rec.ders using errcode = '22023';
      end if;
    end if;

    if v_rec.kazanim_kodu is distinct from v_kod
       or v_rec.kazanim_metni is distinct from v_metin then
      insert into public.question_revisions (question_id, revised_by, old_data, degisen_alanlar)
      values (
        v_rec.id,
        (select auth.uid()),
        v_rec.eski,
        array_remove(array[
          case when v_rec.kazanim_kodu is distinct from v_kod then 'kazanim_kodu' end,
          case when v_rec.kazanim_metni is distinct from v_metin then 'kazanim_metni' end
        ], null)
      );

      update public.questions
         set kazanim_kodu = v_kod,
             kazanim_metni = v_metin
       where id = v_rec.id;

      v_adet := v_adet + 1;
    end if;
  end loop;

  perform public.log_admin_action('soru_kazanim_atandi',
    jsonb_build_object('adet', v_adet, 'kod', v_kod));

  return v_adet;
end;
$$;

revoke execute on function public.admin_set_question_kazanim(uuid[], text) from public, anon;
grant  execute on function public.admin_set_question_kazanim(uuid[], text) to authenticated;

-- ---------------------------------------------------------------------
-- 4. admin_kazanim_kapsam — ders + sınıf için kazanım × onaylı/bekleyen soru sayısı
--    sinav*_ort yalnız 5–8. sınıfta (mufredat_sinav_dagilim, 20261084).
-- ---------------------------------------------------------------------
create or replace function public.admin_kazanim_kapsam(p_ders text, p_sinif int)
returns table (
  kazanim_kodu  text,
  kazanim_metni text,
  ilk_hafta     int,
  unite_tema    text,
  onayli_soru   bigint,
  bekleyen_soru bigint,
  sinav1_ort    numeric,
  sinav2_ort    numeric
)
language plpgsql
stable
security definer
set search_path = ''
as $$
#variable_conflict use_column
declare
  v_mders text;
begin
  perform public.require_admin();

  if p_sinif is null or p_sinif < 1 or p_sinif > 12 then
    raise exception 'Sınıf 1 ile 12 arasında olmalı' using errcode = '22023';
  end if;

  select e.mufredat_ders into v_mders
    from public.mufredat_ders_eslesme e
   where e.soru_ders = p_ders;
  if v_mders is null then
    raise exception 'Bu ders için müfredat eşlemesi yok' using errcode = '22023';
  end if;

  return query
    select o.kazanim_kodu,
           o.kazanim_metni,
           o.ilk_hafta::int,
           o.unite_tema,
           qc.onayli,
           qc.bekleyen,
           case when p_sinif between 5 and 8 then sv.s1 end,
           case when p_sinif between 5 and 8 then sv.s2 end
      from public.mufredat_kazanim_ozet o
      left join lateral (
        select count(*) filter (where q.onay_durumu = 'onaylandi') as onayli,
               count(*) filter (where q.onay_durumu = 'beklemede') as bekleyen
          from public.questions q
         where q.ders = p_ders
           and q.sinif = p_sinif
           and q.kazanim_kodu = o.kazanim_kodu
      ) qc on true
      left join lateral (
        select avg(d.soru_sayisi) filter (where d.sinav = '1. Dönem 1. Ortak Yazılı Sınav') as s1,
               avg(d.soru_sayisi) filter (where d.sinav = '1. Dönem 2. Ortak Yazılı Sınav') as s2
          from public.mufredat_sinav_dagilim d
         where d.ders = v_mders
           and d.sinif = p_sinif
           and d.kazanim_kodu = o.kazanim_kodu
      ) sv on true
     where o.ders = v_mders
       and o.sinif = p_sinif
     order by o.ilk_hafta, o.kazanim_kodu;
end;
$$;

revoke execute on function public.admin_kazanim_kapsam(text, int) from public, anon;
grant  execute on function public.admin_kazanim_kapsam(text, int) to authenticated;

-- ---------------------------------------------------------------------
-- 5. admin_kazanimsiz_sorular — kazanım kodu boş soruların listesi (sayfalı)
-- ---------------------------------------------------------------------
create or replace function public.admin_kazanimsiz_sorular(
  p_ders   text default null,
  p_sinif  int default null,
  p_limit  int default 50,
  p_offset int default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_limit  integer := least(greatest(coalesce(p_limit, 50), 1), 200);
  v_offset integer := greatest(coalesce(p_offset, 0), 0);
  v_toplam integer;
  v_satir  jsonb;
begin
  perform public.require_admin();

  select count(*)::integer into v_toplam
    from public.questions q
   where (q.kazanim_kodu is null or q.kazanim_kodu = '')
     and (p_ders is null or q.ders = p_ders)
     and (p_sinif is null or q.sinif = p_sinif);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.sinif, x.ders, x.created_at, x.id), '[]'::jsonb)
    into v_satir
    from (
      select q.id, q.sinif, q.ders, q.konu, q.alt_konu, q.zorluk, q.soru_metni,
             q.onay_durumu, q.created_at
        from public.questions q
       where (q.kazanim_kodu is null or q.kazanim_kodu = '')
         and (p_ders is null or q.ders = p_ders)
         and (p_sinif is null or q.sinif = p_sinif)
       order by q.sinif, q.ders, q.created_at, q.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('toplam', v_toplam, 'satirlar', v_satir);
end;
$$;

revoke execute on function public.admin_kazanimsiz_sorular(text, int, int, int) from public, anon;
grant  execute on function public.admin_kazanimsiz_sorular(text, int, int, int) to authenticated;
