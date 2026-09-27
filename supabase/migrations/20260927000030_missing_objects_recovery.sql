-- =====================================================================
--  KURTARMA: eksik kalan nesneler (canlıdan birebir)
--  Proje : ccozfrpnvyrnktpffkwo — Öğrenci Hazırlık / Hupo
--  Tarih : 2026-09-27
--
--  KAYNAK (SQL Editor çıktıları, katalogdan okundu — TAHMİN YOK):
--    kurtarilan/cikti-bagimlilik.csv  → fonksiyon gövdeleri + kolonlar
--    kurtarilan/cikti-carpim3.csv     → kısıtlar ve indexler
--    kurtarilan/cikti-kalan.csv       → admin_set_daily_challenge gövdesi
--
--  Sıra: 20260927000010 (tablolar) ve 20260927000020 (RPC'ler) SONRASI.
--
--  BU DOSYADAN SONRA HÂLÂ EKSİK (bkz. bölüm 5 ve supabase/KURTARMA_DURUMU.md):
--    * public.question_quality_config tablosu (kolonları alınmadı)
--    * grade_changes / question_reports RLS politikaları
--    * carpim_sifreleri içerik verisi (10-12 şifre)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) grade_changes — sınıf değişiklik geçmişi
--    (canlıda rls=true, 3 satır)
-- ---------------------------------------------------------------------
create table if not exists public.grade_changes (
  id          uuid        primary key default gen_random_uuid(),
  user_id     uuid        not null
                references public.profiles(id) on delete cascade,
  eski_sinif  smallint,
  yeni_sinif  smallint    not null,
  degistiren  uuid
                references public.profiles(id) on delete set null,
  kaynak      text        not null,
  created_at  timestamptz not null default now(),

  -- Sınıfı kimin değiştirdiği: öğrenci kendi mi, veli mi
  constraint grade_changes_kaynak_check
    check (kaynak in ('ogrenci', 'veli'))
);

comment on table public.grade_changes is
  'Sınıf değişikliği geçmişi. _sinif_yaz() her gerçek değişiklikte bir satır yazar.';
comment on column public.grade_changes.eski_sinif is
  'Değişiklikten önceki sınıf. İlk atamada NULL olabilir.';
comment on column public.grade_changes.degistiren is
  'Değişikliği yapan kullanıcı (öğrenci/veli). Silinirse NULL olur.';

-- Öğrenci: sınıf geçmişini yeniden eskiye listeler
create index if not exists grade_changes_user_idx
  on public.grade_changes (user_id, created_at desc);

-- ---------------------------------------------------------------------
-- 2) question_reports — soru bildirimleri
--    (canlıda rls=true, 0 satır)
-- ---------------------------------------------------------------------
create table if not exists public.question_reports (
  id           uuid        primary key default gen_random_uuid(),
  question_id  uuid        not null
                 references public.questions(id) on delete cascade,
  reporter_id  uuid
                 references public.profiles(id) on delete set null,
  neden        text        not null,
  not_metni    text,
  durum        text        not null default 'acik',
  admin_notu   text,
  cozen_id     uuid
                 references public.profiles(id) on delete set null,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),

  constraint question_reports_neden_check
    check (neden in ('yanlis_cevap', 'anlasilmiyor', 'yazim', 'diger')),
  constraint question_reports_durum_check
    check (durum in ('acik', 'inceleniyor', 'cozuldu', 'gecersiz')),
  constraint question_reports_not_metni_check
    check (not_metni is null or char_length(not_metni) <= 200),
  constraint question_reports_admin_notu_check
    check (admin_notu is null or char_length(admin_notu) <= 500)
);

comment on table public.question_reports is
  'Öğrencinin bildirdiği sorunlu sorular. Eşik aşılınca _refresh_question_flag() soruyu işaretler.';
comment on column public.question_reports.durum is
  'Bildirimin durumu: acik / inceleniyor / cozuldu / gecersiz.';
comment on column public.question_reports.cozen_id is
  'Bildirimi kapatan yönetici. Silinirse NULL olur.';

-- Yönetici: açık bildirimleri sürebilir
create index if not exists question_reports_durum_idx
  on public.question_reports (durum, created_at desc);
-- Yönetici: bir sorunun tüm bildirimleri
create index if not exists question_reports_q_idx
  on public.question_reports (question_id);
-- Öğrenci: kendi bildirimleri
create index if not exists question_reports_reporter_idx
  on public.question_reports (reporter_id, created_at desc);

-- Aynı kişi aynı soruyu, kapanmadan yalnızca bir kez bildirebilir
create unique index if not exists question_reports_one_open
  on public.question_reports (question_id, reporter_id)
  where durum in ('acik', 'inceleniyor');

-- ---------------------------------------------------------------------
-- 3) Yetkiler (RLS fail-closed) — canlıda iki tabloda da rls=true
-- ---------------------------------------------------------------------
-- TODO(kurtarma): Canlıdaki RLS politikaları henüz alınmadı.
-- Bu yüzden politikalar BİLEREK yazılmadı (uydurulmadı): politika yoksa
-- anon/authenticated hiçbir satırı göremez. Uygulama bu iki tabloya
-- yalnızca SECURITY DEFINER RPC'ler üzerinden (set_my_grade,
-- report_question) dokunduğu için kapanış davranışı bozmaz.
-- Gerçek politikalar alınınca buraya eklenecek. Getirme sorgusu:
--   select c.relname, p.polname, p.polcmd, p.polpermissive,
--          pg_get_expr(p.polqual, p.polrelid)       as kullanim_kosulu,
--          pg_get_expr(p.polwithcheck, p.polrelid)  as yazma_kosulu
--   from pg_class c
--   left join pg_policy p on p.polrelid = c.oid
--   where c.relnamespace = 'public'::regnamespace
--     and c.relname in ('grade_changes', 'question_reports')
--   order by c.relname, p.polname;

alter table public.grade_changes    enable row level security;
alter table public.question_reports enable row level security;

-- Anon erişimi kapalı (policy yok + açık revoke ile çift katman)
revoke all on public.grade_changes    from anon;
revoke all on public.question_reports from anon;
-- Girişli kullanıcı doğrudan yazamaz; yazma yalnızca RPC'lerden geçer
revoke insert, update, delete on public.grade_changes    from authenticated;
revoke insert, update, delete on public.question_reports from authenticated;

-- ---------------------------------------------------------------------
-- 4) Yardımcı fonksiyonlar (canlıdan birebir, gövdeler değiştirilmedi)
-- ---------------------------------------------------------------------
-- NOT: Canlı sürümlerde arama yolu bilerek boştur (set search_path TO '')
-- ve tüm nesneler public. ile nitelendirilmiştir. Bu, public, pg_temp
-- alışkanlığından daha katı bir sertleştirmedir; birebir korunmuştur.

-- 4.1 Desteklenen sınıflar (app_settings.desteklenen_siniflar anahtarı)
create or replace function public._desteklenen_siniflar()
returns integer[]
language sql
stable security definer
set search_path to ''
as $function$
  select coalesce(
    (select array_agg(distinct x::integer order by x::integer)
       from public.app_settings s,
            jsonb_array_elements_text(
              case when jsonb_typeof(s.value -> 'siniflar') = 'array'
                   then s.value -> 'siniflar' else '[]'::jsonb end) x
      where s.key = 'desteklenen_siniflar' and x ~ '^([1-9]|1[0-2])$'),
    array[1, 2, 3, 4, 5, 6, 7, 8]);
$function$;

comment on function public._desteklenen_siniflar() is
  'app_settings.desteklenen_siniflar ayarından geçerli sınıf listesini okur, yoksa 1-8 döner.';

-- 4.2 Sınıfı yaz (kayıt geçmişi ile birlikte)
create or replace function public._sinif_yaz(
  p_cocuk uuid,
  p_sinif integer,
  p_kaynak text
)
returns integer
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_eski smallint;
begin
  if p_sinif is null or not (p_sinif = any (public._desteklenen_siniflar())) then
    raise exception 'Bu sınıf şu an desteklenmiyor' using errcode = '22023';
  end if;

  select sinif into v_eski from public.profiles where id = p_cocuk;
  if v_eski is not distinct from p_sinif::smallint then
    return p_sinif;   -- değişiklik yok, kayıt da yok
  end if;

  perform set_config('app.grade_rpc', 'on', true);
  update public.profiles set sinif = p_sinif::smallint where id = p_cocuk;
  perform set_config('app.grade_rpc', 'off', true);

  insert into public.grade_changes (user_id, eski_sinif, yeni_sinif, degistiren, kaynak)
  values (p_cocuk, v_eski, p_sinif::smallint, (select auth.uid()), p_kaynak);
  return p_sinif;
end;
$function$;

comment on function public._sinif_yaz(uuid, integer, text) is
  'Sınıfı doğrular, profiles.sinif''ı günceller ve grade_changes''e geçmiş yazar.';
-- TODO(kurtarma): profiles üzerindeki 30 gün / 24 saat kuralını uygulayan
-- trigger canlıdaki 'app.grade_rpc' bayrağına bakıyor. O trigger'ın tanımı
-- alınana kadar kural geçerli değildir (bkz. bölüm 5).

-- 4.3 Bildirim eşiği aşıldı mı? → soruyu incelemeye al
create or replace function public._refresh_question_flag(p_question_id uuid)
returns void
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_cfg record;
  v_n   integer;
  v_aktif boolean;
begin
  select rapor_esigi, otomatik_gizle into v_cfg from public.question_quality_config where id;
  select count(distinct reporter_id)::integer into v_n
    from public.question_reports
   where question_id = p_question_id and durum in ('acik', 'inceleniyor');
  v_aktif := v_n >= coalesce(v_cfg.rapor_esigi, 3);

  update public.questions
     set inceleme_gerekli = v_aktif,
         onay_durumu = case
           when v_aktif and coalesce(v_cfg.otomatik_gizle, false) and onay_durumu = 'onaylandi'
             then 'beklemede' else onay_durumu end
   where id = p_question_id
     and (inceleme_gerekli is distinct from v_aktif
          or (v_aktif and coalesce(v_cfg.otomatik_gizle, false) and onay_durumu = 'onaylandi'));
end;
$function$;

comment on function public._refresh_question_flag(uuid) is
  'Farklı bildirim sayısı eşiği aşarsa soruyu inceleme_gerekli olarak işaretler.';

-- ---------------------------------------------------------------------
-- 4.4 Yetki daraltma — iç yardımcılar yalnızca fonksiyon içinden çağrılır
--     (canlıda gövde içi çağrılar SECURITY DEFINER sahibi postgres ile
--      çalışır; bu yüzden istemciye EXECUTE vermek GEREKMEZ)
-- TODO(kurtarma): Bu üç fonksiyonun canlı yetkileri alınmadı; AGENTS.md
-- §5.2 gereği yetki GENİŞLETİLMEDİ, daraltıldı. Canlıda authenticated
-- erişimi çıkarsa buraya grant eklenecek.
-- ---------------------------------------------------------------------
revoke execute on function public._desteklenen_siniflar() from public, anon, authenticated;
revoke execute on function public._sinif_yaz(uuid, integer, text) from public, anon, authenticated;
revoke execute on function public._refresh_question_flag(uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 4.5 Yönetici: günün 5 sorusunu elle seç
--     (canlı yetkiler: anon: false | auth: true | servis: true)
-- ---------------------------------------------------------------------
create or replace function public.admin_set_daily_challenge(
  p_gun date,
  p_question_ids uuid[],
  p_anahtar text default null
)
returns void
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_sinif smallint;
begin
  perform public.require_admin();

  if p_gun is null or p_question_ids is null or cardinality(p_question_ids) <> 5
     or (select count(distinct x) from unnest(p_question_ids) x) <> 5 then
    raise exception 'Tam olarak 5 farklı soru gerekli' using errcode = '22023';
  end if;
  if (select count(*) from public.questions
       where id = any (p_question_ids) and onay_durumu = 'onaylandi') <> 5 then
    raise exception 'Yalnızca onaylı sorular seçilebilir' using errcode = '22023';
  end if;

  if p_anahtar is null then
    -- Soruların sınıfından türet (5 soru da aynı sınıfta olmalı).
    select min(q.sinif) into v_sinif from public.questions q where q.id = any (p_question_ids);
    if v_sinif is null
       or exists (select 1 from public.questions q
                   where q.id = any (p_question_ids) and q.sinif is distinct from v_sinif) then
      raise exception 'Seçilen sorular aynı sınıfa ait olmalı' using errcode = '22023';
    end if;
    p_anahtar := 'sinif' || v_sinif;
  end if;

  -- 'sinifN' (yeni) veya eski seviye anahtarları (yalnızca geriye dönük kayıtlar için)
  if p_anahtar !~ '^(sinif([1-9]|1[0-2])|ilkokul|ortaokul|lise|hepsi)$' then
    raise exception 'anahtar sinif1-sinif12 (veya eski ilkokul/ortaokul/lise/hepsi) olmalı'
      using errcode = '22023';
  end if;

  if p_anahtar ~ '^sinif' then
    v_sinif := substr(p_anahtar, 6)::smallint;
    if exists (select 1 from public.questions q
                where q.id = any (p_question_ids) and q.sinif is distinct from v_sinif) then
      raise exception 'Seçilen sorular % anahtarıyla uyuşmuyor', p_anahtar using errcode = '22023';
    end if;
  end if;

  insert into public.daily_challenges (gun, anahtar, question_ids, elle_secildi)
  values (p_gun, p_anahtar, p_question_ids, true)
  on conflict (gun, anahtar) do update
    set question_ids = excluded.question_ids, elle_secildi = true;

  perform public.log_admin_action('gunun_sorusu_secildi', jsonb_build_object(
    'gun', p_gun, 'anahtar', p_anahtar, 'question_ids', p_question_ids));
end;
$function$;

comment on function public.admin_set_daily_challenge(date, uuid[], text) is
  'Yönetici, bir gün için tam 5 onaylı soruyu elle seçer (elle_secildi = true).';

revoke execute on function public.admin_set_daily_challenge(date, uuid[], text) from public, anon;
grant  execute on function public.admin_set_daily_challenge(date, uuid[], text) to authenticated;

-- =====================================================================
-- 5) HÂLÂ EKSİK — bunlar gelmeden ilgili özellik ÇALIŞMAZ
--    Ayrıntılı adımlar: supabase/KURTARMA_DURUMU.md §3
-- =====================================================================
-- 5.1 public.question_quality_config (TABLO) — kolonları alınmadı
--     _refresh_question_flag() buradan rapor_esigi + otomatik_gizle okur;
--     tablo yokken report_question() çağrısı hata verir.
--       select column_name, data_type, is_nullable, column_default
--       from information_schema.columns
--       where table_schema = 'public' and table_name = 'question_quality_config'
--       order by ordinal_position;
--       select conname, pg_get_constraintdef(oid) from pg_constraint
--       where conrelid = 'public.question_quality_config'::regclass;
--       select * from public.question_quality_config;   -- eşik satırı
--
-- 5.2 profiles sınıf değişikliği kuralı (TRIGGER) — 30 gün / 24 saat
--     _sinif_yaz() 'app.grade_rpc' bayrağını set ediyor; kuralı uygulayan
--     trigger'ın tanımı hâlâ diskte yok.
--       select tgname, pg_get_triggerdef(oid) from pg_trigger
--       where tgrelid = 'public.profiles'::regclass and not tgisinternal;
--
-- 5.3 grade_changes / question_reports RLS politikaları → bölüm 3'teki sorgu
--
-- 5.4 carpim_sifreleri içerik verisi (10-12 şifre satırı)
--       select jsonb_agg(to_jsonb(s) order by s.sira) from public.carpim_sifreleri s;



