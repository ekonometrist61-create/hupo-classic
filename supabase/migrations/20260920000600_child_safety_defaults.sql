-- =====================================================================
-- Çocuk güvenliği varsayılanları
--   * profiles.sosyal_ozellikler_acik : sosyal özellikler (varsayılan KAPALI)
--   * profiles.arkadas_ekleme_acik    : arkadaş ekleme      (varsayılan KAPALI)
--   Bu iki ayarı yalnızca çocuğun VELİSİ (parent_id = auth.uid()) değiştirebilir;
--   çocuk kendi hesabında açamaz. Kayıt sırasında metadata ile de açılamaz
--   (handle_new_user yalnızca role ve full_name okur).
--   Arkadaş ekleme, sosyal özellikler kapalıyken açılamaz.
-- =====================================================================

set client_encoding = 'UTF8';

alter table public.profiles
  add column if not exists sosyal_ozellikler_acik boolean not null default false,
  add column if not exists arkadas_ekleme_acik    boolean not null default false;

comment on column public.profiles.sosyal_ozellikler_acik is
  'Sosyal özellikler. Varsayılan false; yalnızca çocuğun velisi değiştirebilir.';
comment on column public.profiles.arkadas_ekleme_acik is
  'Arkadaş ekleme. Varsayılan false; sosyal özellikler kapalıyken true olamaz.';

alter table public.profiles
  drop constraint if exists profiles_arkadas_requires_sosyal;
alter table public.profiles
  add constraint profiles_arkadas_requires_sosyal
  check (not arkadas_ekleme_acik or sosyal_ozellikler_acik);

-- Korumayı genişlet: id / role / parent_id değişmezliğine ek olarak,
-- sosyal ayarları yalnızca çocuğun velisi (veya service_role / SQL editörü) değiştirebilir.
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

    if (new.sosyal_ozellikler_acik is distinct from old.sosyal_ozellikler_acik
        or new.arkadas_ekleme_acik is distinct from old.arkadas_ekleme_acik)
       and old.parent_id is distinct from auth.uid() then
      raise exception 'Sosyal özellik ayarlarını yalnızca çocuğun velisi değiştirebilir'
        using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;
