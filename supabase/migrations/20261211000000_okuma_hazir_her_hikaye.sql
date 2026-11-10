-- =====================================================================
-- Okuma Dünyası — "Hazır Hupo" (kahraman_turu = 'hazir') her hikâyede açık
--   * Kaynak tanım: 20261050000200_okuma_dunyasi_ogrenci.sql (_okuma_katalog, okuma_oturum_baslat).
--   * Değişen yalnız iki koşul: 'hazir' seçildiğinde izinli_turler kontrolü atlanır.
--   * Diğer davranış, imza ve yetkiler birebir aynıdır.
-- =====================================================================

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
         and (p_kahraman_turu is null or p_kahraman_turu = 'hazir' or p_kahraman_turu = any (s.izinli_turler))
    ) q
   where q.sira <= v_limit;

  return v_sonuc;
end;
$$;

revoke execute on function public._okuma_katalog(uuid, boolean, integer, text, text, text, integer, integer, text, integer)
  from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. Oturum başlat (idempotent; advisory lock; kota; saatlik sınır)
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
  if p_kahraman_turu <> 'hazir' and p_kahraman_turu <> all (v_s.izinli_turler) then
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
