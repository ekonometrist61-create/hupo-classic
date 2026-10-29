-- =====================================================================
--  W7 · GİRİŞ OLAYLARI, ÇOCUK KODU GLOBAL SINIRI, ADMİN GİRİŞ ÖZETİ
--  Tarih : 2026-10-27
--  Ön koşul: 20260920000900 (is_admin, require_admin), 20260920001100 (app_settings),
--            20261019000300 (veli_baglama_hatalari, _veli_bagla_hata, veli_cocuk_sayisi),
--            20261025000100 (veli_cocuk_bagla hesap başına 3 / 15 dk sınırı)
--
--  NE DEĞİŞİYOR?
--    1) giris_olaylari         : YALNIZ BAŞARILI girişlerin kaydı (user_id, rol, kanal, zaman).
--                                Doğrudan erişim yok; yazma giris_olayi_kaydet(), okuma RPC'lerle.
--                                Dakikada en fazla 1 kayıt/kullanıcı; fazlası sessizce yutulur.
--    2) son_giris_zamani()     : kullanıcının kendi son girişi; admin, başkasınınkini okuyabilir.
--    3) admin_giris_ozet()     : yalnız toplamlar (gün bazlı sayı, rol kırılımı, farklı hesap sayısı).
--                                Kullanıcı kimliği ya da hesap listesi DÖNMEZ (PII yok).
--    4) giris_olaylari_temizle(): 180 günden eski satırları siler; pg_cron yoksa elle/harici çağrılır.
--    5) veli_cocuk_bagla()     : mevcut hesap başına sınırın YANINA tüm sistem genelinde dakikada N
--                                başarısız deneme eşiği eklenir (varsayılan 30; ayar:
--                                app_settings.veli_kod_global_sinir = {"dakika_basina": N}).
--                                Aşılırsa 'cok_fazla_deneme' (errcode 54000) ile geçici olarak reddeder.
--                                Hesap çoğaltarak taramayı durdurmak için tasarlandı.
--
--  BAŞARISIZ GİRİŞ NEDEN TUTULMUYOR?
--    Başarısız bir giriş denemesinde kullanıcı kimliği yoktur; kaydı yalnız e-posta ya da IP ile
--    tutulabilir. Her ikisi de kişisel veridir (AGENTS §5). Bu yüzden başarısız denemeler bu tabloya
--    yazılmaz; Supabase Auth log'una bırakılır. Tabloda yalnız kimliği bilinen başarılı girişler bulunur.
--    Çocuk kodu sayacı (madde 5) bunun dışındadır: mevcut veli_baglama_hatalari tablosunu kullanır
--    (veli_id + zaman; e-posta ve IP yazılmaz).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Tablo: başarılı giriş olayları
-- ---------------------------------------------------------------------
create table if not exists public.giris_olaylari (
  id          bigint generated always as identity primary key,
  user_id     uuid        not null references auth.users (id) on delete cascade,
  rol         text,
  kanal       text        not null check (kanal in ('web', 'mobil')),
  sonuc       text        not null default 'basarili' check (sonuc = 'basarili'),
  created_at  timestamptz not null default now()
);

comment on table public.giris_olaylari is
  'Yalnız başarılı girişler (kimlikli). Başarısız denemeler kimliksiz olduğu için burada tutulmaz (Auth log). '
  '180 gün sonra giris_olaylari_temizle() siler. Doğrudan erişim yok.';

create index if not exists giris_olaylari_user_zaman_idx
  on public.giris_olaylari (user_id, created_at desc);
create index if not exists giris_olaylari_zaman_idx
  on public.giris_olaylari (created_at);

alter table public.giris_olaylari enable row level security;
-- Politika yok: istemci tabloya hiçbir şekilde erişemez; yalnız aşağıdaki security definer RPC'ler.
revoke all on table public.giris_olaylari from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. Yazıcı: giriş başarılı olduktan sonra istemci çağırır
--    Dönüş: true (kayıt yazıldı) | false (son 1 dakikada zaten kayıt var, sessizce yutuldu)
-- ---------------------------------------------------------------------
create or replace function public.giris_olayi_kaydet(p_kanal text)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid  uuid := auth.uid();
  v_rol  text;
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı' using errcode = '42501';
  end if;
  if p_kanal is null or p_kanal not in ('web', 'mobil') then
    raise exception 'Geçersiz giriş kanalı' using errcode = '22023';
  end if;

  -- Profil satırını kilitle: aynı kullanıcının eşzamanlı çağrıları sıraya girer,
  -- böylece dakika kontrolü yarışmaz.
  select role into v_rol from public.profiles where id = v_uid for update;

  if exists (
    select 1 from public.giris_olaylari
     where user_id = v_uid and created_at > now() - interval '1 minute'
  ) then
    return false;  -- dakikada en çok 1 kayıt; fazlası sessizce yutulur
  end if;

  insert into public.giris_olaylari (user_id, rol, kanal) values (v_uid, v_rol, p_kanal);
  return true;
end;
$$;

revoke execute on function public.giris_olayi_kaydet(text) from public, anon;
grant  execute on function public.giris_olayi_kaydet(text) to authenticated;

-- ---------------------------------------------------------------------
-- 3. Son giriş zamanı: kendi kaydı herkese; başkasının kaydı yalnız admin'e
--    Dönüş: timestamptz | null (hiç giriş kaydı yoksa)
-- ---------------------------------------------------------------------
create or replace function public.son_giris_zamani(p_kullanici uuid default null)
returns timestamptz
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid    uuid := auth.uid();
  v_hedef  uuid := coalesce(p_kullanici, v_uid);
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı' using errcode = '42501';
  end if;
  if v_hedef <> v_uid then
    perform public.require_admin();
  end if;

  return (select max(g.created_at) from public.giris_olaylari g where g.user_id = v_hedef);
end;
$$;

revoke execute on function public.son_giris_zamani(uuid) from public, anon;
grant  execute on function public.son_giris_zamani(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- 4. Admin özeti: yalnız toplamlar (PII yok)
--    Dönüş: { gun, toplam, farkli_hesap, roller:{rol:n}, gunluk:[{gun, toplam, roller}] }
--    Saat dilimi Türkiye (gün sınırı yerel gece yarısı). Pencere en fazla 180 gün.
-- ---------------------------------------------------------------------
create or replace function public.admin_giris_ozet(p_gun integer default 7)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_gun      integer := least(greatest(coalesce(p_gun, 7), 1), 180);
  v_bas      timestamptz := now() - make_interval(days => least(greatest(coalesce(p_gun, 7), 1), 180));
  v_toplam   bigint;
  v_farkli   bigint;
  v_roller   jsonb;
  v_gunluk   jsonb;
begin
  perform public.require_admin();

  select count(*), count(distinct g.user_id)
    into v_toplam, v_farkli
    from public.giris_olaylari g
   where g.created_at >= v_bas;

  select coalesce(jsonb_object_agg(s.rol, s.n), '{}'::jsonb) into v_roller
    from (
      select coalesce(g.rol, 'bilinmiyor') as rol, count(*)::integer as n
        from public.giris_olaylari g
       where g.created_at >= v_bas
       group by 1
    ) s;

  select coalesce(jsonb_agg(jsonb_build_object('gun', d.gun, 'toplam', d.toplam, 'roller', d.roller)
                            order by d.gun), '[]'::jsonb) into v_gunluk
    from (
      select s.gun, sum(s.n)::integer as toplam, jsonb_object_agg(s.rol, s.n) as roller
        from (
          select (g.created_at at time zone 'Europe/Istanbul')::date as gun,
                 coalesce(g.rol, 'bilinmiyor') as rol,
                 count(*)::integer as n
            from public.giris_olaylari g
           where g.created_at >= v_bas
           group by 1, 2
        ) s
       group by s.gun
    ) d;

  return jsonb_build_object(
    'gun', v_gun,
    'toplam', coalesce(v_toplam, 0),
    'farkli_hesap', coalesce(v_farkli, 0),
    'roller', v_roller,
    'gunluk', v_gunluk
  );
end;
$$;

revoke execute on function public.admin_giris_ozet(integer) from public, anon;
grant  execute on function public.admin_giris_ozet(integer) to authenticated;

-- ---------------------------------------------------------------------
-- 5. Saklama: 180 gün
-- ---------------------------------------------------------------------
create or replace function public.giris_olaylari_temizle()
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare v_silinen integer;
begin
  delete from public.giris_olaylari where created_at < now() - interval '180 days';
  get diagnostics v_silinen = row_count;
  return v_silinen;
end;
$$;

revoke all on function public.giris_olaylari_temizle() from public, anon, authenticated;
grant  execute on function public.giris_olaylari_temizle() to service_role;

-- pg_cron etkinse her gün 03:40 (UTC); değilse yalnız fonksiyon kalır, harici zamanlayıcı çağırmalı.
do $$
begin
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    begin
      perform cron.unschedule('giris_olaylari_temizle');
    exception when others then null;
    end;
    perform cron.schedule('giris_olaylari_temizle', '40 3 * * *', 'select public.giris_olaylari_temizle()');
  else
    raise notice 'pg_cron yok: giris_olaylari_temizle() günlük elle/harici zamanlayıcıyla çağrılmalı';
  end if;
end $$;

-- ---------------------------------------------------------------------
-- 6. Çocuk eşleştirme kodu: tüm sistem genelinde dakikalık başarısız-deneme eşiği
--    Ayar: app_settings.veli_kod_global_sinir = {"dakika_basina": N}; yoksa 30.
-- ---------------------------------------------------------------------
insert into public.app_settings (key, value)
values ('veli_kod_global_sinir', '{"dakika_basina": 30}'::jsonb)
on conflict (key) do nothing;

create index if not exists veli_baglama_hatalari_zaman_idx
  on public.veli_baglama_hatalari (created_at);

-- Önceki sürüm: 20261025000100 (hesap başına 15 dk / 3 hata). Bu sürüm onu AYNEN korur ve yanına
-- global eşiği ekler. Global eşik aşıldığında yeni kod denemesi hiçbir şey yazmadan reddedilir.
create or replace function public.veli_cocuk_bagla(p_kod text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := auth.uid();
  v_role    text;
  v_hata    integer;
  v_global  integer;
  v_esik    integer;
  v_kod     text := btrim(coalesce(p_kod, ''));
  v_kayit   public.ogrenci_baglanti_kodlari%rowtype;
  v_ogr     public.profiles%rowtype;
begin
  if v_uid is null then
    raise exception 'Lütfen önce giriş yapın' using errcode = '42501';
  end if;

  -- Veli satırını kilitle: aynı velinin eşzamanlı istekleri sıraya girer (5 çocuk sınırı)
  select role into v_role from public.profiles where id = v_uid for update;
  if v_role is distinct from 'veli' then
    raise exception 'Çocuk bağlama işlemini yalnızca veli hesapları yapabilir' using errcode = '42501';
  end if;

  -- Hesap başına hız sınırı (20261025000100): 15 dakikada en fazla 3 başarısız deneme.
  select count(*) into v_hata from public.veli_baglama_hatalari
   where veli_id = v_uid and created_at > now() - interval '15 minutes';
  if v_hata >= 3 then
    raise exception 'Çok fazla hatalı deneme yaptınız. Lütfen 15 dakika sonra tekrar deneyin.'
      using errcode = '42501';
  end if;

  -- Global hız sınırı (W7): tüm sistemde son 1 dakikadaki başarısız denemeler eşiği aşarsa reddet.
  select case when s.value ->> 'dakika_basina' ~ '^[0-9]{1,4}$'
              then (s.value ->> 'dakika_basina')::integer end
    into v_esik
    from public.app_settings s
   where s.key = 'veli_kod_global_sinir';
  v_esik := greatest(coalesce(v_esik, 30), 1);

  select count(*) into v_global from public.veli_baglama_hatalari
   where created_at > now() - interval '1 minute';
  if v_global >= v_esik then
    raise exception 'cok_fazla_deneme' using errcode = '54000',
      hint = 'Sistem geçici olarak yoğun. Birkaç dakika sonra tekrar deneyin.';
  end if;

  if public.veli_cocuk_sayisi(v_uid) >= 5 then
    raise exception 'En fazla 5 çocuk hesabı bağlayabilirsiniz' using errcode = '22023';
  end if;

  if v_kod !~ '^[0-9]{6}$' then
    return public._veli_bagla_hata(v_uid, 'Kod 6 haneli bir sayı olmalıdır');
  end if;

  select * into v_kayit from public.ogrenci_baglanti_kodlari
   where kod = v_kod and kullanildi_at is null
   for update;
  if not found or v_kayit.son_gecerlilik < now() then
    return public._veli_bagla_hata(v_uid,
      'Kod hatalı ya da süresi dolmuş. Lütfen çocuğunuzdan yeni bir kod isteyin.');
  end if;

  select * into v_ogr from public.profiles where id = v_kayit.ogrenci_id for update;
  if not found or v_ogr.role <> 'ogrenci' or v_ogr.parent_id is not null then
    return public._veli_bagla_hata(v_uid, 'Bu öğrenci hesabı bağlanamıyor');
  end if;

  -- Bayrak: profiles_guard_immutable (20261016) yalnızca 'app.parent_link_rpc' ile boş parent_id
  -- doldurmaya izin verir. Önceki sürümdeki 'app.veli_cocuk_bagla' bayrağını guard tanımıyordu;
  -- başarılı bağlama guard'da reddediliyordu (PGlite'ta doğrulandı). Burada yalnız v_ogr.parent_id
  -- null iken yazılır, yani guard'ın amacıyla birebir örtüşür.
  perform set_config('app.parent_link_rpc', 'on', true);
  update public.profiles set parent_id = v_uid where id = v_ogr.id;
  perform set_config('app.parent_link_rpc', 'off', true);

  update public.ogrenci_baglanti_kodlari
     set kullanildi_at = now(), kullanan_veli = v_uid
   where id = v_kayit.id;

  return jsonb_build_object('ogrenci_id', v_ogr.id, 'ad', v_ogr.full_name);
end;
$$;

-- Mevcut yetkileri koru (20261025000100 ile aynı)
revoke execute on function public.veli_cocuk_bagla(text) from public, anon;
grant  execute on function public.veli_cocuk_bagla(text) to authenticated;
grant  execute on function public.veli_cocuk_bagla(text) to service_role;
