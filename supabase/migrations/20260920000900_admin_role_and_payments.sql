-- =====================================================================
-- Admin rolü, toplu soru yönetimi, ödeme yönetimi ve işlem geçmişi
--
--  * 'admin' rolü kendiliğinden ATANAMAZ: kayıtta yalnızca veli/öğrenci seçilebilir,
--    rol değişikliği istemciye kapalıdır. Admin, SQL Editor'den elle yükseltilir:
--      update public.profiles set role = 'admin'
--       where id = (select id from auth.users where email = 'admin@ornek.com');
--  * Tüm admin işlemleri SECURITY DEFINER RPC'lerle yapılır; her biri rolü DOĞRULAR ve
--    işlem geçmişine (admin_audit_log) yazar.
--  * Ödeme: kart bilgisi ASLA saklanmaz. Tutarlar kuruş (tamsayı), para birimi TRY.
--    Gerçek ödeme sağlayıcısı (iyzico/PayTR) entegrasyonu ayrıdır; bu şema onun
--    webhook'larının yazacağı ve panelin göstereceği kayıtları tutar.
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Rol: admin
-- ---------------------------------------------------------------------
alter table public.profiles drop constraint if exists profiles_role_check;
alter table public.profiles
  add constraint profiles_role_check check (role in ('veli', 'ogrenci', 'admin'));

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
     where id = (select auth.uid()) and role = 'admin'
  );
$$;

-- Yalnızca diğer SECURITY DEFINER fonksiyonların içinden çağrılır
create or replace function public.require_admin()
returns void
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_admin() then
    raise exception 'Bu işlem için admin yetkisi gerekir' using errcode = '42501';
  end if;
end;
$$;

revoke execute on function public.is_admin() from public, anon;
grant  execute on function public.is_admin() to authenticated;
revoke execute on function public.require_admin() from public, anon, authenticated;

-- Koruma: admin, veli-çocuk bağını kurabilsin (RPC içinden). Diğer kullanıcılar için değişmez.
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
       and not (new.parent_id is null and old.parent_id = auth.uid()) then
      raise exception 'parent_id istemci tarafından değiştirilemez' using errcode = '42501';
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

-- ---------------------------------------------------------------------
-- 2. İşlem geçmişi
-- ---------------------------------------------------------------------
create table public.admin_audit_log (
  id          uuid primary key default gen_random_uuid(),
  admin_id    uuid references public.profiles (id) on delete set null,
  islem       text not null,
  detay       jsonb not null default '{}'::jsonb,
  created_at  timestamptz not null default clock_timestamp()
);

create index admin_audit_log_time_idx on public.admin_audit_log (created_at desc);

alter table public.admin_audit_log enable row level security;
create policy "admin_audit_log_select" on public.admin_audit_log
  for select to authenticated using (public.is_admin());
revoke all on public.admin_audit_log from anon;
revoke insert, update, delete on public.admin_audit_log from authenticated;

create or replace function public.log_admin_action(p_islem text, p_detay jsonb default '{}'::jsonb)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.admin_audit_log (admin_id, islem, detay)
  values ((select auth.uid()), p_islem, coalesce(p_detay, '{}'::jsonb));
$$;
revoke execute on function public.log_admin_action(text, jsonb) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 3. Soru doğrulama (toplu ekleme ve tekil kayıt için ortak)
-- ---------------------------------------------------------------------
create or replace function public._soru_hatasi(p jsonb)
returns text
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_siklar jsonb := p -> 'siklar';
  v_key    text;
begin
  if nullif(trim(coalesce(p ->> 'okul', '')), '') is null then return 'okul boş olamaz'; end if;
  if nullif(trim(coalesce(p ->> 'ders', '')), '') is null then return 'ders boş olamaz'; end if;
  if nullif(trim(coalesce(p ->> 'konu', '')), '') is null then return 'konu boş olamaz'; end if;
  if nullif(trim(coalesce(p ->> 'soru_metni', '')), '') is null then return 'soru metni boş olamaz'; end if;
  if coalesce(p ->> 'zorluk', '') !~ '^[1-3]$' then return 'zorluk 1, 2 veya 3 olmalı'; end if;

  if jsonb_typeof(v_siklar) is distinct from 'object' then return 'şıklar eksik'; end if;
  if (select count(*) from jsonb_object_keys(v_siklar)) < 2 then return 'en az 2 şık gerekli'; end if;
  for v_key in select jsonb_object_keys(v_siklar) loop
    if v_key !~ '^[A-E]$' then
      return format('şık anahtarı A-E arasında olmalı (%s)', v_key);
    end if;
    if nullif(trim(coalesce(v_siklar ->> v_key, '')), '') is null then
      return format('%s şıkkı boş olamaz', v_key);
    end if;
  end loop;

  if not (v_siklar ? upper(coalesce(p ->> 'dogru_sik', ''))) then
    return 'doğru şık, dolu şıklardan biri olmalı';
  end if;
  if p ? 'cozum_adimlari' and jsonb_typeof(p -> 'cozum_adimlari') is distinct from 'array' then
    return 'çözüm adımları liste olmalı';
  end if;
  if coalesce(p ->> 'onay_durumu', 'beklemede') not in ('beklemede', 'onaylandi', 'reddedildi') then
    return 'onay durumu beklemede, onaylandi veya reddedildi olmalı';
  end if;
  return null;
end;
$$;
revoke execute on function public._soru_hatasi(jsonb) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 4. Soru yönetimi RPC'leri
-- ---------------------------------------------------------------------

-- Listele (doğru şık ve çözümle birlikte; yalnızca admin)
create or replace function public.admin_list_questions(
  p_ders    text default null,
  p_durum   text default null,
  p_zorluk  integer default null,
  p_arama   text default null,
  p_limit   integer default 25,
  p_offset  integer default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_limit  integer := least(greatest(coalesce(p_limit, 25), 1), 100);
  v_offset integer := greatest(coalesce(p_offset, 0), 0);
  v_arama  text := public.tr_normalize(nullif(trim(coalesce(p_arama, '')), ''));
  v_toplam integer;
  v_satir  jsonb;
begin
  perform public.require_admin();

  select count(*)::integer into v_toplam
    from public.questions q
   where (p_ders is null or q.ders = p_ders)
     and (p_durum is null or q.onay_durumu = p_durum)
     and (p_zorluk is null or q.zorluk = p_zorluk)
     and (v_arama is null or public.tr_normalize(q.soru_metni || ' ' || q.konu || ' ' || coalesce(q.alt_konu, ''))
                              like '%' || v_arama || '%');

  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id), '[]'::jsonb)
    into v_satir
    from (
      select q.id, q.okul, q.ders, q.konu, q.alt_konu, q.zorluk, q.soru_metni, q.siklar,
             q.dogru_sik, q.cozum_adimlari, q.onay_durumu, q.created_at
        from public.questions q
       where (p_ders is null or q.ders = p_ders)
         and (p_durum is null or q.onay_durumu = p_durum)
         and (p_zorluk is null or q.zorluk = p_zorluk)
         and (v_arama is null or public.tr_normalize(q.soru_metni || ' ' || q.konu || ' ' || coalesce(q.alt_konu, ''))
                                  like '%' || v_arama || '%')
       order by q.created_at desc, q.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('toplam', v_toplam, 'satirlar', v_satir);
end;
$$;

-- Tekil ekle / güncelle
create or replace function public.admin_upsert_question(p_id uuid, p_soru jsonb)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_hata text;
  v_id   uuid;
begin
  perform public.require_admin();

  v_hata := public._soru_hatasi(p_soru);
  if v_hata is not null then
    raise exception '%', v_hata using errcode = '22023';
  end if;

  if p_id is null then
    insert into public.questions
      (okul, ders, konu, alt_konu, zorluk, soru_metni, siklar, dogru_sik,
       cozum_adimlari, onay_durumu, created_by)
    values
      (trim(p_soru ->> 'okul'), trim(p_soru ->> 'ders'), trim(p_soru ->> 'konu'),
       nullif(trim(coalesce(p_soru ->> 'alt_konu', '')), ''),
       (p_soru ->> 'zorluk')::smallint, trim(p_soru ->> 'soru_metni'),
       p_soru -> 'siklar', upper(p_soru ->> 'dogru_sik'),
       coalesce(p_soru -> 'cozum_adimlari', '[]'::jsonb),
       coalesce(p_soru ->> 'onay_durumu', 'beklemede'), (select auth.uid()))
    returning id into v_id;
    perform public.log_admin_action('soru_eklendi', jsonb_build_object('soru_id', v_id));
  else
    update public.questions
       set okul = trim(p_soru ->> 'okul'),
           ders = trim(p_soru ->> 'ders'),
           konu = trim(p_soru ->> 'konu'),
           alt_konu = nullif(trim(coalesce(p_soru ->> 'alt_konu', '')), ''),
           zorluk = (p_soru ->> 'zorluk')::smallint,
           soru_metni = trim(p_soru ->> 'soru_metni'),
           siklar = p_soru -> 'siklar',
           dogru_sik = upper(p_soru ->> 'dogru_sik'),
           cozum_adimlari = coalesce(p_soru -> 'cozum_adimlari', '[]'::jsonb),
           onay_durumu = coalesce(p_soru ->> 'onay_durumu', onay_durumu)
     where id = p_id
    returning id into v_id;
    if v_id is null then
      raise exception 'Soru bulunamadı' using errcode = 'P0002';
    end if;
    perform public.log_admin_action('soru_guncellendi', jsonb_build_object('soru_id', v_id));
  end if;

  return v_id;
end;
$$;

-- Toplu ekleme: satır satır doğrular; hatalıları numarasıyla bildirir; tekrarları atlar.
--  p_onayla:            true ise eklenenler doğrudan 'onaylandi', değilse 'beklemede'
--  p_hepsi_veya_hicbiri: true ise tek bir hata varsa HİÇBİR satır eklenmez
create or replace function public.admin_import_questions(
  p_rows                jsonb,
  p_onayla              boolean default false,
  p_hepsi_veya_hicbiri  boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_row      jsonb;
  v_i        integer := 0;
  v_hata     text;
  v_hatalar  jsonb := '[]'::jsonb;
  v_eklenen  integer := 0;
  v_tekrar   integer := 0;
  v_gecerli  jsonb := '[]'::jsonb;
  v_durum    text := case when p_onayla then 'onaylandi' else 'beklemede' end;
begin
  perform public.require_admin();

  if jsonb_typeof(p_rows) is distinct from 'array' then
    raise exception 'Satırlar liste olmalı' using errcode = '22023';
  end if;
  if jsonb_array_length(p_rows) > 1000 then
    raise exception 'Tek seferde en fazla 1000 satır eklenebilir' using errcode = '22023';
  end if;

  -- 1) Doğrula (satır numaraları 1'den başlar)
  for v_row in select * from jsonb_array_elements(p_rows) loop
    v_i := v_i + 1;
    v_hata := public._soru_hatasi(v_row);
    if v_hata is not null then
      v_hatalar := v_hatalar || jsonb_build_array(jsonb_build_object('satir', v_i, 'hata', v_hata));
    else
      v_gecerli := v_gecerli || jsonb_build_array(v_row);
    end if;
  end loop;

  if p_hepsi_veya_hicbiri and jsonb_array_length(v_hatalar) > 0 then
    return jsonb_build_object('eklenen', 0, 'tekrar', 0,
                              'hatali', jsonb_array_length(v_hatalar), 'hatalar', v_hatalar);
  end if;

  -- 2) Ekle (aynı ders + konu + soru metni zaten varsa atla)
  for v_row in select * from jsonb_array_elements(v_gecerli) loop
    if exists (
      select 1 from public.questions q
       where q.ders = trim(v_row ->> 'ders') and q.konu = trim(v_row ->> 'konu')
         and public.tr_normalize(q.soru_metni) = public.tr_normalize(trim(v_row ->> 'soru_metni'))
    ) then
      v_tekrar := v_tekrar + 1;
      continue;
    end if;

    insert into public.questions
      (okul, ders, konu, alt_konu, zorluk, soru_metni, siklar, dogru_sik,
       cozum_adimlari, onay_durumu, created_by)
    values
      (trim(v_row ->> 'okul'), trim(v_row ->> 'ders'), trim(v_row ->> 'konu'),
       nullif(trim(coalesce(v_row ->> 'alt_konu', '')), ''),
       (v_row ->> 'zorluk')::smallint, trim(v_row ->> 'soru_metni'),
       v_row -> 'siklar', upper(v_row ->> 'dogru_sik'),
       coalesce(v_row -> 'cozum_adimlari', '[]'::jsonb), v_durum, (select auth.uid()));
    v_eklenen := v_eklenen + 1;
  end loop;

  perform public.log_admin_action('toplu_soru_eklendi', jsonb_build_object(
    'eklenen', v_eklenen, 'tekrar', v_tekrar, 'hatali', jsonb_array_length(v_hatalar),
    'onayli', p_onayla));

  return jsonb_build_object('eklenen', v_eklenen, 'tekrar', v_tekrar,
                            'hatali', jsonb_array_length(v_hatalar), 'hatalar', v_hatalar);
end;
$$;

create or replace function public.admin_set_question_status(p_ids uuid[], p_durum text)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_adet integer;
begin
  perform public.require_admin();
  if p_durum not in ('beklemede', 'onaylandi', 'reddedildi') then
    raise exception 'Geçersiz durum' using errcode = '22023';
  end if;
  update public.questions set onay_durumu = p_durum where id = any (coalesce(p_ids, '{}'));
  get diagnostics v_adet = row_count;
  perform public.log_admin_action('soru_durumu_degisti',
    jsonb_build_object('durum', p_durum, 'adet', v_adet));
  return v_adet;
end;
$$;

-- Silme: öğrencilerin o soruya ait cevap geçmişi de silinir (CASCADE). Geri alınamaz.
create or replace function public.admin_delete_questions(p_ids uuid[])
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_adet integer;
begin
  perform public.require_admin();
  delete from public.questions where id = any (coalesce(p_ids, '{}'));
  get diagnostics v_adet = row_count;
  perform public.log_admin_action('soru_silindi', jsonb_build_object('adet', v_adet));
  return v_adet;
end;
$$;

-- ---------------------------------------------------------------------
-- 5. Kullanıcı yönetimi
-- ---------------------------------------------------------------------
create or replace function public.admin_list_users(
  p_rol     text default null,
  p_arama   text default null,
  p_limit   integer default 25,
  p_offset  integer default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_limit  integer := least(greatest(coalesce(p_limit, 25), 1), 100);
  v_offset integer := greatest(coalesce(p_offset, 0), 0);
  v_arama  text := public.tr_normalize(nullif(trim(coalesce(p_arama, '')), ''));
  v_toplam integer;
  v_satir  jsonb;
begin
  perform public.require_admin();

  select count(*)::integer into v_toplam
    from public.profiles p
    join auth.users u on u.id = p.id
   where (p_rol is null or p.role = p_rol)
     and (v_arama is null or public.tr_normalize(coalesce(p.full_name, '') || ' ' || coalesce(u.email, ''))
                              like '%' || v_arama || '%');

  select coalesce(jsonb_agg(to_jsonb(x) order by x.uyelik_tarihi desc, x.id), '[]'::jsonb)
    into v_satir
    from (
      select p.id, p.role as rol, p.full_name as ad, u.email, p.sinif,
             p.parent_id as veli_id, v.full_name as veli_ad,
             p.created_at as uyelik_tarihi,
             (select count(*)::integer from public.profiles c where c.parent_id = p.id) as cocuk_sayisi
        from public.profiles p
        join auth.users u on u.id = p.id
        left join public.profiles v on v.id = p.parent_id
       where (p_rol is null or p.role = p_rol)
         and (v_arama is null or public.tr_normalize(coalesce(p.full_name, '') || ' ' || coalesce(u.email, ''))
                                  like '%' || v_arama || '%')
       order by p.created_at desc, p.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('toplam', v_toplam, 'satirlar', v_satir);
end;
$$;

-- Veli–çocuk bağı (daha önce yalnızca SQL ile yapılabiliyordu)
create or replace function public.admin_link_child(p_cocuk_id uuid, p_veli_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.require_admin();
  if not exists (select 1 from public.profiles where id = p_cocuk_id and role = 'ogrenci') then
    raise exception 'Çocuk hesabı bulunamadı (rolü ogrenci olmalı)' using errcode = 'P0002';
  end if;
  if p_veli_id is not null
     and not exists (select 1 from public.profiles where id = p_veli_id and role = 'veli') then
    raise exception 'Veli hesabı bulunamadı (rolü veli olmalı)' using errcode = 'P0002';
  end if;

  update public.profiles set parent_id = p_veli_id where id = p_cocuk_id;
  perform public.log_admin_action(
    case when p_veli_id is null then 'veli_bagi_kaldirildi' else 'veli_bagi_kuruldu' end,
    jsonb_build_object('cocuk_id', p_cocuk_id, 'veli_id', p_veli_id));
end;
$$;

-- ---------------------------------------------------------------------
-- 6. Ödeme yönetimi
-- ---------------------------------------------------------------------
create table public.plans (
  kod          text primary key,
  ad           text not null,
  aciklama     text,
  fiyat_kurus  integer not null check (fiyat_kurus >= 0),
  para_birimi  text not null default 'TRY' check (para_birimi = 'TRY'),
  sure_gun     integer not null check (sure_gun > 0),
  aktif        boolean not null default true,
  sira         integer not null default 0
);

create table public.subscriptions (
  id            uuid primary key default gen_random_uuid(),
  veli_id       uuid not null references public.profiles (id) on delete cascade,
  plan_kod      text not null references public.plans (kod),
  durum         text not null check (durum in ('aktif', 'iptal', 'suresi_doldu', 'beklemede')),
  baslangic     timestamptz not null default now(),
  bitis         timestamptz not null,
  saglayici     text,
  saglayici_ref text,
  created_at    timestamptz not null default now()
);
create index subscriptions_veli_idx on public.subscriptions (veli_id);
create index subscriptions_durum_bitis_idx on public.subscriptions (durum, bitis);

create table public.payments (
  id              uuid primary key default gen_random_uuid(),
  veli_id         uuid references public.profiles (id) on delete set null,
  subscription_id uuid references public.subscriptions (id) on delete set null,
  tutar_kurus     integer not null check (tutar_kurus >= 0),
  para_birimi     text not null default 'TRY' check (para_birimi = 'TRY'),
  durum           text not null check (durum in ('beklemede', 'basarili', 'basarisiz', 'iade')),
  saglayici       text not null default 'manuel',
  saglayici_ref   text,
  aciklama        text,
  created_at      timestamptz not null default now()
);
create index payments_time_idx on public.payments (created_at desc);
create index payments_veli_idx on public.payments (veli_id);
-- Sağlayıcı webhook'ları aynı ödemeyi iki kez yazamasın (idempotent)
create unique index payments_saglayici_ref_uidx
  on public.payments (saglayici, saglayici_ref) where saglayici_ref is not null;

alter table public.plans         enable row level security;
alter table public.subscriptions enable row level security;
alter table public.payments      enable row level security;

create policy "plans_select" on public.plans for select to authenticated using (true);
create policy "subscriptions_select" on public.subscriptions for select to authenticated
  using (veli_id = (select auth.uid()) or public.is_admin());
create policy "payments_select" on public.payments for select to authenticated
  using (veli_id = (select auth.uid()) or public.is_admin());

revoke all on public.plans, public.subscriptions, public.payments from anon;
revoke insert, update, delete on public.plans, public.subscriptions, public.payments from authenticated;

create or replace function public.admin_upsert_plan(
  p_kod          text,
  p_ad           text,
  p_aciklama     text,
  p_fiyat_kurus  integer,
  p_sure_gun     integer,
  p_aktif        boolean default true
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
  insert into public.plans (kod, ad, aciklama, fiyat_kurus, sure_gun, aktif)
  values (p_kod, trim(p_ad), nullif(trim(coalesce(p_aciklama, '')), ''), p_fiyat_kurus, p_sure_gun, coalesce(p_aktif, true))
  on conflict (kod) do update
    set ad = excluded.ad, aciklama = excluded.aciklama, fiyat_kurus = excluded.fiyat_kurus,
        sure_gun = excluded.sure_gun, aktif = excluded.aktif;
  perform public.log_admin_action('plan_kaydedildi',
    jsonb_build_object('kod', p_kod, 'fiyat_kurus', p_fiyat_kurus));
end;
$$;

-- Elle ödeme kaydı (havale/EFT, nakit vb.). Başarılıysa abonelik de oluşturur.
create or replace function public.admin_record_payment(
  p_veli_id      uuid,
  p_plan_kod     text,
  p_tutar_kurus  integer,
  p_durum        text default 'basarili',
  p_aciklama     text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_plan   public.plans%rowtype;
  v_sub    uuid;
  v_odeme  uuid;
begin
  perform public.require_admin();
  if not exists (select 1 from public.profiles where id = p_veli_id and role = 'veli') then
    raise exception 'Veli hesabı bulunamadı' using errcode = 'P0002';
  end if;
  select * into v_plan from public.plans where kod = p_plan_kod;
  if not found then
    raise exception 'Plan bulunamadı' using errcode = 'P0002';
  end if;
  if p_durum not in ('beklemede', 'basarili', 'basarisiz', 'iade') then
    raise exception 'Geçersiz ödeme durumu' using errcode = '22023';
  end if;

  if p_durum = 'basarili' then
    insert into public.subscriptions (veli_id, plan_kod, durum, bitis, saglayici)
    values (p_veli_id, v_plan.kod, 'aktif', now() + make_interval(days => v_plan.sure_gun), 'manuel')
    returning id into v_sub;
  end if;

  insert into public.payments (veli_id, subscription_id, tutar_kurus, durum, saglayici, aciklama)
  values (p_veli_id, v_sub, p_tutar_kurus, p_durum, 'manuel', nullif(trim(coalesce(p_aciklama, '')), ''))
  returning id into v_odeme;

  perform public.log_admin_action('odeme_kaydedildi', jsonb_build_object(
    'odeme_id', v_odeme, 'veli_id', p_veli_id, 'plan', p_plan_kod,
    'tutar_kurus', p_tutar_kurus, 'durum', p_durum));
  return v_odeme;
end;
$$;

-- Durum düzeltme (ör. başarılı → iade). Gerçek iadeyi sağlayıcıda yapmak sizin işiniz;
-- bu yalnızca kaydı günceller. İade edilen ödemeye bağlı abonelik iptal edilir.
create or replace function public.admin_set_payment_status(p_id uuid, p_durum text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_sub uuid;
begin
  perform public.require_admin();
  if p_durum not in ('beklemede', 'basarili', 'basarisiz', 'iade') then
    raise exception 'Geçersiz ödeme durumu' using errcode = '22023';
  end if;
  update public.payments set durum = p_durum where id = p_id returning subscription_id into v_sub;
  if not found then
    raise exception 'Ödeme bulunamadı' using errcode = 'P0002';
  end if;
  if p_durum = 'iade' and v_sub is not null then
    update public.subscriptions set durum = 'iptal' where id = v_sub;
  end if;
  perform public.log_admin_action('odeme_durumu_degisti',
    jsonb_build_object('odeme_id', p_id, 'durum', p_durum));
end;
$$;

create or replace function public.admin_list_payments(
  p_durum      text default null,
  p_baslangic  date default null,
  p_bitis      date default null,
  p_limit      integer default 25,
  p_offset     integer default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_limit  integer := least(greatest(coalesce(p_limit, 25), 1), 100);
  v_offset integer := greatest(coalesce(p_offset, 0), 0);
  v_toplam integer;
  v_tutar  bigint;
  v_satir  jsonb;
begin
  perform public.require_admin();

  select count(*)::integer,
         coalesce(sum(p.tutar_kurus) filter (where p.durum = 'basarili'), 0)
    into v_toplam, v_tutar
    from public.payments p
   where (p_durum is null or p.durum = p_durum)
     and (p_baslangic is null or (p.created_at at time zone 'Europe/Istanbul')::date >= p_baslangic)
     and (p_bitis is null or (p.created_at at time zone 'Europe/Istanbul')::date <= p_bitis);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.tarih desc, x.id), '[]'::jsonb)
    into v_satir
    from (
      select p.id, p.created_at as tarih, p.tutar_kurus, p.para_birimi, p.durum,
             p.saglayici, p.saglayici_ref, p.aciklama,
             p.veli_id, v.full_name as veli_ad, u.email as veli_email,
             s.plan_kod, pl.ad as plan_ad
        from public.payments p
        left join public.profiles v on v.id = p.veli_id
        left join auth.users u on u.id = p.veli_id
        left join public.subscriptions s on s.id = p.subscription_id
        left join public.plans pl on pl.kod = s.plan_kod
       where (p_durum is null or p.durum = p_durum)
         and (p_baslangic is null or (p.created_at at time zone 'Europe/Istanbul')::date >= p_baslangic)
         and (p_bitis is null or (p.created_at at time zone 'Europe/Istanbul')::date <= p_bitis)
       order by p.created_at desc, p.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('toplam', v_toplam, 'basarili_tutar_kurus', v_tutar, 'satirlar', v_satir);
end;
$$;

-- ---------------------------------------------------------------------
-- 7. Panel özeti (tek çağrı)
-- ---------------------------------------------------------------------
create or replace function public.admin_dashboard_summary()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_bugun     date := (now() at time zone 'Europe/Istanbul')::date;
  v_bu_ay     date := date_trunc('month', v_bugun)::date;
  v_gecen_ay  date := (date_trunc('month', v_bugun) - interval '1 month')::date;
begin
  perform public.require_admin();

  return jsonb_build_object(
    'kullanicilar', jsonb_build_object(
      'veli',    (select count(*) from public.profiles where role = 'veli'),
      'ogrenci', (select count(*) from public.profiles where role = 'ogrenci'),
      'admin',   (select count(*) from public.profiles where role = 'admin'),
      'son_30_gun_yeni', (select count(*) from public.profiles where created_at >= now() - interval '30 days'),
      'bagsiz_ogrenci',  (select count(*) from public.profiles where role = 'ogrenci' and parent_id is null)
    ),
    'sorular', jsonb_build_object(
      'toplam',     (select count(*) from public.questions),
      'onayli',     (select count(*) from public.questions where onay_durumu = 'onaylandi'),
      'bekleyen',   (select count(*) from public.questions where onay_durumu = 'beklemede'),
      'reddedilen', (select count(*) from public.questions where onay_durumu = 'reddedildi'),
      'ders_dagilimi', coalesce((
        select jsonb_agg(jsonb_build_object('ders', ders, 'adet', adet) order by adet desc, ders)
          from (select ders, count(*)::integer as adet from public.questions group by ders) d), '[]'::jsonb)
    ),
    'odemeler', jsonb_build_object(
      'bu_ay_kurus', coalesce((select sum(tutar_kurus) from public.payments
          where durum = 'basarili'
            and (created_at at time zone 'Europe/Istanbul')::date >= v_bu_ay), 0),
      'gecen_ay_kurus', coalesce((select sum(tutar_kurus) from public.payments
          where durum = 'basarili'
            and (created_at at time zone 'Europe/Istanbul')::date >= v_gecen_ay
            and (created_at at time zone 'Europe/Istanbul')::date < v_bu_ay), 0),
      'basarili_adet',  (select count(*) from public.payments where durum = 'basarili'),
      'bekleyen_adet',  (select count(*) from public.payments where durum = 'beklemede'),
      'basarisiz_adet', (select count(*) from public.payments where durum = 'basarisiz'),
      'iade_adet',      (select count(*) from public.payments where durum = 'iade'),
      -- Son 6 ay (boş aylar 0 olarak dolar)
      'aylik', (
        select jsonb_agg(jsonb_build_object('ay', to_char(m.ay, 'YYYY-MM'),
                                            'tutar_kurus', coalesce(t.tutar, 0),
                                            'adet', coalesce(t.adet, 0)) order by m.ay)
          from generate_series((v_bu_ay - interval '5 months')::date, v_bu_ay, interval '1 month') as m(ay)
          left join (
            select date_trunc('month', created_at at time zone 'Europe/Istanbul')::date as ay,
                   sum(tutar_kurus) as tutar, count(*) as adet
              from public.payments where durum = 'basarili' group by 1
          ) t on t.ay = m.ay::date)
    ),
    'abonelikler', jsonb_build_object(
      'aktif', (select count(*) from public.subscriptions where durum = 'aktif' and bitis > now()),
      'yakinda_bitecek', (select count(*) from public.subscriptions
          where durum = 'aktif' and bitis > now() and bitis <= now() + interval '7 days')
    ),
    'son_odemeler', coalesce((
      select jsonb_agg(to_jsonb(x) order by x.tarih desc)
        from (select p.created_at as tarih, p.tutar_kurus, p.durum, v.full_name as veli_ad
                from public.payments p left join public.profiles v on v.id = p.veli_id
               order by p.created_at desc limit 5) x), '[]'::jsonb),
    'son_islemler', coalesce((
      select jsonb_agg(to_jsonb(x) order by x.tarih desc)
        from (select a.created_at as tarih, a.islem, a.detay, p.full_name as admin_ad
                from public.admin_audit_log a left join public.profiles p on p.id = a.admin_id
               order by a.created_at desc limit 10) x), '[]'::jsonb)
  );
end;
$$;

-- ---------------------------------------------------------------------
-- 8. Yetkiler: tüm admin RPC'leri yalnızca giriş yapmış kullanıcıya açık
--    (içeride require_admin() yine de admin olmayanı reddeder)
-- ---------------------------------------------------------------------
do $$
declare
  f record;
begin
  for f in
    select p.oid::regprocedure as sig
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.proname like 'admin\_%'
  loop
    execute format('revoke execute on function %s from public, anon', f.sig);
    execute format('grant execute on function %s to authenticated', f.sig);
  end loop;
end
$$;
