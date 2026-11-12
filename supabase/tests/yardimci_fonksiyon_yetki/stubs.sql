-- Yardımcı fonksiyon yetki testi: Supabase bağımlılıklarının taklidi (gerçek migration değil).
-- Roller ve varsayılan yetkiler test.mjs içinde kurulur; bu dosya önce çalışır.
-- Postgres yeni fonksiyonlara PUBLIC'e EXECUTE verir; anon/authenticated de varsayılan
-- yetki ile gelir. Bu, canlıdaki drift durumunu üretmek için kullanılır.

-- Taklit: updated_at trigger fonksiyonu (gerçek tanımla aynı imza ve gövde).
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Taklit: Türkçe normalizasyon. Gerçek gövde ayrıntılı; burada yalnızca aynı imza ve
-- immutable niteliği. Harf eşlemesi: Ğ G, Ü U, Ş S, Ö O, Ç C, İ I, ı i.
create or replace function public.tr_normalize(p_text text)
returns text
language sql
immutable
parallel safe
set search_path = ''
as $$
  select lower(translate(p_text, 'ĞğÜüŞşÖöÇçİı', 'GgUuSsOoCcIi'));
$$;

-- Taklit: hafta başlangıcı (gerçek tanımla aynı gövde; INVOKER).
create or replace function public.hafta_baslangic()
returns date
language sql
stable
set search_path = ''
as $$
  select date_trunc('week', now() at time zone 'Europe/Istanbul')::date;
$$;

-- Kontrol fonksiyonu: bu migration'dan etkilenmemeli (yan etki yok kanıtı).
create or replace function public.kontrol_fonksiyon()
returns integer
language sql
immutable
set search_path = ''
as $$
  select 1;
$$;

-- Çağıran 1 (SECURITY DEFINER): repodaki gerçek çağıranların deseni.
-- anon EXECUTE'u kapansa da iç çağrılar sahibin yetkisiyle çalışmalı.
create or replace function public.ornek_definer_cagri(p_text text)
returns text
language plpgsql
security definer
set search_path = ''
as $$
begin
  return public.tr_normalize(p_text) || '|' || public.hafta_baslangic()::text;
end;
$$;

-- Çağıran 2 (SECURITY INVOKER): repoda böyle bir çağıran yok. Beklenen davranış:
-- anon bu fonksiyonu çağırırsa tr_normalize yetkisi yetmez (42501).
create or replace function public.ornek_invoker_cagri(p_text text)
returns text
language sql
stable
set search_path = ''
as $$
  select public.tr_normalize(p_text);
$$;

-- Tablo üretilen sütunla: questions.arama_vektoru (initial_schema) desenini taklit eder.
create table public.questions_stub (
  id            bigserial primary key,
  soru_metni    text not null,
  arama_vektoru tsvector generated always as (
    to_tsvector('simple', public.tr_normalize(soru_metni))
  ) stored
);
