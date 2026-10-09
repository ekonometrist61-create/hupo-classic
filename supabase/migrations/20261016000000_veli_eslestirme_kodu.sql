-- =====================================================================
--  VELİ ↔ ÇOCUK EŞLEŞTİRME KODU
--  Proje : ccozfrpnvyrnktpffkwo — Öğrenci Hazırlık / Hupo
--  Tarih : 2026-10-16
--
--  SORUN:
--    profiles.parent_id yalnızca admin_link_child() (20260920000900) ile
--    atanabiliyordu. Veli, çocuğunu kendisi bağlayamıyordu.
--
--  ÇÖZÜM (onay akışı veliden başlar, çocuk kodu girerek onaylar — AGENTS §5.3):
--    1. Veli create_parent_link_code() ile 24 saat geçerli, tek kullanımlık,
--       6 karakterli bir kod üretir (veli başına tek aktif kod).
--    2. Çocuk (mobil veya web app) redeem_parent_link_code(kod) çağırır.
--       Yalnızca rolü 'ogrenci' ve parent_id'si boş olan hesap kullanabilir.
--    3. parent_id ataması, profiles_guard_immutable() içinde işlem-yerel
--       app.parent_link_rpc bayrağıyla izinlidir (app.grade_rpc ile aynı desen,
--       20260927000060). İstemci bayrağı REST üzerinden açamaz.
--    4. Kaba kuvvete karşı: öğrenci başına saatte en fazla 5 hatalı deneme.
--       Hatalı deneme exception yerine jsonb döner; böylece deneme kaydı
--       işlem geri alınırken silinmez.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Tablolar
-- ---------------------------------------------------------------------
create table public.parent_link_codes (
  kod                  text primary key
                         check (kod ~ '^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{6}$'),
  veli_id              uuid not null references public.profiles (id) on delete cascade,
  olusturuldu_at       timestamptz not null default now(),
  son_kullanma         timestamptz not null,
  kullanildi_at        timestamptz,
  kullanan_ogrenci_id  uuid references public.profiles (id) on delete set null
);

comment on table public.parent_link_codes is
  'Velinin çocuğunu bağlamak için ürettiği tek kullanımlık kodlar. Yalnızca RPC ile yazılır.';

create index parent_link_codes_veli_idx on public.parent_link_codes (veli_id);

alter table public.parent_link_codes enable row level security;

-- Veli yalnızca kendi kodlarını görür; yazma yalnızca RPC üzerinden.
create policy parent_link_codes_select_own
  on public.parent_link_codes for select
  to authenticated
  using (veli_id = (select auth.uid()));

revoke all on public.parent_link_codes from public, anon, authenticated;
grant  select on public.parent_link_codes to authenticated;

create table public.parent_link_attempts (
  id          bigint generated always as identity primary key,
  ogrenci_id  uuid not null references public.profiles (id) on delete cascade,
  denendi_at  timestamptz not null default now()
);

comment on table public.parent_link_attempts is
  'Hatalı eşleştirme kodu denemeleri (hız sınırı için). İstemciye kapalı.';

create index parent_link_attempts_ogrenci_idx
  on public.parent_link_attempts (ogrenci_id, denendi_at);

alter table public.parent_link_attempts enable row level security;
-- Politika yok: yalnızca security definer RPC erişir.
revoke all on public.parent_link_attempts from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. Koruma tetikleyicisi: eşleştirme bayrağı eklenir
--    (20260927000060'taki dört kural AYNEN korunur)
-- ---------------------------------------------------------------------
create or replace function public.profiles_guard_immutable()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if auth.uid() is not null and not public.is_admin() then
    if new.id <> old.id or new.role <> old.role then
      raise exception 'role istemci tarafından değiştirilemez' using errcode = '42501';
    end if;

    if new.parent_id is distinct from old.parent_id
       and not (new.parent_id is null and old.parent_id = auth.uid())
       -- EŞLEŞTİRME EKİ: yalnızca redeem_parent_link_code() içinden,
       -- yalnızca boş parent_id doldurulurken.
       and not (old.parent_id is null
                and new.parent_id is not null
                and coalesce(current_setting('app.parent_link_rpc', true), '') = 'on') then
      raise exception 'parent_id istemci tarafından değiştirilemez' using errcode = '42501';
    end if;

    if (new.sosyal_ozellikler_acik is distinct from old.sosyal_ozellikler_acik
        or new.arkadas_ekleme_acik is distinct from old.arkadas_ekleme_acik)
       and old.parent_id is distinct from auth.uid() then
      raise exception 'Sosyal özellik ayarlarını yalnızca çocuğun velisi değiştirebilir'
        using errcode = '42501';
    end if;

    if new.sinif is distinct from old.sinif
       and coalesce(current_setting('app.grade_rpc', true), '') <> 'on' then
      raise exception 'Sınıf yalnızca sınıf değiştirme ekranından güncellenebilir'
        using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;

comment on function public.profiles_guard_immutable() is
  'profiles tablosunda id/role/parent_id/sosyal ayarlar ve sinif alanlarını istemciye karşı korur. '
  'sinif yalnızca _sinif_yaz() (app.grade_rpc), boş parent_id yalnızca '
  'redeem_parent_link_code() (app.parent_link_rpc) üzerinden yazılabilir.';

revoke execute on function public.profiles_guard_immutable() from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 3. Veli: kod üret
-- ---------------------------------------------------------------------
create or replace function public.create_parent_link_code()
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid      uuid := auth.uid();
  v_alfabe   constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';  -- 32 karakter, 0/O/1/I yok
  v_kod      text;
  v_bayt     bytea;
  v_son      timestamptz := now() + interval '24 hours';
  v_deneme   integer := 0;
  i          integer;
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı' using errcode = '42501';
  end if;
  if not exists (select 1 from public.profiles where id = v_uid and role = 'veli') then
    raise exception 'Eşleştirme kodunu yalnızca veli hesabı oluşturabilir' using errcode = '42501';
  end if;

  -- Veli başına tek aktif kod: kullanılmamış eski kodlar silinir.
  delete from public.parent_link_codes
   where veli_id = v_uid and kullanildi_at is null;

  loop
    v_deneme := v_deneme + 1;
    -- gen_random_uuid() güçlü rastgelelik kullanır; 256 mod 32 = 0 → yanlılık yok.
    v_bayt := uuid_send(gen_random_uuid());
    v_kod := '';
    for i in 0..5 loop
      v_kod := v_kod || substr(v_alfabe, (get_byte(v_bayt, i) % 32) + 1, 1);
    end loop;

    begin
      insert into public.parent_link_codes (kod, veli_id, son_kullanma)
      values (v_kod, v_uid, v_son);
      exit;
    exception when unique_violation then
      if v_deneme >= 10 then
        raise exception 'Kod üretilemedi, birazdan tekrar dene' using errcode = 'P0001';
      end if;
    end;
  end loop;

  return jsonb_build_object('kod', v_kod, 'son_kullanma', v_son);
end;
$$;

revoke execute on function public.create_parent_link_code() from public, anon;
grant  execute on function public.create_parent_link_code() to authenticated;

-- ---------------------------------------------------------------------
-- 4. Öğrenci: kodu kullan
--    Dönüş: {durum: 'baglandi', veli_ad} | {durum: 'gecersiz'} | {durum: 'cok_deneme'}
-- ---------------------------------------------------------------------
create or replace function public.redeem_parent_link_code(p_kod text)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid      uuid := auth.uid();
  v_role     text;
  v_parent   uuid;
  v_kod      text := upper(regexp_replace(coalesce(p_kod, ''), '[\s-]', '', 'g'));
  v_kayit    public.parent_link_codes%rowtype;
  v_veli_ad  text;
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı' using errcode = '42501';
  end if;

  select role, parent_id into v_role, v_parent
    from public.profiles where id = v_uid;

  if v_role is distinct from 'ogrenci' then
    raise exception 'Bu kod yalnızca öğrenci hesabıyla kullanılabilir' using errcode = '42501';
  end if;
  if v_parent is not null then
    raise exception 'Hesabın zaten bir veliye bağlı' using errcode = 'P0001';
  end if;

  -- Hız sınırı: son 1 saatte 5 hatalı deneme
  if (select count(*) from public.parent_link_attempts
       where ogrenci_id = v_uid and denendi_at > now() - interval '1 hour') >= 5 then
    return jsonb_build_object('durum', 'cok_deneme');
  end if;

  select * into v_kayit
    from public.parent_link_codes
   where kod = v_kod
     and kullanildi_at is null
     and son_kullanma > now()
   for update;

  if not found then
    insert into public.parent_link_attempts (ogrenci_id) values (v_uid);
    return jsonb_build_object('durum', 'gecersiz');
  end if;

  perform set_config('app.parent_link_rpc', 'on', true);
  update public.profiles set parent_id = v_kayit.veli_id where id = v_uid;
  perform set_config('app.parent_link_rpc', 'off', true);

  update public.parent_link_codes
     set kullanildi_at = now(), kullanan_ogrenci_id = v_uid
   where kod = v_kayit.kod;

  delete from public.parent_link_attempts where ogrenci_id = v_uid;

  select full_name into v_veli_ad from public.profiles where id = v_kayit.veli_id;

  return jsonb_build_object('durum', 'baglandi', 'veli_ad', v_veli_ad);
end;
$$;

revoke execute on function public.redeem_parent_link_code(text) from public, anon;
grant  execute on function public.redeem_parent_link_code(text) to authenticated;
