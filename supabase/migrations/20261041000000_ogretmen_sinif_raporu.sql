-- =====================================================================
-- Öğretmen sınıf raporu (TASKS §20, K2: salt okunur)
--
-- public.ogretmen_siniflarim(): öğretmenin kendi sınıflarını (admin için tüm sınıfları)
-- ve her sınıfın TOPLU ilerleme özetini döner. Kişisel veri (ad, e-posta, öğrenci kimliği)
-- çıktıya girmez.
--
-- İlerleme değerleri (ortalama doğru oranı, tekrar bekleyen, son etkinlik, son 7 gün aktif)
-- sınıfta en az 3 cevaplayan öğrenci olduğunda gösterilir. Daha küçük gruplarda tek bir
-- öğrencinin verisi sınıf ortalamasından çıkarılabilir; bu yüzden değerler null kalır ve
-- ilerleme_gosterilir = false döner.
--
-- Yalnızca okuma. Sınıf yazma admin_upsert_sinif üzerinden ve yalnızca admin'dedir.
-- Yeni tablo yok; mevcut siniflar, sinif_uyelikleri ve user_answers okunur.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function public.ogretmen_siniflarim()
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid   uuid := (select auth.uid());
  v_rol   text;
  v_esik  integer := 3;   -- ilerleme değerleri için en az cevaplayan öğrenci sayısı
  v_satir jsonb;
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı' using errcode = '42501';
  end if;

  select p.role into v_rol from public.profiles p where p.id = v_uid;
  if v_rol is distinct from 'ogretmen' and v_rol is distinct from 'admin' then
    raise exception 'Bu işlem için öğretmen veya admin yetkisi gerekir' using errcode = '42501';
  end if;

  with kapsam as (
    -- Öğretmen yalnızca kendi sınıflarını görür; admin hepsini görür.
    select s.id, s.ad, s.sinif_seviyesi, s.okul_adi, s.yil, s.aktif
      from public.siniflar s
     where v_rol = 'admin' or s.ogretmen_id = v_uid
  ),
  ogrenci_ozet as (
    -- Üye başına toplamlar. ogrenci_id yalnızca gruplama için kullanılır, çıktıya girmez.
    select k.id as sinif_id,
           u.ogrenci_id,
           sum(ua.deneme_sayisi)::int                                      as deneme,
           sum(ua.dogru_sayisi)::int                                       as dogru,
           count(*) filter (where ua.sonraki_tekrar_tarihi <= now())::int  as bekleyen,
           max(ua.son_cevap_tarihi)                                        as son_cevap
      from kapsam k
      join public.sinif_uyelikleri u on u.sinif_id = k.id
      join public.user_answers ua on ua.student_id = u.ogrenci_id
     group by k.id, u.ogrenci_id
  ),
  sinif_ozet as (
    select o.sinif_id,
           count(*)::int                                                          as cevaplayan,
           count(*) filter (where o.son_cevap >= now() - interval '7 days')::int  as aktif_7g,
           round(avg(100.0 * o.dogru / nullif(o.deneme, 0)))::int                 as ortalama_dogru_orani,
           sum(o.bekleyen)::int                                                   as bekleyen_tekrar,
           max(o.son_cevap)                                                       as son_aktivite
      from ogrenci_ozet o
     group by o.sinif_id
  )
  select coalesce(jsonb_agg(to_jsonb(x) order by x.yil desc, x.sinif_seviyesi, x.ad), '[]'::jsonb)
    into v_satir
    from (
      select k.id,
             k.ad,
             k.sinif_seviyesi,
             k.okul_adi,
             k.yil,
             k.aktif,
             (select count(*)::int from public.sinif_uyelikleri u where u.sinif_id = k.id) as ogrenci_sayisi,
             coalesce(z.cevaplayan, 0) >= v_esik as ilerleme_gosterilir,
             case when coalesce(z.cevaplayan, 0) >= v_esik then z.aktif_7g end               as aktif_ogrenci_7g,
             case when coalesce(z.cevaplayan, 0) >= v_esik then z.ortalama_dogru_orani end    as ortalama_dogru_orani,
             case when coalesce(z.cevaplayan, 0) >= v_esik then z.bekleyen_tekrar end         as bekleyen_tekrar,
             case when coalesce(z.cevaplayan, 0) >= v_esik then z.son_aktivite end            as son_aktivite
        from kapsam k
        left join sinif_ozet z on z.sinif_id = k.id
    ) x;

  return jsonb_build_object('siniflar', v_satir);
end;
$$;

revoke execute on function public.ogretmen_siniflarim() from public, anon;
grant  execute on function public.ogretmen_siniflarim() to authenticated;
