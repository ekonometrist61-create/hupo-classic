-- =====================================================================
-- Fırsat Bulucu — İlk şema
-- Tablolar: profiles, questions, student_stats, user_answers, user_badges
-- Dosya kodlaması: UTF-8 (Türkçe karakterler: ç ğ ı i ö ş ü İ Ğ Ş Ç Ö Ü)
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 0. UTF-8 güvencesi
-- Veritabanı kodlaması oluşturma anında belirlenir ve sonradan değiştirilemez.
-- Supabase projeleri varsayılan olarak UTF8'dir; farklıysa migration'ı durdur.
-- ---------------------------------------------------------------------
do $$
begin
  if getdatabaseencoding() <> 'UTF8' then
    raise exception 'Veritabanı kodlaması UTF8 olmalı (mevcut: %)', getdatabaseencoding();
  end if;
end
$$;

-- ---------------------------------------------------------------------
-- 1. Yardımcı fonksiyonlar
-- ---------------------------------------------------------------------

-- updated_at otomatik güncelleme
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Türkçe arama normalizasyonu: İ/I/ı → i, ğ → g, ü → u, ş → s, ö → o, ç → c
-- (Postgres'in lower() fonksiyonu 'I' harfini locale'e göre 'ı' yapabildiği için
-- önce translate ile ASCII'ye indirgenir.)
create or replace function public.tr_normalize(p_text text)
returns text
language sql
immutable
parallel safe
set search_path = ''
as $$
  select lower(
    translate(coalesce(p_text, ''), 'İIıĞğÜüŞşÖöÇç', 'iiigguussoocc')
  );
$$;

-- ---------------------------------------------------------------------
-- 2. profiles
-- ---------------------------------------------------------------------
create table public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  role        text not null check (role in ('veli', 'ogrenci')),
  parent_id   uuid references public.profiles (id) on delete set null,
  full_name   text,
  username    text unique,
  sinif       smallint check (sinif between 1 and 12),
  okul        text,
  avatar_url  text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),

  constraint profiles_not_self_parent check (parent_id is null or parent_id <> id),
  -- Sadece öğrencinin bir velisi olabilir
  constraint profiles_parent_only_for_student check (role = 'ogrenci' or parent_id is null)
);

comment on table  public.profiles is 'Kullanıcı profilleri (veli ve öğrenci). auth.users ile 1-1.';
comment on column public.profiles.parent_id is 'Öğrenci ise bağlı olduğu velinin profiles.id değeri.';

create index profiles_parent_id_idx on public.profiles (parent_id) where parent_id is not null;
create index profiles_role_idx on public.profiles (role);

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- parent_id yalnızca 'veli' rolündeki bir profili gösterebilir
create or replace function public.profiles_validate_parent()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.parent_id is not null
     and not exists (
       select 1 from public.profiles p
       where p.id = new.parent_id and p.role = 'veli'
     ) then
    raise exception 'parent_id, rolü "veli" olan bir profili göstermelidir';
  end if;
  return new;
end;
$$;

create trigger profiles_validate_parent
  before insert or update of parent_id, role on public.profiles
  for each row execute function public.profiles_validate_parent();

-- İstemci (JWT'li kullanıcı) role / parent_id / id değiştiremez.
-- service_role ve SQL editörü (auth.uid() = null) serbesttir.
create or replace function public.profiles_guard_immutable()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if auth.uid() is not null then
    if new.id <> old.id
       or new.role <> old.role
       or new.parent_id is distinct from old.parent_id then
      raise exception 'role ve parent_id istemci tarafından değiştirilemez'
        using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;

create trigger profiles_guard_immutable
  before update on public.profiles
  for each row execute function public.profiles_guard_immutable();

-- RLS'te özyineleme olmaması için SECURITY DEFINER yardımcılar
create or replace function public.current_user_role()
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select role from public.profiles where id = (select auth.uid());
$$;

create or replace function public.is_parent_of(p_student_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = p_student_id and parent_id = (select auth.uid())
  );
$$;

create or replace function public.my_parent_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select parent_id from public.profiles where id = (select auth.uid());
$$;

-- Yeni auth kullanıcısı → profil (rol yalnızca 'veli' / 'ogrenci'; aksi halde 'ogrenci').
-- parent_id bilerek metadata'dan ALINMAZ: veli bağlama service_role ile yapılmalı.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_role text := coalesce(new.raw_user_meta_data ->> 'role', 'ogrenci');
begin
  if v_role not in ('veli', 'ogrenci') then
    v_role := 'ogrenci';
  end if;

  insert into public.profiles (id, role, full_name)
  values (new.id, v_role, new.raw_user_meta_data ->> 'full_name');

  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------
-- 3. questions
-- ---------------------------------------------------------------------
create table public.questions (
  id             uuid primary key default gen_random_uuid(),
  okul           text not null,                       -- ör. 'ilkokul', 'ortaokul', 'lise'
  ders           text not null,                       -- ör. 'Matematik'
  konu           text not null,
  alt_konu       text,
  zorluk         smallint not null check (zorluk between 1 and 3),
  soru_metni     text not null,
  siklar         jsonb not null,                      -- {"A": "...", "B": "...", ...}
  dogru_sik      text not null,                       -- siklar içindeki anahtar
  onay_durumu    text not null default 'beklemede'
                   check (onay_durumu in ('beklemede', 'onaylandi', 'reddedildi')),
  created_by     uuid references auth.users (id) on delete set null,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),

  -- Türkçe karakterlerden bağımsız, aksansız tam metin arama vektörü
  arama_vektoru  tsvector generated always as (
    to_tsvector(
      'simple',
      public.tr_normalize(
        ders || ' ' || konu || ' ' || coalesce(alt_konu, '') || ' ' || soru_metni
      )
    )
  ) stored,

  constraint questions_siklar_is_object check (jsonb_typeof(siklar) = 'object'),
  constraint questions_dogru_sik_in_siklar check (siklar ? dogru_sik)
);

comment on column public.questions.siklar is 'JSONB nesne: {"A":"metin","B":"metin",...}';
comment on column public.questions.zorluk is '1 = kolay, 2 = orta, 3 = zor';

create index questions_kategori_idx
  on public.questions (okul, ders, konu, alt_konu)
  where onay_durumu = 'onaylandi';
create index questions_zorluk_idx on public.questions (zorluk);
create index questions_onay_durumu_idx on public.questions (onay_durumu);
create index questions_arama_idx on public.questions using gin (arama_vektoru);

create trigger questions_set_updated_at
  before update on public.questions
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- 4. student_stats
-- ---------------------------------------------------------------------
create table public.student_stats (
  student_id        uuid primary key references public.profiles (id) on delete cascade,
  xp                integer not null default 0 check (xp >= 0),
  level             integer not null default 1 check (level >= 1),
  streak_count      integer not null default 0 check (streak_count >= 0),
  last_active_date  date,
  updated_at        timestamptz not null default now()
);

create trigger student_stats_set_updated_at
  before update on public.student_stats
  for each row execute function public.set_updated_at();

-- Öğrenci profili oluşunca istatistik satırını otomatik aç
create or replace function public.create_student_stats()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.role = 'ogrenci' then
    insert into public.student_stats (student_id) values (new.id)
    on conflict (student_id) do nothing;
  end if;
  return new;
end;
$$;

create trigger profiles_create_student_stats
  after insert on public.profiles
  for each row execute function public.create_student_stats();

-- ---------------------------------------------------------------------
-- 5. user_answers  (öğrenci × soru başına tek satır; SM-2 aralıklı tekrar durumu)
-- ---------------------------------------------------------------------
create table public.user_answers (
  id                     uuid primary key default gen_random_uuid(),
  student_id             uuid not null references public.profiles (id) on delete cascade,
  question_id            uuid not null references public.questions (id) on delete cascade,

  -- Son cevap
  secilen_sik            text not null,
  dogru_mu               boolean not null,
  son_sure_ms            integer check (son_sure_ms is null or son_sure_ms >= 0),
  son_cevap_tarihi       timestamptz not null default now(),

  -- Toplamlar
  deneme_sayisi          integer not null default 1 check (deneme_sayisi >= 1),
  dogru_sayisi           integer not null default 0 check (dogru_sayisi >= 0),

  -- Aralıklı tekrar (SM-2)
  ease_factor            numeric(4, 2) not null default 2.50 check (ease_factor >= 1.30),
  tekrar_sayisi          integer not null default 0 check (tekrar_sayisi >= 0),
  aralik_gun             integer not null default 0 check (aralik_gun >= 0),
  sonraki_tekrar_tarihi  timestamptz not null default now(),

  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now(),

  constraint user_answers_unique_pair unique (student_id, question_id),
  constraint user_answers_dogru_le_deneme check (dogru_sayisi <= deneme_sayisi)
);

comment on table public.user_answers is
  'Öğrenci-soru başına tek satır. Yazma yalnızca public.submit_answer() ile yapılır.';

create index user_answers_due_idx
  on public.user_answers (student_id, sonraki_tekrar_tarihi);
create index user_answers_question_idx on public.user_answers (question_id);

create trigger user_answers_set_updated_at
  before update on public.user_answers
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- 6. user_badges
-- ---------------------------------------------------------------------
create table public.user_badges (
  id          uuid primary key default gen_random_uuid(),
  student_id  uuid not null references public.profiles (id) on delete cascade,
  badge_code  text not null,                 -- ör. 'ilk_soru', 'streak_7'
  metadata    jsonb not null default '{}'::jsonb,
  earned_at   timestamptz not null default now(),

  constraint user_badges_unique unique (student_id, badge_code)
);

create index user_badges_student_idx on public.user_badges (student_id);

-- ---------------------------------------------------------------------
-- 7. submit_answer(): cevap kaydı + SM-2 + XP + streak (tek, hile-korumalı giriş noktası)
-- ---------------------------------------------------------------------
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
  v_today  date := (now() at time zone 'Europe/Istanbul')::date;
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
  v_xp     integer := 0;
  v_stats  public.student_stats%rowtype;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Yalnızca öğrenciler soru cevaplayabilir' using errcode = '42501';
  end if;

  select id, zorluk, dogru_sik, siklar
    into v_q
    from public.questions
   where id = p_question_id and onay_durumu = 'onaylandi';
  if not found then
    raise exception 'Soru bulunamadı' using errcode = 'P0002';
  end if;

  if p_secilen_sik is null or not (v_q.siklar ? p_secilen_sik) then
    raise exception 'Geçersiz şık' using errcode = '22023';
  end if;

  v_dogru := (p_secilen_sik = v_q.dogru_sik);

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

  -- XP yalnızca yeni veya zamanı gelmiş sorudaki doğru cevaba verilir (XP farming engeli)
  if v_dogru and v_due then
    v_xp := 10 * v_q.zorluk;
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

  -- İstatistikler: 100 XP = 1 seviye; art arda gün sayacı
  insert into public.student_stats (student_id) values (v_uid)
  on conflict (student_id) do nothing;

  update public.student_stats
     set xp = xp + v_xp,
         level = ((xp + v_xp) / 100) + 1,
         streak_count = case
           when last_active_date = v_today     then streak_count
           when last_active_date = v_today - 1 then streak_count + 1
           else 1
         end,
         last_active_date = v_today
   where student_id = v_uid
  returning * into v_stats;

  return jsonb_build_object(
    'dogru_mu',              v_dogru,
    'dogru_sik',             v_q.dogru_sik,
    'kazanilan_xp',          v_xp,
    'xp',                    v_stats.xp,
    'level',                 v_stats.level,
    'streak_count',          v_stats.streak_count,
    'sonraki_tekrar_tarihi', v_next
  );
end;
$$;

-- ---------------------------------------------------------------------
-- 8. Row Level Security
-- ---------------------------------------------------------------------
alter table public.profiles      enable row level security;
alter table public.questions     enable row level security;
alter table public.student_stats enable row level security;
alter table public.user_answers  enable row level security;
alter table public.user_badges   enable row level security;

-- profiles ------------------------------------------------------------
create policy "profiles_select_own"
  on public.profiles for select to authenticated
  using (id = (select auth.uid()));

create policy "profiles_select_children"
  on public.profiles for select to authenticated
  using (parent_id = (select auth.uid()));

create policy "profiles_select_own_parent"
  on public.profiles for select to authenticated
  using (id = public.my_parent_id());

create policy "profiles_update_own"
  on public.profiles for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

create policy "profiles_update_children"
  on public.profiles for update to authenticated
  using (parent_id = (select auth.uid()))
  with check (parent_id = (select auth.uid()));

-- INSERT/DELETE politikası yok: profil handle_new_user() ile açılır,
-- silme auth.users → ON DELETE CASCADE ile olur.

-- questions -----------------------------------------------------------
-- Giriş yapmış herkes yalnızca onaylı soruları okur.
-- Ekleme/güncelleme/onay işlemleri service_role ile yapılır (RLS'i atlar).
create policy "questions_select_approved"
  on public.questions for select to authenticated
  using (onay_durumu = 'onaylandi');

-- student_stats / user_answers / user_badges --------------------------
-- Öğrenci kendi kaydını, veli bağlı çocuklarının kaydını okur. Yazma yok.
create policy "student_stats_select"
  on public.student_stats for select to authenticated
  using (student_id = (select auth.uid()) or public.is_parent_of(student_id));

create policy "user_answers_select"
  on public.user_answers for select to authenticated
  using (student_id = (select auth.uid()) or public.is_parent_of(student_id));

create policy "user_badges_select"
  on public.user_badges for select to authenticated
  using (student_id = (select auth.uid()) or public.is_parent_of(student_id));

-- ---------------------------------------------------------------------
-- 9. Yetkiler (defense in depth)
-- ---------------------------------------------------------------------
revoke all on public.profiles, public.questions, public.student_stats,
              public.user_answers, public.user_badges from anon;

revoke insert, update, delete on public.questions, public.student_stats,
                                 public.user_answers, public.user_badges from authenticated;
revoke insert, delete on public.profiles from authenticated;

-- Trigger fonksiyonları doğrudan çağrılamaz
revoke execute on function public.handle_new_user()          from public, anon, authenticated;
revoke execute on function public.create_student_stats()     from public, anon, authenticated;
revoke execute on function public.profiles_validate_parent() from public, anon, authenticated;
revoke execute on function public.profiles_guard_immutable() from public, anon, authenticated;

-- RPC ve RLS yardımcıları yalnızca giriş yapmış kullanıcılara
revoke execute on function public.submit_answer(uuid, text, integer) from public, anon;
grant  execute on function public.submit_answer(uuid, text, integer) to authenticated;

revoke execute on function public.current_user_role() from public, anon;
revoke execute on function public.is_parent_of(uuid)  from public, anon;
revoke execute on function public.my_parent_id()      from public, anon;
grant  execute on function public.current_user_role() to authenticated;
grant  execute on function public.is_parent_of(uuid)  to authenticated;
grant  execute on function public.my_parent_id()      to authenticated;
