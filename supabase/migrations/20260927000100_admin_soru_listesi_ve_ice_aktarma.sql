-- =====================================================================
--  KURTARMA: yönetici soru listesi ve toplu soru içe aktarma
--  Proje : ccozfrpnvyrnktpffkwo — Öğrenci Hazırlık / Hupo
--  Tarih : 2026-09-27
--
--  KAYNAK (canlı gövdeler, BİREBİR kopya):
--    kurtarilan/cikti-kalan.csv → kurtarilan/parcalar/
--      admin_list_questions.sql · admin_import_questions.sql
--  Yetkiler: "-- secdef: true | anon: false | auth: true | servis: true"
--
--  ⚠️ admin_list_questions: diskte ESKİ 6 parametreli sürüm vardı
--     (20260920000900). CANLI sürüm 8 parametrelidir ve şunları ekler:
--       p_inceleme boolean → yalnızca inceleme bekleyenleri süz
--       p_sinif    integer → sınıf süzgeci
--       dönen satırlarda q.sinif, q.inceleme_gerekli ve acik_rapor sayacı
--     Sınıf ve inceleme bayrağı süzgeçleri olmadan moderasyon ekranı
--     "inceleme bekleyen sorular" listesini gösteremez.
--
--  ⚠️ admin_import_questions: diskteki eski sürüm questions.sinif alanını
--     HİÇ YAZMIYORDU (20260920000900:327-335). Canlı sürüm satırlardaki
--     'sinif' değerini smallint olarak yazar. sinif yazılmadığı için
--     20260927000030'daki admin_set_daily_challenge() "seçilen sorular aynı
--     sınıfa ait olmalı" kuralını işletemiyordu.
--     Bu fonksiyonu web panel çağırır:
--     web-panel/src/components/yonetim/sorular/BulkImport.tsx:129
--       supabase.rpc("admin_import_questions", ...)
--
--  BAĞIMLILIKLAR (diskte VAR ✓):
--    public.questions (…, sinif, inceleme_gerekli → 20260927000040)
--    public.question_reports (20260927000030)
--    public._soru_hatasi(jsonb), public.tr_normalize(text),
--    public.log_admin_action(text, jsonb)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. admin_list_questions — 8 parametreli CANLI sürüm
-- ---------------------------------------------------------------------
-- CANLI ile hizalama: diskte 20260920000900'da ESKİ 6 parametreli sürüm
-- duruyor. Aynı isimle iki sürüm birlikte kalırsa PostgREST hangi sürümü
-- çağıracağını bilemez (panel 6 adlandırılmış parametre gönderiyor:
-- web-panel/src/components/yonetim/sorular/QuestionsManager.tsx:69) ve
-- canlıda yalnızca 8 parametreli sürüm vardır (katalog dökümü). Bu yüzden
-- eski sürüm burada KALDIRILIR; kalan sürüm eksik alanların varsayılanlarını
-- kendisi doldurur (p_inceleme/p_sinif = null).
drop function if exists public.admin_list_questions(text, text, integer, text, integer, integer);

create or replace function public.admin_list_questions(
  p_ders text default null,
  p_durum text default null,
  p_zorluk integer default null,
  p_arama text default null,
  p_limit integer default 25,
  p_offset integer default 0,
  p_inceleme boolean default null,
  p_sinif integer default null
)
returns jsonb
language plpgsql
stable security definer
set search_path to ''
as $function$
declare
  v_limit  integer := least(greatest(coalesce(p_limit, 25), 1), 100);
  v_offset integer := greatest(coalesce(p_offset, 0), 0);
  v_arama  text := public.tr_normalize(nullif(trim(coalesce(p_arama, '')), ''));
  v_toplam integer;
  v_satir  jsonb;
begin
  perform public.require_admin();

  if p_sinif is not null and (p_sinif < 1 or p_sinif > 12) then
    raise exception 'Sınıf 1 ile 12 arasında olmalı' using errcode = '22023';
  end if;

  select count(*)::integer into v_toplam
    from public.questions q
   where (p_ders is null or q.ders = p_ders)
     and (p_durum is null or q.onay_durumu = p_durum)
     and (p_zorluk is null or q.zorluk = p_zorluk)
     and (p_inceleme is null or q.inceleme_gerekli = p_inceleme)
     and (p_sinif is null or q.sinif = p_sinif)
     and (v_arama is null or public.tr_normalize(q.soru_metni || ' ' || q.konu || ' ' || coalesce(q.alt_konu, ''))
                              like '%' || v_arama || '%');

  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id), '[]'::jsonb)
    into v_satir
    from (
      select q.id, q.okul, q.sinif, q.ders, q.konu, q.alt_konu, q.zorluk, q.soru_metni, q.siklar,
             q.dogru_sik, q.cozum_adimlari, q.onay_durumu, q.created_at, q.inceleme_gerekli,
             (select count(*)::integer from public.question_reports r
               where r.question_id = q.id and r.durum in ('acik', 'inceleniyor')) as acik_rapor
        from public.questions q
       where (p_ders is null or q.ders = p_ders)
         and (p_durum is null or q.onay_durumu = p_durum)
         and (p_zorluk is null or q.zorluk = p_zorluk)
         and (p_inceleme is null or q.inceleme_gerekli = p_inceleme)
         and (p_sinif is null or q.sinif = p_sinif)
         and (v_arama is null or public.tr_normalize(q.soru_metni || ' ' || q.konu || ' ' || coalesce(q.alt_konu, ''))
                                  like '%' || v_arama || '%')
       order by q.created_at desc, q.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('toplam', v_toplam, 'satirlar', v_satir);
end;
$function$;

comment on function public.admin_list_questions(text, text, integer, text, integer, integer, boolean, integer) is
  'Yönetici soru listesi: ders/durum/zorluk/arama + sınıf ve inceleme bayrağı süzgeçleri.';

revoke execute on function public.admin_list_questions(text, text, integer, text, integer, integer, boolean, integer)
  from public, anon;
grant  execute on function public.admin_list_questions(text, text, integer, text, integer, integer, boolean, integer)
  to authenticated;

-- ---------------------------------------------------------------------
-- 2. admin_import_questions — sinif alanını YAZAN canlı sürüm
-- ---------------------------------------------------------------------
create or replace function public.admin_import_questions(
  p_rows jsonb,
  p_onayla boolean default false,
  p_hepsi_veya_hicbiri boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_row      jsonb;
  v_i        integer := 0;
  v_hata     text;
  v_hatalar  jsonb := '[]'::jsonb;
  v_eklenen  integer := 0;
  v_tekrar   integer := 0;
  v_gecerli  jsonb := '[]'::jsonb;
  v_durum    text := case when p_onayla then 'onaylandi' else 'beklemede' end;
begin
  perform public.require_admin();

  if jsonb_typeof(p_rows) is distinct from 'array' then
    raise exception 'Satırlar liste olmalı' using errcode = '22023';
  end if;
  if jsonb_array_length(p_rows) > 1000 then
    raise exception 'Tek seferde en fazla 1000 satır eklenebilir' using errcode = '22023';
  end if;

  for v_row in select * from jsonb_array_elements(p_rows) loop
    v_i := v_i + 1;
    v_hata := public._soru_hatasi(v_row);
    if v_hata is not null then
      v_hatalar := v_hatalar || jsonb_build_array(jsonb_build_object('satir', v_i, 'hata', v_hata));
    else
      v_gecerli := v_gecerli || jsonb_build_array(v_row);
    end if;
  end loop;

  if p_hepsi_veya_hicbiri and jsonb_array_length(v_hatalar) > 0 then
    return jsonb_build_object('eklenen', 0, 'tekrar', 0,
                              'hatali', jsonb_array_length(v_hatalar), 'hatalar', v_hatalar);
  end if;

  for v_row in select * from jsonb_array_elements(v_gecerli) loop
    if exists (
      select 1 from public.questions q
       where q.ders = trim(v_row ->> 'ders') and q.konu = trim(v_row ->> 'konu')
         and public.tr_normalize(q.soru_metni) = public.tr_normalize(trim(v_row ->> 'soru_metni'))
    ) then
      v_tekrar := v_tekrar + 1;
      continue;
    end if;

    insert into public.questions
      (okul, sinif, ders, konu, alt_konu, zorluk, soru_metni, siklar, dogru_sik,
       cozum_adimlari, onay_durumu, created_by)
    values
      -- sinif zorunlu ve 1-12 (_soru_hatasi doğruladı): NULL üretilmez
      (trim(v_row ->> 'okul'), trim(v_row ->> 'sinif')::smallint,
       trim(v_row ->> 'ders'), trim(v_row ->> 'konu'),
       nullif(trim(coalesce(v_row ->> 'alt_konu', '')), ''),
       (v_row ->> 'zorluk')::smallint, trim(v_row ->> 'soru_metni'),
       v_row -> 'siklar', upper(v_row ->> 'dogru_sik'),
       coalesce(v_row -> 'cozum_adimlari', '[]'::jsonb), v_durum, (select auth.uid()));
    v_eklenen := v_eklenen + 1;
  end loop;

  perform public.log_admin_action('toplu_soru_eklendi', jsonb_build_object(
    'eklenen', v_eklenen, 'tekrar', v_tekrar, 'hatali', jsonb_array_length(v_hatalar),
    'onayli', p_onayla));

  return jsonb_build_object('eklenen', v_eklenen, 'tekrar', v_tekrar,
                            'hatali', jsonb_array_length(v_hatalar), 'hatalar', v_hatalar);
end;
$function$;

comment on function public.admin_import_questions(jsonb, boolean, boolean) is
  'Toplu soru içe aktarma. Satırlardaki sinif değeri questions.sinif alanına yazılır.';

revoke execute on function public.admin_import_questions(jsonb, boolean, boolean) from public, anon;
grant  execute on function public.admin_import_questions(jsonb, boolean, boolean) to authenticated;

-- ---------------------------------------------------------------------
-- NOT (kurtarma): canlıdaki admin_upsert_question() BURAYA ALINMADI.
--   Gövdesi iki eksik nesneye bağlı:
--     * public.question_revisions (tablo) — canlı tanımı dökümde YOK
--     · public._soru_anlik(uuid)          — canlı gövdesi dökümde YOK
--   Ayrıntı: supabase/KURTARMA_DURUMU.md
-- ---------------------------------------------------------------------
