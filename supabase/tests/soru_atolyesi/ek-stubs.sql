-- Soru Atölyesi testleri için ek taklitler (kelime_evreni/stubs.sql'in üstüne uygulanır).
-- require_admin: test admin kabul edilir (yetki kontrolü ayrıca gerçek sistemde).
-- tr_normalize: panel mükerrer kontrolü için sadeleştirilmiş sürüm.
create or replace function public.require_admin() returns void
language plpgsql as $$ begin null; end $$;

create or replace function public.tr_normalize(t text) returns text
language sql immutable as $$
  select lower(regexp_replace(coalesce(t, ''), '\s+', ' ', 'g'))
$$;

alter table public.questions
  add column if not exists alt_konu text,
  add column if not exists cozum_adimlari jsonb not null default '[]'::jsonb,
  add column if not exists created_by uuid;

-- _soru_hatasi: üretim migrasyonu 20260920000900_admin_role_and_payments.sql ile birebir aynı gövde.
create or replace function public._soru_hatasi(p jsonb)
returns text
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_siklar jsonb := p -> 'siklar';
  v_key    text;
begin
  if nullif(trim(coalesce(p ->> 'okul', '')), '') is null then return 'okul boş olamaz'; end if;
  if nullif(trim(coalesce(p ->> 'ders', '')), '') is null then return 'ders boş olamaz'; end if;
  if nullif(trim(coalesce(p ->> 'konu', '')), '') is null then return 'konu boş olamaz'; end if;
  if nullif(trim(coalesce(p ->> 'soru_metni', '')), '') is null then return 'soru metni boş olamaz'; end if;
  if coalesce(p ->> 'zorluk', '') !~ '^[1-3]$' then return 'zorluk 1, 2 veya 3 olmalı'; end if;

  if jsonb_typeof(v_siklar) is distinct from 'object' then return 'şıklar eksik'; end if;
  if (select count(*) from jsonb_object_keys(v_siklar)) < 2 then return 'en az 2 şık gerekli'; end if;
  for v_key in select jsonb_object_keys(v_siklar) loop
    if v_key !~ '^[A-E]$' then
      return format('şık anahtarı A-E arasında olmalı (%s)', v_key);
    end if;
    if nullif(trim(coalesce(v_siklar ->> v_key, '')), '') is null then
      return format('%s şıkkı boş olamaz', v_key);
    end if;
  end loop;

  if not (v_siklar ? upper(coalesce(p ->> 'dogru_sik', ''))) then
    return 'doğru şık, dolu şıklardan biri olmalı';
  end if;
  if p ? 'cozum_adimlari' and jsonb_typeof(p -> 'cozum_adimlari') is distinct from 'array' then
    return 'çözüm adımları liste olmalı';
  end if;
  if coalesce(p ->> 'onay_durumu', 'beklemede') not in ('beklemede', 'onaylandi', 'reddedildi') then
    return 'onay durumu beklemede, onaylandi veya reddedildi olmalı';
  end if;
  return null;
end;
$$;

-- Üretimdeki sütun yetkileri (20260920000300_hide_correct_answer.sql ile birebir): tablo select kapalı,
-- yalnızca listelenen sütunlar açık. Yeni Soru Atölyesi sütunları bu listede DEĞİL → öğrenciye kapalı.
alter table public.questions add column if not exists created_at timestamptz default now(), add column if not exists updated_at timestamptz default now();
revoke select on public.questions from authenticated;
grant select (
  id, okul, ders, konu, alt_konu, zorluk, soru_metni, siklar,
  onay_durumu, created_at, updated_at
) on public.questions to authenticated;