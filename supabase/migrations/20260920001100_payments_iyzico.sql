-- =====================================================================
-- Kartlı ödeme (iyzico Checkout Form) - SUNUCU TARAFI
--
--  * Kart bilgisi ASLA bizim sunucumuza gelmez/saklanmaz (iyzico'nun barındırdığı ödeme sayfası).
--  * Tutar her zaman plans tablosundan okunur (istemciden gelen tutara güvenilmez). Kuruş (tamsayı).
--  * payment_create_pending / payment_set_token / payment_get / payment_complete / payment_fail
--    YALNIZCA service_role (Edge Function) çağırabilir; authenticated/anon çağıramaz.
--  * Abonelik dönemlik ve tek seferliktir (otomatik yenileme yok).
--  * Ücretli özellik kısıtı (premium_gating) varsayılan KAPALI; yönetici açar.
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. payments ek sütunlar
-- ---------------------------------------------------------------------
alter table public.payments
  add column if not exists plan_kod      text references public.plans (kod),
  add column if not exists iyzico_token  text,
  add column if not exists ham           jsonb,          -- yalnızca güvenli alanlar (kart verisi YOK)
  add column if not exists hata_nedeni   text,
  add column if not exists odeme_tarihi  timestamptz;

create unique index if not exists payments_iyzico_token_uidx
  on public.payments (iyzico_token) where iyzico_token is not null;

-- ---------------------------------------------------------------------
-- 2. app_settings
-- ---------------------------------------------------------------------
create table public.app_settings (
  key         text primary key,
  value       jsonb not null,
  updated_at  timestamptz not null default now()
);

alter table public.app_settings enable row level security;
-- İstemci yalnızca beyaz listedeki anahtarları okuyabilir
create policy "app_settings_select" on public.app_settings for select to authenticated
  using (key in ('premium_gating'));
revoke all on public.app_settings from anon;
revoke insert, update, delete on public.app_settings from authenticated;

insert into public.app_settings (key, value)
values ('premium_gating', '{"aktif": false, "ucretsiz_gunluk_soru": 20}'::jsonb)
on conflict (key) do nothing;

create or replace function public.admin_set_setting(p_key text, p_value jsonb)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.require_admin();
  if p_key is distinct from 'premium_gating' then
    raise exception 'Bilinmeyen ayar anahtarı' using errcode = '22023';
  end if;
  if jsonb_typeof(p_value) is distinct from 'object'
     or jsonb_typeof(p_value -> 'aktif') is distinct from 'boolean'
     or jsonb_typeof(p_value -> 'ucretsiz_gunluk_soru') is distinct from 'number'
     or (p_value ->> 'ucretsiz_gunluk_soru') !~ '^[0-9]{1,4}$' then
    raise exception 'premium_gating: {"aktif": true|false, "ucretsiz_gunluk_soru": 0-9999} olmalı'
      using errcode = '22023';
  end if;

  insert into public.app_settings (key, value)
  values (p_key, jsonb_build_object('aktif', p_value -> 'aktif',
                                    'ucretsiz_gunluk_soru', p_value -> 'ucretsiz_gunluk_soru'))
  on conflict (key) do update set value = excluded.value, updated_at = now();

  perform public.log_admin_action('ayar_degisti', jsonb_build_object('key', p_key, 'value', p_value));
end;
$$;
revoke execute on function public.admin_set_setting(text, jsonb) from public, anon;
grant  execute on function public.admin_set_setting(text, jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- 3. Premium yardımcıları (İÇ: istemciye kapalı; my_* RPC'leri içeriden çağırır)
-- ---------------------------------------------------------------------
create or replace function public._premium_kaynak(p_uid uuid)
returns table (sahip uuid, kaynak text, plan_kod text, bitis timestamptz)
language sql
stable
security definer
set search_path = ''
as $$
  with me as (
    select id, role, parent_id from public.profiles where id = p_uid
  ), hedef as (
    select case when role = 'ogrenci' then parent_id else id end as sahip_id,
           case when role = 'ogrenci' then 'veli' else 'kendi' end as k
      from me where role in ('veli', 'ogrenci')
  )
  select h.sahip_id, h.k, s.plan_kod, s.bitis
    from hedef h
    join public.subscriptions s on s.veli_id = h.sahip_id
   where s.durum = 'aktif' and s.bitis > now()
   order by s.bitis desc
   limit 1;
$$;

create or replace function public.is_premium(p_uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.profiles where id = p_uid and role = 'admin')
      or exists (select 1 from public._premium_kaynak(p_uid));
$$;

create or replace function public._gating()
returns table (aktif boolean, limit_gun integer)
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((select (value ->> 'aktif')::boolean from public.app_settings where key = 'premium_gating'), false),
         coalesce((select (value ->> 'ucretsiz_gunluk_soru')::integer from public.app_settings where key = 'premium_gating'), 20);
$$;

-- Kalan ücretsiz soru: NULL = sınırsız (gating kapalı veya premium)
create or replace function public.remaining_free_questions(p_uid uuid)
returns integer
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  g record;
  v_kullanilan integer;
begin
  select * into g from public._gating();
  if not g.aktif or public.is_premium(p_uid) then
    return null;
  end if;
  select count(*)::integer into v_kullanilan
    from public.answer_events
   where student_id = p_uid
     and (created_at at time zone 'Europe/Istanbul')::date = (now() at time zone 'Europe/Istanbul')::date;
  return greatest(g.limit_gun - v_kullanilan, 0);
end;
$$;

create or replace function public.can_start_quiz(p_uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(public.remaining_free_questions(p_uid), 1) > 0;
$$;

revoke execute on function public._premium_kaynak(uuid), public.is_premium(uuid), public._gating(),
  public.remaining_free_questions(uuid), public.can_start_quiz(uuid)
  from public, anon, authenticated;

-- Sert kısıt: gating AÇIKSA ve kota dolmuşsa yeni cevap kaydı reddedilir.
-- (submit_answer'a dokunmadan; yalnızca JWT'li istemci çağrılarında. Gating kapalıyken hiçbir etkisi yok.)
create or replace function public.enforce_quiz_quota()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is not null and not public.can_start_quiz(new.student_id) then
    raise exception 'Günlük ücretsiz soru hakkın doldu' using errcode = 'P0402';
  end if;
  return new;
end;
$$;
revoke execute on function public.enforce_quiz_quota() from public, anon, authenticated;

create trigger user_answers_enforce_quota
  before insert or update of son_cevap_tarihi on public.user_answers
  for each row execute function public.enforce_quiz_quota();

-- ---------------------------------------------------------------------
-- 4. İstemci RPC'leri (yalnızca giriş yapmış kullanıcı)
-- ---------------------------------------------------------------------
create or replace function public.list_active_plans()
returns table (kod text, ad text, aciklama text, fiyat_kurus integer, sure_gun integer)
language sql
stable
security definer
set search_path = ''
as $$
  select p.kod, p.ad, p.aciklama, p.fiyat_kurus, p.sure_gun
    from public.plans p
   where p.aktif
   order by p.sira, p.kod;
$$;

create or replace function public.my_subscription_status()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid  uuid := (select auth.uid());
  g      record;
  k      record;
  v_admin boolean;
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  select * into g from public._gating();
  select public.is_admin() into v_admin;
  select * into k from public._premium_kaynak(v_uid);

  if v_admin then
    return jsonb_build_object('aktif', true, 'plan_kod', null, 'plan_ad', null, 'bitis', null,
      'kalan_gun', null, 'kaynak', 'kendi',
      'gating_aktif', g.aktif, 'ucretsiz_gunluk_soru', g.limit_gun);
  end if;

  return jsonb_build_object(
    'aktif',     k.plan_kod is not null,
    'plan_kod',  k.plan_kod,
    'plan_ad',   (select ad from public.plans where kod = k.plan_kod),
    'bitis',     k.bitis,
    'kalan_gun', case when k.bitis is null then null
                      else greatest(ceil(extract(epoch from (k.bitis - now())) / 86400.0)::integer, 0) end,
    'kaynak',    coalesce(k.kaynak, 'kendi'),
    'gating_aktif', g.aktif,
    'ucretsiz_gunluk_soru', g.limit_gun);
end;
$$;

-- Öğrencinin bugünkü kota durumu (Flutter gösterimi için)
create or replace function public.my_quiz_quota()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  g record;
  v_kalan integer;
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  select * into g from public._gating();
  v_kalan := public.remaining_free_questions(v_uid);
  return jsonb_build_object('gating_aktif', g.aktif, 'premium', public.is_premium(v_uid),
    'ucretsiz_gunluk_soru', g.limit_gun, 'kalan', v_kalan, 'izinli', coalesce(v_kalan, 1) > 0);
end;
$$;

-- Velinin kendi ödemeleri (öğrenci/admin için boş liste)
create or replace function public.my_payments()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  if public.current_user_role() is distinct from 'veli' then
    return '[]'::jsonb;
  end if;
  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.tarih desc, x.id)
      from (
        select p.id, p.created_at as tarih, p.tutar_kurus, p.para_birimi, p.durum,
               p.plan_kod, pl.ad as plan_ad, p.odeme_tarihi
          from public.payments p
          left join public.plans pl on pl.kod = p.plan_kod
         where p.veli_id = v_uid
         order by p.created_at desc, p.id
         limit 50
      ) x), '[]'::jsonb);
end;
$$;

do $$
declare f text;
begin
  foreach f in array array[
    'public.list_active_plans()', 'public.my_subscription_status()',
    'public.my_quiz_quota()', 'public.my_payments()'] loop
    execute format('revoke execute on function %s from public, anon', f);
    execute format('grant execute on function %s to authenticated', f);
  end loop;
end $$;

-- ---------------------------------------------------------------------
-- 5. Yalnızca service_role: Edge Function'ların kullandığı iç fonksiyonlar
-- ---------------------------------------------------------------------
create or replace function public.payment_create_pending(p_veli_id uuid, p_plan_kod text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_plan public.plans%rowtype;
  v_id   uuid;
begin
  if not exists (select 1 from public.profiles where id = p_veli_id and role = 'veli') then
    raise exception 'Yalnızca veli hesabı ödeme yapabilir' using errcode = '42501';
  end if;
  select * into v_plan from public.plans where kod = p_plan_kod and aktif;
  if not found then
    raise exception 'Plan bulunamadı veya satışta değil' using errcode = 'P0002';
  end if;
  if v_plan.fiyat_kurus <= 0 then
    raise exception 'Ücretsiz plan kartla satın alınamaz' using errcode = '22023';
  end if;

  insert into public.payments (veli_id, plan_kod, tutar_kurus, durum, saglayici, aciklama)
  values (p_veli_id, v_plan.kod, v_plan.fiyat_kurus, 'beklemede', 'iyzico', v_plan.ad)
  returning id into v_id;

  return jsonb_build_object('payment_id', v_id, 'tutar_kurus', v_plan.fiyat_kurus,
    'plan_kod', v_plan.kod, 'plan_ad', v_plan.ad, 'sure_gun', v_plan.sure_gun);
end;
$$;

create or replace function public.payment_set_token(p_payment_id uuid, p_token text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if p_token is null or length(p_token) < 8 or length(p_token) > 200 then
    raise exception 'Geçersiz token' using errcode = '22023';
  end if;
  update public.payments set iyzico_token = p_token
   where id = p_payment_id and durum = 'beklemede' and saglayici = 'iyzico';
  if not found then
    raise exception 'Bekleyen ödeme bulunamadı' using errcode = 'P0002';
  end if;
end;
$$;

create or replace function public.payment_get(p_payment_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select to_jsonb(x) from (
    select id, veli_id, plan_kod, tutar_kurus, durum, iyzico_token
      from public.payments where id = p_payment_id and saglayici = 'iyzico'
  ) x;
$$;

create or replace function public._ham_temizle(p jsonb)
returns jsonb
language sql
immutable
set search_path = ''
as $$
  -- Beyaz liste: kart/kişi verisi içerebilecek hiçbir alan alınmaz
  select coalesce(jsonb_object_agg(k, p -> k), '{}'::jsonb)
    from unnest(array['status', 'paymentStatus', 'paymentId', 'paidPrice', 'price', 'currency',
                      'conversationId', 'fraudStatus', 'installment', 'errorCode']) as k
   where jsonb_typeof(p) = 'object' and p ? k
     and jsonb_typeof(p -> k) in ('string', 'number', 'boolean');
$$;

-- İdempotent tamamlama: aynı ödeme ikinci kez işlenmez.
create or replace function public.payment_complete(
  p_payment_id     uuid,
  p_saglayici_ref  text,
  p_odenen_kurus   integer,
  p_ham            jsonb default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_pay   public.payments%rowtype;
  v_plan  public.plans%rowtype;
  v_bas   timestamptz;
  v_sub   uuid;
begin
  select * into v_pay from public.payments where id = p_payment_id and saglayici = 'iyzico' for update;
  if not found then
    raise exception 'Ödeme bulunamadı' using errcode = 'P0002';
  end if;

  if v_pay.durum = 'basarili' then
    return jsonb_build_object('sonuc', 'zaten_islendi', 'durum', 'basarili', 'subscription_id', v_pay.subscription_id);
  elsif v_pay.durum <> 'beklemede' then
    return jsonb_build_object('sonuc', 'islenmis_degistirilmedi', 'durum', v_pay.durum);
  end if;

  if p_saglayici_ref is null or length(trim(p_saglayici_ref)) = 0 then
    raise exception 'saglayici_ref gerekli' using errcode = '22023';
  end if;

  if p_odenen_kurus is distinct from v_pay.tutar_kurus then
    update public.payments
       set durum = 'basarisiz', saglayici_ref = p_saglayici_ref,
           ham = public._ham_temizle(p_ham),
           hata_nedeni = format('TUTAR_UYUSMAZLIGI: beklenen %s, odenen %s kurus. Para cekilmis olabilir; iyzico panelinden kontrol edip iade edin.',
                                v_pay.tutar_kurus, coalesce(p_odenen_kurus::text, 'yok'))
     where id = v_pay.id;
    perform public.log_admin_action('odeme_tutar_uyusmazligi', jsonb_build_object(
      'odeme_id', v_pay.id, 'beklenen_kurus', v_pay.tutar_kurus, 'odenen_kurus', p_odenen_kurus));
    return jsonb_build_object('sonuc', 'tutar_uyusmazligi', 'durum', 'basarisiz');
  end if;

  select * into v_plan from public.plans where kod = v_pay.plan_kod;
  if not found then
    raise exception 'Plan bulunamadı' using errcode = 'P0002';
  end if;

  -- Aynı plandan aktif abonelik varsa bitişinden uzat; yoksa şimdi başlat
  select max(s.bitis) into v_bas
    from public.subscriptions s
   where s.veli_id = v_pay.veli_id and s.plan_kod = v_pay.plan_kod
     and s.durum = 'aktif' and s.bitis > now();
  v_bas := coalesce(v_bas, now());

  insert into public.subscriptions (veli_id, plan_kod, durum, baslangic, bitis, saglayici, saglayici_ref)
  values (v_pay.veli_id, v_pay.plan_kod, 'aktif', v_bas,
          v_bas + make_interval(days => v_plan.sure_gun), 'iyzico', p_saglayici_ref)
  returning id into v_sub;

  update public.payments
     set durum = 'basarili', saglayici_ref = p_saglayici_ref, subscription_id = v_sub,
         odeme_tarihi = now(), ham = public._ham_temizle(p_ham), hata_nedeni = null
   where id = v_pay.id;

  perform public.log_admin_action('odeme_tamamlandi', jsonb_build_object(
    'odeme_id', v_pay.id, 'veli_id', v_pay.veli_id, 'plan', v_pay.plan_kod, 'tutar_kurus', v_pay.tutar_kurus));

  return jsonb_build_object('sonuc', 'tamamlandi', 'durum', 'basarili', 'subscription_id', v_sub);
end;
$$;

create or replace function public.payment_fail(p_payment_id uuid, p_neden text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_pay public.payments%rowtype;
begin
  select * into v_pay from public.payments where id = p_payment_id and saglayici = 'iyzico' for update;
  if not found then
    raise exception 'Ödeme bulunamadı' using errcode = 'P0002';
  end if;
  if v_pay.durum <> 'beklemede' then
    -- Başarılı bir ödeme asla başarısıza düşürülmez (yenileme/tekrar çağrı güvenliği)
    return jsonb_build_object('sonuc', 'islenmis_degistirilmedi', 'durum', v_pay.durum);
  end if;
  update public.payments
     set durum = 'basarisiz', hata_nedeni = left(coalesce(p_neden, 'bilinmiyor'), 200)
   where id = v_pay.id;
  return jsonb_build_object('sonuc', 'basarisiz_kaydedildi', 'durum', 'basarisiz');
end;
$$;

do $$
declare f text;
begin
  foreach f in array array[
    'public.payment_create_pending(uuid, text)', 'public.payment_set_token(uuid, text)',
    'public.payment_get(uuid)', 'public.payment_complete(uuid, text, integer, jsonb)',
    'public.payment_fail(uuid, text)', 'public._ham_temizle(jsonb)'] loop
    execute format('revoke execute on function %s from public, anon, authenticated', f);
    execute format('grant execute on function %s to service_role', f);
  end loop;
end $$;

-- Satışa açık olmayan örnek planlar (fiyatı yönetici belirler ve aktifleştirir)
insert into public.plans (kod, ad, aciklama, fiyat_kurus, sure_gun, aktif, sira) values
  ('aylik',  'Aylık Premium',  '30 gün sınırsız soru', 14990, 30, false, 1),
  ('yillik', 'Yıllık Premium', '365 gün sınırsız soru', 119900, 365, false, 2)
on conflict (kod) do nothing;
