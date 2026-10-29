-- =====================================================================
-- Akıllı soru vurgulama metadata'sı
-- soru_metni tek doğruluk kaynağı olarak DEĞİŞMEZ; vurgu ayrı sütunda aralık olarak tutulur.
-- highlights: [{"start":int,"end":int}] — soru_metni içinde Unicode KOD NOKTASI ofseti, end hariç.
-- Geri alma: update public.questions set highlights = null, highlight_durum = null;
--            (alter table ... drop column highlights, highlight_durum;)
-- =====================================================================

set client_encoding = 'UTF8';

alter table public.questions
  add column if not exists highlights      jsonb,
  add column if not exists highlight_durum text;

alter table public.questions drop constraint if exists questions_highlights_gecerli;
alter table public.questions add constraint questions_highlights_gecerli
  check (highlights is null or (jsonb_typeof(highlights) = 'array' and jsonb_array_length(highlights) <= 2));

alter table public.questions drop constraint if exists questions_highlight_durum_gecerli;
alter table public.questions add constraint questions_highlight_durum_gecerli
  check (highlight_durum is null or highlight_durum in ('otomatik', 'inceleme', 'onayli', 'yok'));

-- Aralık sınırları soru_metni uzunluğunu aşamaz (kod noktası cinsinden).
create or replace function public.questions_highlights_aralik_kontrol()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
declare
  h jsonb;
  v_len int := char_length(new.soru_metni);
begin
  if new.highlights is null then
    return new;
  end if;
  for h in select * from jsonb_array_elements(new.highlights) loop
    if jsonb_typeof(h -> 'start') <> 'number' or jsonb_typeof(h -> 'end') <> 'number'
       or (h ->> 'start')::int < 0 or (h ->> 'end')::int > v_len
       or (h ->> 'start')::int >= (h ->> 'end')::int then
      raise exception 'highlights aralığı geçersiz: %', h using errcode = '22023';
    end if;
  end loop;
  return new;
end;
$$;

drop trigger if exists trg_questions_highlights_aralik on public.questions;
create trigger trg_questions_highlights_aralik
  before insert or update of highlights, soru_metni on public.questions
  for each row execute function public.questions_highlights_aralik_kontrol();

-- Metin düzenlenirse eski aralıklar geçersizleşir: otomatik temizle, editör yeniden onaylasın.
create or replace function public.questions_highlights_metin_degisti()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
begin
  if new.soru_metni is distinct from old.soru_metni and new.highlights is not distinct from old.highlights then
    new.highlights := null;
    new.highlight_durum := 'inceleme';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_questions_highlights_metin on public.questions;
create trigger trg_questions_highlights_metin
  before update of soru_metni on public.questions
  for each row execute function public.questions_highlights_metin_degisti();

-- İstemci: yalnız aralıklar. Durum alanı yönetim içindir.
grant select (highlights) on public.questions to authenticated;

comment on column public.questions.highlights is
  'Soru kökü vurgu aralıkları [{start,end}] (kod noktası ofseti). Şık/cevap anahtarına bağlı değildir.';
