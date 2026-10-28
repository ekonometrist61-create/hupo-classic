set client_encoding = 'UTF8';

-- =====================================================================
--  Customer-Lab L2: sentetik koşu ve sonuç tabloları (H-GIE Faz 6)
--  Ön koşul: 20260920000900_admin_role_and_payments.sql (require_admin) — yalnız
--            fonksiyon adı için; bu dosya o tabloya dokunmaz.
--
--  KURALLAR (spec §2, §3, §6)
--    * Sentetik tablolar gerçek veri tablolarına HİÇ referans vermez (FK yok).
--    * Gerçek tablolar bu tablolara yazmaz; bu tablolar da gerçek tablolara yazmaz.
--    * Her sonuç satırı etiket = 'hipotez' taşır (check); başka değer kabul edilmez.
--    * Her sonuç bir aralık taşır: beklenen_alt <= beklenen_ust (check).
--    * Anon ve authenticated tabloya erişemez; yalnız admin fonksiyonları yazar/okur.
--
--  Not: spec "sentetik_ şeması" dedi; burada tablo önekiyle ayrım yapılır (ayrı şema
--  yerine). Yetki ve yazma yolu ayrı tutulduğu için pratik olarak aynı izolasyondur.
-- =====================================================================

create table if not exists public.sentetik_kosu (
  id            uuid primary key default gen_random_uuid(),
  olusturma     timestamptz not null default now(),
  tohum         bigint not null,
  surum         text not null check (char_length(surum) between 1 and 40),
  varsayimlar   jsonb not null,
  persona       jsonb not null,
  notlar        text check (char_length(notlar) <= 500)
);

create table if not exists public.sentetik_sonuc (
  id              uuid primary key default gen_random_uuid(),
  kosu_id         uuid not null references public.sentetik_kosu (id) on delete cascade,
  senaryo         text not null check (char_length(senaryo) between 1 and 80),
  fiyat_kurus     integer not null check (fiyat_kurus > 0),
  beklenen_alt    numeric not null check (beklenen_alt >= 0 and beklenen_alt <= 1),
  beklenen_ust    numeric not null check (beklenen_ust >= 0 and beklenen_ust <= 1),
  etiket          text not null default 'hipotez' check (etiket = 'hipotez'),
  constraint sentetik_aralik check (beklenen_alt <= beklenen_ust)
);

create index if not exists sentetik_sonuc_kosu_idx on public.sentetik_sonuc (kosu_id);

alter table public.sentetik_kosu enable row level security;
alter table public.sentetik_sonuc enable row level security;
revoke all on public.sentetik_kosu  from public, anon, authenticated;
revoke all on public.sentetik_sonuc from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Kaydet: bir koşu ve sonuçları tek işlemde (en fazla 200 sonuç)
-- ---------------------------------------------------------------------
create or replace function public.admin_sentetik_kaydet(
  p_surum       text,
  p_tohum       bigint,
  p_varsayimlar jsonb,
  p_persona     jsonb,
  p_sonuclar    jsonb,
  p_notlar      text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_kosu uuid;
  v_s    jsonb;
begin
  perform public.require_admin();

  if jsonb_typeof(p_sonuclar) <> 'array' or jsonb_array_length(p_sonuclar) = 0 then
    raise exception 'Sonuç listesi boş olamaz' using errcode = '22023';
  end if;
  if jsonb_array_length(p_sonuclar) > 200 then
    raise exception 'Bir koşuda en fazla 200 sonuç' using errcode = '22023';
  end if;

  insert into public.sentetik_kosu (tohum, surum, varsayimlar, persona, notlar)
  values (p_tohum, p_surum, p_varsayimlar, p_persona, p_notlar)
  returning id into v_kosu;

  for v_s in select * from jsonb_array_elements(p_sonuclar) loop
    insert into public.sentetik_sonuc (kosu_id, senaryo, fiyat_kurus, beklenen_alt, beklenen_ust, etiket)
    values (v_kosu,
            v_s->>'senaryo',
            (v_s->>'fiyat_kurus')::integer,
            (v_s->>'beklenen_alt')::numeric,
            (v_s->>'beklenen_ust')::numeric,
            coalesce(v_s->>'etiket', 'hipotez'));
  end loop;

  return v_kosu;
end;
$function$;

-- ---------------------------------------------------------------------
-- Listele: son koşular ve sonuçları (en yeni önce)
-- ---------------------------------------------------------------------
create or replace function public.admin_sentetik_listele(p_limit int default 10)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_limit int := least(greatest(coalesce(p_limit, 10), 1), 50);
begin
  perform public.require_admin();

  return coalesce((
    select jsonb_agg(jsonb_build_object(
             'id', k.id, 'olusturma', k.olusturma, 'tohum', k.tohum, 'surum', k.surum,
             'varsayimlar', k.varsayimlar, 'persona', k.persona, 'notlar', k.notlar,
             'sonuclar', coalesce((
               select jsonb_agg(jsonb_build_object(
                        'senaryo', s.senaryo, 'fiyat_kurus', s.fiyat_kurus,
                        'beklenen_alt', s.beklenen_alt, 'beklenen_ust', s.beklenen_ust,
                        'etiket', s.etiket)
                      order by s.fiyat_kurus)
                 from public.sentetik_sonuc s where s.kosu_id = k.id
             ), '[]'::jsonb))
           order by k.olusturma desc)
      from (select * from public.sentetik_kosu order by olusturma desc limit v_limit) k
  ), '[]'::jsonb);
end;
$function$;

revoke execute on function public.admin_sentetik_kaydet(text, bigint, jsonb, jsonb, jsonb, text) from public, anon;
revoke execute on function public.admin_sentetik_listele(int)                                       from public, anon;
grant  execute on function public.admin_sentetik_kaydet(text, bigint, jsonb, jsonb, jsonb, text)    to authenticated, service_role;
grant  execute on function public.admin_sentetik_listele(int)                                       to authenticated, service_role;
