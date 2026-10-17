-- =====================================================================
-- Veli telefon doğrulaması (SMS ile sahiplik kanıtı)
--
-- Karar (TASKS.md §22): telefon doğrulaması zorunlu; tekillik veli hesabı
-- başına (aynı doğrulanmış numara iki veli hesabında olamaz); kanal SMS.
--
-- Akış:
--   1. Veli telefonu girer → Edge Function `telefon-kod-gonder` JWT'yi doğrular,
--      `telefon_kod_uret` (service_role) ile kod üretir, SMS'i gönderir.
--   2. Veli kodu girer → `telefon_kod_dogrula` (authenticated RPC) kodu kontrol
--      eder; doğruysa profiles.telefon + telefon_dogrulandi_at yazılır.
--
-- Supabase Auth'un phone_change akışı KULLANILMIYOR: o akışta bekleyen numara
-- benzersiz değil ve yanlış hesaba bağlanabiliyor (Supabase troubleshooting).
-- Bu yüzden OTP ve tekillik tamamen bu migration'da yönetiliyor.
-- =====================================================================

-- 1) Normalizasyon: girilen numarayı +905XXXXXXXXX biçimine çevirir.
--    Kabul edilenler: 5XXXXXXXXX, 05XXXXXXXXX, 905XXXXXXXXX, +905XXXXXXXXX
--    (boşluk, tire, parantez temizlenir). Geçersizse NULL.
create or replace function public.telefon_normalize(p_ham text)
returns text
language plpgsql
immutable
set search_path = public, pg_temp
as $$
declare
  v_rakam text := regexp_replace(coalesce(p_ham, ''), '[^0-9]', '', 'g');
begin
  if length(v_rakam) = 10 and left(v_rakam, 1) = '5' then
    return '+90' || v_rakam;
  elsif length(v_rakam) = 11 and left(v_rakam, 2) = '05' then
    return '+90' || substr(v_rakam, 2);
  elsif length(v_rakam) = 12 and left(v_rakam, 3) = '905' then
    return '+' || v_rakam;
  end if;
  return null;
end;
$$;

revoke execute on function public.telefon_normalize(text) from public;
grant  execute on function public.telefon_normalize(text) to anon, authenticated, service_role;

-- 2) Veli profiline doğrulama zamanı + doğrulanmış numara biçim kuralı.
alter table public.profiles
  add column if not exists telefon_dogrulandi_at timestamptz;

alter table public.profiles
  drop constraint if exists profiles_telefon_dogrulanmis_bicim;
alter table public.profiles
  add constraint profiles_telefon_dogrulanmis_bicim
  check (telefon_dogrulandi_at is null or telefon ~ '^\+905[0-9]{9}$');

-- Tekillik: doğrulanmış bir veli numarası yalnızca bir veli hesabında bulunabilir.
create unique index if not exists profiles_veli_telefon_dogrulanmis_tekil
  on public.profiles (telefon)
  where role = 'veli' and telefon_dogrulandi_at is not null;

-- 3) OTP tablosu: kodlar yalnızca hash+salt olarak tutulur; istemci erişemez.
create table if not exists public.telefon_dogrulama_kodlari (
  id            bigint generated always as identity primary key,
  user_id       uuid not null references auth.users (id) on delete cascade,
  telefon       text not null,
  kod_salt      text not null,
  kod_hash      text not null,
  deneme_sayisi integer not null default 0,
  son_kullanma  timestamptz not null,
  olusturma     timestamptz not null default now()
);

create index if not exists telefon_dogrulama_kodlari_kullanici
  on public.telefon_dogrulama_kodlari (user_id, olusturma desc);

alter table public.telefon_dogrulama_kodlari enable row level security;
-- Politika yok: yalnızca security definer fonksiyonlar ve service_role erişir.
revoke all on table public.telefon_dogrulama_kodlari from public, anon, authenticated;

-- 4) Kod üretimi (yalnızca service_role; Edge Function çağırır).
--    Doğrulama: aynı kullanıcı için 10 dakikada en fazla 3 kod; numara başka bir
--    doğrulanmış veli hesabında ise reddedilir. Kod düz metin olarak döner ve
--    yalnızca SMS göndermek için Edge Function'a verilir; veritabanında hash tutulur.
create or replace function public.telefon_kod_uret(p_user_id uuid, p_ham_telefon text)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
declare
  v_tel     text := public.telefon_normalize(p_ham_telefon);
  v_rol     text;
  v_salt    text;
  v_kod     text;
  v_son_10  integer;
begin
  if v_tel is null then
    raise exception 'Geçerli bir Türk cep numarası girin' using errcode = '22023';
  end if;

  select role into v_rol from public.profiles where id = p_user_id;
  if v_rol is distinct from 'veli' then
    raise exception 'Telefon doğrulaması yalnızca veli hesapları için' using errcode = '42501';
  end if;

  if exists (
    select 1 from public.profiles
    where telefon = v_tel and role = 'veli'
      and telefon_dogrulandi_at is not null and id <> p_user_id
  ) then
    raise exception 'Bu numara başka bir hesapta kayıtlı' using errcode = '23505';
  end if;

  select count(*) into v_son_10
  from public.telefon_dogrulama_kodlari
  where user_id = p_user_id and olusturma > now() - interval '10 minutes';
  if v_son_10 >= 3 then
    raise exception 'Çok fazla kod istendi; 10 dakika sonra tekrar deneyin' using errcode = 'P0001';
  end if;

  -- Eski kodlar silinmez: hız sınırı son 10 dakikadaki kayıtları sayar. Yalnızca
  -- en son kod doğrulanabilir (telefon_kod_dogrula en yeni kaydı okur).
  delete from public.telefon_dogrulama_kodlari
  where user_id = p_user_id and olusturma < now() - interval '1 day';

  -- 6 haneli kod: 0..999999 aralığında kriptografik rastgele sayı.
  v_kod  := lpad((('x' || encode(extensions.gen_random_bytes(4), 'hex'))::bit(32)::bigint % 1000000)::text, 6, '0');
  v_salt := encode(extensions.gen_random_bytes(16), 'hex');

  insert into public.telefon_dogrulama_kodlari (user_id, telefon, kod_salt, kod_hash, son_kullanma)
  values (
    p_user_id, v_tel, v_salt,
    encode(extensions.digest(v_salt || ':' || v_kod, 'sha256'), 'hex'),
    now() + interval '5 minutes'
  );

  return jsonb_build_object('telefon', v_tel, 'kod', v_kod);
end;
$$;

revoke execute on function public.telefon_kod_uret(uuid, text) from public, anon, authenticated;
grant  execute on function public.telefon_kod_uret(uuid, text) to service_role;

-- 5) Kod doğrulama (giriş yapmış veli). En fazla 5 yanlış deneme; süre 5 dakika.
--    Yanlış kod HATA DEĞİL, {durum:'hatali'} döner: hata fırlatılsaydı deneme
--    sayacı yazımı geri alınır ve sınırsız deneme mümkün olurdu.
--    Dönüş: {durum:'ok', telefon} | {durum:'hatali', kalan_deneme}
drop function if exists public.telefon_kod_dogrula(text);
create or replace function public.telefon_kod_dogrula(p_kod text)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
declare
  v_uid   uuid := auth.uid();
  v_kayit public.telefon_dogrulama_kodlari%rowtype;
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı' using errcode = '42501';
  end if;

  select * into v_kayit
  from public.telefon_dogrulama_kodlari
  where user_id = v_uid
  order by olusturma desc
  limit 1
  for update;

  if not found or v_kayit.son_kullanma < now() then
    raise exception 'Kodun süresi doldu; yeni kod isteyin' using errcode = 'P0001';
  end if;

  if v_kayit.deneme_sayisi >= 5 then
    raise exception 'Çok fazla yanlış deneme; yeni kod isteyin' using errcode = 'P0001';
  end if;

  if encode(extensions.digest(v_kayit.kod_salt || ':' || coalesce(p_kod, ''), 'sha256'), 'hex')
     <> v_kayit.kod_hash then
    update public.telefon_dogrulama_kodlari
       set deneme_sayisi = deneme_sayisi + 1
     where id = v_kayit.id;
    return jsonb_build_object('durum', 'hatali', 'kalan_deneme', 4 - v_kayit.deneme_sayisi);
  end if;

  begin
    update public.profiles
       set telefon = v_kayit.telefon,
           telefon_dogrulandi_at = now()
     where id = v_uid and role = 'veli';
  exception when unique_violation then
    raise exception 'Bu numara başka bir hesapta kayıtlı' using errcode = '23505';
  end;

  delete from public.telefon_dogrulama_kodlari where user_id = v_uid;
  return jsonb_build_object('durum', 'ok', 'telefon', v_kayit.telefon);
end;
$$;

revoke execute on function public.telefon_kod_dogrula(text) from public, anon, service_role;
grant  execute on function public.telefon_kod_dogrula(text) to authenticated;
