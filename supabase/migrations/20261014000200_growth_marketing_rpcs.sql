set client_encoding = 'UTF8';

-- =====================================================================
--  Growth CRM: pazarlama motoru admin RPC katmanı
--  (journey otomasyonları, mesaj şablonları, kampanyalar)
--  Tarih : 2026-10-14
--  Ön koşul: 20260920000900_admin_role_and_payments.sql  (require_admin, log_admin_action)
--            20261014000000_growth_crm_core.sql           (growth_* tablolar)
--            20261014000100_growth_crm_rpcs.sql           (_growth_metin_dizi)
--
--  NE EKLİYOR?
--    şema (additive): growth_journeys.trigger_type,
--                     growth_templates.status, growth_templates.updated_at
--    journey     : admin_journey_listele, admin_journey_kaydet, admin_journey_adim_listele
--    şablon      : admin_template_listele, admin_template_kaydet
--    kampanya    : admin_kampanya_listele, admin_kampanya_kaydet
--
--  GÜVENLİK
--    * Her public fonksiyon SECURITY DEFINER + set search_path = '' ve İLK ifadesi
--      public.require_admin(). Tüm referanslar şema-nitelikli.
--    * growth_* tabloları RLS açık ve policy'sizdir; istemci doğrudan erişemez.
--    * Her mutasyon public.log_admin_action ile denetim izine yazılır (yalnızca id'ler).
--
--  Liste yanıtı: { rows: [...], total: n }. limit en fazla 100, offset >= 0.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. Şema eklemeleri (additive; mevcut satırlar bozulmaz)
-- ---------------------------------------------------------------------
alter table public.growth_journeys
  add column if not exists trigger_type text;

alter table public.growth_templates
  add column if not exists status text not null default 'draft'
    check (status in ('draft', 'active', 'archived'));

alter table public.growth_templates
  add column if not exists updated_at timestamptz not null default now();

-- ---------------------------------------------------------------------
-- 1. JOURNEY (growth_journeys)
-- ---------------------------------------------------------------------

-- 1.1 Liste. Liste satırında UI alan adları: segment_id, enrolled_count (entered_30).
create or replace function public.admin_journey_listele(
  p_status text default null,
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
  v_durum    public.growth_journey_status := nullif(btrim(coalesce(p_status, '')), '')::public.growth_journey_status;
  v_toplam   int;
  v_satirlar jsonb;
begin
  perform public.require_admin();

  select count(*)::int into v_toplam
    from public.growth_journeys j
   where (v_durum is null or j.status = v_durum);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id), '[]'::jsonb)
    into v_satirlar
    from (
      select j.id, j.name, j.goal, j.status, j.trigger_type,
             j.audience_segment_id as segment_id, j.audience_label,
             j.entered_30 as enrolled_count, j.converted_30, j.conversion_rate,
             j.requires_human_approval, j.created_at, j.updated_at
        from public.growth_journeys j
       where (v_durum is null or j.status = v_durum)
       order by j.created_at desc, j.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('rows', v_satirlar, 'total', v_toplam);
end;
$function$;

-- 1.2 Upsert: id verilip kayıt varsa güncellenir (yalnızca gönderilen alanlar),
--     yoksa yeni kayıt açılır. Dönüş: journey id.
create or replace function public.admin_journey_kaydet(p_data jsonb)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_id     uuid;
  v_yeni   boolean;
  v_ad     text;
begin
  perform public.require_admin();
  if p_data is null or jsonb_typeof(p_data) <> 'object' then
    raise exception 'Journey verisi nesne olmalı.' using errcode = '22023';
  end if;

  v_id := nullif(p_data ->> 'id', '')::uuid;
  v_ad := btrim(coalesce(p_data ->> 'name', ''));

  if p_data ? 'name' and char_length(v_ad) not between 1 and 120 then
    raise exception 'Journey adı 1-120 karakter olmalı.' using errcode = '22023';
  end if;

  v_yeni := v_id is null or not exists (select 1 from public.growth_journeys j where j.id = v_id);

  if v_yeni then
    if char_length(v_ad) not between 1 and 120 then
      raise exception 'Journey adı 1-120 karakter olmalı.' using errcode = '22023';
    end if;

    v_id := coalesce(v_id, gen_random_uuid());

    insert into public.growth_journeys
      (id, name, goal, status, trigger_type, audience_segment_id, audience_label, requires_human_approval)
    values (
      v_id,
      v_ad,
      nullif(btrim(coalesce(p_data ->> 'goal', '')), ''),
      coalesce(nullif(p_data ->> 'status', ''), 'draft')::public.growth_journey_status,
      nullif(btrim(coalesce(p_data ->> 'trigger_type', '')), ''),
      nullif(p_data ->> 'segment_id', '')::uuid,
      nullif(btrim(coalesce(p_data ->> 'audience_label', '')), ''),
      coalesce((p_data ->> 'requires_human_approval')::boolean, true)
    );
  else
    update public.growth_journeys j set
      name                    = case when p_data ? 'name' then v_ad else j.name end,
      goal                    = case when p_data ? 'goal' then nullif(btrim(coalesce(p_data ->> 'goal', '')), '') else j.goal end,
      status                  = coalesce(nullif(p_data ->> 'status', '')::public.growth_journey_status, j.status),
      trigger_type            = case when p_data ? 'trigger_type' then nullif(btrim(coalesce(p_data ->> 'trigger_type', '')), '') else j.trigger_type end,
      audience_segment_id     = case when p_data ? 'segment_id' then nullif(p_data ->> 'segment_id', '')::uuid else j.audience_segment_id end,
      audience_label          = case when p_data ? 'audience_label' then nullif(btrim(coalesce(p_data ->> 'audience_label', '')), '') else j.audience_label end,
      requires_human_approval = case when p_data ? 'requires_human_approval' then (p_data ->> 'requires_human_approval')::boolean else j.requires_human_approval end,
      updated_at              = now()
     where j.id = v_id;
  end if;

  perform public.log_admin_action('journey_kaydedildi',
    jsonb_build_object('journey_id', v_id, 'yeni', v_yeni));
  return v_id;
end;
$function$;

-- 1.3 Adımlar (position sırasıyla). Dönüş: jsonb dizisi.
create or replace function public.admin_journey_adim_listele(p_journey_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_satirlar jsonb;
begin
  perform public.require_admin();

  select coalesce(jsonb_agg(to_jsonb(s) order by s.position), '[]'::jsonb)
    into v_satirlar
    from public.growth_journey_steps s
   where s.journey_id = p_journey_id;

  return v_satirlar;
end;
$function$;

-- ---------------------------------------------------------------------
-- 2. MESAJ ŞABLONLARI (growth_templates)
-- ---------------------------------------------------------------------

-- 2.1 Liste. Kanal ve durum filtresi isteğe bağlıdır.
create or replace function public.admin_template_listele(
  p_channel text default null,
  p_status  text default null,
  p_limit   int default 25,
  p_offset  int default 0
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
  v_kanal    text := nullif(btrim(coalesce(p_channel, '')), '');
  v_durum    text := nullif(btrim(coalesce(p_status, '')), '');
  v_toplam   int;
  v_satirlar jsonb;
begin
  perform public.require_admin();

  select count(*)::int into v_toplam
    from public.growth_templates t
   where (v_kanal is null or t.channel = v_kanal)
     and (v_durum is null or t.status = v_durum);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.updated_at desc, x.id), '[]'::jsonb)
    into v_satirlar
    from (
      select t.id, t.name, t.channel, t.lifecycle_use_case, t.subject, t.body,
             t.variables, t.version, t.approved, t.status, t.created_at, t.updated_at
        from public.growth_templates t
       where (v_kanal is null or t.channel = v_kanal)
         and (v_durum is null or t.status = v_durum)
       order by t.updated_at desc, t.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('rows', v_satirlar, 'total', v_toplam);
end;
$function$;

-- 2.2 Upsert: id verilip kayıt varsa güncellenir, yoksa yeni kayıt açılır.
--     Gövde değişirse version artar. Dönüş: şablon id.
create or replace function public.admin_template_kaydet(p_data jsonb)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_id     uuid;
  v_yeni   boolean;
  v_ad     text;
  v_kanal  text;
  v_body   text;
  v_durum  text;
begin
  perform public.require_admin();
  if p_data is null or jsonb_typeof(p_data) <> 'object' then
    raise exception 'Şablon verisi nesne olmalı.' using errcode = '22023';
  end if;

  v_id    := nullif(p_data ->> 'id', '')::uuid;
  v_ad    := btrim(coalesce(p_data ->> 'name', ''));
  v_kanal := btrim(coalesce(p_data ->> 'channel', ''));
  v_body  := coalesce(p_data ->> 'body', '');
  v_durum := nullif(btrim(coalesce(p_data ->> 'status', '')), '');

  v_yeni := v_id is null or not exists (select 1 from public.growth_templates t where t.id = v_id);

  if v_yeni or p_data ? 'name' then
    if char_length(v_ad) not between 1 and 120 then
      raise exception 'Şablon adı 1-120 karakter olmalı.' using errcode = '22023';
    end if;
  end if;
  if v_yeni or p_data ? 'channel' then
    if v_kanal not in ('email', 'sms', 'push', 'in_app', 'whatsapp') then
      raise exception 'Geçersiz kanal.' using errcode = '22023';
    end if;
  end if;
  if v_yeni or p_data ? 'body' then
    if char_length(btrim(v_body)) not between 1 and 20000 then
      raise exception 'Şablon gövdesi 1-20000 karakter olmalı.' using errcode = '22023';
    end if;
  end if;
  if v_durum is not null and v_durum not in ('draft', 'active', 'archived') then
    raise exception 'Geçersiz şablon durumu.' using errcode = '22023';
  end if;

  if v_yeni then
    v_id := coalesce(v_id, gen_random_uuid());

    insert into public.growth_templates
      (id, name, channel, lifecycle_use_case, subject, body, variables, status)
    values (
      v_id,
      v_ad,
      v_kanal,
      nullif(btrim(coalesce(p_data ->> 'lifecycle_use_case', '')), ''),
      nullif(btrim(coalesce(p_data ->> 'subject', '')), ''),
      v_body,
      public._growth_metin_dizi(p_data -> 'variables'),
      coalesce(v_durum, 'draft')
    );
  else
    update public.growth_templates t set
      name              = case when p_data ? 'name' then v_ad else t.name end,
      channel           = case when p_data ? 'channel' then v_kanal else t.channel end,
      lifecycle_use_case = case when p_data ? 'lifecycle_use_case'
                             then nullif(btrim(coalesce(p_data ->> 'lifecycle_use_case', '')), '')
                             else t.lifecycle_use_case end,
      subject           = case when p_data ? 'subject' then nullif(btrim(coalesce(p_data ->> 'subject', '')), '') else t.subject end,
      body              = case when p_data ? 'body' then v_body else t.body end,
      variables         = case when p_data ? 'variables' then public._growth_metin_dizi(p_data -> 'variables') else t.variables end,
      version           = case when p_data ? 'body' and v_body is distinct from t.body then t.version + 1 else t.version end,
      status            = coalesce(v_durum, t.status),
      updated_at        = now()
     where t.id = v_id;
  end if;

  perform public.log_admin_action('sablon_kaydedildi',
    jsonb_build_object('template_id', v_id, 'yeni', v_yeni));
  return v_id;
end;
$function$;

-- ---------------------------------------------------------------------
-- 3. KAMPANYALAR (growth_campaigns)
-- ---------------------------------------------------------------------

-- 3.1 Liste.
create or replace function public.admin_kampanya_listele(
  p_status text default null,
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
  v_durum    text := nullif(btrim(coalesce(p_status, '')), '');
  v_toplam   int;
  v_satirlar jsonb;
begin
  perform public.require_admin();

  select count(*)::int into v_toplam
    from public.growth_campaigns c
   where (v_durum is null or c.status = v_durum);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id), '[]'::jsonb)
    into v_satirlar
    from (
      select c.id, c.name, c.channel, c.audience, c.segment_id, c.status, c.template_id,
             c.scheduled_at, c.sent, c.opened, c.clicked, c.converted, c.revenue, c.created_at
        from public.growth_campaigns c
       where (v_durum is null or c.status = v_durum)
       order by c.created_at desc, c.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('rows', v_satirlar, 'total', v_toplam);
end;
$function$;

-- 3.2 Upsert: id verilip kayıt varsa güncellenir, yoksa yeni kayıt açılır.
create or replace function public.admin_kampanya_kaydet(p_data jsonb)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_id     uuid;
  v_yeni   boolean;
  v_ad     text;
  v_kanal  text;
  v_durum  text;
begin
  perform public.require_admin();
  if p_data is null or jsonb_typeof(p_data) <> 'object' then
    raise exception 'Kampanya verisi nesne olmalı.' using errcode = '22023';
  end if;

  v_id    := nullif(p_data ->> 'id', '')::uuid;
  v_ad    := btrim(coalesce(p_data ->> 'name', ''));
  v_kanal := btrim(coalesce(p_data ->> 'channel', ''));
  v_durum := nullif(btrim(coalesce(p_data ->> 'status', '')), '');

  v_yeni := v_id is null or not exists (select 1 from public.growth_campaigns c where c.id = v_id);

  if v_yeni or p_data ? 'name' then
    if char_length(v_ad) not between 1 and 120 then
      raise exception 'Kampanya adı 1-120 karakter olmalı.' using errcode = '22023';
    end if;
  end if;
  if v_yeni or p_data ? 'channel' then
    if v_kanal not in ('email', 'sms', 'push', 'in_app', 'whatsapp') then
      raise exception 'Geçersiz kanal.' using errcode = '22023';
    end if;
  end if;
  if v_durum is not null and v_durum not in ('draft', 'scheduled', 'running', 'completed') then
    raise exception 'Geçersiz kampanya durumu.' using errcode = '22023';
  end if;

  if v_yeni then
    v_id := coalesce(v_id, gen_random_uuid());

    insert into public.growth_campaigns
      (id, name, channel, audience, segment_id, status, template_id, scheduled_at)
    values (
      v_id,
      v_ad,
      v_kanal,
      nullif(btrim(coalesce(p_data ->> 'audience', '')), ''),
      nullif(p_data ->> 'segment_id', '')::uuid,
      coalesce(v_durum, 'draft'),
      nullif(p_data ->> 'template_id', '')::uuid,
      nullif(p_data ->> 'scheduled_at', '')::timestamptz
    );
  else
    update public.growth_campaigns c set
      name         = case when p_data ? 'name' then v_ad else c.name end,
      channel      = case when p_data ? 'channel' then v_kanal else c.channel end,
      audience     = case when p_data ? 'audience' then nullif(btrim(coalesce(p_data ->> 'audience', '')), '') else c.audience end,
      segment_id   = case when p_data ? 'segment_id' then nullif(p_data ->> 'segment_id', '')::uuid else c.segment_id end,
      status       = coalesce(v_durum, c.status),
      template_id  = case when p_data ? 'template_id' then nullif(p_data ->> 'template_id', '')::uuid else c.template_id end,
      scheduled_at = case when p_data ? 'scheduled_at' then nullif(p_data ->> 'scheduled_at', '')::timestamptz else c.scheduled_at end
     where c.id = v_id;
  end if;

  perform public.log_admin_action('kampanya_kaydedildi',
    jsonb_build_object('campaign_id', v_id, 'yeni', v_yeni));
  return v_id;
end;
$function$;

-- ---------------------------------------------------------------------
-- 4. REVOKE / GRANT
-- ---------------------------------------------------------------------
revoke execute on function public.admin_journey_listele(text, int, int)   from public, anon;
revoke execute on function public.admin_journey_kaydet(jsonb)             from public, anon;
revoke execute on function public.admin_journey_adim_listele(uuid)        from public, anon;
revoke execute on function public.admin_template_listele(text, text, int, int) from public, anon;
revoke execute on function public.admin_template_kaydet(jsonb)            from public, anon;
revoke execute on function public.admin_kampanya_listele(text, int, int)  from public, anon;
revoke execute on function public.admin_kampanya_kaydet(jsonb)            from public, anon;

grant execute on function public.admin_journey_listele(text, int, int)   to authenticated;
grant execute on function public.admin_journey_kaydet(jsonb)             to authenticated;
grant execute on function public.admin_journey_adim_listele(uuid)        to authenticated;
grant execute on function public.admin_template_listele(text, text, int, int) to authenticated;
grant execute on function public.admin_template_kaydet(jsonb)            to authenticated;
grant execute on function public.admin_kampanya_listele(text, int, int)  to authenticated;
grant execute on function public.admin_kampanya_kaydet(jsonb)            to authenticated;
