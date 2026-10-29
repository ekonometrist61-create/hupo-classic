set client_encoding = 'UTF8';

-- =====================================================================
-- Growth KVKK ve hane birleştirme (GÖR-W4, 2026-10-27)
--
--  Önkoşul : 20260920000900 (require_admin, log_admin_action, admin_audit_log)
--            20261014000000 (growth_* tablolar)
--            20261014000100 (admin_musteri_360_detay, admin_lead_asama, admin_prospect_*)
--            20261027000000 (_growth_hane_upsert, growth_household_izinleri, listele, ozet)
--            20261050000500 (export_my_data güncel tanımı; bu dosya onu genişletir)
--
--  NE EKLİYOR?
--    kolon   : growth_households.owner_user_id, merged_into, merged_at
--    iç      : _growth_ucretli_aktif_mi, _growth_lead_hane_bagla (istemciye KAPALI)
--    KVKK    : admin_growth_hane_anonimlestir  (kalıcı silme, aktif ücretli abonelikte reddeder)
--              admin_growth_hane_disa_aktar    (erişim hakkı, JSON dökümü)
--    birleşt.: admin_growth_hane_birlestir     (kaynak soft-delete: merged_into)
--    lead    : admin_growth_lead_haneye_bagla  (prospect'in lead'ine hane bağlar / üretir)
--              admin_lead_asama               (won geçişinde hane bağlama kancası eklenir)
--    sahip   : admin_growth_hane_sahip_ata     (owner = admin kullanıcı kimliği)
--    360     : admin_musteri_360_listele/detay/ozet birleştirilmiş (merged_into dolu) kayıtları gizler
--    export  : export_my_data 'growth' bölümü (çağıranın kendi hanesi)
--
--  KURALLAR
--    * Tüm admin RPC'ler ilk ifadede require_admin() çağırır; anon revoke edilir.
--    * SECURITY DEFINER + set search_path = ''; gövdedeki her nesne public. ile nitelenir.
--    * Denetim (admin_audit_log) PII içermez: ad, e-posta, telefon, adres, serbest metin
--      neden yazılmaz; yalnızca kayıt kimlikleri, sayılar ve değişen alan adları.
--    * Silme nedeni serbest metindir ve PII içerebilir; denetime yalnızca karakter sayısı yazılır.
--    * Kurum muhasebe kaydı core'da (payments) kalır; growth_financial_transactions CRM
--      projeksiyonudur ve hane silinince birlikte silinir.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Kolonlar
-- ---------------------------------------------------------------------
alter table public.growth_households
  add column if not exists owner_user_id uuid references public.profiles (id) on delete set null,
  add column if not exists merged_into uuid,
  add column if not exists merged_at timestamptz;

-- Birleştirilmiş (soft-delete) kayıtlar: merged_into dolu. Bilerek FK yok; ana kayıt silinse de
-- kaynak kayıt gizli kalır ve anonim kalır.
create index if not exists growth_households_merged_idx
  on public.growth_households (merged_into) where merged_into is not null;

-- ---------------------------------------------------------------------
-- 2. İç yardımcılar (istemciye kapalı)
-- ---------------------------------------------------------------------

-- Hanenin ücretli aktif aboneliği var mı? Core abonelik (fiyat > 0, süre dolmamış),
-- projeksiyon (core'u olmayan kurumsal hane) veya hane özet durumu ('active').
create or replace function public._growth_ucretli_aktif_mi(p_household_id uuid)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $f$
declare
  v_h public.growth_households%rowtype;
begin
  select * into v_h from public.growth_households h where h.id = p_household_id;
  if not found then
    return false;
  end if;

  if v_h.subscription_status = 'active' then
    return true;
  end if;

  if v_h.core_parent_user_id is not null and exists (
       select 1
         from public.subscriptions s
         join public.plans pl on pl.kod = s.plan_kod
        where s.veli_id = v_h.core_parent_user_id
          and s.durum = 'aktif'
          and s.bitis > now()
          and pl.fiyat_kurus > 0) then
    return true;
  end if;

  return exists (
    select 1
      from public.growth_subscription_projection sp
     where sp.household_id = p_household_id
       and sp.status = 'active'
       and sp.plan in ('premium', 'family')
       and (sp.ends_at is null or sp.ends_at > now()));
end;
$f$;

-- Lead'i bir haneye bağlar. p_household_id verilirse o haneye (elle bağlama).
-- Verilmezse: lead zaten bağlıysa o hane; değilse e-posta eşleşen mevcut hane; yoksa yeni hane.
create or replace function public._growth_lead_hane_bagla(p_lead_id uuid, p_household_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $f$
declare
  l          public.growth_leads%rowtype;
  v_hane     uuid;
  v_onceki   uuid;
  v_yeni     boolean := false;
begin
  select * into l from public.growth_leads where id = p_lead_id for update;
  if not found then
    raise exception 'Lead bulunamadı' using errcode = 'P0002';
  end if;

  if p_household_id is not null then
    if not exists (select 1 from public.growth_households h
                    where h.id = p_household_id and h.merged_into is null) then
      raise exception 'Hane bulunamadı' using errcode = 'P0002';
    end if;
    v_hane := p_household_id;
  elsif l.household_id is not null then
    v_hane := l.household_id;
  else
    select h.id into v_onceki from public.growth_households h
     where lower(h.email) = lower(btrim(l.email)) and h.merged_into is null;

    v_hane := public._growth_hane_upsert(l.email, l.parent_name, l.phone,
                                         coalesce(l.source, 'crm_lead'), null, 'lead');
    if v_hane is null then
      raise exception 'Lead e-posta adresi geçersiz.' using errcode = '22023';
    end if;
    v_yeni := v_onceki is null;
  end if;

  update public.growth_leads
     set household_id = v_hane, updated_at = now()
   where id = p_lead_id;

  perform public.log_admin_action('lead_haneye_baglandi',
    jsonb_build_object('lead_id', p_lead_id, 'household_id', v_hane, 'olusturuldu', v_yeni));

  return jsonb_build_object('lead_id', p_lead_id, 'household_id', v_hane, 'olusturuldu', v_yeni);
end;
$f$;

-- ---------------------------------------------------------------------
-- 3. Lead → hane (prospect üzerinden; won geçişinde admin_lead_asama de çağırır)
-- ---------------------------------------------------------------------
create or replace function public.admin_growth_lead_haneye_bagla(
  p_prospect_id uuid,
  p_household_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $f$
declare
  v_lead_id uuid;
begin
  perform public.require_admin();

  select p.converted_lead_id into v_lead_id
    from public.growth_prospects p where p.id = p_prospect_id;
  if not found then
    raise exception 'Prospect bulunamadı' using errcode = 'P0002';
  end if;
  if v_lead_id is null then
    raise exception 'Bu prospect henüz lead''e dönüştürülmemiş.' using errcode = '23514';
  end if;

  return public._growth_lead_hane_bagla(v_lead_id, p_household_id);
end;
$f$;

-- Aşama değişikliği. Yalnızca 20261014000100 gövdesine 'won' kancası eklenmiştir:
-- lead 'won' olduğunda hane bağlanır (e-posta eşleşmesi varsa mevcut hane kullanılır).
create or replace function public.admin_lead_asama(p_lead_id uuid, p_stage growth_lead_stage)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_eski public.growth_lead_stage;
begin
  perform public.require_admin();
  if p_stage is null then
    raise exception 'Aşama gerekli.' using errcode = '22023';
  end if;

  select l.stage into v_eski from public.growth_leads l where l.id = p_lead_id for update;
  if not found then
    raise exception 'Lead bulunamadı' using errcode = 'P0002';
  end if;

  update public.growth_leads
     set stage = p_stage, updated_at = now()
   where id = p_lead_id;

  perform public.log_admin_action('lead_asamasi_degisti',
    jsonb_build_object('lead_id', p_lead_id, 'eski', v_eski, 'yeni', p_stage));

  if p_stage = 'won' and v_eski is distinct from 'won' then
    perform public._growth_lead_hane_bagla(p_lead_id, null);
  end if;
end;
$$;

-- ---------------------------------------------------------------------
-- 4. Hane sahibi: serbest metin yerine admin kullanıcı kimliği
-- ---------------------------------------------------------------------
create or replace function public.admin_growth_hane_sahip_ata(p_household_id uuid, p_owner_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $f$
declare
  v_ad text;
begin
  perform public.require_admin();

  if not exists (select 1 from public.growth_households h
                  where h.id = p_household_id and h.merged_into is null) then
    raise exception 'Müşteri bulunamadı' using errcode = 'P0002';
  end if;

  if p_owner_id is null then
    v_ad := null;
  else
    select coalesce(nullif(btrim(p.full_name), ''), nullif(btrim(p.username), ''), 'Yönetici')
      into v_ad
      from public.profiles p
     where p.id = p_owner_id and p.role = 'admin';
    if not found then
      raise exception 'Sahip yalnızca admin kullanıcı olabilir.' using errcode = '22023';
    end if;
  end if;

  update public.growth_households
     set owner_user_id = p_owner_id, owner_name = v_ad
   where id = p_household_id;

  perform public.log_admin_action('musteri_sahibi_atandi',
    jsonb_build_object('household_id', p_household_id, 'owner_user_id', p_owner_id));

  return jsonb_build_object('household_id', p_household_id,
                            'owner_user_id', p_owner_id, 'owner_name', v_ad);
end;
$f$;

-- ---------------------------------------------------------------------
-- 5. KVKK erişim hakkı: hane dökümü (JSON)
-- ---------------------------------------------------------------------
create or replace function public.admin_growth_hane_disa_aktar(p_household_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $f$
declare
  h        public.growth_households%rowtype;
  v_kisi   int;
  v_olay   int;
  v_izin   int;
  v_mesaj  int;
  v_odeme  int;
  v_dokum  jsonb;
begin
  perform public.require_admin();

  select * into h from public.growth_households
   where id = p_household_id and merged_into is null;
  if not found then
    raise exception 'Müşteri bulunamadı' using errcode = 'P0002';
  end if;

  v_kisi  := (select count(*) from public.growth_customer_people k where k.household_id = p_household_id);
  v_olay  := (select count(*) from public.growth_events e where e.household_id = p_household_id);
  v_izin  := (select count(*) from public.growth_consent_bridge b where b.household_id = p_household_id);
  v_mesaj := (select count(*) from public.growth_message_log m where m.household_id = p_household_id);
  v_odeme := (select count(*) from public.growth_financial_transactions t where t.household_id = p_household_id);

  v_dokum := jsonb_build_object(
    'olusturulma_tarihi', now(),
    'hane', to_jsonb(h),
    'kisiler', coalesce((
      select jsonb_agg(to_jsonb(k) - 'household_id' order by k.created_at)
        from public.growth_customer_people k where k.household_id = p_household_id), '[]'::jsonb),
    'adresler', coalesce((
      select jsonb_agg(to_jsonb(a) - 'household_id' order by a.created_at)
        from public.growth_customer_addresses a where a.household_id = p_household_id), '[]'::jsonb),
    'olaylar', coalesce((
      select jsonb_agg(jsonb_build_object('olay', e.event_name, 'kaynak', e.source,
                                          'zaman', e.occurred_at, 'ozellikler', e.properties)
                       order by e.occurred_at)
        from public.growth_events e where e.household_id = p_household_id), '[]'::jsonb),
    'izinler', coalesce((
      select jsonb_agg(jsonb_build_object('kanal', b.channel, 'izin', b.granted,
                                          'kaynak', b.source, 'degisim', b.changed_at)
                       order by b.channel)
        from public.growth_consent_bridge b where b.household_id = p_household_id), '[]'::jsonb),
    'mesajlar', coalesce((
      select jsonb_agg(jsonb_build_object('kanal', m.channel, 'durum', m.status,
                                          'gonderim', m.sent_at, 'acilma', m.opened_at,
                                          'tiklama', m.clicked_at, 'donusum', m.converted_at,
                                          'olusturulma', m.created_at)
                       order by m.created_at)
        from public.growth_message_log m where m.household_id = p_household_id), '[]'::jsonb),
    'abonelik', (select v.subscription from public.growth_customer_360 v where v.id = p_household_id),
    'abonelik_projeksiyonu', coalesce((
      select jsonb_agg(to_jsonb(sp) - 'household_id' order by sp.synced_at desc)
        from public.growth_subscription_projection sp where sp.household_id = p_household_id), '[]'::jsonb),
    'ozet_odeme', jsonb_build_object(
      'toplam_tutar_try', h.total_revenue_try,
      'odeme_adedi', h.total_paid_transactions,
      'son_odeme', h.last_payment_at),
    'odemeler', coalesce((
      select jsonb_agg(jsonb_build_object('belge_no', t.document_no, 'tur', t.transaction_type,
                                          'durum', t.status, 'tarih', t.purchase_date,
                                          'tutar_try', t.amount_try, 'iade_try', t.refund_amount_try,
                                          'odeme_tipi', t.payment_type, 'zaman', t.occurred_at,
                                          'fatura_adres', t.billing_address_snapshot)
                       order by t.occurred_at desc)
        from public.growth_financial_transactions t where t.household_id = p_household_id), '[]'::jsonb)
  );

  perform public.log_admin_action('musteri_veri_disa_aktarildi',
    jsonb_build_object('household_id', p_household_id,
                       'sayilar', jsonb_build_object('kisi', v_kisi, 'olay', v_olay, 'izin', v_izin,
                                                     'mesaj', v_mesaj, 'odeme', v_odeme)));

  return v_dokum;
end;
$f$;

-- ---------------------------------------------------------------------
-- 6. KVKK silme: anonimleştirme (geri alınamaz). Aktif ücretli abonelikte reddeder.
--    Hane ve bağlı tüm CRM kayıtları silinir; prospect ve lead'lerdeki kimlik alanları temizlenir.
-- ---------------------------------------------------------------------
create or replace function public.admin_growth_hane_anonimlestir(p_household_id uuid, p_neden text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $f$
declare
  h          public.growth_households%rowtype;
  v_neden_n  int := char_length(btrim(coalesce(p_neden, '')));
  v_lead_ids uuid[];
  v_pros_ids uuid[];
  v_say      jsonb;
  v_pros_n   int;
begin
  perform public.require_admin();

  if v_neden_n < 3 or v_neden_n > 500 then
    raise exception 'Silme nedeni 3-500 karakter olmalı.' using errcode = '22023';
  end if;

  select * into h from public.growth_households where id = p_household_id for update;
  if not found then
    raise exception 'Müşteri bulunamadı' using errcode = 'P0002';
  end if;
  if h.merged_into is not null then
    raise exception 'Birleştirilmiş kayıt doğrudan silinemez; ana kaydı üzerinden işlem yapın.'
      using errcode = '23514';
  end if;
  if public._growth_ucretli_aktif_mi(p_household_id) then
    raise exception 'Aktif ücretli abonelik varken hane silinemez. Önce aboneliği sonlandırın.'
      using errcode = '23514';
  end if;

  -- Hane ile ilişkili lead'ler (hane bağlı ya da bağlı değil ama e-postası aynı) ve prospect'ler.
  select coalesce(array_agg(l.id), '{}') into v_lead_ids
    from public.growth_leads l
   where l.household_id = p_household_id
      or (l.household_id is null and lower(l.email) = lower(h.email));

  select coalesce(array_agg(p.id), '{}') into v_pros_ids
    from public.growth_prospects p
   where p.converted_lead_id = any(v_lead_ids)
      or lower(p.email) = lower(h.email);

  v_say := jsonb_build_object(
    'kisi',                 (select count(*) from public.growth_customer_people where household_id = p_household_id),
    'olay',                 (select count(*) from public.growth_events where household_id = p_household_id),
    'mesaj',                (select count(*) from public.growth_message_log where household_id = p_household_id),
    'journey_kaydi',        (select count(*) from public.growth_journey_enrollments where household_id = p_household_id),
    'gorev',                (select count(*) from public.growth_tasks where household_id = p_household_id),
    'ekip_notu',            (select count(*) from public.growth_team_feed where household_id = p_household_id),
    'destek_talebi',        (select count(*) from public.growth_support_tickets where household_id = p_household_id),
    'adres',                (select count(*) from public.growth_customer_addresses where household_id = p_household_id),
    'finansal_islem',       (select count(*) from public.growth_financial_transactions where household_id = p_household_id),
    'abonelik_projeksiyonu',(select count(*) from public.growth_subscription_projection where household_id = p_household_id),
    'izin',                 (select count(*) from public.growth_household_izinleri where household_id = p_household_id),
    'ogrenci',              (select count(*) from public.growth_students where household_id = p_household_id),
    'kimlik_baglantisi',    (select count(*) from public.growth_identity_links where household_id = p_household_id),
    'ai_oneri',             (select count(*) from public.growth_ai_recommendations where household_id = p_household_id),
    'lead',                 coalesce(array_length(v_lead_ids, 1), 0),
    'firsat',               (select count(*) from public.growth_opportunities
                              where household_id = p_household_id or lead_id = any(v_lead_ids)),
    'birlestirilmis_kayit', (select count(*) from public.growth_households where merged_into = p_household_id)
  );

  -- Prospect: kimlik alanları temizlenir, aday yeniden iletişime girmesin diye 'suppressed' olur.
  update public.growth_prospects p set
    display_name = 'Silinmiş kayıt', first_name = null, last_name = null,
    email = null, phone = null, city = null, district = null, job_title = null,
    anonymous_id = null, source_url = null, notes = '{}', tags = '{}',
    next_best_action = null, next_action_at = null,
    status = 'suppressed', converted_lead_id = null, updated_at = now()
   where p.id = any(v_pros_ids);
  get diagnostics v_pros_n = row_count;

  update public.growth_prospect_events set properties = '{}'::jsonb, title = null, anonymous_id = null
   where prospect_id = any(v_pros_ids);
  update public.growth_prospect_provenance set source_url = null, notes = null
   where prospect_id = any(v_pros_ids);

  -- Lead, fırsat ve özel alan değerleri (hane silinince FK ile bağlar kopar; kimlik kalmasın diye açıkça silinir).
  delete from public.growth_opportunities
   where household_id = p_household_id or lead_id = any(v_lead_ids);
  delete from public.growth_leads where id = any(v_lead_ids);
  delete from public.growth_entity_custom_values where entity_id = p_household_id::text;

  -- Birleştirilmiş kayıtlar (tombstone) bu hanenin devamıdır; onlar da silinir.
  delete from public.growth_households where merged_into = p_household_id;

  -- Hane: kişi, adres, olay, mesaj, journey, görev, ekip notu, destek, izin, finansal projeksiyon
  -- ve kimlik bağları ON DELETE CASCADE ile gider.
  delete from public.growth_households where id = p_household_id;

  perform public.log_admin_action('musteri_hanesi_anonimlestirildi',
    jsonb_build_object('household_id', p_household_id,
                       'neden_karakter_sayisi', v_neden_n,
                       'silinen', v_say,
                       'anonimlestirilen_prospect', v_pros_n));

  return jsonb_build_object('household_id', p_household_id, 'silinen', v_say,
                            'anonimlestirilen_prospect', v_pros_n);
end;
$f$;

-- ---------------------------------------------------------------------
-- 7. Hane birleştirme: kaynak → hedef. Kaynak soft-delete (merged_into), PII temizlenir.
-- ---------------------------------------------------------------------
create or replace function public.admin_growth_hane_birlestir(p_kaynak uuid, p_hedef uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $f$
declare
  s          public.growth_households%rowtype;
  t          public.growth_households%rowtype;
  v_say      jsonb;
  v_uyari    text[] := '{}';
  v_izin     record;
  v_tg       boolean;
  v_toplam   numeric(14,2);
  v_adet     int;
  v_son      timestamptz;
  v_yeni_mail text;
  v_dup_yol  int;
begin
  perform public.require_admin();

  if p_kaynak is null or p_hedef is null or p_kaynak = p_hedef then
    raise exception 'Birleştirme için iki farklı hane gerekir.' using errcode = '22023';
  end if;

  select * into s from public.growth_households where id = p_kaynak for update;
  if not found then
    raise exception 'Kaynak hane bulunamadı' using errcode = 'P0002';
  end if;
  select * into t from public.growth_households where id = p_hedef for update;
  if not found then
    raise exception 'Hedef hane bulunamadı' using errcode = 'P0002';
  end if;
  if s.merged_into is not null or t.merged_into is not null then
    raise exception 'Birleştirilmiş bir hane tekrar birleştirilemez.' using errcode = '23514';
  end if;
  if s.core_parent_user_id is not null and t.core_parent_user_id is not null
     and s.core_parent_user_id <> t.core_parent_user_id then
    raise exception 'İki farklı hesaba bağlı haneler birleştirilemez.' using errcode = '23514';
  end if;

  -- İzin uyarısı: core iletisim_tercihleri öncelikli olduğu için hedefte core izni varsa
  -- kaynağın geri çekmesi otomatik uygulanmaz; bu kanallar yanıtta bildirilir.
  for v_izin in
    select i.channel, i.granted from public.growth_household_izinleri i where i.household_id = s.id
  loop
    if not v_izin.granted and exists (
         select 1 from public.growth_consent_bridge b
          where b.household_id = t.id and b.channel = v_izin.channel and b.granted) then
      v_uyari := v_uyari || ('kanal:' || v_izin.channel);
    end if;
  end loop;

  -- Sayımlar (taşınmadan önce)
  v_say := jsonb_build_object(
    'kisi',                 (select count(*) from public.growth_customer_people where household_id = s.id),
    'olay',                 (select count(*) from public.growth_events where household_id = s.id),
    'mesaj',                (select count(*) from public.growth_message_log where household_id = s.id),
    'gorev',                (select count(*) from public.growth_tasks where household_id = s.id),
    'ekip_notu',            (select count(*) from public.growth_team_feed where household_id = s.id),
    'destek_talebi',        (select count(*) from public.growth_support_tickets where household_id = s.id),
    'lead',                 (select count(*) from public.growth_leads where household_id = s.id),
    'firsat',               (select count(*) from public.growth_opportunities where household_id = s.id),
    'ogrenci',              (select count(*) from public.growth_students where household_id = s.id),
    'adres',                (select count(*) from public.growth_customer_addresses where household_id = s.id),
    'finansal_islem',       (select count(*) from public.growth_financial_transactions where household_id = s.id),
    'abonelik_projeksiyonu',(select count(*) from public.growth_subscription_projection where household_id = s.id),
    'izin',                 (select count(*) from public.growth_household_izinleri where household_id = s.id),
    'kimlik_baglantisi',    (select count(*) from public.growth_identity_links where household_id = s.id),
    'ai_oneri',             (select count(*) from public.growth_ai_recommendations where household_id = s.id),
    'not_dizisi',           coalesce(array_length(s.notes, 1), 0)
  );

  -- Journey kayıtları: hedefte aynı (journey, entered_at) varsa kaynaktaki kopya silinir.
  select count(*)::int into v_dup_yol
    from public.growth_journey_enrollments e
   where e.household_id = s.id
     and exists (select 1 from public.growth_journey_enrollments k
                  where k.household_id = t.id and k.journey_id = e.journey_id and k.entered_at = e.entered_at);
  delete from public.growth_journey_enrollments e
   where e.household_id = s.id
     and exists (select 1 from public.growth_journey_enrollments k
                  where k.household_id = t.id and k.journey_id = e.journey_id and k.entered_at = e.entered_at);

  -- Taşımalar
  update public.growth_customer_people set household_id = t.id, updated_at = now() where household_id = s.id;
  update public.growth_events set household_id = t.id where household_id = s.id;
  update public.growth_message_log set household_id = t.id where household_id = s.id;
  update public.growth_journey_enrollments set household_id = t.id where household_id = s.id;
  update public.growth_tasks set household_id = t.id where household_id = s.id;
  update public.growth_team_feed set household_id = t.id where household_id = s.id;
  update public.growth_support_tickets set household_id = t.id where household_id = s.id;
  update public.growth_leads set household_id = t.id where household_id = s.id;
  update public.growth_opportunities set household_id = t.id where household_id = s.id;
  update public.growth_students set household_id = t.id where household_id = s.id;
  update public.growth_customer_addresses set household_id = t.id where household_id = s.id;
  update public.growth_subscription_projection set household_id = t.id where household_id = s.id;
  update public.growth_financial_transactions set household_id = t.id where household_id = s.id;
  update public.growth_ai_recommendations set household_id = t.id where household_id = s.id;

  -- Kimlik bağları: çakışanlar kopyadır, silinir.
  delete from public.growth_identity_links e
   where e.household_id = s.id
     and exists (select 1 from public.growth_identity_links k
                  where k.household_id = t.id and k.anonymous_id = e.anonymous_id);
  update public.growth_identity_links set household_id = t.id where household_id = s.id;

  -- Özel alan değerleri (entity_id metin olarak hane kimliği)
  update public.growth_entity_custom_values v set entity_id = t.id::text
   where v.entity_id = s.id::text
     and not exists (select 1 from public.growth_entity_custom_values x
                      where x.field_id = v.field_id and x.entity_id = t.id::text);
  delete from public.growth_entity_custom_values where entity_id = s.id::text;

  -- İzinler: iki tarafta da varsa daha kısıtlayıcı (AND) korunur; yalnız kaynakta varsa kopyalanır.
  for v_izin in
    select i.channel, i.granted, i.source, i.surum
      from public.growth_household_izinleri i where i.household_id = s.id
  loop
    select x.granted into v_tg from public.growth_household_izinleri x
     where x.household_id = t.id and x.channel = v_izin.channel;
    perform public._growth_izin_yaz(t.id, v_izin.channel,
                                    v_izin.granted and coalesce(v_tg, true),
                                    'birlestirme', v_izin.surum);
  end loop;
  delete from public.growth_household_izinleri where household_id = s.id;

  -- Core hesap bağı: hedefte yoksa kaynaktan taşınır (core tercihleri veli_id ile zaten hedefe bakar).
  if s.core_parent_user_id is not null and t.core_parent_user_id is null then
    update public.growth_households set core_parent_user_id = null where id = s.id;
    update public.growth_households set core_parent_user_id = s.core_parent_user_id where id = t.id;
  end if;

  -- Hedef alanları: boş olanlar kaynaktan doldurulur; not/etiket birleşir; yaşam döngüsü ilerisi kalır.
  select coalesce(sum(x.amount_try), 0), count(*)::int, max(x.occurred_at)
    into v_toplam, v_adet, v_son
    from public.growth_financial_transactions x
   where x.household_id = t.id and x.status = 'paid';

  update public.growth_households set
    notes = (select coalesce(array_agg(distinct n order by n), '{}') from unnest(t.notes || s.notes) n),
    tags  = (select coalesce(array_agg(distinct g order by g), '{}') from unnest(t.tags || s.tags) g),
    phone = coalesce(t.phone, s.phone),
    city = coalesce(t.city, s.city),
    first_name = coalesce(t.first_name, s.first_name),
    last_name = coalesce(t.last_name, s.last_name),
    lifecycle = case when public._growth_lifecycle_sira(s.lifecycle) > public._growth_lifecycle_sira(t.lifecycle)
                     then s.lifecycle else t.lifecycle end,
    total_revenue_try = v_toplam,
    ltv = v_toplam,
    total_paid_transactions = v_adet,
    last_payment_at = v_son
   where id = t.id;

  -- Kaynak: e-posta benzersizliğini bozmamak için yeniden adlandırılır, kimlik alanları temizlenir.
  v_yeni_mail := 'birlesti-' || s.id::text || '@anonim.invalid';
  update public.growth_households set
    email = v_yeni_mail, parent_name = 'Birleştirilmiş kayıt',
    first_name = null, last_name = null, phone = null, city = null, country = null, region = null,
    district = null, nationality = null, gender = null, birth_date = null, national_id_last4 = null,
    utm_source = null, utm_medium = null, utm_campaign = null, referral_code = null,
    owner_name = null, owner_user_id = null, notes = '{}', tags = '{}', target_schools = '{}',
    exam_goal = null, core_parent_user_id = null,
    merged_into = t.id, merged_at = now(),
    total_revenue_try = 0, ltv = 0, total_paid_transactions = 0, last_payment_at = null
   where id = s.id;

  perform public.log_admin_action('musteri_haneleri_birlestirildi',
    jsonb_build_object('kaynak_id', s.id, 'hedef_id', t.id, 'tasinan', v_say,
                       'journey_tekrar_silinen', v_dup_yol, 'izin_uyari_kanallari', to_jsonb(v_uyari)));

  return jsonb_build_object('kaynak_id', s.id, 'hedef_id', t.id, 'tasinan', v_say,
                            'journey_tekrar_silinen', v_dup_yol, 'uyarilar', to_jsonb(v_uyari));
end;
$f$;

-- ---------------------------------------------------------------------
-- 8. Müşteri 360: birleştirilmiş (merged_into dolu) kayıtlar listede ve detayda görünmez.
--    Gövdeler 20261014000100 (detay) ve 20261027000000 (listele, ozet) ile aynıdır; yalnız filtre eklenmiştir.
-- ---------------------------------------------------------------------
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
   where h.merged_into is null
     and (p_lifecycle is null or h.lifecycle = p_lifecycle)
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
       where h.merged_into is null
         and (p_lifecycle is null or h.lifecycle = p_lifecycle)
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

create or replace function public.admin_musteri_360_detay(p_household_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_hane        jsonb;
  v_cocuklar    jsonb;
  v_abonelik    jsonb;
  v_izinler     jsonb;
  v_kisiler     jsonb;
  v_adresler    jsonb;
  v_islemler    jsonb;
  v_projeksiyon jsonb;
  v_olaylar     jsonb;
  v_ekip        jsonb;
  v_destek      jsonb;
begin
  perform public.require_admin();

  if exists (select 1 from public.growth_households h
              where h.id = p_household_id and h.merged_into is not null) then
    raise exception 'Müşteri bulunamadı' using errcode = 'P0002';
  end if;

  -- Hane skaler alanları; iç içe bölümler ayrı anahtarlarda döner.
  select to_jsonb(v) - 'children' - 'addresses' - 'transactions' - 'subscription',
         v.children,
         v.subscription
    into v_hane, v_cocuklar, v_abonelik
    from public.growth_customer_360 v
   where v.id = p_household_id;
  if v_hane is null then
    raise exception 'Müşteri bulunamadı' using errcode = 'P0002';
  end if;

  -- Kanal bazlı izin (core iletisim_tercihleri, growth_consent_bridge üzerinden).
  select coalesce(jsonb_agg(jsonb_build_object(
           'kanal', b.channel, 'izin', b.granted, 'kaynak', b.source, 'degisim', b.changed_at
         ) order by b.channel), '[]'::jsonb)
    into v_izinler
    from public.growth_consent_bridge b
   where b.household_id = p_household_id;

  -- Hane kişileri. TC kimlik yalnızca son 4 hane, maskeli.
  select coalesce(jsonb_agg(to_jsonb(k) order by k.created_at), '[]'::jsonb)
    into v_kisiler
    from (
      select kp.id, kp.person_role, kp.core_person_id, kp.core_student_id,
             kp.first_name, kp.last_name,
             case when kp.national_id_last4 is null then null
                  else '*******' || kp.national_id_last4 end as national_id_masked,
             kp.birth_date, kp.gender, kp.nationality, kp.grade, kp.phone, kp.email,
             kp.active, kp.created_at
        from public.growth_customer_people kp
       where kp.household_id = p_household_id
    ) k;

  select coalesce(jsonb_agg(to_jsonb(a) order by a.is_default desc, a.created_at), '[]'::jsonb)
    into v_adresler
    from public.growth_customer_addresses a
   where a.household_id = p_household_id;

  select coalesce(jsonb_agg(to_jsonb(t) order by t.occurred_at desc), '[]'::jsonb)
    into v_islemler
    from (
      select * from public.growth_financial_transactions
       where household_id = p_household_id
       order by occurred_at desc
       limit 50
    ) t;

  select coalesce(jsonb_agg(to_jsonb(sp) order by sp.synced_at desc), '[]'::jsonb)
    into v_projeksiyon
    from (
      select * from public.growth_subscription_projection
       where household_id = p_household_id
       order by synced_at desc
       limit 10
    ) sp;

  select coalesce(jsonb_agg(to_jsonb(e) order by e.occurred_at desc), '[]'::jsonb)
    into v_olaylar
    from (
      select ge.id, ge.event_name, ge.source, ge.occurred_at, ge.student_id,
             ge.properties, ge.utm, ge.session_id
        from public.growth_events ge
       where ge.household_id = p_household_id
       order by ge.occurred_at desc
       limit 50
    ) e;

  select coalesce(jsonb_agg(to_jsonb(f) order by f.created_at desc), '[]'::jsonb)
    into v_ekip
    from (
      select * from public.growth_team_feed
       where household_id = p_household_id
       order by created_at desc
       limit 30
    ) f;

  select coalesce(jsonb_agg(to_jsonb(s) order by s.created_at desc), '[]'::jsonb)
    into v_destek
    from (
      select * from public.growth_support_tickets
       where household_id = p_household_id
       order by created_at desc
       limit 20
    ) s;

  return jsonb_build_object(
    'musteri', v_hane,
    'cocuklar', v_cocuklar,
    'iletisim_izinleri', v_izinler,
    'kisiler', v_kisiler,
    'adresler', v_adresler,
    'abonelik', v_abonelik,
    'abonelik_projeksiyonu', v_projeksiyon,
    'islemler', v_islemler,
    'olaylar', v_olaylar,
    'ekip_akisi', v_ekip,
    'destek_talepleri', v_destek
  );
end;
$function$;

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
                  from public.growth_households g where g.merged_into is null group by 1) s), '[]'::jsonb)
  ) into v
  from public.growth_households h
  where h.merged_into is null;

  return v;
end;
$f$;

-- ---------------------------------------------------------------------
-- 9. export_my_data: 'growth' bölümü (çağıranın kendi hanesi). Mevcut tüm anahtarlar
--    (kelime, okuma dahil) 20261050000500 gövdesiyle aynen korunur.
-- ---------------------------------------------------------------------
create or replace function public.export_my_data()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid  uuid := (select auth.uid());
  v_hane uuid;
begin
  if v_uid is null then
    raise exception 'Oturum gerekli' using errcode = '42501';
  end if;

  select h.id into v_hane
    from public.growth_households h
   where h.core_parent_user_id = v_uid and h.merged_into is null
   order by h.created_at
   limit 1;

  return jsonb_build_object(
    'olusturulma_tarihi', now(),
    'profil', (
      select jsonb_build_object(
               'id', p.id, 'rol', p.role, 'ad_soyad', p.full_name,
               'kullanici_adi', p.username, 'sinif', p.sinif, 'okul', p.okul,
               'veli_id', p.parent_id, 'uyelik_tarihi', p.created_at,
               'sosyal_ozellikler_acik', p.sosyal_ozellikler_acik,
               'arkadas_ekleme_acik', p.arkadas_ekleme_acik)
        from public.profiles p where p.id = v_uid),
    'istatistikler', (
      select to_jsonb(s) - 'student_id' from public.student_stats s where s.student_id = v_uid),
    'cevaplar', coalesce((
      select jsonb_agg(jsonb_build_object(
               'soru_id', ua.question_id, 'secilen_sik', ua.secilen_sik,
               'dogru_mu', ua.dogru_mu, 'deneme_sayisi', ua.deneme_sayisi,
               'dogru_sayisi', ua.dogru_sayisi, 'son_cevap_tarihi', ua.son_cevap_tarihi)
             order by ua.son_cevap_tarihi)
        from public.user_answers ua where ua.student_id = v_uid), '[]'::jsonb),
    'rozetler', coalesce((
      select jsonb_agg(jsonb_build_object('rozet', b.badge_code, 'tarih', b.earned_at))
        from public.user_badges b where b.student_id = v_uid), '[]'::jsonb),
    'bildirimler', coalesce((
      select jsonb_agg(jsonb_build_object(
               'tur', n.tur, 'baslik', n.baslik, 'mesaj', n.mesaj, 'tarih', n.created_at)
             order by n.created_at)
        from public.notifications n where n.alici_id = v_uid), '[]'::jsonb),
    'xp_gecmisi', coalesce((
      select jsonb_agg(jsonb_build_object('xp', x.xp, 'tarih', x.created_at) order by x.created_at)
        from public.xp_events x where x.student_id = v_uid), '[]'::jsonb),
    'onaylar', coalesce((
      select jsonb_agg(jsonb_build_object('tur', c.tur, 'surum', c.surum, 'tarih', c.created_at)
             order by c.created_at)
        from public.consents c where c.cocuk_id = v_uid), '[]'::jsonb),
    'kelime', jsonb_build_object(
      'denemeler', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'soru_id', d.soru_id, 'anlam_id', d.anlam_id,
                 'secilen_indeks', d.secilen_indeks, 'dogru_mu', d.dogru_mu,
                 'ipucu_kullanildi', d.ipucu_kullanildi, 'kazanilan_xp', d.kazanilan_xp,
                 'tarih', d.created_at)
               order by d.created_at)
          from public.kelime_denemeleri d where d.ogrenci_id = v_uid), '[]'::jsonb),
      'ustaliklar', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'anlam_id', u.anlam_id, 'beceri', u.beceri,
                 'basari_seviyesi', u.basari_seviyesi,
                 'sonraki_tekrar_tarihi', u.sonraki_tekrar_tarihi,
                 'son_cevap_tarihi', u.son_cevap_tarihi)
               order by u.guncellendi)
          from public.kelime_ustaliklari u where u.ogrenci_id = v_uid), '[]'::jsonb),
      'kaydedilenler', coalesce((
        select jsonb_agg(jsonb_build_object('anlam_id', k.anlam_id, 'tarih', k.created_at)
                         order by k.created_at)
          from public.kelime_kaydedilenler k where k.ogrenci_id = v_uid), '[]'::jsonb)
    ),
    'okuma', jsonb_build_object(
      -- Yalnızca çağıranın kendi satırları. Soru anahtarı (doğru şık / açıklama) ve iç anahtarlar
      -- (istemci_anahtari, sürüm kimliği, XP bayrakları, veli kimliği) dışarı çıkmaz;
      -- cevapta yalnızca çocuğun seçtiği şık ve sonucu ('dogru_mu') bulunur.
      'oturumlari', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'oturum_id', o.id, 'hikaye', h.slug, 'kahraman_turu', o.kahraman_turu,
                 'yoldas_var', o.yoldas_var, 'okuma_modu', o.okuma_modu, 'sinif', o.sinif, 'gun', o.gun,
                 'baslangic', o.baslangic_at, 'son_sayfa', o.son_sayfa, 'tamamlandi', o.tamamlandi_at,
                 'soru_sayisi', o.soru_sayisi, 'dogru_sayisi', o.dogru_sayisi,
                 'beceri_sonuclari', o.beceri_sonuclari, 'dokunulan_hedefler', o.dokunulan_hedefler,
                 'kazanilan_xp', o.kazanilan_xp)
               order by o.baslangic_at)
          from public.okuma_oturumlari o
          join public.okuma_hikayeleri h on h.id = o.hikaye_id
         where o.ogrenci_id = v_uid), '[]'::jsonb),
      'cevaplari', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'oturum_id', c.oturum_id, 'soru_id', c.soru_id, 'secilen_sik', c.secenek_id,
                 'dogru_mu', c.dogru, 'beceri', c.beceri, 'hedef_id', c.hedef_id,
                 'olcme_turu', c.olcme_turu, 'tarih', c.created_at)
               order by c.created_at, c.soru_id)
          from public.okuma_cevaplari c
          join public.okuma_oturumlari o on o.id = c.oturum_id
         where o.ogrenci_id = v_uid), '[]'::jsonb),
      'geri_bildirimleri', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'oturum_id', g.oturum_id, 'yildiz', g.yildiz, 'iyilestirme_kodlari', g.iyilestirme_kodlari,
                 'baska_kahraman', g.baska_kahraman, 'ayni_turden', g.ayni_turden,
                 'sorun_kodlari', g.sorun_kodlari, 'tarih', g.created_at)
               order by g.created_at)
          from public.okuma_geri_bildirimleri g
          join public.okuma_oturumlari o on o.id = g.oturum_id
         where o.ogrenci_id = v_uid), '[]'::jsonb),
      'ogrenci_hedef_durumu', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'hedef_id', d.hedef_id, 'durum', d.durum, 'ilk_gorulme', d.ilk_gorulme_at,
                 'son_dogru', d.son_dogru_at, 'tekrar', d.tekrar_at, 'hata_turu', d.hata_turu)
               order by d.ilk_gorulme_at, d.hedef_id)
          from public.okuma_ogrenci_hedef_durumu d where d.ogrenci_id = v_uid), '[]'::jsonb),
      'pdf_kullanimlari', coalesce((
        select jsonb_agg(jsonb_build_object('hikaye', h.slug, 'ay', u.ay, 'tarih', u.created_at)
                         order by u.created_at)
          from public.okuma_pdf_kullanimlari u
          join public.okuma_hikayeleri h on h.id = u.hikaye_id
         where u.kullanici_id = v_uid), '[]'::jsonb),
      'cocuk_tercihleri', (
        select jsonb_build_object('degerler', t.degerler, 'guncellendi', t.guncellendi_at)
          from public.okuma_cocuk_tercihleri t where t.cocuk_id = v_uid)
    ),
    -- Growth: çağıranın kendi hanesi. Yalnızca kendi olayları, izinleri ve mesaj günlüğü özeti
    -- (içerik gövdesi, sağlayıcı kimliği ve kimlik alanları dışarıdadır).
    'growth', jsonb_build_object(
      'hane', (
        select jsonb_build_object('musteri_no', h.customer_no, 'olusturulma_tarihi', h.created_at,
                                  'yasam_dongusu', h.lifecycle, 'plan', h.plan,
                                  'abonelik_durumu', h.subscription_status)
          from public.growth_households h where h.id = v_hane),
      'olaylar', coalesce((
        select jsonb_agg(jsonb_build_object('olay', e.event_name, 'kaynak', e.source, 'tarih', e.occurred_at)
                         order by e.occurred_at)
          from public.growth_events e where e.household_id = v_hane), '[]'::jsonb),
      'izinler', coalesce((
        select jsonb_agg(jsonb_build_object('kanal', b.channel, 'izin', b.granted,
                                            'kaynak', b.source, 'degisim', b.changed_at)
                         order by b.channel)
          from public.growth_consent_bridge b where b.household_id = v_hane), '[]'::jsonb),
      'mesaj_gunlugu_ozeti', coalesce((
        select jsonb_agg(jsonb_build_object('kanal', m.kanal, 'durum', m.durum, 'adet', m.adet)
                         order by m.kanal, m.durum)
          from (
            select ml.channel as kanal, ml.status as durum, count(*)::int as adet
              from public.growth_message_log ml
             where ml.household_id = v_hane
             group by ml.channel, ml.status
          ) m), '[]'::jsonb)
    )
  );
end;
$$;

-- ---------------------------------------------------------------------
-- 10. Yetkiler: admin RPC'ler yalnız authenticated (içeride require_admin); iç yardımcılar kapalı.
-- ---------------------------------------------------------------------
revoke execute on function
  public._growth_ucretli_aktif_mi(uuid),
  public._growth_lead_hane_bagla(uuid, uuid)
  from public, anon, authenticated;

revoke execute on function
  public.admin_growth_lead_haneye_bagla(uuid, uuid),
  public.admin_growth_hane_sahip_ata(uuid, uuid),
  public.admin_growth_hane_disa_aktar(uuid),
  public.admin_growth_hane_anonimlestir(uuid, text),
  public.admin_growth_hane_birlestir(uuid, uuid),
  public.admin_lead_asama(uuid, growth_lead_stage),
  public.admin_musteri_360_detay(uuid),
  public.admin_musteri_360_ozet()
  from public, anon;

grant execute on function
  public.admin_growth_lead_haneye_bagla(uuid, uuid),
  public.admin_growth_hane_sahip_ata(uuid, uuid),
  public.admin_growth_hane_disa_aktar(uuid),
  public.admin_growth_hane_anonimlestir(uuid, text),
  public.admin_growth_hane_birlestir(uuid, uuid),
  public.admin_lead_asama(uuid, growth_lead_stage),
  public.admin_musteri_360_detay(uuid),
  public.admin_musteri_360_ozet()
  to authenticated;

revoke execute on function public.admin_musteri_360_listele(text, public.growth_lifecycle_stage, public.growth_plan, int, int, text, text)
  from public, anon;
grant  execute on function public.admin_musteri_360_listele(text, public.growth_lifecycle_stage, public.growth_plan, int, int, text, text)
  to authenticated;

revoke execute on function public.export_my_data() from public, anon;
grant  execute on function public.export_my_data() to authenticated;
