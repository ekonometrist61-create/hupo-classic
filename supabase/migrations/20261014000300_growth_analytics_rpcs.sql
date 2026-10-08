set client_encoding = 'UTF8';

-- =====================================================================
--  Growth analitik ve AI öneri RPC katmanı (salt okunur + geri bildirim)
--  Tarih : 2026-10-14
--  Ön koşul: 20260920000900_admin_role_and_payments.sql  (require_admin, log_admin_action)
--            20261014000000_growth_crm_core.sql           (growth_* tablolar ve enum'lar)
--
--  NE EKLİYOR?
--    analitik    : admin_growth_ozet, admin_lifecycle_dagilim, admin_prospect_kaynaklar
--    AI öneri    : admin_ai_oneri_listele, admin_ai_oneri_geri_bildirim
--
--  NOT (şema farkları)
--    * growth_support_tickets.status enum'u (new/open/waiting/resolved) 'closed' içermez;
--      açık talep = status <> 'resolved'.
--    * growth_prospects kaynak kanalını source_type kolonunda tutar; çıktıda source_channel adıyla döner.
--    * growth_ai_recommendations: reason -> description, status -> accepted (approved/executed = true,
--      rejected = false, diğerleri null). score ve expires_at kolonları yok; null döner.
--
--  GÜVENLİK
--    * Her public fonksiyon SECURITY DEFINER + set search_path = '' ve İLK ifadesi public.require_admin().
--    * Geri bildirim işlemi public.log_admin_action ile denetim izine yazılır (PII yazılmaz).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. ANALİTİK
-- ---------------------------------------------------------------------

-- 1.1 Özet kartları. p_gun: son N gün (1-365) etkinlik ve mesaj sayıları için.
create or replace function public.admin_growth_ozet(p_gun int default 30)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_gun   int := least(greatest(coalesce(p_gun, 30), 1), 365);
  v_bas   timestamptz := now() - make_interval(days => least(greatest(coalesce(p_gun, 30), 1), 365));
begin
  perform public.require_admin();

  return jsonb_build_object(
    'gun', v_gun,
    'total_households',    (select count(*)::int from public.growth_households),
    'active_households',   (select count(*)::int from public.growth_households h
                             where h.lifecycle in ('activated', 'engaged', 'paid')),
    'total_prospects',     (select count(*)::int from public.growth_prospects),
    'converted_prospects', (select count(*)::int from public.growth_prospects p
                             where p.status = 'converted'),
    'open_leads',          (select count(*)::int from public.growth_leads l
                             where l.stage not in ('won', 'lost')),
    'open_tickets',        (select count(*)::int from public.growth_support_tickets s
                             where s.status <> 'resolved'),
    'recent_events',       (select count(*)::int from public.growth_events e
                             where e.occurred_at >= v_bas),
    'message_log_count',   (select count(*)::int from public.growth_message_log m
                             where m.created_at >= v_bas)
  );
end;
$function$;

-- 1.2 Yaşam döngüsü dağılımı: [{lifecycle, count}] (adede göre azalan).
create or replace function public.admin_lifecycle_dagilim()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
begin
  perform public.require_admin();

  return coalesce((
    select jsonb_agg(jsonb_build_object('lifecycle', x.lifecycle, 'count', x.adet)
                     order by x.adet desc, x.lifecycle)
      from (
        select h.lifecycle::text as lifecycle, count(*)::int as adet
          from public.growth_households h
         group by h.lifecycle
      ) x
  ), '[]'::jsonb);
end;
$function$;

-- 1.3 Potansiyel aday kaynakları: [{source_channel, count}] (adede göre azalan).
create or replace function public.admin_prospect_kaynaklar()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
begin
  perform public.require_admin();

  return coalesce((
    select jsonb_agg(jsonb_build_object('source_channel', x.kanal, 'count', x.adet)
                     order by x.adet desc, x.kanal)
      from (
        select p.source_type::text as kanal, count(*)::int as adet
          from public.growth_prospects p
         group by p.source_type
      ) x
  ), '[]'::jsonb);
end;
$function$;

-- ---------------------------------------------------------------------
-- 2. AI ÖNERİLER (growth_ai_recommendations)
-- ---------------------------------------------------------------------

-- 2.1 Liste. Opsiyonel hane filtresi. Dönüş: { rows: [...], total: n }.
create or replace function public.admin_ai_oneri_listele(
  p_household_id uuid default null,
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
    from public.growth_ai_recommendations r
   where (p_household_id is null or r.household_id = p_household_id);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id), '[]'::jsonb)
    into v_satirlar
    from (
      select r.id,
             r.household_id,
             r.recommendation_type,
             r.title,
             r.reason as description,
             null::int as score,
             case when r.status in ('approved', 'executed') then true
                  when r.status = 'rejected' then false
                  else null end as accepted,
             r.status,
             null::timestamptz as expires_at,
             r.created_at
        from public.growth_ai_recommendations r
       where (p_household_id is null or r.household_id = p_household_id)
       order by r.created_at desc, r.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('rows', v_satirlar, 'total', v_toplam);
end;
$function$;

-- 2.2 Geri bildirim: öneriyi kabul (true) veya reddet (false). Yalnızca karar alanları yazılır.
create or replace function public.admin_ai_oneri_geri_bildirim(
  p_recommendation_id uuid,
  p_accepted          boolean
)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_uid   uuid := (select auth.uid());
  v_eski  text;
begin
  perform public.require_admin();
  if p_accepted is null then
    raise exception 'Kabul durumu gerekli.' using errcode = '22023';
  end if;

  select r.status into v_eski
    from public.growth_ai_recommendations r
   where r.id = p_recommendation_id
   for update;
  if not found then
    raise exception 'Öneri bulunamadı' using errcode = 'P0002';
  end if;
  if v_eski in ('executed', 'expired') then
    raise exception 'Bu öneri artık geri bildirim almaz (durum: %).', v_eski using errcode = '23514';
  end if;

  update public.growth_ai_recommendations r
     set status      = case when p_accepted then 'approved' else 'rejected' end,
         reviewed_by = v_uid,
         reviewed_at = now()
   where r.id = p_recommendation_id;

  perform public.log_admin_action('ai_onerisi_geri_bildirim',
    jsonb_build_object('recommendation_id', p_recommendation_id,
                       'kabul', p_accepted, 'durum_eski', v_eski));
end;
$function$;

-- ---------------------------------------------------------------------
-- 3. REVOKE / GRANT
-- ---------------------------------------------------------------------
revoke execute on function public.admin_growth_ozet(int)                          from public, anon;
revoke execute on function public.admin_lifecycle_dagilim()                       from public, anon;
revoke execute on function public.admin_prospect_kaynaklar()                      from public, anon;
revoke execute on function public.admin_ai_oneri_listele(uuid, int, int)          from public, anon;
revoke execute on function public.admin_ai_oneri_geri_bildirim(uuid, boolean)     from public, anon;

grant execute on function public.admin_growth_ozet(int)                           to authenticated;
grant execute on function public.admin_lifecycle_dagilim()                        to authenticated;
grant execute on function public.admin_prospect_kaynaklar()                       to authenticated;
grant execute on function public.admin_ai_oneri_listele(uuid, int, int)           to authenticated;
grant execute on function public.admin_ai_oneri_geri_bildirim(uuid, boolean)      to authenticated;
