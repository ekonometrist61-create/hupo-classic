-- =====================================================================
-- Okuma Dünyası — F1 (4/4): veli ve öğretmen RPC'leri
--   * Veli: değer listesi / öncelik (≤5), çocuk özeti. Özet: is_parent_of + veli rızası SUNUCUDA
--     (rıza yoksa {riza, ozet:null}); min-N (soru doğruluğu ≥3 soru, çocuk puanı ≥3 oy);
--     premium/deneme ise ayrıntılı, değilse temel. Cinsiyet kırılımı HİÇBİR çıktıda yoktur.
--   * Öğretmen: sınıf toplulaştırması; çocuk kimliği/adı yok; en az 3 öğrenci.
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Değerler
-- ---------------------------------------------------------------------
create or replace function public.okuma_degerleri_listele()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null or public.current_user_role() not in ('veli', 'admin') then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;
  return coalesce((
    select jsonb_agg(jsonb_build_object('kod', s.anahtar, 'ad', s.ad)
                     order by substring(s.anahtar from 2)::integer)
      from public.okuma_etiket_sozlugu s where s.tur = 'deger' and s.aktif), '[]'::jsonb);
end;
$$;

revoke all on function public.okuma_degerleri_listele() from public, anon;
grant execute on function public.okuma_degerleri_listele() to authenticated;

create or replace function public.okuma_veli_degerleri_getir(p_cocuk_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;
  return jsonb_build_object('degerler', to_jsonb(coalesce(
    (select t.degerler from public.okuma_cocuk_tercihleri t where t.cocuk_id = p_cocuk_id), '{}'::text[])));
end;
$$;

revoke all on function public.okuma_veli_degerleri_getir(uuid) from public, anon;
grant execute on function public.okuma_veli_degerleri_getir(uuid) to authenticated;

create or replace function public.okuma_veli_degerleri_ayarla(p_cocuk_id uuid, p_degerler text[])
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_d   text[] := coalesce(p_degerler, '{}');
begin
  if v_uid is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;
  if cardinality(v_d) > 5 then
    raise exception 'EN_FAZLA_BES' using errcode = '22023';
  end if;
  if (select count(distinct x) from unnest(v_d) x) <> cardinality(v_d) then
    raise exception 'TEKRARLI_DEGER' using errcode = '22023';
  end if;
  if exists (select 1 from unnest(v_d) x
              where x is null or not exists (select 1 from public.okuma_etiket_sozlugu s
                                              where s.tur = 'deger' and s.aktif and s.anahtar = x)) then
    raise exception 'GECERSIZ_DEGER' using errcode = '22023';
  end if;

  insert into public.okuma_cocuk_tercihleri (cocuk_id, degerler, guncelleyen_veli_id, guncellendi_at)
  values (p_cocuk_id, v_d, v_uid, now())
  on conflict (cocuk_id) do update
    set degerler = excluded.degerler, guncelleyen_veli_id = excluded.guncelleyen_veli_id,
        guncellendi_at = now();

  return jsonb_build_object('degerler', to_jsonb(v_d));
end;
$$;

revoke all on function public.okuma_veli_degerleri_ayarla(uuid, text[]) from public, anon;
grant execute on function public.okuma_veli_degerleri_ayarla(uuid, text[]) to authenticated;

-- ---------------------------------------------------------------------
-- 2. Veli özeti
-- ---------------------------------------------------------------------
create or replace function public.okuma_veli_ozeti(p_cocuk_id uuid, p_gun integer default 30)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := (select auth.uid());
  v_gun     integer := least(greatest(coalesce(p_gun, 30), 1), 365);
  v_riza    text;
  v_basla   timestamptz;
  v_detay   boolean;
  v_okunan  integer;
  v_tamam   integer;
  v_oy      integer;
  v_ozet    jsonb;
begin
  -- Yetki: yalnızca bağlı veli. Rıza yoksa özet hesaplanmaz.
  if v_uid is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;

  v_riza := public._veli_riza_durumu(p_cocuk_id);
  if v_riza is distinct from 'verildi' then
    return jsonb_build_object('riza', false, 'riza_durumu', v_riza, 'ozet', null);
  end if;

  v_basla := now() - make_interval(days => v_gun);
  v_detay := public.is_premium(p_cocuk_id) or public._deneme_aktif(p_cocuk_id);

  select count(distinct o.hikaye_id)::integer,
         count(distinct o.hikaye_id) filter (where o.tamamlandi_at is not null)::integer
    into v_okunan, v_tamam
    from public.okuma_oturumlari o
   where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla;

  v_ozet := jsonb_build_object('gun', v_gun, 'detay', v_detay, 'okunan_hikaye', v_okunan, 'tamamlanan_hikaye', v_tamam);

  if v_detay then
    select count(*)::integer into v_oy
      from public.okuma_geri_bildirimleri g join public.okuma_oturumlari o on o.id = g.oturum_id
     where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla;

    v_ozet := v_ozet || jsonb_build_object(
      'ortalama_sure_dk', (select round(avg(least(extract(epoch from (o.tamamlandi_at - o.baslangic_at)) / 60.0, 30))::numeric, 1)
                             from public.okuma_oturumlari o
                            where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla and o.tamamlandi_at is not null),
      -- Soru doğruluğu işlem türüne göre; asgari 3 soru, altında oran verilmez
      'soru_dogrulugu', (
        select jsonb_object_agg(b.beceri,
                 case when coalesce(x.n, 0) >= 3
                      then jsonb_build_object('yeterli', true, 'soru', x.n, 'dogru', x.d, 'oran', round(100.0 * x.d / x.n, 0))
                      else jsonb_build_object('yeterli', false) end)
          from unnest(array['hatirlama', 'cikarim', 'yorumlama', 'degerlendirme', 'sozcuk_baglami']) as b(beceri)
          left join (
            select c.beceri, count(*)::integer as n, count(*) filter (where c.dogru)::integer as d
              from public.okuma_cevaplari c join public.okuma_oturumlari o on o.id = c.oturum_id
             where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla
             group by c.beceri) x on x.beceri = b.beceri),
      'tema_dagilimi', (
        select coalesce(jsonb_agg(jsonb_build_object('tema', t.tema, 'ad', s.ad, 'hikaye', t.adet) order by t.adet desc, t.tema), '[]'::jsonb)
          from (select tm as tema, count(distinct o.hikaye_id)::integer as adet
                  from public.okuma_oturumlari o join public.okuma_hikaye_etiketleri e on e.surum_id = o.surum_id
                  cross join lateral unnest(e.temalar) tm
                 where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla group by tm) t
          left join public.okuma_etiket_sozlugu s on s.tur = 'tema' and s.anahtar = t.tema),
      'deger_dagilimi', (
        select coalesce(jsonb_agg(jsonb_build_object('deger', t.deger, 'ad', s.ad, 'hikaye', t.adet) order by t.adet desc, t.deger), '[]'::jsonb)
          from (select dg as deger, count(distinct o.hikaye_id)::integer as adet
                  from public.okuma_oturumlari o join public.okuma_hikaye_etiketleri e on e.surum_id = o.surum_id
                  cross join lateral unnest(array_remove(array[e.ana_deger, e.yardimci_deger], null)) dg
                 where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla group by dg) t
          left join public.okuma_etiket_sozlugu s on s.tur = 'deger' and s.anahtar = t.deger),
      'ders_dagilimi', (
        select coalesce(jsonb_agg(jsonb_build_object('ders', t.ders, 'ad', s.ad, 'hikaye', t.adet) order by t.adet desc, t.ders), '[]'::jsonb)
          from (select dr as ders, count(distinct o.hikaye_id)::integer as adet
                  from public.okuma_oturumlari o join public.okuma_hikaye_etiketleri e on e.surum_id = o.surum_id
                  cross join lateral unnest(e.ders_baglantisi) dr
                 where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla group by dr) t
          left join public.okuma_etiket_sozlugu s on s.tur = 'ders' and s.anahtar = t.ders),
      'zorluk_seyri', (
        select coalesce(jsonb_agg(jsonb_build_object('hafta', w.hafta, 'hikaye', w.adet,
                 'ort_okuma_zorlugu', w.okuma, 'ort_kavram_zorlugu', w.kavram) order by w.hafta), '[]'::jsonb)
          from (select date_trunc('week', o.baslangic_at at time zone 'Europe/Istanbul')::date as hafta,
                       count(distinct o.hikaye_id)::integer as adet,
                       round(avg(e.okuma_zorlugu)::numeric, 1) as okuma, round(avg(e.kavram_zorlugu)::numeric, 1) as kavram
                  from public.okuma_oturumlari o join public.okuma_hikaye_etiketleri e on e.surum_id = o.surum_id
                 where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla group by 1) w),
      -- Hedef durumları: hikâyeyi okumak "öğrendi" değildir; kalıcılık yalnız gecikmeli doğru cevapla yükselir
      'hedef_durumlari', (
        select coalesce(jsonb_object_agg(d.durum, d.adet), '{}'::jsonb)
          from (select durum, count(*)::integer as adet from public.okuma_ogrenci_hedef_durumu
                 where ogrenci_id = p_cocuk_id group by durum) d),
      'pekisen_hedefler', (
        select coalesce(jsonb_agg(jsonb_build_object('hedef_id', h.id, 'etiket', h.etiket, 'durum', d.durum)
                                  order by d.son_dogru_at desc), '[]'::jsonb)
          from (select * from public.okuma_ogrenci_hedef_durumu
                 where ogrenci_id = p_cocuk_id and durum in ('retrieved', 'transferred')
                 order by son_dogru_at desc limit 10) d
          join public.okuma_ogrenme_hedefleri h on h.id = d.hedef_id),
      -- Çocuğun verdiği puan: asgari 3 oy
      'cocuk_puani', case when v_oy >= 3 then jsonb_build_object(
          'oy', v_oy,
          'ortalama', (select round(avg(g.yildiz)::numeric, 1) from public.okuma_geri_bildirimleri g
                         join public.okuma_oturumlari o on o.id = g.oturum_id
                        where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla),
          'sevilen_temalar', (select coalesce(jsonb_agg(q.tema order by q.adet desc, q.tema), '[]'::jsonb) from (
              select tm as tema, count(*)::integer as adet
                from public.okuma_geri_bildirimleri g join public.okuma_oturumlari o on o.id = g.oturum_id
                join public.okuma_hikaye_etiketleri e on e.surum_id = o.surum_id
                cross join lateral unnest(e.temalar) tm
               where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla and g.yildiz >= 4
               group by tm order by adet desc, tm limit 3) q))
        else jsonb_build_object('oy', v_oy, 'ortalama', null, 'sevilen_temalar', '[]'::jsonb) end);
  end if;

  return jsonb_build_object('riza', true, 'riza_durumu', v_riza, 'ozet', v_ozet);
end;
$$;

revoke all on function public.okuma_veli_ozeti(uuid, integer) from public, anon;
grant execute on function public.okuma_veli_ozeti(uuid, integer) to authenticated;

-- ---------------------------------------------------------------------
-- 3. Öğretmen sınıf özeti (toplulaştırma; en az 3 öğrenci; çocuk kimliği/adı yok)
-- ---------------------------------------------------------------------
create or replace function public.okuma_ogretmen_sinif_ozeti(p_sinif_id uuid, p_gun integer default 30)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid    uuid := (select auth.uid());
  v_rol    text;
  v_gun    integer := least(greatest(coalesce(p_gun, 30), 1), 365);
  v_basla  timestamptz;
  v_esik   integer := 3;
  v_sinif  record;
  v_uye    integer;
  v_okuyan integer;
  v_ozet   jsonb := null;
begin
  if v_uid is null then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;
  v_rol := public.current_user_role();
  if v_rol is distinct from 'ogretmen' and v_rol is distinct from 'admin' then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;

  select s.id, s.ad, s.sinif_seviyesi, s.ogretmen_id into v_sinif from public.siniflar s where s.id = p_sinif_id;
  if not found or (v_rol = 'ogretmen' and v_sinif.ogretmen_id is distinct from v_uid) then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;

  v_basla := now() - make_interval(days => v_gun);
  select count(*)::integer into v_uye from public.sinif_uyelikleri u where u.sinif_id = p_sinif_id;
  select count(distinct o.ogrenci_id)::integer into v_okuyan
    from public.okuma_oturumlari o join public.sinif_uyelikleri u on u.ogrenci_id = o.ogrenci_id and u.sinif_id = p_sinif_id
   where o.baslangic_at >= v_basla;

  if v_okuyan >= v_esik then
    v_ozet := jsonb_build_object(
      'oturum_sayisi', (select count(*)::integer from public.okuma_oturumlari o
                          join public.sinif_uyelikleri u on u.ogrenci_id = o.ogrenci_id and u.sinif_id = p_sinif_id
                         where o.baslangic_at >= v_basla),
      'tamamlama_orani', (select round(100.0 * count(*) filter (where o.tamamlandi_at is not null) / nullif(count(*), 0), 0)
                            from public.okuma_oturumlari o
                            join public.sinif_uyelikleri u on u.ogrenci_id = o.ogrenci_id and u.sinif_id = p_sinif_id
                           where o.baslangic_at >= v_basla),
      -- İşlem türüne göre anlama: en az 3 soru ve en az 3 farklı öğrenci
      'soru_dogrulugu', (
        select jsonb_object_agg(b.beceri,
                 case when coalesce(x.n, 0) >= 3 and coalesce(x.ogr, 0) >= v_esik
                      then jsonb_build_object('yeterli', true, 'soru', x.n, 'oran', round(100.0 * x.d / x.n, 0))
                      else jsonb_build_object('yeterli', false) end)
          from unnest(array['hatirlama', 'cikarim', 'yorumlama', 'degerlendirme', 'sozcuk_baglami']) as b(beceri)
          left join (
            select c.beceri, count(*)::integer as n, count(*) filter (where c.dogru)::integer as d,
                   count(distinct o.ogrenci_id)::integer as ogr
              from public.okuma_cevaplari c
              join public.okuma_oturumlari o on o.id = c.oturum_id
              join public.sinif_uyelikleri u on u.ogrenci_id = o.ogrenci_id and u.sinif_id = p_sinif_id
             where o.baslangic_at >= v_basla group by c.beceri) x on x.beceri = b.beceri),
      -- Zorlanılan hedefler: yanlış oranı yüksek olanlar; hedef başına en az 3 öğrenci
      'zorlanilan_hedefler', (
        select coalesce(jsonb_agg(jsonb_build_object('hedef_id', z.hedef_id, 'etiket', h.etiket,
                 'yanlis_orani', z.yanlis_orani, 'ogrenci_sayisi', z.ogr) order by z.yanlis_orani desc, z.hedef_id), '[]'::jsonb)
          from (select c.hedef_id, count(distinct o.ogrenci_id)::integer as ogr,
                       round(100.0 * count(*) filter (where not c.dogru) / count(*), 0) as yanlis_orani
                  from public.okuma_cevaplari c
                  join public.okuma_oturumlari o on o.id = c.oturum_id
                  join public.sinif_uyelikleri u on u.ogrenci_id = o.ogrenci_id and u.sinif_id = p_sinif_id
                 where o.baslangic_at >= v_basla and c.hedef_id is not null
                 group by c.hedef_id
                having count(distinct o.ogrenci_id) >= v_esik and count(*) filter (where not c.dogru) > 0
                 order by yanlis_orani desc, c.hedef_id limit 5) z
          join public.okuma_ogrenme_hedefleri h on h.id = z.hedef_id),
      -- Tema ilgisi: temada en az 3 farklı öğrenci
      'tema_ilgisi', (
        select coalesce(jsonb_agg(jsonb_build_object('tema', t.tema, 'ad', s.ad, 'ogrenci_sayisi', t.ogr, 'hikaye_sayisi', t.hik)
                                  order by t.ogr desc, t.tema), '[]'::jsonb)
          from (select tm as tema, count(distinct o.ogrenci_id)::integer as ogr, count(distinct o.hikaye_id)::integer as hik
                  from public.okuma_oturumlari o
                  join public.sinif_uyelikleri u on u.ogrenci_id = o.ogrenci_id and u.sinif_id = p_sinif_id
                  join public.okuma_hikaye_etiketleri e on e.surum_id = o.surum_id
                  cross join lateral unnest(e.temalar) tm
                 where o.baslangic_at >= v_basla
                 group by tm having count(distinct o.ogrenci_id) >= v_esik) t
          left join public.okuma_etiket_sozlugu s on s.tur = 'tema' and s.anahtar = t.tema));
  end if;

  return jsonb_build_object(
    'sinif', jsonb_build_object('id', v_sinif.id, 'ad', v_sinif.ad, 'sinif_seviyesi', v_sinif.sinif_seviyesi),
    'gun', v_gun, 'ogrenci_sayisi', v_uye, 'okuyan_ogrenci', v_okuyan,
    'yeterli', v_okuyan >= v_esik, 'min_n', v_esik, 'ozet', v_ozet);
end;
$$;

revoke all on function public.okuma_ogretmen_sinif_ozeti(uuid, integer) from public, anon;
grant execute on function public.okuma_ogretmen_sinif_ozeti(uuid, integer) to authenticated;
