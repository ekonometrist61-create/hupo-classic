-- =====================================================================
--  Anket D1: şema ve arşiv güvencesi
--  Proje : Hupo / Yönetim Merkezi
--  Tarih : 2026-11-08
--  Ön koşul: 20261007000030, 20261026000000, 20261029000000, 20261030000000,
--            20261032000000 (anketler.arsivlendi_at), 20261039000000
--  Kaynak: PROJE_GUNLUGU.md §24 D1 (kullanıcı dilim onayı, 2026-11-08)
--
--  NE DEĞİŞİYOR?
--    * anket_surumleri         : yayımlanan her sürümün değişmez anlık görüntüsü
--    * anketler kod kilidi     : yayımlanmış bir sorunun kimliği, türü ve seçenek kodları
--                                kaldırılamaz ya da değiştirilemez (metin düzeltilebilir)
--    * tek yayında anket       : aynı anda en fazla bir anket yayında (kısıt + trigger)
--    * yayın anında arşiv      : yeni anket yayına alınınca önceki yayındaki anket kapanır
--                                ve arşivlenir (arsivlendi_at)
--    * anket_yanitlari.anket_id: on delete cascade -> restrict (yanıtlar anketle birlikte silinemez)
--    * anket_gosterimleri      : gösterim ve atlama kaydı (D2 tüketir; şimdi boş)
--    * etkilesim_butcesi       : veli başına günlük temas bütçesi, push ve anket ortak (D2 tüketir)
--    * anket_taslaklari        : yönetim taslakları (D4 kullanır; şimdi boş)
--
--  KURALLAR
--    * Yeni tablolar RLS açık ve politikasızdır; yalnızca SECURITY DEFINER fonksiyonlar
--      (trigger'lar ve ileride D2/D4 RPC'leri) erişir. anon/authenticated doğrudan erişemez.
--    * Trigger fonksiyonları SECURITY DEFINER ve search_path = '' ile çalışır; çağıran
--      kullanıcının RLS'i sürüm tablosunu görmesini gerektirmez.
--    * Veri kaybı yoktur: mevcut anketler silinmez, yanıtlar taşınmaz. Yalnızca
--      yayındaki/kapalı anketler için geriye dönük sürüm anlık görüntüsü alınır.
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 0. Ön kontrol: birden fazla yayında anket varsa tek-yayın kısıtı kurulamaz
-- ---------------------------------------------------------------------
do $$
begin
  if (select count(*) from public.anketler where durum = 'yayinda') > 1 then
    raise exception 'Birden fazla yayında anket var; tek yayında kısıtı kurulamaz. Önce birini kapatın.'
      using errcode = '23514';
  end if;
end;
$$;

-- ---------------------------------------------------------------------
-- 1. Sürüm anlık görüntüleri (değişmez)
-- ---------------------------------------------------------------------
create table if not exists public.anket_surumleri (
  id                  uuid primary key default gen_random_uuid(),
  anket_id            uuid not null references public.anketler (id) on delete restrict,
  surum               integer not null check (surum >= 1),
  ad                  text not null,
  anonim              boolean not null,
  sorular             jsonb not null,
  tekrar_gosterim_gun integer not null,
  yuzeyler            text[] not null,
  yayinlandi_at       timestamptz not null default now(),
  yayinlayan_id       uuid references public.profiles (id) on delete set null,
  constraint anket_surumleri_tekil unique (anket_id, surum)
);

create or replace function public._anket_surum_degismez()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
begin
  raise exception 'Yayımlanmış anket sürümü değiştirilemez ya da silinemez.' using errcode = '23514';
end;
$function$;

drop trigger if exists anket_surumleri_degismez on public.anket_surumleri;
create trigger anket_surumleri_degismez
  before update or delete on public.anket_surumleri
  for each row execute function public._anket_surum_degismez();

-- ---------------------------------------------------------------------
-- 2. Yayın anı: tek yayında kuralı ve önceki anketin otomatik arşivi (BEFORE)
--    BEFORE olmalı: unique indeks yeni satır yazılırken eski satırın kapanmış olmasını ister.
-- ---------------------------------------------------------------------
create or replace function public._anketler_yayin_oncesi()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
begin
  if new.durum = 'yayinda' and (tg_op = 'INSERT' or old.durum is distinct from 'yayinda') then
    update public.anketler
       set durum = 'kapali',
           arsivlendi_at = coalesce(arsivlendi_at, now()),
           updated_at = now()
     where durum = 'yayinda'
       and id is distinct from new.id;
  end if;
  return new;
end;
$function$;

drop trigger if exists anketler_yayin_oncesi on public.anketler;
create trigger anketler_yayin_oncesi
  before insert or update of durum on public.anketler
  for each row execute function public._anketler_yayin_oncesi();

-- Tek yayında: en fazla bir satır durum = 'yayinda'
create unique index if not exists anketler_tek_yayin
  on public.anketler (durum)
  where durum = 'yayinda';

-- ---------------------------------------------------------------------
-- 3. Sürüm kaydı: yayın anında ve yayındaki sorular değişip sürüm arttığında (AFTER)
-- ---------------------------------------------------------------------
create or replace function public._anketler_surum_kaydi()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
begin
  if (new.durum = 'yayinda' and (tg_op = 'INSERT' or old.durum is distinct from 'yayinda'))
     or (tg_op = 'UPDATE' and new.surum is distinct from old.surum) then
    insert into public.anket_surumleri
      (anket_id, surum, ad, anonim, sorular, tekrar_gosterim_gun, yuzeyler, yayinlayan_id)
    values
      (new.id, new.surum, new.ad, new.anonim, new.sorular, new.tekrar_gosterim_gun, new.yuzeyler, (select auth.uid()))
    on conflict (anket_id, surum) do nothing;
  end if;
  return null;
end;
$function$;

drop trigger if exists anketler_surum_kaydi on public.anketler;
create trigger anketler_surum_kaydi
  after insert or update on public.anketler
  for each row execute function public._anketler_surum_kaydi();

-- ---------------------------------------------------------------------
-- 4. Kod kilidi: bir sürüm kaydedilmişse soru kimliği, türü ve seçenek kodları korunur
-- ---------------------------------------------------------------------
create or replace function public._anketler_kod_kilidi()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_eski  jsonb;
  v_yeni  jsonb;
begin
  if not exists (select 1 from public.anket_surumleri where anket_id = old.id) then
    return new;
  end if;

  for v_eski in select e.value from jsonb_array_elements(old.sorular) as e(value) loop
    select e.value into v_yeni
      from jsonb_array_elements(new.sorular) as e(value)
     where e.value ->> 'id' = v_eski ->> 'id'
     limit 1;

    if v_yeni is null then
      raise exception 'Yayımlanmış soru kaldırılamaz: %', v_eski ->> 'id' using errcode = '23514';
    end if;
    if (v_yeni ->> 'tur') is distinct from (v_eski ->> 'tur') then
      raise exception 'Yayımlanmış sorunun türü değiştirilemez: %', v_eski ->> 'id' using errcode = '23514';
    end if;
    if not (coalesce(v_eski -> 'secenekler', '[]'::jsonb) <@ coalesce(v_yeni -> 'secenekler', '[]'::jsonb)) then
      raise exception 'Yayımlanmış sorunun seçenek kodu kaldırılamaz veya değiştirilemez: %', v_eski ->> 'id'
        using errcode = '23514';
    end if;
  end loop;
  return new;
end;
$function$;

drop trigger if exists anketler_kod_kilidi on public.anketler;
create trigger anketler_kod_kilidi
  before update of sorular on public.anketler
  for each row
  when (old.sorular is distinct from new.sorular)
  execute function public._anketler_kod_kilidi();

-- ---------------------------------------------------------------------
-- 5. Geriye dönük sürüm anlık görüntüleri (yalnız yayında ya da kapalı anketler)
-- ---------------------------------------------------------------------
insert into public.anket_surumleri
  (anket_id, surum, ad, anonim, sorular, tekrar_gosterim_gun, yuzeyler, yayinlayan_id)
select a.id, a.surum, a.ad, a.anonim, a.sorular, a.tekrar_gosterim_gun, a.yuzeyler, null
  from public.anketler a
 where a.durum in ('yayinda', 'kapali')
on conflict (anket_id, surum) do nothing;

-- ---------------------------------------------------------------------
-- 6. Arşiv güvencesi: yanıtlı anket silinemez
-- ---------------------------------------------------------------------
alter table public.anket_yanitlari drop constraint if exists anket_yanitlari_anket_id_fkey;
alter table public.anket_yanitlari
  add constraint anket_yanitlari_anket_id_fkey
  foreign key (anket_id) references public.anketler (id) on delete restrict;

-- ---------------------------------------------------------------------
-- 7. Yeni tablolar (D2 ve D4 tüketir)
-- ---------------------------------------------------------------------
create table if not exists public.anket_gosterimleri (
  id          uuid primary key default gen_random_uuid(),
  anket_id    uuid not null references public.anketler (id) on delete restrict,
  veli_id     uuid not null references public.profiles (id) on delete cascade,
  yuzey       text not null check (yuzey in ('mobil', 'web_app', 'veli_paneli')),
  olay        text not null check (olay in ('gosterildi', 'atlandi', 'tamamlandi')),
  created_at  timestamptz not null default now()
);
create index if not exists anket_gosterimleri_veli_idx
  on public.anket_gosterimleri (veli_id, anket_id, created_at desc);

create table if not exists public.etkilesim_butcesi (
  veli_id uuid not null references public.profiles (id) on delete cascade,
  gun     date not null,
  kanal   text not null check (kanal in ('push', 'anket', 'eposta')),
  sayi    integer not null default 0 check (sayi >= 0),
  primary key (veli_id, gun, kanal)
);

create table if not exists public.anket_taslaklari (
  id                  uuid primary key default gen_random_uuid(),
  kaynak_anket_id     uuid references public.anketler (id) on delete set null,
  ad                  text not null default '',
  anonim              boolean not null default false,
  sorular             jsonb not null default '[]'::jsonb,
  tekrar_gosterim_gun integer not null default 30,
  yuzeyler            text[] not null default array['veli_paneli']::text[],
  olusturan_id        uuid references public.profiles (id) on delete set null,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  constraint anket_taslaklari_yuzeyler check (
    cardinality(yuzeyler) between 1 and 3
    and yuzeyler <@ array['mobil', 'web_app', 'veli_paneli']::text[]
  )
);

alter table public.anket_surumleri   enable row level security;
alter table public.anket_gosterimleri enable row level security;
alter table public.etkilesim_butcesi enable row level security;
alter table public.anket_taslaklari  enable row level security;

revoke all on public.anket_surumleri, public.anket_gosterimleri,
              public.etkilesim_butcesi, public.anket_taslaklari
  from public, anon, authenticated;

revoke execute on function public._anket_surum_degismez()  from public, anon, authenticated;
revoke execute on function public._anketler_yayin_oncesi() from public, anon, authenticated;
revoke execute on function public._anketler_surum_kaydi()  from public, anon, authenticated;
revoke execute on function public._anketler_kod_kilidi()    from public, anon, authenticated;
