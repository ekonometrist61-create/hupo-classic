-- =====================================================================
-- Ligler, profil ilerlemesi ve bildirim sistemi
--
--  * Ligler haftalıktır (Pazartesi 00:00 - Pazar 24:00, Europe/Istanbul).
--    Hafta sonunda yeterli XP toplayan bir üst lige çıkar. Düşme YOKTUR:
--    çocuklarda cezalandırıcı mekanik kullanmıyoruz.
--  * Sıralama ANONİMDİR: yalnızca "N kişi arasında K. sıradasın" bilgisi
--    döner, başka çocukların adı/verisi asla döndürülmez
--    (sosyal özellikler varsayılan olarak kapalıdır).
--  * Bildirimler sunucuda üretilir (rozet, seviye, lig); çocuk bildirim yazamaz.
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Haftanın başlangıcı (Pazartesi, İstanbul saatiyle)
-- ---------------------------------------------------------------------
create or replace function public.hafta_baslangic()
returns date
language sql
stable
set search_path = ''
as $$
  select date_trunc('week', now() at time zone 'Europe/Istanbul')::date;
$$;

-- ---------------------------------------------------------------------
-- 2. XP geçmişi (haftalık XP için)
-- ---------------------------------------------------------------------
create table public.xp_events (
  id          uuid primary key default gen_random_uuid(),
  student_id  uuid not null references public.profiles (id) on delete cascade,
  xp          integer not null check (xp > 0),
  created_at  timestamptz not null default now()
);

create index xp_events_student_time_idx
  on public.xp_events (student_id, created_at desc);

alter table public.xp_events enable row level security;

create policy "xp_events_select"
  on public.xp_events for select to authenticated
  using (student_id = (select auth.uid()) or public.is_parent_of(student_id));

revoke all on public.xp_events from anon;
revoke insert, update, delete on public.xp_events from authenticated;

-- ---------------------------------------------------------------------
-- 3. Lig kataloğu
-- ---------------------------------------------------------------------
create table public.leagues (
  kod          text primary key,
  ad           text not null,
  sira         integer not null unique,
  yukselme_xp  integer check (yukselme_xp > 0),   -- NULL = en üst lig
  renk         text not null,
  ikon         text not null default 'shield'
);

alter table public.leagues enable row level security;
create policy "leagues_select" on public.leagues for select to authenticated using (true);
revoke all on public.leagues from anon;
revoke insert, update, delete on public.leagues from authenticated;

insert into public.leagues (kod, ad, sira, yukselme_xp, renk, ikon) values
  ('bronz',  'Bronz Ligi',   1, 100, '#CD7F32', 'shield'),
  ('gumus',  'Gümüş Ligi',   2, 150, '#9AA5B1', 'shield'),
  ('altin',  'Altın Ligi',   3, 200, '#FFC533', 'shield'),
  ('zumrut', 'Zümrüt Ligi',  4, 250, '#22C58B', 'shield'),
  ('elmas',  'Elmas Ligi',   5, null, '#2FB8FF', 'diamond');

-- ---------------------------------------------------------------------
-- 4. student_stats: lig + en uzun seri
-- ---------------------------------------------------------------------
alter table public.student_stats
  add column if not exists lig text not null default 'bronz' references public.leagues (kod),
  add column if not exists lig_hafta date,
  add column if not exists en_uzun_seri integer not null default 0 check (en_uzun_seri >= 0);

update public.student_stats set en_uzun_seri = greatest(en_uzun_seri, streak_count);

-- ---------------------------------------------------------------------
-- 5. Bildirimler
-- ---------------------------------------------------------------------
create table public.notifications (
  id          uuid primary key default gen_random_uuid(),
  alici_id    uuid not null references public.profiles (id) on delete cascade,
  tur         text not null check (tur in ('rozet', 'seviye', 'lig', 'bilgi')),
  baslik      text not null,
  mesaj       text not null,
  ikon        text not null default 'notifications',
  okundu      boolean not null default false,
  created_at  timestamptz not null default now()
);

create index notifications_alici_time_idx
  on public.notifications (alici_id, created_at desc);
create index notifications_unread_idx
  on public.notifications (alici_id) where okundu = false;

alter table public.notifications enable row level security;

create policy "notifications_select_own"
  on public.notifications for select to authenticated
  using (alici_id = (select auth.uid()));

revoke all on public.notifications from anon;
revoke insert, update, delete on public.notifications from authenticated;

-- Okundu işaretleme: yalnızca kendi bildirimleri (p_ids NULL ise hepsi)
create or replace function public.mark_notifications_read(p_ids uuid[] default null)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_count integer;
begin
  if (select auth.uid()) is null then
    raise exception 'Oturum gerekli' using errcode = '42501';
  end if;

  update public.notifications
     set okundu = true
   where alici_id = (select auth.uid())
     and okundu = false
     and (p_ids is null or id = any (p_ids));
  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

revoke execute on function public.mark_notifications_read(uuid[]) from public, anon;
grant  execute on function public.mark_notifications_read(uuid[]) to authenticated;

-- Rozet kazanılınca
create or replace function public.notify_badge_earned()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  d record;
begin
  select ad, ikon into d from public.badge_definitions where kod = new.badge_code;
  insert into public.notifications (alici_id, tur, baslik, mesaj, ikon)
  values (
    new.student_id, 'rozet', 'Yeni rozet kazandın!',
    format('"%s" rozeti artık senin. Harikasın!', coalesce(d.ad, new.badge_code)),
    coalesce(d.ikon, 'star')
  );
  return new;
end;
$$;

create trigger user_badges_notify
  after insert on public.user_badges
  for each row execute function public.notify_badge_earned();

-- Seviye atlanınca
create or replace function public.notify_level_up()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.notifications (alici_id, tur, baslik, mesaj, ikon)
  values (
    new.student_id, 'seviye', 'Seviye atladın!',
    format('Artık Seviye %s! Böyle devam.', new.level),
    'emoji_events'
  );
  return new;
end;
$$;

create trigger student_stats_notify_level
  after update on public.student_stats
  for each row when (new.level > old.level)
  execute function public.notify_level_up();

revoke execute on function public.notify_badge_earned() from public, anon, authenticated;
revoke execute on function public.notify_level_up()     from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 6. Lig dönemini kapat: yeni haftaya geçildiyse geçen haftanın XP'sine bakıp yükselt
-- ---------------------------------------------------------------------
create or replace function public.resolve_league_week(p_student_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_bu_hafta  date := public.hafta_baslangic();
  s           record;
  v_xp        integer;
  v_yeni_kod  text;
  v_yeni_ad   text;
begin
  select lig, lig_hafta into s
    from public.student_stats
   where student_id = p_student_id
   for update;
  if not found then
    return;
  end if;

  if s.lig_hafta is null then
    update public.student_stats set lig_hafta = v_bu_hafta where student_id = p_student_id;
    return;
  end if;
  if s.lig_hafta >= v_bu_hafta then
    return;
  end if;

  -- Biten dönemin (lig_hafta ... +7 gün) toplam XP'si
  select coalesce(sum(xp), 0) into v_xp
    from public.xp_events
   where student_id = p_student_id
     and (created_at at time zone 'Europe/Istanbul')::date >= s.lig_hafta
     and (created_at at time zone 'Europe/Istanbul')::date <  s.lig_hafta + 7;

  -- Yeterliyse bir üst lige çık (düşme yok)
  select l2.kod, l2.ad into v_yeni_kod, v_yeni_ad
    from public.leagues l
    join public.leagues l2 on l2.sira = l.sira + 1
   where l.kod = s.lig
     and l.yukselme_xp is not null
     and v_xp >= l.yukselme_xp;

  update public.student_stats
     set lig = coalesce(v_yeni_kod, lig),
         lig_hafta = v_bu_hafta
   where student_id = p_student_id;

  if v_yeni_kod is not null then
    insert into public.notifications (alici_id, tur, baslik, mesaj, ikon)
    values (
      p_student_id, 'lig', 'Yeni lige yükseldin!',
      format('Tebrikler, artık %s içinde yarışıyorsun!', v_yeni_ad),
      'shield'
    );
  end if;
end;
$$;

revoke execute on function public.resolve_league_week(uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 7. XP / seri fonksiyonu: haftalık XP kaydı, en uzun seri, lig dönemi
-- ---------------------------------------------------------------------
create or replace function public.award_xp_and_streak(
  p_student_id  uuid,
  p_zorluk      smallint,
  p_xp_ver      boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_today  date := (now() at time zone 'Europe/Istanbul')::date;
  v_xp     integer;
  v_stats  public.student_stats%rowtype;
begin
  v_xp := case p_zorluk when 1 then 10 when 2 then 20 when 3 then 30 end;
  if v_xp is null then
    raise exception 'Geçersiz zorluk: % (1, 2 veya 3 olmalı)', p_zorluk using errcode = '22023';
  end if;
  if not p_xp_ver then
    v_xp := 0;
  end if;

  insert into public.student_stats (student_id) values (p_student_id)
  on conflict (student_id) do nothing;

  -- Yeni haftaya geçildiyse önce geçen haftanın ligini sonuçlandır
  perform public.resolve_league_week(p_student_id);

  if v_xp > 0 then
    insert into public.xp_events (student_id, xp) values (p_student_id, v_xp);
  end if;

  update public.student_stats
     set xp = xp + v_xp,
         level = ((xp + v_xp) / 100) + 1,           -- 100 XP = 1 seviye
         streak_count = case
           when last_active_date = v_today     then greatest(streak_count, 1)
           when last_active_date = v_today - 1 then streak_count + 1
           else 1
         end,
         last_active_date = v_today
   where student_id = p_student_id;

  update public.student_stats
     set en_uzun_seri = greatest(en_uzun_seri, streak_count)
   where student_id = p_student_id
  returning * into v_stats;

  if not found then
    raise exception 'Öğrenci istatistiği bulunamadı' using errcode = 'P0002';
  end if;

  return jsonb_build_object(
    'kazanilan_xp',     v_xp,
    'xp',               v_stats.xp,
    'level',            v_stats.level,
    'streak_count',     v_stats.streak_count,
    'last_active_date', v_stats.last_active_date
  );
end;
$$;

revoke execute on function public.award_xp_and_streak(uuid, smallint, boolean)
  from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 8. Profil ekranı verileri (öğrencinin kendisi veya velisi çağırabilir)
-- ---------------------------------------------------------------------

-- Lig durumu: anonim sıralama + haftanın kalan süresi
create or replace function public.get_league_status(p_student_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid       uuid := (select auth.uid());
  v_bu_hafta  date := public.hafta_baslangic();
  v_xp        integer;
  l           record;
  v_sira      integer;
  v_toplam    integer;
  v_bitis     timestamptz;
  v_sonraki   text;
begin
  if v_uid is null
     or not (v_uid = p_student_id or public.is_parent_of(p_student_id)) then
    raise exception 'Bu öğrencinin verilerine erişim yetkiniz yok' using errcode = '42501';
  end if;

  insert into public.student_stats (student_id) values (p_student_id)
  on conflict (student_id) do nothing;
  perform public.resolve_league_week(p_student_id);

  select l1.kod, l1.ad, l1.sira, l1.yukselme_xp, l1.renk, l1.ikon
    into l
    from public.student_stats s
    join public.leagues l1 on l1.kod = s.lig
   where s.student_id = p_student_id;

  select coalesce(sum(xp), 0) into v_xp
    from public.xp_events
   where student_id = p_student_id
     and (created_at at time zone 'Europe/Istanbul')::date >= v_bu_hafta;

  -- Anonim sıralama: aynı ligdeki öğrenciler arasında bu haftaki XP'ye göre
  with hafta as (
    select s.student_id,
           coalesce(sum(e.xp) filter (
             where (e.created_at at time zone 'Europe/Istanbul')::date >= v_bu_hafta), 0) as xp
      from public.student_stats s
      left join public.xp_events e on e.student_id = s.student_id
     where s.lig = l.kod
     group by s.student_id
  )
  select count(*)::integer,
         (count(*) filter (where hafta.xp > v_xp) + 1)::integer
    into v_toplam, v_sira
    from hafta;

  v_bitis := ((v_bu_hafta + 7)::timestamp) at time zone 'Europe/Istanbul';

  select ad into v_sonraki from public.leagues where sira = l.sira + 1;

  return jsonb_build_object(
    'kod',            l.kod,
    'ad',             l.ad,
    'sira_no',        l.sira,
    'renk',           l.renk,
    'ikon',           l.ikon,
    'sonraki_lig',    v_sonraki,
    'yukselme_xp',    l.yukselme_xp,
    'haftalik_xp',    v_xp,
    'sira',           v_sira,
    'toplam',         v_toplam,
    'kalan_saniye',   greatest(0, floor(extract(epoch from (v_bitis - now())))::integer)
  );
end;
$$;

-- Genel ilerleme: üyelik, toplamlar, ders bazlı ilerleme
create or replace function public.get_profile_overview(p_student_id uuid)
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

  return jsonb_build_object(
    'uye_tarihi', (select created_at from public.profiles where id = p_student_id),
    'toplam_soru', (
      select count(*)::integer from public.user_answers where student_id = p_student_id),
    'dogruluk', (
      select round(100.0 * sum(dogru_sayisi) / nullif(sum(deneme_sayisi), 0))::integer
        from public.user_answers where student_id = p_student_id),
    'en_uzun_seri', coalesce((
      select en_uzun_seri from public.student_stats where student_id = p_student_id), 0),
    'ders_ilerleme', coalesce((
      select jsonb_agg(to_jsonb(x) order by x.ders)
        from (
          select q.ders,
                 count(ua.id)::integer as cozulen,
                 count(*)::integer     as toplam,
                 coalesce(round(100.0 * sum(ua.dogru_sayisi)
                                / nullif(sum(ua.deneme_sayisi), 0)), 0)::integer as basari
            from public.questions q
            left join public.user_answers ua
                   on ua.question_id = q.id and ua.student_id = p_student_id
           where q.onay_durumu = 'onaylandi'
           group by q.ders
        ) x
    ), '[]'::jsonb)
  );
end;
$$;

revoke execute on function public.get_league_status(uuid)    from public, anon;
revoke execute on function public.get_profile_overview(uuid) from public, anon;
grant  execute on function public.get_league_status(uuid)    to authenticated;
grant  execute on function public.get_profile_overview(uuid) to authenticated;
