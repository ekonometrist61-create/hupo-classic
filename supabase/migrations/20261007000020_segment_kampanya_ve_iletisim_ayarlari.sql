-- =====================================================================
--  Segmentler, iletişim kampanyaları (taslak → ön kontrol → planlama) ve
--  iletişim politikası ayarları
--  Proje : Hupo / Yönetim Merkezi  (Aşama D)
--  Tarih : 2026-10-07
--  Ön koşul: 20261007000010_crm_profil_tercihler_ve_denetim.sql
--
--  NE EKLİYOR?
--    tablolar : public.iletisim_ayarlari (tek satır), public.segmentler,
--               public.iletisim_kampanyalari
--    iç       : _segment_veliler, _sessiz_saat_mi        (istemciye KAPALI)
--    admin RPC: admin_iletisim_ayarlari_getir/kaydet,
--               admin_segment_onizle/kaydet/listele/arsivle,
--               admin_kampanya_listele/kaydet/on_kontrol/planla/iptal
--
--  KURALLAR
--    * Hedef kişi her zaman VELİDİR; birden çok çocuğu olan aile tek alıcıdır
--      (segment profiles.role='veli' üzerinden kurulur → doğal tekilleştirme).
--      Çocuk hesaplarına ticari mesaj segmentlenemez.
--    * Alıcı izni (iletisim_tercihleri) ön kontrolde ve gönderim anında yeniden
--      değerlendirilir. İzin yoksa alıcı hariç tutulur.
--    * Sessiz saat ve haftalık toplam sıklık sınırı (kanallar birlikte) ön kontrolde
--      uygulanır.
--    * GÖNDERİCİ WORKER YOKTUR. 'planlandi' durumu bir niyet kaydıdır: mesaj
--      gönderilmez; olay_kutusu'na PII'sız olay yazılır. Worker (lease, idempotency,
--      retry, gönderim anında izin/sıklık yeniden kontrolü) ayrı sprinttedir.
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. İletişim politikası (tek satır)
-- ---------------------------------------------------------------------
create table if not exists public.iletisim_ayarlari (
  id              boolean primary key default true,
  haftalik_limit  integer not null default 3,
  sessiz_baslangic time not null default '20:00',
  sessiz_bitis    time not null default '09:00',
  zaman_dilimi    text not null default 'Europe/Istanbul',
  updated_by      uuid references public.profiles (id) on delete set null,
  updated_at      timestamptz not null default now(),
  constraint iletisim_ayarlari_tek_satir check (id),
  constraint iletisim_ayarlari_limit check (haftalik_limit between 0 and 20)
);
insert into public.iletisim_ayarlari (id) values (true) on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- 2. Segmentler
-- ---------------------------------------------------------------------
create table if not exists public.segmentler (
  id          uuid primary key default gen_random_uuid(),
  ad          text not null,
  aciklama    text,
  kriterler   jsonb not null default '{}'::jsonb,
  arsiv       boolean not null default false,
  created_by  uuid references public.profiles (id) on delete set null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  constraint segmentler_ad_uzunluk check (char_length(btrim(ad)) between 2 and 80),
  constraint segmentler_kriter_nesne check (jsonb_typeof(kriterler) = 'object')
);

-- ---------------------------------------------------------------------
-- 3. İletişim kampanyaları (mevcut `kampanyalar` kupon kampanyasıdır; ad çakışmasın)
-- ---------------------------------------------------------------------
create table if not exists public.iletisim_kampanyalari (
  id            uuid primary key default gen_random_uuid(),
  ad            text not null,
  kanal         text not null,
  segment_id    uuid not null references public.segmentler (id) on delete restrict,
  baslik        text not null,
  mesaj         text not null,
  durum         text not null default 'taslak',
  planlanan_at  timestamptz,
  onkontrol     jsonb,
  created_by    uuid references public.profiles (id) on delete set null,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  constraint iletisim_kampanyalari_ad check (char_length(btrim(ad)) between 2 and 80),
  constraint iletisim_kampanyalari_kanal check (kanal in ('eposta', 'push', 'sms', 'uygulama_ici')),
  constraint iletisim_kampanyalari_baslik check (char_length(btrim(baslik)) between 1 and 100),
  constraint iletisim_kampanyalari_mesaj check (char_length(btrim(mesaj)) between 1 and 1000),
  constraint iletisim_kampanyalari_durum
    check (durum in ('taslak', 'kontrol_edildi', 'planlandi', 'iptal'))
);
create index if not exists iletisim_kampanyalari_durum_idx
  on public.iletisim_kampanyalari (durum, planlanan_at);

alter table public.iletisim_ayarlari      enable row level security;
alter table public.segmentler             enable row level security;
alter table public.iletisim_kampanyalari  enable row level security;

revoke all on table public.iletisim_ayarlari     from public, anon, authenticated;
revoke all on table public.segmentler            from public, anon, authenticated;
revoke all on table public.iletisim_kampanyalari from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 4. İç yardımcılar (istemciye KAPALI)
-- ---------------------------------------------------------------------

-- Kriterlere uyan veliler (tekil) + seçilen kanal için izinli mi?
-- kriterler: { plan:[kod|'free'], sinif:[n], aktiflik:'aktif_7'|'pasif_7'|'pasif_30',
--              ilk_gorev_bekleyen:bool, yenileme_yaklasan:bool }
create or replace function public._segment_veliler(p_kriterler jsonb, p_kanal text default 'eposta')
returns table (r_veli_id uuid, r_ad text, r_izinli boolean)
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  k          jsonb := coalesce(p_kriterler, '{}'::jsonb);
  v_plan     text[];
  v_sinif    smallint[];
  v_aktiflik text := nullif(k ->> 'aktiflik', '');
  v_ilk      boolean := coalesce((k ->> 'ilk_gorev_bekleyen')::boolean, false);
  v_yen      boolean := coalesce((k ->> 'yenileme_yaklasan')::boolean, false);
begin
  if p_kanal not in ('eposta', 'push', 'sms', 'uygulama_ici') then
    raise exception 'Geçersiz kanal.' using errcode = '22023';
  end if;
  if jsonb_typeof(k) is distinct from 'object' then
    raise exception 'Kriterler nesne olmalı.' using errcode = '22023';
  end if;
  -- Bilinmeyen/yanlış tipli kriter SESSİZCE yok sayılmaz: kitle istemeden genişlemesin.
  if exists (select 1 from jsonb_object_keys(k) kk
              where kk not in ('plan', 'sinif', 'aktiflik', 'ilk_gorev_bekleyen', 'yenileme_yaklasan')) then
    raise exception 'Bilinmeyen segment kriteri.' using errcode = '22023';
  end if;
  if v_aktiflik is not null and v_aktiflik not in ('aktif_7', 'pasif_7', 'pasif_30') then
    raise exception 'Geçersiz aktiflik kriteri.' using errcode = '22023';
  end if;
  if (k ? 'plan' and jsonb_typeof(k -> 'plan') is distinct from 'array')
     or (k ? 'sinif' and jsonb_typeof(k -> 'sinif') is distinct from 'array')
     or (k ? 'ilk_gorev_bekleyen' and jsonb_typeof(k -> 'ilk_gorev_bekleyen') is distinct from 'boolean')
     or (k ? 'yenileme_yaklasan' and jsonb_typeof(k -> 'yenileme_yaklasan') is distinct from 'boolean') then
    raise exception 'Segment kriteri tipleri geçersiz.' using errcode = '22023';
  end if;
  if jsonb_typeof(k -> 'plan') = 'array' then
    v_plan := array(select jsonb_array_elements_text(k -> 'plan'));
    if cardinality(v_plan) = 0 then v_plan := null; end if;
  end if;
  if jsonb_typeof(k -> 'sinif') = 'array' then
    if exists (select 1 from jsonb_array_elements_text(k -> 'sinif') e where e !~ '^(1[0-2]|[1-9])$') then
      raise exception 'Sınıf 1-12 arasında olmalı.' using errcode = '22023';
    end if;
    v_sinif := array(select (jsonb_array_elements_text(k -> 'sinif'))::smallint);
    if cardinality(v_sinif) = 0 then v_sinif := null; end if;
  end if;

  return query
  select p.id, p.full_name,
         exists (select 1 from public.iletisim_tercihleri t
                  where t.veli_id = p.id and t.kanal = p_kanal and t.izin)
    from public.profiles p
   where p.role = 'veli'
     and (v_plan is null
          or coalesce((select sb.plan_kod from public.subscriptions sb
                        where sb.veli_id = p.id and sb.durum = 'aktif' and sb.bitis > now()
                        order by sb.bitis desc limit 1), 'free') = any (v_plan))
     and (v_sinif is null
          or exists (select 1 from public.profiles c
                      where c.parent_id = p.id and c.sinif = any (v_sinif)))
     and (v_aktiflik is null
          or case v_aktiflik
               when 'aktif_7' then exists (
                 select 1 from public.profiles c join public.student_stats s on s.student_id = c.id
                  where c.parent_id = p.id and s.last_active_date >= current_date - 7)
               when 'pasif_7' then
                 exists (select 1 from public.profiles c where c.parent_id = p.id)
                 and not exists (
                   select 1 from public.profiles c join public.student_stats s on s.student_id = c.id
                    where c.parent_id = p.id and s.last_active_date >= current_date - 7)
               else
                 exists (select 1 from public.profiles c where c.parent_id = p.id)
                 and not exists (
                   select 1 from public.profiles c join public.student_stats s on s.student_id = c.id
                    where c.parent_id = p.id and s.last_active_date >= current_date - 30)
             end)
     and (not v_ilk
          or exists (select 1 from public.profiles c
                      where c.parent_id = p.id
                        and not exists (select 1 from public.user_answers ua where ua.student_id = c.id)))
     and (not v_yen
          or exists (select 1 from public.subscriptions sb
                      where sb.veli_id = p.id and sb.durum = 'aktif'
                        and sb.bitis between now() and now() + interval '7 days'));
end;
$function$;

create or replace function public._sessiz_saat_mi(p_zaman timestamptz)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  a public.iletisim_ayarlari%rowtype;
  v_yerel time;
begin
  select * into a from public.iletisim_ayarlari where id;
  v_yerel := (p_zaman at time zone a.zaman_dilimi)::time;
  if a.sessiz_baslangic > a.sessiz_bitis then
    return v_yerel >= a.sessiz_baslangic or v_yerel < a.sessiz_bitis;   -- gece yarısını aşan aralık
  end if;
  return v_yerel >= a.sessiz_baslangic and v_yerel < a.sessiz_bitis;
end;
$function$;

revoke execute on function public._segment_veliler(jsonb, text) from public, anon, authenticated;
revoke execute on function public._sessiz_saat_mi(timestamptz)  from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 5. İletişim ayarları RPC
-- ---------------------------------------------------------------------
create or replace function public.admin_iletisim_ayarlari_getir()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v jsonb;
begin
  perform public.require_admin();
  select jsonb_build_object(
           'haftalik_limit', a.haftalik_limit,
           'sessiz_baslangic', to_char(a.sessiz_baslangic, 'HH24:MI'),
           'sessiz_bitis', to_char(a.sessiz_bitis, 'HH24:MI'),
           'zaman_dilimi', a.zaman_dilimi,
           'updated_at', a.updated_at)
    into v from public.iletisim_ayarlari a where a.id;
  return v;
end;
$function$;

create or replace function public.admin_iletisim_ayarlari_kaydet(
  p_haftalik_limit   integer,
  p_sessiz_baslangic time,
  p_sessiz_bitis     time
)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
begin
  perform public.require_admin();
  if p_haftalik_limit is null or p_haftalik_limit not between 0 and 20 then
    raise exception 'Haftalık sınır 0-20 arasında olmalı.' using errcode = '22023';
  end if;
  if p_sessiz_baslangic is null or p_sessiz_bitis is null or p_sessiz_baslangic = p_sessiz_bitis then
    raise exception 'Sessiz saat başlangıcı ve bitişi farklı olmalı.' using errcode = '22023';
  end if;

  update public.iletisim_ayarlari
     set haftalik_limit = p_haftalik_limit, sessiz_baslangic = p_sessiz_baslangic,
         sessiz_bitis = p_sessiz_bitis, updated_by = (select auth.uid()), updated_at = now()
   where id;

  perform public.log_admin_action('iletisim_ayarlari_guncellendi',
    jsonb_build_object('haftalik_limit', p_haftalik_limit,
                       'sessiz_baslangic', p_sessiz_baslangic, 'sessiz_bitis', p_sessiz_bitis));
end;
$function$;

-- ---------------------------------------------------------------------
-- 6. Segment RPC
-- ---------------------------------------------------------------------
create or replace function public.admin_segment_onizle(p_kriterler jsonb, p_kanal text default 'eposta')
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_toplam integer;
  v_izinli integer;
  v_ornek  jsonb;
begin
  perform public.require_admin();

  select count(*)::integer, (count(*) filter (where r_izinli))::integer
    into v_toplam, v_izinli
    from public._segment_veliler(p_kriterler, p_kanal);

  select coalesce(jsonb_agg(jsonb_build_object('veli_id', s.r_veli_id, 'ad', s.r_ad, 'izinli', s.r_izinli)), '[]'::jsonb)
    into v_ornek
    from (select * from public._segment_veliler(p_kriterler, p_kanal) order by r_ad nulls last limit 10) s;

  return jsonb_build_object('toplam', v_toplam, 'izinli', v_izinli,
                            'haric', v_toplam - v_izinli, 'ornek', v_ornek);
end;
$function$;

create or replace function public.admin_segment_kaydet(
  p_id         uuid,
  p_ad         text,
  p_aciklama   text,
  p_kriterler  jsonb
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_id uuid := p_id;
  v_ad text := btrim(coalesce(p_ad, ''));
begin
  perform public.require_admin();
  if char_length(v_ad) < 2 or char_length(v_ad) > 80 then
    raise exception 'Segment adı 2-80 karakter olmalı.' using errcode = '22023';
  end if;
  if p_kriterler is null or jsonb_typeof(p_kriterler) <> 'object' then
    raise exception 'Kriterler nesne olmalı.' using errcode = '22023';
  end if;
  -- Kriterleri kaydetmeden doğrula (geçersizse _segment_veliler hata verir).
  perform 1 from public._segment_veliler(p_kriterler, 'eposta') limit 1;

  if v_id is null then
    insert into public.segmentler (ad, aciklama, kriterler, created_by)
    values (v_ad, nullif(btrim(coalesce(p_aciklama, '')), ''), p_kriterler, (select auth.uid()))
    returning id into v_id;
  else
    -- Ön kontrol/planlama yapılmış kampanyanın kitlesi sonradan değişmesin.
    if exists (select 1 from public.iletisim_kampanyalari
                where segment_id = v_id and durum in ('kontrol_edildi', 'planlandi')) then
      raise exception 'Bu segment kontrol edilmiş veya planlanmış bir kampanyada kullanılıyor.'
        using errcode = '23503';
    end if;
    update public.segmentler
       set ad = v_ad, aciklama = nullif(btrim(coalesce(p_aciklama, '')), ''),
           kriterler = p_kriterler, updated_at = now()
     where id = v_id and not arsiv;
    if not found then
      raise exception 'Segment bulunamadı' using errcode = 'P0002';
    end if;
  end if;

  perform public.log_admin_action('segment_kaydedildi', jsonb_build_object('segment_id', v_id));
  return v_id;
end;
$function$;

create or replace function public.admin_segment_listele()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_res jsonb;
begin
  perform public.require_admin();

  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc), '[]'::jsonb) into v_res
    from (
      select s.id, s.ad, s.aciklama, s.kriterler, s.created_at, l.veli_sayisi, l.izinli_eposta
        from public.segmentler s
        cross join lateral (
          select count(*)::integer as veli_sayisi,
                 (count(*) filter (where v.r_izinli))::integer as izinli_eposta
            from public._segment_veliler(s.kriterler, 'eposta') v
        ) l
       where not s.arsiv
    ) x;

  return v_res;
end;
$function$;

create or replace function public.admin_segment_arsivle(p_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
begin
  perform public.require_admin();
  if exists (select 1 from public.iletisim_kampanyalari
              where segment_id = p_id and durum in ('taslak', 'kontrol_edildi', 'planlandi')) then
    raise exception 'Bu segment açık bir kampanyada kullanılıyor.' using errcode = '23503';
  end if;
  update public.segmentler set arsiv = true, updated_at = now() where id = p_id and not arsiv;
  if not found then
    raise exception 'Segment bulunamadı' using errcode = 'P0002';
  end if;
  perform public.log_admin_action('segment_arsivlendi', jsonb_build_object('segment_id', p_id));
end;
$function$;

-- ---------------------------------------------------------------------
-- 7. Kampanya RPC
-- ---------------------------------------------------------------------
create or replace function public.admin_kampanya_listele()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_res jsonb;
begin
  perform public.require_admin();

  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc), '[]'::jsonb) into v_res
    from (
      select c.id, c.ad, c.kanal, c.segment_id, s.ad as segment_ad, c.baslik, c.mesaj,
             c.durum, c.planlanan_at, c.onkontrol, c.created_at
        from public.iletisim_kampanyalari c
        join public.segmentler s on s.id = c.segment_id
    ) x;

  return v_res;
end;
$function$;

create or replace function public.admin_kampanya_kaydet(
  p_id          uuid,
  p_ad          text,
  p_kanal       text,
  p_segment_id  uuid,
  p_baslik      text,
  p_mesaj       text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_id    uuid := p_id;
  v_durum text;
begin
  perform public.require_admin();
  if not exists (select 1 from public.segmentler where id = p_segment_id and not arsiv) then
    raise exception 'Segment bulunamadı.' using errcode = 'P0002';
  end if;

  if v_id is null then
    insert into public.iletisim_kampanyalari (ad, kanal, segment_id, baslik, mesaj, created_by)
    values (btrim(coalesce(p_ad, '')), p_kanal, p_segment_id,
            btrim(coalesce(p_baslik, '')), btrim(coalesce(p_mesaj, '')), (select auth.uid()))
    returning id into v_id;
  else
    select durum into v_durum from public.iletisim_kampanyalari where id = v_id;
    if not found then
      raise exception 'Kampanya bulunamadı' using errcode = 'P0002';
    end if;
    if v_durum not in ('taslak', 'kontrol_edildi') then
      raise exception 'Planlanmış veya iptal edilmiş kampanya düzenlenemez.' using errcode = '23514';
    end if;
    -- İçerik/kitle değişince önceki ön kontrol geçersizdir.
    update public.iletisim_kampanyalari
       set ad = btrim(coalesce(p_ad, '')), kanal = p_kanal, segment_id = p_segment_id,
           baslik = btrim(coalesce(p_baslik, '')), mesaj = btrim(coalesce(p_mesaj, '')),
           durum = 'taslak', onkontrol = null, planlanan_at = null, updated_at = now()
     where id = v_id;
  end if;

  perform public.log_admin_action('iletisim_kampanyasi_kaydedildi', jsonb_build_object('kampanya_id', v_id));
  return v_id;
end;
$function$;

-- Ön kontrol: kitle, izin, sıklık sınırı, sessiz saat. Gönderim YAPMAZ.
create or replace function public.admin_kampanya_on_kontrol(p_id uuid, p_planlanan_at timestamptz)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  c          public.iletisim_kampanyalari%rowtype;
  s          public.segmentler%rowtype;
  a          public.iletisim_ayarlari%rowtype;
  v_toplam   integer;
  v_izinli   integer;
  v_diger    uuid[] := '{}';
  v_sinir    integer;
  v_sessiz   boolean;
  v_sonuc    jsonb;
  r          record;
begin
  perform public.require_admin();

  select * into c from public.iletisim_kampanyalari where id = p_id;
  if not found then
    raise exception 'Kampanya bulunamadı' using errcode = 'P0002';
  end if;
  if c.durum not in ('taslak', 'kontrol_edildi') then
    raise exception 'Bu kampanya için ön kontrol yapılamaz.' using errcode = '23514';
  end if;
  if p_planlanan_at is null or p_planlanan_at <= now() then
    raise exception 'Planlanan zaman gelecekte olmalı.' using errcode = '22023';
  end if;

  select * into s from public.segmentler where id = c.segment_id and not arsiv;
  if not found then
    raise exception 'Segment bulunamadı veya arşivlenmiş.' using errcode = 'P0002';
  end if;
  select * into a from public.iletisim_ayarlari where id;

  select count(*)::integer, (count(*) filter (where r_izinli))::integer
    into v_toplam, v_izinli
    from public._segment_veliler(s.kriterler, c.kanal);

  -- Planlanan zamanın ±6 günündeki (7 günlük pencereye sığan) planlı diğer kampanyaların
  -- GERÇEK alıcıları (yalnızca o kanalda izinliler), kanallar birlikte sayılır.
  -- Not: bu, "her olası 7 günlük pencere" için tam hesap değil, muhafazakâr bir yaklaşımdır.
  for r in
    select c2.kanal as kanal2, s2.kriterler as kriter2
      from public.iletisim_kampanyalari c2
      join public.segmentler s2 on s2.id = c2.segment_id
     where c2.durum = 'planlandi' and c2.id <> p_id
       and c2.planlanan_at between p_planlanan_at - interval '6 days' and p_planlanan_at + interval '6 days'
  loop
    v_diger := v_diger || array(select r_veli_id from public._segment_veliler(r.kriter2, r.kanal2) where r_izinli);
  end loop;

  with sayac as (
    select x as veli, count(*) as n from unnest(v_diger) x group by x
  )
  select count(*)::integer into v_sinir
    from public._segment_veliler(s.kriterler, c.kanal) h
    join sayac y on y.veli = h.r_veli_id
   where h.r_izinli and y.n >= a.haftalik_limit;

  v_sessiz := public._sessiz_saat_mi(p_planlanan_at);

  v_sonuc := jsonb_build_object(
    'hedef', v_toplam,
    'izinli', v_izinli,
    'izin_haric', v_toplam - v_izinli,
    'sinir_haric', v_sinir,
    'gonderilecek', greatest(v_izinli - v_sinir, 0),
    'sessiz_saat', v_sessiz,
    'haftalik_limit', a.haftalik_limit,
    'planlanan_at', p_planlanan_at,
    'kontrol_zamani', now()
  );

  update public.iletisim_kampanyalari
     set durum = 'kontrol_edildi', planlanan_at = p_planlanan_at, onkontrol = v_sonuc, updated_at = now()
   where id = p_id;

  perform public.log_admin_action('iletisim_kampanyasi_on_kontrol', jsonb_build_object('kampanya_id', p_id));
  return v_sonuc;
end;
$function$;

-- Planlama: yalnızca taze ve temiz bir ön kontrolden sonra. Mesaj GÖNDERİLMEZ (worker yok).
create or replace function public.admin_kampanya_planla(p_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  c public.iletisim_kampanyalari%rowtype;
begin
  perform public.require_admin();

  select * into c from public.iletisim_kampanyalari where id = p_id for update;
  if not found then
    raise exception 'Kampanya bulunamadı' using errcode = 'P0002';
  end if;
  if c.durum <> 'kontrol_edildi' or c.onkontrol is null then
    raise exception 'Önce ön kontrol yapılmalı.' using errcode = '23514';
  end if;
  if c.planlanan_at is null or c.planlanan_at <= now() + interval '5 minutes' then
    raise exception 'Planlanan zaman en az 5 dakika sonrası olmalı; ön kontrolü yenileyin.' using errcode = '23514';
  end if;
  if (c.onkontrol ->> 'kontrol_zamani')::timestamptz < now() - interval '1 hour' then
    raise exception 'Ön kontrol 1 saatten eski; yenileyin.' using errcode = '23514';
  end if;
  if coalesce((c.onkontrol ->> 'sessiz_saat')::boolean, true) then
    raise exception 'Planlanan zaman sessiz saat aralığında.' using errcode = '23514';
  end if;
  if coalesce((c.onkontrol ->> 'gonderilecek')::integer, 0) < 1 then
    raise exception 'Gönderilecek izinli alıcı yok.' using errcode = '23514';
  end if;

  update public.iletisim_kampanyalari set durum = 'planlandi', updated_at = now() where id = p_id;

  insert into public.olay_kutusu (tur, payload)
  values ('iletisim_kampanyasi_planlandi',
          jsonb_build_object('kampanya_id', p_id, 'kanal', c.kanal, 'planlanan_at', c.planlanan_at));

  perform public.log_admin_action('iletisim_kampanyasi_planlandi', jsonb_build_object('kampanya_id', p_id));
end;
$function$;

create or replace function public.admin_kampanya_iptal(p_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_eski text;
begin
  perform public.require_admin();

  select durum into v_eski from public.iletisim_kampanyalari where id = p_id for update;
  if not found or v_eski = 'iptal' then
    raise exception 'Kampanya bulunamadı veya zaten iptal.' using errcode = 'P0002';
  end if;

  update public.iletisim_kampanyalari set durum = 'iptal', updated_at = now() where id = p_id;

  -- Yalnızca daha önce planlanmış (outbox'a olay yazılmış) kampanyanın iptali olay üretir.
  if v_eski = 'planlandi' then
    insert into public.olay_kutusu (tur, payload)
    values ('iletisim_kampanyasi_iptal_edildi', jsonb_build_object('kampanya_id', p_id));
  end if;

  perform public.log_admin_action('iletisim_kampanyasi_iptal_edildi', jsonb_build_object('kampanya_id', p_id));
end;
$function$;

-- ---------------------------------------------------------------------
-- 8. REVOKE / GRANT (hepsi yalnızca authenticated; içeride require_admin)
-- ---------------------------------------------------------------------
revoke execute on function public.admin_iletisim_ayarlari_getir()                            from public, anon;
revoke execute on function public.admin_iletisim_ayarlari_kaydet(integer, time, time)        from public, anon;
revoke execute on function public.admin_segment_onizle(jsonb, text)                          from public, anon;
revoke execute on function public.admin_segment_kaydet(uuid, text, text, jsonb)              from public, anon;
revoke execute on function public.admin_segment_listele()                                    from public, anon;
revoke execute on function public.admin_segment_arsivle(uuid)                                from public, anon;
revoke execute on function public.admin_kampanya_listele()                                   from public, anon;
revoke execute on function public.admin_kampanya_kaydet(uuid, text, text, uuid, text, text)  from public, anon;
revoke execute on function public.admin_kampanya_on_kontrol(uuid, timestamptz)               from public, anon;
revoke execute on function public.admin_kampanya_planla(uuid)                                from public, anon;
revoke execute on function public.admin_kampanya_iptal(uuid)                                 from public, anon;

grant execute on function public.admin_iletisim_ayarlari_getir()                            to authenticated;
grant execute on function public.admin_iletisim_ayarlari_kaydet(integer, time, time)        to authenticated;
grant execute on function public.admin_segment_onizle(jsonb, text)                          to authenticated;
grant execute on function public.admin_segment_kaydet(uuid, text, text, jsonb)              to authenticated;
grant execute on function public.admin_segment_listele()                                    to authenticated;
grant execute on function public.admin_segment_arsivle(uuid)                                to authenticated;
grant execute on function public.admin_kampanya_listele()                                   to authenticated;
grant execute on function public.admin_kampanya_kaydet(uuid, text, text, uuid, text, text)  to authenticated;
grant execute on function public.admin_kampanya_on_kontrol(uuid, timestamptz)               to authenticated;
grant execute on function public.admin_kampanya_planla(uuid)                                to authenticated;
grant execute on function public.admin_kampanya_iptal(uuid)                                 to authenticated;
