-- =====================================================================
--  KURTARMA: soru analitiği kümesi (_question_analytics_base + RPC)
--  Proje : ccozfrpnvyrnktpffkwo — Öğrenci Hazırlık / Hupo
--  Tarih : 2026-09-27
--
--  NE EKSİKTİ?
--    Canlıda var olan, diskte HİÇ olmayan 2 fonksiyon:
--      public._question_analytics_base(integer)
--      public.admin_question_analytics(text, integer, integer, integer, text, boolean)
--    (20260927000090_admin_ayarlar_ve_moderasyon.sql:408 bu bağımlılığı not
--     ediyor; gövde o migration'a konmamıştı.)
--
--  KAYNAK
--    [OK] admin_question_analytics — BİREBİR kopya
--         (kurtarilan/parcalar/admin_question_analytics.sql)
--    [TAHMIN] _question_analytics_base — gövde dökümde YOK. Çağrı sözleşmesi
--         çağıranın (BİREBİR gövde) kullandığı kolonlardan çıkarıldı:
--           b.id, b.ders, b.konu, b.zorluk, b.soru_metni, b.dogru_sik,
--           b.onay_durumu, b.inceleme_gerekli, b.ogrenci, b.deneme, b.dogru,
--           b.dogru_oran, b.ort_sure_ms, b.limit_ms, b.dagilim, b.bayraklar(text[])
--         Ayrıca: yalnızca onaylanmış sorular, "deneme >= p_min_cevap" süzgeci,
--         bayraklar boş değilse "şüpheli" sayılır.
--    [KANIT] limit_ms: soru başına süre limiti istemciden birebir —
--         mobile-app/lib/models/models.dart:92-97
--           /// Soru başına verilen süre (saniye): kolay 45, orta 60, zor 90.
--           int get timeLimitSeconds => switch (zorluk) { 1 => 45, 2 => 60, _ => 90 };
--         quiz_screen.dart:111 → limitMs = timeLimitSeconds * 1000
--         Yani limit_ms = zorluk 1 → 45000, 2 → 60000, 3 → 90000.
--    [KANIT] dagilim 'bos' anahtarı: 20260920000400_solution_steps_and_timeout.sql
--         → user_answers.secilen_sik NULL olabilir ("süre doldu"); NULL'lar
--         'bos' anahtarında toplanır.
--
--  TODO(kurtarma): İki nokta canlıdan teyit edilmeli:
--    1) Bayrak adları ve eşikleri hiçbir dökümde geçmiyor (panel bu alanı
--       henüz tüketmiyor: web-panel/src'de "analytics/bayraklar" araması boş).
--       Burada kullanılan adlar: inceleme, zor, kolay, yavas, bos_fazla,
--       dagilim_ters. Eşikler: zor < %30, kolay > %95, yavas > limit_ms,
--       bos_fazla > %25, dagilim_ters = çeldirici doğrudan çok seçilmiş.
--    2) Gövde birebir alınmalı:
--       select pg_get_functiondef('public._question_analytics_base(integer)'::regprocedure);
--
--  GÜVENLİK: Yalnızca SECURITY DEFINER admin RPC'si okur; istemciye
--    _question_analytics_base için hiç yetki verilmez (fail-closed).
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. _question_analytics_base — onaylı soruların cevap istatistikleri
-- ---------------------------------------------------------------------
create or replace function public._question_analytics_base(p_min_cevap integer default 5)
returns table (
  id               uuid,
  ders             text,
  konu             text,
  zorluk           smallint,
  soru_metni       text,
  dogru_sik        text,
  onay_durumu      text,
  inceleme_gerekli boolean,
  ogrenci          integer,
  deneme           integer,
  dogru            integer,
  dogru_oran       numeric,
  ort_sure_ms      integer,
  limit_ms         integer,
  dagilim          jsonb,
  bayraklar        text[]
)
language sql
stable
security definer
set search_path to ''
as $function$
  with toplam as (
    select
      q.id               as id,
      q.ders             as ders,
      q.konu             as konu,
      q.zorluk           as zorluk,
      q.soru_metni       as soru_metni,
      q.dogru_sik        as dogru_sik,
      q.onay_durumu      as onay_durumu,
      q.inceleme_gerekli as inceleme_gerekli,
      count(a.student_id)::integer  as ogrenci, -- cevap satırı sayısı: user_answers (öğrenci, soru) tekil olduğu için öğrenci sayısına eşit; 'bos_fazla' oranının paydası
      coalesce(sum(a.deneme_sayisi), 0)::integer                as deneme,
      coalesce(sum(a.dogru_sayisi), 0)::integer                 as dogru,
      round(coalesce(sum(a.dogru_sayisi), 0)::numeric
            / nullif(coalesce(sum(a.deneme_sayisi), 0), 0), 4)  as dogru_oran,
      round(avg(a.son_sure_ms))::integer                        as ort_sure_ms,
      -- Soru başına süre limiti: istemci ile birebir (models.dart → 45/60/90 sn)
      (case q.zorluk when 1 then 45000 when 2 then 60000 else 90000 end) as limit_ms,
      coalesce((
        select jsonb_object_agg(d.sik, d.adet)
          from (
            select coalesce(a2.secilen_sik, 'bos') as sik, count(*)::integer as adet
              from public.user_answers a2
             where a2.question_id = q.id
             group by 1
          ) d
      ), '{}'::jsonb)                                            as dagilim
    from public.questions q
    left join public.user_answers a on a.question_id = q.id
    where q.onay_durumu = 'onaylandi'
    group by q.id, q.ders, q.konu, q.zorluk, q.soru_metni, q.dogru_sik, q.onay_durumu, q.inceleme_gerekli
  )
  select
    t.id, t.ders, t.konu, t.zorluk, t.soru_metni, t.dogru_sik, t.onay_durumu, t.inceleme_gerekli,
    t.ogrenci, t.deneme, t.dogru, t.dogru_oran, t.ort_sure_ms, t.limit_ms, t.dagilim,
    array_remove(array[
      case when t.inceleme_gerekli then 'inceleme' end,
      case when t.dogru_oran is not null and t.dogru_oran < 0.30 then 'zor' end,
      case when t.dogru_oran is not null and t.dogru_oran > 0.95 then 'kolay' end,
      case when t.ort_sure_ms is not null and t.ort_sure_ms > t.limit_ms then 'yavas' end,
      case when coalesce((t.dagilim ->> 'bos')::integer, 0)::numeric
                 / greatest(t.ogrenci, 1) > 0.25 then 'bos_fazla' end,
      case when exists (
             select 1 from jsonb_each_text(t.dagilim) d
              where d.key <> 'bos'
                and d.key is distinct from t.dogru_sik
                and d.value::integer > coalesce((t.dagilim ->> t.dogru_sik)::integer, 0)
           ) then 'dagilim_ters' end
    ]::text[], null) as bayraklar
  from toplam t
  where t.deneme >= greatest(coalesce(p_min_cevap, 5), 1);
$function$;

comment on function public._question_analytics_base(integer) is
  'Onaylı soruların cevap istatistikleri (öğrenci/deneme/doğru/doğru oranı/süre/şık dağılımı/bayraklar). Yalnızca admin RPC''leri okur.';

-- ---------------------------------------------------------------------
-- 2. admin_question_analytics — BİREBİR canlı gövde
-- ---------------------------------------------------------------------
create or replace function public.admin_question_analytics(
  p_ders text default null,
  p_min_cevap integer default 5,
  p_limit integer default 25,
  p_offset integer default 0,
  p_sirala text default 'deneme_azalan',
  p_sadece_supheli boolean default false
)
returns jsonb
language plpgsql
stable security definer
set search_path to ''
as $function$
declare
  v_min    integer := greatest(coalesce(p_min_cevap, 5), 1);
  v_limit  integer := least(greatest(coalesce(p_limit, 25), 1), 100);
  v_offset integer := greatest(coalesce(p_offset, 0), 0);
  v_sirala text := coalesce(p_sirala, 'deneme_azalan');
  v_toplam integer;
  v_satir  jsonb;
  v_ozet   jsonb;
begin
  perform public.require_admin();
  if v_sirala not in ('deneme_azalan', 'dogru_artan', 'dogru_azalan', 'sure_azalan', 'supheli') then
    raise exception 'Geçersiz sıralama' using errcode = '22023';
  end if;

  select count(*)::integer into v_toplam
    from public._question_analytics_base(v_min) b
   where (p_ders is null or b.ders = p_ders)
     and (not coalesce(p_sadece_supheli, false) or cardinality(b.bayraklar) > 0);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.sira), '[]'::jsonb) into v_satir
    from (
      select b.id, b.ders, b.konu, b.zorluk, b.soru_metni, b.dogru_sik, b.onay_durumu,
             b.inceleme_gerekli, b.ogrenci, b.deneme, b.dogru, b.dogru_oran,
             b.ort_sure_ms, b.limit_ms, b.dagilim, to_jsonb(b.bayraklar) as bayraklar,
             row_number() over (order by
               case v_sirala when 'dogru_artan' then b.dogru_oran end asc nulls last,
               case v_sirala when 'dogru_azalan' then b.dogru_oran end desc nulls last,
               case v_sirala when 'sure_azalan' then b.ort_sure_ms end desc nulls last,
               case v_sirala when 'supheli' then cardinality(b.bayraklar) end desc,
               b.deneme desc, b.id) as sira
        from public._question_analytics_base(v_min) b
       where (p_ders is null or b.ders = p_ders)
         and (not coalesce(p_sadece_supheli, false) or cardinality(b.bayraklar) > 0)
       order by sira
       limit v_limit offset v_offset
    ) x;

  select jsonb_build_object(
    'cevaplanan_soru', (select count(*) from public._question_analytics_base(v_min)),
    'toplam_deneme', coalesce((select sum(deneme) from public._question_analytics_base(v_min)), 0),
    'genel_dogru_oran', (select round(sum(dogru)::numeric / nullif(sum(deneme), 0), 4)
                           from public._question_analytics_base(v_min)),
    'supheli_soru', (select count(*) from public._question_analytics_base(v_min)
                      where cardinality(bayraklar) > 0),
    'min_cevap', v_min,
    'ders_ozeti', coalesce((
      select jsonb_agg(to_jsonb(d) order by d.ders)
        from (
          select q.ders,
                 count(*)::integer as soru,
                 count(b.id)::integer as cevaplanan_soru,
                 coalesce(sum(b.deneme), 0)::integer as deneme,
                 round(sum(b.dogru)::numeric / nullif(sum(b.deneme), 0), 4) as dogru_oran,
                 count(*) filter (where cardinality(b.bayraklar) > 0)::integer as supheli
            from public.questions q
            left join public._question_analytics_base(v_min) b on b.id = q.id
           where q.onay_durumu = 'onaylandi'
           group by q.ders
        ) d), '[]'::jsonb)
  ) into v_ozet;

  return jsonb_build_object('toplam', v_toplam, 'satirlar', v_satir, 'ozet', v_ozet);
end;
$function$;

comment on function public.admin_question_analytics(text, integer, integer, integer, text, boolean) is
  'Soru bazlı cevap analitiği: özet, ders özeti ve şüpheli soru listesi.';

-- ---------------------------------------------------------------------
-- 3. REVOKE / GRANT — canlı yetki özeti birebir
-- ---------------------------------------------------------------------
revoke execute on function public._question_analytics_base(integer) from public, anon, authenticated;

revoke execute on function public.admin_question_analytics(text, integer, integer, integer, text, boolean) from public, anon;
grant  execute on function public.admin_question_analytics(text, integer, integer, integer, text, boolean) to authenticated;