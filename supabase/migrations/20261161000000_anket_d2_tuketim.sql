-- =====================================================================
--  Anket D2: tüketim (sıradaki kart, etkileşim bütçesi, sessiz saat, atlama sayacı)
--  Proje : Hupo / Yönetim Merkezi
--  Tarih : 2026-11-08
--  Ön koşul: 20261029000000 (yüzeyler), 20261158000000 (D1: anket_gosterimleri,
--            etkilesim_butcesi)
--  Kaynak: PROJE_GUNLUGU.md §24 D2 (GÖR-024)
--
--  NE DEĞİŞİYOR?
--    * anket_siradaki_kart(p_yuzey, p_yerel_saat) : veliye EN FAZLA 1 anket kartı döner
--    * anket_kart_atla(p_anket_id, p_yuzey)        : kartı kapatma = atlama (kart başına bir kez)
--    * anket_gosterimleri 'tamamlandi'             : anket_katilimlari trigger'ı yazar
--    * etkilesim_butce_al (iç)                     : push + anket ortak günlük bütçe
--
--  KURALLAR (kullanıcı kararları, §24)
--    * Bütçe: 24 saatte en fazla 1 kart. Ortak sayaç push ve anket kanallarını toplar;
--      kart gün içinde ekrana yeniden çizilirse (yenileme) bütçe TEKRAR harcanmaz.
--    * Sessiz saat: 22:00-08:00 (cihaz yerel saati, p_yerel_saat; verilmezse Europe/Istanbul).
--      Sessiz saatte kart dönmez ve bütçe harcanmaz.
--    * Atlama takvimi (anket başına, veli başına): 1. atlama 3 gün, 2. atlama 14 gün,
--      3. ve sonrası 90 gün. Sayaç sıfırlanmaz.
--    * Kartı kapatma (X) atlamadır; anket içi "soruyu atla" ve yarım kalan taslak sayılmaz
--      (bu RPC'ler çağrılmaz). Yanıtlanmış anket mevcut tekrar_gosterim_gun kuralıyla döner.
--    * Yüzey: mobil, web_app, veli_paneli. web_sitesi'nde anket kartı yoktur (hata).
--    * Çocuk verisi yok: yalnız veli kimliği ve anket kimliği tutulur.
--    * Mevcut anket_aktif_listem / anket_yanit_gonder değişmez (eski istemciler çalışır).
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. İç yardımcılar
-- ---------------------------------------------------------------------
create or replace function public._anket_sessiz_saat_mi(p_saat time)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select p_saat >= time '22:00' or p_saat < time '08:00';
$$;

create or replace function public._anket_atlama_bekleme(p_atlama_sayisi integer)
returns interval
language sql
immutable
set search_path = ''
as $$
  select case
    when coalesce(p_atlama_sayisi, 0) <= 0 then interval '0'
    when p_atlama_sayisi = 1 then interval '3 days'
    when p_atlama_sayisi = 2 then interval '14 days'
    else interval '90 days'
  end;
$$;

-- Ortak bütçe: bugün (Europe/Istanbul) push + anket toplamı p_limit'in altındaysa 1 harcar.
create or replace function public._etkilesim_butce_al(p_veli uuid, p_kanal text, p_limit integer default 1)
returns boolean
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_gun date := (now() at time zone 'Europe/Istanbul')::date;
  v_top integer;
begin
  if p_kanal not in ('push', 'anket', 'eposta') then
    raise exception 'Geçersiz kanal.' using errcode = '22023';
  end if;
  -- Aynı veli için eşzamanlı çağrılar sıraya girer (çifte kart yok).
  perform pg_advisory_xact_lock(hashtextextended('etkilesim:' || p_veli::text, 0));

  select coalesce(sum(sayi), 0)::integer into v_top
    from public.etkilesim_butcesi
   where veli_id = p_veli and gun = v_gun and kanal in ('push', 'anket');

  if v_top >= p_limit then
    return false;
  end if;

  insert into public.etkilesim_butcesi (veli_id, gun, kanal, sayi)
  values (p_veli, v_gun, p_kanal, 1)
  on conflict (veli_id, gun, kanal) do update set sayi = public.etkilesim_butcesi.sayi + 1;
  return true;
end;
$function$;

-- ---------------------------------------------------------------------
-- 2. Sıradaki kart
-- ---------------------------------------------------------------------
create or replace function public.anket_siradaki_kart(p_yuzey text, p_yerel_saat time default null)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_uid     uuid := (select auth.uid());
  v_saat    time;
  a         public.anketler%rowtype;
  v_son     record;
begin
  if v_uid is null or not exists (select 1 from public.profiles where id = v_uid and role = 'veli') then
    raise exception 'Bu işlem yalnızca veli hesabı içindir.' using errcode = '42501';
  end if;
  if p_yuzey is null or p_yuzey not in ('mobil', 'web_app', 'veli_paneli') then
    raise exception 'Geçersiz yayın yüzeyi.' using errcode = '22023';
  end if;

  -- Sessiz saat: kart yok, bütçe harcanmaz.
  v_saat := coalesce(p_yerel_saat, (now() at time zone 'Europe/Istanbul')::time);
  if public._anket_sessiz_saat_mi(v_saat) then
    return null;
  end if;

  -- Aday: yayında, bu yüzeyde, tekrar penceresi dışında, atlama beklemesi dolmuş.
  select x.* into a
    from public.anketler x
   where x.durum = 'yayinda' and x.hedef = 'veli'
     and p_yuzey = any (x.yuzeyler)
     and not exists (select 1 from public.anket_katilimlari k
                      where k.anket_id = x.id and k.veli_id = v_uid
                        and k.son_at > now() - make_interval(days => x.tekrar_gosterim_gun))
     and not exists (select 1
                       from (select count(*)::integer n, max(g.created_at) son
                               from public.anket_gosterimleri g
                              where g.anket_id = x.id and g.veli_id = v_uid and g.olay = 'atlandi') s
                      where s.n > 0 and now() < s.son + public._anket_atlama_bekleme(s.n))
   order by x.created_at
   limit 1;
  if not found then
    return null;
  end if;

  -- Son olay: çözülmemiş bir kart son 24 saatte gösterildiyse aynı kart bütçe harcamadan döner.
  select g.olay, g.created_at into v_son
    from public.anket_gosterimleri g
   where g.anket_id = a.id and g.veli_id = v_uid
   order by g.created_at desc, g.id
   limit 1;

  if not coalesce(v_son.olay = 'gosterildi' and v_son.created_at > now() - interval '24 hours', false) then
    -- Yeni kart: son 24 saatte başka bir kart gösterilmediyse ve günlük bütçe varsa.
    if exists (select 1 from public.anket_gosterimleri g
                where g.veli_id = v_uid and g.olay = 'gosterildi'
                  and g.created_at > now() - interval '24 hours') then
      return null;
    end if;
    if not public._etkilesim_butce_al(v_uid, 'anket', 1) then
      return null;
    end if;
    insert into public.anket_gosterimleri (anket_id, veli_id, yuzey, olay)
    values (a.id, v_uid, p_yuzey, 'gosterildi');
  end if;

  return jsonb_build_object(
    'id', a.id, 'ad', a.ad, 'anonim', a.anonim, 'surum', a.surum, 'sorular', a.sorular,
    'soru_sayisi', jsonb_array_length(a.sorular),
    'sure_dk', greatest(1, ceil(jsonb_array_length(a.sorular) * 15 / 60.0))::integer,
    'yuzey', p_yuzey);
end;
$function$;

comment on function public.anket_siradaki_kart(text, time) is
  'Veliye en fazla 1 anket kartı: yüzey, tekrar penceresi, atlama (3/14/90 gün), günlük bütçe ve sessiz saat (22-08) uygulanır. Yalnızca veli.';

-- ---------------------------------------------------------------------
-- 3. Kartı kapatma = atlama (kart başına bir kez)
-- ---------------------------------------------------------------------
create or replace function public.anket_kart_atla(p_anket_id uuid, p_yuzey text)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_uid   uuid := (select auth.uid());
  v_son   text;
  v_n     integer;
  v_son_t timestamptz;
begin
  if v_uid is null or not exists (select 1 from public.profiles where id = v_uid and role = 'veli') then
    raise exception 'Bu işlem yalnızca veli hesabı içindir.' using errcode = '42501';
  end if;
  if p_yuzey is null or p_yuzey not in ('mobil', 'web_app', 'veli_paneli') then
    raise exception 'Geçersiz yayın yüzeyi.' using errcode = '22023';
  end if;
  if not exists (select 1 from public.anketler where id = p_anket_id) then
    raise exception 'Anket bulunamadı' using errcode = 'P0002';
  end if;

  perform pg_advisory_xact_lock(hashtextextended('atla:' || v_uid::text || p_anket_id::text, 0));

  select g.olay into v_son
    from public.anket_gosterimleri g
   where g.anket_id = p_anket_id and g.veli_id = v_uid
   order by g.created_at desc, g.id
   limit 1;

  -- Yalnız çözülmemiş (gösterilmiş) kart atlanabilir; ikinci kapatma sayılmaz.
  if v_son = 'gosterildi' then
    insert into public.anket_gosterimleri (anket_id, veli_id, yuzey, olay)
    values (p_anket_id, v_uid, p_yuzey, 'atlandi');
  end if;

  select count(*)::integer, max(created_at) into v_n, v_son_t
    from public.anket_gosterimleri
   where anket_id = p_anket_id and veli_id = v_uid and olay = 'atlandi';

  return jsonb_build_object(
    'atlama_sayisi', v_n,
    'sonraki_gosterim', case when v_n > 0 then v_son_t + public._anket_atlama_bekleme(v_n) end);
end;
$function$;

comment on function public.anket_kart_atla(uuid, text) is
  'Kartı kapatma: atlama sayılır (kart başına bir kez). Dönen sonraki_gosterim 3/14/90 gün takvimine göredir. Yalnızca veli.';

-- ---------------------------------------------------------------------
-- 4. Tamamlama kaydı: katılım yazılınca (yanıt gönderilince) 'tamamlandi'
-- ---------------------------------------------------------------------
create or replace function public._anket_katilim_gosterim()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_yuzey text;
begin
  select g.yuzey into v_yuzey
    from public.anket_gosterimleri g
   where g.anket_id = new.anket_id and g.veli_id = new.veli_id
   order by g.created_at desc, g.id
   limit 1;
  insert into public.anket_gosterimleri (anket_id, veli_id, yuzey, olay)
  values (new.anket_id, new.veli_id, coalesce(v_yuzey, 'veli_paneli'), 'tamamlandi');
  return null;
end;
$function$;

drop trigger if exists anket_katilim_gosterim on public.anket_katilimlari;
create trigger anket_katilim_gosterim
  after insert or update on public.anket_katilimlari
  for each row execute function public._anket_katilim_gosterim();

-- ---------------------------------------------------------------------
-- 5. Yetkiler
-- ---------------------------------------------------------------------
revoke execute on function public._anket_sessiz_saat_mi(time)               from public, anon, authenticated;
revoke execute on function public._anket_atlama_bekleme(integer)            from public, anon, authenticated;
revoke execute on function public._etkilesim_butce_al(uuid, text, integer)  from public, anon, authenticated;
revoke execute on function public._anket_katilim_gosterim()                 from public, anon, authenticated;

revoke execute on function public.anket_siradaki_kart(text, time) from public, anon;
revoke execute on function public.anket_kart_atla(uuid, text)     from public, anon;
grant  execute on function public.anket_siradaki_kart(text, time) to authenticated;
grant  execute on function public.anket_kart_atla(uuid, text)     to authenticated;
