-- =====================================================================
-- Müşteri 360 — veri toplama katmanı
--   Web, uygulama ve pazarlama formlarından gelen kişileri tek müşteri kartına
--   (growth_households) toplar. Plan: docs/growth-crm/VERI_TOPLAMA_PLANI.md
--
--   Kaynaklar: profiles (veli/öğrenci), subscriptions, payments,
--              veli_adaylari (landing formu), deneme_sinavi_on_kayitlari.
--   Kurallar : e-posta (küçük harf) ile tek kart; senkron yalnızca boş alanı doldurur,
--              admin'in elle yazdığı değeri ezmez; izin asla tahmin edilmez;
--              tetikleyici hatası asıl işlemi bozmaz (uyarı loglanır).
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. İzin tablosu: hesabı olmayan kişiler için kanal izni (hesaplı veli için
--    kaynak iletisim_tercihleri'dir; growth_consent_bridge ikisini birleştirir).
-- ---------------------------------------------------------------------
create table if not exists public.growth_household_izinleri (
  household_id uuid not null references public.growth_households (id) on delete cascade,
  channel      text not null check (channel in ('email', 'sms', 'phone', 'push', 'in_app')),
  granted      boolean not null,
  source       text not null,
  surum        text,
  updated_at   timestamptz not null default now(),
  primary key (household_id, channel)
);
alter table public.growth_household_izinleri enable row level security;
revoke all on table public.growth_household_izinleri from public, anon, authenticated;

create or replace view public.growth_consent_bridge
with (security_invoker = true) as
select
  h.id as household_id,
  case t.kanal when 'eposta' then 'email' when 'push' then 'push' when 'sms' then 'sms' when 'uygulama_ici' then 'in_app' end as channel,
  t.izin as granted,
  t.kaynak as source,
  t.updated_at as changed_at
from public.iletisim_tercihleri t
join public.growth_households h on h.core_parent_user_id = t.veli_id
union all
select i.household_id, i.channel, i.granted, i.source, i.updated_at
  from public.growth_household_izinleri i
  join public.growth_households h on h.id = i.household_id
 where not exists (
   select 1 from public.iletisim_tercihleri t
    where t.veli_id = h.core_parent_user_id
      and case t.kanal when 'eposta' then 'email' when 'push' then 'push' when 'sms' then 'sms' when 'uygulama_ici' then 'in_app' end = i.channel
 );

-- ---------------------------------------------------------------------
-- 2. Müşteri numarası
-- ---------------------------------------------------------------------
create sequence if not exists public.growth_musteri_no_seq;

-- ---------------------------------------------------------------------
-- 3. İç yardımcılar (istemciye kapalı)
-- ---------------------------------------------------------------------
create or replace function public._growth_lifecycle_sira(p_asama public.growth_lifecycle_stage)
returns int
language sql
immutable
set search_path = ''
as $f$
  select case p_asama
    when 'visitor' then 1 when 'lead' then 2 when 'registered' then 3 when 'trial' then 4
    when 'activated' then 5 when 'engaged' then 6 when 'paid' then 7
    else 0 end;   -- at_risk / churned / winback: her zaman ilerletilebilir
$f$;

-- Kişiyi bulur ya da oluşturur. Mevcut kartta yalnızca BOŞ alanları doldurur.
create or replace function public._growth_hane_upsert(
  p_email      text,
  p_ad         text,
  p_telefon    text,
  p_kaynak     text,
  p_core_user  uuid default null,
  p_lifecycle  public.growth_lifecycle_stage default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $f$
declare
  v_email text := lower(btrim(coalesce(p_email, '')));
  v_ad    text := nullif(btrim(coalesce(p_ad, '')), '');
  v_tel   text := nullif(btrim(coalesce(p_telefon, '')), '');
  v_kay   text := nullif(btrim(coalesce(p_kaynak, '')), '');
  v_id    uuid;
begin
  if v_email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    return null;
  end if;

  select h.id into v_id
    from public.growth_households h
   where (p_core_user is not null and h.core_parent_user_id = p_core_user)
      or lower(h.email) = v_email
   order by (h.core_parent_user_id = p_core_user) desc nulls last, h.created_at
   limit 1;

  if v_id is null then
    insert into public.growth_households (
      core_parent_user_id, parent_name, first_name, last_name, email, phone, source,
      lifecycle, customer_no
    ) values (
      p_core_user,
      coalesce(v_ad, split_part(v_email, '@', 1)),
      case when v_ad is null then null else split_part(v_ad, ' ', 1) end,
      case when v_ad is null or position(' ' in v_ad) = 0 then null
           else btrim(substr(v_ad, position(' ' in v_ad) + 1)) end,
      v_email, v_tel, v_kay,
      coalesce(p_lifecycle, 'lead'),
      'HUP-' || lpad(nextval('public.growth_musteri_no_seq')::text, 6, '0')
    )
    on conflict (lower(email)) do nothing
    returning id into v_id;

    if v_id is null then
      select h.id into v_id from public.growth_households h where lower(h.email) = v_email;
    end if;
  end if;

  update public.growth_households h set
    core_parent_user_id = coalesce(h.core_parent_user_id, p_core_user),
    phone      = coalesce(h.phone, v_tel),
    source     = coalesce(h.source, v_kay),
    first_name = coalesce(h.first_name, case when v_ad is null then null else split_part(v_ad, ' ', 1) end),
    last_name  = coalesce(h.last_name, case when v_ad is null or position(' ' in v_ad) = 0 then null
                                            else btrim(substr(v_ad, position(' ' in v_ad) + 1)) end),
    customer_no = coalesce(h.customer_no, 'HUP-' || lpad(nextval('public.growth_musteri_no_seq')::text, 6, '0')),
    lifecycle  = case when p_lifecycle is not null
                       and public._growth_lifecycle_sira(p_lifecycle) > public._growth_lifecycle_sira(h.lifecycle)
                      then p_lifecycle else h.lifecycle end
   where h.id = v_id;

  return v_id;
end;
$f$;

create or replace function public._growth_olay_yaz(
  p_hane  uuid,
  p_olay  text,
  p_props jsonb default '{}'::jsonb
)
returns void
language sql
security definer
set search_path = ''
as $f$
  insert into public.growth_events (household_id, event_name, source, properties)
  select p_hane, p_olay, 'server', coalesce(p_props, '{}'::jsonb)
   where p_hane is not null;
$f$;

-- Kanal izni yazar; genel ticari izin özetini yeniden hesaplar.
create or replace function public._growth_izin_yaz(
  p_hane   uuid,
  p_kanal  text,
  p_izin   boolean,
  p_kaynak text,
  p_surum  text default null,
  -- true: var olan kaydı DEĞİŞTİRME (işaretlenmemiş kutu, verilmiş izni geri çekmiş sayılmaz)
  p_sadece_yoksa boolean default false
)
returns void
language plpgsql
security definer
set search_path = ''
as $f$
declare
  v_genel public.growth_consent_status;
begin
  if p_hane is null or p_izin is null then
    return;
  end if;

  if p_sadece_yoksa then
    insert into public.growth_household_izinleri (household_id, channel, granted, source, surum)
    values (p_hane, p_kanal, p_izin, p_kaynak, p_surum)
    on conflict (household_id, channel) do nothing;
  else
    insert into public.growth_household_izinleri (household_id, channel, granted, source, surum)
    values (p_hane, p_kanal, p_izin, p_kaynak, p_surum)
    on conflict (household_id, channel) do update
      set granted = excluded.granted, source = excluded.source,
          surum = excluded.surum, updated_at = now();
  end if;

  select case when bool_or(b.granted) then 'granted'
              when count(*) > 0 then 'denied'
              else 'unknown' end::public.growth_consent_status
    into v_genel
    from public.growth_consent_bridge b
   where b.household_id = p_hane and b.channel in ('email', 'sms', 'phone', 'push');

  update public.growth_households
     set commercial_consent_overall = coalesce(v_genel, 'unknown'),
         consent_proof_updated_at = now()
   where id = p_hane;
end;
$f$;

-- ---------------------------------------------------------------------
-- 4. Kaynak eşleyiciler (tetikleyiciler ve geri doldurma aynı fonksiyonu kullanır)
-- ---------------------------------------------------------------------

-- 4.1 Hesap (veli / öğrenci)
create or replace function public._growth_profil_esle(p_profil uuid, p_yeni boolean default false)
returns void
language plpgsql
security definer
set search_path = ''
as $f$
declare
  p      public.profiles%rowtype;
  v_mail text;
  v_hane uuid;
  v_kisi uuid;
begin
  select * into p from public.profiles where id = p_profil;
  if not found then return; end if;

  if p.role = 'veli' then
    select u.email into v_mail from auth.users u where u.id = p.id;
    v_hane := public._growth_hane_upsert(v_mail, p.full_name, null, 'uygulama_kayit', p.id, 'registered');
    if p_yeni then
      perform public._growth_olay_yaz(v_hane, 'hesap_olusturuldu', '{}'::jsonb);
    end if;
    -- Daha önce bu veliye bağlanmış öğrencileri de içeri al.
    perform public._growth_profil_esle(c.id) from public.profiles c where c.parent_id = p.id and c.role = 'ogrenci';

  elsif p.role = 'ogrenci' and p.parent_id is not null then
    select h.id into v_hane from public.growth_households h where h.core_parent_user_id = p.parent_id;
    if v_hane is null then return; end if;

    select k.id into v_kisi from public.growth_customer_people k
     where k.household_id = v_hane and k.core_student_id = p.id;
    if v_kisi is null then
      insert into public.growth_customer_people (household_id, core_student_id, person_role, first_name, grade)
      values (v_hane, p.id, 'student', coalesce(p.full_name, p.username),
              case when p.sinif between 3 and 8 then p.sinif end);
      perform public._growth_olay_yaz(v_hane, 'ogrenci_baglandi', jsonb_build_object('sinif', p.sinif));
    else
      update public.growth_customer_people k set
        first_name = coalesce(p.full_name, p.username, k.first_name),
        grade = case when p.sinif between 3 and 8 then p.sinif else k.grade end,
        updated_at = now()
       where k.id = v_kisi;
    end if;
  end if;
end;
$f$;

-- 4.2 Abonelik: en güncel aboneliğe göre plan / durum / yaşam döngüsü / MRR
create or replace function public._growth_abonelik_esle(p_veli uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $f$
declare
  v_hane  uuid;
  s       record;
  v_plan  public.growth_plan;
  v_durum text;
  v_asama public.growth_lifecycle_stage;
  v_mrr   numeric(12,2) := 0;
begin
  select h.id into v_hane from public.growth_households h where h.core_parent_user_id = p_veli;
  if v_hane is null then return; end if;

  select sb.*, pl.fiyat_kurus, pl.sure_gun, pl.tip_kod
    into s
    from public.subscriptions sb
    join public.plans pl on pl.kod = sb.plan_kod
   where sb.veli_id = p_veli
   order by (sb.durum = 'aktif' and sb.bitis > now()) desc, sb.bitis desc
   limit 1;
  if not found then return; end if;

  if s.durum = 'aktif' and s.bitis > now() then
    if s.fiyat_kurus = 0 then
      v_plan := 'trial'; v_durum := 'trial'; v_asama := 'trial';
    else
      v_plan := case when s.tip_kod = 'family' then 'family' else 'premium' end;
      v_durum := 'active'; v_asama := 'paid';
      v_mrr := round(s.fiyat_kurus / 100.0 * 30 / greatest(s.sure_gun, 1), 2);
    end if;
  elsif s.durum = 'iptal' then
    v_plan := 'free'; v_durum := 'cancelled'; v_asama := 'churned';
  elsif s.durum = 'suresi_doldu' or (s.durum = 'aktif' and s.bitis <= now()) then
    v_plan := 'free'; v_durum := 'expired'; v_asama := 'churned';
  else
    return;   -- beklemede: durumu değiştirme
  end if;

  update public.growth_households h set
    plan = v_plan,
    subscription_status = v_durum,
    mrr = v_mrr,
    trial_started_at = case when v_durum = 'trial' then coalesce(h.trial_started_at, s.baslangic) else h.trial_started_at end,
    lifecycle = case
      when v_asama in ('paid', 'trial')
        then case when public._growth_lifecycle_sira(v_asama) > public._growth_lifecycle_sira(h.lifecycle)
                    or h.lifecycle in ('at_risk', 'churned', 'winback')
                  then v_asama else h.lifecycle end
      -- churned: yalnızca daha önce deneme/ücretli olmuş kartta
      when h.lifecycle in ('trial', 'activated', 'engaged', 'paid') then 'churned'
      else h.lifecycle end
   where h.id = v_hane;
end;
$f$;

-- 4.3 Ödeme → işlem satırı + ciro toplamları
create or replace function public._growth_odeme_esle(p_odeme uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $f$
declare
  p       public.payments%rowtype;
  v_hane  uuid;
  v_sure  int;
  v_durum text;
  v_tutar numeric(14,2);
begin
  select * into p from public.payments where id = p_odeme;
  if not found or p.veli_id is null then return; end if;

  select h.id into v_hane from public.growth_households h where h.core_parent_user_id = p.veli_id;
  if v_hane is null then return; end if;

  select pl.sure_gun into v_sure
    from public.subscriptions sb join public.plans pl on pl.kod = sb.plan_kod
   where sb.id = p.subscription_id;

  v_durum := case p.durum when 'basarili' then 'paid' when 'basarisiz' then 'failed'
                          when 'iade' then 'refunded' else 'pending' end;
  v_tutar := round(p.tutar_kurus / 100.0, 2);

  insert into public.growth_financial_transactions (
    household_id, core_transaction_id, document_no, transaction_type, status,
    purchase_date, currency, amount, amount_try, payment_type, payment_source,
    occurred_at, order_id, refund_amount_try
  ) values (
    v_hane, p.id::text,
    'ODM-' || upper(left(replace(p.id::text, '-', ''), 10)),
    case when p.durum = 'iade' then 'refund'
         when v_sure >= 300 then 'annual_subscription'
         when v_sure is not null then 'monthly_subscription'
         else 'other' end,
    v_durum, p.created_at::date, p.para_birimi, v_tutar, v_tutar,
    case when p.saglayici ~* 'pos|iyzico|paytr|stripe' then 'virtual_pos'
         when p.saglayici ~* 'eft|havale' then 'eft_transfer'
         when p.saglayici ~* 'apple|google|revenuecat|play' then 'in_app'
         else 'other' end,
    p.saglayici, p.created_at, p.saglayici_ref,
    case when p.durum = 'iade' then v_tutar else 0 end
  )
  on conflict (document_no) do update set
    status = excluded.status, transaction_type = excluded.transaction_type,
    amount = excluded.amount, amount_try = excluded.amount_try,
    refund_amount_try = excluded.refund_amount_try, updated_at = now();

  update public.growth_households h set
    total_revenue_try = coalesce(t.toplam, 0),
    total_paid_transactions = coalesce(t.adet, 0),
    last_payment_at = t.son,
    ltv = coalesce(t.toplam, 0),
    lifecycle = case when p.durum = 'basarili'
                      and (public._growth_lifecycle_sira(h.lifecycle) < 7)
                     then 'paid' else h.lifecycle end
    from (
      select sum(amount_try) as toplam, count(*)::int as adet, max(occurred_at) as son
        from public.growth_financial_transactions
       where household_id = v_hane and status = 'paid'
    ) t
   where h.id = v_hane;

  if p.durum = 'basarili' then
    perform public._growth_olay_yaz(v_hane, 'odeme_basarili',
      jsonb_build_object('tutar_try', v_tutar, 'saglayici', p.saglayici));
  end if;
end;
$f$;

-- 4.4 Landing formu adayı
create or replace function public._growth_aday_esle(p_aday uuid, p_yeni boolean default false)
returns void
language plpgsql
security definer
set search_path = ''
as $f$
declare
  a      public.veli_adaylari%rowtype;
  v_hane uuid;
begin
  select * into a from public.veli_adaylari where id = p_aday;
  if not found then return; end if;

  v_hane := public._growth_hane_upsert(a.email, a.ad, a.telefon, a.kaynak, a.veli_id, 'lead');
  if p_yeni then
    perform public._growth_olay_yaz(v_hane, 'veli_adayi_kaydi', jsonb_build_object('kaynak', a.kaynak));
  end if;
  -- pazarlama_izni=false "izin verilmedi" demek değildir (soru sorulmamış olabilir): yalnızca true yazılır.
  if a.pazarlama_izni then
    perform public._growth_izin_yaz(v_hane, 'email', true, 'web_form', null);
  end if;
end;
$f$;

-- 4.5 Deneme sınavı ön kaydı: iki taraflı izin kutuları AÇIK sorulur; boş bırakılan kutu "verilmedi"dir.
create or replace function public._growth_on_kayit_esle(p_kayit uuid, p_yeni boolean default false)
returns void
language plpgsql
security definer
set search_path = ''
as $f$
declare
  k      public.deneme_sinavi_on_kayitlari%rowtype;
  v_hane uuid;
  v_kisi uuid;
begin
  select * into k from public.deneme_sinavi_on_kayitlari where id = p_kayit;
  if not found then return; end if;

  v_hane := public._growth_hane_upsert(k.eposta_norm, k.veli_ad, k.telefon, 'deneme_on_kayit', null, 'lead');
  if v_hane is null then return; end if;

  -- Çocuk: yalnızca ad + sınıf.
  select p.id into v_kisi from public.growth_customer_people p
   where p.household_id = v_hane and p.person_role = 'student' and p.core_student_id is null
     and lower(p.first_name) = k.cocuk_ad_norm;
  if v_kisi is null then
    insert into public.growth_customer_people (household_id, person_role, first_name, grade)
    values (v_hane, 'student', k.cocuk_ad, case when k.sinif between 3 and 8 then k.sinif end);
  else
    update public.growth_customer_people
       set grade = case when k.sinif between 3 and 8 then k.sinif else grade end, updated_at = now()
     where id = v_kisi;
  end if;

  -- İşaretli kutu izni yazar/yeniler; işaretsiz kutu yalnızca kayıt yoksa "verilmedi" yazar.
  perform public._growth_izin_yaz(v_hane, 'email', k.izin_eposta,  'web_form', k.izin_surum, not k.izin_eposta);
  perform public._growth_izin_yaz(v_hane, 'sms',   k.izin_sms,     'web_form', k.izin_surum, not k.izin_sms);
  perform public._growth_izin_yaz(v_hane, 'phone', k.izin_telefon, 'web_form', k.izin_surum, not k.izin_telefon);

  if p_yeni then
    perform public._growth_olay_yaz(v_hane, 'deneme_on_kayit',
      jsonb_build_object('sinif', k.sinif, 'exam_id', k.exam_id));
  end if;
end;
$f$;

-- ---------------------------------------------------------------------
-- 5. Tetikleyiciler (hata asıl işlemi bozmaz)
-- ---------------------------------------------------------------------
create or replace function public._growth_tetik_profil() returns trigger
language plpgsql security definer set search_path = '' as $f$
begin
  begin
    perform public._growth_profil_esle(new.id, tg_op = 'INSERT');
  exception when others then
    raise warning 'growth profil senkron: %', sqlerrm;
  end;
  return null;
end;
$f$;

create or replace function public._growth_tetik_abonelik() returns trigger
language plpgsql security definer set search_path = '' as $f$
begin
  begin
    perform public._growth_abonelik_esle(new.veli_id);
  exception when others then
    raise warning 'growth abonelik senkron: %', sqlerrm;
  end;
  return null;
end;
$f$;

create or replace function public._growth_tetik_odeme() returns trigger
language plpgsql security definer set search_path = '' as $f$
begin
  begin
    perform public._growth_odeme_esle(new.id);
  exception when others then
    raise warning 'growth odeme senkron: %', sqlerrm;
  end;
  return null;
end;
$f$;

create or replace function public._growth_tetik_aday() returns trigger
language plpgsql security definer set search_path = '' as $f$
begin
  begin
    perform public._growth_aday_esle(new.id, tg_op = 'INSERT');
  exception when others then
    raise warning 'growth aday senkron: %', sqlerrm;
  end;
  return null;
end;
$f$;

create or replace function public._growth_tetik_on_kayit() returns trigger
language plpgsql security definer set search_path = '' as $f$
begin
  begin
    perform public._growth_on_kayit_esle(new.id, tg_op = 'INSERT');
  exception when others then
    raise warning 'growth on kayit senkron: %', sqlerrm;
  end;
  return null;
end;
$f$;

drop trigger if exists growth_profil_esle on public.profiles;
create trigger growth_profil_esle
  after insert or update of full_name, role, parent_id, sinif on public.profiles
  for each row execute function public._growth_tetik_profil();

drop trigger if exists growth_abonelik_esle on public.subscriptions;
create trigger growth_abonelik_esle
  after insert or update on public.subscriptions
  for each row execute function public._growth_tetik_abonelik();

drop trigger if exists growth_odeme_esle on public.payments;
create trigger growth_odeme_esle
  after insert or update on public.payments
  for each row execute function public._growth_tetik_odeme();

drop trigger if exists growth_aday_esle on public.veli_adaylari;
create trigger growth_aday_esle
  after insert or update on public.veli_adaylari
  for each row execute function public._growth_tetik_aday();

drop trigger if exists growth_on_kayit_esle on public.deneme_sinavi_on_kayitlari;
create trigger growth_on_kayit_esle
  after insert or update on public.deneme_sinavi_on_kayitlari
  for each row execute function public._growth_tetik_on_kayit();

-- ---------------------------------------------------------------------
-- 6. Geri doldurma (tekrar çalışsa çoğaltmaz)
-- ---------------------------------------------------------------------
do $backfill$
declare
  r record;
begin
  for r in select id from public.profiles where role = 'veli' order by created_at loop
    perform public._growth_profil_esle(r.id);
  end loop;
  for r in select id from public.profiles where role = 'ogrenci' and parent_id is not null loop
    perform public._growth_profil_esle(r.id);
  end loop;
  for r in select distinct veli_id from public.subscriptions loop
    perform public._growth_abonelik_esle(r.veli_id);
  end loop;
  for r in select id from public.payments where veli_id is not null order by created_at loop
    perform public._growth_odeme_esle(r.id);
  end loop;
  for r in select id from public.veli_adaylari order by created_at loop
    perform public._growth_aday_esle(r.id);
  end loop;
  for r in select id from public.deneme_sinavi_on_kayitlari order by olusturma loop
    perform public._growth_on_kayit_esle(r.id);
  end loop;
end;
$backfill$;

-- ---------------------------------------------------------------------
-- 7. Admin RPC: liste filtreleri (kaynak, kanal izni) + veri toplama özeti
-- ---------------------------------------------------------------------
drop function if exists public.admin_musteri_360_listele(text, public.growth_lifecycle_stage, public.growth_plan, int, int);

create or replace function public.admin_musteri_360_listele(
  p_arama      text default '',
  p_lifecycle  public.growth_lifecycle_stage default null,
  p_plan       public.growth_plan default null,
  p_limit      int default 25,
  p_offset     int default 0,
  p_kaynak     text default null,
  p_izin_kanal text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $f$
declare
  v_limit    int := least(greatest(coalesce(p_limit, 25), 1), 100);
  v_offset   int := greatest(coalesce(p_offset, 0), 0);
  v_desen    text := case when btrim(coalesce(p_arama, '')) = '' then null
                          else public._growth_like_desen(p_arama) end;
  v_kaynak   text := nullif(btrim(coalesce(p_kaynak, '')), '');
  v_kanal    text := nullif(btrim(coalesce(p_izin_kanal, '')), '');
  v_toplam   int;
  v_satirlar jsonb;
begin
  perform public.require_admin();
  if v_kanal is not null and v_kanal not in ('email', 'sms', 'phone', 'push') then
    raise exception 'Geçersiz izin kanalı.' using errcode = '22023';
  end if;

  select count(*)::int into v_toplam
    from public.growth_households h
   where (p_lifecycle is null or h.lifecycle = p_lifecycle)
     and (p_plan is null or h.plan = p_plan)
     and (v_kaynak is null or h.source = v_kaynak or (v_kaynak = 'bilinmiyor' and h.source is null))
     and (v_kanal is null or exists (
            select 1 from public.growth_consent_bridge b
             where b.household_id = h.id and b.channel = v_kanal and b.granted))
     and (v_desen is null or h.parent_name ilike v_desen or h.email ilike v_desen
                          or h.phone ilike v_desen or h.customer_no ilike v_desen);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id), '[]'::jsonb)
    into v_satirlar
    from (
      select h.id, h.customer_no, h.parent_name, h.email, h.phone, h.city,
             h.lifecycle, h.plan, h.subscription_status, h.account_status,
             h.owner_name, h.total_revenue_try, h.lead_score, h.churn_score,
             h.tags, h.last_seen_at, h.next_follow_up_at, h.created_at,
             h.source, h.commercial_consent_overall,
             (select count(*)::int from public.growth_customer_people k
               where k.household_id = h.id and k.person_role = 'student') as cocuk_sayisi
        from public.growth_households h
       where (p_lifecycle is null or h.lifecycle = p_lifecycle)
         and (p_plan is null or h.plan = p_plan)
         and (v_kaynak is null or h.source = v_kaynak or (v_kaynak = 'bilinmiyor' and h.source is null))
         and (v_kanal is null or exists (
                select 1 from public.growth_consent_bridge b
                 where b.household_id = h.id and b.channel = v_kanal and b.granted))
         and (v_desen is null or h.parent_name ilike v_desen or h.email ilike v_desen
                              or h.phone ilike v_desen or h.customer_no ilike v_desen)
       order by h.created_at desc, h.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('rows', v_satirlar, 'total', v_toplam);
end;
$f$;

-- Veri toplama özeti: hangi kaynaktan kaç kişi, hangi kanalda ulaşılabilir, kart ne kadar dolu.
create or replace function public.admin_musteri_360_ozet()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $f$
declare
  v jsonb;
begin
  perform public.require_admin();

  select jsonb_build_object(
    'toplam', count(*),
    'son_7_gun', count(*) filter (where h.created_at > now() - interval '7 days'),
    'telefonlu', count(*) filter (where h.phone is not null),
    'cocuklu', count(*) filter (where exists (
        select 1 from public.growth_customer_people k
         where k.household_id = h.id and k.person_role = 'student')),
    'izin_email', count(*) filter (where exists (
        select 1 from public.growth_consent_bridge b where b.household_id = h.id and b.channel = 'email' and b.granted)),
    'izin_sms', count(*) filter (where exists (
        select 1 from public.growth_consent_bridge b where b.household_id = h.id and b.channel = 'sms' and b.granted)),
    'izin_phone', count(*) filter (where exists (
        select 1 from public.growth_consent_bridge b where b.household_id = h.id and b.channel = 'phone' and b.granted)),
    'izin_push', count(*) filter (where exists (
        select 1 from public.growth_consent_bridge b where b.household_id = h.id and b.channel = 'push' and b.granted)),
    'kaynaklar', coalesce((
        select jsonb_agg(jsonb_build_object('kaynak', s.kaynak, 'adet', s.adet) order by s.adet desc)
          from (select coalesce(g.source, 'bilinmiyor') as kaynak, count(*)::int as adet
                  from public.growth_households g group by 1) s), '[]'::jsonb)
  ) into v
  from public.growth_households h;

  return v;
end;
$f$;

-- ---------------------------------------------------------------------
-- 8. Yetkiler
-- ---------------------------------------------------------------------
revoke execute on function
  public._growth_lifecycle_sira(public.growth_lifecycle_stage),
  public._growth_hane_upsert(text, text, text, text, uuid, public.growth_lifecycle_stage),
  public._growth_olay_yaz(uuid, text, jsonb),
  public._growth_izin_yaz(uuid, text, boolean, text, text, boolean),
  public._growth_profil_esle(uuid, boolean),
  public._growth_abonelik_esle(uuid),
  public._growth_odeme_esle(uuid),
  public._growth_aday_esle(uuid, boolean),
  public._growth_on_kayit_esle(uuid, boolean),
  public._growth_tetik_profil(),
  public._growth_tetik_abonelik(),
  public._growth_tetik_odeme(),
  public._growth_tetik_aday(),
  public._growth_tetik_on_kayit()
  from public, anon, authenticated;

revoke execute on function public.admin_musteri_360_listele(text, public.growth_lifecycle_stage, public.growth_plan, int, int, text, text) from public, anon;
revoke execute on function public.admin_musteri_360_ozet() from public, anon;
grant  execute on function public.admin_musteri_360_listele(text, public.growth_lifecycle_stage, public.growth_plan, int, int, text, text) to authenticated;
grant  execute on function public.admin_musteri_360_ozet() to authenticated;
