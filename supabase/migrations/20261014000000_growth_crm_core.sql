set client_encoding = 'UTF8';

-- =====================================================================
-- HUPO Growth CRM layer (Growth OS v0.1 + CRM core v0.2 + Customer 360 v0.3
-- + Prospect acquisition v0.4, merged into one migration).
--
-- Purpose: the CRM / growth / sales-follow-up layer for Hupo. It sits on
-- top of the Hupolingo core tables and never replaces them.
--
-- Rules:
--   * Additive only. Creates growth_* tables, enums, indexes and views.
--   * No core table duplication. Learning data, parent/student identity,
--     subscriptions, plans, payments, channel consent and the admin audit
--     trail stay authoritative in the core tables:
--       profiles, student_stats, subscriptions, plans, payments,
--       iletisim_tercihleri, iletisim_tercih_gecmisi, admin_audit_log,
--       veli_adaylari, olay_kutusu.
--   * Channel consent: growth_consents is NOT created. Use
--     iletisim_tercihleri via the growth_consent_bridge view.
--   * Audit: growth_audit_log is NOT created. Use admin_audit_log and
--     log_admin_action().
--   * Core links: growth_households.core_parent_user_id and
--     growth_students.core_student_id reference profiles(id) ON DELETE SET NULL.
--   * Security: every growth_* table has RLS enabled and no policies, and
--     PUBLIC / anon / authenticated are revoked. Only service_role (server
--     side) can access these tables. Never expose service_role to the browser.
--   * Prospect data (04) is public-B2B or consented first-party data only.
--     Child identities must never flow into ad audiences.
-- =====================================================================

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------
create type public.growth_lifecycle_stage as enum ('visitor','lead','registered','trial','activated','engaged','paid','at_risk','churned','winback');
create type public.growth_plan as enum ('free','trial','premium','family');
create type public.growth_consent_status as enum ('granted','denied','unknown');
create type public.growth_journey_status as enum ('draft','active','paused');
create type public.growth_lead_stage as enum ('new','contacted','qualified','trial','decision','won','lost');
create type public.growth_task_status as enum ('open','done','overdue');
create type public.growth_task_priority as enum ('low','normal','high');
create type public.growth_ticket_status as enum ('new','open','waiting','resolved');
create type public.growth_ticket_priority as enum ('low','normal','high','critical');
create type public.growth_prospect_kind as enum ('parent','teacher','institution','partner');
create type public.growth_prospect_status as enum ('unreviewed','new','nurturing','marketing_ready','sales_ready','converted','disqualified','suppressed');
create type public.growth_channel_eligibility as enum ('allowed','blocked','review');
create type public.growth_email_verification_status as enum ('valid','invalid','accept_all','unknown','not_checked');

-- ---------------------------------------------------------------------
-- Households (parent / customer account in the CRM)
-- ---------------------------------------------------------------------
create table if not exists public.growth_households (
  id uuid primary key default gen_random_uuid(),
  core_parent_user_id uuid references public.profiles (id) on delete set null,
  parent_name text not null,
  email text not null,
  phone text,
  city text,
  source text,
  campaign text,
  lifecycle public.growth_lifecycle_stage not null default 'lead',
  plan public.growth_plan not null default 'free',
  trial_started_at timestamptz,
  created_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  last_parent_dashboard_at timestamptz,
  mrr numeric(12,2) not null default 0,
  ltv numeric(12,2) not null default 0,
  lead_score int not null default 0 check (lead_score between 0 and 100),
  churn_score int not null default 0 check (churn_score between 0 and 100),
  tags text[] not null default '{}',
  notes text[] not null default '{}'
);
create unique index if not exists growth_households_email_uq on public.growth_households(lower(email));
create index if not exists growth_households_lifecycle_idx on public.growth_households(lifecycle, plan);
create index if not exists growth_households_scores_idx on public.growth_households(lead_score desc, churn_score desc);

-- Students in the CRM view. Authoritative student data lives in profiles + student_stats.
create table if not exists public.growth_students (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.growth_households(id) on delete cascade,
  core_student_id uuid references public.profiles (id) on delete set null,
  nickname text not null,
  grade smallint check (grade between 3 and 8),
  active_days_30 int not null default 0,
  questions_30 int not null default 0,
  accuracy_30 numeric(5,2) not null default 0,
  streak int not null default 0,
  xp int not null default 0,
  league text,
  strongest_subject text,
  weakest_subject text,
  updated_at timestamptz not null default now()
);
create index if not exists growth_students_household_idx on public.growth_students(household_id);
create index if not exists growth_students_core_student_idx on public.growth_students(core_student_id) where core_student_id is not null;

-- Events: the CRM event stream (web, app, payment, support, automation, server).
create table if not exists public.growth_events (
  id uuid primary key default gen_random_uuid(),
  household_id uuid references public.growth_households(id) on delete cascade,
  student_id uuid references public.growth_students(id) on delete set null,
  anonymous_id text,
  user_id uuid,
  event_name text not null,
  source text not null check (source in ('web','app','crm','payment','support','automation','server')),
  occurred_at timestamptz not null default now(),
  properties jsonb not null default '{}'::jsonb,
  utm jsonb,
  session_id text,
  created_at timestamptz not null default now()
);
create index if not exists growth_events_household_time_idx on public.growth_events(household_id, occurred_at desc);
create index if not exists growth_events_name_time_idx on public.growth_events(event_name, occurred_at desc);
create index if not exists growth_events_anonymous_idx on public.growth_events(anonymous_id) where anonymous_id is not null;

create table if not exists public.growth_identity_links (
  id uuid primary key default gen_random_uuid(),
  anonymous_id text not null,
  household_id uuid not null references public.growth_households(id) on delete cascade,
  linked_at timestamptz not null default now(),
  unique(anonymous_id, household_id)
);

-- ---------------------------------------------------------------------
-- Segments, journeys, campaigns, templates, message log, AI recommendations
-- (growth_consents and growth_audit_log intentionally omitted, see header)
-- ---------------------------------------------------------------------
create table if not exists public.growth_segments (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  color text default '#2563EB',
  logic_json jsonb not null default '{}'::jsonb,
  logic_text text,
  channel_ready text[] not null default '{}',
  estimated_count int not null default 0,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.growth_journeys (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  goal text,
  status public.growth_journey_status not null default 'draft',
  audience_segment_id uuid references public.growth_segments(id) on delete set null,
  audience_label text,
  exit_conditions jsonb not null default '{}'::jsonb,
  entered_30 int not null default 0,
  converted_30 int not null default 0,
  conversion_rate numeric(6,2) not null default 0,
  requires_human_approval boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.growth_journey_steps (
  id uuid primary key default gen_random_uuid(),
  journey_id uuid not null references public.growth_journeys(id) on delete cascade,
  position int not null,
  step_type text not null check (step_type in ('trigger','delay','condition','email','push','in_app','sms','whatsapp','webhook','ai_action')),
  label text not null,
  detail text,
  config jsonb not null default '{}'::jsonb,
  unique(journey_id, position)
);

create table if not exists public.growth_journey_enrollments (
  id uuid primary key default gen_random_uuid(),
  journey_id uuid not null references public.growth_journeys(id) on delete cascade,
  household_id uuid not null references public.growth_households(id) on delete cascade,
  current_step_id uuid references public.growth_journey_steps(id) on delete set null,
  status text not null default 'active' check (status in ('active','waiting','completed','exited','failed')),
  entered_at timestamptz not null default now(),
  next_run_at timestamptz,
  completed_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  unique(journey_id, household_id, entered_at)
);
create index if not exists growth_journey_due_idx on public.growth_journey_enrollments(status, next_run_at);

create table if not exists public.growth_campaigns (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  channel text not null check (channel in ('email','push','in_app','sms','whatsapp')),
  audience text,
  segment_id uuid references public.growth_segments(id) on delete set null,
  status text not null default 'draft' check (status in ('draft','scheduled','running','completed')),
  template_id uuid,
  scheduled_at timestamptz,
  sent int not null default 0,
  opened int not null default 0,
  clicked int not null default 0,
  converted int not null default 0,
  revenue numeric(12,2) not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.growth_templates (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  channel text not null,
  lifecycle_use_case text,
  subject text,
  body text not null,
  variables text[] not null default '{}',
  version int not null default 1,
  approved boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.growth_message_log (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.growth_households(id) on delete cascade,
  campaign_id uuid references public.growth_campaigns(id) on delete set null,
  journey_id uuid references public.growth_journeys(id) on delete set null,
  channel text not null,
  status text not null,
  provider_message_id text,
  consent_snapshot jsonb not null,
  payload_hash text,
  sent_at timestamptz,
  opened_at timestamptz,
  clicked_at timestamptz,
  converted_at timestamptz,
  error text,
  created_at timestamptz not null default now()
);

create table if not exists public.growth_ai_recommendations (
  id uuid primary key default gen_random_uuid(),
  household_id uuid references public.growth_households(id) on delete cascade,
  agent_name text not null,
  recommendation_type text not null,
  title text not null,
  reason text not null,
  proposed_action jsonb not null,
  risk_level text not null default 'medium',
  requires_approval boolean not null default true,
  status text not null default 'pending' check (status in ('pending','approved','rejected','executed','expired')),
  model text,
  prompt_version text,
  created_at timestamptz not null default now(),
  reviewed_by uuid,
  reviewed_at timestamptz
);

-- ---------------------------------------------------------------------
-- CRM core: leads, opportunities, tasks, support, sources, team feed, custom fields
-- ---------------------------------------------------------------------
create table if not exists public.growth_leads (
  id uuid primary key default gen_random_uuid(),
  household_id uuid references public.growth_households(id) on delete set null,
  parent_name text not null,
  email text not null,
  phone text,
  source text,
  campaign text,
  owner_user_id uuid,
  owner_name text,
  stage public.growth_lead_stage not null default 'new',
  score int not null default 0 check (score between 0 and 100),
  next_action text,
  next_action_at timestamptz,
  value_estimate numeric(12,2) not null default 0,
  tags text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists growth_leads_stage_score_idx on public.growth_leads(stage, score desc);
create index if not exists growth_leads_email_idx on public.growth_leads(lower(email));

create table if not exists public.growth_opportunities (
  id uuid primary key default gen_random_uuid(),
  household_id uuid references public.growth_households(id) on delete set null,
  lead_id uuid references public.growth_leads(id) on delete set null,
  title text not null,
  opportunity_type text not null check (opportunity_type in ('premium','family','institutional')),
  stage text not null check (stage in ('discovery','trial','decision','payment','won','lost')),
  amount numeric(12,2) not null default 0,
  probability int not null default 0 check (probability between 0 and 100),
  owner_user_id uuid,
  owner_name text,
  next_step text,
  close_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists growth_opportunities_stage_idx on public.growth_opportunities(stage, close_date);

create table if not exists public.growth_tasks (
  id uuid primary key default gen_random_uuid(),
  household_id uuid references public.growth_households(id) on delete cascade,
  lead_id uuid references public.growth_leads(id) on delete cascade,
  title text not null,
  task_type text not null check (task_type in ('call','email','meeting','follow_up','review','other')),
  due_at timestamptz not null,
  owner_user_id uuid,
  owner_name text,
  status public.growth_task_status not null default 'open',
  priority public.growth_task_priority not null default 'normal',
  recurring boolean not null default false,
  recurrence_rule text,
  created_by_automation boolean not null default false,
  created_at timestamptz not null default now(),
  completed_at timestamptz
);
create index if not exists growth_tasks_due_idx on public.growth_tasks(status, due_at);

create table if not exists public.growth_support_tickets (
  id text primary key,
  household_id uuid not null references public.growth_households(id) on delete cascade,
  subject text not null,
  category text not null check (category in ('billing','technical','account','content','subscription','other')),
  priority public.growth_ticket_priority not null default 'normal',
  status public.growth_ticket_status not null default 'new',
  owner_user_id uuid,
  owner_name text,
  sentiment text check (sentiment in ('positive','neutral','negative')),
  first_response_due_at timestamptz,
  first_responded_at timestamptz,
  resolution_due_at timestamptz,
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists growth_support_status_priority_idx on public.growth_support_tickets(status, priority, created_at desc);

create table if not exists public.growth_lead_sources (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  source_type text not null check (source_type in ('website_form','google_ads','meta_ads','referral','organic','manual','partner')),
  active boolean not null default true,
  routing_rule text,
  consent_capture_config jsonb not null default '{}'::jsonb,
  field_mapping jsonb not null default '{}'::jsonb,
  leads_30 int not null default 0,
  trials_30 int not null default 0,
  paid_30 int not null default 0,
  cost_30 numeric(12,2) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.growth_team_feed (
  id uuid primary key default gen_random_uuid(),
  household_id uuid references public.growth_households(id) on delete cascade,
  lead_id uuid references public.growth_leads(id) on delete cascade,
  author_user_id uuid,
  author_name text,
  feed_type text not null check (feed_type in ('note','call','meeting','support','system')),
  body text not null,
  sentiment text check (sentiment in ('positive','neutral','negative')),
  sentiment_source text,
  pinned boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists growth_team_feed_household_idx on public.growth_team_feed(household_id, created_at desc);

create table if not exists public.growth_custom_fields (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null check (entity_type in ('household','lead','opportunity','ticket')),
  field_key text not null,
  label text not null,
  field_type text not null check (field_type in ('text','number','boolean','date','select','multi_select')),
  options jsonb not null default '[]'::jsonb,
  required boolean not null default false,
  active boolean not null default true,
  unique(entity_type, field_key)
);

create table if not exists public.growth_entity_custom_values (
  id uuid primary key default gen_random_uuid(),
  field_id uuid not null references public.growth_custom_fields(id) on delete cascade,
  entity_id text not null,
  value jsonb,
  updated_at timestamptz not null default now(),
  unique(field_id, entity_id)
);

-- ---------------------------------------------------------------------
-- Customer 360 additions: people, addresses, subscription projection, transactions
-- ---------------------------------------------------------------------
alter table public.growth_households
  add column if not exists customer_no text,
  add column if not exists core_customer_id text,
  add column if not exists customer_type text check (customer_type in ('individual','corporate')) default 'individual',
  add column if not exists primary_role text check (primary_role in ('parent','student','teacher','institution_contact')) default 'parent',
  add column if not exists account_status text check (account_status in ('active','passive','blocked')) default 'active',
  add column if not exists first_name text,
  add column if not exists last_name text,
  add column if not exists national_id_last4 text,
  add column if not exists birth_date date,
  add column if not exists gender text,
  add column if not exists nationality text,
  add column if not exists country text,
  add column if not exists region text,
  add column if not exists district text,
  add column if not exists preferred_language text default 'tr',
  add column if not exists preferred_channel text check (preferred_channel in ('email','push','sms','whatsapp','phone','none')) default 'none',
  add column if not exists owner_name text,
  add column if not exists last_contact_at timestamptz,
  add column if not exists next_follow_up_at timestamptz,
  add column if not exists subscription_status text check (subscription_status in ('trial','active','paused','cancelled','expired','free')) default 'free',
  add column if not exists total_revenue_try numeric(14,2) not null default 0,
  add column if not exists total_paid_transactions int not null default 0,
  add column if not exists last_payment_at timestamptz,
  add column if not exists utm_source text,
  add column if not exists utm_medium text,
  add column if not exists utm_campaign text,
  add column if not exists referral_code text,
  add column if not exists commercial_consent_overall public.growth_consent_status not null default 'unknown',
  add column if not exists consent_proof_updated_at timestamptz,
  add column if not exists target_schools text[] not null default '{}',
  add column if not exists exam_goal text;

create unique index if not exists growth_households_customer_no_uq
  on public.growth_households(customer_no) where customer_no is not null;
create index if not exists growth_households_location_idx
  on public.growth_households(country, region, district);
create index if not exists growth_households_owner_followup_idx
  on public.growth_households(owner_name, next_follow_up_at);

-- A household/customer can contain more than one linked person.
-- Keep raw national identity values OUT of this CRM projection where possible.
-- If legal/invoicing requirements force storage, use a separate encrypted PII vault.
create table if not exists public.growth_customer_people (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.growth_households(id) on delete cascade,
  core_person_id uuid,
  core_student_id uuid,
  customer_no text,
  person_role text not null check (person_role in ('parent','student','teacher','institution_contact')),
  first_name text,
  last_name text,
  national_id_last4 text,
  birth_date date,
  gender text,
  nationality text,
  grade smallint check (grade between 3 and 8),
  phone text,
  email text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists growth_customer_people_household_idx on public.growth_customer_people(household_id, person_role);

create table if not exists public.growth_customer_addresses (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.growth_households(id) on delete cascade,
  address_type text not null check (address_type in ('billing','delivery','home','other')),
  label text,
  country text,
  region text,
  district text,
  postal_code text,
  address_line text not null,
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists growth_customer_addresses_household_idx on public.growth_customer_addresses(household_id, address_type);

-- Fallback subscription projection for households WITHOUT a core parent account
-- (institutional / corporate leads). Core-linked households read subscriptions + plans directly.
create table if not exists public.growth_subscription_projection (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.growth_households(id) on delete cascade,
  core_subscription_id text,
  plan public.growth_plan not null,
  status text not null check (status in ('trial','active','paused','cancelled','expired','free')),
  billing_cycle text check (billing_cycle in ('monthly','annual','none')),
  trial_started_at timestamptz,
  trial_ends_at timestamptz,
  started_at timestamptz,
  ends_at timestamptz,
  next_renewal_at timestamptz,
  auto_renew boolean,
  cancelled_at timestamptz,
  cancel_reason text,
  synced_at timestamptz not null default now()
);
create index if not exists growth_subscription_projection_household_idx on public.growth_subscription_projection(household_id, synced_at desc);

create table if not exists public.growth_financial_transactions (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.growth_households(id) on delete cascade,
  core_transaction_id text,
  document_no text not null,
  transaction_type text not null check (transaction_type in ('annual_subscription','monthly_subscription','product_order','renewal','refund','other')),
  status text not null default 'pending' check (status in ('pending','paid','failed','refunded','cancelled')),
  updated_at timestamptz not null default now(),
  updated_by text,
  purchase_date date,
  billing_address_id uuid references public.growth_customer_addresses(id) on delete set null,
  billing_address_snapshot text,
  currency text not null default 'TRY',
  exchange_rate numeric(18,6),
  amount numeric(14,2) not null default 0,
  amount_try numeric(14,2) not null default 0,
  payment_type text check (payment_type in ('virtual_pos','eft_transfer','card','coin','in_app','other')),
  payment_source text,
  occurred_at timestamptz not null default now(),
  order_id text,
  invoice_no text,
  coupon_code text,
  discount_amount_try numeric(14,2) not null default 0,
  refund_amount_try numeric(14,2) not null default 0,
  metadata jsonb not null default '{}'::jsonb,
  unique(document_no)
);
create index if not exists growth_financial_transactions_household_time_idx on public.growth_financial_transactions(household_id, occurred_at desc);
create index if not exists growth_financial_transactions_status_idx on public.growth_financial_transactions(status, occurred_at desc);

-- ---------------------------------------------------------------------
-- Prospect acquisition (top of funnel, consent-gated)
-- ---------------------------------------------------------------------
create table if not exists public.growth_prospects (
  id uuid primary key default gen_random_uuid(),
  prospect_no text unique not null,
  kind public.growth_prospect_kind not null default 'parent',
  status public.growth_prospect_status not null default 'unreviewed',
  first_name text,
  last_name text,
  display_name text not null,
  email text,
  phone text,
  email_verification public.growth_email_verification_status not null default 'not_checked',
  city text,
  district text,
  company_name text,
  company_domain text,
  job_title text,
  grade_interest smallint[] not null default '{}',
  exam_interest text,
  target_school_interest text[] not null default '{}',
  source_type text not null check (source_type in ('website_form','meta_lead_form','google_lead_form','manual','csv_import','referral','partner_api','event_qr','public_business_web','anonymous_web')),
  origin text not null check (origin in ('first_party','ad_lead_form','manual','csv_import','referral','public_business_web','partner_api','event_qr')),
  source_name text not null,
  source_url text,
  campaign text,
  utm_source text,
  utm_medium text,
  utm_campaign text,
  anonymous_id text,
  owner_user_id uuid,
  owner_name text,
  first_touch_at timestamptz not null default now(),
  last_touch_at timestamptz not null default now(),
  fit_score int not null default 0 check (fit_score between 0 and 35),
  intent_score int not null default 0 check (intent_score between 0 and 35),
  engagement_score int not null default 0 check (engagement_score between 0 and 20),
  data_quality_score int not null default 0 check (data_quality_score between 0 and 10),
  score_penalty int not null default 0 check (score_penalty between 0 and 100),
  total_score int generated always as (greatest(0, least(100, fit_score + intent_score + engagement_score + data_quality_score - score_penalty))) stored,
  score_reasons text[] not null default '{}',
  page_views_30 int not null default 0,
  pricing_views_30 int not null default 0,
  content_downloads_30 int not null default 0,
  form_submissions_30 int not null default 0,
  next_best_action text,
  next_action_at timestamptz,
  tags text[] not null default '{}',
  notes text[] not null default '{}',
  converted_lead_id uuid references public.growth_leads(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists growth_prospects_status_score_idx on public.growth_prospects(status, total_score desc);
create index if not exists growth_prospects_email_idx on public.growth_prospects(lower(email)) where email is not null;
create index if not exists growth_prospects_phone_idx on public.growth_prospects(phone) where phone is not null;
create index if not exists growth_prospects_anon_idx on public.growth_prospects(anonymous_id) where anonymous_id is not null;

create table if not exists public.growth_prospect_consents (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null references public.growth_prospects(id) on delete cascade,
  channel text not null check (channel in ('email','sms','whatsapp','phone','ad_personalization')),
  eligibility public.growth_channel_eligibility not null default 'review',
  captured_at timestamptz,
  source text,
  proof_ref text,
  revoked_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  unique(prospect_id, channel)
);
create index if not exists growth_prospect_consents_channel_idx on public.growth_prospect_consents(channel, eligibility);

create table if not exists public.growth_prospect_events (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid references public.growth_prospects(id) on delete cascade,
  anonymous_id text,
  event_type text not null,
  source text not null check (source in ('web','ads','email','crm','event','partner')),
  occurred_at timestamptz not null default now(),
  title text,
  properties jsonb not null default '{}'::jsonb,
  session_id text,
  source_event_id text,
  unique(source, source_event_id)
);
create index if not exists growth_prospect_events_prospect_time_idx on public.growth_prospect_events(prospect_id, occurred_at desc);
create index if not exists growth_prospect_events_anon_time_idx on public.growth_prospect_events(anonymous_id, occurred_at desc) where anonymous_id is not null;

create table if not exists public.growth_prospect_provenance (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null references public.growth_prospects(id) on delete cascade,
  source_url text,
  collection_method text not null,
  collected_at timestamptz not null default now(),
  public_business_data_only boolean not null default false,
  terms_review_status text not null default 'review' check (terms_review_status in ('approved','review','blocked')),
  robots_observed boolean,
  notes text
);

create table if not exists public.growth_prospect_connectors (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  connector_type text not null check (connector_type in ('website_form','meta_lead_form','google_lead_form','manual','csv_import','referral','partner_api','event_qr','public_business_web','anonymous_web')),
  category text not null check (category in ('first_party','paid_media','import','partner','public_web','event')),
  active boolean not null default false,
  consent_evidence text not null default 'manual_review' check (consent_evidence in ('native','mapped','manual_review','not_applicable')),
  field_mapping jsonb not null default '{}'::jsonb,
  config jsonb not null default '{}'::jsonb,
  health text not null default 'offline' check (health in ('healthy','warning','offline')),
  last_sync_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.growth_lead_capture_forms (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  purpose text not null check (purpose in ('trial','content','webinar','contact','waitlist','event')),
  landing_page text,
  consent_mode text not null check (consent_mode in ('separate_marketing_opt_in','service_only','custom')),
  status text not null default 'draft' check (status in ('active','draft','paused')),
  field_schema jsonb not null default '[]'::jsonb,
  hidden_attribution_fields text[] not null default array['utm_source','utm_medium','utm_campaign','referrer','landing_page','anonymous_id'],
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.growth_prospect_lists (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  list_type text not null check (list_type in ('dynamic','static')),
  definition jsonb not null default '{}'::jsonb,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.growth_prospect_list_members (
  list_id uuid not null references public.growth_prospect_lists(id) on delete cascade,
  prospect_id uuid not null references public.growth_prospects(id) on delete cascade,
  entered_at timestamptz not null default now(),
  exited_at timestamptz,
  primary key (list_id, prospect_id)
);

create table if not exists public.growth_prospect_score_history (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null references public.growth_prospects(id) on delete cascade,
  fit_score int not null,
  intent_score int not null,
  engagement_score int not null,
  data_quality_score int not null,
  penalty int not null default 0,
  total_score int not null,
  reasons text[] not null default '{}',
  computed_at timestamptz not null default now(),
  model_version text not null default 'rules-v1'
);
create index if not exists growth_prospect_score_history_idx on public.growth_prospect_score_history(prospect_id, computed_at desc);

create table if not exists public.growth_prospect_suppressions (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid references public.growth_prospects(id) on delete cascade,
  email_hash text,
  phone_hash text,
  channel text,
  reason text not null,
  source text,
  suppressed_at timestamptz not null default now(),
  expires_at timestamptz
);
create index if not exists growth_prospect_suppressions_email_idx on public.growth_prospect_suppressions(email_hash) where email_hash is not null;
create index if not exists growth_prospect_suppressions_phone_idx on public.growth_prospect_suppressions(phone_hash) where phone_hash is not null;

create table if not exists public.growth_prospect_import_jobs (
  id uuid primary key default gen_random_uuid(),
  source_name text not null,
  original_file_name text,
  status text not null default 'pending' check (status in ('pending','validating','importing','completed','failed','cancelled')),
  total_rows int not null default 0,
  imported_rows int not null default 0,
  duplicate_rows int not null default 0,
  rejected_rows int not null default 0,
  field_mapping jsonb not null default '{}'::jsonb,
  consent_mapping jsonb not null default '{}'::jsonb,
  error_summary jsonb not null default '{}'::jsonb,
  created_by uuid,
  created_at timestamptz not null default now(),
  completed_at timestamptz
);

-- ---------------------------------------------------------------------
-- Views
-- ---------------------------------------------------------------------

-- Bridge: core channel consent (iletisim_tercihleri) projected onto CRM households.
-- Replaces the former growth_consents table. Read-only; core stays authoritative.
create or replace view public.growth_consent_bridge
with (security_invoker = true) as
select
  h.id as household_id,
  case t.kanal when 'eposta' then 'email' when 'push' then 'push' when 'sms' then 'sms' when 'uygulama_ici' then 'in_app' end as channel,
  t.izin as granted,
  t.kaynak as source,
  t.updated_at as changed_at
from public.iletisim_tercihleri t
join public.growth_households h on h.core_parent_user_id = t.veli_id;

-- Customer 360: CRM surface joining growth_* CRM fields with core tables.
-- Column order: v0.1 columns first, then v0.3 Customer 360 columns.
create or replace view public.growth_customer_360
with (security_invoker = true) as
select
  h.id, h.parent_name, h.email, h.phone, h.city, h.source, h.campaign, h.lifecycle, h.plan,
  case when h.trial_started_at is null then null else greatest(1, floor(extract(epoch from (now()-h.trial_started_at))/86400)::int + 1) end as trial_day,
  h.created_at, h.last_seen_at, h.last_parent_dashboard_at, h.mrr, h.ltv, h.lead_score, h.churn_score,
  -- Consent comes from core iletisim_tercihleri (no growth_consents table).
  coalesce((select case when t.izin then 'granted' else 'denied' end from public.iletisim_tercihleri t where t.veli_id = h.core_parent_user_id and t.kanal = 'eposta'), 'unknown') as consent_email,
  coalesce((select case when t.izin then 'granted' else 'denied' end from public.iletisim_tercihleri t where t.veli_id = h.core_parent_user_id and t.kanal = 'push'), 'unknown') as consent_push,
  coalesce((select case when t.izin then 'granted' else 'denied' end from public.iletisim_tercihleri t where t.veli_id = h.core_parent_user_id and t.kanal = 'sms'), 'unknown') as consent_sms,
  -- Core has no WhatsApp channel in iletisim_tercihleri, so this stays 'unknown' until one exists.
  'unknown'::text as consent_whatsapp,
  h.tags, h.notes,
  -- Children: core profiles (role 'ogrenci', parent_id) + student_stats.
  -- Growth-only analytics come from growth_students linked by core_student_id.
  -- Unlinked growth_students rows (no core_student_id) are kept as a fallback.
  coalesce((
    select jsonb_agg(c.child order by c.sort_name)
    from (
      select coalesce(p.full_name, p.username) as sort_name,
             jsonb_build_object(
               'id', p.id, 'nickname', coalesce(p.full_name, p.username), 'grade', p.sinif,
               'xp', coalesce(ss.xp, 0), 'level', coalesce(ss.level, 1), 'streak', coalesce(ss.streak_count, 0),
               'lastActiveDate', ss.last_active_date,
               'activeDays30', gs.active_days_30, 'questions30', gs.questions_30, 'accuracy30', gs.accuracy_30,
               'league', gs.league, 'strongestSubject', gs.strongest_subject, 'weakestSubject', gs.weakest_subject,
               'source', 'core'
             ) as child
      from public.profiles p
      left join public.student_stats ss on ss.student_id = p.id
      left join lateral (
        select g.* from public.growth_students g where g.core_student_id = p.id order by g.updated_at desc limit 1
      ) gs on true
      where p.role = 'ogrenci' and p.parent_id = h.core_parent_user_id
      union all
      select g.nickname,
             jsonb_build_object(
               'id', g.id, 'nickname', g.nickname, 'grade', g.grade, 'xp', g.xp, 'streak', g.streak,
               'activeDays30', g.active_days_30, 'questions30', g.questions_30, 'accuracy30', g.accuracy_30,
               'league', g.league, 'strongestSubject', g.strongest_subject, 'weakestSubject', g.weakest_subject,
               'source', 'growth'
             )
      from public.growth_students g
      where g.household_id = h.id and g.core_student_id is null
    ) c
  ), '[]'::jsonb) as children,
  h.customer_no,
  h.core_customer_id,
  h.customer_type,
  h.primary_role,
  h.account_status,
  h.first_name,
  h.last_name,
  case when h.national_id_last4 is null then null else '*******' || h.national_id_last4 end as national_id_masked,
  h.birth_date,
  h.gender,
  h.nationality,
  h.country,
  h.region,
  h.district,
  h.preferred_language,
  h.preferred_channel,
  h.owner_name,
  h.last_contact_at,
  h.next_follow_up_at,
  h.subscription_status,
  h.total_revenue_try,
  h.total_paid_transactions,
  h.last_payment_at,
  h.utm_source,
  h.utm_medium,
  h.utm_campaign,
  h.referral_code,
  h.commercial_consent_overall,
  h.consent_proof_updated_at,
  h.target_schools,
  h.exam_goal,
  coalesce((select jsonb_agg(jsonb_build_object(
    'id', a.id, 'type', a.address_type, 'label', a.label, 'country', a.country, 'region', a.region,
    'district', a.district, 'postalCode', a.postal_code, 'addressLine', a.address_line, 'isDefault', a.is_default
  ) order by a.is_default desc, a.created_at) from public.growth_customer_addresses a where a.household_id=h.id),'[]'::jsonb) as addresses,
  -- Subscription: core subscriptions + plans when the household has a core parent.
  -- Otherwise the growth_subscription_projection fallback (institutional / corporate leads).
  case when h.core_parent_user_id is not null then
    (select jsonb_build_object(
       'source', 'core', 'coreSubscriptionId', s.id, 'status', s.durum, 'plan', s.plan_kod,
       'planName', pl.ad, 'priceKurus', pl.fiyat_kurus, 'startedAt', s.baslangic, 'endsAt', s.bitis,
       'provider', s.saglayici
     )
     from public.subscriptions s
     join public.plans pl on pl.kod = s.plan_kod
     where s.veli_id = h.core_parent_user_id
     order by (s.durum = 'aktif') desc, s.bitis desc
     limit 1)
  else
    (select jsonb_build_object(
       'source', 'projection', 'coreSubscriptionId', sp.core_subscription_id, 'status', sp.status, 'plan', sp.plan,
       'billingCycle', sp.billing_cycle, 'trialStartedAt', sp.trial_started_at, 'trialEndsAt', sp.trial_ends_at,
       'startedAt', sp.started_at, 'endsAt', sp.ends_at, 'nextRenewalAt', sp.next_renewal_at, 'autoRenew', sp.auto_renew,
       'cancelledAt', sp.cancelled_at, 'cancelReason', sp.cancel_reason
     )
     from public.growth_subscription_projection sp
     where sp.household_id = h.id
     order by sp.synced_at desc limit 1)
  end as subscription,
  coalesce((select jsonb_agg(jsonb_build_object(
    'id', t.id, 'documentNo', t.document_no, 'transactionType', t.transaction_type, 'status', t.status,
    'updatedAt', t.updated_at, 'updatedBy', t.updated_by, 'purchaseDate', t.purchase_date,
    'billingAddress', t.billing_address_snapshot, 'currency', t.currency, 'exchangeRate', t.exchange_rate,
    'amount', t.amount, 'amountTry', t.amount_try, 'paymentType', t.payment_type, 'paymentSource', t.payment_source,
    'occurredAt', t.occurred_at, 'orderId', t.order_id, 'invoiceNo', t.invoice_no, 'couponCode', t.coupon_code,
    'discountAmountTry', t.discount_amount_try, 'refundAmountTry', t.refund_amount_try
  ) order by t.occurred_at desc) from public.growth_financial_transactions t where t.household_id=h.id),'[]'::jsonb) as transactions
from public.growth_households h;

-- Prospect 360: prospect row + consent, event timeline and latest provenance.
create or replace view public.growth_prospect_360
with (security_invoker = true) as
select
  p.*,
  coalesce((select jsonb_object_agg(c.channel, jsonb_build_object('eligibility',c.eligibility,'capturedAt',c.captured_at,'source',c.source,'proofRef',c.proof_ref)) from public.growth_prospect_consents c where c.prospect_id=p.id),'{}'::jsonb) as consent,
  coalesce((select jsonb_agg(jsonb_build_object('id',e.id,'at',e.occurred_at,'type',e.event_type,'source',e.source,'title',e.title,'properties',e.properties) order by e.occurred_at desc) from public.growth_prospect_events e where e.prospect_id=p.id),'[]'::jsonb) as events,
  (select jsonb_build_object('sourceUrl',pr.source_url,'collectionMethod',pr.collection_method,'collectedAt',pr.collected_at,'publicBusinessDataOnly',pr.public_business_data_only,'termsReviewStatus',pr.terms_review_status,'robotsObserved',pr.robots_observed) from public.growth_prospect_provenance pr where pr.prospect_id=p.id order by pr.collected_at desc limit 1) as provenance
from public.growth_prospects p;

-- ---------------------------------------------------------------------
-- Row Level Security: enabled on every growth_* table, with no policies.
-- Only service_role (server side, bypasses RLS) can read or write.
-- Add explicit staff/admin policies only after mapping the Hupolingo RBAC model.
-- ---------------------------------------------------------------------
alter table public.growth_households enable row level security;
alter table public.growth_students enable row level security;
alter table public.growth_events enable row level security;
alter table public.growth_identity_links enable row level security;
alter table public.growth_segments enable row level security;
alter table public.growth_journeys enable row level security;
alter table public.growth_journey_steps enable row level security;
alter table public.growth_journey_enrollments enable row level security;
alter table public.growth_campaigns enable row level security;
alter table public.growth_templates enable row level security;
alter table public.growth_message_log enable row level security;
alter table public.growth_ai_recommendations enable row level security;
alter table public.growth_leads enable row level security;
alter table public.growth_opportunities enable row level security;
alter table public.growth_tasks enable row level security;
alter table public.growth_support_tickets enable row level security;
alter table public.growth_lead_sources enable row level security;
alter table public.growth_team_feed enable row level security;
alter table public.growth_custom_fields enable row level security;
alter table public.growth_entity_custom_values enable row level security;
alter table public.growth_customer_people enable row level security;
alter table public.growth_customer_addresses enable row level security;
alter table public.growth_subscription_projection enable row level security;
alter table public.growth_financial_transactions enable row level security;
alter table public.growth_prospects enable row level security;
alter table public.growth_prospect_consents enable row level security;
alter table public.growth_prospect_events enable row level security;
alter table public.growth_prospect_provenance enable row level security;
alter table public.growth_prospect_connectors enable row level security;
alter table public.growth_lead_capture_forms enable row level security;
alter table public.growth_prospect_lists enable row level security;
alter table public.growth_prospect_list_members enable row level security;
alter table public.growth_prospect_score_history enable row level security;
alter table public.growth_prospect_suppressions enable row level security;
alter table public.growth_prospect_import_jobs enable row level security;

-- Deny direct client access. Views are included so anon/authenticated cannot read
-- them through default privileges.
revoke all on table
  public.growth_households,
  public.growth_students,
  public.growth_events,
  public.growth_identity_links,
  public.growth_segments,
  public.growth_journeys,
  public.growth_journey_steps,
  public.growth_journey_enrollments,
  public.growth_campaigns,
  public.growth_templates,
  public.growth_message_log,
  public.growth_ai_recommendations,
  public.growth_leads,
  public.growth_opportunities,
  public.growth_tasks,
  public.growth_support_tickets,
  public.growth_lead_sources,
  public.growth_team_feed,
  public.growth_custom_fields,
  public.growth_entity_custom_values,
  public.growth_customer_people,
  public.growth_customer_addresses,
  public.growth_subscription_projection,
  public.growth_financial_transactions,
  public.growth_prospects,
  public.growth_prospect_consents,
  public.growth_prospect_events,
  public.growth_prospect_provenance,
  public.growth_prospect_connectors,
  public.growth_lead_capture_forms,
  public.growth_prospect_lists,
  public.growth_prospect_list_members,
  public.growth_prospect_score_history,
  public.growth_prospect_suppressions,
  public.growth_prospect_import_jobs,
  public.growth_consent_bridge,
  public.growth_customer_360,
  public.growth_prospect_360
from public, anon, authenticated;
