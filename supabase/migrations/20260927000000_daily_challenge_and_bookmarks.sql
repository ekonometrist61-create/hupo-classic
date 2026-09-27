-- =====================================================================
--  Günün 5 Sorusu (Daily Challenge) + Kayıtlı Sorular (Bookmarks)
--  Bu migration canlı Supabase'ten birebir kurtarılmıştır.
--
--  Kaynak: ccozfrpnvyrnktpffkwo / pg_get_functiondef + information_schema
--  Tarih : 2026-09-27
--
--  NOT: Bu migration IDEMPOTENT yazıldı. Zaten canlıda varsa no-op olur.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Tablolar
-- ---------------------------------------------------------------------

create table if not exists public.daily_challenges (
  gun            date        not null,
  anahtar        text        not null,
  question_ids   uuid[]      not null,
  elle_secildi   boolean     not null default false,
  created_at     timestamptz not null default now(),

  constraint daily_challenges_pkey primary key (gun, anahtar),
  -- anahtar: hangi havuzdan soru seçildi (ilkokul|ortaokul|lise|hepsi|sinifN)
  constraint daily_challenges_anahtar_check
    check (anahtar ~ '^(ilkokul|ortaokul|lise|hepsi|sinif([1-9]|1[0-2]))$'),
  -- günde en fazla 10 soru
  constraint daily_challenges_question_ids_check
    check (cardinality(question_ids) >= 1 and cardinality(question_ids) <= 10)
);

comment on table public.daily_challenges is
  'Günlük soru havuzu. Yönetici admin_set_daily_challenge ile doldurur.';

create table if not exists public.daily_challenge_completions (
  user_id        uuid        not null,
  gun            date        not null,
  dogru_sayisi   integer     not null,
  bonus_xp       integer     not null,
  created_at     timestamptz not null default now(),

  constraint daily_challenge_completions_pkey primary key (user_id, gun),
  constraint daily_challenge_completions_dogru_sayisi_check check (dogru_sayisi >= 0),
  constraint daily_challenge_completions_bonus_xp_check      check (bonus_xp >= 0),
  constraint daily_challenge_completions_user_id_fkey
    foreign key (user_id) references public.profiles(id) on delete cascade
);

comment on table public.daily_challenge_completions is
  'Öğrencinin günlük 5 sorusunu tamamlama kaydı. Bir günde en fazla 1 kez.';

create table if not exists public.question_bookmarks (
  user_id        uuid        not null,
  question_id    uuid        not null,
  created_at     timestamptz not null default now(),

  constraint question_bookmarks_pkey primary key (user_id, question_id),
  constraint question_bookmarks_user_id_fkey
    foreign key (user_id) references auth.users(id) on delete cascade,
  constraint question_bookmarks_question_id_fkey
    foreign key (question_id) references public.questions(id) on delete cascade
);

comment on table public.question_bookmarks is
  'Öğrencinin yıldızladığı sorular. En fazla 200 kayıt.';

-- ---------------------------------------------------------------------
-- 2) RLS
--    daily_challenges / daily_challenge_completions: politika YOK.
--    Erişim sadece SECURITY DEFINER RPC'ler üzerinden. Bu bilinçli tasarım:
--    öğrenci doğrudan tabloyu okuyamaz, kurallar sunucuda uygulanır.
-- ---------------------------------------------------------------------

alter table public.daily_challenges            enable row level security;
alter table public.daily_challenge_completions enable row level security;
alter table public.question_bookmarks          enable row level security;

drop policy if exists question_bookmarks_select_own on public.question_bookmarks;
drop policy if exists question_bookmarks_insert_own on public.question_bookmarks;
drop policy if exists question_bookmarks_delete_own on public.question_bookmarks;

-- Yalnızca kendi kayıtlarını görebilir.
create policy question_bookmarks_select_own
  on public.question_bookmarks
  for select
  to authenticated
  using (user_id = (select auth.uid()));

-- Yalnızca kendi adına, yalnızca onaylı soru kaydedebilir.
create policy question_bookmarks_insert_own
  on public.question_bookmarks
  for insert
  to authenticated
  with check (
    user_id = (select auth.uid())
    and public.current_user_role() = 'ogrenci'
    and exists (
      select 1 from public.questions q
      where q.id = question_bookmarks.question_id
        and q.onay_durumu = 'onaylandi'
    )
  );

-- Yalnızca kendi kaydını silebilir.
create policy question_bookmarks_delete_own
  on public.question_bookmarks
  for delete
  to authenticated
  using (user_id = (select auth.uid()));

-- ---------------------------------------------------------------------
-- 3) Yardımcı fonksiyonlar (RPC'ler bunları kullanıyor)
-- ---------------------------------------------------------------------

-- Bugünün tarihi (Europe/Istanbul). Sunucu UTC'de olabilir.
create or replace function public._dc_bugun()
returns date
language sql
stable
set search_path to ''
as $$
  select (now() at time zone 'Europe/Istanbul')::date;
$$;

-- Günün soru havuzunu ve anahtarını döndürür.
-- p_anahtar: 'sinif5' gibi sınıf anahtarı, null ise genel anahtar.
-- Önceki sürümde parametre adı farklıydı; Postgres yeniden oluşturmayı reddeder.
drop function if exists public._dc_coz(date, smallint, boolean);
create or replace function public._dc_coz(p_gun date, p_sinif smallint, p_anahtar_gerekli boolean)
returns table (k_anahtar text, k_ids uuid[])
language plpgsql
stable
security definer
set search_path to ''
as $$
declare
  v_key text;
  v_ids uuid[];
begin
  -- Önce sınıfa özel havuz.
  if p_sinif is not null then
    select anahtar, question_ids into v_key, v_ids
      from public.daily_challenges
     where gun = p_gun and anahtar = 'sinif' || p_sinif::text
     limit 1;
       if found then
         return query select v_key, v_ids;
         return;
       end if;
    end if;

  -- Sonra genel havuzlar: önce 'hepsi', sonra 'ortaokul', 'ilkokul', 'lise'.
  if p_anahtar_gerekli then
    foreach v_key in array array['hepsi', 'ortaokul', 'ilkokul', 'lise'] loop
      select question_ids into v_ids
        from public.daily_challenges
       where gun = p_gun and anahtar = v_key
       limit 1;
      if found then
        return query select v_key, v_ids;
        return;
      end if;
    end loop;
    return;  -- havuz yok
  end if;

  -- p_anahtar_gerekli = false: anahtar şart değil, ne varsa onu kullan.
  select anahtar, question_ids into v_key, v_ids
    from public.daily_challenges
   where gun = p_gun
   order by case anahtar
              when 'hepsi'     then 0
              when 'ortaokul'   then 1
              when 'ilkokul'    then 2
              when 'lise'       then 3
              else 4
            end
   limit 1;
  if found then
    return query select v_key, v_ids;
  end if;
end;
$$;

-- Öğrencinin bu gün bu sorulardan kaç tanesini cevapladığı ve doğru sayısı.
-- SÜTUN ADLARI canlı şemadan alındı: user_answers.dogru_mu (dogru DEĞİL).
create or replace function public._dc_durum(p_uid uuid, p_gun date, p_ids uuid[])
returns table (cevaplanan integer, dogru integer)
language sql
stable
set search_path to ''
as $$
  select
    count(*)::integer,
    count(*) filter (where u.dogru_mu)::integer
  from public.user_answers u
  where u.student_id = p_uid
    and u.question_id = any (p_ids)
    and (u.son_cevap_tarihi at time zone 'Europe/Istanbul')::date = p_gun;
$$;

-- ---------------------------------------------------------------------
-- 4) Öğrenci RPC'leri (canlıdan birebir)
-- ---------------------------------------------------------------------

create or replace function public.get_daily_challenge()
returns jsonb
language plpgsql
security definer
set search_path to ''
as $$
declare
  v_uid     uuid := (select auth.uid());
  v_gun     date := public._dc_bugun();
  v_sinif   smallint;
  v_key     text;
  v_ids     uuid[];
  v_sorular jsonb;
  v_toplam  integer;
  v_cevapli uuid[];
  d         record;
  c         record;
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  if public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Günün 5 Sorusu yalnızca öğrenciler içindir' using errcode = '42501';
  end if;
  select sinif into v_sinif from public.profiles where id = v_uid;
  select z.k_anahtar, z.k_ids into v_key, v_ids from public._dc_coz(v_gun, v_sinif, true) z;
  if v_ids is null then
    return jsonb_build_object('gun', v_gun, 'mevcut', false, 'sorular', '[]'::jsonb,
      'toplam', 0, 'cevaplanan', 0, 'tamamlandi', false, 'dogru_sayisi', 0, 'bonus_xp', 0);
  end if;
  select coalesce(jsonb_agg(jsonb_build_object(
           'id', q.id, 'ders', q.ders, 'konu', q.konu, 'alt_konu', q.alt_konu,
           'zorluk', q.zorluk, 'soru_metni', q.soru_metni, 'siklar', q.siklar)
         order by t.ord), '[]'::jsonb),
         count(*)::integer
    into v_sorular, v_toplam
    from unnest(v_ids) with ordinality as t(qid, ord)
    join public.questions q on q.id = t.qid and q.onay_durumu = 'onaylandi';
  select * into d from public._dc_durum(v_uid, v_gun, v_ids);
  select coalesce(array_agg(question_id), '{}') into v_cevapli from public.user_answers
   where student_id = v_uid and question_id = any (v_ids)
     and (son_cevap_tarihi at time zone 'Europe/Istanbul')::date = v_gun;
  select * into c from public.daily_challenge_completions where user_id = v_uid and gun = v_gun;
  return jsonb_build_object(
    'gun', v_gun, 'mevcut', v_toplam > 0, 'anahtar', v_key, 'sorular', v_sorular, 'toplam', v_toplam,
    'cevaplanan', least(d.cevaplanan, v_toplam), 'cevaplanan_idler', to_jsonb(v_cevapli),
    'tamamlandi', c.user_id is not null,
    'dogru_sayisi', coalesce(c.dogru_sayisi, d.dogru),
    'bonus_xp', coalesce(c.bonus_xp, 0));
end;
$$;

create or replace function public.complete_daily_challenge()
returns jsonb
language plpgsql
security definer
set search_path to ''
as $$
declare
  v_uid    uuid := (select auth.uid());
  v_gun    date := public._dc_bugun();
  v_bonus  constant integer := 25;
  v_ids    uuid[];
  v_toplam integer;
  d        record;
  c        record;
  v_yeni   boolean := false;
  v_n      integer;
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  if public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Günün 5 Sorusu yalnızca öğrenciler içindir' using errcode = '42501';
  end if;
  select * into c from public.daily_challenge_completions where user_id = v_uid and gun = v_gun;
  if found then
    return jsonb_build_object('tamamlandi', true, 'yeni', false,
      'dogru_sayisi', c.dogru_sayisi, 'bonus_xp', c.bonus_xp);
  end if;
  select z.k_ids into v_ids
    from public._dc_coz(v_gun, (select sinif from public.profiles where id = v_uid), false) z;
  if v_ids is null then
    return jsonb_build_object('tamamlandi', false, 'yeni', false, 'dogru_sayisi', 0, 'bonus_xp', 0);
  end if;
  select count(*)::integer into v_toplam
    from public.questions where id = any (v_ids) and onay_durumu = 'onaylandi';
  select * into d from public._dc_durum(v_uid, v_gun, v_ids);
  if v_toplam = 0 or d.cevaplanan < v_toplam then
    return jsonb_build_object('tamamlandi', false, 'yeni', false,
      'dogru_sayisi', d.dogru, 'bonus_xp', 0);
  end if;
  insert into public.daily_challenge_completions (user_id, gun, dogru_sayisi, bonus_xp)
  values (v_uid, v_gun, d.dogru, v_bonus)
  on conflict (user_id, gun) do nothing;
  get diagnostics v_n = row_count;
  if v_n = 1 then
    v_yeni := true;
    insert into public.xp_events (student_id, xp) values (v_uid, v_bonus);
    update public.student_stats
       set xp = xp + v_bonus, level = ((xp + v_bonus) / 100) + 1
     where student_id = v_uid;
    insert into public.notifications (alici_id, tur, baslik, mesaj, ikon)
    values (v_uid, 'bilgi', 'Günün 5 Sorusu tamam!',
            format('Bugünkü 5 soruyu bitirdin, %s bonus XP kazandın. Yarın yeni sorular seni bekliyor!', v_bonus),
            'star');
  end if;
  return jsonb_build_object('tamamlandi', true, 'yeni', v_yeni,
    'dogru_sayisi', d.dogru, 'bonus_xp', v_bonus);
end;
$$;

create or replace function public.list_bookmarks()
returns table (
  question_id uuid,
  ders       text,
  konu       text,
  alt_konu   text,
  zorluk     smallint,
  soru_metni text,
  siklar     jsonb,
  created_at timestamptz
)
language sql
stable security definer
set search_path to ''
as $$
  select q.id, q.ders, q.konu, q.alt_konu, q.zorluk, q.soru_metni, q.siklar, b.created_at
    from public.question_bookmarks b
    join public.questions q on q.id = b.question_id
   where b.user_id = (select auth.uid())
     and q.onay_durumu = 'onaylandi'
   order by b.created_at desc
   limit 200;
$$;

create or replace function public.toggle_bookmark(p_question_id uuid)
returns boolean
language plpgsql
security definer
set search_path to ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_sayi integer;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Yalnızca öğrenciler soru kaydedebilir' using errcode = '42501';
  end if;
  delete from public.question_bookmarks
   where user_id = v_uid and question_id = p_question_id;
  if found then
    return false;
  end if;
  if not exists (select 1 from public.questions
                  where id = p_question_id and onay_durumu = 'onaylandi') then
    raise exception 'Soru bulunamadı' using errcode = 'P0002';
  end if;
  select count(*) into v_sayi from public.question_bookmarks where user_id = v_uid;
  if v_sayi >= 200 then
    raise exception 'En fazla 200 soru kaydedebilirsin' using errcode = 'P0403';
  end if;
  insert into public.question_bookmarks (user_id, question_id) values (v_uid, p_question_id);
  return true;
end;
$$;

-- ---------------------------------------------------------------------
-- 5) Yetki: anon'a AÇIK OLMAMALI
--    canlıda get_app_config dışında hepsi anon:false. Burada da korunur.
-- ---------------------------------------------------------------------

revoke execute on function public.get_daily_challenge()   from public, anon;
revoke execute on function public.complete_daily_challenge() from public, anon;
revoke execute on function public.list_bookmarks()        from public, anon;
revoke execute on function public.toggle_bookmark(uuid)  from public, anon;
revoke execute on function public._dc_bugun()             from public, anon;
revoke execute on function public._dc_coz(date, smallint, boolean) from public, anon;
revoke execute on function public._dc_durum(uuid, date, uuid[]) from public, anon;

grant execute on function public.get_daily_challenge()   to authenticated;
grant execute on function public.complete_daily_challenge() to authenticated;
grant execute on function public.list_bookmarks()        to authenticated;
grant execute on function public.toggle_bookmark(uuid)  to authenticated;

-- Yönetici fonksiyonu: canlıda mevcut, sadece service_role çağırmalı.
-- (gövde canlıdan alınabilir; parametreler: p_gun, p_question_ids, p_anahtar)
-- TODO(kurtarma): admin_set_daily_challenge gövdesi henüz alınmadı.
