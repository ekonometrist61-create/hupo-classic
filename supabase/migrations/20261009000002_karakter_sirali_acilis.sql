set client_encoding = 'UTF8';

-- =====================================================================
--  Karakter sıralı açılış kuralı
--  Bir sınıftaki N. karakter, aynı sınıftaki (N-1). karakter
--  kazanılmadan açılamaz. karakter_sira = 1 her zaman açılabilir.
--  Önceki sürüm: 20260928000010_character_system.sql (evaluate_characters)
-- =====================================================================

create or replace function public.evaluate_characters(p_student_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_xp          integer;
  v_streak      integer;
  v_soru_sayisi integer;
  v_seviye      integer;
  v_ders_basari integer;
  r             record;
begin
  -- Öğrenci istatistiklerini çek (student_stats: badge sistemiyle aynı kaynak)
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

  -- Toplam doğru cevap sayısı
  select coalesce(sum(dogru_sayisi), 0)::integer
  into v_soru_sayisi
  from public.user_answers
  where student_id = p_student_id;

  -- Ustalaşılan ders sayısı: accuracy ≥ 80 % ve en az 20 soru
  select count(*)::integer
  into v_ders_basari
  from (
    select q.ders
    from public.user_answers ua
    join public.questions q on q.id = ua.question_id
    where ua.student_id = p_student_id
    group by q.ders
    having sum(ua.deneme_sayisi) >= 20
       and (sum(ua.dogru_sayisi)::float / sum(ua.deneme_sayisi)) >= 0.8
  ) t;

  -- Kazanılabilecek her karakter için kontrol et
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
$$;

revoke execute on function public.evaluate_characters(uuid) from public, anon;
grant  execute on function public.evaluate_characters(uuid) to authenticated;
