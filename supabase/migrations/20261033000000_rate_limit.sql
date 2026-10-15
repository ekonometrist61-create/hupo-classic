-- =====================================================================
-- IP BAŞINA HIZ SINIRI (TASKS.md §16.2)
--
-- Anonim uç noktaları (veli adayı, deneme ön kaydı) botlara karşı korur.
-- Sayaç tablosu yalnızca servis rolünün (Edge Function) erişebildiği
-- bir tabloda tutulur; istemci doğrudan okuyamaz veya yazamaz.
--
-- Kullanım (Edge Function, service_role):
--   select public.rate_limit_kontrol('veli_adayi', '203.0.113.7', 5, 600);
--   → true: izin verildi (sayaç artar), false: sınır aşıldı.
--
-- Sınırlar: aynı anda gelen istekler kısa bir yarış penceresi açabilir
-- (tam atomik değil). Bu bir kötüye kullanım frenidir; kesin kota değildir.
-- =====================================================================

create table if not exists public.rate_limit_hits (
  id      bigint generated always as identity primary key,
  bucket  text        not null,
  anahtar text        not null,
  zaman   timestamptz not null default now()
);

create index if not exists rate_limit_hits_bucket_anahtar_zaman_idx
  on public.rate_limit_hits (bucket, anahtar, zaman desc);

alter table public.rate_limit_hits enable row level security;
revoke all on public.rate_limit_hits from public, anon, authenticated;

create or replace function public.rate_limit_kontrol(
  p_bucket      text,
  p_anahtar     text,
  p_limit       integer,
  p_pencere_sn  integer
)
returns boolean
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_anahtar text := coalesce(nullif(btrim(p_anahtar), ''), 'bilinmiyor');
  v_say     integer;
begin
  if p_bucket is null or p_limit is null or p_limit < 1
     or p_pencere_sn is null or p_pencere_sn < 1 then
    raise exception 'rate_limit_kontrol: geçersiz parametre' using errcode = '22023';
  end if;

  select count(*) into v_say
    from public.rate_limit_hits h
   where h.bucket = p_bucket
     and h.anahtar = v_anahtar
     and h.zaman > now() - make_interval(secs => p_pencere_sn);

  if v_say >= p_limit then
    return false;
  end if;

  insert into public.rate_limit_hits (bucket, anahtar) values (p_bucket, v_anahtar);

  -- Eski kayıtları ara sıra temizle (her çağrıda değil; düşük trafikte sorun değil).
  if random() < 0.01 then
    delete from public.rate_limit_hits where zaman < now() - interval '2 days';
  end if;

  return true;
end;
$function$;

comment on function public.rate_limit_kontrol(text, text, integer, integer) is
  'Anahtar (ör. IP) başına pencere içinde en fazla p_limit istek. Yalnızca service_role.';

revoke execute on function public.rate_limit_kontrol(text, text, integer, integer) from public, anon, authenticated;
grant  execute on function public.rate_limit_kontrol(text, text, integer, integer) to service_role;
