set client_encoding = 'UTF8';

-- =====================================================================
--  Growth CRM: admin RPC katmanı
--  (müşteri 360, prospect, lead, CRM görevi, destek, ekip akışı)
--  Tarih : 2026-10-14
--  Ön koşul: 20260920000900_admin_role_and_payments.sql  (require_admin, log_admin_action)
--            20261014000000_growth_crm_core.sql           (growth_* tablolar ve view'lar)
--
--  NE EKLİYOR?
--    iç yardımcı : _growth_like_desen, _growth_metin_dizi,
--                  _growth_email_normalize, _growth_skor_kaydet        (istemciye KAPALI)
--    müşteri 360 : admin_musteri_360_listele, admin_musteri_360_detay,
--                  admin_musteri_360_guncelle
--    prospect    : admin_prospect_listele, admin_prospect_kaydet,
--                  admin_prospect_detay, admin_prospect_guncelle,
--                  admin_prospect_lead_donustur
--    lead        : admin_lead_listele, admin_lead_kaydet, admin_lead_asama
--    CRM görevi  : admin_crm_gorev_listele, admin_crm_gorev_kaydet
--    destek      : admin_destek_listele, admin_destek_kaydet
--    ekip akışı  : admin_ekip_akisi_listele, admin_ekip_akisi_ekle
--
--  GÜVENLİK
--    * Her public fonksiyon SECURITY DEFINER + set search_path = '' ve İLK ifadesi
--      public.require_admin(). Tüm tablo/fonksiyon referansları şema-nitelikli.
--    * growth_* tabloları RLS açık ve policy'sizdir; istemci doğrudan erişemez.
--      Yalnızca bu RPC'ler (tablo sahibi yetkisiyle) okur/yazar.
--    * Her mutasyon public.log_admin_action ile denetim izine yazılır. Denetim
--      detayına PII (ad, e-posta, telefon, not, mesaj gövdesi) YAZILMAZ; yalnızca
--      kayıt id'leri ve değişen alanların ADLARI.
--    * Kanal izni bu katmandan DEĞİŞTİRİLMEZ. growth_households.commercial_consent_overall
--      ve core iletisim_tercihleri bu RPC'lerle yazılamaz; kanal izni core'daki
--      gerekçeli admin_veli_tercih_ayarla ile yönetilir (admin yalnızca geri çekebilir).
--    * Prospect: 'converted' durumu yalnızca admin_prospect_lead_donustur ile atanır.
--      'suppressed' ve 'disqualified' prospect lead'e dönüştürülemez.
--    * Prospect verisi yalnızca kamuya açık B2B veya rızalı birinci taraf veri olmalıdır
--      (growth_crm_core başlığı). Kaynak kanalı her kayıtta zorunludur ve provenance
--      satırı yazılır. Çocuk kimlikleri ad hedefleme kitlesine aktarılmaz.
--
--  ARAMA / SAYFALAMA
--    * Arama ILIKE ile yapılır; girdideki % _ \ karakterleri kaçışlanır (literal arama).
--      Büyük hacimde pg_trgm GIN indeksi gerekir (ayrı sprint).
--    * limit en fazla 100, offset >= 0. Liste yanıtı: { rows: [...], total: n }.
--
--  İNDEKSLER (bu dosyada; mevcut indeksler core migration'da)
--    growth_tasks(household_id, due_at), growth_tasks(lead_id, due_at),
--    growth_support_tickets(household_id, created_at desc),
--    growth_team_feed(lead_id, created_at desc),
--    growth_prospect_provenance(prospect_id, collected_at desc),
--    growth_prospects(kind, status), growth_leads(updated_at desc)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. İç yardımcılar (istemciye KAPALI)
-- ---------------------------------------------------------------------

-- ILIKE deseni: kullanıcı girdisindeki % _ \ karakterleri literal olarak aranır.
create or replace function public._growth_like_desen(p_metin text)
returns text
language sql
immutable
set search_path = ''
as $function$
  select '%' || replace(replace(replace(btrim(p_metin), '\', '\\'), '%', '\%'), '_', '\_') || '%';
$function$;

-- jsonb dizisini text[] yapar; dizi değilse (null dahil) boş dizi döner.
create or replace function public._growth_metin_dizi(p_json jsonb)
returns text[]
language sql
immutable
set search_path = ''
as $function$
  select case when jsonb_typeof(p_json) = 'array'
              then array(select jsonb_array_elements_text(p_json))
              else '{}'::text[] end;
$function$;

-- E-postayı normalize eder (lower + trim). Boşsa NULL; biçim geçersizse hata.
create or replace function public._growth_email_normalize(p_email text)
returns text
language plpgsql
immutable
set search_path = ''
as $function$
declare
  v_email text := lower(btrim(coalesce(p_email, '')));
begin
  if v_email = '' then
    return null;
  end if;
  if v_email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    raise exception 'Geçersiz e-posta adresi.' using errcode = '22023';
  end if;
  return v_email;
end;
$function$;

-- Prospect skor anlık görüntüsü (score history). Yalnızca RPC içinden çağrılır.
create or replace function public._growth_skor_kaydet(p_prospect_id uuid, p_model text)
returns void
language sql
security definer
set search_path = ''
as $function$
  insert into public.growth_prospect_score_history
    (prospect_id, fit_score, intent_score, engagement_score, data_quality_score,
     penalty, total_score, reasons, model_version)
  select p.id, p.fit_score, p.intent_score, p.engagement_score, p.data_quality_score,
         p.score_penalty, p.total_score, p.score_reasons, p_model
    from public.growth_prospects p
   where p.id = p_prospect_id;
$function$;

-- ---------------------------------------------------------------------
-- 1. MÜŞTERİ 360 (growth_households tabanlı)
-- ---------------------------------------------------------------------

-- 1.1 Liste. Hafif hane kolonları; ağır 360 view'i (alt sorgular) listede kullanılmaz.
create or replace function public.admin_musteri_360_listele(
  p_arama      text default '',
  p_lifecycle  growth_lifecycle_stage default null,
  p_plan       growth_plan default null,
  p_limit      int default 25,
  p_offset     int default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_limit    int := least(greatest(coalesce(p_limit, 25), 1), 100);
  v_offset   int := greatest(coalesce(p_offset, 0), 0);
  v_desen    text := case when btrim(coalesce(p_arama, '')) = '' then null
                          else public._growth_like_desen(p_arama) end;
  v_toplam   int;
  v_satirlar jsonb;
begin
  perform public.require_admin();

  select count(*)::int into v_toplam
    from public.growth_households h
   where (p_lifecycle is null or h.lifecycle = p_lifecycle)
     and (p_plan is null or h.plan = p_plan)
     and (v_desen is null or h.parent_name ilike v_desen
                          or h.email ilike v_desen
                          or h.phone ilike v_desen);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id), '[]'::jsonb)
    into v_satirlar
    from (
      select h.id, h.customer_no, h.parent_name, h.email, h.phone, h.city,
             h.lifecycle, h.plan, h.subscription_status, h.account_status,
             h.owner_name, h.total_revenue_try, h.lead_score, h.churn_score,
             h.tags, h.last_seen_at, h.next_follow_up_at, h.created_at
        from public.growth_households h
       where (p_lifecycle is null or h.lifecycle = p_lifecycle)
         and (p_plan is null or h.plan = p_plan)
         and (v_desen is null or h.parent_name ilike v_desen
                              or h.email ilike v_desen
                              or h.phone ilike v_desen)
       order by h.created_at desc, h.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('rows', v_satirlar, 'total', v_toplam);
end;
$function$;

-- 1.2 Tek müşteri detayı. Çocuklar + abonelik view'den (core + growth birleşik),
--     diğer bölümler doğrudan tablolardan ve sınırlı sayıda okunur.
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

-- 1.3 Güncelleme. Yalnızca beyaz listedeki alanlar yazılır; bilinmeyen alan hata verir.
--     Kanal izni ve konsent alanları (commercial_consent_overall) BU RPC'de yoktur.
create or replace function public.admin_musteri_360_guncelle(p_household_id uuid, p_data jsonb)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_alanlar text[];
  v_izinsiz text[];
begin
  perform public.require_admin();
  if p_data is null or jsonb_typeof(p_data) <> 'object' then
    raise exception 'Güncelleme verisi nesne olmalı.' using errcode = '22023';
  end if;

  select array_agg(x.k order by x.k) into v_alanlar
    from jsonb_object_keys(p_data) as x(k);

  select array_agg(x.k order by x.k) into v_izinsiz
    from jsonb_object_keys(p_data) as x(k)
   where x.k not in (
     'parent_name', 'first_name', 'last_name', 'phone', 'city', 'country', 'region',
     'district', 'lifecycle', 'account_status', 'preferred_channel', 'preferred_language',
     'owner_name', 'next_follow_up_at', 'last_contact_at', 'exam_goal', 'target_schools',
     'tags', 'notes');
  if v_izinsiz is not null then
    raise exception 'Bu alanlar müşteri güncellemesinde kullanılamaz: %',
      array_to_string(v_izinsiz, ', ') using errcode = '22023';
  end if;

  update public.growth_households h set
    parent_name        = case when p_data ? 'parent_name' then p_data ->> 'parent_name' else h.parent_name end,
    first_name         = case when p_data ? 'first_name' then p_data ->> 'first_name' else h.first_name end,
    last_name          = case when p_data ? 'last_name' then p_data ->> 'last_name' else h.last_name end,
    phone              = case when p_data ? 'phone' then p_data ->> 'phone' else h.phone end,
    city               = case when p_data ? 'city' then p_data ->> 'city' else h.city end,
    country            = case when p_data ? 'country' then p_data ->> 'country' else h.country end,
    region             = case when p_data ? 'region' then p_data ->> 'region' else h.region end,
    district           = case when p_data ? 'district' then p_data ->> 'district' else h.district end,
    lifecycle          = case when p_data ? 'lifecycle'
                              then (p_data ->> 'lifecycle')::public.growth_lifecycle_stage
                              else h.lifecycle end,
    account_status     = case when p_data ? 'account_status' then p_data ->> 'account_status' else h.account_status end,
    preferred_channel  = case when p_data ? 'preferred_channel' then p_data ->> 'preferred_channel' else h.preferred_channel end,
    preferred_language = case when p_data ? 'preferred_language' then p_data ->> 'preferred_language' else h.preferred_language end,
    owner_name         = case when p_data ? 'owner_name' then p_data ->> 'owner_name' else h.owner_name end,
    next_follow_up_at  = case when p_data ? 'next_follow_up_at'
                              then nullif(p_data ->> 'next_follow_up_at', '')::timestamptz
                              else h.next_follow_up_at end,
    last_contact_at    = case when p_data ? 'last_contact_at'
                              then nullif(p_data ->> 'last_contact_at', '')::timestamptz
                              else h.last_contact_at end,
    exam_goal          = case when p_data ? 'exam_goal' then p_data ->> 'exam_goal' else h.exam_goal end,
    target_schools     = case when p_data ? 'target_schools'
                              then public._growth_metin_dizi(p_data -> 'target_schools')
                              else h.target_schools end,
    tags               = case when p_data ? 'tags' then public._growth_metin_dizi(p_data -> 'tags') else h.tags end,
    notes              = case when p_data ? 'notes' then public._growth_metin_dizi(p_data -> 'notes') else h.notes end
   where h.id = p_household_id;

  if not found then
    raise exception 'Müşteri bulunamadı' using errcode = 'P0002';
  end if;

  perform public.log_admin_action('musteri_360_guncellendi',
    jsonb_build_object('household_id', p_household_id, 'alanlar', to_jsonb(v_alanlar)));
end;
$function$;

-- ---------------------------------------------------------------------
-- 2. POTANSİYEL ADAYLAR (growth_prospects)
-- ---------------------------------------------------------------------

-- 2.1 Liste. Toplam skor (total_score) üretilmiş kolondur; minimum skor filtresi onu kullanır.
create or replace function public.admin_prospect_listele(
  p_arama      text default '',
  p_status     growth_prospect_status default null,
  p_kind       growth_prospect_kind default null,
  p_min_score  int default null,
  p_limit      int default 25,
  p_offset     int default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_limit    int := least(greatest(coalesce(p_limit, 25), 1), 100);
  v_offset   int := greatest(coalesce(p_offset, 0), 0);
  v_desen    text := case when btrim(coalesce(p_arama, '')) = '' then null
                          else public._growth_like_desen(p_arama) end;
  v_toplam   int;
  v_satirlar jsonb;
begin
  perform public.require_admin();

  select count(*)::int into v_toplam
    from public.growth_prospects p
   where (p_status is null or p.status = p_status)
     and (p_kind is null or p.kind = p_kind)
     and (p_min_score is null or p.total_score >= p_min_score)
     and (v_desen is null or p.display_name ilike v_desen
                          or p.email ilike v_desen
                          or p.phone ilike v_desen);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.total_score desc, x.created_at desc, x.id), '[]'::jsonb)
    into v_satirlar
    from (
      select p.id, p.prospect_no, p.kind, p.status, p.display_name, p.email, p.phone,
             p.email_verification, p.city, p.company_name, p.source_type, p.source_name,
             p.campaign, p.fit_score, p.intent_score, p.engagement_score,
             p.data_quality_score, p.score_penalty, p.total_score, p.tags,
             p.owner_name, p.next_best_action, p.next_action_at, p.last_touch_at,
             p.created_at
        from public.growth_prospects p
       where (p_status is null or p.status = p_status)
         and (p_kind is null or p.kind = p_kind)
         and (p_min_score is null or p.total_score >= p_min_score)
         and (v_desen is null or p.display_name ilike v_desen
                              or p.email ilike v_desen
                              or p.phone ilike v_desen)
       order by p.total_score desc, p.created_at desc, p.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('rows', v_satirlar, 'total', v_toplam);
end;
$function$;

-- 2.2 Oluşturma. Kaynak kanalından origin türetilir; provenance ve ilk skor anlık görüntüsü yazılır.
--     Durum her zaman 'unreviewed' başlar; 'converted' buradan atanamaz.
create or replace function public.admin_prospect_kaydet(p_data jsonb)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_ad          text;
  v_email       text;
  v_kaynak      text;
  v_origin      text;
  v_kaynak_adi  text;
  v_id          uuid;
begin
  perform public.require_admin();
  if p_data is null or jsonb_typeof(p_data) <> 'object' then
    raise exception 'Prospect verisi nesne olmalı.' using errcode = '22023';
  end if;

  v_ad := btrim(coalesce(p_data ->> 'display_name', ''));
  if char_length(v_ad) < 2 or char_length(v_ad) > 120 then
    raise exception 'Ad 2-120 karakter olmalı.' using errcode = '22023';
  end if;

  v_email := public._growth_email_normalize(p_data ->> 'email');

  v_kaynak := nullif(btrim(coalesce(p_data ->> 'source_channel', '')), '');
  v_origin := case v_kaynak
    when 'website_form'        then 'first_party'
    when 'anonymous_web'       then 'first_party'
    when 'meta_lead_form'      then 'ad_lead_form'
    when 'google_lead_form'    then 'ad_lead_form'
    when 'manual'              then 'manual'
    when 'csv_import'          then 'csv_import'
    when 'referral'            then 'referral'
    when 'partner_api'         then 'partner_api'
    when 'event_qr'            then 'event_qr'
    when 'public_business_web' then 'public_business_web'
    else null
  end;
  if v_origin is null then
    raise exception 'Geçersiz kaynak kanalı.' using errcode = '22023';
  end if;
  v_kaynak_adi := coalesce(nullif(btrim(coalesce(p_data ->> 'source_detail', '')), ''), v_kaynak);

  insert into public.growth_prospects (
    prospect_no, kind, display_name, first_name, last_name, email, phone,
    city, district, company_name, company_domain, job_title,
    grade_interest, exam_interest, target_school_interest,
    source_type, origin, source_name, source_url, campaign,
    utm_source, utm_medium, utm_campaign, anonymous_id,
    owner_user_id, owner_name,
    fit_score, intent_score, engagement_score, data_quality_score, score_penalty,
    score_reasons, next_best_action, next_action_at, tags, notes
  ) values (
    'PRS-' || to_char(now(), 'YYMMDD') || '-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8)),
    coalesce(nullif(p_data ->> 'kind', ''), 'parent')::public.growth_prospect_kind,
    v_ad,
    nullif(btrim(coalesce(p_data ->> 'first_name', '')), ''),
    nullif(btrim(coalesce(p_data ->> 'last_name', '')), ''),
    v_email,
    nullif(btrim(coalesce(p_data ->> 'phone', '')), ''),
    nullif(btrim(coalesce(p_data ->> 'city', '')), ''),
    nullif(btrim(coalesce(p_data ->> 'district', '')), ''),
    nullif(btrim(coalesce(p_data ->> 'company_name', '')), ''),
    nullif(btrim(coalesce(p_data ->> 'company_domain', '')), ''),
    nullif(btrim(coalesce(p_data ->> 'job_title', '')), ''),
    array(select g::smallint from unnest(public._growth_metin_dizi(p_data -> 'grade_interest')) as g),
    nullif(btrim(coalesce(p_data ->> 'exam_interest', '')), ''),
    public._growth_metin_dizi(p_data -> 'target_school_interest'),
    v_kaynak,
    v_origin,
    v_kaynak_adi,
    nullif(btrim(coalesce(p_data ->> 'source_url', '')), ''),
    nullif(btrim(coalesce(p_data ->> 'campaign', '')), ''),
    nullif(btrim(coalesce(p_data ->> 'utm_source', '')), ''),
    nullif(btrim(coalesce(p_data ->> 'utm_medium', '')), ''),
    nullif(btrim(coalesce(p_data ->> 'utm_campaign', '')), ''),
    nullif(btrim(coalesce(p_data ->> 'anonymous_id', '')), ''),
    nullif(p_data ->> 'owner_user_id', '')::uuid,
    nullif(btrim(coalesce(p_data ->> 'owner_name', '')), ''),
    coalesce((p_data ->> 'fit_score')::int, 0),
    coalesce((p_data ->> 'intent_score')::int, 0),
    coalesce((p_data ->> 'engagement_score')::int, 0),
    coalesce((p_data ->> 'data_quality_score')::int, 0),
    coalesce((p_data ->> 'score_penalty')::int, 0),
    public._growth_metin_dizi(p_data -> 'score_reasons'),
    nullif(btrim(coalesce(p_data ->> 'next_best_action', '')), ''),
    nullif(p_data ->> 'next_action_at', '')::timestamptz,
    public._growth_metin_dizi(p_data -> 'tags'),
    public._growth_metin_dizi(p_data -> 'notes')
  )
  returning id into v_id;

  -- Kaynak kaydı (provenance). Halka açık işletme verisi bayrağı admin tarafından beyan edilir.
  insert into public.growth_prospect_provenance
    (prospect_id, source_url, collection_method, public_business_data_only, terms_review_status, notes)
  values (
    v_id,
    nullif(btrim(coalesce(p_data ->> 'source_url', '')), ''),
    v_kaynak,
    coalesce((p_data ->> 'public_business_data_only')::boolean, false),
    'review',
    'Admin girişi'
  );

  perform public._growth_skor_kaydet(v_id, 'manual');

  perform public.log_admin_action('prospect_kaydedildi',
    jsonb_build_object('prospect_id', v_id, 'kaynak', v_kaynak));
  return v_id;
end;
$function$;

-- 2.3 Detay: kayıt + kanal izinleri + olay zaman çizelgesi + provenance + skor geçmişi.
create or replace function public.admin_prospect_detay(p_prospect_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_prospect  jsonb;
  v_izinler   jsonb;
  v_olaylar   jsonb;
  v_kaynaklar jsonb;
  v_skorlar   jsonb;
begin
  perform public.require_admin();

  select to_jsonb(p) into v_prospect
    from public.growth_prospects p
   where p.id = p_prospect_id;
  if v_prospect is null then
    raise exception 'Prospect bulunamadı' using errcode = 'P0002';
  end if;

  select coalesce(jsonb_agg(to_jsonb(c) order by c.channel), '[]'::jsonb) into v_izinler
    from public.growth_prospect_consents c
   where c.prospect_id = p_prospect_id;

  select coalesce(jsonb_agg(to_jsonb(e) order by e.occurred_at desc), '[]'::jsonb) into v_olaylar
    from (
      select ev.id, ev.event_type, ev.source, ev.occurred_at, ev.title, ev.properties, ev.session_id
        from public.growth_prospect_events ev
       where ev.prospect_id = p_prospect_id
       order by ev.occurred_at desc
       limit 100
    ) e;

  select coalesce(jsonb_agg(to_jsonb(pr) order by pr.collected_at desc), '[]'::jsonb) into v_kaynaklar
    from (
      select * from public.growth_prospect_provenance
       where prospect_id = p_prospect_id
       order by collected_at desc
       limit 20
    ) pr;

  select coalesce(jsonb_agg(to_jsonb(sh) order by sh.computed_at desc), '[]'::jsonb) into v_skorlar
    from (
      select * from public.growth_prospect_score_history
       where prospect_id = p_prospect_id
       order by computed_at desc
       limit 50
    ) sh;

  return jsonb_build_object(
    'prospect', v_prospect,
    'consents', v_izinler,
    'events', v_olaylar,
    'provenance', v_kaynaklar,
    'score_history', v_skorlar
  );
end;
$function$;

-- 2.4 Güncelleme. Beyaz liste; toplam skor üretilmiş kolon olduğu için yazılmaz.
--     Skor değiştiyse history'ye yeni anlık görüntü eklenir.
create or replace function public.admin_prospect_guncelle(p_prospect_id uuid, p_data jsonb)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_eski     public.growth_prospects%rowtype;
  v_yeni     public.growth_prospects%rowtype;
  v_alanlar  text[];
  v_izinsiz  text[];
begin
  perform public.require_admin();
  if p_data is null or jsonb_typeof(p_data) <> 'object' then
    raise exception 'Güncelleme verisi nesne olmalı.' using errcode = '22023';
  end if;

  select array_agg(x.k order by x.k) into v_alanlar
    from jsonb_object_keys(p_data) as x(k);

  select array_agg(x.k order by x.k) into v_izinsiz
    from jsonb_object_keys(p_data) as x(k)
   where x.k not in (
     'status', 'kind', 'display_name', 'first_name', 'last_name', 'email', 'phone',
     'email_verification', 'city', 'district', 'company_name', 'company_domain', 'job_title',
     'grade_interest', 'exam_interest', 'target_school_interest',
     'fit_score', 'intent_score', 'engagement_score', 'data_quality_score', 'score_penalty',
     'score_reasons', 'next_best_action', 'next_action_at', 'tags', 'notes',
     'owner_user_id', 'owner_name');
  if v_izinsiz is not null then
    raise exception 'Bu alanlar prospect güncellemesinde kullanılamaz: %',
      array_to_string(v_izinsiz, ', ') using errcode = '22023';
  end if;

  select * into v_eski from public.growth_prospects where id = p_prospect_id for update;
  if not found then
    raise exception 'Prospect bulunamadı' using errcode = 'P0002';
  end if;

  if p_data ? 'status' then
    if (p_data ->> 'status') = 'converted' then
      raise exception 'Dönüşüm için admin_prospect_lead_donustur kullanın.' using errcode = '23514';
    end if;
    if v_eski.status = 'converted' then
      raise exception 'Dönüştürülmüş prospect durumu değiştirilemez.' using errcode = '23514';
    end if;
  end if;
  if p_data ? 'display_name' and char_length(btrim(coalesce(p_data ->> 'display_name', ''))) < 2 then
    raise exception 'Ad en az 2 karakter olmalı.' using errcode = '22023';
  end if;

  update public.growth_prospects pr set
    status             = case when p_data ? 'status' then (p_data ->> 'status')::public.growth_prospect_status else pr.status end,
    kind               = case when p_data ? 'kind' then (p_data ->> 'kind')::public.growth_prospect_kind else pr.kind end,
    display_name       = case when p_data ? 'display_name' then btrim(p_data ->> 'display_name') else pr.display_name end,
    first_name         = case when p_data ? 'first_name' then nullif(btrim(p_data ->> 'first_name'), '') else pr.first_name end,
    last_name          = case when p_data ? 'last_name' then nullif(btrim(p_data ->> 'last_name'), '') else pr.last_name end,
    email              = case when p_data ? 'email' then public._growth_email_normalize(p_data ->> 'email') else pr.email end,
    phone              = case when p_data ? 'phone' then nullif(btrim(p_data ->> 'phone'), '') else pr.phone end,
    email_verification = case when p_data ? 'email_verification'
                              then (p_data ->> 'email_verification')::public.growth_email_verification_status
                              else pr.email_verification end,
    city               = case when p_data ? 'city' then nullif(btrim(p_data ->> 'city'), '') else pr.city end,
    district           = case when p_data ? 'district' then nullif(btrim(p_data ->> 'district'), '') else pr.district end,
    company_name       = case when p_data ? 'company_name' then nullif(btrim(p_data ->> 'company_name'), '') else pr.company_name end,
    company_domain     = case when p_data ? 'company_domain' then nullif(btrim(p_data ->> 'company_domain'), '') else pr.company_domain end,
    job_title          = case when p_data ? 'job_title' then nullif(btrim(p_data ->> 'job_title'), '') else pr.job_title end,
    grade_interest     = case when p_data ? 'grade_interest'
                              then array(select g::smallint from unnest(public._growth_metin_dizi(p_data -> 'grade_interest')) as g)
                              else pr.grade_interest end,
    exam_interest      = case when p_data ? 'exam_interest' then nullif(btrim(p_data ->> 'exam_interest'), '') else pr.exam_interest end,
    target_school_interest = case when p_data ? 'target_school_interest'
                                  then public._growth_metin_dizi(p_data -> 'target_school_interest')
                                  else pr.target_school_interest end,
    fit_score          = case when p_data ? 'fit_score' then (p_data ->> 'fit_score')::int else pr.fit_score end,
    intent_score       = case when p_data ? 'intent_score' then (p_data ->> 'intent_score')::int else pr.intent_score end,
    engagement_score   = case when p_data ? 'engagement_score' then (p_data ->> 'engagement_score')::int else pr.engagement_score end,
    data_quality_score = case when p_data ? 'data_quality_score' then (p_data ->> 'data_quality_score')::int else pr.data_quality_score end,
    score_penalty      = case when p_data ? 'score_penalty' then (p_data ->> 'score_penalty')::int else pr.score_penalty end,
    score_reasons      = case when p_data ? 'score_reasons'
                              then public._growth_metin_dizi(p_data -> 'score_reasons')
                              else pr.score_reasons end,
    next_best_action   = case when p_data ? 'next_best_action' then nullif(btrim(p_data ->> 'next_best_action'), '') else pr.next_best_action end,
    next_action_at     = case when p_data ? 'next_action_at'
                              then nullif(p_data ->> 'next_action_at', '')::timestamptz
                              else pr.next_action_at end,
    tags               = case when p_data ? 'tags' then public._growth_metin_dizi(p_data -> 'tags') else pr.tags end,
    notes              = case when p_data ? 'notes' then public._growth_metin_dizi(p_data -> 'notes') else pr.notes end,
    owner_user_id      = case when p_data ? 'owner_user_id'
                              then nullif(p_data ->> 'owner_user_id', '')::uuid
                              else pr.owner_user_id end,
    owner_name         = case when p_data ? 'owner_name' then nullif(btrim(p_data ->> 'owner_name'), '') else pr.owner_name end,
    updated_at         = now()
   where pr.id = p_prospect_id
  returning * into v_yeni;

  if (v_yeni.fit_score, v_yeni.intent_score, v_yeni.engagement_score,
      v_yeni.data_quality_score, v_yeni.score_penalty)
     is distinct from
     (v_eski.fit_score, v_eski.intent_score, v_eski.engagement_score,
      v_eski.data_quality_score, v_eski.score_penalty) then
    perform public._growth_skor_kaydet(p_prospect_id, 'manual');
  end if;

  perform public.log_admin_action('prospect_guncellendi',
    jsonb_build_object('prospect_id', p_prospect_id, 'alanlar', to_jsonb(v_alanlar),
                       'durum_eski', v_eski.status, 'durum_yeni', v_yeni.status));
end;
$function$;

-- 2.5 Lead'e dönüştürme. Prospect 'converted' olur; lead kaydı oluşturulur.
--     Suppressed / disqualified / zaten converted kayıtlar dönüştürülemez.
create or replace function public.admin_prospect_lead_donustur(
  p_prospect_id uuid,
  p_household_id uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_p       public.growth_prospects%rowtype;
  v_lead_id uuid;
begin
  perform public.require_admin();

  select * into v_p from public.growth_prospects where id = p_prospect_id for update;
  if not found then
    raise exception 'Prospect bulunamadı' using errcode = 'P0002';
  end if;
  if v_p.status in ('converted', 'suppressed', 'disqualified') then
    raise exception 'Bu prospect lead''e dönüştürülemez (durum: %).', v_p.status using errcode = '23514';
  end if;
  if v_p.email is null then
    raise exception 'Lead için e-posta adresi gerekli.' using errcode = '23514';
  end if;
  if p_household_id is not null and not exists (
       select 1 from public.growth_households h where h.id = p_household_id) then
    raise exception 'Hane bulunamadı' using errcode = 'P0002';
  end if;

  insert into public.growth_leads
    (household_id, parent_name, email, phone, source, campaign,
     owner_user_id, owner_name, stage, score, value_estimate, tags)
  values
    (p_household_id, v_p.display_name, v_p.email, v_p.phone, v_p.source_name, v_p.campaign,
     v_p.owner_user_id, v_p.owner_name, 'new', least(100, greatest(0, v_p.total_score)), 0, v_p.tags)
  returning id into v_lead_id;

  update public.growth_prospects
     set status = 'converted', converted_lead_id = v_lead_id, updated_at = now()
   where id = p_prospect_id;

  perform public.log_admin_action('prospect_lead_donusturuldu',
    jsonb_build_object('prospect_id', p_prospect_id, 'lead_id', v_lead_id,
                       'household_id', p_household_id, 'durum_eski', v_p.status));
  return v_lead_id;
end;
$function$;

-- ---------------------------------------------------------------------
-- 3. LEAD (growth_leads)
-- ---------------------------------------------------------------------

-- 3.1 Liste.
create or replace function public.admin_lead_listele(
  p_arama  text default '',
  p_stage  growth_lead_stage default null,
  p_limit  int default 25,
  p_offset int default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_limit    int := least(greatest(coalesce(p_limit, 25), 1), 100);
  v_offset   int := greatest(coalesce(p_offset, 0), 0);
  v_desen    text := case when btrim(coalesce(p_arama, '')) = '' then null
                          else public._growth_like_desen(p_arama) end;
  v_toplam   int;
  v_satirlar jsonb;
begin
  perform public.require_admin();

  select count(*)::int into v_toplam
    from public.growth_leads l
   where (p_stage is null or l.stage = p_stage)
     and (v_desen is null or l.parent_name ilike v_desen
                          or l.email ilike v_desen
                          or l.phone ilike v_desen);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.score desc, x.updated_at desc, x.id), '[]'::jsonb)
    into v_satirlar
    from (
      select l.id, l.household_id, l.parent_name, l.email, l.phone, l.source, l.campaign,
             l.owner_name, l.stage, l.score, l.next_action, l.next_action_at,
             l.value_estimate, l.tags, l.created_at, l.updated_at
        from public.growth_leads l
       where (p_stage is null or l.stage = p_stage)
         and (v_desen is null or l.parent_name ilike v_desen
                              or l.email ilike v_desen
                              or l.phone ilike v_desen)
       order by l.score desc, l.updated_at desc, l.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('rows', v_satirlar, 'total', v_toplam);
end;
$function$;

-- 3.2 Oluşturma.
create or replace function public.admin_lead_kaydet(p_data jsonb)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_ad    text;
  v_email text;
  v_id    uuid;
begin
  perform public.require_admin();
  if p_data is null or jsonb_typeof(p_data) <> 'object' then
    raise exception 'Lead verisi nesne olmalı.' using errcode = '22023';
  end if;

  v_ad := btrim(coalesce(p_data ->> 'parent_name', ''));
  if char_length(v_ad) < 2 or char_length(v_ad) > 120 then
    raise exception 'Ad 2-120 karakter olmalı.' using errcode = '22023';
  end if;
  v_email := public._growth_email_normalize(p_data ->> 'email');
  if v_email is null then
    raise exception 'Lead için e-posta adresi gerekli.' using errcode = '22023';
  end if;

  insert into public.growth_leads
    (household_id, parent_name, email, phone, source, campaign, owner_user_id, owner_name,
     stage, score, next_action, next_action_at, value_estimate, tags)
  values (
    nullif(p_data ->> 'household_id', '')::uuid,
    v_ad,
    v_email,
    nullif(btrim(coalesce(p_data ->> 'phone', '')), ''),
    nullif(btrim(coalesce(p_data ->> 'source', '')), ''),
    nullif(btrim(coalesce(p_data ->> 'campaign', '')), ''),
    nullif(p_data ->> 'owner_user_id', '')::uuid,
    nullif(btrim(coalesce(p_data ->> 'owner_name', '')), ''),
    coalesce(nullif(p_data ->> 'stage', ''), 'new')::public.growth_lead_stage,
    coalesce((p_data ->> 'score')::int, 0),
    nullif(btrim(coalesce(p_data ->> 'next_action', '')), ''),
    nullif(p_data ->> 'next_action_at', '')::timestamptz,
    coalesce((p_data ->> 'value_estimate')::numeric, 0),
    public._growth_metin_dizi(p_data -> 'tags')
  )
  returning id into v_id;

  perform public.log_admin_action('lead_kaydedildi', jsonb_build_object('lead_id', v_id));
  return v_id;
end;
$function$;

-- 3.3 Aşama değişikliği.
create or replace function public.admin_lead_asama(p_lead_id uuid, p_stage growth_lead_stage)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
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
end;
$function$;

-- ---------------------------------------------------------------------
-- 4. CRM GÖREVLERİ (growth_tasks)
-- ---------------------------------------------------------------------

-- 4.1 Liste.
create or replace function public.admin_crm_gorev_listele(
  p_household_id uuid default null,
  p_lead_id      uuid default null,
  p_status       growth_task_status default null,
  p_limit        int default 25,
  p_offset       int default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_limit    int := least(greatest(coalesce(p_limit, 25), 1), 100);
  v_offset   int := greatest(coalesce(p_offset, 0), 0);
  v_toplam   int;
  v_satirlar jsonb;
begin
  perform public.require_admin();

  select count(*)::int into v_toplam
    from public.growth_tasks t
   where (p_household_id is null or t.household_id = p_household_id)
     and (p_lead_id is null or t.lead_id = p_lead_id)
     and (p_status is null or t.status = p_status);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.due_at, x.id), '[]'::jsonb)
    into v_satirlar
    from (
      select t.*
        from public.growth_tasks t
       where (p_household_id is null or t.household_id = p_household_id)
         and (p_lead_id is null or t.lead_id = p_lead_id)
         and (p_status is null or t.status = p_status)
       order by t.due_at, t.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('rows', v_satirlar, 'total', v_toplam);
end;
$function$;

-- 4.2 Upsert: id verilip kayıt varsa güncellenir (yalnızca gönderilen alanlar),
--     yoksa yeni kayıt açılır. id verilmezse üretilir.
create or replace function public.admin_crm_gorev_kaydet(p_data jsonb)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_id     uuid;
  v_yeni   boolean;
  v_durum  public.growth_task_status;
begin
  perform public.require_admin();
  if p_data is null or jsonb_typeof(p_data) <> 'object' then
    raise exception 'Görev verisi nesne olmalı.' using errcode = '22023';
  end if;

  v_id    := nullif(p_data ->> 'id', '')::uuid;
  v_durum := (p_data ->> 'status')::public.growth_task_status;   -- anahtar yoksa NULL

  if p_data ? 'title' and char_length(btrim(coalesce(p_data ->> 'title', ''))) not between 1 and 200 then
    raise exception 'Görev başlığı 1-200 karakter olmalı.' using errcode = '22023';
  end if;

  v_yeni := v_id is null or not exists (select 1 from public.growth_tasks t where t.id = v_id);

  if v_yeni then
    if char_length(btrim(coalesce(p_data ->> 'title', ''))) not between 1 and 200 then
      raise exception 'Görev başlığı 1-200 karakter olmalı.' using errcode = '22023';
    end if;
    if p_data ->> 'due_at' is null then
      raise exception 'Görev için bitiş zamanı (due_at) gerekli.' using errcode = '22023';
    end if;

    v_id := coalesce(v_id, gen_random_uuid());

    insert into public.growth_tasks
      (id, household_id, lead_id, title, task_type, due_at, owner_user_id, owner_name,
       status, priority, recurring, recurrence_rule, created_by_automation, completed_at)
    values (
      v_id,
      nullif(p_data ->> 'household_id', '')::uuid,
      nullif(p_data ->> 'lead_id', '')::uuid,
      btrim(p_data ->> 'title'),
      coalesce(nullif(p_data ->> 'task_type', ''), 'follow_up'),
      (p_data ->> 'due_at')::timestamptz,
      nullif(p_data ->> 'owner_user_id', '')::uuid,
      nullif(p_data ->> 'owner_name', ''),
      coalesce(v_durum, 'open'),
      coalesce((p_data ->> 'priority')::public.growth_task_priority, 'normal'),
      coalesce((p_data ->> 'recurring')::boolean, false),
      nullif(p_data ->> 'recurrence_rule', ''),
      false,   -- otomasyon bayrağı istemciden set edilemez
      case when v_durum = 'done'
           then coalesce(nullif(p_data ->> 'completed_at', '')::timestamptz, now()) end
    );
  else
    update public.growth_tasks t set
      household_id    = case when p_data ? 'household_id' then nullif(p_data ->> 'household_id', '')::uuid else t.household_id end,
      lead_id         = case when p_data ? 'lead_id' then nullif(p_data ->> 'lead_id', '')::uuid else t.lead_id end,
      title           = case when p_data ? 'title' then btrim(p_data ->> 'title') else t.title end,
      task_type       = case when p_data ? 'task_type' then p_data ->> 'task_type' else t.task_type end,
      due_at          = case when p_data ? 'due_at' then (p_data ->> 'due_at')::timestamptz else t.due_at end,
      owner_user_id   = case when p_data ? 'owner_user_id' then nullif(p_data ->> 'owner_user_id', '')::uuid else t.owner_user_id end,
      owner_name      = case when p_data ? 'owner_name' then nullif(p_data ->> 'owner_name', '') else t.owner_name end,
      status          = coalesce(v_durum, t.status),
      priority        = case when p_data ? 'priority' then (p_data ->> 'priority')::public.growth_task_priority else t.priority end,
      recurring       = case when p_data ? 'recurring' then (p_data ->> 'recurring')::boolean else t.recurring end,
      recurrence_rule = case when p_data ? 'recurrence_rule' then nullif(p_data ->> 'recurrence_rule', '') else t.recurrence_rule end,
      completed_at    = case
                          when p_data ? 'completed_at' then nullif(p_data ->> 'completed_at', '')::timestamptz
                          when v_durum = 'done' then coalesce(t.completed_at, now())
                          when v_durum is not null then null
                          else t.completed_at
                        end
     where t.id = v_id;
  end if;

  perform public.log_admin_action('crm_gorevi_kaydedildi',
    jsonb_build_object('gorev_id', v_id, 'yeni', v_yeni));
  return v_id;
end;
$function$;

-- ---------------------------------------------------------------------
-- 5. DESTEK TALEPLERİ (growth_support_tickets, id = text)
-- ---------------------------------------------------------------------

-- 5.1 Liste. Öncelik: kritikten düşüğe, eşitlikte en eski önce.
create or replace function public.admin_destek_listele(
  p_household_id uuid default null,
  p_status       growth_ticket_status default null,
  p_priority     growth_ticket_priority default null,
  p_limit        int default 25,
  p_offset       int default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_limit    int := least(greatest(coalesce(p_limit, 25), 1), 100);
  v_offset   int := greatest(coalesce(p_offset, 0), 0);
  v_toplam   int;
  v_satirlar jsonb;
begin
  perform public.require_admin();

  select count(*)::int into v_toplam
    from public.growth_support_tickets s
   where (p_household_id is null or s.household_id = p_household_id)
     and (p_status is null or s.status = p_status)
     and (p_priority is null or s.priority = p_priority);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.priority desc, x.created_at asc, x.id), '[]'::jsonb)
    into v_satirlar
    from (
      select s.*
        from public.growth_support_tickets s
       where (p_household_id is null or s.household_id = p_household_id)
         and (p_status is null or s.status = p_status)
         and (p_priority is null or s.priority = p_priority)
       order by s.priority desc, s.created_at asc, s.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('rows', v_satirlar, 'total', v_toplam);
end;
$function$;

-- 5.2 Upsert (id text). id verilmezse TKT-... üretilir. Hane sonradan değiştirilmez.
create or replace function public.admin_destek_kaydet(p_data jsonb)
returns text
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_id     text;
  v_yeni   boolean;
  v_durum  public.growth_ticket_status;
begin
  perform public.require_admin();
  if p_data is null or jsonb_typeof(p_data) <> 'object' then
    raise exception 'Destek verisi nesne olmalı.' using errcode = '22023';
  end if;

  v_id    := nullif(btrim(coalesce(p_data ->> 'id', '')), '');
  v_durum := (p_data ->> 'status')::public.growth_ticket_status;   -- anahtar yoksa NULL

  if p_data ? 'subject' and char_length(btrim(coalesce(p_data ->> 'subject', ''))) not between 1 and 200 then
    raise exception 'Konu 1-200 karakter olmalı.' using errcode = '22023';
  end if;

  v_yeni := v_id is null or not exists (select 1 from public.growth_support_tickets s where s.id = v_id);

  if v_yeni then
    if p_data ->> 'household_id' is null then
      raise exception 'Destek talebi bir haneye bağlı olmalı.' using errcode = '22023';
    end if;
    if char_length(btrim(coalesce(p_data ->> 'subject', ''))) not between 1 and 200 then
      raise exception 'Konu 1-200 karakter olmalı.' using errcode = '22023';
    end if;

    v_id := coalesce(v_id, 'TKT-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 10)));

    insert into public.growth_support_tickets
      (id, household_id, subject, category, priority, status, owner_user_id, owner_name,
       sentiment, first_response_due_at, first_responded_at, resolution_due_at, resolved_at)
    values (
      v_id,
      (p_data ->> 'household_id')::uuid,
      btrim(p_data ->> 'subject'),
      coalesce(nullif(p_data ->> 'category', ''), 'other'),
      coalesce((p_data ->> 'priority')::public.growth_ticket_priority, 'normal'),
      coalesce(v_durum, 'new'),
      nullif(p_data ->> 'owner_user_id', '')::uuid,
      nullif(p_data ->> 'owner_name', ''),
      nullif(p_data ->> 'sentiment', ''),
      nullif(p_data ->> 'first_response_due_at', '')::timestamptz,
      nullif(p_data ->> 'first_responded_at', '')::timestamptz,
      nullif(p_data ->> 'resolution_due_at', '')::timestamptz,
      case when v_durum = 'resolved'
           then coalesce(nullif(p_data ->> 'resolved_at', '')::timestamptz, now()) end
    );
  else
    update public.growth_support_tickets s set
      subject               = case when p_data ? 'subject' then btrim(p_data ->> 'subject') else s.subject end,
      category              = case when p_data ? 'category' then p_data ->> 'category' else s.category end,
      priority              = case when p_data ? 'priority' then (p_data ->> 'priority')::public.growth_ticket_priority else s.priority end,
      status                = coalesce(v_durum, s.status),
      owner_user_id         = case when p_data ? 'owner_user_id' then nullif(p_data ->> 'owner_user_id', '')::uuid else s.owner_user_id end,
      owner_name            = case when p_data ? 'owner_name' then nullif(p_data ->> 'owner_name', '') else s.owner_name end,
      sentiment             = case when p_data ? 'sentiment' then nullif(p_data ->> 'sentiment', '') else s.sentiment end,
      first_response_due_at = case when p_data ? 'first_response_due_at' then nullif(p_data ->> 'first_response_due_at', '')::timestamptz else s.first_response_due_at end,
      first_responded_at    = case when p_data ? 'first_responded_at' then nullif(p_data ->> 'first_responded_at', '')::timestamptz else s.first_responded_at end,
      resolution_due_at     = case when p_data ? 'resolution_due_at' then nullif(p_data ->> 'resolution_due_at', '')::timestamptz else s.resolution_due_at end,
      resolved_at           = case
                                when p_data ? 'resolved_at' then nullif(p_data ->> 'resolved_at', '')::timestamptz
                                when v_durum = 'resolved' then coalesce(s.resolved_at, now())
                                when v_durum is not null then null
                                else s.resolved_at
                              end,
      updated_at            = now()
     where s.id = v_id;
  end if;

  perform public.log_admin_action('destek_talebi_kaydedildi',
    jsonb_build_object('talep_id', v_id, 'yeni', v_yeni));
  return v_id;
end;
$function$;

-- ---------------------------------------------------------------------
-- 6. EKİP AKIŞI (growth_team_feed)
-- ---------------------------------------------------------------------

-- 6.1 Liste. Sabitlenenler önce, sonra en yeni.
create or replace function public.admin_ekip_akisi_listele(
  p_household_id uuid default null,
  p_lead_id      uuid default null,
  p_limit        int default 25,
  p_offset       int default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_limit    int := least(greatest(coalesce(p_limit, 25), 1), 100);
  v_offset   int := greatest(coalesce(p_offset, 0), 0);
  v_toplam   int;
  v_satirlar jsonb;
begin
  perform public.require_admin();

  select count(*)::int into v_toplam
    from public.growth_team_feed f
   where (p_household_id is null or f.household_id = p_household_id)
     and (p_lead_id is null or f.lead_id = p_lead_id);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.pinned desc, x.created_at desc, x.id), '[]'::jsonb)
    into v_satirlar
    from (
      select f.id, f.household_id, f.lead_id, f.author_user_id, f.author_name,
             f.feed_type, f.body, f.sentiment, f.sentiment_source, f.pinned, f.created_at
        from public.growth_team_feed f
       where (p_household_id is null or f.household_id = p_household_id)
         and (p_lead_id is null or f.lead_id = p_lead_id)
       order by f.pinned desc, f.created_at desc, f.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('rows', v_satirlar, 'total', v_toplam);
end;
$function$;

-- 6.2 Ekleme. Yazar = auth.uid() (actor). Sistem kayıtları (feed_type 'system') admin tarafından
--     üretilemez. Tablo metadata kolonu içermediği için ek alanlar yazılmaz.
create or replace function public.admin_ekip_akisi_ekle(p_data jsonb)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_uid     uuid := (select auth.uid());
  v_ad      text;
  v_hh      uuid;
  v_lead    uuid;
  v_tur     text;
  v_metin   text;
  v_duygu   text;
  v_id      uuid;
begin
  perform public.require_admin();
  if v_uid is null then
    raise exception 'Oturum bulunamadı.' using errcode = '42501';
  end if;
  if p_data is null or jsonb_typeof(p_data) <> 'object' then
    raise exception 'Ekip akışı verisi nesne olmalı.' using errcode = '22023';
  end if;

  v_hh   := nullif(p_data ->> 'household_id', '')::uuid;
  v_lead := nullif(p_data ->> 'lead_id', '')::uuid;
  if v_hh is null and v_lead is null then
    raise exception 'Ekip akışı kaydı bir hane veya lead ile ilişkili olmalı.' using errcode = '22023';
  end if;

  v_tur := coalesce(nullif(btrim(coalesce(p_data ->> 'entry_type', '')), ''), 'note');
  if v_tur not in ('note', 'call', 'meeting', 'support') then
    raise exception 'Geçersiz ekip akışı türü.' using errcode = '22023';
  end if;

  v_metin := btrim(coalesce(p_data ->> 'content', ''));
  if char_length(v_metin) not between 1 and 4000 then
    raise exception 'İçerik 1-4000 karakter olmalı.' using errcode = '22023';
  end if;

  v_duygu := nullif(p_data ->> 'sentiment', '');

  select p.full_name into v_ad from public.profiles p where p.id = v_uid;

  insert into public.growth_team_feed
    (household_id, lead_id, author_user_id, author_name, feed_type, body,
     sentiment, sentiment_source, pinned)
  values (
    v_hh, v_lead, v_uid, coalesce(v_ad, 'Admin'), v_tur, v_metin,
    v_duygu, case when v_duygu is not null then 'manual' end,
    coalesce((p_data ->> 'pinned')::boolean, false)
  )
  returning id into v_id;

  -- Gövde (PII olabilir) denetim izine yazılmaz.
  perform public.log_admin_action('ekip_akisi_kaydi_eklendi',
    jsonb_build_object('feed_id', v_id, 'household_id', v_hh, 'lead_id', v_lead, 'tur', v_tur));
  return v_id;
end;
$function$;

-- ---------------------------------------------------------------------
-- 7. İNDEKSLER (sorgu desenlerine göre; idempotent)
-- ---------------------------------------------------------------------
create index if not exists growth_tasks_household_due_idx
  on public.growth_tasks (household_id, due_at) where household_id is not null;
create index if not exists growth_tasks_lead_due_idx
  on public.growth_tasks (lead_id, due_at) where lead_id is not null;
create index if not exists growth_support_tickets_household_idx
  on public.growth_support_tickets (household_id, created_at desc);
create index if not exists growth_team_feed_lead_idx
  on public.growth_team_feed (lead_id, created_at desc) where lead_id is not null;
create index if not exists growth_prospect_provenance_prospect_idx
  on public.growth_prospect_provenance (prospect_id, collected_at desc);
create index if not exists growth_prospects_kind_status_idx
  on public.growth_prospects (kind, status);
create index if not exists growth_leads_updated_idx
  on public.growth_leads (updated_at desc);

-- ---------------------------------------------------------------------
-- 8. REVOKE / GRANT
--    Yardımcılar: yalnızca SECURITY DEFINER gövdeleri (tablo sahibi) çağırır; istemciye kapalı.
--    Public RPC'ler: authenticated; içeride require_admin() yetki kontrolü yapar.
-- ---------------------------------------------------------------------
revoke execute on function public._growth_like_desen(text)          from public, anon, authenticated;
revoke execute on function public._growth_metin_dizi(jsonb)         from public, anon, authenticated;
revoke execute on function public._growth_email_normalize(text)     from public, anon, authenticated;
revoke execute on function public._growth_skor_kaydet(uuid, text)   from public, anon, authenticated;

revoke execute on function public.admin_musteri_360_listele(text, public.growth_lifecycle_stage, public.growth_plan, int, int) from public, anon;
revoke execute on function public.admin_musteri_360_detay(uuid)                 from public, anon;
revoke execute on function public.admin_musteri_360_guncelle(uuid, jsonb)       from public, anon;
revoke execute on function public.admin_prospect_listele(text, public.growth_prospect_status, public.growth_prospect_kind, int, int, int) from public, anon;
revoke execute on function public.admin_prospect_kaydet(jsonb)                  from public, anon;
revoke execute on function public.admin_prospect_detay(uuid)                    from public, anon;
revoke execute on function public.admin_prospect_guncelle(uuid, jsonb)          from public, anon;
revoke execute on function public.admin_prospect_lead_donustur(uuid, uuid)      from public, anon;
revoke execute on function public.admin_lead_listele(text, public.growth_lead_stage, int, int) from public, anon;
revoke execute on function public.admin_lead_kaydet(jsonb)                      from public, anon;
revoke execute on function public.admin_lead_asama(uuid, public.growth_lead_stage) from public, anon;
revoke execute on function public.admin_crm_gorev_listele(uuid, uuid, public.growth_task_status, int, int) from public, anon;
revoke execute on function public.admin_crm_gorev_kaydet(jsonb)                 from public, anon;
revoke execute on function public.admin_destek_listele(uuid, public.growth_ticket_status, public.growth_ticket_priority, int, int) from public, anon;
revoke execute on function public.admin_destek_kaydet(jsonb)                    from public, anon;
revoke execute on function public.admin_ekip_akisi_listele(uuid, uuid, int, int) from public, anon;
revoke execute on function public.admin_ekip_akisi_ekle(jsonb)                  from public, anon;

grant execute on function public.admin_musteri_360_listele(text, public.growth_lifecycle_stage, public.growth_plan, int, int) to authenticated;
grant execute on function public.admin_musteri_360_detay(uuid)                 to authenticated;
grant execute on function public.admin_musteri_360_guncelle(uuid, jsonb)       to authenticated;
grant execute on function public.admin_prospect_listele(text, public.growth_prospect_status, public.growth_prospect_kind, int, int, int) to authenticated;
grant execute on function public.admin_prospect_kaydet(jsonb)                  to authenticated;
grant execute on function public.admin_prospect_detay(uuid)                    to authenticated;
grant execute on function public.admin_prospect_guncelle(uuid, jsonb)          to authenticated;
grant execute on function public.admin_prospect_lead_donustur(uuid, uuid)      to authenticated;
grant execute on function public.admin_lead_listele(text, public.growth_lead_stage, int, int) to authenticated;
grant execute on function public.admin_lead_kaydet(jsonb)                      to authenticated;
grant execute on function public.admin_lead_asama(uuid, public.growth_lead_stage) to authenticated;
grant execute on function public.admin_crm_gorev_listele(uuid, uuid, public.growth_task_status, int, int) to authenticated;
grant execute on function public.admin_crm_gorev_kaydet(jsonb)                 to authenticated;
grant execute on function public.admin_destek_listele(uuid, public.growth_ticket_status, public.growth_ticket_priority, int, int) to authenticated;
grant execute on function public.admin_destek_kaydet(jsonb)                    to authenticated;
grant execute on function public.admin_ekip_akisi_listele(uuid, uuid, int, int) to authenticated;
grant execute on function public.admin_ekip_akisi_ekle(jsonb)                  to authenticated;
