-- =====================================================================
--  KURTARMA: deneme sınavı kümesi (yönetici sınav tanımı + sonuçlar)
--  Proje : ccozfrpnvyrnktpffkwo — Öğrenci Hazırlık / Hupo
--  Tarih : 2026-09-27
--
--  NE EKSİKTİ?
--    Canlıda var olan, diskte HİÇ olmayan 3 tablo ve 7 fonksiyon:
--      tablolar     : public.deneme_sinavlari, public.deneme_sinavi_sorulari,
--                     public.deneme_sinavi_denemeleri
--      fonksiyonlar : _deneme_sinavi_siniflar_gecerli, admin_upsert_mock_exam,
--                     admin_list_mock_exams, admin_set_mock_exam_active,
--                     admin_set_mock_exam_questions, admin_get_mock_exam_questions,
--                     admin_get_mock_exam_results
--
--  KAYNAK
--    [OK] BIREBIR kopya (canli govdeler, kurtarilan/parcalar/*.sql):
--        _deneme_sinavi_siniflar_gecerli.sql, admin_upsert_mock_exam.sql,
--        admin_list_mock_exams.sql, admin_set_mock_exam_active.sql,
--        admin_set_mock_exam_questions.sql, admin_get_mock_exam_questions.sql,
--        admin_get_mock_exam_results.sql
--    [OK] TABLOLAR KULLANIMDAN GERI KURULDU. Kolon adlari canli govdelerde
--      gecen adlarla birebir; tipler govdelerin kullandigi islemlerden
--      cikarildi (ornek: admin_get_mock_exam_results'un RETURNS TABLE
--      bildirimi dogru_sayisi/yanlis_sayisi/bos_sayisi icin smallint,
--      puan icin numeric diyor; denemeleri tablosu buna UYMAK ZORUNDA).
--    [OK] siniflar kucuk dizisi dogrudan _desteklenen_siniflar() (app_settings
--      'desteklenen_siniflar') ile dogrulanir.
--
--  DOGRULAMA SORGULARI (canlidan alinip bu dosya tazelenmeli):
--    select table_name, column_name, data_type, is_nullable, column_default
--      from information_schema.columns
--     where table_schema = 'public' and table_name like 'deneme_sinavi%'
--     order by table_name, ordinal_position;
--    select pg_get_functiondef('public.admin_get_mock_exam_results(uuid)'::regprocedure);
--
--  NOT: Öğrenci tarafı (sınava girme/gönderme) RPC'leri kurtarma dökümünde
--    YOKTUR; yani ya canlıda da yoktu ya da diskte mevcuttu. Bu yüzden burada
--    yalnızca yönetici tarafı geri kuruldu. Öğrenci akışı yazılacaksa
--    deneme_sinavi_denemeleri tablosu (exam_id, student_id) tekil kaydı ile
--    buna hazırdır.
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. deneme_sinavlari — sınav tanımı (sınıf bazlı)
-- ---------------------------------------------------------------------
create table if not exists public.deneme_sinavlari (
  id               uuid primary key default gen_random_uuid(),
  ad               text not null,
  baslangic_zamani timestamptz not null,
  sure_dakika      integer not null default 40,
  siniflar         smallint[] not null default '{}',
  aktif            boolean not null default true,
  sorular_kilitli  boolean not null default false,
  created_by       uuid references public.profiles (id) on delete set null,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),

  constraint deneme_sinavlari_ad_uzunluk check (char_length(btrim(ad)) between 2 and 120),
  constraint deneme_sinavlari_sure_check  check (sure_dakika between 5 and 240)
);

create index if not exists deneme_sinavlari_baslangic_idx
  on public.deneme_sinavlari (baslangic_zamani desc);

comment on table public.deneme_sinavlari is
  'Deneme sınavı tanımı. admin_upsert_mock_exam() yazar, admin_list_mock_exams() okur.';
comment on column public.deneme_sinavlari.sorular_kilitli is
  'Kilitli sınavın soruları değiştirilemez (admin_set_mock_exam_questions 42501 verir).';
comment on column public.deneme_sinavlari.siniflar is
  'Sınavın atandığı sınıflar; _desteklenen_siniflar() kümesinin alt kümesi olmalı.';

-- ---------------------------------------------------------------------
-- 2. deneme_sinavi_sorulari — sınavın sınıf bazlı soru listesi
--   admin_set_mock_exam_questions(): önce siler, sonra row_number() sırasıyla yazar.
-- ---------------------------------------------------------------------
create table if not exists public.deneme_sinavi_sorulari (
  exam_id     uuid not null references public.deneme_sinavlari (id) on delete cascade,
  sinif       smallint not null,
  question_id uuid not null references public.questions (id) on delete cascade,
  sira        integer not null,

  primary key (exam_id, sinif, question_id),
  constraint deneme_sinavi_sorulari_sira_uniq unique (exam_id, sinif, sira),
  constraint deneme_sinavi_sorulari_sira_check check (sira >= 1)
);

create index if not exists deneme_sinavi_sorulari_soru_idx
  on public.deneme_sinavi_sorulari (question_id);

comment on table public.deneme_sinavi_sorulari is
  'Sınav-soru eşlemesi (sınıf bazlı, sira = sınav içi soru numarası).';

-- ---------------------------------------------------------------------
-- 3. deneme_sinavi_denemeleri — öğrencinin sınav sonucu
--   admin_get_mock_exam_results(): yalnızca bitis_zamani dolu kayıtları
--   sınıf içinde puan desc, bitis_zamani asc sırasıyla rank'lar.
--   Öğrenci başına tek kayıt: unique (exam_id, student_id).
-- ---------------------------------------------------------------------
create table if not exists public.deneme_sinavi_denemeleri (
  id            uuid primary key default gen_random_uuid(),
  exam_id       uuid not null references public.deneme_sinavlari (id) on delete cascade,
  student_id    uuid not null references public.profiles (id) on delete cascade,
  sinif         smallint not null,
  puan          numeric not null default 0,
  dogru_sayisi  smallint not null default 0,
  yanlis_sayisi smallint not null default 0,
  bos_sayisi    smallint not null default 0,
  bitis_zamani  timestamptz,
  created_at    timestamptz not null default now(),

  unique (exam_id, student_id),
  constraint deneme_sinavi_denemeleri_puan_check check (puan >= 0),
  constraint deneme_sinavi_denemeleri_sayilar_check
    check (dogru_sayisi >= 0 and yanlis_sayisi >= 0 and bos_sayisi >= 0)
);

create index if not exists deneme_sinavi_denemeleri_exam_idx
  on public.deneme_sinavi_denemeleri (exam_id, sinif, puan desc);
create index if not exists deneme_sinavi_denemeleri_ogrenci_idx
  on public.deneme_sinavi_denemeleri (student_id);

comment on table public.deneme_sinavi_denemeleri is
  'Öğrenci deneme sınavı sonucu. Sıralama yalnızca bitis_zamani dolu (bitmiş) kayıtlarda yapılır.';

-- ---------------------------------------------------------------------
-- 4. RLS + yetkiler (fail-closed)
--   Yönetici fonksiyonları SECURITY DEFINER; istemciye tablo yetkisi yok.
-- ---------------------------------------------------------------------
alter table public.deneme_sinavlari          enable row level security;
alter table public.deneme_sinavi_sorulari    enable row level security;
alter table public.deneme_sinavi_denemeleri  enable row level security;

revoke all on table public.deneme_sinavlari         from public, anon, authenticated;
revoke all on table public.deneme_sinavi_sorulari   from public, anon, authenticated;
revoke all on table public.deneme_sinavi_denemeleri from public, anon, authenticated;

-- =====================================================================
-- 5. CANLI GÖVDELER (BİREBİR) — deneme sınavı yönetici RPC'leri
--    Yetki özeti (kurtarilan/parcalar/_ozet.txt):
--      _deneme_sinavi_siniflar_gecerli : anon: false | auth: false | servis: true
--      admin_*                         : anon: false | auth: true  | servis: true
-- =====================================================================

-- 5.1 _deneme_sinavi_siniflar_gecerli — sınıf dizisi desteği denetimi
create or replace function public._deneme_sinavi_siniflar_gecerli(p_siniflar smallint[])
returns boolean
language sql
stable security definer
set search_path to ''
as $function$
  select p_siniflar is not null and cardinality(p_siniflar) > 0
     and not exists (
       select 1 from unnest(p_siniflar) s
        where s <> all (public._desteklenen_siniflar())
     );
$function$;

comment on function public._deneme_sinavi_siniflar_gecerli(smallint[]) is
  'Sınavın sınıf dizisi boş değilse ve tamamı desteklenen sınıflardansa true döner.';

-- 5.2 admin_upsert_mock_exam
create or replace function public.admin_upsert_mock_exam(
  p_id uuid,
  p_ad text,
  p_baslangic timestamptz,
  p_sure_dakika integer default 40,
  p_siniflar smallint[] default null,
  p_aktif boolean default true
)
returns uuid
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_id uuid := p_id;
begin
  perform public.require_admin();

  if p_ad is null or length(trim(p_ad)) < 2 or length(trim(p_ad)) > 120 then
    raise exception 'Sınav adı 2-120 karakter olmalı' using errcode = '22023';
  end if;
  if p_baslangic is null then
    raise exception 'Başlangıç tarihi/saati gerekli' using errcode = '22023';
  end if;
  if p_sure_dakika is null or p_sure_dakika < 5 or p_sure_dakika > 240 then
    raise exception 'Süre 5-240 dakika arasında olmalı' using errcode = '22023';
  end if;
  if not public._deneme_sinavi_siniflar_gecerli(p_siniflar) then
    raise exception 'Geçersiz sınıf seçimi (desteklenmeyen bir sınıf var)' using errcode = '22023';
  end if;

  if v_id is null then
    insert into public.deneme_sinavlari (ad, baslangic_zamani, sure_dakika, siniflar, aktif, created_by)
    values (trim(p_ad), p_baslangic, p_sure_dakika, p_siniflar, coalesce(p_aktif, true), (select auth.uid()))
    returning id into v_id;
  else
    update public.deneme_sinavlari
       set ad = trim(p_ad), baslangic_zamani = p_baslangic, sure_dakika = p_sure_dakika,
           siniflar = p_siniflar, aktif = coalesce(p_aktif, true), updated_at = now()
     where id = v_id;
    if not found then
      raise exception 'Sınav bulunamadı' using errcode = 'P0002';
    end if;
  end if;

  perform public.log_admin_action('deneme_sinavi_kaydedildi', jsonb_build_object('sinav_id', v_id, 'ad', trim(p_ad)));
  return v_id;
end;
$function$;

comment on function public.admin_upsert_mock_exam(uuid, text, timestamptz, integer, smallint[], boolean) is
  'Deneme sınavı tanımını ekler/günceller (ad, başlangıç, süre, sınıflar, aktiflik).';

-- 5.3 admin_list_mock_exams
create or replace function public.admin_list_mock_exams()
returns jsonb
language plpgsql
stable security definer
set search_path to ''
as $function$
begin
  perform public.require_admin();
  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.baslangic_zamani desc, x.id)
      from (
        select e.id, e.ad, e.baslangic_zamani, e.sure_dakika, e.siniflar, e.aktif, e.sorular_kilitli,
               e.created_at,
               (select count(distinct sinif) from public.deneme_sinavi_sorulari q where q.exam_id = e.id)::integer
                 as soru_atanan_sinif_sayisi
          from public.deneme_sinavlari e
      ) x
  ), '[]'::jsonb);
end;
$function$;

comment on function public.admin_list_mock_exams() is
  'Deneme sınavlarını en yeni başlangıçtan geriye listeler.';

-- 5.4 admin_set_mock_exam_active
create or replace function public.admin_set_mock_exam_active(p_id uuid, p_aktif boolean)
returns void
language plpgsql
security definer
set search_path to ''
as $function$
begin
  perform public.require_admin();
  update public.deneme_sinavlari set aktif = coalesce(p_aktif, false), updated_at = now() where id = p_id;
  if not found then
    raise exception 'Sınav bulunamadı' using errcode = 'P0002';
  end if;
  perform public.log_admin_action('deneme_sinavi_durumu_degisti', jsonb_build_object('sinav_id', p_id, 'aktif', p_aktif));
end;
$function$;

comment on function public.admin_set_mock_exam_active(uuid, boolean) is
  'Deneme sınavını yayına alır/kaldırır.';

-- 5.5 admin_set_mock_exam_questions
create or replace function public.admin_set_mock_exam_questions(p_exam_id uuid, p_sinif integer, p_question_ids uuid[])
returns void
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_exam public.deneme_sinavlari%rowtype;
  v_eksik integer;
begin
  perform public.require_admin();

  select * into v_exam from public.deneme_sinavlari where id = p_exam_id for update;
  if not found then
    raise exception 'Sınav bulunamadı' using errcode = 'P0002';
  end if;
  if v_exam.sorular_kilitli then
    raise exception 'Bu sınavın soruları kilitlendi, değiştirilemez' using errcode = '42501';
  end if;
  if now() > v_exam.baslangic_zamani then
    raise exception 'Başlamış/geçmiş bir sınavın soruları değiştirilemez' using errcode = '42501';
  end if;
  if p_sinif is null or p_sinif::smallint <> all (v_exam.siniflar) then
    raise exception 'Bu sınıf bu sınava atanmamış' using errcode = '22023';
  end if;
  if p_question_ids is null or cardinality(p_question_ids) = 0 then
    raise exception 'En az bir soru seçilmeli' using errcode = '22023';
  end if;

  select count(*) into v_eksik
    from unnest(p_question_ids) qid
   where not exists (select 1 from public.questions q where q.id = qid);
  if v_eksik > 0 then
    raise exception 'Seçilen sorulardan % tanesi bulunamadı', v_eksik using errcode = 'P0002';
  end if;

  delete from public.deneme_sinavi_sorulari where exam_id = p_exam_id and sinif = p_sinif::smallint;

  insert into public.deneme_sinavi_sorulari (exam_id, sinif, question_id, sira)
  select p_exam_id, p_sinif::smallint, qid, row_number() over ()
    from unnest(p_question_ids) qid;

  perform public.log_admin_action('deneme_sinavi_sorulari_belirlendi',
    jsonb_build_object('sinav_id', p_exam_id, 'sinif', p_sinif, 'soru_sayisi', cardinality(p_question_ids)));
end;
$function$;

comment on function public.admin_set_mock_exam_questions(uuid, integer, uuid[]) is
  'Bir sınıfın sınav sorularını verilen sırayla baştan yazar (başlamış/kilitli sınavda 42501).';

-- 5.6 admin_get_mock_exam_questions
create or replace function public.admin_get_mock_exam_questions(p_exam_id uuid, p_sinif integer)
returns jsonb
language plpgsql
stable security definer
set search_path to ''
as $function$
begin
  perform public.require_admin();
  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.sira)
      from (
        select s.sira, q.id, q.ders, q.konu, q.alt_konu, q.zorluk, q.soru_metni
          from public.deneme_sinavi_sorulari s
          join public.questions q on q.id = s.question_id
         where s.exam_id = p_exam_id and s.sinif = p_sinif::smallint
      ) x
  ), '[]'::jsonb);
end;
$function$;

comment on function public.admin_get_mock_exam_questions(uuid, integer) is
  'Sınavın bir sınıf için seçilmiş sorularını sıra numarasıyla döner.';

-- 5.7 admin_get_mock_exam_results
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
  bitis_zamani timestamptz
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
      d.puan,
      d.dogru_sayisi,
      d.yanlis_sayisi,
      d.bos_sayisi,
      rank() over (partition by d.sinif order by d.puan desc, d.bitis_zamani asc),
      d.bitis_zamani
    from public.deneme_sinavi_denemeleri d
    join public.profiles p on p.id = d.student_id
   where d.exam_id = p_exam_id and d.bitis_zamani is not null
   order by d.sinif, d.puan desc, d.bitis_zamani asc;
end;
$function$;

comment on function public.admin_get_mock_exam_results(uuid) is
  'Bitmiş denemeleri sınıf içi sıralamayla döner (sıra: puan desc, bitiş zamanı asc).';

-- =====================================================================
-- 6. REVOKE / GRANT — canlı yetki özeti birebir
-- =====================================================================
revoke execute on function public._deneme_sinavi_siniflar_gecerli(smallint[]) from public, anon, authenticated;

revoke execute on function public.admin_upsert_mock_exam(uuid, text, timestamptz, integer, smallint[], boolean) from public, anon;
grant  execute on function public.admin_upsert_mock_exam(uuid, text, timestamptz, integer, smallint[], boolean) to authenticated;

revoke execute on function public.admin_list_mock_exams() from public, anon;
grant  execute on function public.admin_list_mock_exams() to authenticated;

revoke execute on function public.admin_set_mock_exam_active(uuid, boolean) from public, anon;
grant  execute on function public.admin_set_mock_exam_active(uuid, boolean) to authenticated;

revoke execute on function public.admin_set_mock_exam_questions(uuid, integer, uuid[]) from public, anon;
grant  execute on function public.admin_set_mock_exam_questions(uuid, integer, uuid[]) to authenticated;

revoke execute on function public.admin_get_mock_exam_questions(uuid, integer) from public, anon;
grant  execute on function public.admin_get_mock_exam_questions(uuid, integer) to authenticated;

revoke execute on function public.admin_get_mock_exam_results(uuid) from public, anon;
grant  execute on function public.admin_get_mock_exam_results(uuid) to authenticated;
