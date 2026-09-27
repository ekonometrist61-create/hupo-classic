-- =====================================================================
-- Rozet (badge) sistemi
--   badge_definitions : rozet kataloğu (ad, kazanma şartı, eşik)
--   user_badges       : kazanılan rozetler (mevcut tablo; artık kataloğa bağlı)
--   Rozetler SUNUCUDA, cevap/istatistik değiştikçe otomatik verilir; istemci rozet veremez.
--   get_student_badges() : profil ekranının veri kaynağı (kazanıldı mı + ilerleme)
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Katalog
-- ---------------------------------------------------------------------
create table public.badge_definitions (
  kod         text primary key,
  ad          text not null,
  aciklama    text not null,                       -- kazanma şartı (kullanıcıya gösterilir)
  ikon        text not null default 'star',        -- uygulamadaki ikon anahtarı
  kosul_turu  text not null
                check (kosul_turu in ('soru_sayisi', 'streak', 'seviye', 'xp', 'ders_basari')),
  esik        integer not null check (esik > 0),   -- ders_basari için yüzde, diğerleri için sayı
  ders        text,                                -- yalnızca ders_basari
  min_deneme  integer not null default 10 check (min_deneme > 0),
  sira        integer not null default 0,

  constraint badge_definitions_ders_gerekli
    check (kosul_turu <> 'ders_basari' or ders is not null),
  constraint badge_definitions_yuzde_araligi
    check (kosul_turu <> 'ders_basari' or esik <= 100)
);

alter table public.badge_definitions enable row level security;

create policy "badge_definitions_select"
  on public.badge_definitions for select to authenticated
  using (true);

revoke all on public.badge_definitions from anon;
revoke insert, update, delete on public.badge_definitions from authenticated;

-- Kazanılan rozetler artık katalogdaki bir koda bağlı olmalı
alter table public.user_badges
  add constraint user_badges_badge_code_fkey
  foreign key (badge_code) references public.badge_definitions (kod) on delete cascade;

-- ---------------------------------------------------------------------
-- 2. İlerleme hesabı (her rozet için öğrencinin şu anki değeri)
-- ---------------------------------------------------------------------
create or replace function public.badge_progress(p_student_id uuid)
returns table (badge_code text, ilerleme integer, deneme integer)
language sql
stable
security definer
set search_path = ''
as $$
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
      else 0
    end,
    case when d.kosul_turu = 'ders_basari' then coalesce((
        select sum(ua.deneme_sayisi)::integer
          from public.user_answers ua
          join public.questions q on q.id = ua.question_id
         where ua.student_id = p_student_id and q.ders = d.ders), 0)
    end
  from public.badge_definitions d;
$$;

-- ---------------------------------------------------------------------
-- 3. Rozetleri ver (şartı sağlayanları user_badges'e ekler)
-- ---------------------------------------------------------------------
create or replace function public.evaluate_badges(p_student_id uuid)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.user_badges (student_id, badge_code)
  select p_student_id, d.kod
    from public.badge_definitions d
    join public.badge_progress(p_student_id) p on p.badge_code = d.kod
   where p.ilerleme >= d.esik
     and (d.kosul_turu <> 'ders_basari' or p.deneme >= d.min_deneme)
  on conflict (student_id, badge_code) do nothing;
$$;

create or replace function public.badges_after_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.evaluate_badges(new.student_id);
  return new;
end;
$$;

-- Cevap kaydedilince (soru sayısı, ders başarısı) ...
create trigger user_answers_award_badges
  after insert or update on public.user_answers
  for each row execute function public.badges_after_change();

-- ... ve XP / seviye / seri değişince
create trigger student_stats_award_badges
  after update on public.student_stats
  for each row execute function public.badges_after_change();

revoke execute on function public.badge_progress(uuid)     from public, anon, authenticated;
revoke execute on function public.evaluate_badges(uuid)    from public, anon, authenticated;
revoke execute on function public.badges_after_change()    from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 4. Profil ekranı için veri: tüm rozetler + kazanıldı mı + ilerleme
--    Yalnızca öğrencinin kendisi veya velisi çağırabilir.
-- ---------------------------------------------------------------------
create or replace function public.get_student_badges(p_student_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null
     or not (v_uid = p_student_id or public.is_parent_of(p_student_id)) then
    raise exception 'Bu öğrencinin verilerine erişim yetkiniz yok' using errcode = '42501';
  end if;

  return coalesce((
    select jsonb_agg(
             jsonb_build_object(
               'kod', d.kod,
               'ad', d.ad,
               'aciklama', d.aciklama,
               'ikon', d.ikon,
               'kosul_turu', d.kosul_turu,
               'esik', d.esik,
               'ders', d.ders,
               'min_deneme', d.min_deneme,
               'kazanildi', ub.id is not null,
               'kazanma_tarihi', ub.earned_at,
               'ilerleme', p.ilerleme,
               'deneme', p.deneme
             )
             order by d.sira, d.kod)
      from public.badge_definitions d
      join public.badge_progress(p_student_id) p on p.badge_code = d.kod
      left join public.user_badges ub
             on ub.student_id = p_student_id and ub.badge_code = d.kod
  ), '[]'::jsonb);
end;
$$;

revoke execute on function public.get_student_badges(uuid) from public, anon;
grant  execute on function public.get_student_badges(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- 5. Başlangıç rozetleri
-- ---------------------------------------------------------------------
insert into public.badge_definitions
  (kod, ad, aciklama, ikon, kosul_turu, esik, ders, min_deneme, sira)
values
  ('ilk_soru',    'İlk Adım',            'İlk sorunu çöz.',                                            'flag',                  'soru_sayisi', 1,   null, 10, 10),
  ('soru_25',     'Çalışkan Arı',        '25 farklı soru çöz.',                                        'menu_book',             'soru_sayisi', 25,  null, 10, 20),
  ('soru_100',    'Soru Avcısı',         '100 farklı soru çöz.',                                       'track_changes',         'soru_sayisi', 100, null, 10, 30),
  ('streak_3',    'Isınma Turu',         '3 gün üst üste soru çöz.',                                   'local_fire_department', 'streak',      3,   null, 10, 40),
  ('streak_7',    'Alev Alev',           '7 gün üst üste soru çöz.',                                   'local_fire_department', 'streak',      7,   null, 10, 50),
  ('streak_30',   'Durdurulamaz',        '30 gün üst üste soru çöz.',                                  'whatshot',              'streak',      30,  null, 10, 60),
  ('xp_500',      'XP Koleksiyoncusu',   '500 XP topla.',                                              'bolt',                  'xp',          500, null, 10, 70),
  ('seviye_5',    'Yükselen Yıldız',     '5. seviyeye ulaş.',                                          'star',                  'seviye',      5,   null, 10, 80),
  ('seviye_10',   'Usta',                '10. seviyeye ulaş.',                                         'military_tech',         'seviye',      10,  null, 10, 90),
  ('matematik_90','Matematik Ustası',    'Matematik dersinde en az 10 soru çöz ve %90 başarı yakala.', 'calculate',             'ders_basari', 90,  'Matematik',     10, 100),
  ('turkce_90',   'Türkçe Ustası',       'Türkçe dersinde en az 10 soru çöz ve %90 başarı yakala.',    'translate',             'ders_basari', 90,  'Türkçe',        10, 110),
  ('fen_90',      'Fen Kaşifi',          'Fen Bilimleri dersinde en az 10 soru çöz ve %90 başarı yakala.', 'science',           'ders_basari', 90,  'Fen Bilimleri', 10, 120);

-- Mevcut öğrencilerin şimdiye kadarki başarıları için rozetleri hemen ver
select public.evaluate_badges(id) from public.profiles where role = 'ogrenci';
