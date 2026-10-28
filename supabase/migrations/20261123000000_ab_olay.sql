set client_encoding = 'UTF8';

-- =====================================================================
--  A/B olay kaydı, I1 (H-GIE Faz 6). Spec: specs/AB_OLAY_INGEST_SPEC.md (D1–D4 onaylı)
--  Ön koşul: 20261121000000_ab_deney.sql (ab_deney, ab_kol, require_admin)
--
--  TASARIM
--    * Kullanıcı başına bir kez sayım: ab_tekillik. Kayıt, deney + metrik + kullanıcı kimliğinin
--      SHA-256 özeti. Kimlik saklanmaz; kayıt 7 gün sonra silinir (ab_tekillik_temizle).
--    * Toplulaştırılmış günlük sayılar: ab_olay_gunluk (deney, kol, metrik, gün, sayı).
--      Kullanıcı kimliği yoktur. Bitişten 400 gün sonra silinir (ab_gunluk_temizle).
--    * Kol sunucuda ab_kol ile belirlenir; istemci kol gönderemez.
--    * Dönüşüm yalnız maruziyetten sonra sayılır (ab_donusum_kaydet, önce ab_maruziyet_kaydet).
--    * Yalnız deney yayındayken ve tarih aralığında kayıt alınır.
--    * Yönetici sayıları: kol başına n (maruziyet) < 30 ise o kolun tüm sayıları gizlenir.
--
--  KAPSAM DIŞI: deney kaydı tabloları ve ab_karar (ayrı dosyalar).
-- =====================================================================

create table if not exists public.ab_tekillik (
  deney_id  uuid not null references public.ab_deney (id) on delete cascade,
  metrik    text not null,
  anahtar   text not null check (char_length(anahtar) = 64),
  olusma    timestamptz not null default now(),
  primary key (deney_id, metrik, anahtar)
);

create table if not exists public.ab_olay_gunluk (
  deney_id  uuid not null references public.ab_deney (id) on delete cascade,
  kol       text not null check (kol in ('kontrol', 'deney')),
  metrik    text not null check (char_length(metrik) between 1 and 80),
  gun       date not null,
  sayi      integer not null default 0 check (sayi >= 0),
  primary key (deney_id, kol, metrik, gun)
);

alter table public.ab_tekillik enable row level security;
alter table public.ab_olay_gunluk enable row level security;
revoke all on public.ab_tekillik from public, anon, authenticated;
revoke all on public.ab_olay_gunluk from public, anon, authenticated;

-- Özet: kullanıcı kimliğinin SHA-256 (deney ve metrikle birlikte). Kimlik tabloya yazılmaz.
create or replace function public._ab_anahtar(p_deney uuid, p_metrik text, p_kullanici uuid)
returns text
language sql
immutable
set search_path = ''
as $$
  select encode(sha256(convert_to(p_deney::text || ':' || p_metrik || ':' || p_kullanici::text, 'UTF8')), 'hex')
$$;

-- Deney aktif mi ve kullanıcı hangi kolda? Değilse null.
create or replace function public._ab_olay_kol(p_deney uuid)
returns text
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_kol text := public.ab_kol(p_deney);
begin
  if v_kol is null then
    raise exception 'Deney aktif değil ya da kullanıcı atanmadı' using errcode = '22023';
  end if;
  return v_kol;
end;
$function$;

create or replace function public._ab_gunluk_artir(p_deney uuid, p_kol text, p_metrik text)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.ab_olay_gunluk (deney_id, kol, metrik, gun, sayi)
  values (p_deney, p_kol, p_metrik, (now() at time zone 'Europe/Istanbul')::date, 1)
  on conflict (deney_id, kol, metrik, gun) do update set sayi = public.ab_olay_gunluk.sayi + 1
$$;

-- Maruziyet: kullanıcı deneye girdi (kol döner). Kullanıcı başına bir kez sayılır.
create or replace function public.ab_maruziyet_kaydet(p_deney uuid)
returns text
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_kol text := public._ab_olay_kol(p_deney);
  v_an  text;
  v_ok  int;
begin
  v_an := public._ab_anahtar(p_deney, 'maruziyet', auth.uid());
  insert into public.ab_tekillik (deney_id, metrik, anahtar)
  values (p_deney, 'maruziyet', v_an)
  on conflict do nothing;
  get diagnostics v_ok = row_count;
  if v_ok = 1 then
    perform public._ab_gunluk_artir(p_deney, v_kol, 'maruziyet');
  end if;
  return v_kol;
end;
$function$;

-- Dönüşüm: birincil veya guardrail metriği. Kullanıcı başına bir kez; önce maruziyet gerekir.
create or replace function public.ab_donusum_kaydet(p_deney uuid, p_metrik text)
returns boolean
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_kol  text := public._ab_olay_kol(p_deney);
  v_def  text[];
  v_bir  text;
  v_maruz text;
  v_ok   int;
begin
  if p_metrik = 'maruziyet' then
    raise exception 'Geçersiz metrik' using errcode = '22023';
  end if;
  select array[d.birincil_metrik] || d.guardrail, d.birincil_metrik into v_def, v_bir
    from public.ab_deney d where d.id = p_deney;
  if not (p_metrik = any (v_def)) then
    raise exception 'Metrik bu deneyde tanımlı değil' using errcode = '22023';
  end if;

  v_maruz := public._ab_anahtar(p_deney, 'maruziyet', auth.uid());
  if not exists (select 1 from public.ab_tekillik t
                  where t.deney_id = p_deney and t.metrik = 'maruziyet' and t.anahtar = v_maruz) then
    raise exception 'Önce maruziyet kaydı gerekir' using errcode = '22023';
  end if;

  insert into public.ab_tekillik (deney_id, metrik, anahtar)
  values (p_deney, p_metrik, public._ab_anahtar(p_deney, p_metrik, auth.uid()))
  on conflict do nothing;
  get diagnostics v_ok = row_count;
  if v_ok = 1 then
    perform public._ab_gunluk_artir(p_deney, v_kol, p_metrik);
    return true;
  end if;
  return false;
end;
$function$;

-- Yönetici: kol başına toplu sayılar (n < 30 ise o kolun sayıları null)
create or replace function public.admin_ab_sayilar(p_deney uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_esik int := 30;
  v_sonuc jsonb := '{}'::jsonb;
  v_kol   text;
  v_n     bigint;
  v_met   jsonb;
begin
  perform public.require_admin();
  foreach v_kol in array array['kontrol', 'deney'] loop
    select coalesce(sum(g.sayi), 0) into v_n
      from public.ab_olay_gunluk g
     where g.deney_id = p_deney and g.kol = v_kol and g.metrik = 'maruziyet';

    select coalesce(jsonb_object_agg(x.metrik, x.toplam), '{}'::jsonb) into v_met
      from (select g.metrik, sum(g.sayi)::int as toplam
              from public.ab_olay_gunluk g
             where g.deney_id = p_deney and g.kol = v_kol and g.metrik <> 'maruziyet'
             group by g.metrik) x;

    v_sonuc := v_sonuc || jsonb_build_object(v_kol, jsonb_build_object(
      'maruziyet', case when v_n >= v_esik then v_n else null end,
      'metrikler', case when v_n >= v_esik then v_met else null end));
  end loop;
  return jsonb_build_object('esik', v_esik, 'kollar', v_sonuc);
end;
$function$;

-- Temizlik: 7 günlük tekillik, 400 günlük (bitişten sonra) toplulaştırılmış sayılar
create or replace function public.ab_tekillik_temizle()
returns int
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_n int;
begin
  delete from public.ab_tekillik where olusma < now() - interval '7 days';
  get diagnostics v_n = row_count;
  return v_n;
end;
$function$;

create or replace function public.ab_gunluk_temizle()
returns int
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_n int;
begin
  delete from public.ab_olay_gunluk g
   using public.ab_deney d
   where d.id = g.deney_id and d.bitis + 400 < (now() at time zone 'Europe/Istanbul')::date;
  get diagnostics v_n = row_count;
  return v_n;
end;
$function$;

revoke execute on function public._ab_anahtar(uuid, text, uuid) from public, anon, authenticated;
revoke execute on function public._ab_olay_kol(uuid) from public, anon, authenticated;
revoke execute on function public._ab_gunluk_artir(uuid, text, text) from public, anon, authenticated;
revoke execute on function public.ab_tekillik_temizle() from public, anon, authenticated;
revoke execute on function public.ab_gunluk_temizle() from public, anon, authenticated;
revoke execute on function public.ab_maruziyet_kaydet(uuid) from public, anon;
revoke execute on function public.ab_donusum_kaydet(uuid, text) from public, anon;
revoke execute on function public.admin_ab_sayilar(uuid) from public, anon;
grant  execute on function public.ab_maruziyet_kaydet(uuid) to authenticated, service_role;
grant  execute on function public.ab_donusum_kaydet(uuid, text) to authenticated, service_role;
grant  execute on function public.admin_ab_sayilar(uuid) to authenticated, service_role;

-- Zamanlayıcı: her gece 03:40 (UTC)
do $$
begin
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    begin perform cron.unschedule('ab_tekillik_temizle'); exception when others then null; end;
    begin perform cron.unschedule('ab_gunluk_temizle'); exception when others then null; end;
    perform cron.schedule('ab_tekillik_temizle', '40 3 * * *', 'select public.ab_tekillik_temizle()');
    perform cron.schedule('ab_gunluk_temizle', '42 3 * * *', 'select public.ab_gunluk_temizle()');
  else
    raise notice 'pg_cron yok: temizlik işleri harici zamanlayıcıyla çağrılmalı';
  end if;
end $$;
