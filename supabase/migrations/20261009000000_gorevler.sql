-- =====================================================================
-- Günlük Görevler (Quests)
--   * quest_definitions : sabit katalog (badge_definitions ile aynı desen)
--   * quest_claims       : ödül yalnızca bir kez alınsın diye (gün bazlı)
--   * İlerleme canlı hesaplanır (yeni sayaç tablosu yok): user_answers
--     üzerinden "bugün" sorgulanır — veli raporu/konu ilerlemesiyle aynı
--     "sunucu gerçek veriden hesaplar" ilkesi.
--   * submit_answer(): kurtarma anının tarihini de kaydeder (kurtarma_tarihi)
--     — "bugün kaç kurtarma yaptın" görevi bunu kullanır.
-- =====================================================================

set client_encoding = 'UTF8';

alter table public.user_answers
  add column if not exists kurtarma_tarihi timestamptz;

create table public.quest_definitions (
  kod         text primary key,
  baslik      text not null,
  aciklama    text not null,
  hedef_tipi  text not null check (hedef_tipi in ('soru_sayisi', 'dogru_sayisi', 'kurtarma_sayisi')),
  hedef_deger integer not null check (hedef_deger > 0),
  odul_xp     integer not null check (odul_xp > 0),
  aktif       boolean not null default true,
  sira        integer not null default 0
);

alter table public.quest_definitions enable row level security;
create policy "quest_definitions_select"
  on public.quest_definitions for select to authenticated
  using (true);
revoke all on public.quest_definitions from anon;
revoke insert, update, delete on public.quest_definitions from authenticated;

insert into public.quest_definitions (kod, baslik, aciklama, hedef_tipi, hedef_deger, odul_xp, sira) values
  ('gunluk_10_soru',   'Günlük soru',            'Bugün 10 soru çöz',                              'soru_sayisi',     10, 20, 1),
  ('gunluk_5_dogru',   'Doğru seri',             'Bugün 5 doğru cevap ver',                         'dogru_sayisi',    5,  20, 2),
  ('gunluk_kurtarma',  'Yanlışlarını tekrar et', 'Bugün 2 kurtarma yap (yanlıştan sonra benzer soruyu doğru çöz)', 'kurtarma_sayisi', 2, 30, 3);

create table public.quest_claims (
  student_id uuid not null references public.profiles (id) on delete cascade,
  quest_kod  text not null references public.quest_definitions (kod) on delete cascade,
  gun        date not null,
  odul_xp    integer not null check (odul_xp > 0),
  created_at timestamptz not null default now(),
  primary key (student_id, quest_kod, gun)
);

alter table public.quest_claims enable row level security;
create policy "quest_claims_select"
  on public.quest_claims for select to authenticated
  using (student_id = (select auth.uid()) or public.is_parent_of(student_id));
revoke all on public.quest_claims from anon;
revoke insert, update, delete on public.quest_claims from authenticated;

-- ---------------------------------------------------------------------
-- submit_answer(): kurtarma anının tarihini de damgala (görev sayımı için)
-- ---------------------------------------------------------------------
create or replace function public.submit_answer(
  p_question_id  uuid,
  p_secilen_sik  text,
  p_sure_ms      integer default null,
  p_request_id   uuid    default null,
  p_kurtarma_of  uuid    default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid         uuid := (select auth.uid());
  v_q           record;
  v_a           public.user_answers%rowtype;
  v_exists      boolean;
  v_dogru       boolean;
  v_due         boolean;
  v_kalite      integer;
  v_ef          numeric;
  v_rep         integer;
  v_aralik      integer;
  v_next        timestamptz;
  v_award       jsonb;
  v_orig        public.user_answers%rowtype;
  v_orig_konu   text;
  v_recovery_xp integer := 0;
  v_kurtarma_mi boolean := false;
  v_new_xp      integer;
  v_new_level   integer;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Yalnızca öğrenciler soru cevaplayabilir' using errcode = '42501';
  end if;

  select id, konu, zorluk, dogru_sik, siklar, cozum_adimlari
    into v_q
    from public.questions
   where id = p_question_id and onay_durumu = 'onaylandi';
  if not found then
    raise exception 'Soru bulunamadı' using errcode = 'P0002';
  end if;

  if p_secilen_sik is not null and not (v_q.siklar ? p_secilen_sik) then
    raise exception 'Geçersiz şık' using errcode = '22023';
  end if;

  v_dogru := (p_secilen_sik is not null and p_secilen_sik = v_q.dogru_sik);

  select * into v_a
    from public.user_answers
   where student_id = v_uid and question_id = p_question_id
   for update;
  v_exists := found;

  -- Aynı request_id ile gelen tekrar istek: XP vermeden önbellek sonucu dön
  if v_exists and p_request_id is not null and v_a.son_request_id = p_request_id then
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

    return coalesce(v_award, '{}'::jsonb) || jsonb_build_object(
      'dogru_mu',              v_a.dogru_mu,
      'dogru_sik',             v_q.dogru_sik,
      'cozum_adimlari',        v_q.cozum_adimlari,
      'sure_doldu',            v_a.secilen_sik is null,
      'sonraki_tekrar_tarihi', v_a.sonraki_tekrar_tarihi,
      'replay',                true,
      'kurtarma_mi',           false
    );
  end if;

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
    deneme_sayisi, dogru_sayisi, ease_factor, tekrar_sayisi, aralik_gun,
    sonraki_tekrar_tarihi, son_request_id
  )
  values (
    v_uid, p_question_id, p_secilen_sik, v_dogru, p_sure_ms, now(),
    1, case when v_dogru then 1 else 0 end, v_ef, v_rep, v_aralik, v_next,
    p_request_id
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
        sonraki_tekrar_tarihi = excluded.sonraki_tekrar_tarihi,
        son_request_id        = excluded.son_request_id;

  if v_dogru then
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

  -- Kurtarma XP: yanlış yapılan bir sorunun hemen ardından AYNI konudan farklı
  -- bir soru doğru çözülürse bir kez verilir. kurtarma_tarihi, günlük görev
  -- sayımı için ayrıca damgalanır.
  if v_dogru and p_kurtarma_of is not null and p_kurtarma_of <> p_question_id then
    select * into v_orig
      from public.user_answers
     where student_id = v_uid and question_id = p_kurtarma_of
       for update;

    if found and not v_orig.dogru_mu and not v_orig.kurtarma_xp_verildi then
      select konu into v_orig_konu
        from public.questions
       where id = p_kurtarma_of;

      if v_orig_konu is not null and v_orig_konu = v_q.konu then
        v_recovery_xp := 5;
        v_kurtarma_mi := true;

        update public.user_answers
           set kurtarma_xp_verildi = true,
               kurtarma_tarihi     = now()
         where student_id = v_uid and question_id = p_kurtarma_of;

        insert into public.xp_events (student_id, xp) values (v_uid, v_recovery_xp);

        update public.student_stats
           set xp = xp + v_recovery_xp,
               level = ((xp + v_recovery_xp) / 100) + 1
         where student_id = v_uid
        returning xp, level into v_new_xp, v_new_level;

        v_award := v_award || jsonb_build_object(
          'kazanilan_xp', coalesce((v_award->>'kazanilan_xp')::integer, 0) + v_recovery_xp,
          'xp',           v_new_xp,
          'level',        v_new_level
        );
      end if;
    end if;
  end if;

  return coalesce(v_award, '{}'::jsonb) || jsonb_build_object(
    'dogru_mu',              v_dogru,
    'dogru_sik',             v_q.dogru_sik,
    'cozum_adimlari',        v_q.cozum_adimlari,
    'sure_doldu',            p_secilen_sik is null,
    'sonraki_tekrar_tarihi', v_next,
    'kurtarma_mi',           v_kurtarma_mi
  );
end;
$$;

revoke execute on function public.submit_answer(uuid, text, integer, uuid, uuid) from public, anon;
grant  execute on function public.submit_answer(uuid, text, integer, uuid, uuid) to authenticated;

-- ---------------------------------------------------------------------
-- Görev ilerlemesi: "bugün" gerçek veriden hesaplanır (sayaç tablosu yok)
-- ---------------------------------------------------------------------
create or replace function public._gorev_ilerleme(p_uid uuid, p_tipi text, p_gun date)
returns integer
language sql
stable
security invoker
set search_path = ''
as $$
  select case p_tipi
    when 'soru_sayisi' then (
      select count(*)::integer from public.user_answers
       where student_id = p_uid
         and (son_cevap_tarihi at time zone 'Europe/Istanbul')::date = p_gun
    )
    when 'dogru_sayisi' then (
      select count(*)::integer from public.user_answers
       where student_id = p_uid and dogru_mu
         and (son_cevap_tarihi at time zone 'Europe/Istanbul')::date = p_gun
    )
    when 'kurtarma_sayisi' then (
      select count(*)::integer from public.user_answers
       where student_id = p_uid and kurtarma_tarihi is not null
         and (kurtarma_tarihi at time zone 'Europe/Istanbul')::date = p_gun
    )
    else 0
  end;
$$;

revoke execute on function public._gorev_ilerleme(uuid, text, date) from public, anon, authenticated;

create or replace function public.get_my_quests()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_gun date := (now() at time zone 'Europe/Istanbul')::date;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Yalnızca öğrenciler görevlerini görebilir' using errcode = '42501';
  end if;

  return coalesce((
    select jsonb_agg(row_to_json(t) order by t.sira)
      from (
        select qd.kod,
               qd.baslik,
               qd.aciklama,
               qd.hedef_deger,
               qd.odul_xp,
               qd.sira,
               least(public._gorev_ilerleme(v_uid, qd.hedef_tipi, v_gun), qd.hedef_deger) as ilerleme,
               (public._gorev_ilerleme(v_uid, qd.hedef_tipi, v_gun) >= qd.hedef_deger) as tamamlandi,
               exists (
                 select 1 from public.quest_claims qc
                  where qc.student_id = v_uid and qc.quest_kod = qd.kod and qc.gun = v_gun
               ) as odul_alindi
          from public.quest_definitions qd
         where qd.aktif
      ) t
  ), '[]'::jsonb);
end;
$$;

revoke execute on function public.get_my_quests() from public, anon;
grant  execute on function public.get_my_quests() to authenticated;

create or replace function public.claim_quest_reward(p_kod text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := (select auth.uid());
  v_gun     date := (now() at time zone 'Europe/Istanbul')::date;
  v_quest   record;
  v_ilerleme integer;
  v_new_xp  integer;
  v_new_level integer;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Yalnızca öğrenciler ödül alabilir' using errcode = '42501';
  end if;

  select kod, hedef_tipi, hedef_deger, odul_xp into v_quest
    from public.quest_definitions
   where kod = p_kod and aktif;
  if not found then
    raise exception 'Görev bulunamadı' using errcode = 'P0002';
  end if;

  v_ilerleme := public._gorev_ilerleme(v_uid, v_quest.hedef_tipi, v_gun);
  if v_ilerleme < v_quest.hedef_deger then
    raise exception 'Görev henüz tamamlanmadı' using errcode = '22023';
  end if;

  insert into public.quest_claims (student_id, quest_kod, gun, odul_xp)
  values (v_uid, p_kod, v_gun, v_quest.odul_xp);

  insert into public.xp_events (student_id, xp) values (v_uid, v_quest.odul_xp);

  update public.student_stats
     set xp = xp + v_quest.odul_xp,
         level = ((xp + v_quest.odul_xp) / 100) + 1
   where student_id = v_uid
  returning xp, level into v_new_xp, v_new_level;

  return jsonb_build_object('kazanilan_xp', v_quest.odul_xp, 'xp', v_new_xp, 'level', v_new_level);
exception
  when unique_violation then
    raise exception 'Bu görevin ödülünü bugün zaten aldın' using errcode = '23505';
end;
$$;

revoke execute on function public.claim_quest_reward(text) from public, anon;
grant  execute on function public.claim_quest_reward(text) to authenticated;
