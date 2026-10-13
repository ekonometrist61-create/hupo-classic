-- plans tablosuna opsiyonel deneme süresi kolonu (plan başına, günden önce ücretli süre)
alter table public.plans
  add column if not exists deneme_gun integer check (deneme_gun is null or deneme_gun >= 0);

-- list_active_plans: deneme_gun alanını ekle
create or replace function public.list_active_plans()
returns table (
  kod          text,
  ad           text,
  aciklama     text,
  fiyat_kurus  integer,
  sure_gun     integer,
  deneme_gun   integer
)
language sql
security definer
set search_path = ''
as $$
  select kod, ad, aciklama, fiyat_kurus, sure_gun, deneme_gun
  from   public.plans
  where  aktif = true
  order  by sira, kod;
$$;

-- admin_upsert_plan: deneme_gun parametresi eklendi
drop function if exists public.admin_upsert_plan(text, text, text, integer, integer, boolean, text);

create function public.admin_upsert_plan(
  p_kod          text,
  p_ad           text,
  p_aciklama     text,
  p_fiyat_kurus  integer,
  p_sure_gun     integer,
  p_aktif        boolean  default true,
  p_tip_kod      text     default 'premium',
  p_deneme_gun   integer  default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.require_admin();
  if p_kod is null or p_kod !~ '^[a-z0-9_]{2,30}$' then
    raise exception 'Plan kodu 2-30 karakter, küçük harf/rakam/alt çizgi olmalı' using errcode = '22023';
  end if;
  insert into public.plans (kod, ad, aciklama, fiyat_kurus, sure_gun, aktif, tip_kod, deneme_gun)
  values (p_kod, trim(p_ad), nullif(trim(coalesce(p_aciklama, '')), ''), p_fiyat_kurus, p_sure_gun,
          coalesce(p_aktif, true), coalesce(p_tip_kod, 'premium'), p_deneme_gun)
  on conflict (kod) do update
    set ad = excluded.ad, aciklama = excluded.aciklama, fiyat_kurus = excluded.fiyat_kurus,
        sure_gun = excluded.sure_gun, aktif = excluded.aktif, tip_kod = excluded.tip_kod,
        deneme_gun = excluded.deneme_gun;
  perform public.log_admin_action('plan_kaydedildi',
    jsonb_build_object('kod', p_kod, 'fiyat_kurus', p_fiyat_kurus, 'tip_kod', p_tip_kod,
                       'deneme_gun', p_deneme_gun));
end;
$$;

revoke execute on function public.admin_upsert_plan(text, text, text, integer, integer, boolean, text, integer) from public, anon;
grant  execute on function public.admin_upsert_plan(text, text, text, integer, integer, boolean, text, integer) to authenticated;
