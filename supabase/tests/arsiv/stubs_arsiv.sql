-- Arşiv testleri için ek taklit: require_admin() (gerçek tanım 20260920000900'de).
-- kelime_evreni/stubs.sql üzerine, migration'lardan önce çalıştırılır.
create or replace function public.require_admin() returns void
language plpgsql security definer set search_path = '' as $$
begin
  if not public.is_admin() then
    raise exception 'Bu işlem yalnızca yönetici içindir.' using errcode = '42501';
  end if;
end $$;
