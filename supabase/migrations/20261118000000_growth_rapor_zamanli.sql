set client_encoding = 'UTF8';

-- =====================================================================
--  Haftalık rapor taslağı: zamanlı üretim (H-GIE Faz 2, gölge modu)
--  Ön koşul: 20261114 (kohort, cac), 20261115 (veri kalitesi), 20261116 (rapor taslağı)
--
--  DEĞİŞİKLİK: kohort, CAC ve veri kalitesi fonksiyonlarının veri mantığı _..._veri
--  çekirdek fonksiyonlarına taşındı. admin_* fonksiyonları aynı imzayla kalır: önce
--  require_admin() çağırıp çekirdeği döndürürler. Davranış değişmedi.
--
--  ZAMANLI ÜRETİM: growth_rapor_zamanli_uret() pazartesi 08:30 İstanbul (05:30 UTC)
--  pg_cron ile çalışır. Yalnız taslak yazar. GÖNDERİM YOKTUR; taslak yönetici
--  onayını bekler. Dönem anahtarı admin üretimiyle aynıdır: aynı hafta tek kayıt.
--
--  GÜVENLİK
--    * Çekirdek fonksiyonlar anon ve authenticated tarafından çağrılamaz.
--    * Zamanlı fonksiyon yalnız veritabanı sahibi / cron tarafından çağrılır.
--    * icerik.kaynak = 'zamanli' ile el ile üretimden ayırt edilir.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. KOHORT çekirdeği (yetki kontrolü yok)
-- ---------------------------------------------------------------------
create or replace function public._growth_kohort_veri(p_gun int)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_gun      int := least(greatest(coalesce(p_gun, 90), 1), 365);
  v_bugun    date := (now() at time zone 'Europe/Istanbul')::date;
  v_haftalik jsonb;
  u1 bigint; t1 bigint;
  u7 bigint; t7 bigint;
  u30 bigint; t30 bigint;
begin
  with k as (
    select h.id,
           (h.created_at at time zone 'Europe/Istanbul')::date as kg
      from public.growth_households h
     where h.created_at >= now() - make_interval(days => v_gun)
       and public._growth_kayitli_hane(h.lifecycle)
  ),
  s as (
    select k.id, k.kg,
           (k.kg + 1  <= v_bugun) as m1,
           (k.kg + 7  <= v_bugun) as m7,
           (k.kg + 30 <= v_bugun) as m30,
           exists (select 1 from public.growth_hane_aktif_gunleri a
                    where a.household_id = k.id and a.gun = k.kg + 1)  as r1,
           exists (select 1 from public.growth_hane_aktif_gunleri a
                    where a.household_id = k.id and a.gun = k.kg + 7)  as r7,
           exists (select 1 from public.growth_hane_aktif_gunleri a
                    where a.household_id = k.id and a.gun = k.kg + 30) as r30
      from k
  ),
  w as (
    select date_trunc('week', s.kg)::date as hafta,
           count(*) as boyut,
           count(*) filter (where s.m1)  as u1,
           count(*) filter (where s.m1 and s.r1)  as t1,
           count(*) filter (where s.m7)  as u7,
           count(*) filter (where s.m7 and s.r7)  as t7,
           count(*) filter (where s.m30) as u30,
           count(*) filter (where s.m30 and s.r30) as t30
      from s
     group by 1
  )
  select coalesce((select jsonb_agg(jsonb_build_object(
                     'hafta', w.hafta,
                     'boyut', public._growth_gizle(w.boyut),
                     'd1_oran', public._growth_yuzde(w.t1, w.u1),
                     'd7_oran', public._growth_yuzde(w.t7, w.u7),
                     'd30_oran', public._growth_yuzde(w.t30, w.u30)
                   ) order by w.hafta) from w), '[]'::jsonb),
         coalesce((select sum(w.u1)  from w), 0), coalesce((select sum(w.t1)  from w), 0),
         coalesce((select sum(w.u7)  from w), 0), coalesce((select sum(w.t7)  from w), 0),
         coalesce((select sum(w.u30) from w), 0), coalesce((select sum(w.t30) from w), 0)
    into v_haftalik, u1, t1, u7, t7, u30, t30;

  return jsonb_build_object(
    'gun', v_gun,
    'bugun', v_bugun,
    'ozet', jsonb_build_array(
      jsonb_build_object('gun', 1,  'uygun_hane', public._growth_gizle(u1),  'tutulan', public._growth_gizle(t1),  'oran', public._growth_yuzde(t1,  u1)),
      jsonb_build_object('gun', 7,  'uygun_hane', public._growth_gizle(u7),  'tutulan', public._growth_gizle(t7),  'oran', public._growth_yuzde(t7,  u7)),
      jsonb_build_object('gun', 30, 'uygun_hane', public._growth_gizle(u30), 'tutulan', public._growth_gizle(t30), 'oran', public._growth_yuzde(t30, u30))
    ),
    'haftalik', v_haftalik
  );
end;
$function$;

create or replace function public.admin_growth_kohort(p_gun int default 90)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
begin
  perform public.require_admin();
  return public._growth_kohort_veri(p_gun);
end;
$function$;

-- ---------------------------------------------------------------------
-- 2. CAC çekirdeği
-- ---------------------------------------------------------------------
create or replace function public._growth_cac_veri(p_gun int)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_gun      int := least(greatest(coalesce(p_gun, 90), 1), 365);
  v_bugun    date := (now() at time zone 'Europe/Istanbul')::date;
  v_n        bigint;
  v_satirlar jsonb;
begin
  select count(*) into v_n
    from public.growth_households h
   where h.created_at >= now() - make_interval(days => v_gun)
     and public._growth_kayitli_hane(h.lifecycle);

  select coalesce(jsonb_agg(jsonb_build_object(
           'para_birimi', x.para_birimi,
           'harcama', x.harcama,
           'yeni_hane', public._growth_gizle(v_n),
           'cac', case when public._growth_gizle(v_n) is null then null
                       else round(x.harcama / v_n, 2) end,
           'durum', case when public._growth_gizle(v_n) is null then 'veri_az' else 'hesaplandi' end
         ) order by x.para_birimi), '[]'::jsonb)
    into v_satirlar
    from (
      select h.para_birimi, sum(h.tutar) as harcama
        from public.growth_harcama h
       where h.tarih >= v_bugun - v_gun
         and h.tarih <= v_bugun
       group by h.para_birimi
    ) x;

  return jsonb_build_object(
    'gun', v_gun,
    'yeni_hane', public._growth_gizle(v_n),
    'satirlar', v_satirlar,
    'durum', case when jsonb_array_length(v_satirlar) = 0 then 'harcama_yok' else 'ok' end
  );
end;
$function$;

create or replace function public.admin_growth_cac(p_gun int default 90)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
begin
  perform public.require_admin();
  return public._growth_cac_veri(p_gun);
end;
$function$;

-- ---------------------------------------------------------------------
-- 3. VERİ KALİTESİ çekirdeği
-- ---------------------------------------------------------------------
create or replace function public._growth_veri_kalitesi_veri()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_veli       bigint;
  v_eposta     bigint;
  v_tarihsiz   bigint;
  v_izin       jsonb;
begin
  select count(*) into v_veli
    from public.profiles p
   where p.role = 'veli';

  select count(*) filter (where h.email is null or btrim(h.email) = ''),
         count(*) filter (where h.lifecycle in ('activated', 'engaged', 'paid', 'at_risk', 'winback')
                            and h.activated_at is null)
    into v_eposta, v_tarihsiz
    from public.growth_households h;

  select coalesce(jsonb_agg(jsonb_build_object(
           'kanal', c.kanal,
           'acik', public._growth_gizle(coalesce(g.acik, 0)),
           'kapali', public._growth_gizle(coalesce(g.kapali, 0)),
           'kayit_yok', public._growth_gizle(greatest(v_veli - coalesce(g.toplam, 0), 0))
         ) order by c.sira), '[]'::jsonb)
    into v_izin
    from (values ('eposta', 1), ('push', 2), ('sms', 3), ('uygulama_ici', 4)) as c(kanal, sira)
    left join (
      select t.kanal,
             count(*) filter (where t.izin)     as acik,
             count(*) filter (where not t.izin) as kapali,
             count(*)                           as toplam
        from public.iletisim_tercihleri t
        join public.profiles p on p.id = t.veli_id and p.role = 'veli'
       group by t.kanal
    ) g on g.kanal = c.kanal;

  return jsonb_build_object(
    'veli_toplam', public._growth_gizle(v_veli),
    'kalite', jsonb_build_array(
      jsonb_build_object('kod', 'eposta_eksik',   'sayi', public._growth_gizle(v_eposta)),
      jsonb_build_object('kod', 'aktif_tarihsiz', 'sayi', public._growth_gizle(v_tarihsiz))
    ),
    'izin', v_izin
  );
end;
$function$;

create or replace function public.admin_growth_veri_kalitesi()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
begin
  perform public.require_admin();
  return public._growth_veri_kalitesi_veri();
end;
$function$;

-- ---------------------------------------------------------------------
-- 4. ZAMANLI ÜRETİM (yalnız taslak; gönderim yok)
-- ---------------------------------------------------------------------
create or replace function public.growth_rapor_zamanli_uret()
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_donem text := 'haftalik-' || to_char(now() at time zone 'Europe/Istanbul', 'IYYY-"W"IW');
  v_id uuid;
begin
  select r.id into v_id from public.growth_rapor_taslagi r where r.donem_anahtari = v_donem;
  if v_id is not null then
    return v_id;
  end if;

  insert into public.growth_rapor_taslagi (donem_anahtari, icerik, olusturan)
  values (v_donem,
          jsonb_build_object(
            'kaynak', 'zamanli',
            'kohort', public._growth_kohort_veri(30),
            'cac', public._growth_cac_veri(30),
            'veri_kalitesi', public._growth_veri_kalitesi_veri(),
            'uretildi', now()),
          null)
  on conflict (donem_anahtari) do nothing
  returning id into v_id;

  if v_id is null then
    select r.id into v_id from public.growth_rapor_taslagi r where r.donem_anahtari = v_donem;
  end if;
  return v_id;
end;
$function$;

-- ---------------------------------------------------------------------
-- 5. YETKİLER
-- ---------------------------------------------------------------------
revoke execute on function public._growth_kohort_veri(int)        from public, anon, authenticated;
revoke execute on function public._growth_cac_veri(int)           from public, anon, authenticated;
revoke execute on function public._growth_veri_kalitesi_veri()    from public, anon, authenticated;
revoke execute on function public.growth_rapor_zamanli_uret()     from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 6. ZAMANLAYICI: pazartesi 05:30 UTC (08:30 İstanbul)
-- ---------------------------------------------------------------------
do $$
begin
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    begin
      perform cron.unschedule('growth_rapor_zamanli');
    exception when others then null;
    end;
    perform cron.schedule('growth_rapor_zamanli', '30 5 * * 1', 'select public.growth_rapor_zamanli_uret()');
  else
    raise notice 'pg_cron yok: growth_rapor_zamanli_uret() harici zamanlayıcıyla çağrılmalı';
  end if;
end $$;
