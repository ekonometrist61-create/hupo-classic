-- =====================================================================
-- Adım adım çözüm metni + "süre doldu" (boş cevap) desteği
--   * questions.cozum_adimlari : çözüm adımları (JSON metin dizisi)
--     Bu sütun istemciye AÇILMAZ (20260920000300'deki sütun listesinde yok);
--     çözüm yalnızca cevap verildikten sonra submit_answer() sonucunda döner.
--   * submit_answer(): p_secilen_sik NULL ise süre dolmuş demektir → yanlış sayılır.
-- =====================================================================

set client_encoding = 'UTF8';

alter table public.questions
  add column if not exists cozum_adimlari jsonb not null default '[]'::jsonb;

alter table public.questions
  drop constraint if exists questions_cozum_adimlari_is_array;
alter table public.questions
  add constraint questions_cozum_adimlari_is_array
  check (jsonb_typeof(cozum_adimlari) = 'array');

-- Süresi dolan soruda seçilmiş şık yoktur
alter table public.user_answers
  alter column secilen_sik drop not null;

create or replace function public.submit_answer(
  p_question_id  uuid,
  p_secilen_sik  text,
  p_sure_ms      integer default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid    uuid := (select auth.uid());
  v_q      record;
  v_a      public.user_answers%rowtype;
  v_exists boolean;
  v_dogru  boolean;
  v_due    boolean;
  v_kalite integer;
  v_ef     numeric;
  v_rep    integer;
  v_aralik integer;
  v_next   timestamptz;
  v_award  jsonb;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Yalnızca öğrenciler soru cevaplayabilir' using errcode = '42501';
  end if;

  select id, zorluk, dogru_sik, siklar, cozum_adimlari
    into v_q
    from public.questions
   where id = p_question_id and onay_durumu = 'onaylandi';
  if not found then
    raise exception 'Soru bulunamadı' using errcode = 'P0002';
  end if;

  -- NULL = süre doldu (yanlış sayılır); doluysa geçerli bir şık olmalı
  if p_secilen_sik is not null and not (v_q.siklar ? p_secilen_sik) then
    raise exception 'Geçersiz şık' using errcode = '22023';
  end if;

  v_dogru := (p_secilen_sik is not null and p_secilen_sik = v_q.dogru_sik);

  select * into v_a
    from public.user_answers
   where student_id = v_uid and question_id = p_question_id
   for update;
  v_exists := found;

  if v_exists then
    v_ef := v_a.ease_factor;
    v_rep := v_a.tekrar_sayisi;
    v_aralik := v_a.aralik_gun;
    v_next := v_a.sonraki_tekrar_tarihi;
    v_due := v_a.sonraki_tekrar_tarihi <= now();
  else
    v_ef := 2.5;
    v_rep := 0;
    v_aralik := 0;
    v_next := now();
    v_due := true;
  end if;

  -- SM-2: zamanı gelmeden doğru cevap programı değiştirmez; yanlış her zaman sıfırlar
  if v_due or not v_dogru then
    v_kalite := case when v_dogru then 4 else 1 end;

    if v_kalite < 3 then
      v_rep := 0;
      v_aralik := 1;
    else
      v_rep := v_rep + 1;
      v_aralik := case v_rep
                    when 1 then 1
                    when 2 then 6
                    else round(v_aralik * v_ef)::integer
                  end;
    end if;

    v_ef := greatest(
      1.3,
      v_ef + 0.1 - (5 - v_kalite) * (0.08 + (5 - v_kalite) * 0.02)
    );
    v_next := now() + make_interval(days => v_aralik);
  end if;

  insert into public.user_answers as ua (
    student_id, question_id, secilen_sik, dogru_mu, son_sure_ms, son_cevap_tarihi,
    deneme_sayisi, dogru_sayisi, ease_factor, tekrar_sayisi, aralik_gun, sonraki_tekrar_tarihi
  )
  values (
    v_uid, p_question_id, p_secilen_sik, v_dogru, p_sure_ms, now(),
    1, case when v_dogru then 1 else 0 end, v_ef, v_rep, v_aralik, v_next
  )
  on conflict (student_id, question_id) do update
    set secilen_sik           = excluded.secilen_sik,
        dogru_mu              = excluded.dogru_mu,
        son_sure_ms           = excluded.son_sure_ms,
        son_cevap_tarihi      = excluded.son_cevap_tarihi,
        deneme_sayisi         = ua.deneme_sayisi + 1,
        dogru_sayisi          = ua.dogru_sayisi + case when excluded.dogru_mu then 1 else 0 end,
        ease_factor           = excluded.ease_factor,
        tekrar_sayisi         = excluded.tekrar_sayisi,
        aralik_gun            = excluded.aralik_gun,
        sonraki_tekrar_tarihi = excluded.sonraki_tekrar_tarihi;

  if v_dogru then
    -- XP yalnızca yeni veya tekrar zamanı gelmiş soruda verilir
    v_award := public.award_xp_and_streak(v_uid, v_q.zorluk, v_due);
  else
    select jsonb_build_object(
             'kazanilan_xp', 0,
             'xp', s.xp,
             'level', s.level,
             'streak_count', s.streak_count,
             'last_active_date', s.last_active_date
           )
      into v_award
      from public.student_stats s
     where s.student_id = v_uid;
  end if;

  return coalesce(v_award, '{}'::jsonb) || jsonb_build_object(
    'dogru_mu',              v_dogru,
    'dogru_sik',             v_q.dogru_sik,
    'cozum_adimlari',        v_q.cozum_adimlari,
    'sure_doldu',            p_secilen_sik is null,
    'sonraki_tekrar_tarihi', v_next
  );
end;
$$;

revoke execute on function public.submit_answer(uuid, text, integer) from public, anon;
grant  execute on function public.submit_answer(uuid, text, integer) to authenticated;
