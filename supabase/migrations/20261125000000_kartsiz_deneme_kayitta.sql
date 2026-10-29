-- =====================================================================
--  Kartsız ücretsiz deneme (14 gün) + deneme sırasında özellik sınırları
--  Tarih : 2026-10-29
--
--  1) Veli hesabı açılınca hane için deneme başlar (deneme.gun, varsayılan 14).
--     Yalnız yeni INSERT'te çalışır; mevcut hesaplara geriye dönük deneme AÇILMAZ.
--     Kart istenmez; deneme bitince otomatik ücret alınmaz.
--
--  2) Deneme aktifken uygulama sınırsız değildir. Sınırlar app_settings
--     'deneme_sinirlari' ayarında tutulur:
--       { "varsayilan": { "<ozellik>": {"sinir": N, "pencere": "gunluk"|"deneme"} },
--         "siniflar":   { "<sinif 1-12>": { "<ozellik>": {...} } } }
--     - pencere "gunluk": İstanbul günü başına; "deneme": deneme süresi boyunca toplam.
--     - Sınıf override'ı yalnız o özelliği değiştirir; yoksa varsayılan geçerlidir.
--     - Sayım doğrudan özelliğin kendi tablosundan yapılır (ayrı sayaç yok).
--     - Yalnız oturumlu (istemci) yazımları sınırlanır; servis/sunucu yazımları
--       etkilenmez. Premium ve deneme dışı hesaplarda davranış değişmez.
--     - Sınır dolunca P0402 hatası döner (quiz ekranı bunu kota olarak gösterir).
--
--  3) Soru çözme sınırı remaining_free_questions / my_quiz_quota içinde sınıf
--     bazlı okunur (soru ayarı yoksa deneme.gunluk_soru kullanılır).
--
--  Not: Bu migration uzak veritabanına yalnızca onayla uygulanır. 20261108,
--  20261109 ve 20261124 bu migration'a bağlı değildir ve uygulanmaz.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Kayıtta deneme
-- ---------------------------------------------------------------------
create or replace function public.deneme_veli_profili_ekle()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_gun integer;
begin
  if new.role is distinct from 'veli' then
    return new;
  end if;

  -- Hane başına bir kez: daha önce deneme kaydı (kendiliğinden ya da admin) varsa dokunma.
  if exists (select 1 from public.deneme_donemleri d where d.veli_id = new.id) then
    return new;
  end if;

  select a.gun into v_gun from public._deneme_ayar() a;

  insert into public.deneme_donemleri (veli_id, bitis)
  values (new.id, now() + make_interval(days => v_gun));

  return new;
end;
$$;

comment on function public.deneme_veli_profili_ekle() is
  'Yeni veli profilinde hane için kartsız ücretsiz deneme başlatır (app_settings deneme.gun).';

revoke execute on function public.deneme_veli_profili_ekle() from public, anon, authenticated;

drop trigger if exists trg_deneme_veli_profili_ekle on public.profiles;
create trigger trg_deneme_veli_profili_ekle
  after insert on public.profiles
  for each row execute function public.deneme_veli_profili_ekle();

-- ---------------------------------------------------------------------
-- 2. Sınır ayarı (varsayılan değerler)
-- ---------------------------------------------------------------------
insert into public.app_settings (key, value)
values ('deneme_sinirlari', '{
  "varsayilan": {
    "soru":           {"sinir": 20, "pencere": "gunluk"},
    "kelime_evreni":  {"sinir": 30, "pencere": "gunluk"},
    "carpim_sifresi": {"sinir": 40, "pencere": "gunluk"},
    "okuma_hikayesi": {"sinir": 2,  "pencere": "gunluk"},
    "meydan_okuma":   {"sinir": 3,  "pencere": "deneme"},
    "deneme_sinavi":  {"sinir": 2,  "pencere": "deneme"}
  },
  "siniflar": {}
}'::jsonb)
on conflict (key) do nothing;

-- Çocuğun sınıfına göre sınır nesnesi; sınıf override'ı yoksa varsayılan. Yoksa null (sınırsız).
create or replace function public._deneme_sinir(p_ogrenci uuid, p_ozellik text)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    (select s.value -> 'siniflar' -> (p.sinif::text) -> p_ozellik
       from public.app_settings s
       join public.profiles p on p.id = p_ogrenci
      where s.key = 'deneme_sinirlari' and p.sinif is not null),
    (select s.value -> 'varsayilan' -> p_ozellik
       from public.app_settings s
      where s.key = 'deneme_sinirlari')
  );
$$;

revoke execute on function public._deneme_sinir(uuid, text) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 3. Sınır tetikleyicisi (özellik tablolarında AFTER INSERT)
--    TG_ARGV[0] öğrenci kolonu, [1] zaman kolonu, [2] özellik anahtarı, [3] Türkçe etiket
-- ---------------------------------------------------------------------
create or replace function public.deneme_sinir_tetik()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_ogrenci uuid := (to_jsonb(new) ->> TG_ARGV[0])::uuid;
  v_zaman   text := TG_ARGV[1];
  v_ozellik text := TG_ARGV[2];
  v_etiket  text := TG_ARGV[3];
  v_sinir   jsonb;
  v_pencere text;
  v_limit   integer;
  v_bas     timestamptz;
  v_bit     timestamptz := 'infinity'::timestamptz;
  v_sayi    bigint;
begin
  -- Yalnız oturumlu (istemci) yazımları; servis ve sunucu yazımları etkilenmez.
  if (select auth.uid()) is null or v_ogrenci is null then
    return new;
  end if;
  if public.is_premium(v_ogrenci) or not public._deneme_aktif(v_ogrenci) then
    return new;
  end if;

  v_sinir := public._deneme_sinir(v_ogrenci, v_ozellik);
  if v_sinir is null then
    return new;
  end if;
  v_limit   := (v_sinir ->> 'sinir')::integer;
  v_pencere := coalesce(v_sinir ->> 'pencere', 'gunluk');

  if v_pencere = 'deneme' then
    select max(d.baslangic) into v_bas
      from public.deneme_donemleri d
     where d.veli_id = public._deneme_sahibi(v_ogrenci) and d.bitis > now();
  else
    v_bas := ((now() at time zone 'Europe/Istanbul')::date)::timestamp at time zone 'Europe/Istanbul';
    v_bit := v_bas + interval '1 day';
  end if;

  execute format(
    'select count(*) from public.%I where %I = $1 and %I >= $2 and %I < $3',
    TG_TABLE_NAME, TG_ARGV[0], v_zaman, v_zaman)
    into v_sayi using v_ogrenci, v_bas, v_bit;

  -- AFTER INSERT: sayım yeni satırı içerir; idempotent (ON CONFLICT) tekrarlar insert
  -- tetikleyicisini ateşlemez, bu yüzden tekrar gönderim sınıra takılmaz.
  if v_sayi > v_limit then
    raise exception '%', format('%s için %s ücretsiz hakkın doldu.', v_etiket,
      case when v_pencere = 'deneme' then 'deneme süresindeki' else 'bugünkü' end)
      using errcode = 'P0402';
  end if;
  return new;
end;
$$;

revoke execute on function public.deneme_sinir_tetik() from public, anon, authenticated;

drop trigger if exists trg_deneme_sinir_kelime on public.kelime_denemeleri;
create trigger trg_deneme_sinir_kelime after insert on public.kelime_denemeleri
  for each row execute function public.deneme_sinir_tetik('ogrenci_id', 'created_at', 'kelime_evreni', 'Kelime Evreni');

drop trigger if exists trg_deneme_sinir_carpim on public.carpim_deneme_log;
create trigger trg_deneme_sinir_carpim after insert on public.carpim_deneme_log
  for each row execute function public.deneme_sinir_tetik('user_id', 'created_at', 'carpim_sifresi', 'Çarpım şifreleri');

drop trigger if exists trg_deneme_sinir_deneme_sinavi on public.deneme_sinavi_katilimlari;
create trigger trg_deneme_sinir_deneme_sinavi after insert on public.deneme_sinavi_katilimlari
  for each row execute function public.deneme_sinir_tetik('student_id', 'kayit_zamani', 'deneme_sinavi', 'Deneme sınavı');

drop trigger if exists trg_deneme_sinir_okuma on public.okuma_oturumlari;
create trigger trg_deneme_sinir_okuma after insert on public.okuma_oturumlari
  for each row execute function public.deneme_sinir_tetik('ogrenci_id', 'baslangic_at', 'okuma_hikayesi', 'Okuma hikâyesi');

drop trigger if exists trg_deneme_sinir_meydan on public.meydan_okumalar;
create trigger trg_deneme_sinir_meydan after insert on public.meydan_okumalar
  for each row execute function public.deneme_sinir_tetik('davet_eden', 'olusturulma', 'meydan_okuma', 'Meydan okuma');

-- ---------------------------------------------------------------------
-- 4. Soru kotası: deneme aktifken sınıf bazlı soru sınırı
-- ---------------------------------------------------------------------
create or replace function public.remaining_free_questions(p_uid uuid)
returns integer
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  g record;
  v_limit    integer;
  v_kullanilan integer;
begin
  if public.is_premium(p_uid) then
    return null;
  end if;

  if public._deneme_aktif(p_uid) then
    v_limit := coalesce(
      (public._deneme_sinir(p_uid, 'soru') ->> 'sinir')::integer,
      (select a.gunluk_soru from public._deneme_ayar() a));
  else
    select * into g from public._gating();
    if not g.aktif then
      return null;
    end if;
    v_limit := g.limit_gun;
  end if;

  select count(*)::integer into v_kullanilan
    from public.answer_events
   where student_id = p_uid
     and (created_at at time zone 'Europe/Istanbul')::date = (now() at time zone 'Europe/Istanbul')::date;
  return greatest(v_limit - v_kullanilan, 0);
end;
$$;

create or replace function public.my_quiz_quota()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := (select auth.uid());
  g         record;
  v_premium boolean;
  v_deneme  boolean;
  v_kalan   integer;
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  select * into g from public._gating();
  v_premium := public.is_premium(v_uid);
  v_deneme  := not v_premium and public._deneme_aktif(v_uid);
  v_kalan   := public.remaining_free_questions(v_uid);
  return jsonb_build_object(
    'gating_aktif', g.aktif or v_deneme,
    'premium', v_premium,
    'deneme', v_deneme,
    'ucretsiz_gunluk_soru',
      case when v_deneme
        then coalesce((public._deneme_sinir(v_uid, 'soru') ->> 'sinir')::integer,
                      (select a.gunluk_soru from public._deneme_ayar() a))
        else g.limit_gun end,
    'kalan', v_kalan,
    'izinli', coalesce(v_kalan, 1) > 0);
end;
$$;

-- ---------------------------------------------------------------------
-- 5. Yönetici: sınır ayarını doğrulayarak yazar
-- ---------------------------------------------------------------------
create or replace function public.admin_set_deneme_sinirlari(p_value jsonb)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_obj jsonb;
  v_sinif text;
begin
  perform public.require_admin();

  if jsonb_typeof(p_value) is distinct from 'object'
     or jsonb_typeof(p_value -> 'varsayilan') is distinct from 'object'
     or (p_value ? 'siniflar' and jsonb_typeof(p_value -> 'siniflar') is distinct from 'object') then
    raise exception 'deneme_sinirlari: {"varsayilan": {...}, "siniflar": {...}} olmalı' using errcode = '22023';
  end if;

  -- Sınıf anahtarları 1-12
  for v_sinif in select jsonb_object_keys(coalesce(p_value -> 'siniflar', '{}'::jsonb)) loop
    if v_sinif !~ '^([1-9]|1[0-2])$' then
      raise exception 'deneme_sinirlari: sınıf anahtarı 1-12 olmalı (%)', v_sinif using errcode = '22023';
    end if;
    if jsonb_typeof(p_value -> 'siniflar' -> v_sinif) is distinct from 'object' then
      raise exception 'deneme_sinirlari: sınıf % bir nesne olmalı', v_sinif using errcode = '22023';
    end if;
  end loop;

  -- Her özellik: {"sinir": 0-1000 tam sayı, "pencere": "gunluk" | "deneme"}
  for v_obj in
    select e.value from jsonb_each(p_value -> 'varsayilan') e
    union all
    select f.value from jsonb_each(coalesce(p_value -> 'siniflar', '{}'::jsonb)) c,
                        jsonb_each(c.value) f
  loop
    if jsonb_typeof(v_obj) is distinct from 'object'
       or jsonb_typeof(v_obj -> 'sinir') is distinct from 'number'
       or (v_obj ->> 'sinir') !~ '^[0-9]{1,4}$'
       or (v_obj ->> 'sinir')::integer > 1000
       or coalesce(v_obj ->> 'pencere', '') not in ('gunluk', 'deneme') then
      raise exception 'deneme_sinirlari: her özellik {"sinir": 0-1000, "pencere": "gunluk"|"deneme"} olmalı'
        using errcode = '22023';
    end if;
  end loop;

  insert into public.app_settings (key, value) values ('deneme_sinirlari', p_value)
  on conflict (key) do update set value = excluded.value, updated_at = now();

  perform public.log_admin_action('ayar_degisti', jsonb_build_object('key', 'deneme_sinirlari'));
end;
$$;

revoke execute on function public.admin_set_deneme_sinirlari(jsonb) from public, anon;
grant  execute on function public.admin_set_deneme_sinirlari(jsonb) to authenticated;
