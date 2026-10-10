set client_encoding = 'UTF8';

-- =====================================================================
--  Canlı tanımlara göre yazıldı (pg_get_functiondef ve kısıt dökümü).
--  1) Koşul türü kısıtına karakter_sayisi ve ders_sayisi_basari eklenir;
--     çarpım (carpim_*) türleri korunur.
--  2) badge_progress: canlı gövde korunur, iki yeni tür eklenir.
--  3) evaluate_badges: canlı gövdeye sıralı aile kuralı eklenir.
--  4) Ders ustalığı tek kural: en az 10 deneme ve en az %90 doğruluk.
--  5) Karakter kazanımı rozetleri de tetikler.
-- =====================================================================

alter table public.badge_definitions
  drop constraint if exists badge_definitions_kosul_turu_check;

alter table public.badge_definitions
  add constraint badge_definitions_kosul_turu_check
  check (kosul_turu = any (array[
    'soru_sayisi', 'streak', 'seviye', 'xp', 'ders_basari',
    'carpim_sifre_sayisi', 'carpim_zorunlu_tamam', 'carpim_yildiz',
    'carpim_streak', 'carpim_ogretti',
    'karakter_sayisi', 'ders_sayisi_basari'
  ]::text[]));

create or replace function public.badge_progress(p_student_id uuid)
returns table (badge_code text, ilerleme integer, deneme integer)
language sql
stable
security definer
set search_path = ''
as $function$
  select
    d.kod,
    case d.kosul_turu
      when 'soru_sayisi' then (
        select count(*)::integer
          from public.user_answers ua
         where ua.student_id = p_student_id)
      when 'streak' then coalesce((
        select s.streak_count from public.student_stats s
         where s.student_id = p_student_id), 0)
      when 'seviye' then coalesce((
        select s.level from public.student_stats s
         where s.student_id = p_student_id), 1)
      when 'xp' then coalesce((
        select s.xp from public.student_stats s
         where s.student_id = p_student_id), 0)
      when 'ders_basari' then coalesce((
        select round(100.0 * sum(ua.dogru_sayisi) / nullif(sum(ua.deneme_sayisi), 0))::integer
          from public.user_answers ua
          join public.questions q on q.id = ua.question_id
         where ua.student_id = p_student_id and q.ders = d.ders), 0)
      -- Çarpım Tablosu Şifreleri: tamamlanan şifre sayısı (herhangi hangileri)
      when 'carpim_sifre_sayisi' then coalesce((
        select count(*)::integer
          from public.carpim_ilerleme ci
         where ci.user_id = p_student_id and ci.kapali_bitti), 0)
      -- Zorunlu 12 şifre (sira'ya göre ilk 12) tamamlandı mı
      when 'carpim_zorunlu_tamam' then coalesce((
        select count(*)::integer
          from public.carpim_ilerleme ci
          join (select id from public.carpim_sifreleri order by sira limit 12) m
            on m.id = ci.sifre_id
         where ci.user_id = p_student_id and ci.kapali_bitti), 0)
      -- Tüm şifreler toplamında ilk denemede doğru bilinen kapalı test sorusu sayısı
      when 'carpim_yildiz' then coalesce((
        select sum(ci.kapali_yildiz)::integer
          from public.carpim_ilerleme ci
         where ci.user_id = p_student_id), 0)
      -- En son (created_at DESC) art arda ilk denemede doğru bilinen kapalı test sayısı
      when 'carpim_streak' then coalesce((
        select coalesce(
          (select (min(t.rn) - 1)::integer
             from (
               select row_number() over (order by l.created_at desc) as rn, l.ilk_sonuc
                 from public.carpim_deneme_log l
                where l.user_id = p_student_id and l.asama = 'kapali'
             ) t
            where t.ilk_sonuc = false),
          (select count(*)::integer
             from public.carpim_deneme_log l
            where l.user_id = p_student_id and l.asama = 'kapali')
        )
      ), 0)
      -- En az bir şifrede "öğrettim" işaretlendi mi (0/1)
      when 'carpim_ogretti' then (
        select case when exists (
                 select 1 from public.carpim_ilerleme ci
                  where ci.user_id = p_student_id and ci.ogretti
               ) then 1 else 0 end
      )
      when 'karakter_sayisi' then (
        select count(*)::integer
          from public.user_characters uc
         where uc.student_id = p_student_id)
      when 'ders_sayisi_basari' then (
        select count(*)::integer
          from (
            select q.ders
              from public.user_answers ua
              join public.questions q on q.id = ua.question_id
             where ua.student_id = p_student_id
             group by q.ders
            having sum(ua.deneme_sayisi) >= 10
               and 100.0 * sum(ua.dogru_sayisi) / sum(ua.deneme_sayisi) >= 90
          ) ustalasilan)
      else 0
    end,
    case when d.kosul_turu = 'ders_basari' then coalesce((
        select sum(ua.deneme_sayisi)::integer
          from public.user_answers ua
          join public.questions q on q.id = ua.question_id
         where ua.student_id = p_student_id and q.ders = d.ders), 0)
    end
  from public.badge_definitions d;
$function$;

create or replace function public.evaluate_badges(p_student_id uuid)
returns void
language sql
security definer
set search_path = ''
as $function$
  insert into public.user_badges (student_id, badge_code)
  select p_student_id, d.kod
    from public.badge_definitions d
    join public.badge_progress(p_student_id) p on p.badge_code = d.kod
   where p.ilerleme >= d.esik
     and (d.kosul_turu <> 'ders_basari' or p.deneme >= d.min_deneme)
     and not exists (
       select 1
         from public.badge_definitions onceki
        where onceki.kosul_turu = d.kosul_turu
          and onceki.esik < d.esik
          and (d.kosul_turu <> 'ders_basari' or onceki.ders = d.ders)
          and not exists (
            select 1 from public.user_badges ub
             where ub.student_id = p_student_id and ub.badge_code = onceki.kod)
     )
  on conflict (student_id, badge_code) do nothing;
$function$;

drop trigger if exists user_characters_award_badges on public.user_characters;
create trigger user_characters_award_badges
  after insert on public.user_characters
  for each row execute function public.badges_after_change();

insert into public.badge_definitions
  (kod, ad, aciklama, ikon, kosul_turu, esik, ders, min_deneme, sira)
values
  ('demir_disiplin',   'Demir Disiplin',        '100 gün üst üste soru çöz.',                                  'shield',        'streak',             100, null, 10, 65),
  ('uc_ders_uzman',    '3 Derste Uzman',        '3 farklı derste en az 10 soru çöz ve %90 başarı yakala.',     'star',          'ders_sayisi_basari', 3,   null, 10, 200),
  ('bes_ders_efsane',  '5 Derste Efsane',       '5 farklı derste en az 10 soru çöz ve %90 başarı yakala.',     'diamond',       'ders_sayisi_basari', 5,   null, 10, 210),
  ('ilk_karakter',     'İlk Karakter',          'Koleksiyondan ilk karakterini aç.',                           'flag',          'karakter_sayisi',    1,   null, 10, 220),
  ('karakter_20',      'Koleksiyoncu',          '20 karakter aç.',                                             'emoji_events',  'karakter_sayisi',    20,  null, 10, 230),
  ('karakter_40',      'Efsanevi Koleksiyoncu', 'Tüm 40 karakteri aç.',                                        'military_tech', 'karakter_sayisi',    40,  null, 10, 240)
on conflict (kod) do nothing;

create or replace function public.evaluate_characters(p_student_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_xp          integer;
  v_streak      integer;
  v_soru_sayisi integer;
  v_seviye      integer;
  v_ders_basari integer;
  r             record;
begin
  select
    coalesce(xp, 0),
    coalesce(streak_count, 0),
    coalesce(level, 1)
  into v_xp, v_streak, v_seviye
  from public.student_stats
  where student_id = p_student_id;

  v_xp     := coalesce(v_xp, 0);
  v_streak := coalesce(v_streak, 0);
  v_seviye := coalesce(v_seviye, 1);

  select coalesce(sum(dogru_sayisi), 0)::integer
  into v_soru_sayisi
  from public.user_answers
  where student_id = p_student_id;

  select count(*)::integer
  into v_ders_basari
  from (
    select q.ders
    from public.user_answers ua
    join public.questions q on q.id = ua.question_id
    where ua.student_id = p_student_id
    group by q.ders
    having sum(ua.deneme_sayisi) >= 10
       and 100.0 * sum(ua.dogru_sayisi) / sum(ua.deneme_sayisi) >= 90
  ) t;

  for r in
    select cd.kod, cd.kosul_turu, cd.kosul_deger
    from public.character_definitions cd
    where not exists (
      select 1 from public.user_characters uc
      where uc.student_id = p_student_id and uc.karakter_kod = cd.kod
    )
    and (
      cd.karakter_sira = 1
      or exists (
        select 1
          from public.user_characters uc2
          join public.character_definitions cd2 on uc2.karakter_kod = cd2.kod
         where uc2.student_id = p_student_id
           and cd2.sinif = cd.sinif
           and cd2.karakter_sira = cd.karakter_sira - 1
      )
    )
  loop
    if (r.kosul_turu = 'baslangic') or
       (r.kosul_turu = 'xp'          and v_xp          >= r.kosul_deger) or
       (r.kosul_turu = 'streak'       and v_streak      >= r.kosul_deger) or
       (r.kosul_turu = 'soru_sayisi'  and v_soru_sayisi >= r.kosul_deger) or
       (r.kosul_turu = 'seviye'       and v_seviye      >= r.kosul_deger) or
       (r.kosul_turu = 'ders_basari'  and v_ders_basari >= r.kosul_deger)
    then
      insert into public.user_characters (student_id, karakter_kod)
      values (p_student_id, r.kod)
      on conflict do nothing;
    end if;
  end loop;
end;
$function$;
