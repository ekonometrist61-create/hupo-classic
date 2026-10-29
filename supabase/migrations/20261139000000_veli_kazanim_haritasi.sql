-- =====================================================================
--  F2 · Veli kazanım haritası (docs/veli-ogretmen-paneli/AR-GE_VE_PLAN_2026-10-29.md §6, §7)
--  public.veli_kazanim_haritasi(p_cocuk_id, p_ders)
--    * Yalnız çocuğun velisi çağırabilir; veli rızası 'verildi' değilse veri dönmez.
--    * Kazanım başına: soru sayısı, cevap sayısı, farklı gün, kalıcılık, durum.
--    * Durum (öneri, pilotla kalibre edilir):
--        veri_yok   : < 6 cevap
--        gelisiyor  : doğru oranı < %60
--        guclu      : >= %80 VE >= 2 farklı gün VE en az 1 aralıklı tekrarda doğru
--        pekisiyor  : diğer
--    * 1–4. sınıfta sayısal oran DÖNMEZ (oran = null); yalnız nitel durum (GÖR-058 ilkesi).
--    * Tahmin, puan veya yeterlilik iddiası yok.
--  Yalnız okuma. Yeni tablo yok. Bu dosya UZAKTA UYGULANMADI.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function public.veli_kazanim_haritasi(p_cocuk_id uuid, p_ders text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid    uuid := (select auth.uid());
  v_riza   text;
  v_sinif  smallint;
  v_mders  text;
  v_bugun  smallint;
  v_sonuc  jsonb;
begin
  if v_uid is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'Bu öğrencinin verilerine erişim yetkiniz yok' using errcode = '42501';
  end if;
  if nullif(btrim(coalesce(p_ders, '')), '') is null then
    raise exception 'Ders seçilmedi' using errcode = '22023';
  end if;

  v_riza := public._veli_riza_durumu(p_cocuk_id);
  if v_riza <> 'verildi' then
    return jsonb_build_object('riza', v_riza, 'kazanimlar', '[]'::jsonb);
  end if;

  select p.sinif into v_sinif from public.profiles p where p.id = p_cocuk_id;
  if v_sinif is null then
    return jsonb_build_object('riza', v_riza, 'sinif', null, 'kazanimlar', '[]'::jsonb);
  end if;

  select e.mufredat_ders into v_mders
    from public.mufredat_ders_eslesme e where e.soru_ders = p_ders;
  if v_mders is null then
    return jsonb_build_object('riza', v_riza, 'sinif', v_sinif, 'plan_var', false, 'kazanimlar', '[]'::jsonb);
  end if;

  v_bugun := public.mufredat_bugun_hafta(null);

  with kazanim as (
    select o.kazanim_kodu, o.kazanim_metni, o.ilk_hafta, o.unite_tema
      from public.mufredat_kazanim_ozet o
     where o.ders = v_mders and o.sinif = v_sinif
  ),
  sorular as (
    select q.id, q.kazanim_kodu
      from public.questions q
     where q.ders = p_ders and q.sinif = v_sinif
       and q.onay_durumu = 'onaylandi'
       and q.kazanim_kodu is not null and q.kazanim_kodu <> ''
  ),
  cevap as (
    select s.kazanim_kodu,
           count(*)                                                        as n,
           count(*) filter (where ae.dogru_mu)                             as d,
           count(distinct (ae.created_at at time zone 'Europe/Istanbul')::date) as gun
      from public.answer_events ae
      join sorular s on s.id = ae.question_id
     where ae.student_id = p_cocuk_id
     group by s.kazanim_kodu
  ),
  kalici as (
    select s.kazanim_kodu, count(*) as k
      from public.user_answers ua
      join sorular s on s.id = ua.question_id
     where ua.student_id = p_cocuk_id and ua.tekrar_sayisi >= 1 and ua.dogru_mu
     group by s.kazanim_kodu
  ),
  soru_say as (
    select kazanim_kodu, count(*) as adet from sorular group by kazanim_kodu
  ),
  satir as (
    select k.ilk_hafta, k.kazanim_kodu, k.kazanim_metni, k.unite_tema,
           coalesce(ss.adet, 0)::int as soru_sayisi,
           coalesce(c.n, 0)::int     as cevap,
           coalesce(c.gun, 0)::int   as gun,
           coalesce(kl.k, 0)::int    as kalici,
           case when coalesce(c.n, 0) >= 6 then 100.0 * c.d / c.n end as oran
      from kazanim k
      left join soru_say ss on ss.kazanim_kodu = k.kazanim_kodu
      left join cevap c     on c.kazanim_kodu  = k.kazanim_kodu
      left join kalici kl   on kl.kazanim_kodu = k.kazanim_kodu
  )
  select jsonb_build_object(
           'riza', v_riza,
           'sinif', v_sinif,
           'ders', p_ders,
           'bugun_hafta', v_bugun,
           'plan_var', true,
           'kazanimlar', coalesce(jsonb_agg(
             jsonb_build_object(
               'kod', r.kazanim_kodu,
               'metin', r.kazanim_metni,
               'unite_tema', r.unite_tema,
               'ilk_hafta', r.ilk_hafta,
               'bu_hafta_mi', (r.ilk_hafta = v_bugun),
               'islendi_mi', (v_bugun is not null and r.ilk_hafta <= v_bugun),
               'soru_sayisi', r.soru_sayisi,
               'cevap', r.cevap,
               'farkli_gun', r.gun,
               'kalici_dogru', r.kalici,
               'oran', case when v_sinif >= 5 and r.oran is not null then round(r.oran)::int end,
               'durum', case
                 when r.cevap < 6 then 'veri_yok'
                 when r.oran < 60 then 'gelisiyor'
                 when r.oran >= 80 and r.gun >= 2 and r.kalici >= 1 then 'guclu'
                 else 'pekisiyor' end
             ) order by r.ilk_hafta, r.kazanim_kodu), '[]'::jsonb))
    into v_sonuc
    from satir r;

  return v_sonuc;
end;
$$;

revoke execute on function public.veli_kazanim_haritasi(uuid, text) from public, anon;
grant  execute on function public.veli_kazanim_haritasi(uuid, text) to authenticated;
