-- =====================================================================
-- Okuma Dünyası — F1 (3/4): öğrenci RPC'leri (katalog, paket teslimi, oturum, cevap, XP, geri bildirim, PDF)
--   * Hiçbir RPC'de serbest metin parametre yok: metin alanları kod (desen/beyaz liste) doğrulamalıdır.
--   * Çocuk / aile / yoldaş adı sunucuya gitmez. Cinsiyet parametresi ve alanı yoktur.
--   * Soru anahtarı (dogru, aciklama) yalnız okuma_cevap_kontrol ile, cevaptan SONRA ve tek soru için döner.
--   * XP yalnız award_xp_and_streak üzerinden; (öğrenci, hikâye) ilk tamamlamasında, günlük tavan altında.
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Katalog çekirdeği (iç)
-- ---------------------------------------------------------------------
create or replace function public._okuma_katalog(
  p_uid uuid, p_onizleme boolean,
  p_ana_sinif integer, p_tema text, p_ders text, p_deger text,
  p_zorluk_min integer, p_zorluk_max integer, p_kahraman_turu text, p_limit integer)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_limit  integer := least(greatest(coalesce(p_limit, 24), 1), 48);
  v_zmin   integer := greatest(coalesce(p_zorluk_min, 1), 1);
  v_zmax   integer := least(coalesce(p_zorluk_max, 5), 5);
  v_sinif  smallint;
  v_tercih text[];
  v_sonuc  jsonb;
begin
  if p_ana_sinif is not null and p_ana_sinif not between 1 and 8 then
    raise exception 'BAD_SINIF' using errcode = '22023';
  end if;
  if p_tema is not null and p_tema !~ '^[a-z_]{1,40}$' then
    raise exception 'BAD_TEMA' using errcode = '22023';
  end if;
  if p_ders is not null and p_ders !~ '^[a-z_]{1,40}$' then
    raise exception 'BAD_DERS' using errcode = '22023';
  end if;
  if p_deger is not null and p_deger !~ '^D([1-9]|1[0-9]|20)$' then
    raise exception 'BAD_DEGER' using errcode = '22023';
  end if;
  if p_kahraman_turu is not null and p_kahraman_turu not in
     ('ben', 'anne', 'baba', 'kardes', 'arkadas', 'baska_biri', 'hayvan', 'arac', 'hayali', 'hazir') then
    raise exception 'BAD_KAHRAMAN_TURU' using errcode = '22023';
  end if;

  select p.sinif into v_sinif from public.profiles p where p.id = p_uid;
  select t.degerler into v_tercih from public.okuma_cocuk_tercihleri t where t.cocuk_id = p_uid;
  v_tercih := coalesce(v_tercih, '{}');

  select coalesce(jsonb_agg(jsonb_build_object(
           'hikaye_id', q.hikaye_id, 'surum_id', q.surum_id, 'surum_no', q.surum_no, 'slug', q.slug,
           'baslik', q.baslik, 'tanitim', q.tanitim, 'tur', q.tur, 'konu', q.konu,
           'ana_sinif', q.ana_sinif, 'okuma_zorlugu', q.okuma_zorlugu, 'kavram_zorlugu', q.kavram_zorlugu,
           'temalar', q.temalar, 'ders_baglantisi', q.ders_baglantisi,
           'ana_deger', q.ana_deger, 'yardimci_deger', q.yardimci_deger,
           'izinli_turler', q.izinli_turler, 'dunya_tipi', q.dunya_tipi,
           'kelime_sayisi', q.kelime_sayisi, 'tahmini_sure_dk', q.tahmini_sure_dk,
           'soru_sayisi', q.soru_sayisi, 'sha256', q.sha256,
           'onizleme', q.onizleme, 'gorulmedi', q.gorulmedi, 'deger_eslesmesi', q.deger_eslesmesi)
         order by q.sira), '[]'::jsonb)
    into v_sonuc
    from (
      select h.id as hikaye_id, s.id as surum_id, s.surum_no, h.slug, s.baslik, s.tanitim, s.tur, s.konu,
             e.ana_sinif, e.okuma_zorlugu, e.kavram_zorlugu, e.temalar, e.ders_baglantisi,
             e.ana_deger, e.yardimci_deger, s.izinli_turler, s.dunya_tipi,
             case when (e.olculen ->> 'kelime_sayisi') ~ '^[0-9]{1,6}$' then (e.olculen ->> 'kelime_sayisi')::integer end as kelime_sayisi,
             case when (e.olculen ->> 'tahmini_sure_dk') ~ '^[0-9]{1,3}(\.[0-9]{1,2})?$' then (e.olculen ->> 'tahmini_sure_dk')::numeric end as tahmini_sure_dk,
             s.soru_sayisi, s.sha256, (s.durum <> 'yayinda') as onizleme,
             not exists (select 1 from public.okuma_oturumlari o where o.ogrenci_id = p_uid and o.hikaye_id = h.id) as gorulmedi,
             coalesce(e.ana_deger = any (v_tercih) or e.yardimci_deger = any (v_tercih), false) as deger_eslesmesi,
             row_number() over (
               order by
                 not exists (select 1 from public.okuma_oturumlari o where o.ogrenci_id = p_uid and o.hikaye_id = h.id) desc,
                 coalesce(e.ana_deger = any (v_tercih) or e.yardimci_deger = any (v_tercih), false) desc,
                 abs(e.ana_sinif - coalesce(v_sinif, e.ana_sinif)) asc,
                 (e.ilgi_egilimi = 'ortak') desc,   -- yalnız yumuşak sıralama; cinsiyet bilinmez ve filtre yoktur
                 e.okuma_zorlugu asc, h.slug asc) as sira
        from public.okuma_hikayeleri h
        cross join lateral (select public._okuma_gorunen_surum(h.id, p_onizleme) as sid) g
        join public.okuma_hikaye_surumleri s on s.id = g.sid
        join public.okuma_hikaye_etiketleri e on e.surum_id = s.id
       where g.sid is not null
         and (p_ana_sinif is null or e.ana_sinif = p_ana_sinif)
         and (p_tema is null or p_tema = any (e.temalar))
         and (p_ders is null or p_ders = any (e.ders_baglantisi))
         and (p_deger is null or e.ana_deger = p_deger or e.yardimci_deger = p_deger)
         and e.okuma_zorlugu between v_zmin and v_zmax
         and (p_kahraman_turu is null or p_kahraman_turu = any (s.izinli_turler))
    ) q
   where q.sira <= v_limit;

  return v_sonuc;
end;
$$;

revoke execute on function public._okuma_katalog(uuid, boolean, integer, text, text, text, integer, integer, text, integer)
  from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. Özellik durumu (bayrak kapalıyken de çağrılabilir)
-- ---------------------------------------------------------------------
create or replace function public.okuma_ozellik_durumu()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := public._okuma_ogrenci();
  v_e       record;
  v_sinirli boolean;
  v_limit   integer := coalesce((public._okuma_ayar('okuma_gunluk_hikaye'))::integer, 1);
  v_kullan  integer;
  v_pdf_lim integer := coalesce((public._okuma_ayar('okuma_pdf_aylik_ucretsiz'))::integer, 3);
  v_pdf_kul integer;
begin
  select * into v_e from public._okuma_erisim(v_uid);
  v_sinirli := public._okuma_kota_sinirli(v_uid);
  v_kullan := public._okuma_kota_kullanilan(v_uid);
  select count(*)::integer into v_pdf_kul from public.okuma_pdf_kullanimlari k
   where k.kullanici_id = v_uid
     and k.ay = date_trunc('month', now() at time zone 'Europe/Istanbul')::date;

  return jsonb_build_object(
    'erisim', v_e.erisim,
    'onizleme', v_e.onizleme,
    'gunluk_kota', jsonb_build_object(
      'sinirli', v_sinirli, 'limit', case when v_sinirli then v_limit end,
      'kullanilan', v_kullan, 'kalan', case when v_sinirli then greatest(v_limit - v_kullan, 0) end),
    'pdf', jsonb_build_object(
      'sinirli', v_sinirli, 'aylik_limit', case when v_sinirli then v_pdf_lim end,
      'kullanilan', v_pdf_kul, 'kalan', case when v_sinirli then greatest(v_pdf_lim - v_pdf_kul, 0) end),
    'xp', jsonb_build_object(
      'tamamlama', (public._okuma_ayar('xp_tamamlama'))::integer,
      'dogru_bonus', (public._okuma_ayar('xp_dogru_bonus'))::integer,
      'dogru_orani_esik', (public._okuma_ayar('dogru_orani_esik'))::integer,
      'gunluk_hikaye_tavani', (public._okuma_ayar('xp_gunluk_hikaye_tavani'))::integer));
end;
$$;

revoke all on function public.okuma_ozellik_durumu() from public, anon;
grant execute on function public.okuma_ozellik_durumu() to authenticated;

-- ---------------------------------------------------------------------
-- 3. Katalog
-- ---------------------------------------------------------------------
create or replace function public.okuma_katalog_filtre(
  p_ana_sinif integer default null,
  p_tema text default null,
  p_ders text default null,
  p_deger text default null,
  p_zorluk_min integer default 1,
  p_zorluk_max integer default 5,
  p_kahraman_turu text default null,
  p_limit integer default 24)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public._okuma_ogrenci();
  v_e   record;
begin
  select * into v_e from public._okuma_erisim(v_uid);
  if not v_e.erisim then
    raise exception 'OKUMA_KAPALI' using errcode = '42501';
  end if;
  return jsonb_build_object(
    'onizleme', v_e.onizleme,
    'hikayeler', public._okuma_katalog(v_uid, v_e.onizleme, p_ana_sinif, p_tema, p_ders, p_deger,
                                       p_zorluk_min, p_zorluk_max, p_kahraman_turu, p_limit));
end;
$$;

revoke all on function public.okuma_katalog_filtre(integer, text, text, text, integer, integer, text, integer) from public, anon;
grant execute on function public.okuma_katalog_filtre(integer, text, text, text, integer, integer, text, integer) to authenticated;

-- ---------------------------------------------------------------------
-- 4. Paket teslimi: soru anahtarı (dogru, aciklama) SOYULMUŞ
-- ---------------------------------------------------------------------
create or replace function public.okuma_hikaye_getir(p_hikaye_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := public._okuma_ogrenci();
  v_e     record;
  v_sid   uuid;
  v_s     public.okuma_hikaye_surumleri%rowtype;
  v_paket jsonb;
begin
  select * into v_e from public._okuma_erisim(v_uid);
  if not v_e.erisim then
    raise exception 'OKUMA_KAPALI' using errcode = '42501';
  end if;
  v_sid := public._okuma_gorunen_surum(p_hikaye_id, v_e.onizleme);
  if v_sid is null then
    raise exception 'HIKAYE_BULUNAMADI' using errcode = 'P0002';
  end if;
  -- Okuma kotası paket indirmeyi de bağlar (oturum açmadan sınırsız okuma yolu kalmasın)
  perform public._okuma_kota_kontrol(v_uid, p_hikaye_id);

  select * into v_s from public.okuma_hikaye_surumleri where id = v_sid;

  v_paket := jsonb_set(
    v_s.icerik - 'uretim',
    '{sorular}',
    coalesce((select jsonb_agg(q - 'dogru' - 'aciklama' order by ord)
                from jsonb_array_elements(v_s.icerik -> 'sorular') with ordinality as t(q, ord)), '[]'::jsonb));
  v_paket := jsonb_set(v_paket, '{hikaye,etiketler}', (v_paket #> '{hikaye,etiketler}') - 'denetim');

  return jsonb_build_object(
    'hikaye_id', v_s.hikaye_id, 'surum_id', v_s.id, 'surum', v_s.surum_no, 'sha256', v_s.sha256,
    'min_motor_surumu', v_s.min_motor_surumu, 'onizleme', v_s.durum <> 'yayinda', 'paket', v_paket);
end;
$$;

revoke all on function public.okuma_hikaye_getir(uuid) from public, anon;
grant execute on function public.okuma_hikaye_getir(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- 5. Oturum başlat (idempotent; advisory lock; kota; saatlik sınır)
-- ---------------------------------------------------------------------
create or replace function public.okuma_oturum_baslat(
  p_hikaye_id uuid,
  p_kahraman_turu text,
  p_yoldas_var boolean,
  p_okuma_modu text,
  p_istemci_anahtari text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := public._okuma_ogrenci();
  v_e     record;
  v_modu  text := coalesce(p_okuma_modu, 'zengin');
  v_yol   boolean := coalesce(p_yoldas_var, false);
  v_o     public.okuma_oturumlari%rowtype;
  v_sid   uuid;
  v_s     public.okuma_hikaye_surumleri%rowtype;
  v_sinirli boolean;
  v_limit integer;
begin
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('okuma:' || v_uid::text, 0));

  if p_kahraman_turu is null or p_kahraman_turu not in
     ('ben', 'anne', 'baba', 'kardes', 'arkadas', 'baska_biri', 'hayvan', 'arac', 'hayali', 'hazir') then
    raise exception 'BAD_KAHRAMAN_TURU' using errcode = '22023';
  end if;
  if v_modu not in ('sade', 'zengin') then
    raise exception 'BAD_OKUMA_MODU' using errcode = '22023';
  end if;
  if p_istemci_anahtari is null or p_istemci_anahtari !~ '^[A-Za-z0-9_-]{8,64}$' then
    raise exception 'INVALID_ATTEMPT_KEY' using errcode = '22023';
  end if;

  select * into v_e from public._okuma_erisim(v_uid);
  if not v_e.erisim then
    raise exception 'OKUMA_KAPALI' using errcode = '42501';
  end if;

  v_sinirli := public._okuma_kota_sinirli(v_uid);
  v_limit := coalesce((public._okuma_ayar('okuma_gunluk_hikaye'))::integer, 1);

  -- Ağ yeniden denemesi: aynı oturum
  select * into v_o from public.okuma_oturumlari where ogrenci_id = v_uid and istemci_anahtari = p_istemci_anahtari;
  if found then
    if v_o.hikaye_id <> p_hikaye_id or v_o.kahraman_turu <> p_kahraman_turu
       or v_o.yoldas_var <> v_yol or v_o.okuma_modu <> v_modu then
      raise exception 'IDEMPOTENCY_CONFLICT' using errcode = '22023';
    end if;
    return jsonb_build_object('oturum_id', v_o.id, 'hikaye_id', v_o.hikaye_id, 'surum_id', v_o.surum_id,
                              'soru_sayisi', v_o.soru_sayisi, 'tekrar', true,
                              'kota_kalan', case when v_sinirli then greatest(v_limit - public._okuma_kota_kullanilan(v_uid), 0) end);
  end if;

  v_sid := public._okuma_gorunen_surum(p_hikaye_id, v_e.onizleme);
  if v_sid is null then
    raise exception 'HIKAYE_BULUNAMADI' using errcode = 'P0002';
  end if;
  select * into v_s from public.okuma_hikaye_surumleri where id = v_sid;
  if p_kahraman_turu <> all (v_s.izinli_turler) then
    raise exception 'KAHRAMAN_TURU_UYGUN_DEGIL' using errcode = '22023';
  end if;

  perform public._okuma_kota_kontrol(v_uid, p_hikaye_id);

  if (select count(*) from public.okuma_oturumlari o
       where o.ogrenci_id = v_uid and o.baslangic_at > now() - interval '1 hour')
     >= coalesce((public._okuma_ayar('saatlik_baslatma_siniri'))::integer, 12) then
    raise exception 'RATE_LIMIT' using errcode = '53400';
  end if;

  insert into public.okuma_oturumlari (
    ogrenci_id, hikaye_id, surum_id, istemci_anahtari, kahraman_turu, yoldas_var, okuma_modu,
    sinif, gun, soru_sayisi)
  values (
    v_uid, p_hikaye_id, v_sid, p_istemci_anahtari, p_kahraman_turu, v_yol, v_modu,
    (select p.sinif from public.profiles p where p.id = v_uid), public._okuma_gun(), v_s.soru_sayisi)
  returning * into v_o;

  return jsonb_build_object('oturum_id', v_o.id, 'hikaye_id', v_o.hikaye_id, 'surum_id', v_o.surum_id,
                            'soru_sayisi', v_o.soru_sayisi, 'tekrar', false,
                            'kota_kalan', case when v_sinirli then greatest(v_limit - public._okuma_kota_kullanilan(v_uid), 0) end);
end;
$$;

revoke all on function public.okuma_oturum_baslat(uuid, text, boolean, text, text) from public, anon;
grant execute on function public.okuma_oturum_baslat(uuid, text, boolean, text, text) to authenticated;

-- Okuma ilerlemesi (bırakılan sayfa analitiği için): yalnız sayı
create or replace function public.okuma_ilerleme_kaydet(p_oturum_id uuid, p_sayfa integer)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public._okuma_ogrenci();
  v_son smallint;
begin
  if p_sayfa is null or p_sayfa not between 0 and 12 then
    raise exception 'BAD_SAYFA' using errcode = '22023';
  end if;
  update public.okuma_oturumlari
     set son_sayfa = greatest(son_sayfa, p_sayfa::smallint)
   where id = p_oturum_id and ogrenci_id = v_uid and tamamlandi_at is null
  returning son_sayfa into v_son;
  if not found then
    raise exception 'OTURUM_BULUNAMADI' using errcode = 'P0002';
  end if;
  return jsonb_build_object('son_sayfa', v_son);
end;
$$;

revoke all on function public.okuma_ilerleme_kaydet(uuid, integer) from public, anon;
grant execute on function public.okuma_ilerleme_kaydet(uuid, integer) to authenticated;

-- ---------------------------------------------------------------------
-- 6. Cevap kontrolü: tek deneme; doğru şık + açıklama YALNIZ cevaptan sonra, tek soru için
-- ---------------------------------------------------------------------
create or replace function public.okuma_cevap_kontrol(
  p_oturum_id uuid, p_soru_id text, p_secenek_id text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := public._okuma_ogrenci();
  v_o     public.okuma_oturumlari%rowtype;
  v_icerik jsonb;
  v_q     jsonb;
  v_c     public.okuma_cevaplari%rowtype;
  v_dogru boolean;
begin
  if p_soru_id is null or p_soru_id !~ '^s[0-9]{1,3}$' then
    raise exception 'BAD_SORU' using errcode = '22023';
  end if;
  if p_secenek_id is null or p_secenek_id not in ('A', 'B', 'C', 'D') then
    raise exception 'BAD_OPTION' using errcode = '22023';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('okuma:' || v_uid::text, 0));

  select * into v_o from public.okuma_oturumlari where id = p_oturum_id and ogrenci_id = v_uid for update;
  if not found then
    raise exception 'OTURUM_BULUNAMADI' using errcode = 'P0002';
  end if;

  select s.icerik into v_icerik from public.okuma_hikaye_surumleri s where s.id = v_o.surum_id;
  select q into v_q from jsonb_array_elements(v_icerik -> 'sorular') q where q ->> 'id' = p_soru_id;
  if v_q is null then
    raise exception 'SORU_BULUNAMADI' using errcode = 'P0002';
  end if;

  -- Tek deneme: kayıtlı sonuç tekrar döner, cevap değiştirilemez
  select * into v_c from public.okuma_cevaplari where oturum_id = p_oturum_id and soru_id = p_soru_id;
  if found then
    return jsonb_build_object('dogru', v_c.dogru, 'aciklama', v_q ->> 'aciklama',
                              'dogru_secenek_id', v_q ->> 'dogru', 'tekrar', true);
  end if;

  if v_o.tamamlandi_at is not null then
    raise exception 'OTURUM_KAPALI' using errcode = '22023';
  end if;
  if not exists (select 1 from jsonb_array_elements(v_q -> 'secenekler') s where s ->> 'id' = p_secenek_id) then
    raise exception 'BAD_OPTION' using errcode = '22023';
  end if;

  v_dogru := p_secenek_id = (v_q ->> 'dogru');
  insert into public.okuma_cevaplari (oturum_id, soru_id, secenek_id, dogru, beceri, hedef_id, olcme_turu)
  values (p_oturum_id, p_soru_id, p_secenek_id, v_dogru, v_q ->> 'beceri', v_q ->> 'hedef_id', v_q ->> 'olcme_turu');

  update public.okuma_oturumlari
     set dogru_sayisi = dogru_sayisi + case when v_dogru then 1 else 0 end
   where id = p_oturum_id;

  return jsonb_build_object('dogru', v_dogru, 'aciklama', v_q ->> 'aciklama',
                            'dogru_secenek_id', v_q ->> 'dogru', 'tekrar', false);
end;
$$;

revoke all on function public.okuma_cevap_kontrol(uuid, text, text) from public, anon;
grant execute on function public.okuma_cevap_kontrol(uuid, text, text) to authenticated;

-- ---------------------------------------------------------------------
-- 7. Oturumu bitir: XP, seri, hedef durumları, sonuç özeti
-- ---------------------------------------------------------------------
create or replace function public.okuma_oturum_bitir(
  p_oturum_id uuid,
  p_dokunulan text[] default '{}')
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := public._okuma_ogrenci();
  v_o       public.okuma_oturumlari%rowtype;
  v_dok     text[] := coalesce(p_dokunulan, '{}');
  v_dogru   integer;
  v_soru    integer;
  v_oran    numeric;
  v_ilk     boolean;
  v_gunluk  integer;
  v_tavan   integer := coalesce((public._okuma_ayar('xp_gunluk_hikaye_tavani'))::integer, 2);
  v_xp_tam  integer := coalesce((public._okuma_ayar('xp_tamamlama'))::integer, 10);
  v_xp_bon  integer := coalesce((public._okuma_ayar('xp_dogru_bonus'))::integer, 10);
  v_esik    integer := coalesce((public._okuma_ayar('dogru_orani_esik'))::integer, 67);
  v_toplam  integer;
  v_xp_ver  boolean;
  v_award   jsonb;
  v_xp      integer := 0;
  v_beceri  jsonb;
  v_hedefler jsonb;
  v_tavan_doldu boolean := false;
begin
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('okuma:' || v_uid::text, 0));

  select * into v_o from public.okuma_oturumlari where id = p_oturum_id and ogrenci_id = v_uid for update;
  if not found then
    raise exception 'OTURUM_BULUNAMADI' using errcode = 'P0002';
  end if;

  -- Dokunulan kimlikler: yalnız bu sürümde kayıtlı hedefler
  if cardinality(v_dok) > 50 then
    raise exception 'BAD_HEDEF' using errcode = '22023';
  end if;
  if exists (select 1 from unnest(v_dok) d
              where d is null or d !~ '^[a-z0-9_]{1,80}$'
                 or not exists (select 1 from public.okuma_hikaye_hedefleri hh
                                 where hh.surum_id = v_o.surum_id and hh.hedef_id = d)) then
    raise exception 'BAD_HEDEF' using errcode = '22023';
  end if;

  select coalesce(jsonb_object_agg(b, jsonb_build_object('soru', n, 'dogru', d)), '{}'::jsonb)
    into v_beceri
    from (select c.beceri as b, count(*)::integer as n, count(*) filter (where c.dogru)::integer as d
            from public.okuma_cevaplari c where c.oturum_id = v_o.id group by c.beceri) x;

  -- Zaten bitmiş: kayıtlı sonuç, XP/seri tekrar işlenmez
  if v_o.tamamlandi_at is not null then
    select coalesce(jsonb_agg(jsonb_build_object('hedef_id', h.id, 'etiket', h.etiket, 'durum', d.durum)), '[]'::jsonb)
      into v_hedefler
      from public.okuma_hikaye_hedefleri hh
      join public.okuma_ogrenme_hedefleri h on h.id = hh.hedef_id
      left join public.okuma_ogrenci_hedef_durumu d on d.hedef_id = h.id and d.ogrenci_id = v_uid
     where hh.surum_id = v_o.surum_id;
    return jsonb_build_object(
      'oturum_id', v_o.id, 'tamamlandi', true, 'tekrar', true,
      'soru_sayisi', v_o.soru_sayisi, 'dogru_sayisi', v_o.dogru_sayisi,
      'dogru_orani', case when v_o.soru_sayisi > 0 then round(100.0 * v_o.dogru_sayisi / v_o.soru_sayisi, 0) end,
      'kazanilan_xp', v_o.kazanilan_xp, 'ilk_tamamlama', v_o.ilk_tamamlama,
      'beceri_sonuclari', v_o.beceri_sonuclari, 'hedefler', v_hedefler);
  end if;

  v_soru := v_o.soru_sayisi;
  select count(*) filter (where c.dogru)::integer into v_dogru
    from public.okuma_cevaplari c where c.oturum_id = v_o.id;
  v_dogru := coalesce(v_dogru, 0);
  v_oran := case when v_soru > 0 then 100.0 * v_dogru / v_soru else 0 end;

  -- XP kuralı: (öğrenci, hikâye) ilk tamamlama + günde en çok N hikâyenin XP'si
  v_ilk := not exists (select 1 from public.okuma_oturumlari x
                        where x.ogrenci_id = v_uid and x.hikaye_id = v_o.hikaye_id and x.ilk_tamamlama);
  select count(distinct x.hikaye_id)::integer into v_gunluk
    from public.okuma_oturumlari x
   where x.ogrenci_id = v_uid and x.xp_verildi
     and (x.tamamlandi_at at time zone 'Europe/Istanbul')::date = public._okuma_gun();
  v_toplam := v_xp_tam + case when v_soru > 0 and v_oran >= v_esik then v_xp_bon else 0 end;
  v_tavan_doldu := v_ilk and v_gunluk >= v_tavan;
  v_xp_ver := v_ilk and v_gunluk < v_tavan and v_toplam > 0;

  -- Tek XP/seri yazım yolu. xp_ver=false iken yalnız seri işler. 10/20/30 adımı: toplam / 10.
  v_award := public.award_xp_and_streak(
    v_uid, least(greatest(v_toplam / 10, 1), 3)::smallint, v_xp_ver);
  v_xp := case when v_xp_ver then coalesce((v_award ->> 'kazanilan_xp')::integer, 0) else 0 end;

  -- Hedef durumları: maruziyet
  insert into public.okuma_ogrenci_hedef_durumu (ogrenci_id, hedef_id, durum)
  select v_uid, hh.hedef_id, 'introduced'
    from public.okuma_hikaye_hedefleri hh where hh.surum_id = v_o.surum_id
  on conflict (ogrenci_id, hedef_id) do nothing;

  -- Hedef durumları: soru sonuçları
  with sonuc as (
    select c.hedef_id,
           bool_or(c.dogru) as dogru_var,
           bool_or(not c.dogru) as yanlis_var,
           coalesce(bool_or(c.dogru and c.olcme_turu = 'transfer'), false) as transfer_dogru,
           (array_agg(c.beceri order by c.created_at) filter (where not c.dogru))[1] as hata_beceri
      from public.okuma_cevaplari c
     where c.oturum_id = v_o.id and c.hedef_id is not null
     group by c.hedef_id)
  update public.okuma_ogrenci_hedef_durumu d
     set durum = case
           when s.dogru_var then case
             when d.durum in ('not_seen', 'introduced', 'refresh_due') then 'recognized'
             when d.durum = 'recognized' and (d.son_dogru_at is null or d.son_dogru_at < now() - interval '1 day') then 'retrieved'
             when d.durum in ('retrieved', 'transferred') and s.transfer_dogru then 'transferred'
             else d.durum end
           when s.yanlis_var and d.durum in ('recognized', 'retrieved', 'transferred') then 'refresh_due'
           else d.durum end,
         son_dogru_at = case when s.dogru_var then now() else d.son_dogru_at end,
         hata_turu = case when s.yanlis_var and not s.dogru_var then s.hata_beceri else d.hata_turu end
    from sonuc s
   where d.ogrenci_id = v_uid and d.hedef_id = s.hedef_id;

  update public.okuma_ogrenci_hedef_durumu d
     set tekrar_at = case d.durum
           when 'recognized'   then now() + interval '2 days'
           when 'retrieved'    then now() + interval '7 days'
           when 'transferred'  then now() + interval '21 days'
           when 'refresh_due'  then now() + interval '1 day'
           else d.tekrar_at end
   where d.ogrenci_id = v_uid
     and d.hedef_id in (select c.hedef_id from public.okuma_cevaplari c
                         where c.oturum_id = v_o.id and c.hedef_id is not null);

  update public.okuma_oturumlari
     set tamamlandi_at = now(), dogru_sayisi = v_dogru, beceri_sonuclari = v_beceri,
         dokunulan_hedefler = (select coalesce(array_agg(distinct d), '{}') from unnest(v_dok) d),
         kazanilan_xp = v_xp, xp_verildi = v_xp_ver, ilk_tamamlama = v_ilk,
         son_sayfa = greatest(son_sayfa, 1)
   where id = v_o.id;

  select coalesce(jsonb_agg(jsonb_build_object('hedef_id', h.id, 'etiket', h.etiket, 'durum', d.durum)), '[]'::jsonb)
    into v_hedefler
    from public.okuma_hikaye_hedefleri hh
    join public.okuma_ogrenme_hedefleri h on h.id = hh.hedef_id
    left join public.okuma_ogrenci_hedef_durumu d on d.hedef_id = h.id and d.ogrenci_id = v_uid
   where hh.surum_id = v_o.surum_id;

  return jsonb_build_object(
    'oturum_id', v_o.id, 'tamamlandi', true, 'tekrar', false,
    'soru_sayisi', v_soru, 'dogru_sayisi', v_dogru, 'dogru_orani', round(v_oran, 0),
    'kazanilan_xp', v_xp, 'ilk_tamamlama', v_ilk, 'xp_tavani_doldu', v_tavan_doldu,
    'beceri_sonuclari', v_beceri, 'hedefler', v_hedefler,
    'seri', v_award - 'kazanilan_xp');
end;
$$;

revoke all on function public.okuma_oturum_bitir(uuid, text[]) from public, anon;
grant execute on function public.okuma_oturum_bitir(uuid, text[]) to authenticated;

-- ---------------------------------------------------------------------
-- 8. Geri bildirim (anket; quizden ayrı; yalnız kod beyaz listesi; ödülsüz)
-- ---------------------------------------------------------------------
create or replace function public.okuma_geri_bildirim_gonder(
  p_oturum_id uuid,
  p_yildiz integer,
  p_iyilestirme_kodlari text[] default '{}',
  p_baska_kahraman boolean default false,
  p_ayni_turden boolean default false,
  p_sorun_kodlari text[] default '{}')
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public._okuma_ogrenci();
  v_iy  text[] := coalesce(p_iyilestirme_kodlari, '{}');
  v_so  text[] := coalesce(p_sorun_kodlari, '{}');
begin
  if p_yildiz is null or p_yildiz not between 1 and 5 then
    raise exception 'BAD_YILDIZ' using errcode = '22023';
  end if;
  if cardinality(v_iy) > 8 or exists (select 1 from unnest(v_iy) k where k is null or k <> all (array[
       'daha_kisa', 'daha_uzun', 'daha_komik', 'daha_gizemli', 'daha_kolay', 'daha_zor',
       'daha_cok_macera', 'daha_cok_bilgi'])) then
    raise exception 'BAD_KOD' using errcode = '22023';
  end if;
  if cardinality(v_so) > 8 or exists (select 1 from unnest(v_so) k where k is null or k <> all (array[
       'ad_yanlis_yazilmis', 'anlasilmayan_sozcuk', 'soru_hatali', 'cevap_hatali',
       'cok_zor', 'cok_kolay', 'yazi_hatasi', 'uygunsuz_icerik'])) then
    raise exception 'BAD_KOD' using errcode = '22023';
  end if;
  if not exists (select 1 from public.okuma_oturumlari o where o.id = p_oturum_id and o.ogrenci_id = v_uid) then
    raise exception 'OTURUM_BULUNAMADI' using errcode = 'P0002';
  end if;

  insert into public.okuma_geri_bildirimleri (
    oturum_id, yildiz, iyilestirme_kodlari, baska_kahraman, ayni_turden, sorun_kodlari)
  values (
    p_oturum_id, p_yildiz::smallint, (select coalesce(array_agg(distinct k), '{}') from unnest(v_iy) k),
    coalesce(p_baska_kahraman, false), coalesce(p_ayni_turden, false),
    (select coalesce(array_agg(distinct k), '{}') from unnest(v_so) k))
  on conflict (oturum_id) do update
    set yildiz = excluded.yildiz, iyilestirme_kodlari = excluded.iyilestirme_kodlari,
        baska_kahraman = excluded.baska_kahraman, ayni_turden = excluded.ayni_turden,
        sorun_kodlari = excluded.sorun_kodlari;

  return jsonb_build_object('kaydedildi', true);
end;
$$;

revoke all on function public.okuma_geri_bildirim_gonder(uuid, integer, text[], boolean, boolean, text[]) from public, anon;
grant execute on function public.okuma_geri_bildirim_gonder(uuid, integer, text[], boolean, boolean, text[]) to authenticated;

-- ---------------------------------------------------------------------
-- 9. Okuma serisi + bugünkü hikâye önerisi
-- ---------------------------------------------------------------------
create or replace function public.okuma_seri_ve_oneri()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := public._okuma_ogrenci();
  v_e       record;
  v_stats   record;
  v_bugun   date := public._okuma_gun();
  v_tam     integer;
  v_toplam  integer;
  v_sinirli boolean;
  v_limit   integer := coalesce((public._okuma_ayar('okuma_gunluk_hikaye'))::integer, 1);
  v_oneriler jsonb;
begin
  select * into v_e from public._okuma_erisim(v_uid);
  if not v_e.erisim then
    raise exception 'OKUMA_KAPALI' using errcode = '42501';
  end if;

  select s.streak_count, s.last_active_date, s.en_uzun_seri into v_stats
    from public.student_stats s where s.student_id = v_uid;
  select count(distinct o.hikaye_id)::integer into v_tam
    from public.okuma_oturumlari o
   where o.ogrenci_id = v_uid and o.tamamlandi_at is not null
     and (o.tamamlandi_at at time zone 'Europe/Istanbul')::date = v_bugun;
  select count(distinct o.hikaye_id)::integer into v_toplam
    from public.okuma_oturumlari o where o.ogrenci_id = v_uid and o.tamamlandi_at is not null;
  v_sinirli := public._okuma_kota_sinirli(v_uid);
  v_oneriler := public._okuma_katalog(v_uid, v_e.onizleme, null, null, null, null, 1, 5, null, 1);

  return jsonb_build_object(
    'seri', jsonb_build_object(
      'streak_count', coalesce(v_stats.streak_count, 0),
      'en_uzun_seri', coalesce(v_stats.en_uzun_seri, 0),
      'son_aktif_gun', v_stats.last_active_date,
      'seri_devam', coalesce(v_stats.last_active_date >= v_bugun - 1, false),
      'bugun_okudu', v_tam > 0),
    'bugun_tamamlanan', v_tam,
    'toplam_tamamlanan', v_toplam,
    'kota_dolu', v_sinirli and public._okuma_kota_kullanilan(v_uid) >= v_limit,
    'oneri', v_oneriler -> 0);
end;
$$;

revoke all on function public.okuma_seri_ve_oneri() from public, anon;
grant execute on function public.okuma_seri_ve_oneri() to authenticated;

-- ---------------------------------------------------------------------
-- 10. PDF hakkı (sunucu sayacı): ücretsizde ayda N, premium/deneme sınırsız.
--     Aynı hikâye aynı ay ikinci kez hak tüketmez. Öğrenci, veli veya admin çağırabilir.
-- ---------------------------------------------------------------------
create or replace function public.okuma_pdf_hakki_kullan(p_hikaye_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := (select auth.uid());
  v_ay      date := date_trunc('month', now() at time zone 'Europe/Istanbul')::date;
  v_onizleme boolean;
  v_limit   integer := coalesce((public._okuma_ayar('okuma_pdf_aylik_ucretsiz'))::integer, 3);
  v_kullan  integer;
  v_tekrar  boolean;
begin
  if v_uid is null or public.current_user_role() not in ('ogrenci', 'veli', 'admin') then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('okuma:' || v_uid::text, 0));

  v_onizleme := public.current_user_role() = 'admin'
                or coalesce((public._okuma_ayar('izinli_kullanicilar')) ? v_uid::text, false);
  if public._okuma_gorunen_surum(p_hikaye_id, v_onizleme) is null then
    raise exception 'HIKAYE_BULUNAMADI' using errcode = 'P0002';
  end if;

  if not public._okuma_kota_sinirli(v_uid) then
    insert into public.okuma_pdf_kullanimlari (kullanici_id, hikaye_id, ay)
    values (v_uid, p_hikaye_id, v_ay) on conflict do nothing;
    return jsonb_build_object('izin', true, 'kalan', null, 'tekrar', false);
  end if;

  select count(*)::integer into v_kullan from public.okuma_pdf_kullanimlari k
   where k.kullanici_id = v_uid and k.ay = v_ay;
  v_tekrar := exists (select 1 from public.okuma_pdf_kullanimlari k
                       where k.kullanici_id = v_uid and k.ay = v_ay and k.hikaye_id = p_hikaye_id);
  if v_tekrar then
    return jsonb_build_object('izin', true, 'kalan', greatest(v_limit - v_kullan, 0), 'tekrar', true);
  end if;
  if v_kullan >= v_limit then
    return jsonb_build_object('izin', false, 'kalan', 0, 'tekrar', false);
  end if;

  insert into public.okuma_pdf_kullanimlari (kullanici_id, hikaye_id, ay) values (v_uid, p_hikaye_id, v_ay);
  return jsonb_build_object('izin', true, 'kalan', v_limit - v_kullan - 1, 'tekrar', false);
end;
$$;

revoke all on function public.okuma_pdf_hakki_kullan(uuid) from public, anon;
grant execute on function public.okuma_pdf_hakki_kullan(uuid) to authenticated;
