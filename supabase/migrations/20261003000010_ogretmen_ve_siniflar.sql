-- =====================================================================
-- Öğretmen rolü ve sınıf yönetimi
--
-- 1. profiles.role kısıtına 'ogretmen' eklendi
-- 2. siniflar tablosu: öğretmen-sınıf eşleşmesi
-- 3. sinif_uyelikleri tablosu: öğrenci-sınıf üyeliği
-- 4. Admin RPC'leri: admin_list_siniflar, admin_upsert_sinif
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Öğretmen rolü
-- ---------------------------------------------------------------------
alter table public.profiles drop constraint if exists profiles_role_check;
alter table public.profiles
  add constraint profiles_role_check
  check (role in ('veli', 'ogrenci', 'admin', 'ogretmen'));

-- ---------------------------------------------------------------------
-- 2. siniflar — öğretmenin sorumlu olduğu sınıf grubu
-- ---------------------------------------------------------------------
create table public.siniflar (
  id              uuid primary key default gen_random_uuid(),
  ad              text not null,
  sinif_seviyesi  smallint not null check (sinif_seviyesi between 1 and 12),
  ogretmen_id     uuid references public.profiles (id) on delete set null,
  okul_adi        text,
  yil             smallint not null default extract(year from now())::smallint,
  aktif           boolean not null default true,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

comment on table public.siniflar is 'Öğretmen sorumluluğundaki sınıf grupları.';

create index siniflar_ogretmen_idx on public.siniflar (ogretmen_id) where ogretmen_id is not null;
create index siniflar_yil_idx      on public.siniflar (yil, aktif);

create trigger siniflar_set_updated_at
  before update on public.siniflar
  for each row execute function public.set_updated_at();

alter table public.siniflar enable row level security;

-- Admin her şeyi yapabilir
create policy "siniflar_admin_all"
  on public.siniflar for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- Öğretmen kendi sınıflarını görebilir
create policy "siniflar_ogretmen_select"
  on public.siniflar for select to authenticated
  using (ogretmen_id = (select auth.uid()));

revoke all on public.siniflar from anon;

-- ---------------------------------------------------------------------
-- 3. sinif_uyelikleri — hangi öğrenci hangi sınıfta
-- ---------------------------------------------------------------------
create table public.sinif_uyelikleri (
  sinif_id      uuid not null references public.siniflar (id) on delete cascade,
  ogrenci_id    uuid not null references public.profiles (id) on delete cascade,
  katilim_tarihi timestamptz not null default now(),
  primary key (sinif_id, ogrenci_id)
);

comment on table public.sinif_uyelikleri is 'Öğrenci-sınıf üyeliği.';

create index sinif_uyelikleri_ogrenci_idx on public.sinif_uyelikleri (ogrenci_id);

alter table public.sinif_uyelikleri enable row level security;

-- Admin her şeyi yapabilir
create policy "sinif_uyelikleri_admin_all"
  on public.sinif_uyelikleri for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- Öğretmen kendi sınıflarının üyelerini görebilir
create policy "sinif_uyelikleri_ogretmen_select"
  on public.sinif_uyelikleri for select to authenticated
  using (
    exists (
      select 1 from public.siniflar s
      where s.id = sinif_id and s.ogretmen_id = (select auth.uid())
    )
  );

-- Öğrenci kendi üyeliğini görebilir
create policy "sinif_uyelikleri_ogrenci_select"
  on public.sinif_uyelikleri for select to authenticated
  using (ogrenci_id = (select auth.uid()));

revoke all on public.sinif_uyelikleri from anon;

-- ---------------------------------------------------------------------
-- 4. admin_list_siniflar — sınıf listesi (admin ve öğretmen için)
-- ---------------------------------------------------------------------
create or replace function public.admin_list_siniflar(
  p_ogretmen_id uuid default null,
  p_sinif_seviyesi integer default null,
  p_aktif boolean default null,
  p_limit integer default 25,
  p_offset integer default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_limit  integer := least(greatest(coalesce(p_limit, 25), 1), 100);
  v_offset integer := greatest(coalesce(p_offset, 0), 0);
  v_toplam integer;
  v_satir  jsonb;
begin
  -- Admin veya öğretmen çağırabilir
  if not (public.is_admin() or exists (
    select 1 from public.profiles where id = auth.uid() and role = 'ogretmen'
  )) then
    raise exception 'Bu işlem için admin veya öğretmen yetkisi gerekir' using errcode = '42501';
  end if;

  -- Öğretmen yalnızca kendi sınıflarını görebilir
  if not public.is_admin() then
    p_ogretmen_id := auth.uid();
  end if;

  select count(*)::integer into v_toplam
    from public.siniflar s
   where (p_ogretmen_id is null or s.ogretmen_id = p_ogretmen_id)
     and (p_sinif_seviyesi is null or s.sinif_seviyesi = p_sinif_seviyesi)
     and (p_aktif is null or s.aktif = p_aktif);

  select jsonb_agg(row_to_json(q.*)) into v_satir
    from (
      select
        s.id,
        s.ad,
        s.sinif_seviyesi,
        s.okul_adi,
        s.yil,
        s.aktif,
        s.created_at,
        p.full_name as ogretmen_adi,
        p.id        as ogretmen_id,
        (select count(*) from public.sinif_uyelikleri u where u.sinif_id = s.id)::integer as ogrenci_sayisi
      from public.siniflar s
      left join public.profiles p on p.id = s.ogretmen_id
      where (p_ogretmen_id is null or s.ogretmen_id = p_ogretmen_id)
        and (p_sinif_seviyesi is null or s.sinif_seviyesi = p_sinif_seviyesi)
        and (p_aktif is null or s.aktif = p_aktif)
      order by s.yil desc, s.sinif_seviyesi, s.ad
      limit v_limit offset v_offset
    ) q;

  return jsonb_build_object(
    'toplam', v_toplam,
    'satirlar', coalesce(v_satir, '[]'::jsonb)
  );
end;
$$;

revoke execute on function public.admin_list_siniflar(uuid, integer, boolean, integer, integer) from public, anon;
grant  execute on function public.admin_list_siniflar(uuid, integer, boolean, integer, integer) to authenticated;

-- ---------------------------------------------------------------------
-- 5. admin_upsert_sinif — sınıf oluştur/güncelle (yalnızca admin)
-- ---------------------------------------------------------------------
create or replace function public.admin_upsert_sinif(
  p_id             uuid default null,
  p_ad             text default null,
  p_sinif_seviyesi integer default null,
  p_ogretmen_id    uuid default null,
  p_okul_adi       text default null,
  p_yil            integer default null,
  p_aktif          boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_id   uuid;
  v_kayit public.siniflar;
begin
  perform public.require_admin();

  if p_id is null then
    -- Yeni sınıf
    if p_ad is null or p_sinif_seviyesi is null then
      raise exception 'ad ve sinif_seviyesi zorunludur' using errcode = '22023';
    end if;
    insert into public.siniflar (ad, sinif_seviyesi, ogretmen_id, okul_adi, yil, aktif)
    values (
      trim(p_ad),
      p_sinif_seviyesi,
      p_ogretmen_id,
      nullif(trim(coalesce(p_okul_adi, '')), ''),
      coalesce(p_yil, extract(year from now())::integer),
      coalesce(p_aktif, true)
    )
    returning id into v_id;
  else
    -- Güncelle
    update public.siniflar
    set
      ad             = coalesce(trim(p_ad), ad),
      sinif_seviyesi = coalesce(p_sinif_seviyesi, sinif_seviyesi),
      ogretmen_id    = coalesce(p_ogretmen_id, ogretmen_id),
      okul_adi       = coalesce(nullif(trim(coalesce(p_okul_adi, '')), ''), okul_adi),
      yil            = coalesce(p_yil, yil),
      aktif          = coalesce(p_aktif, aktif)
    where id = p_id
    returning id into v_id;

    if v_id is null then
      raise exception 'Sınıf bulunamadı' using errcode = '02000';
    end if;
  end if;

  select * into v_kayit from public.siniflar where id = v_id;
  return row_to_json(v_kayit)::jsonb;
end;
$$;

revoke execute on function public.admin_upsert_sinif(uuid, text, integer, uuid, text, integer, boolean) from public, anon, authenticated;
grant  execute on function public.admin_upsert_sinif(uuid, text, integer, uuid, text, integer, boolean) to authenticated;

-- ---------------------------------------------------------------------
-- 6. admin_sinif_ogrenci_ekle / cikar — üyelik yönetimi (admin)
-- ---------------------------------------------------------------------
create or replace function public.admin_sinif_ogrenci_ekle(
  p_sinif_id   uuid,
  p_ogrenci_id uuid
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.require_admin();
  if not exists (select 1 from public.profiles where id = p_ogrenci_id and role = 'ogrenci') then
    raise exception 'Belirtilen kullanıcı öğrenci değil' using errcode = '22023';
  end if;
  insert into public.sinif_uyelikleri (sinif_id, ogrenci_id)
  values (p_sinif_id, p_ogrenci_id)
  on conflict do nothing;
end;
$$;

revoke execute on function public.admin_sinif_ogrenci_ekle(uuid, uuid) from public, anon, authenticated;
grant  execute on function public.admin_sinif_ogrenci_ekle(uuid, uuid) to authenticated;

create or replace function public.admin_sinif_ogrenci_cikar(
  p_sinif_id   uuid,
  p_ogrenci_id uuid
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.require_admin();
  delete from public.sinif_uyelikleri
  where sinif_id = p_sinif_id and ogrenci_id = p_ogrenci_id;
end;
$$;

revoke execute on function public.admin_sinif_ogrenci_cikar(uuid, uuid) from public, anon, authenticated;
grant  execute on function public.admin_sinif_ogrenci_cikar(uuid, uuid) to authenticated;
