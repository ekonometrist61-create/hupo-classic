-- =====================================================================
-- Growth mesaj günlüğü yazıcısı (İletişim eksikleri E3 / P3)
--
-- Kapsam:
--   * growth_message_log için sunucu tarafı yazma yolu:
--       growth_mesaj_kaydet        : yeni günlük satırı (gönderim öncesi/sonrası)
--       growth_mesaj_durum_guncelle: durum değişimi ve açıldı/tıklandı/dönüştü işaretleri
--   * Kampanya sayaçları (growth_campaigns.sent / opened / clicked / converted)
--     yalnız tetikleyiciyle artar. Bir sayaç, ilgili zaman damgası NULL iken ilk kez
--     dolduğunda bir kez artar. Aynı olay tekrar gelirse (webhook tekrarı) sayaç değişmez.
--   * Zaman damgaları geri alınmaz. Durum gerilese bile sayaç azalmaz.
--   * Bu migration mesaj GÖNDERMEZ. E-posta, SMS, push veya WhatsApp çağrısı içermez.
--
-- Kurallar:
--   * İki RPC yalnız service_role'e açıktır (public/anon/authenticated revoke).
--   * Tablolara istemci erişimi 20261014000000 ile zaten kapalıdır; burada değişmez.
--   * Durum-işaret tutarlılığı: acildi / tiklandi / donustu durumu, ilgili zaman damgası
--     (opened_at / clicked_at / converted_at) dolu değilse reddedilir. Böylece satırdaki
--     durum ile sayaçlar çelişmez.
--   * growth_message_log.status için CHECK eklenir. NOT VALID: mevcut satırlar denetlenmez,
--     yeni yazılan satırlar denetlenir. Bu tabloya bugüne kadar yazan kod yoktu.
--   * 'engellendi' (W9): uygunluk kapısı (growth_iletisim_uygun_mu) veya kanal kuralı göndermeyi
--     engellediğinde yazılır; error alanı neden kodunu taşır (izin_yok, siklik_siniri, kanal_kapali ...).
--     Sıklık sayımı (20261101) 'engellendi' satırlarını saymaz.
--
-- Idempotent: create or replace / if not exists / DO bloğu. Tekrar çalıştırılabilir.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Durum kısıtı (yalnız yeni satırlara)
-- ---------------------------------------------------------------------
do $$
begin
  if not exists (
    select 1 from pg_constraint
     where conname = 'growth_message_log_status_chk'
       and conrelid = 'public.growth_message_log'::regclass
  ) then
    alter table public.growth_message_log
      add constraint growth_message_log_status_chk
      check (status in ('kuyrukta','gonderildi','teslim_edildi','acildi','tiklandi','donustu','basarisiz','izin_yok','engellendi'))
      not valid;
  end if;
end $$;

-- ---------------------------------------------------------------------
-- 2. Sayaç tetikleyicisi: her zaman dolan zaman damgası için bir kez artış
-- ---------------------------------------------------------------------
create or replace function public._growth_mesaj_sayac()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_gonderildi boolean;
  v_acildi     boolean;
  v_tiklandi   boolean;
  v_donustu    boolean;
begin
  if new.campaign_id is null then
    return new;
  end if;

  -- INSERT'te OLD tanımsızdır; yalnız NULL -> dolu geçişleri sayılır.
  if tg_op = 'INSERT' then
    v_gonderildi := new.sent_at is not null;
    v_acildi     := new.opened_at is not null;
    v_tiklandi   := new.clicked_at is not null;
    v_donustu    := new.converted_at is not null;
  else
    v_gonderildi := new.sent_at is not null and old.sent_at is null;
    v_acildi     := new.opened_at is not null and old.opened_at is null;
    v_tiklandi   := new.clicked_at is not null and old.clicked_at is null;
    v_donustu    := new.converted_at is not null and old.converted_at is null;
  end if;

  if v_gonderildi then
    update public.growth_campaigns set sent = sent + 1 where id = new.campaign_id;
  end if;
  if v_acildi then
    update public.growth_campaigns set opened = opened + 1 where id = new.campaign_id;
  end if;
  if v_tiklandi then
    update public.growth_campaigns set clicked = clicked + 1 where id = new.campaign_id;
  end if;
  if v_donustu then
    update public.growth_campaigns set converted = converted + 1 where id = new.campaign_id;
  end if;

  return new;
end;
$function$;

drop trigger if exists growth_message_log_sayac_tr on public.growth_message_log;
create trigger growth_message_log_sayac_tr
  after insert or update of sent_at, opened_at, clicked_at, converted_at
  on public.growth_message_log
  for each row
  execute function public._growth_mesaj_sayac();

-- ---------------------------------------------------------------------
-- 3. Oluşturma: günlük satırı yazar
--    Açıldı / tıklandı / dönüştü durumları yalnız growth_mesaj_durum_guncelle ile
--    yazılır (işaret bilgisi burada yoktur).
-- ---------------------------------------------------------------------
create or replace function public.growth_mesaj_kaydet(
  p_household_id        uuid,
  p_campaign_id         uuid,
  p_journey_id          uuid,
  p_channel             text,
  p_status              text,
  p_provider_message_id text,
  p_consent_snapshot    jsonb,
  p_payload_hash        text,
  p_error               text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_id uuid;
begin
  if p_household_id is null then
    raise exception 'Hane kimliği zorunlu.' using errcode = '22023';
  end if;

  if p_channel is null or p_channel not in ('email','push','in_app','sms','whatsapp') then
    raise exception 'Geçersiz kanal.' using errcode = '22023';
  end if;

  if p_status is null or p_status not in ('kuyrukta','gonderildi','teslim_edildi','acildi','tiklandi','donustu','basarisiz','izin_yok','engellendi') then
    raise exception 'Geçersiz mesaj durumu.' using errcode = '22023';
  end if;

  if p_status in ('acildi','tiklandi','donustu') then
    raise exception 'Açıldı, tıklandı ve dönüştü durumları growth_mesaj_durum_guncelle ile yazılır.'
      using errcode = '22023';
  end if;

  if p_consent_snapshot is null or jsonb_typeof(p_consent_snapshot) <> 'object' then
    raise exception 'İzin anlık görüntüsü nesne olmalı.' using errcode = '22023';
  end if;

  insert into public.growth_message_log
    (household_id, campaign_id, journey_id, channel, status, provider_message_id,
     consent_snapshot, payload_hash, sent_at, error)
  values (
    p_household_id,
    p_campaign_id,
    p_journey_id,
    p_channel,
    p_status,
    nullif(btrim(coalesce(p_provider_message_id, '')), ''),
    p_consent_snapshot,
    nullif(btrim(coalesce(p_payload_hash, '')), ''),
    case when p_status in ('gonderildi','teslim_edildi') then now() end,
    nullif(left(btrim(coalesce(p_error, '')), 500), '')
  )
  returning id into v_id;

  return v_id;
end;
$function$;

-- ---------------------------------------------------------------------
-- 4. Durum güncelleme: durum ve işaretler (webhook / gönderici tarafı)
--    p_opened / p_clicked / p_converted true ise ilgili zaman damgası
--    yalnız NULL iken doldurulur; dolu ise olduğu gibi kalır (tek sayım).
-- ---------------------------------------------------------------------
create or replace function public.growth_mesaj_durum_guncelle(
  p_id                  uuid,
  p_status              text,
  p_provider_message_id text default null,
  p_opened              boolean default false,
  p_clicked             boolean default false,
  p_converted           boolean default false
)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_satir      public.growth_message_log%rowtype;
  v_simdi      timestamptz := now();
  v_gonderildi timestamptz;
  v_acildi     timestamptz;
  v_tiklandi   timestamptz;
  v_donustu    timestamptz;
begin
  if p_id is null then
    raise exception 'Mesaj kimliği zorunlu.' using errcode = '22023';
  end if;

  if p_status is null or p_status not in ('kuyrukta','gonderildi','teslim_edildi','acildi','tiklandi','donustu','basarisiz','izin_yok','engellendi') then
    raise exception 'Geçersiz mesaj durumu.' using errcode = '22023';
  end if;

  select * into v_satir
    from public.growth_message_log m
   where m.id = p_id
   for update;

  if not found then
    raise exception 'Mesaj kaydı bulunamadı' using errcode = 'P0002';
  end if;

  v_gonderildi := coalesce(v_satir.sent_at,
    case when p_status in ('gonderildi','teslim_edildi','acildi','tiklandi','donustu') then v_simdi end);
  v_acildi     := coalesce(v_satir.opened_at,
    case when coalesce(p_opened, false) then v_simdi end);
  v_tiklandi   := coalesce(v_satir.clicked_at,
    case when coalesce(p_clicked, false) then v_simdi end);
  v_donustu    := coalesce(v_satir.converted_at,
    case when coalesce(p_converted, false) then v_simdi end);

  if p_status = 'acildi' and v_acildi is null then
    raise exception 'Durum acildi ama açılma işareti yok.' using errcode = '22023';
  end if;
  if p_status = 'tiklandi' and v_tiklandi is null then
    raise exception 'Durum tiklandi ama tıklama işareti yok.' using errcode = '22023';
  end if;
  if p_status = 'donustu' and v_donustu is null then
    raise exception 'Durum donustu ama dönüşüm işareti yok.' using errcode = '22023';
  end if;

  update public.growth_message_log m set
    status              = p_status,
    provider_message_id = coalesce(nullif(btrim(coalesce(p_provider_message_id, '')), ''), m.provider_message_id),
    sent_at             = v_gonderildi,
    opened_at           = v_acildi,
    clicked_at          = v_tiklandi,
    converted_at        = v_donustu
   where m.id = p_id;
end;
$function$;

-- ---------------------------------------------------------------------
-- 5. REVOKE / GRANT
-- ---------------------------------------------------------------------
revoke execute on function public._growth_mesaj_sayac()                                                           from public, anon, authenticated;
revoke execute on function public.growth_mesaj_kaydet(uuid, uuid, uuid, text, text, text, jsonb, text, text)     from public, anon, authenticated;
revoke execute on function public.growth_mesaj_durum_guncelle(uuid, text, text, boolean, boolean, boolean)       from public, anon, authenticated;

grant execute on function public.growth_mesaj_kaydet(uuid, uuid, uuid, text, text, text, jsonb, text, text)     to service_role;
grant execute on function public.growth_mesaj_durum_guncelle(uuid, text, text, boolean, boolean, boolean)       to service_role;
