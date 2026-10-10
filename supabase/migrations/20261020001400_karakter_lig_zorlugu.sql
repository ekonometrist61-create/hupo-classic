-- =====================================================================
-- Karakter açılma zorluğu: lige göre artan çarpan.
--   Taban eşikler (kosul_deger) Bronz ligi için geçerlidir. Öğrencinin
--   güncel ligindeki çarpanla çarpılıp yukarı yuvarlanır:
--     Bronz 1.00 · Gümüş 1.25 · Altın 1.50 · Zümrüt 1.75 · Elmas 2.00
--   Baslangic karakteri her zaman açıktır.
--   Zihin Ustaları seviye eşikleri 1-5'ten 3-15'e yükseltildi (eskiden seviye 1 herkese açıktı).
--   Test verisi olduğu için mevcut kazanımlar sıfırlanıp yeni kurala göre yeniden hesaplanır.
-- =====================================================================

create table if not exists public.karakter_lig_carpanlari (
  lig_kod text primary key references public.leagues (kod) on delete cascade,
  carpan  numeric(4, 2) not null check (carpan >= 1)
);

alter table public.karakter_lig_carpanlari enable row level security;
revoke all on table public.karakter_lig_carpanlari from public, anon, authenticated;

insert into public.karakter_lig_carpanlari (lig_kod, carpan) values
  ('bronz', 1.00), ('gumus', 1.25), ('altin', 1.50), ('zumrut', 1.75), ('elmas', 2.00)
on conflict (lig_kod) do update set carpan = excluded.carpan;

update public.character_definitions set kosul_deger = 3  where kod = 'fikir_kivilcimi';
update public.character_definitions set kosul_deger = 5  where kod = 'bilgi_avcisi';
update public.character_definitions set kosul_deger = 8  where kod = 'bulmaca_ustasi';
update public.character_definitions set kosul_deger = 11 where kod = 'akil_ustasi';
update public.character_definitions set kosul_deger = 15 where kod = 'zihin_simsegi';

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
  v_lig         text;
  v_carpan      numeric;
  v_esik        integer;
  r             record;
begin
  select coalesce(xp, 0), coalesce(streak_count, 0), coalesce(level, 1), coalesce(lig, 'bronz')
    into v_xp, v_streak, v_seviye, v_lig
    from public.student_stats
   where student_id = p_student_id;

  v_xp     := coalesce(v_xp, 0);
  v_streak := coalesce(v_streak, 0);
  v_seviye := coalesce(v_seviye, 1);
  v_lig    := coalesce(v_lig, 'bronz');

  select coalesce(max(k.carpan), 1) into v_carpan
    from public.karakter_lig_carpanlari k
   where k.lig_kod = v_lig;

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
    v_esik := case when r.kosul_turu = 'baslangic' then 0
                   else ceil(r.kosul_deger * v_carpan)::integer end;

    if (r.kosul_turu = 'baslangic') or
       (r.kosul_turu = 'xp'          and v_xp          >= v_esik) or
       (r.kosul_turu = 'streak'      and v_streak      >= v_esik) or
       (r.kosul_turu = 'soru_sayisi' and v_soru_sayisi >= v_esik) or
       (r.kosul_turu = 'seviye'      and v_seviye      >= v_esik) or
       (r.kosul_turu = 'ders_basari' and v_ders_basari >= v_esik)
    then
      insert into public.user_characters (student_id, karakter_kod)
      values (p_student_id, r.kod)
      on conflict do nothing;
    end if;
  end loop;
end;
$$;

revoke execute on function public.evaluate_characters(uuid) from public, anon, authenticated;

create or replace function public.get_my_characters()
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid   uuid := auth.uid();
  v_carpan numeric := 1;
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı';
  end if;

  select coalesce(max(k.carpan), 1) into v_carpan
    from public.karakter_lig_carpanlari k
    join public.student_stats s on s.lig = k.lig_kod
   where s.student_id = v_uid;

  return (
    select jsonb_agg(
      jsonb_build_object(
        'kod',          cd.kod,
        'ad',           cd.ad,
        'aciklama',     cd.aciklama,
        'ikon',         cd.ikon,
        'sinif',        cd.sinif,
        'sinif_sira',   cd.sinif_sira,
        'karakter_sira',cd.karakter_sira,
        'kosul_turu',   cd.kosul_turu,
        'kosul_deger',  case when cd.kosul_turu = 'baslangic' then 0
                             else ceil(cd.kosul_deger * coalesce(v_carpan, 1))::integer end,
        'kazanildi',    (uc.karakter_kod is not null),
        'kazanildi_at', uc.kazanildi_at
      ) order by cd.sinif_sira, cd.karakter_sira
    )
    from public.character_definitions cd
    left join public.user_characters uc
      on uc.karakter_kod = cd.kod and uc.student_id = v_uid
  );
end;
$$;

revoke execute on function public.get_my_characters() from public, anon;
grant  execute on function public.get_my_characters() to authenticated;

-- Test verisi: mevcut kazanımları sıfırla ve yeni kuralla yeniden değerlendir.
delete from public.user_characters;

do $$
declare
  s record;
begin
  for s in select id from public.profiles where role = 'ogrenci' loop
    perform public.evaluate_characters(s.id);
  end loop;
end
$$;
