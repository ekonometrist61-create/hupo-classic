-- Kullanım süresi analitiği (anonim): hangi yüzeyde hangi ekranda ne kadar vakit geçiriliyor.
--
-- Karar kaydı (Growth CRM olay altyapısı yeniden kullanılmadı):
--   growth_events (20261014000000_growth_crm_core.sql) hane/öğrenci/kimlik bağlantısına (household_id,
--   anonymous_id, growth_identity_links) göre tasarlanmış, pazarlama otomasyonu için kişiye bağlı bir olay
--   akışıdır. Bu özellik ise kimliğe bağlanmaması gereken, yüksek hacimli ve 300 gün sonunda silinecek
--   ekran-süresi verisidir. Aynı tabloyu kullanmak (a) anonimlik sözünü zayıflatır, (b) CRM segment/yolculuk
--   tetikleyicilerini gürültüyle doldurur, (c) saklama süresini CRM kuralından ayıramaz. Bu yüzden bağımsız
--   tablo kullanılır; hesap, çocuk, e-posta, profil kimliği, serbest metin ASLA saklanmaz.
--
-- Saklama: 300 gün (bir eğitim-öğretim dönemi). kullanim_olaylari_temizle() eskileri siler; pg_cron kuruluysa
-- her gün 03:15'te otomatik çalışır, değilse zamanlanmış bir görev (ya da elle) çağırmalıdır.

create table if not exists public.kullanim_olaylari (
  id               bigint generated always as identity primary key,
  yuzey            text        not null check (yuzey in ('mobil', 'flutter_web', 'site', 'yonetim', 'veli', 'ogretmen')),
  ekran            text        not null check (char_length(ekran) between 1 and 60 and ekran ~ '^[A-Za-z0-9_/.:\[\]-]+$'),
  sure_sn          integer     not null check (sure_sn between 1 and 14400),
  baslangic        timestamptz not null,
  oturum_anahtari  text        not null check (oturum_anahtari ~ '^[A-Za-z0-9_-]{16,64}$'),
  rol              text        not null check (rol in ('ogrenci', 'veli', 'ogretmen', 'admin', 'ziyaretci')),
  created_at       timestamptz not null default now()
);

comment on table public.kullanim_olaylari is
  'Anonim ekran-süresi olayları. Kimliğe bağlı değildir; 300 gün sonra kullanim_olaylari_temizle() siler.';

create index if not exists kullanim_olaylari_baslangic_idx on public.kullanim_olaylari (baslangic);
create index if not exists kullanim_olaylari_oturum_hiz_idx on public.kullanim_olaylari (oturum_anahtari, created_at desc);

alter table public.kullanim_olaylari enable row level security;
revoke all on table public.kullanim_olaylari from public, anon, authenticated;
-- Politika yok: istemciler tabloya doğrudan erişemez; yalnız aşağıdaki RPC'ler (security definer) yazar/okur.

-- Toplu olay gönderimi ------------------------------------------------------------------------------
create or replace function public.kullanim_olaylari_gonder(p_olaylar jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_olay    jsonb;
  v_n       integer;
  v_sure    integer;
  v_bas     timestamptz;
  v_ekran   text;
  v_anahtar text;
  v_oturum  text;
  v_son_dk  integer;
  v_anahtarlar text[] := '{}';
  v_sayac   integer := 0;
begin
  if p_olaylar is null or jsonb_typeof(p_olaylar) <> 'array' then
    raise exception 'olaylar dizi olmalı' using errcode = '22023';
  end if;
  v_n := jsonb_array_length(p_olaylar);
  if v_n = 0 then
    return jsonb_build_object('kabul', 0);
  end if;
  if v_n > 50 then
    raise exception 'çağrı başına en çok 50 olay' using errcode = '22023';
  end if;

  for v_olay in select * from jsonb_array_elements(p_olaylar) loop
    if jsonb_typeof(v_olay) <> 'object'
       or jsonb_typeof(v_olay -> 'sure_sn') is distinct from 'number'
       or jsonb_typeof(v_olay -> 'yuzey') is distinct from 'string'
       or jsonb_typeof(v_olay -> 'ekran') is distinct from 'string'
       or jsonb_typeof(v_olay -> 'baslangic') is distinct from 'string'
       or jsonb_typeof(v_olay -> 'oturum_anahtari') is distinct from 'string'
       or jsonb_typeof(v_olay -> 'rol') is distinct from 'string' then
      raise exception 'olay alanları eksik ya da türü hatalı' using errcode = '22023';
    end if;
    if (v_olay ->> 'sure_sn') !~ '^[0-9]{1,5}$' then
      raise exception 'sure_sn tam sayı olmalı' using errcode = '22023';
    end if;
    v_sure := (v_olay ->> 'sure_sn')::integer;
    if v_sure not between 1 and 14400 then
      raise exception 'sure_sn 1-14400 olmalı' using errcode = '22023';
    end if;
    if (v_olay ->> 'yuzey') not in ('mobil', 'flutter_web', 'site', 'yonetim', 'veli', 'ogretmen') then
      raise exception 'geçersiz yuzey' using errcode = '22023';
    end if;
    if (v_olay ->> 'rol') not in ('ogrenci', 'veli', 'ogretmen', 'admin', 'ziyaretci') then
      raise exception 'geçersiz rol' using errcode = '22023';
    end if;
    v_ekran := v_olay ->> 'ekran';
    if char_length(v_ekran) not between 1 and 60 or v_ekran !~ '^[A-Za-z0-9_/.:\[\]-]+$' then
      raise exception 'geçersiz ekran adı' using errcode = '22023';
    end if;
    v_oturum := v_olay ->> 'oturum_anahtari';
    if v_oturum !~ '^[A-Za-z0-9_-]{16,64}$' then
      raise exception 'geçersiz oturum anahtarı' using errcode = '22023';
    end if;
    begin
      v_bas := (v_olay ->> 'baslangic')::timestamptz;
    exception when others then
      raise exception 'geçersiz baslangic' using errcode = '22023';
    end;
    -- Çevrimdışı kuyruk için geçmiş toleransı 2 gün, saat kayması için gelecek toleransı 5 dk.
    if v_bas < now() - interval '2 days' or v_bas > now() + interval '5 minutes' then
      raise exception 'baslangic izin verilen aralıkta değil' using errcode = '22023';
    end if;
    if not (v_oturum = any (v_anahtarlar)) then
      v_anahtarlar := v_anahtarlar || v_oturum;
    end if;
  end loop;

  -- Basit hız sınırı: oturum anahtarı başına son 1 dakikada en çok 100 olay.
  foreach v_anahtar in array v_anahtarlar loop
    select count(*) into v_son_dk from public.kullanim_olaylari
      where oturum_anahtari = v_anahtar and created_at > now() - interval '1 minute';
    v_sayac := (select count(*) from jsonb_array_elements(p_olaylar) e where e ->> 'oturum_anahtari' = v_anahtar);
    if v_son_dk + v_sayac > 100 then
      raise exception 'hız sınırı aşıldı' using errcode = '54000';
    end if;
  end loop;

  insert into public.kullanim_olaylari (yuzey, ekran, sure_sn, baslangic, oturum_anahtari, rol)
  select e ->> 'yuzey', e ->> 'ekran', (e ->> 'sure_sn')::integer, (e ->> 'baslangic')::timestamptz,
         e ->> 'oturum_anahtari', e ->> 'rol'
  from jsonb_array_elements(p_olaylar) e;

  return jsonb_build_object('kabul', v_n);
end $$;

revoke all on function public.kullanim_olaylari_gonder(jsonb) from public;
grant execute on function public.kullanim_olaylari_gonder(jsonb) to anon, authenticated;

-- Yönetim raporu ------------------------------------------------------------------------------------
-- Yüzey × ekran toplamları ve günlük trend. 5'ten az oturumlu satırlar/günler bastırılır.
create or replace function public.kullanim_raporu(p_gun integer default 30, p_yuzey text default null)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_gun      integer := least(greatest(coalesce(p_gun, 30), 1), 300);
  v_baslangic timestamptz;
  v_satirlar jsonb;
  v_trend    jsonb;
begin
  perform public.require_admin();
  if p_yuzey is not null and p_yuzey not in ('mobil', 'flutter_web', 'site', 'yonetim', 'veli', 'ogretmen') then
    raise exception 'geçersiz yuzey' using errcode = '22023';
  end if;
  v_baslangic := now() - make_interval(days => v_gun);

  select coalesce(jsonb_agg(to_jsonb(s) order by s.toplam_sn desc), '[]'::jsonb) into v_satirlar
  from (
    select yuzey, ekran,
           sum(sure_sn)::bigint as toplam_sn,
           count(distinct oturum_anahtari)::integer as oturum,
           round(sum(sure_sn)::numeric / count(distinct oturum_anahtari), 1) as ortalama_sn
    from public.kullanim_olaylari
    where baslangic >= v_baslangic and (p_yuzey is null or yuzey = p_yuzey)
    group by yuzey, ekran
    having count(distinct oturum_anahtari) >= 5
  ) s;

  select coalesce(jsonb_agg(to_jsonb(t) order by t.gun, t.yuzey), '[]'::jsonb) into v_trend
  from (
    select (baslangic at time zone 'UTC')::date as gun, yuzey,
           sum(sure_sn)::bigint as toplam_sn,
           count(distinct oturum_anahtari)::integer as oturum
    from public.kullanim_olaylari
    where baslangic >= v_baslangic and (p_yuzey is null or yuzey = p_yuzey)
    group by 1, 2
    having count(distinct oturum_anahtari) >= 5
  ) t;

  return jsonb_build_object('gun', v_gun, 'yuzey', p_yuzey, 'satirlar', v_satirlar, 'trend', v_trend);
end $$;

revoke all on function public.kullanim_raporu(integer, text) from public, anon;
grant execute on function public.kullanim_raporu(integer, text) to authenticated;

-- Temizlik (300 gün) --------------------------------------------------------------------------------
create or replace function public.kullanim_olaylari_temizle()
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare v_silinen integer;
begin
  delete from public.kullanim_olaylari where created_at < now() - interval '300 days';
  get diagnostics v_silinen = row_count;
  return v_silinen;
end $$;

revoke all on function public.kullanim_olaylari_temizle() from public, anon, authenticated;
grant execute on function public.kullanim_olaylari_temizle() to service_role;

-- pg_cron etkinse her gün 03:15 UTC; değilse yalnız fonksiyon kalır (belge: KULLANIM_SURESI_KVKK_NOTU.md).
do $$
begin
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    begin
      perform cron.unschedule('kullanim_olaylari_temizle');
    exception when others then null;
    end;
    perform cron.schedule('kullanim_olaylari_temizle', '15 3 * * *', 'select public.kullanim_olaylari_temizle()');
  else
    raise notice 'pg_cron yok: kullanim_olaylari_temizle() günlük elle/harici zamanlayıcıyla çağrılmalı';
  end if;
end $$;