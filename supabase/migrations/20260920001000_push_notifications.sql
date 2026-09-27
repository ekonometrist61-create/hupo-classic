-- =====================================================================
-- Push bildirimleri (FCM) altyapısı
--
--  * Push VARSAYILAN OLARAK KAPALIDIR (opt-in). Çocuk hesabı için ayrıca velinin
--    açık rızası (consents: veli_acik_riza) gerekir; rıza geri çekilirse push hemen durur.
--  * Sessiz saatler (varsayılan 20:00-08:00, Europe/Istanbul): bu aralıkta push GÖNDERİLMEZ
--    (ertelenmez, kuyruğa alınmaz). Bildirim yine uygulama içi kutuda görünür.
--  * Push içeriği yalnızca zaten uygulama içi bildirimde olan başlık/mesajdır;
--    ad, soyad gibi kişisel veri taşımaz.
--  * Cihaz jetonları (FCM token) yalnızca sahibi tarafından yönetilir.
--  * Gönderim: notifications'a satır eklenince (izin varsa) push_outbox'a satır düşer;
--    Supabase Database Webhook bu tabloya bağlanıp "send-push" Edge Function'ı çağırır.
--    Function service_role ile push_targets() üzerinden gönderilecek jetonları alır.
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Cihaz jetonları
-- ---------------------------------------------------------------------
create table public.device_tokens (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.profiles (id) on delete cascade,
  token       text not null unique check (length(token) between 20 and 4096),
  platform    text not null check (platform in ('android', 'ios')),
  created_at  timestamptz not null default now(),
  last_seen   timestamptz not null default now()
);

create index device_tokens_user_idx on public.device_tokens (user_id);

alter table public.device_tokens enable row level security;

-- Kullanıcı yalnızca kendi satırlarını görür ve siler. Ekleme/güncelleme RPC ile yapılır
-- (aynı jeton başka hesaba geçebilir: paylaşılan cihazda hesap değişimi).
create policy "device_tokens_select_own"
  on public.device_tokens for select to authenticated
  using (user_id = (select auth.uid()));

create policy "device_tokens_delete_own"
  on public.device_tokens for delete to authenticated
  using (user_id = (select auth.uid()));

revoke all on public.device_tokens from anon;
revoke insert, update on public.device_tokens from authenticated;

-- ---------------------------------------------------------------------
-- 2. Push tercihleri (sunucu tarafı; varsayılan KAPALI)
-- ---------------------------------------------------------------------
create table public.push_preferences (
  user_id       uuid primary key references public.profiles (id) on delete cascade,
  push_enabled  boolean not null default false,
  quiet_start   time not null default '20:00',
  quiet_end     time not null default '08:00',
  updated_at    timestamptz not null default now()
);

alter table public.push_preferences enable row level security;

create policy "push_preferences_select_own"
  on public.push_preferences for select to authenticated
  using (user_id = (select auth.uid()));

-- Yazma yalnızca set_push_preference() üzerinden (rıza kontrolü orada)
revoke all on public.push_preferences from anon;
revoke insert, update, delete on public.push_preferences from authenticated;

-- ---------------------------------------------------------------------
-- 3. Yardımcı fonksiyonlar
-- ---------------------------------------------------------------------

-- Sessiz saat mi? Başlangıç > bitiş ise gece yarısını aşar (20:00-08:00).
-- Başlangıç = bitiş ise sessiz saat yoktur. Saat dilimi: Europe/Istanbul.
create or replace function public.push_in_quiet_hours(
  p_start  time,
  p_end    time,
  p_at     timestamptz default now()
)
returns boolean
language sql
stable
set search_path = ''
as $$
  select case
    when p_start = p_end then false
    when p_start < p_end then
      (p_at at time zone 'Europe/Istanbul')::time >= p_start
      and (p_at at time zone 'Europe/Istanbul')::time < p_end
    else
      (p_at at time zone 'Europe/Istanbul')::time >= p_start
      or (p_at at time zone 'Europe/Istanbul')::time < p_end
  end;
$$;

-- Bu kullanıcı için rıza koşulu sağlanıyor mu?
--   veli   : evet (kendi hesabı)
--   öğrenci: bir velisi VAR ve en son veli kaydı "veli_acik_riza" (geri çekilmemiş)
create or replace function public.push_consent_ok(p_user_id uuid)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_role   text;
  v_parent uuid;
  v_last   text;
begin
  select role, parent_id into v_role, v_parent from public.profiles where id = p_user_id;
  if not found then
    return false;
  end if;
  if v_role = 'veli' then
    return true;
  end if;
  if v_parent is null then
    return false;
  end if;

  select tur into v_last
    from public.consents
   where cocuk_id = p_user_id and tur in ('veli_acik_riza', 'veli_riza_geri_cekildi')
   order by created_at desc, id desc
   limit 1;

  return coalesce(v_last = 'veli_acik_riza', false);
end;
$$;

-- ---------------------------------------------------------------------
-- 4. İstemci RPC'leri
-- ---------------------------------------------------------------------

create or replace function public.register_device_token(p_token text, p_platform text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then
    raise exception 'Oturum gerekli' using errcode = '42501';
  end if;
  if p_token is null or length(p_token) < 20 or length(p_token) > 4096 then
    raise exception 'Geçersiz jeton' using errcode = '22023';
  end if;
  if p_platform is null or p_platform not in ('android', 'ios') then
    raise exception 'Platform android veya ios olmalı' using errcode = '22023';
  end if;

  insert into public.device_tokens (user_id, token, platform)
  values (v_uid, p_token, p_platform)
  on conflict (token) do update
    set user_id = excluded.user_id,
        platform = excluded.platform,
        last_seen = now();
end;
$$;

-- Yalnızca kendi jetonunu siler (başkasının jetonu için sessizce 0 satır)
create or replace function public.unregister_device_token(p_token text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then
    raise exception 'Oturum gerekli' using errcode = '42501';
  end if;
  delete from public.device_tokens where token = p_token and user_id = v_uid;
end;
$$;

-- Tercihi aç/kapat. Kapatmak her zaman serbesttir. Çocuk için açmak veli rızası ister.
create or replace function public.set_push_preference(
  p_enabled      boolean,
  p_quiet_start  time default null,
  p_quiet_end    time default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then
    raise exception 'Oturum gerekli' using errcode = '42501';
  end if;
  if p_enabled is null then
    raise exception 'Tercih gerekli' using errcode = '22023';
  end if;
  if p_enabled and not public.push_consent_ok(v_uid) then
    raise exception 'Bildirimleri açmak için velinin onayı gerekiyor' using errcode = '42501';
  end if;

  insert into public.push_preferences (user_id, push_enabled, quiet_start, quiet_end)
  values (v_uid, p_enabled, coalesce(p_quiet_start, '20:00'), coalesce(p_quiet_end, '08:00'))
  on conflict (user_id) do update
    set push_enabled = excluded.push_enabled,
        quiet_start  = coalesce(p_quiet_start, public.push_preferences.quiet_start),
        quiet_end    = coalesce(p_quiet_end, public.push_preferences.quiet_end),
        updated_at   = now();

  return public.get_push_preference();
end;
$$;

create or replace function public.get_push_preference()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid      uuid := (select auth.uid());
  r          public.push_preferences%rowtype;
  v_consent  boolean;
begin
  if v_uid is null then
    raise exception 'Oturum gerekli' using errcode = '42501';
  end if;
  select * into r from public.push_preferences where user_id = v_uid;
  v_consent := public.push_consent_ok(v_uid);

  return jsonb_build_object(
    'push_enabled',        coalesce(r.push_enabled, false) and v_consent,
    'quiet_start',         to_char(coalesce(r.quiet_start, '20:00'::time), 'HH24:MI'),
    'quiet_end',           to_char(coalesce(r.quiet_end, '08:00'::time), 'HH24:MI'),
    'veli_onayi_gerekli',  not v_consent
  );
end;
$$;

-- ---------------------------------------------------------------------
-- 5. Rıza geri çekilince push kapanır
-- ---------------------------------------------------------------------
create or replace function public.push_disable_on_consent_withdrawn()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.tur = 'veli_riza_geri_cekildi' then
    update public.push_preferences set push_enabled = false, updated_at = now()
     where user_id = new.cocuk_id and push_enabled;
  end if;
  return new;
end;
$$;

create trigger consents_disable_push
  after insert on public.consents
  for each row execute function public.push_disable_on_consent_withdrawn();

-- ---------------------------------------------------------------------
-- 6. Gönderim kuyruğu
-- ---------------------------------------------------------------------
create table public.push_outbox (
  id               uuid primary key default gen_random_uuid(),
  notification_id  uuid not null references public.notifications (id) on delete cascade,
  user_id          uuid not null references public.profiles (id) on delete cascade,
  status           text not null default 'pending'
                     check (status in ('pending', 'sending', 'sent', 'failed', 'skipped')),
  attempts         integer not null default 0,
  last_error       text,
  created_at       timestamptz not null default now(),
  sent_at          timestamptz
);

create index push_outbox_status_idx on public.push_outbox (status, created_at);

-- Yalnızca service_role erişir (RLS açık, politika yok + yetkiler geri alınır)
alter table public.push_outbox enable row level security;
revoke all on public.push_outbox from anon, authenticated;

-- Kullanıcı push alabilir mi? (opt-in + rıza + sessiz saat dışı)
create or replace function public.push_allowed_now(p_user_id uuid, p_at timestamptz default now())
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  r public.push_preferences%rowtype;
begin
  select * into r from public.push_preferences where user_id = p_user_id;
  if not found or not r.push_enabled then
    return false;
  end if;
  if not public.push_consent_ok(p_user_id) then
    return false;
  end if;
  return not public.push_in_quiet_hours(r.quiet_start, r.quiet_end, p_at);
end;
$$;

-- notifications'a satır eklenince: izin varsa kuyruğa yaz
create or replace function public.enqueue_push()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if public.push_allowed_now(new.alici_id) then
    insert into public.push_outbox (notification_id, user_id) values (new.id, new.alici_id);
  end if;
  return new;
end;
$$;

create trigger notifications_enqueue_push
  after insert on public.notifications
  for each row execute function public.enqueue_push();

-- Edge Function için: gönderim anında koşulları TEKRAR uygular ve jetonları döner
create or replace function public.push_targets(p_notification_id uuid)
returns table (
  notification_id  uuid,
  user_id          uuid,
  token            text,
  platform         text,
  baslik           text,
  mesaj            text,
  tur              text
)
language sql
stable
security definer
set search_path = ''
as $$
  select n.id, n.alici_id, d.token, d.platform, n.baslik, n.mesaj, n.tur
    from public.notifications n
    join public.device_tokens d on d.user_id = n.alici_id
   where n.id = p_notification_id
     and public.push_allowed_now(n.alici_id);
$$;

-- ---------------------------------------------------------------------
-- 7. Yetkiler
-- ---------------------------------------------------------------------
revoke execute on function public.register_device_token(text, text)       from public, anon;
revoke execute on function public.unregister_device_token(text)           from public, anon;
revoke execute on function public.set_push_preference(boolean, time, time) from public, anon;
revoke execute on function public.get_push_preference()                   from public, anon;
grant  execute on function public.register_device_token(text, text)       to authenticated;
grant  execute on function public.unregister_device_token(text)           to authenticated;
grant  execute on function public.set_push_preference(boolean, time, time) to authenticated;
grant  execute on function public.get_push_preference()                   to authenticated;

-- İç fonksiyonlar: istemci doğrudan çağıramaz
revoke execute on function public.push_in_quiet_hours(time, time, timestamptz) from public, anon, authenticated;
revoke execute on function public.push_consent_ok(uuid)                       from public, anon, authenticated;
revoke execute on function public.push_allowed_now(uuid, timestamptz)         from public, anon, authenticated;
revoke execute on function public.enqueue_push()                              from public, anon, authenticated;
revoke execute on function public.push_disable_on_consent_withdrawn()         from public, anon, authenticated;
revoke execute on function public.push_targets(uuid)                          from public, anon, authenticated;
grant  execute on function public.push_targets(uuid)                          to service_role;
