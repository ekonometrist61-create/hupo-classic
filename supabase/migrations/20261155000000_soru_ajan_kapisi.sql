-- =====================================================================
-- Sorular: Ajan A / Ajan B kapısı (GÖR-090, kullanıcı talebi 2026-11-08)
--   Akış: beklemede → Ajan A + Ajan B "pass" → insan onayı → onaylandi.
--   1. questions.denetim (jsonb): { ajan_a, ajan_b } değerleri pending|pass|review_needed|fail.
--      Anahtar yoksa "bekliyor" sayılır.
--   2. Tetikleyici: bir soru "onaylandi" durumuna GEÇERKEN ikisi de "pass" değilse
--      işlem reddedilir (AJAN_KAPISI). Bu, panel, içe aktarma ve doğrudan SQL yollarının
--      hepsini kapsar; RPC'ye bağımlı değildir.
--      Mevcut onaylı sorular etkilenmez (geçiş yalnızca onaylandi'ye yeni girişte kontrol edilir).
--   3. admin_soru_ajan_denetim_isle(p_sonuclar): yalnız service_role çağırır. Ajan sonuçlarını yazar.
--   4. admin_list_questions: p_denetim süzgeci (ajan_gecti | ajan_bekliyor | ajan_reddi) ve
--      satırda denetim alanı. Eski 8 parametreli sürüm kaldırılır (adlandırılmış çağrı belirsizliği).
-- =====================================================================

set client_encoding = 'UTF8';

alter table public.questions
  add column if not exists denetim jsonb not null default '{}'::jsonb;

alter table public.questions drop constraint if exists questions_denetim_is_object;
alter table public.questions
  add constraint questions_denetim_is_object check (jsonb_typeof(denetim) = 'object');

comment on column public.questions.denetim is
  'Ajan denetim sonuçları: {"ajan_a": "pass|review_needed|fail", "ajan_b": ..., "denetim_zaman": ts}. Onay kapısı yalnız ikisi pass iken açılır.';

-- ---------------------------------------------------------------------
-- Yardımcı: iki ajan da geçti mi?
-- ---------------------------------------------------------------------
create or replace function public.soru_ajan_gecti(p_denetim jsonb)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select coalesce(p_denetim ->> 'ajan_a', '') = 'pass'
     and coalesce(p_denetim ->> 'ajan_b', '') = 'pass';
$$;

-- Saf ve salt okunur fonksiyon; tetikleyici çağıran rolün yetkisiyle çalıştığı için geri alınmaz.

-- ---------------------------------------------------------------------
-- Tetikleyici: onaylandi'ye geçişte ajan kapısı
-- ---------------------------------------------------------------------
create or replace function public.questions_ajan_kapisi()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.onay_durumu = 'onaylandi'
     and (tg_op = 'INSERT' or old.onay_durumu is distinct from 'onaylandi')
     and not public.soru_ajan_gecti(new.denetim) then
    raise exception 'AJAN_KAPISI: soru Ajan A ve Ajan B kontrolünden geçmeden onaylanamaz' using errcode = '22023';
  end if;
  return new;
end;
$$;

revoke all on function public.questions_ajan_kapisi() from public, anon, authenticated;

drop trigger if exists questions_ajan_kapisi on public.questions;
create trigger questions_ajan_kapisi
  before insert or update of onay_durumu, denetim on public.questions
  for each row execute function public.questions_ajan_kapisi();

-- ---------------------------------------------------------------------
-- Ajan sonuçlarını yaz (yalnız service_role; pipeline çağırır)
--   p_sonuclar: [{ "id": uuid, "ajan_a": "pass|review_needed|fail", "ajan_b": "...", "not": "..." }]
--   Eksik ajan alanı dokunulmadan kalır. Onay durumunu DEĞİŞTİRMEZ.
-- ---------------------------------------------------------------------
create or replace function public.admin_soru_ajan_denetim_isle(p_sonuclar jsonb)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_r     jsonb;
  v_a     text;
  v_b     text;
  v_adet  integer;
  v_n     integer := 0;
begin
  if p_sonuclar is null or jsonb_typeof(p_sonuclar) <> 'array' then
    raise exception 'BAD_LISTE: dizi bekleniyor' using errcode = '22023';
  end if;

  for v_r in select value from jsonb_array_elements(p_sonuclar) loop
    v_a := nullif(v_r ->> 'ajan_a', '');
    v_b := nullif(v_r ->> 'ajan_b', '');
    if (v_a is not null and v_a not in ('pass', 'review_needed', 'fail'))
       or (v_b is not null and v_b not in ('pass', 'review_needed', 'fail')) then
      raise exception 'BAD_SONUC: ajan sonucu pass, review_needed veya fail olmalı' using errcode = '22023';
    end if;

    update public.questions q
       set denetim = q.denetim || jsonb_strip_nulls(jsonb_build_object(
             'ajan_a', v_a,
             'ajan_b', v_b,
             'denetim_not', nullif(v_r ->> 'not', ''),
             'denetim_zaman', now()))
     where q.id = (v_r ->> 'id')::uuid;
    get diagnostics v_adet = row_count;
    v_n := v_n + v_adet;
  end loop;

  return v_n;
end;
$$;

revoke all on function public.admin_soru_ajan_denetim_isle(jsonb) from public, anon, authenticated;
grant execute on function public.admin_soru_ajan_denetim_isle(jsonb) to service_role;

-- ---------------------------------------------------------------------
-- Yönetici listesi: ajan denetim süzgeci ve denetim alanı
-- ---------------------------------------------------------------------
drop function if exists public.admin_list_questions(text, text, integer, text, integer, integer, boolean, integer);

create or replace function public.admin_list_questions(
  p_ders text default null,
  p_durum text default null,
  p_zorluk integer default null,
  p_arama text default null,
  p_limit integer default 25,
  p_offset integer default 0,
  p_inceleme boolean default null,
  p_sinif integer default null,
  p_denetim text default null
)
returns jsonb
language plpgsql
stable security definer
set search_path to ''
as $function$
declare
  v_limit  integer := least(greatest(coalesce(p_limit, 25), 1), 100);
  v_offset integer := greatest(coalesce(p_offset, 0), 0);
  v_arama  text := public.tr_normalize(nullif(trim(coalesce(p_arama, '')), ''));
  v_toplam integer;
  v_satir  jsonb;
begin
  perform public.require_admin();

  if p_sinif is not null and (p_sinif < 1 or p_sinif > 12) then
    raise exception 'Sınıf 1 ile 12 arasında olmalı' using errcode = '22023';
  end if;
  if p_denetim is not null and p_denetim not in ('ajan_gecti', 'ajan_bekliyor', 'ajan_reddi') then
    raise exception 'BAD_FILTRE: denetim süzgeci ajan_gecti, ajan_bekliyor veya ajan_reddi olmalı' using errcode = '22023';
  end if;

  select count(*)::integer into v_toplam
    from public.questions q
   where (p_ders is null or q.ders = p_ders)
     and (p_durum is null or q.onay_durumu = p_durum)
     and (p_zorluk is null or q.zorluk = p_zorluk)
     and (p_inceleme is null or q.inceleme_gerekli = p_inceleme)
     and (p_sinif is null or q.sinif = p_sinif)
     and (p_denetim is null
          or (p_denetim = 'ajan_gecti' and public.soru_ajan_gecti(q.denetim))
          or (p_denetim = 'ajan_reddi'
              and (coalesce(q.denetim ->> 'ajan_a', '') in ('review_needed', 'fail')
                   or coalesce(q.denetim ->> 'ajan_b', '') in ('review_needed', 'fail')))
          or (p_denetim = 'ajan_bekliyor'
              and not public.soru_ajan_gecti(q.denetim)
              and not (coalesce(q.denetim ->> 'ajan_a', '') in ('review_needed', 'fail')
                       or coalesce(q.denetim ->> 'ajan_b', '') in ('review_needed', 'fail'))))
     and (v_arama is null or public.tr_normalize(q.soru_metni || ' ' || q.konu || ' ' || coalesce(q.alt_konu, ''))
                              like '%' || v_arama || '%');

  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id), '[]'::jsonb)
    into v_satir
    from (
      select q.id, q.okul, q.sinif, q.ders, q.konu, q.alt_konu, q.zorluk, q.soru_metni, q.siklar,
             q.dogru_sik, q.cozum_adimlari, q.onay_durumu, q.created_at, q.inceleme_gerekli,
             q.denetim,
             (select count(*)::integer from public.question_reports r
               where r.question_id = q.id and r.durum in ('acik', 'inceleniyor')) as acik_rapor
        from public.questions q
       where (p_ders is null or q.ders = p_ders)
         and (p_durum is null or q.onay_durumu = p_durum)
         and (p_zorluk is null or q.zorluk = p_zorluk)
         and (p_inceleme is null or q.inceleme_gerekli = p_inceleme)
         and (p_sinif is null or q.sinif = p_sinif)
         and (p_denetim is null
              or (p_denetim = 'ajan_gecti' and public.soru_ajan_gecti(q.denetim))
              or (p_denetim = 'ajan_reddi'
                  and (coalesce(q.denetim ->> 'ajan_a', '') in ('review_needed', 'fail')
                       or coalesce(q.denetim ->> 'ajan_b', '') in ('review_needed', 'fail')))
              or (p_denetim = 'ajan_bekliyor'
                  and not public.soru_ajan_gecti(q.denetim)
                  and not (coalesce(q.denetim ->> 'ajan_a', '') in ('review_needed', 'fail')
                           or coalesce(q.denetim ->> 'ajan_b', '') in ('review_needed', 'fail'))))
         and (v_arama is null or public.tr_normalize(q.soru_metni || ' ' || q.konu || ' ' || coalesce(q.alt_konu, ''))
                                  like '%' || v_arama || '%')
       order by q.created_at desc, q.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('toplam', v_toplam, 'satirlar', v_satir);
end;
$function$;

comment on function public.admin_list_questions(text, text, integer, text, integer, integer, boolean, integer, text) is
  'Yönetici soru listesi: ders/durum/zorluk/arama, sınıf ve inceleme süzgeçleri, ajan denetim süzgeci (p_denetim) ve denetim alanı.';

revoke execute on function public.admin_list_questions(text, text, integer, text, integer, integer, boolean, integer, text)
  from public, anon;
grant  execute on function public.admin_list_questions(text, text, integer, text, integer, integer, boolean, integer, text)
  to authenticated;
