-- =====================================================================
--  Pazarlama push yasal kapısı, ön izin ölçümü ve sıklık sınırı
--  Tarih : 2026-10-16
--  Ön koşul: 20260920001000 (push), 20261007000020 (kampanya_push_gonder öncesi),
--            20261036000000 (kampanya_push_gonder), 20261037000000 (kayıt push izni)
--
--  1. pazarlama_push_kapisi (tek satır) — HUKUK KAPISI
--     * Varsayılan KAPALI. Kapalıyken: kampanya push'u gönderilmez (iptal edilir),
--       kayıt formunda push kutusu görünmez.
--     * Açmak için üç şart: metin sürümü girilmiş, İYS kararı "bilinmiyor" değil
--       ve yönetici kararı kaydedilmiş. Karar hukuk görüşüne dayanır; kod kararı VERMEZ,
--       yalnızca kapıyı uygular.
--     * İYS kararı: 'gerekli_degil' ya da 'gerekli_kayit_tamam' (kayıt tamamlandığını
--       yönetici beyan eder; İYS ile otomatik doğrulama YOKTUR).
--
--  2. Ön izin ölçümü (uygulama içi "Hupo haber versin mi?")
--     * push_on_izin_gunluk : gün × sonuç toplamı. KİMLİK YOK. Yönetim ekranı buradan okur.
--     * push_on_izin_durumu : kişi başı sıklık sayacı (14 günlük sabit pencere, en fazla 2 gösterim).
--       Yalnızca frekans sınırı için tutulur. Pencere 14 günü geçince veri işlevsizdir ve
--       günlük temizlikte silinir (ölçülülük: süre sınırı = pencere süresi).
--     * Küçük hücre: admin_push_on_izin_ozeti toplam gösterim 10'un altındaysa sayıları gizler
--       (tekil kişiyi ayırt edilebilir kılacak küçük sayılara karşı).
--     * Harici analitik servisi kullanılmaz; çocuk verisi dışarı çıkmaz.
--
--  3. kampanya_push_gonder: hukuk kapısı kapalıysa kampanya "yasal_kapi_kapali" nedeniyle iptal edilir.
--     Gövde 20261036 ile aynıdır; yalnızca bu kapı eklendi.
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Hukuk kapısı
-- ---------------------------------------------------------------------
create table if not exists public.pazarlama_push_kapisi (
  id             boolean primary key default true,
  durum          text not null default 'kapali',
  metin_surumu   text,
  iys_karari     text not null default 'bilinmiyor',
  onay_notu      text,
  guncelleyen_id uuid references public.profiles (id) on delete set null,
  updated_at     timestamptz not null default now(),
  constraint pazarlama_push_kapisi_tek_satir check (id),
  constraint pazarlama_push_kapisi_durum check (durum in ('kapali', 'onaylandi')),
  constraint pazarlama_push_kapisi_iys check (iys_karari in ('bilinmiyor', 'gerekli_degil', 'gerekli_kayit_tamam')),
  constraint pazarlama_push_kapisi_onay_sarti check (
    durum = 'kapali'
    or (
      metin_surumu is not null
      and char_length(btrim(metin_surumu)) between 1 and 60
      and iys_karari <> 'bilinmiyor'
    )
  )
);

insert into public.pazarlama_push_kapisi (id) values (true) on conflict (id) do nothing;

alter table public.pazarlama_push_kapisi enable row level security;
revoke all on table public.pazarlama_push_kapisi from public, anon, authenticated;

-- Kapı açık mı? (iç kullanım: dağıtım ve kayıt formu kontrolü)
create or replace function public._pazarlama_push_acik()
returns boolean
language sql
stable
security definer
set search_path = ''
as $function$
  select exists (
    select 1 from public.pazarlama_push_kapisi k
     where k.id
       and k.durum = 'onaylandi'
       and k.metin_surumu is not null
       and k.iys_karari <> 'bilinmiyor'
  );
$function$;

revoke execute on function public._pazarlama_push_acik() from public, anon, authenticated;

-- Kayıt formu: push kutusu gösterilsin mi? Yalnızca onaylı metin sürümü için.
create or replace function public.iletisim_push_kullanilabilir(p_metin_surumu text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $function$
  select p_metin_surumu is not null
     and public._pazarlama_push_acik()
     and exists (
           select 1 from public.pazarlama_push_kapisi k
            where k.id and k.metin_surumu = p_metin_surumu
         );
$function$;

comment on function public.iletisim_push_kullanilabilir(text) is
  'Kayıt formunda push izni kutusunu göstermek için: kapı açık ve metin sürümü onaylı mı. Girişsiz çağrılabilir; yalnızca boolean döner.';

revoke execute on function public.iletisim_push_kullanilabilir(text) from public;
grant  execute on function public.iletisim_push_kullanilabilir(text) to anon, authenticated;

create or replace function public.admin_pazarlama_push_kapisi_getir()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
begin
  perform public.require_admin();
  return (
    select jsonb_build_object(
             'durum', k.durum,
             'metin_surumu', k.metin_surumu,
             'iys_karari', k.iys_karari,
             'onay_notu', k.onay_notu,
             'updated_at', k.updated_at)
      from public.pazarlama_push_kapisi k
     where k.id
  );
end;
$function$;

create or replace function public.admin_pazarlama_push_kapisi_guncelle(
  p_durum        text,
  p_metin_surumu text default null,
  p_iys_karari   text default null,
  p_onay_notu    text default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_metin text := nullif(btrim(coalesce(p_metin_surumu, '')), '');
  v_not   text := nullif(btrim(coalesce(p_onay_notu, '')), '');
begin
  perform public.require_admin();

  if p_durum is null or p_durum not in ('kapali', 'onaylandi') then
    raise exception 'Durum kapali veya onaylandi olmalı' using errcode = '22023';
  end if;
  if p_iys_karari is null or p_iys_karari not in ('bilinmiyor', 'gerekli_degil', 'gerekli_kayit_tamam') then
    raise exception 'İYS kararı geçersiz' using errcode = '22023';
  end if;
  if p_durum = 'onaylandi' then
    if v_metin is null then
      raise exception 'Onaylamak için onaylanan metin sürümü girilmeli' using errcode = '22023';
    end if;
    if p_iys_karari = 'bilinmiyor' then
      raise exception 'Onaylamak için İYS kararı verilmelidir' using errcode = '22023';
    end if;
  end if;

  update public.pazarlama_push_kapisi
     set durum = p_durum,
         metin_surumu = v_metin,
         iys_karari = p_iys_karari,
         onay_notu = v_not,
         guncelleyen_id = (select auth.uid()),
         updated_at = now()
   where id;

  perform public.log_admin_action('pazarlama_push_kapisi_guncellendi', jsonb_build_object(
    'durum', p_durum, 'metin_surumu', v_metin, 'iys_karari', p_iys_karari));

  return public.admin_pazarlama_push_kapisi_getir();
end;
$function$;

revoke execute on function public.admin_pazarlama_push_kapisi_getir()                                 from public, anon;
grant  execute on function public.admin_pazarlama_push_kapisi_getir()                                 to authenticated;
revoke execute on function public.admin_pazarlama_push_kapisi_guncelle(text, text, text, text)        from public, anon;
grant  execute on function public.admin_pazarlama_push_kapisi_guncelle(text, text, text, text)        to authenticated;

-- ---------------------------------------------------------------------
-- 2. Ön izin ölçümü ve sıklık sınırı
-- ---------------------------------------------------------------------
create table if not exists public.push_on_izin_durumu (
  user_id            uuid primary key references public.profiles (id) on delete cascade,
  pencere_baslangic  timestamptz not null,
  pencere_gosterim   integer not null default 0 check (pencere_gosterim >= 0),
  updated_at         timestamptz not null default now()
);

alter table public.push_on_izin_durumu enable row level security;
revoke all on table public.push_on_izin_durumu from public, anon, authenticated;

create table if not exists public.push_on_izin_gunluk (
  gun    date not null,
  sonuc  text not null check (sonuc in ('gosterildi', 'evet', 'ertele', 'sistem_verildi', 'sistem_reddedildi')),
  adet   integer not null default 0 check (adet >= 0),
  primary key (gun, sonuc)
);

alter table public.push_on_izin_gunluk enable row level security;
revoke all on table public.push_on_izin_gunluk from public, anon, authenticated;

-- Gösterim izni + sayım. true: ön izin gösterilebilir (ve gösterim sayılır).
-- Sınır: 14 günlük sabit pencerede en fazla 2 gösterim. Çocuk hesabında velinin onayı yoksa false.
create or replace function public.push_on_izin_baslat()
returns boolean
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_uid uuid := (select auth.uid());
  d     public.push_on_izin_durumu%rowtype;
  v_bugun date := (now() at time zone 'Europe/Istanbul')::date;
begin
  if v_uid is null then
    raise exception 'Oturum gerekli' using errcode = '42501';
  end if;
  if not public.push_consent_ok(v_uid) then
    return false;
  end if;

  insert into public.push_on_izin_durumu (user_id, pencere_baslangic, pencere_gosterim)
  values (v_uid, now(), 0)
  on conflict (user_id) do nothing;

  select * into d from public.push_on_izin_durumu where user_id = v_uid for update;

  if d.pencere_baslangic < now() - interval '14 days' then
    update public.push_on_izin_durumu
       set pencere_baslangic = now(), pencere_gosterim = 0, updated_at = now()
     where user_id = v_uid;
    d.pencere_gosterim := 0;
  end if;

  if d.pencere_gosterim >= 2 then
    return false;
  end if;

  update public.push_on_izin_durumu
     set pencere_gosterim = pencere_gosterim + 1, updated_at = now()
   where user_id = v_uid;

  insert into public.push_on_izin_gunluk (gun, sonuc, adet) values (v_bugun, 'gosterildi', 1)
  on conflict (gun, sonuc) do update set adet = public.push_on_izin_gunluk.adet + 1;

  return true;
end;
$function$;

-- Sonuç bildirimi: evet | ertele (kullanıcı) ve sistem_verildi | sistem_reddedildi (işletim sistemi).
-- Yalnızca toplam sayılır; kişi kimliği yazılmaz.
create or replace function public.push_on_izin_bildir(p_sonuc text)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_bugun date := (now() at time zone 'Europe/Istanbul')::date;
begin
  if (select auth.uid()) is null then
    raise exception 'Oturum gerekli' using errcode = '42501';
  end if;
  if p_sonuc is null or p_sonuc not in ('evet', 'ertele', 'sistem_verildi', 'sistem_reddedildi') then
    raise exception 'Geçersiz ön izin sonucu' using errcode = '22023';
  end if;

  insert into public.push_on_izin_gunluk (gun, sonuc, adet) values (v_bugun, p_sonuc, 1)
  on conflict (gun, sonuc) do update set adet = public.push_on_izin_gunluk.adet + 1;
end;
$function$;

create or replace function public.admin_push_on_izin_ozeti(p_gun integer default 30)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_gun  integer := least(greatest(coalesce(p_gun, 30), 1), 365);
  v_bas  date := (now() at time zone 'Europe/Istanbul')::date - (least(greatest(coalesce(p_gun, 30), 1), 365) - 1);
  g      integer;
  e      integer;
  er     integer;
  sv     integer;
  sr     integer;
begin
  perform public.require_admin();

  select
    coalesce(sum(adet) filter (where sonuc = 'gosterildi'), 0)::integer,
    coalesce(sum(adet) filter (where sonuc = 'evet'), 0)::integer,
    coalesce(sum(adet) filter (where sonuc = 'ertele'), 0)::integer,
    coalesce(sum(adet) filter (where sonuc = 'sistem_verildi'), 0)::integer,
    coalesce(sum(adet) filter (where sonuc = 'sistem_reddedildi'), 0)::integer
    into g, e, er, sv, sr
    from public.push_on_izin_gunluk
   where gun >= v_bas;

  -- Küçük hücre kuralı: 10'dan az gösterimde hiçbir sayı ya da oran dönmez.
  if g < 10 then
    return jsonb_build_object(
      'gun', v_gun,
      'yetersiz_veri', true,
      'gosterildi', null,
      'evet', null,
      'ertele', null,
      'sistem_verildi', null,
      'sistem_reddedildi', null,
      'evet_orani', null,
      'sistem_verildi_orani', null
    );
  end if;

  return jsonb_build_object(
    'gun', v_gun,
    'yetersiz_veri', false,
    'gosterildi', g,
    'evet', e,
    'ertele', er,
    'sistem_verildi', sv,
    'sistem_reddedildi', sr,
    'evet_orani', round(100.0 * e / g, 1),
    'sistem_verildi_orani', round(100.0 * sv / g, 1)
  );
end;
$function$;

revoke execute on function public.push_on_izin_baslat()                 from public, anon;
grant  execute on function public.push_on_izin_baslat()                 to authenticated;
revoke execute on function public.push_on_izin_bildir(text)             from public, anon;
grant  execute on function public.push_on_izin_bildir(text)             to authenticated;
revoke execute on function public.admin_push_on_izin_ozeti(integer)     from public, anon;
grant  execute on function public.admin_push_on_izin_ozeti(integer)     to authenticated;

-- Sayaç temizliği: pencere süresini (14 gün) geçen kişi-bazlı kayıtlar silinir.
-- Silinen kayıt, bir sonraki gösterimde yeni pencere açılmasıyla aynı davranışı verir.
-- Günlük toplamlar kimliksizdir; saklama süresi hukuk görüşüyle ayrıca kararlaştırılır (TASKS §25).
do $$
begin
  if not exists (select 1 from cron.job where jobname = 'push-on-izin-durumu-temizle') then
    perform cron.schedule(
      'push-on-izin-durumu-temizle',
      '17 3 * * *',
      $cmd$delete from public.push_on_izin_durumu where pencere_baslangic < now() - interval '14 days'$cmd$
    );
  end if;
end
$$;

-- ---------------------------------------------------------------------
-- 3. kampanya_push_gonder: hukuk kapısı (gövde 20261036 + kapı kontrolü)
-- ---------------------------------------------------------------------
create or replace function public.kampanya_push_gonder()
returns integer
language plpgsql
security definer
set search_path = ''
as $function$
declare
  c         public.iletisim_kampanyalari%rowtype;
  s         public.segmentler%rowtype;
  a         public.iletisim_ayarlari%rowtype;
  v_kapi    boolean := public._pazarlama_push_acik();
  v_adet    integer := 0;
  v_satir   integer;
begin
  select * into a from public.iletisim_ayarlari where id;

  for c in
    select *
      from public.iletisim_kampanyalari
     where durum = 'planlandi'
       and kanal = 'push'
       and planlanan_at <= now()
     order by planlanan_at, id
       for update skip locked
  loop
    begin
    -- Hukuk kapısı kapalıysa pazarlama push'u gönderilmez; kampanya iptal edilir.
    if not v_kapi then
      update public.iletisim_kampanyalari
         set durum = 'iptal',
             onkontrol = coalesce(onkontrol, '{}'::jsonb)
                         || jsonb_build_object('iptal_nedeni', 'yasal_kapi_kapali'),
             updated_at = now()
       where id = c.id;
      continue;
    end if;

    select * into s from public.segmentler where id = c.segment_id and not arsiv;

    -- Boş kriter "herkes" demektir; pazarlama push'unda bu kabul edilmez.
    if not found or s.kriterler = '{}'::jsonb then
      update public.iletisim_kampanyalari
         set durum = 'iptal',
             onkontrol = coalesce(onkontrol, '{}'::jsonb)
                         || jsonb_build_object('iptal_nedeni', 'segment_bos_veya_yok'),
             updated_at = now()
       where id = c.id;
      continue;
    end if;

    -- Sessiz saatte dağıtım yapılmaz; push kuralıyla aynı: ertelenmez, kampanya iptal edilir.
    if public._sessiz_saat_mi(now()) then
      update public.iletisim_kampanyalari
         set durum = 'iptal',
             onkontrol = coalesce(onkontrol, '{}'::jsonb)
                         || jsonb_build_object('iptal_nedeni', 'sessiz_saat'),
             updated_at = now()
       where id = c.id;
      continue;
    end if;

    insert into public.notifications (alici_id, tur, baslik, mesaj, ikon, kategori, pazarlama, kaynak_kampanya_id)
    select r.r_veli_id, 'bilgi', c.baslik, c.mesaj, 'bell', 'kampanya', true, c.id
      from public._segment_veliler(s.kriterler, 'push') r
     where r.r_izinli
       and (
         select count(*) from public.notifications x
          where x.alici_id = r.r_veli_id
            and x.pazarlama
            and x.created_at > now() - interval '7 days'
       ) < a.haftalik_limit
    on conflict (kaynak_kampanya_id, alici_id) where kaynak_kampanya_id is not null do nothing;

    get diagnostics v_satir = row_count;
    v_adet := v_adet + v_satir;

    update public.iletisim_kampanyalari
       set durum = 'gonderildi',
           onkontrol = coalesce(onkontrol, '{}'::jsonb)
                       || jsonb_build_object('alici_sayisi', v_satir, 'gonderim_zamani', now()),
           updated_at = now()
     where id = c.id;
    exception when others then
      update public.iletisim_kampanyalari
         set durum = 'iptal',
             onkontrol = coalesce(onkontrol, '{}'::jsonb)
                         || jsonb_build_object('iptal_nedeni', 'dagitim_hatasi', 'hata', left(sqlerrm, 200)),
             updated_at = now()
       where id = c.id;
    end;
  end loop;

  return v_adet;
end;
$function$;

revoke execute on function public.kampanya_push_gonder() from public, anon, authenticated;
