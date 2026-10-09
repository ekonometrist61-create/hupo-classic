-- =====================================================================
--  14 günlük deneme süresi + admin yönetimi + deneme günlük kotası
--  Tarih : 2026-10-18
--
--  * deneme_donemleri  : veli (hane) bazlı deneme kaydı; istemciye kapalı.
--  * app_settings 'deneme': {"gun": 1-90, "gunluk_soru": 0-9999}
--      - gun        : yeni denemenin süresi (varsayılan 14)
--      - gunluk_soru: deneme sırasında günlük soru kotası (varsayılan 20)
--  * Deneme aktifken kota = deneme.gunluk_soru (premium_gating açık/kapalı fark etmez).
--    Premium ise sınırsız. Deneme yoksa mevcut premium_gating mantığı aynen geçerli.
--  * Admin RPC'leri: admin_deneme_veli_ara, admin_deneme_baslat, admin_deneme_bitir,
--    admin_deneme_listele. Ayar ekranı: admin_set_setting / admin_get_settings.
--  * İstemci RPC'leri: my_deneme_durumu() (giriş gerekli), get_deneme_ayari() (anon: yalnız gün).
--
--  Not: Bu migration uzak veritabanına henüz uygulanmadı. Uygulamadan önce
--  `npm run db:preview` ile farkı inceleyin.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Deneme kayıtları
-- ---------------------------------------------------------------------
create table if not exists public.deneme_donemleri (
  id          uuid primary key default gen_random_uuid(),
  veli_id     uuid not null references public.profiles (id) on delete cascade,
  baslangic   timestamptz not null default now(),
  bitis       timestamptz not null,
  olusturan   uuid references public.profiles (id) on delete set null,
  created_at  timestamptz not null default now(),
  constraint deneme_bitis_sonra check (bitis > baslangic)
);

create index if not exists deneme_donemleri_veli_bitis_idx
  on public.deneme_donemleri (veli_id, bitis desc);

alter table public.deneme_donemleri enable row level security;
revoke all on public.deneme_donemleri from anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. Varsayılan ayar
-- ---------------------------------------------------------------------
insert into public.app_settings (key, value)
values ('deneme', '{"gun": 14, "gunluk_soru": 20}'::jsonb)
on conflict (key) do nothing;

-- ---------------------------------------------------------------------
-- 3. Yardımcılar (istemciye kapalı)
-- ---------------------------------------------------------------------
-- Çocuk hesabı için hane sahibi velinin id'si; veli için kendi id'si.
create or replace function public._deneme_sahibi(p_uid uuid)
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select case when p.role = 'ogrenci' then p.parent_id else p.id end
    from public.profiles p
   where p.id = p_uid and p.role in ('veli', 'ogrenci');
$$;

create or replace function public._deneme_aktif(p_uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
      from public.deneme_donemleri d
     where d.veli_id = public._deneme_sahibi(p_uid)
       and d.bitis > now()
  );
$$;

create or replace function public._deneme_ayar()
returns table (gun integer, gunluk_soru integer)
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((select (s.value ->> 'gun')::integer from public.app_settings s where s.key = 'deneme'), 14),
         coalesce((select (s.value ->> 'gunluk_soru')::integer from public.app_settings s where s.key = 'deneme'), 20);
$$;

revoke execute on function public._deneme_sahibi(uuid), public._deneme_aktif(uuid), public._deneme_ayar()
  from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 4. Kota: deneme varsa deneme kotası, yoksa mevcut premium_gating mantığı
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
    v_limit := (select a.gunluk_soru from public._deneme_ayar() a);
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

-- Flutter gösterimi: deneme durumunu da döndürür; limit deneme aktifken deneme kotasıdır.
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
      case when v_deneme then (select a.gunluk_soru from public._deneme_ayar() a) else g.limit_gun end,
    'kalan', v_kalan,
    'izinli', coalesce(v_kalan, 1) > 0);
end;
$$;

-- İstemci: kendi hanesinin deneme durumu
create or replace function public.my_deneme_durumu()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := (select auth.uid());
  v_bitis timestamptz;
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  select max(d.bitis) into v_bitis
    from public.deneme_donemleri d
   where d.veli_id = public._deneme_sahibi(v_uid)
     and d.bitis > now();
  return jsonb_build_object(
    'aktif', v_bitis is not null,
    'bitis', v_bitis,
    'kalan_gun', case when v_bitis is null then null
                      else greatest(ceil(extract(epoch from (v_bitis - now())) / 86400.0)::integer, 0) end,
    'gunluk_soru', (select a.gunluk_soru from public._deneme_ayar() a));
end;
$$;

revoke execute on function public.my_deneme_durumu() from public, anon;
grant  execute on function public.my_deneme_durumu() to authenticated;

-- Landing (girişsiz): yalnızca deneme süresi (gün). Kota ve kayıtlar açık değildir.
create or replace function public.get_deneme_ayari()
returns integer
language sql
stable
security definer
set search_path = ''
as $$
  select (select a.gun from public._deneme_ayar() a);
$$;

revoke execute on function public.get_deneme_ayari() from public;
grant  execute on function public.get_deneme_ayari() to anon, authenticated;

-- ---------------------------------------------------------------------
-- 5. Ayar ekranı: admin_set_setting ('deneme' anahtarı eklendi) + admin_get_settings
--    Tam gövde 20261017000000 sürümünden alındı; yalnızca 'deneme' dalı eklendi.
-- ---------------------------------------------------------------------
create or replace function public.admin_set_setting(p_key text, p_value jsonb)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_yeni  jsonb;
  v_p     text;
  v_mesaj text;
  v_liste integer[];
  v_tarih timestamptz;
begin
  perform public.require_admin();

  if p_key = 'premium_gating' then
    if jsonb_typeof(p_value) is distinct from 'object'
       or jsonb_typeof(p_value -> 'aktif') is distinct from 'boolean'
       or jsonb_typeof(p_value -> 'ucretsiz_gunluk_soru') is distinct from 'number'
       or (p_value ->> 'ucretsiz_gunluk_soru') !~ '^[0-9]{1,4}$' then
      raise exception 'premium_gating: {"aktif": true|false, "ucretsiz_gunluk_soru": 0-9999} olmalı'
        using errcode = '22023';
    end if;
    v_yeni := jsonb_build_object('aktif', p_value -> 'aktif',
                                 'ucretsiz_gunluk_soru', p_value -> 'ucretsiz_gunluk_soru');

  elsif p_key = 'deneme' then
    if jsonb_typeof(p_value) is distinct from 'object'
       or jsonb_typeof(p_value -> 'gun') is distinct from 'number'
       or jsonb_typeof(p_value -> 'gunluk_soru') is distinct from 'number'
       or (p_value ->> 'gun') !~ '^[0-9]{1,2}$'
       or (p_value ->> 'gunluk_soru') !~ '^[0-9]{1,4}$' then
      raise exception 'deneme: {"gun": 1-90, "gunluk_soru": 0-9999} olmalı' using errcode = '22023';
    end if;
    if (p_value ->> 'gun')::integer not between 1 and 90 then
      raise exception 'deneme: gün sayısı 1-90 arasında olmalı' using errcode = '22023';
    end if;
    v_yeni := jsonb_build_object('gun', (p_value ->> 'gun')::integer,
                                 'gunluk_soru', (p_value ->> 'gunluk_soru')::integer);

  elsif p_key = 'bakim_modu' then
    if jsonb_typeof(p_value) is distinct from 'object'
       or jsonb_typeof(p_value -> 'aktif') is distinct from 'boolean'
       or jsonb_typeof(coalesce(p_value -> 'mesaj', '""'::jsonb)) is distinct from 'string' then
      raise exception 'bakim_modu: {"aktif": true|false, "mesaj": "metin"} olmalı' using errcode = '22023';
    end if;
    v_mesaj := trim(coalesce(p_value ->> 'mesaj', ''));
    if length(v_mesaj) > 300 then
      raise exception 'Mesaj en fazla 300 karakter olabilir' using errcode = '22023';
    end if;
    v_yeni := jsonb_build_object('aktif', p_value -> 'aktif', 'mesaj', v_mesaj);

  elsif p_key = 'min_surum' then
    if jsonb_typeof(p_value) is distinct from 'object' then
      raise exception 'min_surum bir nesne olmalı' using errcode = '22023';
    end if;
    foreach v_p in array array['android', 'ios', 'web'] loop
      if jsonb_typeof(p_value -> v_p) is distinct from 'string'
         or (p_value ->> v_p) !~ '^[0-9]{1,4}\.[0-9]{1,4}\.[0-9]{1,4}$' then
        raise exception 'min_surum: % için sürüm 1.2.3 biçiminde olmalı', v_p using errcode = '22023';
      end if;
    end loop;
    if jsonb_typeof(coalesce(p_value -> 'mesaj', '""'::jsonb)) is distinct from 'string' then
      raise exception 'min_surum.mesaj metin olmalı' using errcode = '22023';
    end if;
    v_mesaj := trim(coalesce(p_value ->> 'mesaj', ''));
    if length(v_mesaj) > 300 then
      raise exception 'Mesaj en fazla 300 karakter olabilir' using errcode = '22023';
    end if;
    v_yeni := jsonb_build_object('android', p_value ->> 'android', 'ios', p_value ->> 'ios',
                                 'web', p_value ->> 'web', 'mesaj', v_mesaj);

  elsif p_key = 'desteklenen_siniflar' then
    if jsonb_typeof(p_value) is distinct from 'object'
       or jsonb_typeof(p_value -> 'siniflar') is distinct from 'array'
       or jsonb_array_length(p_value -> 'siniflar') not between 1 and 12
       or exists (select 1 from jsonb_array_elements(p_value -> 'siniflar') e
                   where jsonb_typeof(e) is distinct from 'number'
                      or (e #>> '{}') !~ '^([1-9]|1[0-2])$') then
      raise exception 'desteklenen_siniflar: {"siniflar": [3, 4]} (1-12 arası tam sayılar) olmalı'
        using errcode = '22023';
    end if;
    select array_agg(distinct (e #>> '{}')::integer order by (e #>> '{}')::integer)
      into v_liste from jsonb_array_elements(p_value -> 'siniflar') e;
    v_yeni := jsonb_build_object('siniflar', to_jsonb(v_liste));

  elsif p_key = 'reklamlar' then
    if jsonb_typeof(p_value) is distinct from 'object' then
      raise exception 'reklamlar bir nesne olmalı' using errcode = '22023';
    end if;
    for v_p in select jsonb_object_keys(p_value) loop
      if v_p not in ('veli_paneli_acik', 'ogrenci_acik', 'admob_app_id_android', 'admob_app_id_ios',
                     'admob_banner_id_android', 'admob_banner_id_ios', 'adsense_publisher_id',
                     'adsense_slot_id') then
        raise exception 'reklamlar: bilinmeyen alan %', v_p using errcode = '22023';
      end if;
    end loop;
    foreach v_p in array array['veli_paneli_acik', 'ogrenci_acik'] loop
      if jsonb_typeof(p_value -> v_p) is distinct from 'boolean' then
        raise exception 'reklamlar: % boolean olmalı', v_p using errcode = '22023';
      end if;
    end loop;
    foreach v_p in array array['admob_app_id_android', 'admob_app_id_ios', 'admob_banner_id_android',
                                'admob_banner_id_ios', 'adsense_publisher_id', 'adsense_slot_id'] loop
      if not (p_value -> v_p is null or jsonb_typeof(p_value -> v_p) = 'null'
              or jsonb_typeof(p_value -> v_p) = 'string') then
        raise exception 'reklamlar: % metin veya null olmalı', v_p using errcode = '22023';
      end if;
      if jsonb_typeof(p_value -> v_p) = 'string' and trim(p_value ->> v_p) = '' then
        raise exception 'reklamlar: % boş olamaz (boş bırakmak için null kullanın)', v_p
          using errcode = '22023';
      end if;
    end loop;
    v_yeni := jsonb_build_object(
      'veli_paneli_acik', p_value -> 'veli_paneli_acik',
      'ogrenci_acik', p_value -> 'ogrenci_acik',
      'admob_app_id_android', case when p_value -> 'admob_app_id_android' is null
        or jsonb_typeof(p_value -> 'admob_app_id_android') = 'null' then null
        else trim(p_value ->> 'admob_app_id_android') end,
      'admob_app_id_ios', case when p_value -> 'admob_app_id_ios' is null
        or jsonb_typeof(p_value -> 'admob_app_id_ios') = 'null' then null
        else trim(p_value ->> 'admob_app_id_ios') end,
      'admob_banner_id_android', case when p_value -> 'admob_banner_id_android' is null
        or jsonb_typeof(p_value -> 'admob_banner_id_android') = 'null' then null
        else trim(p_value ->> 'admob_banner_id_android') end,
      'admob_banner_id_ios', case when p_value -> 'admob_banner_id_ios' is null
        or jsonb_typeof(p_value -> 'admob_banner_id_ios') = 'null' then null
        else trim(p_value ->> 'admob_banner_id_ios') end,
      'adsense_publisher_id', case when p_value -> 'adsense_publisher_id' is null
        or jsonb_typeof(p_value -> 'adsense_publisher_id') = 'null' then null
        else trim(p_value ->> 'adsense_publisher_id') end,
      'adsense_slot_id', case when p_value -> 'adsense_slot_id' is null
        or jsonb_typeof(p_value -> 'adsense_slot_id') = 'null' then null
        else trim(p_value ->> 'adsense_slot_id') end);

  elsif p_key = 'deneme_sinavi_tarihi' then
    if jsonb_typeof(p_value) is distinct from 'string' then
      raise exception 'deneme_sinavi_tarihi: ISO 8601 tarih metni olmalı' using errcode = '22023';
    end if;
    begin
      v_tarih := (p_value #>> '{}')::timestamptz;
    exception when others then
      raise exception 'deneme_sinavi_tarihi: geçerli bir tarih değil' using errcode = '22023';
    end;
    v_yeni := to_jsonb(to_char(v_tarih at time zone 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"'));

  else
    raise exception 'Bilinmeyen ayar anahtarı' using errcode = '22023';
  end if;

  insert into public.app_settings (key, value) values (p_key, v_yeni)
  on conflict (key) do update set value = excluded.value, updated_at = now();

  perform public.log_admin_action('ayar_degisti', jsonb_build_object('key', p_key, 'value', v_yeni));
end;
$function$;

comment on function public.admin_set_setting(text, jsonb) is
  'Yönetici ayarı yazar: premium_gating, deneme, bakim_modu, min_surum, desteklenen_siniflar, reklamlar, deneme_sinavi_tarihi.';

revoke execute on function public.admin_set_setting(text, jsonb) from public, anon;
grant  execute on function public.admin_set_setting(text, jsonb) to authenticated;

create or replace function public.admin_get_settings()
returns jsonb
language plpgsql
stable security definer
set search_path to ''
as $function$
begin
  perform public.require_admin();
  return coalesce((select jsonb_object_agg(key, value) from public.app_settings
                    where key in ('premium_gating', 'deneme', 'bakim_modu', 'min_surum', 'desteklenen_siniflar',
                                  'reklamlar', 'deneme_sinavi_tarihi')), '{}'::jsonb);
end;
$function$;

comment on function public.admin_get_settings() is
  'Yönetici ayar ekranı için 7 ayar anahtarını tek nesnede döndürür.';

revoke execute on function public.admin_get_settings() from public, anon;
grant  execute on function public.admin_get_settings() to authenticated;

-- ---------------------------------------------------------------------
-- 6. Admin: deneme yönetimi
-- ---------------------------------------------------------------------
-- Veli arama (ad, kullanıcı adı veya e-posta). En fazla 25 sonuç.
create or replace function public.admin_deneme_veli_ara(p_arama text default '')
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_arama text := btrim(coalesce(p_arama, ''));
  v_desen text := '%' || v_arama || '%';
  v_sonuc jsonb;
begin
  perform public.require_admin();

  select coalesce(jsonb_agg(to_jsonb(x) order by x.ad), '[]'::jsonb) into v_sonuc
    from (
      select p.id, coalesce(p.full_name, '') as ad, p.username, u.email,
             exists (select 1 from public.deneme_donemleri d
                      where d.veli_id = p.id and d.bitis > now()) as deneme_aktif
        from public.profiles p
        left join auth.users u on u.id = p.id
       where p.role = 'veli'
         and (v_arama = '' or p.full_name ilike v_desen or p.username ilike v_desen or u.email ilike v_desen)
       order by p.full_name nulls last
       limit 25
    ) x;
  return v_sonuc;
end;
$$;

-- Veliye deneme başlat. p_gun boşsa ayardaki gün kullanılır.
create or replace function public.admin_deneme_baslat(p_veli_id uuid, p_gun integer default null)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_gun   integer;
  v_bitis timestamptz;
begin
  perform public.require_admin();

  if not exists (select 1 from public.profiles where id = p_veli_id and role = 'veli') then
    raise exception 'Deneme yalnızca veli hesabına açılabilir' using errcode = '22023';
  end if;
  if p_gun is not null and p_gun not between 1 and 90 then
    raise exception 'Deneme günü 1-90 arasında olmalı' using errcode = '22023';
  end if;
  if public._deneme_aktif(p_veli_id) then
    raise exception 'Bu velinin zaten aktif bir denemesi var' using errcode = '22023';
  end if;

  v_gun   := coalesce(p_gun, (select a.gun from public._deneme_ayar() a));
  v_bitis := now() + make_interval(days => v_gun);

  insert into public.deneme_donemleri (veli_id, bitis, olusturan)
  values (p_veli_id, v_bitis, (select auth.uid()));

  perform public.log_admin_action('deneme_baslatildi',
    jsonb_build_object('veli_id', p_veli_id, 'gun', v_gun, 'bitis', v_bitis));

  return jsonb_build_object('veli_id', p_veli_id, 'gun', v_gun, 'bitis', v_bitis);
end;
$$;

-- Aktif denemeyi hemen bitirir. Dönüş: bitirilen kayıt sayısı.
create or replace function public.admin_deneme_bitir(p_veli_id uuid)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_adet integer;
begin
  perform public.require_admin();

  update public.deneme_donemleri
     set bitis = now()
   where veli_id = p_veli_id
     and bitis > now();
  get diagnostics v_adet = row_count;

  if v_adet > 0 then
    perform public.log_admin_action('deneme_bitirildi', jsonb_build_object('veli_id', p_veli_id));
  end if;
  return v_adet;
end;
$$;

-- Aktif denemeler (bitiş tarihine göre)
create or replace function public.admin_deneme_listele()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.require_admin();

  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.bitis)
      from (
        select d.veli_id, coalesce(p.full_name, '') as ad, p.username, u.email,
               d.baslangic, d.bitis,
               greatest(ceil(extract(epoch from (d.bitis - now())) / 86400.0)::integer, 0) as kalan_gun
          from public.deneme_donemleri d
          join public.profiles p on p.id = d.veli_id
          left join auth.users u on u.id = d.veli_id
         where d.bitis > now()
      ) x
  ), '[]'::jsonb);
end;
$$;

revoke execute on function public.admin_deneme_veli_ara(text), public.admin_deneme_baslat(uuid, integer),
  public.admin_deneme_bitir(uuid), public.admin_deneme_listele()
  from public, anon;
grant  execute on function public.admin_deneme_veli_ara(text), public.admin_deneme_baslat(uuid, integer),
  public.admin_deneme_bitir(uuid), public.admin_deneme_listele()
  to authenticated;
