-- =====================================================================
--  Journey adımlarını kaydet (P7)
--  Panelde journey adımları tabloya yazılmıyordu; motor (20261099) çalıştıracak adım bulamazdı.
--
--  admin_journey_adim_kaydet(p_journey_id uuid, p_adimlar jsonb) returns jsonb
--    * İlk ifade public.require_admin().
--    * p_adimlar: nesne dizisi, sıra = dizi sırası (position 1..n).
--        { step_type, label, detail?, config? }
--    * İzin verilen tipler: trigger, delay, email, push, in_app, sms, whatsapp.
--      condition / webhook / ai_action motor tarafından işlenmediği için REDDEDİLİR.
--    * delay: config.saat 0-8760 sayı.  sms / whatsapp kaydedilir ama motor kuyruğa almaz (kanal_kapali).
--    * En çok 20 adım. Etiket 1-120 karakter.
--    * Journey 'active' iken veya açık (active/waiting) kaydı varken adımlar DEĞİŞTİRİLEMEZ:
--      uçuştaki kayıtların adımı kaybolmasın.
--    * Adımlar tek işlemde değiştirilir (sil + ekle). Dönüş: { journey_id, adim_sayisi }.
-- =====================================================================

create or replace function public.admin_journey_adim_kaydet(p_journey_id uuid, p_adimlar jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_durum  public.growth_journey_status;
  v_oge    jsonb;
  v_sira   int := 0;
  v_tip    text;
  v_etiket text;
  v_config jsonb;
  v_saat   numeric;
begin
  perform public.require_admin();

  if p_adimlar is null or jsonb_typeof(p_adimlar) <> 'array' then
    raise exception 'Adımlar bir dizi olmalı.' using errcode = '22023';
  end if;
  if jsonb_array_length(p_adimlar) > 20 then
    raise exception 'En fazla 20 adım eklenebilir.' using errcode = '22023';
  end if;

  select j.status into v_durum
    from public.growth_journeys j
   where j.id = p_journey_id
     for update;
  if not found then
    raise exception 'Journey bulunamadı.' using errcode = 'P0002';
  end if;
  if v_durum = 'active' then
    raise exception 'Aktif journey''nin adımları değiştirilemez. Önce duraklatın.' using errcode = '22023';
  end if;
  if exists (select 1 from public.growth_journey_enrollments e
              where e.journey_id = p_journey_id and e.status in ('active', 'waiting')) then
    raise exception 'Açık kaydı olan journey''nin adımları değiştirilemez.' using errcode = '22023';
  end if;

  -- Önce hepsini doğrula; yazma ancak sonra başlar.
  for v_oge in select * from jsonb_array_elements(p_adimlar) loop
    if jsonb_typeof(v_oge) <> 'object' then
      raise exception 'Her adım bir nesne olmalı.' using errcode = '22023';
    end if;
    v_tip    := v_oge ->> 'step_type';
    v_etiket := btrim(coalesce(v_oge ->> 'label', ''));
    v_config := coalesce(v_oge -> 'config', '{}'::jsonb);

    if v_tip is null or v_tip not in ('trigger', 'delay', 'email', 'push', 'in_app', 'sms', 'whatsapp') then
      raise exception 'Adım tipi desteklenmiyor: %', coalesce(v_tip, '(boş)') using errcode = '22023';
    end if;
    if char_length(v_etiket) not between 1 and 120 then
      raise exception 'Adım etiketi 1-120 karakter olmalı.' using errcode = '22023';
    end if;
    if jsonb_typeof(v_config) <> 'object' then
      raise exception 'Adım ayarı nesne olmalı.' using errcode = '22023';
    end if;
    if v_tip = 'delay' then
      if jsonb_typeof(v_config -> 'saat') is distinct from 'number' then
        raise exception 'Bekleme adımında saat sayı olmalı.' using errcode = '22023';
      end if;
      v_saat := (v_config ->> 'saat')::numeric;
      if v_saat < 0 or v_saat > 8760 then
        raise exception 'Bekleme saati 0-8760 arası olmalı.' using errcode = '22023';
      end if;
    end if;
    -- Motor (20261099) e-posta adımında config.sablon okur; yoksa adım işlenemez.
    if v_tip = 'email' then
      if jsonb_typeof(v_config -> 'sablon') is distinct from 'string'
         or btrim(v_config ->> 'sablon') = '' then
        raise exception 'E-posta adımında şablon anahtarı zorunlu.' using errcode = '22023';
      end if;
    end if;
  end loop;

  delete from public.growth_journey_steps s where s.journey_id = p_journey_id;

  for v_oge in select * from jsonb_array_elements(p_adimlar) loop
    v_sira := v_sira + 1;
    insert into public.growth_journey_steps (journey_id, position, step_type, label, detail, config)
    values (
      p_journey_id,
      v_sira,
      v_oge ->> 'step_type',
      btrim(v_oge ->> 'label'),
      nullif(btrim(coalesce(v_oge ->> 'detail', '')), ''),
      coalesce(v_oge -> 'config', '{}'::jsonb)
    );
  end loop;

  update public.growth_journeys j set updated_at = now() where j.id = p_journey_id;

  perform public.log_admin_action('journey_adimlari_kaydedildi',
    jsonb_build_object('journey_id', p_journey_id, 'adim_sayisi', v_sira));

  return jsonb_build_object('journey_id', p_journey_id, 'adim_sayisi', v_sira);
end;
$function$;

revoke execute on function public.admin_journey_adim_kaydet(uuid, jsonb) from public, anon;
grant  execute on function public.admin_journey_adim_kaydet(uuid, jsonb) to authenticated;
