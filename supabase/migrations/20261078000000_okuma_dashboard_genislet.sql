-- =====================================================================
-- Okuma Dünyası — dashboard genişletmesi (Faz 3, 20261065 üzerine; create or replace, mevcut anahtarlar AYNEN korunur)
--   Çocuk özeti (_okuma_cocuk_ozet; veli + öğretmenin bireysel özeti ortak):
--     * soru_dogrulugu / olcme_turu_dogrulugu içinde yanlis (= soru - dogru) eklenir.
--     * dogruluk_toplami: tüm sorularda soru/dogru/yanlis (asgari 3 soru).
--     * kavramlar / atasozleri / kelimeler satırlarına dönem içi soru/dogru/yanlis (hedefe bağlı sorular) eklenir.
--     * hedef listesi imzası (uuid, text[], integer) olur; eski 2 argümanlı iç yardımcı düşürülür.
--   Sınıf özeti (okuma_ogretmen_sinif_ozeti; yalnız min-N geçilince):
--     * soru_dogrulugu / olcme_turu_dogrulugu içinde dogru ve yanlis.
--     * dogruluk_toplami, zorluk_seyri (haftada en az 3 öğrenci olmayan hafta verilmez).
--     * kavram/atasözü/sözcük satırlarına taniyan_sayisi / hatirlayan_sayisi / aktaran_sayisi
--       (her biri en az 3 öğrenci değilse null; kimlik yok).
--   Yetki, rıza, min-N, grant kuralları değişmez. Bu dosya UZAKTA UYGULANMADI.
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Ortak çocuk özeti (iç yardımcı; istemciye açık DEĞİL)
-- ---------------------------------------------------------------------
create or replace function public._okuma_cocuk_ozet(p_cocuk_id uuid, p_gun integer, p_detay boolean)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_gun     integer := least(greatest(coalesce(p_gun, 30), 1), 365);
  v_basla   timestamptz := now() - make_interval(days => least(greatest(coalesce(p_gun, 30), 1), 365));
  v_okunan  integer;
  v_tamam   integer;
  v_oy      integer;
  v_kelime  integer;
  v_sure    numeric;
  v_ozet    jsonb;
begin
  select count(distinct o.hikaye_id)::integer,
         count(distinct o.hikaye_id) filter (where o.tamamlandi_at is not null)::integer
    into v_okunan, v_tamam
    from public.okuma_oturumlari o
   where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla;

  -- Okunan kelime: tamamlanan oturumların hikâye ölçümü (olculen.kelime_sayisi)
  select coalesce(sum(case when e.olculen ->> 'kelime_sayisi' ~ '^[0-9]{1,6}$'
                           then (e.olculen ->> 'kelime_sayisi')::integer else 0 end), 0)::integer
    into v_kelime
    from public.okuma_oturumlari o join public.okuma_hikaye_etiketleri e on e.surum_id = o.surum_id
   where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla and o.tamamlandi_at is not null;

  select coalesce(round(sum(least(extract(epoch from (o.tamamlandi_at - o.baslangic_at)) / 60.0, 30))::numeric, 0), 0)
    into v_sure
    from public.okuma_oturumlari o
   where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla and o.tamamlandi_at is not null;

  v_ozet := jsonb_build_object('gun', v_gun, 'detay', p_detay, 'okunan_hikaye', v_okunan, 'tamamlanan_hikaye', v_tamam,
                               'okunan_kelime', v_kelime, 'toplam_sure_dk', v_sure);

  if p_detay then
    select count(*)::integer into v_oy
      from public.okuma_geri_bildirimleri g join public.okuma_oturumlari o on o.id = g.oturum_id
     where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla;

    v_ozet := v_ozet || jsonb_build_object(
      'ortalama_sure_dk', (select round(avg(least(extract(epoch from (o.tamamlandi_at - o.baslangic_at)) / 60.0, 30))::numeric, 1)
                             from public.okuma_oturumlari o
                            where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla and o.tamamlandi_at is not null),
      'dogruluk_toplami', (
        select case when count(*) >= 3
                    then jsonb_build_object('yeterli', true, 'soru', count(*)::integer, 'dogru', (count(*) filter (where c.dogru))::integer,
                           'yanlis', (count(*) filter (where not c.dogru))::integer,
                           'oran', round(100.0 * count(*) filter (where c.dogru) / count(*), 0))
                    else jsonb_build_object('yeterli', false) end
          from public.okuma_cevaplari c join public.okuma_oturumlari o on o.id = c.oturum_id
         where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla),
      'soru_dogrulugu', (
        select jsonb_object_agg(b.beceri,
                 case when coalesce(x.n, 0) >= 3
                      then jsonb_build_object('yeterli', true, 'soru', x.n, 'dogru', x.d, 'yanlis', x.n - x.d, 'oran', round(100.0 * x.d / x.n, 0))
                      else jsonb_build_object('yeterli', false) end)
          from unnest(array['hatirlama', 'cikarim', 'yorumlama', 'degerlendirme', 'sozcuk_baglami']) as b(beceri)
          left join (
            select c.beceri, count(*)::integer as n, count(*) filter (where c.dogru)::integer as d
              from public.okuma_cevaplari c join public.okuma_oturumlari o on o.id = c.oturum_id
             where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla
             group by c.beceri) x on x.beceri = b.beceri),
      -- Soru türüne göre (metin kanıtı / kavram doğruluğu / transfer); asgari 3 soru
      'olcme_turu_dogrulugu', (
        select jsonb_object_agg(b.tur,
                 case when coalesce(x.n, 0) >= 3
                      then jsonb_build_object('yeterli', true, 'soru', x.n, 'dogru', x.d, 'yanlis', x.n - x.d, 'oran', round(100.0 * x.d / x.n, 0))
                      else jsonb_build_object('yeterli', false) end)
          from unnest(array['metin_kaniti', 'kavram_dogrulugu', 'transfer']) as b(tur)
          left join (
            select c.olcme_turu, count(*)::integer as n, count(*) filter (where c.dogru)::integer as d
              from public.okuma_cevaplari c join public.okuma_oturumlari o on o.id = c.oturum_id
             where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla and c.olcme_turu is not null
             group by c.olcme_turu) x on x.olcme_turu = b.tur),
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

    -- Yeni alanlar (Faz B)
    v_ozet := v_ozet || jsonb_build_object(
      -- Son 10 oturum: hangi hikâye, hangi tür, ne zaman, doğru/soru
      'son_hikayeler', (
        select coalesce(jsonb_agg(jsonb_build_object('hikaye_id', x.hikaye_id, 'baslik', x.baslik, 'tur', x.tur,
                 'tarih', x.baslangic_at, 'tamamlandi', x.tamam, 'dogru', x.dogru_sayisi, 'soru', x.soru_sayisi)
                 order by x.baslangic_at desc), '[]'::jsonb)
          from (select o.hikaye_id, s.baslik, s.tur, o.baslangic_at, (o.tamamlandi_at is not null) as tamam,
                       o.dogru_sayisi, o.soru_sayisi
                  from public.okuma_oturumlari o join public.okuma_hikaye_surumleri s on s.id = o.surum_id
                 where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla
                 order by o.baslangic_at desc limit 10) x),
      'tur_dagilimi', (
        select coalesce(jsonb_agg(jsonb_build_object('tur', t.tur, 'hikaye', t.hik, 'oturum', t.ot) order by t.hik desc, t.tur), '[]'::jsonb)
          from (select s.tur, count(distinct o.hikaye_id)::integer as hik, count(*)::integer as ot
                  from public.okuma_oturumlari o join public.okuma_hikaye_surumleri s on s.id = o.surum_id
                 where o.ogrenci_id = p_cocuk_id and o.baslangic_at >= v_basla group by s.tur) t),
      -- Öğrenme hedefleri türe göre: kavram / atasözü-deyim / sözcük. Durum "gördü/tanıdı/hatırladı" ayrımını taşır.
      'kavramlar', public._okuma_cocuk_hedef_listesi(p_cocuk_id, array['concept'], v_gun),
      'atasozleri', public._okuma_cocuk_hedef_listesi(p_cocuk_id, array['proverb', 'idiom'], v_gun),
      'kelimeler', public._okuma_cocuk_hedef_listesi(p_cocuk_id, array['lexeme'], v_gun));
  end if;

  return v_ozet;
end;
$$;

revoke all on function public._okuma_cocuk_ozet(uuid, integer, boolean) from public, anon, authenticated;

-- Çocuğun hedef listesi (tür filtreli): ad + durum + son görüldüğü hikâye
drop function if exists public._okuma_cocuk_hedef_listesi(uuid, text[]);

create or replace function public._okuma_cocuk_hedef_listesi(p_cocuk_id uuid, p_turler text[], p_gun integer)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(jsonb_agg(jsonb_build_object('hedef_id', q.id, 'etiket', q.etiket, 'tur', q.tur, 'durum', q.durum,
           'hikaye', q.hikaye, 'soru', q.soru, 'dogru', q.dogru, 'yanlis', q.soru - q.dogru)
           order by q.ilk_gorulme_at desc, q.id), '[]'::jsonb)
    from (select h.id, h.etiket, h.tur, d.durum, d.ilk_gorulme_at,
                 -- Dönem içinde bu hedefe bağlı soruların doğru/yanlış sayısı (hedef durumu ayrıca tüm zamanı yansıtır)
                 (select count(*)::integer from public.okuma_cevaplari c join public.okuma_oturumlari o on o.id = c.oturum_id
                   where o.ogrenci_id = p_cocuk_id and c.hedef_id = h.id
                     and o.baslangic_at >= now() - make_interval(days => least(greatest(coalesce(p_gun, 30), 1), 365))) as soru,
                 (select count(*) filter (where c.dogru)::integer from public.okuma_cevaplari c join public.okuma_oturumlari o on o.id = c.oturum_id
                   where o.ogrenci_id = p_cocuk_id and c.hedef_id = h.id
                     and o.baslangic_at >= now() - make_interval(days => least(greatest(coalesce(p_gun, 30), 1), 365))) as dogru,
                 (select s.baslik
                    from public.okuma_oturumlari o
                    join public.okuma_hikaye_hedefleri hh on hh.surum_id = o.surum_id and hh.hedef_id = h.id
                    join public.okuma_hikaye_surumleri s on s.id = o.surum_id
                   where o.ogrenci_id = p_cocuk_id
                   order by o.baslangic_at desc limit 1) as hikaye
            from public.okuma_ogrenci_hedef_durumu d
            join public.okuma_ogrenme_hedefleri h on h.id = d.hedef_id
           where d.ogrenci_id = p_cocuk_id and d.durum <> 'not_seen' and h.tur = any (p_turler)
           order by d.ilk_gorulme_at desc, h.id limit 50) q;
$$;

revoke all on function public._okuma_cocuk_hedef_listesi(uuid, text[], integer) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. Veli özeti (geriye uyumlu: aynı imza, aynı rıza ve premium kapısı)
-- ---------------------------------------------------------------------
create or replace function public.okuma_veli_ozeti(p_cocuk_id uuid, p_gun integer default 30)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := (select auth.uid());
  v_gun   integer := least(greatest(coalesce(p_gun, 30), 1), 365);
  v_riza  text;
  v_detay boolean;
begin
  -- Yetki: yalnızca bağlı veli. Rıza yoksa özet hesaplanmaz.
  if v_uid is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;

  v_riza := public._veli_riza_durumu(p_cocuk_id);
  if v_riza is distinct from 'verildi' then
    return jsonb_build_object('riza', false, 'riza_durumu', v_riza, 'ozet', null);
  end if;

  v_detay := public.is_premium(p_cocuk_id) or public._deneme_aktif(p_cocuk_id);

  return jsonb_build_object('riza', true, 'riza_durumu', v_riza,
                            'ozet', public._okuma_cocuk_ozet(p_cocuk_id, v_gun, v_detay));
end;
$$;

revoke all on function public.okuma_veli_ozeti(uuid, integer) from public, anon;
grant execute on function public.okuma_veli_ozeti(uuid, integer) to authenticated;

-- ---------------------------------------------------------------------
-- 3. Öğretmen sınıf özeti (geriye uyumlu; yeni toplulaştırmalar min-N altında verilmez)
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
      'soru_dogrulugu', (
        select jsonb_object_agg(b.beceri,
                 case when coalesce(x.n, 0) >= 3 and coalesce(x.ogr, 0) >= v_esik
                      then jsonb_build_object('yeterli', true, 'soru', x.n, 'dogru', x.d, 'yanlis', x.n - x.d, 'oran', round(100.0 * x.d / x.n, 0))
                      else jsonb_build_object('yeterli', false) end)
          from unnest(array['hatirlama', 'cikarim', 'yorumlama', 'degerlendirme', 'sozcuk_baglami']) as b(beceri)
          left join (
            select c.beceri, count(*)::integer as n, count(*) filter (where c.dogru)::integer as d,
                   count(distinct o.ogrenci_id)::integer as ogr
              from public.okuma_cevaplari c
              join public.okuma_oturumlari o on o.id = c.oturum_id
              join public.sinif_uyelikleri u on u.ogrenci_id = o.ogrenci_id and u.sinif_id = p_sinif_id
             where o.baslangic_at >= v_basla group by c.beceri) x on x.beceri = b.beceri),
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

    -- Yeni toplulaştırmalar (Faz B): sınıf toplamı; öğe başına en az 3 farklı öğrenci
    v_ozet := v_ozet || jsonb_build_object(
      'okunan_kelime', (
        select coalesce(sum(case when e.olculen ->> 'kelime_sayisi' ~ '^[0-9]{1,6}$'
                                 then (e.olculen ->> 'kelime_sayisi')::integer else 0 end), 0)::integer
          from public.okuma_oturumlari o
          join public.sinif_uyelikleri u on u.ogrenci_id = o.ogrenci_id and u.sinif_id = p_sinif_id
          join public.okuma_hikaye_etiketleri e on e.surum_id = o.surum_id
         where o.baslangic_at >= v_basla and o.tamamlandi_at is not null),
      'toplam_sure_dk', (
        select coalesce(round(sum(least(extract(epoch from (o.tamamlandi_at - o.baslangic_at)) / 60.0, 30))::numeric, 0), 0)
          from public.okuma_oturumlari o
          join public.sinif_uyelikleri u on u.ogrenci_id = o.ogrenci_id and u.sinif_id = p_sinif_id
         where o.baslangic_at >= v_basla and o.tamamlandi_at is not null),
      'tur_dagilimi', (
        select coalesce(jsonb_agg(jsonb_build_object('tur', t.tur, 'ogrenci_sayisi', t.ogr, 'hikaye_sayisi', t.hik, 'oturum', t.ot)
                                  order by t.ot desc, t.tur), '[]'::jsonb)
          from (select s.tur, count(distinct o.ogrenci_id)::integer as ogr, count(distinct o.hikaye_id)::integer as hik,
                       count(*)::integer as ot
                  from public.okuma_oturumlari o
                  join public.sinif_uyelikleri u on u.ogrenci_id = o.ogrenci_id and u.sinif_id = p_sinif_id
                  join public.okuma_hikaye_surumleri s on s.id = o.surum_id
                 where o.baslangic_at >= v_basla
                 group by s.tur having count(distinct o.ogrenci_id) >= v_esik) t),
      'okunan_hikayeler', (
        select coalesce(jsonb_agg(jsonb_build_object('hikaye_id', t.hikaye_id, 'baslik', t.baslik, 'tur', t.tur,
                 'ogrenci_sayisi', t.ogr, 'oturum', t.ot, 'dogru_orani', t.oran) order by t.ot desc, t.hikaye_id), '[]'::jsonb)
          from (select o.hikaye_id, min(s.baslik) as baslik, min(s.tur) as tur,
                       count(distinct o.ogrenci_id)::integer as ogr, count(*)::integer as ot,
                       round(100.0 * sum(o.dogru_sayisi) / nullif(sum(o.soru_sayisi), 0), 0) as oran
                  from public.okuma_oturumlari o
                  join public.sinif_uyelikleri u on u.ogrenci_id = o.ogrenci_id and u.sinif_id = p_sinif_id
                  join public.okuma_hikaye_surumleri s on s.id = o.surum_id
                 where o.baslangic_at >= v_basla
                 group by o.hikaye_id having count(distinct o.ogrenci_id) >= v_esik
                 order by count(*) desc, o.hikaye_id limit 10) t),
      'deger_dagilimi', (
        select coalesce(jsonb_agg(jsonb_build_object('deger', t.deger, 'ad', s.ad, 'ogrenci_sayisi', t.ogr, 'hikaye_sayisi', t.hik)
                                  order by t.ogr desc, t.deger), '[]'::jsonb)
          from (select dg as deger, count(distinct o.ogrenci_id)::integer as ogr, count(distinct o.hikaye_id)::integer as hik
                  from public.okuma_oturumlari o
                  join public.sinif_uyelikleri u on u.ogrenci_id = o.ogrenci_id and u.sinif_id = p_sinif_id
                  join public.okuma_hikaye_etiketleri e on e.surum_id = o.surum_id
                  cross join lateral unnest(array_remove(array[e.ana_deger, e.yardimci_deger], null)) dg
                 where o.baslangic_at >= v_basla
                 group by dg having count(distinct o.ogrenci_id) >= v_esik) t
          left join public.okuma_etiket_sozlugu s on s.tur = 'deger' and s.anahtar = t.deger),
      'olcme_turu_dogrulugu', (
        select jsonb_object_agg(b.tur,
                 case when coalesce(x.n, 0) >= 3 and coalesce(x.ogr, 0) >= v_esik
                      then jsonb_build_object('yeterli', true, 'soru', x.n, 'dogru', x.d, 'yanlis', x.n - x.d, 'oran', round(100.0 * x.d / x.n, 0))
                      else jsonb_build_object('yeterli', false) end)
          from unnest(array['metin_kaniti', 'kavram_dogrulugu', 'transfer']) as b(tur)
          left join (
            select c.olcme_turu, count(*)::integer as n, count(*) filter (where c.dogru)::integer as d,
                   count(distinct o.ogrenci_id)::integer as ogr
              from public.okuma_cevaplari c
              join public.okuma_oturumlari o on o.id = c.oturum_id
              join public.sinif_uyelikleri u on u.ogrenci_id = o.ogrenci_id and u.sinif_id = p_sinif_id
             where o.baslangic_at >= v_basla and c.olcme_turu is not null group by c.olcme_turu) x on x.olcme_turu = b.tur),
      -- Tüm sorularda doğru/yanlış toplamı (en az 3 soru ve 3 öğrenci)
      'dogruluk_toplami', (
        select case when count(*) >= 3 and count(distinct o.ogrenci_id) >= v_esik
                    then jsonb_build_object('yeterli', true, 'soru', count(*)::integer, 'dogru', (count(*) filter (where c.dogru))::integer,
                           'yanlis', (count(*) filter (where not c.dogru))::integer,
                           'oran', round(100.0 * count(*) filter (where c.dogru) / count(*), 0))
                    else jsonb_build_object('yeterli', false) end
          from public.okuma_cevaplari c
          join public.okuma_oturumlari o on o.id = c.oturum_id
          join public.sinif_uyelikleri u on u.ogrenci_id = o.ogrenci_id and u.sinif_id = p_sinif_id
         where o.baslangic_at >= v_basla),
      -- Haftalık ortalama zorluk: yalnız o hafta en az 3 farklı öğrenci okuduysa
      'zorluk_seyri', (
        select coalesce(jsonb_agg(jsonb_build_object('hafta', w.hafta, 'ogrenci_sayisi', w.ogr, 'hikaye', w.adet,
                 'ort_okuma_zorlugu', w.okuma, 'ort_kavram_zorlugu', w.kavram) order by w.hafta), '[]'::jsonb)
          from (select date_trunc('week', o.baslangic_at at time zone 'Europe/Istanbul')::date as hafta,
                       count(distinct o.ogrenci_id)::integer as ogr, count(distinct o.hikaye_id)::integer as adet,
                       round(avg(e.okuma_zorlugu)::numeric, 1) as okuma, round(avg(e.kavram_zorlugu)::numeric, 1) as kavram
                  from public.okuma_oturumlari o
                  join public.sinif_uyelikleri u on u.ogrenci_id = o.ogrenci_id and u.sinif_id = p_sinif_id
                  join public.okuma_hikaye_etiketleri e on e.surum_id = o.surum_id
                 where o.baslangic_at >= v_basla
                 group by 1 having count(distinct o.ogrenci_id) >= v_esik) w),
      'kavramlar', public._okuma_sinif_hedef_listesi(p_sinif_id, array['concept'], v_esik),
      'atasozleri', public._okuma_sinif_hedef_listesi(p_sinif_id, array['proverb', 'idiom'], v_esik),
      'kelimeler', public._okuma_sinif_hedef_listesi(p_sinif_id, array['lexeme'], v_esik));
  end if;

  return jsonb_build_object(
    'sinif', jsonb_build_object('id', v_sinif.id, 'ad', v_sinif.ad, 'sinif_seviyesi', v_sinif.sinif_seviyesi),
    'gun', v_gun, 'ogrenci_sayisi', v_uye, 'okuyan_ogrenci', v_okuyan,
    'yeterli', v_okuyan >= v_esik, 'min_n', v_esik, 'ozet', v_ozet);
end;
$$;

revoke all on function public.okuma_ogretmen_sinif_ozeti(uuid, integer) from public, anon;
grant execute on function public.okuma_ogretmen_sinif_ozeti(uuid, integer) to authenticated;

-- Sınıf hedef listesi (tür filtreli): öğe başına en az p_esik öğrenci; çocuk kimliği yok
create or replace function public._okuma_sinif_hedef_listesi(p_sinif_id uuid, p_turler text[], p_esik integer)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(jsonb_agg(jsonb_build_object('hedef_id', q.id, 'etiket', q.etiket, 'tur', q.tur,
           'ogrenci_sayisi', q.ogr,
           'ogrenen_sayisi', case when q.ogrenen >= p_esik then q.ogrenen else null end,
           -- Basamaklı sayılar (kümülatif): tanıyan >= hatırlayan >= aktaran; her biri min-N altında null
           'taniyan_sayisi', case when q.ogrenen >= p_esik then q.ogrenen else null end,
           'hatirlayan_sayisi', case when q.hatirlayan >= p_esik then q.hatirlayan else null end,
           'aktaran_sayisi', case when q.aktaran >= p_esik then q.aktaran else null end)
           order by q.ogr desc, q.id), '[]'::jsonb)
    from (select h.id, h.etiket, h.tur, count(distinct d.ogrenci_id)::integer as ogr,
                 count(distinct d.ogrenci_id) filter (where d.durum in ('recognized', 'retrieved', 'transferred'))::integer as ogrenen,
                 count(distinct d.ogrenci_id) filter (where d.durum in ('retrieved', 'transferred'))::integer as hatirlayan,
                 count(distinct d.ogrenci_id) filter (where d.durum = 'transferred')::integer as aktaran
            from public.okuma_ogrenci_hedef_durumu d
            join public.sinif_uyelikleri u on u.ogrenci_id = d.ogrenci_id and u.sinif_id = p_sinif_id
            join public.okuma_ogrenme_hedefleri h on h.id = d.hedef_id
           where d.durum <> 'not_seen' and h.tur = any (p_turler)
           group by h.id, h.etiket, h.tur
          having count(distinct d.ogrenci_id) >= p_esik
           order by count(distinct d.ogrenci_id) desc, h.id limit 20) q;
$$;

revoke all on function public._okuma_sinif_hedef_listesi(uuid, text[], integer) from public, anon, authenticated;

