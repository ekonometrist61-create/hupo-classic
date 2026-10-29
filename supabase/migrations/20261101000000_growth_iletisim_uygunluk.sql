set client_encoding = 'UTF8';

-- =====================================================================
--  Growth iletişim uygunluk kapısı: izin + sessiz saat + sıklık sınırı
--  Tarih : 2026-10-27
--  Plan  : docs/growth-crm/ILETISIM_EKSIKLERI_PLANI_2026-10-27.md (E4 / P4)
--  Ön koşul: 20261007000010 (iletisim_tercihleri), 20261007000020 (iletisim_ayarlari),
--            20261014000000 (growth_households, growth_message_log),
--            20261015000000 (ticari_iletisim_engelli_mi), 20261020000300 (kanal listesi)
--
--  NE EKLİYOR?
--    tablo    : public.growth_iletisim_limitleri (tek satır; günlük sınır)
--    fonksiyon: public.growth_iletisim_uygun_mu(hane, kanal, zaman) -> jsonb
--               {uygun bool, neden text, sonraki_uygun timestamptz}
--    iç       : _growth_sessiz_mi, _growth_sonraki_sabah, _growth_siklik_sonraki
--
--  KAPSAM: YALNIZ PAZARLAMA
--    Bu fonksiyon pazarlama gönderimleri içindir. İşlem (hesap) bildirimleri
--    (doğrulama, şifre, ödeme, olay_kutusu / eposta_outbox) bu kapıdan GEÇMEZ;
--    sessiz saat ve sıklık sınırı onlara uygulanmaz. growth_message_log'a yalnız
--    pazarlama gönderimleri yazılmalıdır.
--
--  KURALLAR (sırayla; ilk başarısız olan neden olur)
--    1. İzin: TEK TANIM _growth_izin_var_mi(hane, kanal) -> growth_consent_bridge.granted.
--       Bridge iki kaynağı birleştirir: core velisinin iletisim_tercihleri satırı ve hane
--       üzerindeki form/CRM izinleri (growth_household_izinleri, 20261027). Journey motoru
--       (20261099) ve gönderim anı kontrolü (20261110) aynı fonksiyonu kullanır.
--       E-posta ise bastırma listesinde (iptal) olmamalı. Değilse neden='izin_yok'.
--    2. Sessiz saat: iletisim_ayarlari.sessiz_baslangic..sessiz_bitis (zaman_dilimi).
--       İçindeyse neden='sessiz_saat', sonraki_uygun = sabah bitiş saati.
--    3. Sıklık: aynı hane + aynı kanal için growth_message_log'da
--       gonderildi / teslim_edildi / acildi / tiklandi / donustu / kuyrukta kayıtları sayılır.
--       Son 24 saatte >= günlük sınır veya son 7 günde >= haftalık sınır
--       (iletisim_ayarlari.haftalik_limit) ise neden='siklik_siniri'.
--
--  KARAR NOTLARI
--    * Sessiz saat ve haftalık sınır iletisim_ayarlari satırından okunur (REUSE haritası).
--      Satır yoksa 21:00-09:00 ve haftalık 3 kullanılır.
--    * Günlük sınır iletisim_ayarlari'nda kolon olmadığı için growth_iletisim_limitleri
--      tek satırlık tabloda tutulur (varsayılan 1).
--    * Uygunsa sonraki_uygun = p_simdi. İzin yoksa null (kendiliğinden uygunluk yok).
--      Bir sınır 0 ise (yönetici kapattı) neden='siklik_siniri', sonraki_uygun = null.
--    * Kanal eşlemesi: email->email, push->push, sms->sms, in_app->in_app (bridge kanal adları).
--      whatsapp bridge'de kanal olmadığı için her zaman izin_yok.
--    * Zaman damgası coalesce(sent_at, created_at). Pencere sınırı dışlayıcıdır:
--      tam 24 saat (veya 7 gün) önceki kayıt sayılmaz.
--    * Yalnız service_role çağırır. Fonksiyon SECURITY DEFINER, search_path = ''.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Günlük sınır (tek satır)
-- ---------------------------------------------------------------------
create table if not exists public.growth_iletisim_limitleri (
  id            boolean primary key default true,
  gunluk_limit  integer not null default 1,
  updated_at    timestamptz not null default now(),
  constraint growth_iletisim_limitleri_tek_satir check (id),
  constraint growth_iletisim_limitleri_gunluk check (gunluk_limit between 0 and 20)
);
insert into public.growth_iletisim_limitleri (id) values (true) on conflict (id) do nothing;

alter table public.growth_iletisim_limitleri enable row level security;
revoke all on table public.growth_iletisim_limitleri from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. İç yardımcılar (istemciye kapalı; yalnız growth_iletisim_uygun_mu çağırır)
-- ---------------------------------------------------------------------

-- Verilen anın yerel saati sessiz aralıkta mı? Gece yarısını aşan aralık desteklenir.
create or replace function public._growth_sessiz_mi(
  p_zaman timestamptz,
  p_bas   time,
  p_bit   time,
  p_tz    text
)
returns boolean
language plpgsql
stable
set search_path = ''
as $function$
declare
  v_yerel time := (p_zaman at time zone p_tz)::time;
begin
  if p_bas > p_bit then
    return v_yerel >= p_bas or v_yerel < p_bit;   -- gece yarısını aşan aralık
  end if;
  return v_yerel >= p_bas and v_yerel < p_bit;
end;
$function$;

-- p_zaman'dan sonraki ilk bitiş saati (yerel). Örn. 21:30 -> ertesi gün 09:00.
create or replace function public._growth_sonraki_sabah(
  p_zaman timestamptz,
  p_bit   time,
  p_tz    text
)
returns timestamptz
language plpgsql
stable
set search_path = ''
as $function$
declare
  v_yerel timestamp := p_zaman at time zone p_tz;
  v_aday  timestamp := date_trunc('day', p_zaman at time zone p_tz) + (p_bit - time '00:00');
begin
  if v_aday <= v_yerel then
    v_aday := v_aday + interval '1 day';
  end if;
  return v_aday at time zone p_tz;
end;
$function$;

-- Pencere içindeki pazarlama kayıtları p_limit'e ulaştıysa, sayının p_limit'in altına
-- ineceği ilk an (en eski kayıt pencereden çıkınca). Ulaşmadıysa null.
create or replace function public._growth_siklik_sonraki(
  p_household_id uuid,
  p_kanal        text,
  p_simdi        timestamptz,
  p_pencere      interval,
  p_limit        integer
)
returns timestamptz
language plpgsql
stable
set search_path = ''
as $function$
declare
  v_zamanlar timestamptz[];
  v_n        integer;
begin
  select array_agg(x.t order by x.t) into v_zamanlar
    from (
      select coalesce(l.sent_at, l.created_at) as t
        from public.growth_message_log l
       where l.household_id = p_household_id
         and l.channel = p_kanal
         and l.status in ('gonderildi', 'teslim_edildi', 'acildi', 'tiklandi', 'donustu', 'kuyrukta')
         and coalesce(l.sent_at, l.created_at) > p_simdi - p_pencere
    ) x;

  v_n := coalesce(cardinality(v_zamanlar), 0);
  if v_n < p_limit then
    return null;
  end if;
  -- Dizi küçükten büyüğe sıralı (1 tabanlı). (n - limit + 1). kayıt pencereden çıkınca sayı limit-1'e iner.
  return v_zamanlar[v_n - p_limit + 1] + p_pencere;
end;
$function$;

-- Hane + growth kanalı için izin: bridge'de granted ve (e-postada) bastırılmamış ve hane engelli değil.
-- Tek izin tanımı: uygunluk kapısı ve gönderim anı kontrolü bunu çağırır.
create or replace function public._growth_izin_var_mi(p_household_id uuid, p_kanal text)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_email text;
begin
  select h.email into v_email from public.growth_households h where h.id = p_household_id;
  if not found then
    return false;
  end if;

  if not exists (
    select 1 from public.growth_consent_bridge b
     where b.household_id = p_household_id
       and b.channel = p_kanal
       and b.granted
  ) then
    return false;
  end if;

  if p_kanal = 'email' and coalesce(public.ticari_iletisim_engelli_mi(v_email), false) then
    return false;   -- e-posta iptal bağlantısıyla bastırılmış
  end if;
  return true;
end;
$function$;

-- ---------------------------------------------------------------------
-- 3. Ana fonksiyon (yalnız service_role; pazarlama gönderimi öncesi çağrılır)
-- ---------------------------------------------------------------------
create or replace function public.growth_iletisim_uygun_mu(
  p_household_id uuid,
  p_channel      text,
  p_simdi        timestamptz default now()
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  h           public.growth_households%rowtype;
  v_kanal     text := lower(btrim(coalesce(p_channel, '')));
  v_growth    text;   -- growth_message_log / growth_campaigns / bridge kanal adı
  v_izinli    boolean;
  v_hafta_lim integer;
  v_gun_lim   integer;
  v_bas       time;
  v_bit       time;
  v_tz        text;
  v_gun       timestamptz;
  v_hafta     timestamptz;
  v_sonraki   timestamptz;
begin
  if v_kanal in ('email', 'eposta') then
    v_growth := 'email';
  elsif v_kanal = 'push' then
    v_growth := 'push';
  elsif v_kanal = 'sms' then
    v_growth := 'sms';
  elsif v_kanal in ('in_app', 'uygulama_ici') then
    v_growth := 'in_app';
  elsif v_kanal = 'whatsapp' then
    v_growth := 'whatsapp';   -- bridge'de yok: izin her zaman yok
  else
    raise exception 'Geçersiz kanal.' using errcode = '22023';
  end if;

  select * into h from public.growth_households where id = p_household_id;
  if not found then
    raise exception 'Hane bulunamadı.' using errcode = 'P0002';
  end if;

  -- 1. İzin (tek tanım: growth_consent_bridge; core tercih + hane/form izni)
  v_izinli := public._growth_izin_var_mi(h.id, v_growth);
  if not v_izinli then
    return jsonb_build_object('uygun', false, 'neden', 'izin_yok', 'sonraki_uygun', null);
  end if;

  -- Ayarlar: iletisim_ayarlari satırı; yoksa 21:00-09:00 / haftalık 3 / Europe/Istanbul.
  v_hafta_lim := coalesce((select a.haftalik_limit from public.iletisim_ayarlari a where a.id), 3);
  v_bas       := coalesce((select a.sessiz_baslangic from public.iletisim_ayarlari a where a.id), time '21:00');
  v_bit       := coalesce((select a.sessiz_bitis from public.iletisim_ayarlari a where a.id), time '09:00');
  v_tz        := coalesce((select a.zaman_dilimi from public.iletisim_ayarlari a where a.id), 'Europe/Istanbul');
  v_gun_lim   := coalesce((select l.gunluk_limit from public.growth_iletisim_limitleri l where l.id), 1);

  -- 2. Sessiz saat
  if public._growth_sessiz_mi(p_simdi, v_bas, v_bit, v_tz) then
    return jsonb_build_object('uygun', false, 'neden', 'sessiz_saat',
                              'sonraki_uygun', public._growth_sonraki_sabah(p_simdi, v_bit, v_tz));
  end if;

  -- 3. Sıklık sınırı
  if v_gun_lim <= 0 or v_hafta_lim <= 0 then
    return jsonb_build_object('uygun', false, 'neden', 'siklik_siniri', 'sonraki_uygun', null);
  end if;

  v_gun   := public._growth_siklik_sonraki(h.id, v_growth, p_simdi, interval '24 hours', v_gun_lim);
  v_hafta := public._growth_siklik_sonraki(h.id, v_growth, p_simdi, interval '7 days', v_hafta_lim);

  if v_gun is not null or v_hafta is not null then
    v_sonraki := greatest(v_gun, v_hafta);   -- greatest null'ları yok sayar
    if public._growth_sessiz_mi(v_sonraki, v_bas, v_bit, v_tz) then
      v_sonraki := public._growth_sonraki_sabah(v_sonraki, v_bit, v_tz);
    end if;
    return jsonb_build_object('uygun', false, 'neden', 'siklik_siniri', 'sonraki_uygun', v_sonraki);
  end if;

  return jsonb_build_object('uygun', true, 'neden', null, 'sonraki_uygun', p_simdi);
end;
$function$;

-- ---------------------------------------------------------------------
-- 4. Yetkiler (service_role dışında kimse çağıramaz)
-- ---------------------------------------------------------------------
revoke execute on function public.growth_iletisim_uygun_mu(uuid, text, timestamptz)
  from public, anon, authenticated;
grant  execute on function public.growth_iletisim_uygun_mu(uuid, text, timestamptz)
  to service_role;

revoke execute on function public._growth_izin_var_mi(uuid, text)
  from public, anon, authenticated;

revoke execute on function public._growth_sessiz_mi(timestamptz, time, time, text)
  from public, anon, authenticated;
revoke execute on function public._growth_sonraki_sabah(timestamptz, time, text)
  from public, anon, authenticated;
revoke execute on function public._growth_siklik_sonraki(uuid, text, timestamptz, interval, integer)
  from public, anon, authenticated;
