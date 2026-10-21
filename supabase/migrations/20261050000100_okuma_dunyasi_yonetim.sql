-- =====================================================================
-- Okuma Dünyası — F1 (2/4): paket doğrulama, içe aktarma, yayın kapısı ve yönetim RPC'leri
--   * Doğrulayıcı sema/hikaye-paketi.v1.schema.json'u (etiketler dahil) SQL'de yeniden uygular.
--   * Yayın kapısı sunucuda: ajan_a=pass, ajan_b=pass, insan=approved + oluşturan ≠ onaylayan.
--   * Tüm yönetim RPC'leri require_admin() ile başlar (42501) ve log_admin_action yazar.
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Doğrulama yardımcıları (iç; istemciye kapalı)
-- ---------------------------------------------------------------------
create or replace function public._okuma_js_tam(p jsonb, p_alt integer, p_ust integer)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select case
           when jsonb_typeof(p) = 'number' and (p #>> '{}') ~ '^[0-9]{1,6}$'
             then ((p #>> '{}')::integer between p_alt and p_ust)
           else false
         end;
$$;

create or replace function public._okuma_js_dizge(p jsonb, p_desen text, p_min integer, p_max integer)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select case
           when jsonb_typeof(p) = 'string'
             then length(p #>> '{}') between p_min and p_max
                  and (p_desen is null or (p #>> '{}') ~ p_desen)
           else false
         end;
$$;

create or replace function public._okuma_js_enum(p jsonb, p_izinli text[])
returns boolean
language sql
immutable
set search_path = ''
as $$
  select case when jsonb_typeof(p) = 'string' then (p #>> '{}') = any (p_izinli) else false end;
$$;

create or replace function public._okuma_js_dizi(
  p jsonb, p_izinli text[], p_desen text, p_min integer, p_max integer, p_tekil boolean)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select case
           when jsonb_typeof(p) = 'array' then
             jsonb_array_length(p) between p_min and p_max
             and not exists (
               select 1 from jsonb_array_elements(p) e
                where jsonb_typeof(e) <> 'string'
                   or (p_izinli is not null and (e #>> '{}') <> all (p_izinli))
                   or (p_desen is not null and (e #>> '{}') !~ p_desen))
             and (not p_tekil
                  or (select count(distinct (e #>> '{}')) from jsonb_array_elements(p) e) = jsonb_array_length(p))
           else false
         end;
$$;

-- Nesne anahtarları: zorunlular var mı, tanımsız anahtar var mı? Sorun yoksa null.
create or replace function public._okuma_anahtar_hatasi(p jsonb, p_zorunlu text[], p_istege_bagli text[])
returns text
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_anahtarlar text[];
  v_eksik text[];
  v_fazla text[];
begin
  if jsonb_typeof(p) is distinct from 'object' then
    return 'nesne olmalı';
  end if;
  select coalesce(array_agg(k), '{}') into v_anahtarlar from jsonb_object_keys(p) k;
  select array_agg(z) into v_eksik from unnest(p_zorunlu) z where z <> all (v_anahtarlar);
  select array_agg(k) into v_fazla from unnest(v_anahtarlar) k
   where k <> all (p_zorunlu || coalesce(p_istege_bagli, '{}'));
  if v_eksik is not null then return 'eksik alan: ' || array_to_string(v_eksik, ', '); end if;
  if v_fazla is not null then return 'tanımsız alan: ' || array_to_string(v_fazla, ', '); end if;
  return null;
end;
$$;

-- Tek metin parçası
create or replace function public._okuma_parca_hatasi(p jsonb)
returns text
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_t text;
  v_hal text[] := array['yalin', 'belirtme', 'yonelme', 'bulunma', 'ayrilma', 'ilgi'];
  v_m text;
begin
  if jsonb_typeof(p) is distinct from 'object' then return 'parça nesne olmalı'; end if;
  if jsonb_typeof(p -> 't') is distinct from 'string' then return 'parça türü (t) eksik'; end if;
  v_t := p ->> 't';

  if v_t in ('metin', 'vurgu') then
    v_m := public._okuma_anahtar_hatasi(p, array['t', 'v'], null);
    if v_m is null and not public._okuma_js_dizge(p -> 'v', null, 1, 5000) then v_m := 'v boş olamaz'; end if;
  elsif v_t = 'kahraman' then
    v_m := public._okuma_anahtar_hatasi(p, array['t', 'hal'], null);
    if v_m is null and not public._okuma_js_enum(p -> 'hal', v_hal) then v_m := 'hal geçersiz'; end if;
  elsif v_t = 'yoldas' then
    v_m := public._okuma_anahtar_hatasi(p, array['t', 'hal', 'yedek'], null);
    if v_m is null and not public._okuma_js_enum(p -> 'hal', v_hal) then v_m := 'hal geçersiz'; end if;
    if v_m is null and not public._okuma_js_dizge(p -> 'yedek', null, 1, 200) then v_m := 'yedek boş olamaz'; end if;
  elsif v_t in ('kelime', 'atasozu', 'deyim') then
    v_m := public._okuma_anahtar_hatasi(p, array['t', 'yuva'], null);
    if v_m is null and not public._okuma_js_dizge(p -> 'yuva', '^[a-z0-9_]+$', 1, 80) then v_m := 'yuva geçersiz'; end if;
  elsif v_t in ('deger', 'hareket') then
    v_m := public._okuma_anahtar_hatasi(p, array['t', 'anahtar'], null);
    if v_m is null and not public._okuma_js_dizge(p -> 'anahtar', '^[a-z0-9_]+$', 1, 80) then v_m := 'anahtar geçersiz'; end if;
  elsif v_t = 'isaret' then
    v_m := public._okuma_anahtar_hatasi(p, array['t', 'kod'], null);
    if v_m is null and not public._okuma_js_enum(p -> 'kod', array['ipucu', 'yildiz', 'kitap', 'anahtar', 'hupo', 'roket',
         'kalp', 'kedi', 'kus', 'ay', 'bulut', 'ucak', 'balik', 'orman', 'deniz', 'gunes']) then
      v_m := 'kod geçersiz';
    end if;
  elsif v_t = 'ikon' then
    v_m := public._okuma_anahtar_hatasi(p, array['t', 'v'], null);
    if v_m is null and not public._okuma_js_dizge(p -> 'v', null, 1, 8) then v_m := 'v 1-8 karakter olmalı'; end if;
  else
    return 'bilinmeyen parça türü: ' || left(v_t, 30);
  end if;
  return case when v_m is null then null else v_t || ': ' || v_m end;
end;
$$;

create or replace function public._okuma_parcalar_hatasi(p jsonb)
returns text
language plpgsql
immutable
set search_path = ''
as $$
declare
  e jsonb;
  v_m text;
begin
  if jsonb_typeof(p) is distinct from 'array' or jsonb_array_length(p) < 1 then
    return 'parçalar en az bir öğeli liste olmalı';
  end if;
  for e in select x from jsonb_array_elements(p) x loop
    v_m := public._okuma_parca_hatasi(e);
    if v_m is not null then return v_m; end if;
  end loop;
  return null;
end;
$$;

-- ---------------------------------------------------------------------
-- 2. Paket doğrulayıcı: hatalar listesi (boş liste = geçerli)
-- ---------------------------------------------------------------------
create or replace function public._okuma_paket_hatalari(p jsonb)
returns jsonb
language plpgsql
stable
set search_path = ''
as $$
declare
  v_h text[] := '{}';
  v_m text;
  v_hik jsonb;
  v_et jsonb;
  v_x jsonb;
  v_y jsonb;
  v_n integer := 0;
  v_kuy text;
  v_hedef_idleri text[] := '{}';
  v_soru_idleri text[] := '{}';
  v_secenek_idleri text[];
  v_temalar text[];
  v_dersler text[];
  v_catilar text[];
  v_degerler text[];
  v_ad text;
  v_sinif_alt integer;
  v_sinif_ust integer;
  v_ana_sinif integer;
  v_i integer;
  r record;
begin
  if jsonb_typeof(p) is distinct from 'object' then
    return to_jsonb(array['paket bir nesne olmalı']);
  end if;
  if length(p::text) > 300000 then
    return to_jsonb(array['paket çok büyük (en fazla 300 KB)']);
  end if;

  select coalesce(array_agg(anahtar), '{}') into v_temalar from public.okuma_etiket_sozlugu where tur = 'tema' and aktif;
  select coalesce(array_agg(anahtar), '{}') into v_dersler from public.okuma_etiket_sozlugu where tur = 'ders' and aktif;
  select coalesce(array_agg(anahtar), '{}') into v_catilar from public.okuma_etiket_sozlugu where tur = 'cati_deger' and aktif;
  select coalesce(array_agg(anahtar), '{}') into v_degerler from public.okuma_etiket_sozlugu where tur = 'deger' and aktif;

  v_m := public._okuma_anahtar_hatasi(p, array['paket_surumu', 'hikaye', 'sayfalar', 'sorular', 'uretim'],
           array['deger_sahneleri', 'hareket_sahneleri', 'deyim_cumleleri']);
  if v_m is not null then v_h := v_h || ('paket: ' || v_m); end if;
  if p -> 'paket_surumu' is distinct from '1'::jsonb then v_h := v_h || 'paket_surumu 1 olmalı'::text; end if;

  -- ---------------- hikaye ----------------
  v_hik := p -> 'hikaye';
  if jsonb_typeof(v_hik) is distinct from 'object' then
    v_h := v_h || 'hikaye nesne olmalı'::text;
  else
    v_m := public._okuma_anahtar_hatasi(v_hik,
      array['slug', 'baslik', 'tur', 'konu', 'sinif_alt', 'sinif_ust', 'okuma_bandi', 'dunya_tipi',
            'izinli_turler', 'deger_anahtarlari', 'yetiskin_uygun', 'durum', 'etiketler'], array['tanitim']);
    if v_m is not null then v_h := v_h || ('hikaye: ' || v_m); end if;
    if not public._okuma_js_dizge(v_hik -> 'slug', '^[a-z0-9]+(-[a-z0-9]+)*$', 1, 80) then v_h := v_h || 'hikaye.slug geçersiz'::text; end if;
    if not public._okuma_js_dizge(v_hik -> 'baslik', null, 3, 80) then v_h := v_h || 'hikaye.baslik 3-80 karakter olmalı'::text; end if;
    if not public._okuma_js_enum(v_hik -> 'tur', array['gizem', 'macera', 'bilim', 'doga', 'mizah']) then v_h := v_h || 'hikaye.tur geçersiz'::text; end if;
    if not public._okuma_js_dizge(v_hik -> 'konu', '^[a-z_]+$', 1, 60) then v_h := v_h || 'hikaye.konu geçersiz'::text; end if;
    if not public._okuma_js_tam(v_hik -> 'sinif_alt', 1, 8) then v_h := v_h || 'hikaye.sinif_alt 1-8 olmalı'::text; end if;
    if not public._okuma_js_tam(v_hik -> 'sinif_ust', 1, 8) then v_h := v_h || 'hikaye.sinif_ust 1-8 olmalı'::text; end if;
    if not public._okuma_js_tam(v_hik -> 'okuma_bandi', 1, 3) then v_h := v_h || 'hikaye.okuma_bandi 1-3 olmalı'::text; end if;
    if not public._okuma_js_enum(v_hik -> 'dunya_tipi', array['gercekci', 'masalsi']) then v_h := v_h || 'hikaye.dunya_tipi geçersiz'::text; end if;
    if not public._okuma_js_dizi(v_hik -> 'izinli_turler',
         array['ben', 'anne', 'baba', 'kardes', 'arkadas', 'baska_biri', 'hayvan', 'arac', 'hayali', 'hazir'],
         null, 1, 10, true) then
      v_h := v_h || 'hikaye.izinli_turler geçersiz (en az 1, tekil, tanımlı tür)'::text;
    end if;
    if not public._okuma_js_dizi(v_hik -> 'deger_anahtarlari', null, '^D([1-9]|1[0-9]|20)$', 0, 5, true) then
      v_h := v_h || 'hikaye.deger_anahtarlari geçersiz (en çok 5, tekil, D1-D20)'::text;
    end if;
    if jsonb_typeof(v_hik -> 'yetiskin_uygun') is distinct from 'boolean' then v_h := v_h || 'hikaye.yetiskin_uygun boolean olmalı'::text; end if;
    if not public._okuma_js_enum(v_hik -> 'durum', array['taslak', 'incelemede', 'yayinda', 'arsiv']) then v_h := v_h || 'hikaye.durum geçersiz'::text; end if;
    if v_hik ? 'tanitim' and not public._okuma_js_dizge(v_hik -> 'tanitim', null, 0, 160) then
      v_h := v_h || 'hikaye.tanitim en çok 160 karakter olmalı'::text;
    end if;
    if public._okuma_js_tam(v_hik -> 'sinif_alt', 1, 8) and public._okuma_js_tam(v_hik -> 'sinif_ust', 1, 8) then
      v_sinif_alt := (v_hik ->> 'sinif_alt')::integer;
      v_sinif_ust := (v_hik ->> 'sinif_ust')::integer;
      if v_sinif_alt > v_sinif_ust then v_h := v_h || 'hikaye.sinif_alt, sinif_ust değerinden büyük olamaz'::text; end if;
    end if;

    -- ---------------- etiketler ----------------
    v_et := v_hik -> 'etiketler';
    if jsonb_typeof(v_et) is distinct from 'object' then
      v_h := v_h || 'etiketler nesne olmalı'::text;
    else
      v_m := public._okuma_anahtar_hatasi(v_et,
        array['ana_sinif', 'okuma_zorlugu', 'kavram_zorlugu', 'ilgi_egilimi', 'temalar', 'ders_baglantisi', 'maarif',
              'ogrenme_hedefleri', 'kanit_duzeyi', 'program_surumu', 'denetim'], array['olculen']);
      if v_m is not null then v_h := v_h || ('etiketler: ' || v_m); end if;
      if not public._okuma_js_tam(v_et -> 'ana_sinif', 1, 8) then v_h := v_h || 'etiketler.ana_sinif 1-8 olmalı'::text; end if;
      if not public._okuma_js_tam(v_et -> 'okuma_zorlugu', 1, 5) then v_h := v_h || 'etiketler.okuma_zorlugu 1-5 olmalı'::text; end if;
      if not public._okuma_js_tam(v_et -> 'kavram_zorlugu', 1, 5) then v_h := v_h || 'etiketler.kavram_zorlugu 1-5 olmalı'::text; end if;
      if not public._okuma_js_enum(v_et -> 'ilgi_egilimi', array['ortak', 'kiz_egilimli', 'erkek_egilimli']) then
        v_h := v_h || 'etiketler.ilgi_egilimi geçersiz'::text;
      end if;
      if not public._okuma_js_dizi(v_et -> 'temalar', v_temalar, null, 1, 4, true) then
        v_h := v_h || 'etiketler.temalar geçersiz (1-4, tekil, sözlükte olmalı)'::text;
      end if;
      if not public._okuma_js_dizi(v_et -> 'ders_baglantisi', v_dersler, null, 1, 6, true) then
        v_h := v_h || 'etiketler.ders_baglantisi geçersiz (en az 1, tekil, sözlükte olmalı)'::text;
      end if;
      if not public._okuma_js_enum(v_et -> 'kanit_duzeyi', array['A', 'B', 'C', 'D']) then v_h := v_h || 'etiketler.kanit_duzeyi A-D olmalı'::text; end if;
      if not public._okuma_js_dizge(v_et -> 'program_surumu', null, 3, 200) then v_h := v_h || 'etiketler.program_surumu en az 3 karakter olmalı'::text; end if;
      if jsonb_typeof(v_et -> 'olculen') not in ('object') and v_et ? 'olculen' then v_h := v_h || 'etiketler.olculen nesne olmalı'::text; end if;

      -- maarif
      v_x := v_et -> 'maarif';
      v_m := public._okuma_anahtar_hatasi(v_x, array['ana_deger'], array['yardimci_deger', 'cati_degerler']);
      if v_m is not null then
        v_h := v_h || ('etiketler.maarif: ' || v_m);
      else
        if not public._okuma_js_dizge(v_x -> 'ana_deger', '^D([1-9]|1[0-9]|20)$', 1, 4) then v_h := v_h || 'maarif.ana_deger D1-D20 olmalı'::text; end if;
        if v_x ? 'yardimci_deger' then
          if not public._okuma_js_dizge(v_x -> 'yardimci_deger', '^D([1-9]|1[0-9]|20)$', 1, 4) then
            v_h := v_h || 'maarif.yardimci_deger D1-D20 olmalı'::text;
          elsif (v_x ->> 'yardimci_deger') = (v_x ->> 'ana_deger') then
            v_h := v_h || 'maarif.yardimci_deger ana_deger ile aynı olamaz'::text;
          end if;
        end if;
        if v_x ? 'cati_degerler' and not public._okuma_js_dizi(v_x -> 'cati_degerler', v_catilar, null, 0, 3, true) then
          v_h := v_h || 'maarif.cati_degerler geçersiz'::text;
        end if;
        if jsonb_typeof(v_hik -> 'deger_anahtarlari') = 'array'
           and not (v_hik -> 'deger_anahtarlari') @> to_jsonb(v_x ->> 'ana_deger') then
          v_h := v_h || 'maarif.ana_deger, hikaye.deger_anahtarlari içinde olmalı'::text;
        end if;
      end if;

      -- denetim
      v_x := v_et -> 'denetim';
      v_m := public._okuma_anahtar_hatasi(v_x, array['ajan_a', 'ajan_b', 'insan'], null);
      if v_m is not null then
        v_h := v_h || ('etiketler.denetim: ' || v_m);
      else
        if not public._okuma_js_enum(v_x -> 'ajan_a', array['pending', 'pass', 'fail', 'review_needed']) then v_h := v_h || 'denetim.ajan_a geçersiz'::text; end if;
        if not public._okuma_js_enum(v_x -> 'ajan_b', array['pending', 'pass', 'fail', 'review_needed']) then v_h := v_h || 'denetim.ajan_b geçersiz'::text; end if;
        if not public._okuma_js_enum(v_x -> 'insan', array['pending', 'approved', 'rejected']) then v_h := v_h || 'denetim.insan geçersiz'::text; end if;
      end if;

      -- sınıf tutarlılığı
      if public._okuma_js_tam(v_et -> 'ana_sinif', 1, 8) and v_sinif_alt is not null and v_sinif_ust is not null then
        v_ana_sinif := (v_et ->> 'ana_sinif')::integer;
        if v_ana_sinif < v_sinif_alt or v_ana_sinif > v_sinif_ust then
          v_h := v_h || 'etiketler.ana_sinif, sinif_alt-sinif_ust aralığında olmalı'::text;
        end if;
      end if;

      -- öğrenme hedefleri
      if jsonb_typeof(v_et -> 'ogrenme_hedefleri') is distinct from 'array' then
        v_h := v_h || 'etiketler.ogrenme_hedefleri liste olmalı'::text;
      else
        v_i := 0;
        for v_x in select e from jsonb_array_elements(v_et -> 'ogrenme_hedefleri') e loop
          v_i := v_i + 1;
          v_m := public._okuma_anahtar_hatasi(v_x, array['id', 'tur', 'etiket', 'islev'], array['yuva']);
          if v_m is not null then
            v_h := v_h || ('ogrenme_hedefleri[' || v_i || ']: ' || v_m);
            continue;
          end if;
          if not public._okuma_js_dizge(v_x -> 'id', '^[a-z0-9_]+$', 1, 80) then v_h := v_h || ('ogrenme_hedefleri[' || v_i || '].id geçersiz'); end if;
          if not public._okuma_js_enum(v_x -> 'tur', array['lexeme', 'idiom', 'proverb', 'homonym', 'concept', 'fact', 'misconception', 'value']) then
            v_h := v_h || ('ogrenme_hedefleri[' || v_i || '].tur geçersiz');
          end if;
          if not public._okuma_js_dizge(v_x -> 'etiket', null, 2, 120) then v_h := v_h || ('ogrenme_hedefleri[' || v_i || '].etiket 2-120 karakter olmalı'); end if;
          if v_x ? 'yuva' and not public._okuma_js_dizge(v_x -> 'yuva', '^[a-z0-9_]+$', 1, 80) then v_h := v_h || ('ogrenme_hedefleri[' || v_i || '].yuva geçersiz'); end if;
          if not public._okuma_js_enum(v_x -> 'islev', array['first_hint', 'application', 'retrieval', 'transfer', 'background']) then
            v_h := v_h || ('ogrenme_hedefleri[' || v_i || '].islev geçersiz');
          end if;
          if jsonb_typeof(v_x -> 'id') = 'string' then

            v_hedef_idleri := array_append(v_hedef_idleri, (v_x ->> 'id') || '/' || coalesce(v_x ->> 'islev', ''));
          end if;
        end loop;
        -- aynı (id, islev) çifti ikinci kez geçemez
        if (select count(distinct h2) from unnest(v_hedef_idleri) h2) <> cardinality(v_hedef_idleri) then
          v_h := v_h || 'ogrenme_hedefleri: aynı id ve islev birden fazla kez geçiyor'::text;
        end if;
        -- aynı id farklı tür taşıyamaz
        if exists (
          select 1 from jsonb_array_elements(v_et -> 'ogrenme_hedefleri') a
            join jsonb_array_elements(v_et -> 'ogrenme_hedefleri') b
              on a ->> 'id' = b ->> 'id' and a ->> 'tur' is distinct from b ->> 'tur') then
          v_h := v_h || 'ogrenme_hedefleri: aynı id farklı tür taşıyor'::text;
        end if;
      end if;
    end if;
  end if;

  -- ---------------- sayfalar ----------------
  if jsonb_typeof(p -> 'sayfalar') is distinct from 'array'
     or jsonb_array_length(p -> 'sayfalar') not between 3 and 12 then
    v_h := v_h || 'sayfalar 3-12 öğeli liste olmalı'::text;
  else
    v_n := jsonb_array_length(p -> 'sayfalar');
    v_i := 0;
    for v_x in select e from jsonb_array_elements(p -> 'sayfalar') e loop
      v_i := v_i + 1;
      v_m := public._okuma_anahtar_hatasi(v_x, array['omurga', 'parcalar'], null);
      if v_m is null and jsonb_typeof(v_x -> 'omurga') is distinct from 'boolean' then v_m := 'omurga boolean olmalı'; end if;
      if v_m is null then v_m := public._okuma_parcalar_hatasi(v_x -> 'parcalar'); end if;
      if v_m is not null then v_h := v_h || ('sayfalar[' || v_i || ']: ' || v_m); end if;
    end loop;
  end if;

  -- ---------------- sahneler ----------------
  foreach v_ad in array array['deger_sahneleri', 'hareket_sahneleri'] loop
    if p ? v_ad then
      if jsonb_typeof(p -> v_ad) is distinct from 'object' then
        v_h := v_h || (v_ad || ' nesne olmalı');
      else
        for r in select key as k1, value as v1 from jsonb_each(p -> v_ad) loop
          if jsonb_typeof(r.v1) is distinct from 'object' or not (r.v1 ? '_default') then
            v_h := v_h || (v_ad || '.' || left(r.k1, 40) || ': nesne olmalı ve _default içermeli');
            continue;
          end if;
          for v_kuy, v_y in select key, value from jsonb_each(r.v1) loop
            if v_kuy !~ '^(_default|D([1-9]|1[0-9]|20)|[a-z_]+)$' then
              v_h := v_h || (v_ad || '.' || left(r.k1, 40) || ': geçersiz varyant anahtarı ' || left(v_kuy, 20));
            end if;
            v_m := public._okuma_parcalar_hatasi(v_y);
            if v_m is not null then v_h := v_h || (v_ad || '.' || left(r.k1, 40) || '.' || left(v_kuy, 20) || ': ' || v_m); end if;
          end loop;
        end loop;
      end if;
    end if;
  end loop;

  if p ? 'deyim_cumleleri' then
    if jsonb_typeof(p -> 'deyim_cumleleri') is distinct from 'object' then
      v_h := v_h || 'deyim_cumleleri nesne olmalı'::text;
    else
      for v_kuy, v_y in select key, value from jsonb_each(p -> 'deyim_cumleleri') loop
        v_m := public._okuma_parcalar_hatasi(v_y);
        if v_m is not null then v_h := v_h || ('deyim_cumleleri.' || left(v_kuy, 40) || ': ' || v_m); end if;
      end loop;
    end if;
  end if;

  -- ---------------- sorular ----------------
  if jsonb_typeof(p -> 'sorular') is distinct from 'array'
     or jsonb_array_length(p -> 'sorular') not between 2 and 5 then
    v_h := v_h || 'sorular 2-5 öğeli liste olmalı'::text;
  else
    v_i := 0;
    for v_x in select e from jsonb_array_elements(p -> 'sorular') e loop
      v_i := v_i + 1;
      v_ad := 'sorular[' || v_i || ']';
      v_m := public._okuma_anahtar_hatasi(v_x,
        array['id', 'beceri', 'dayanak_sayfa', 'metin', 'secenekler', 'dogru', 'aciklama'], array['hedef_id', 'olcme_turu']);
      if v_m is not null then v_h := v_h || (v_ad || ': ' || v_m); continue; end if;
      if not public._okuma_js_dizge(v_x -> 'id', '^s[0-9]+$', 2, 8) then
        v_h := v_h || (v_ad || '.id s1, s2 ... biçiminde olmalı');
      elsif (v_x ->> 'id') = any (v_soru_idleri) then
        v_h := v_h || (v_ad || '.id yinelenmiş');
      else
        v_soru_idleri := array_append(v_soru_idleri, v_x ->> 'id');
      end if;
      if not public._okuma_js_enum(v_x -> 'beceri', array['hatirlama', 'cikarim', 'yorumlama', 'degerlendirme', 'sozcuk_baglami']) then
        v_h := v_h || (v_ad || '.beceri geçersiz');
      end if;
      if not public._okuma_js_tam(v_x -> 'dayanak_sayfa', 1, 12) then
        v_h := v_h || (v_ad || '.dayanak_sayfa tam sayı ve ≥ 1 olmalı');
      elsif v_n > 0 and (v_x ->> 'dayanak_sayfa')::integer > v_n then
        v_h := v_h || (v_ad || '.dayanak_sayfa sayfa sayısını aşıyor');
      end if;
      if not public._okuma_js_dizge(v_x -> 'metin', null, 5, 600) then v_h := v_h || (v_ad || '.metin 5-600 karakter olmalı'); end if;
      if not public._okuma_js_dizge(v_x -> 'aciklama', null, 5, 800) then v_h := v_h || (v_ad || '.aciklama 5-800 karakter olmalı'); end if;
      if v_x ? 'olcme_turu' and not public._okuma_js_enum(v_x -> 'olcme_turu', array['metin_kaniti', 'kavram_dogrulugu', 'transfer']) then
        v_h := v_h || (v_ad || '.olcme_turu geçersiz');
      end if;
      if v_x ? 'hedef_id' then
        if not public._okuma_js_dizge(v_x -> 'hedef_id', '^[a-z0-9_]+$', 1, 80) then
          v_h := v_h || (v_ad || '.hedef_id geçersiz');
        elsif not exists (select 1 from unnest(v_hedef_idleri) h2 where split_part(h2, '/', 1) = (v_x ->> 'hedef_id')) then
          v_h := v_h || (v_ad || '.hedef_id etiketlerdeki ogrenme_hedefleri içinde yok');
        end if;
      end if;
      -- seçenekler
      v_secenek_idleri := '{}';
      if jsonb_typeof(v_x -> 'secenekler') is distinct from 'array' or jsonb_array_length(v_x -> 'secenekler') not between 3 and 4 then
        v_h := v_h || (v_ad || '.secenekler 3-4 öğeli liste olmalı');
      else
        for v_y in select e from jsonb_array_elements(v_x -> 'secenekler') e loop
          v_m := public._okuma_anahtar_hatasi(v_y, array['id', 'metin'], null);
          if v_m is null and not public._okuma_js_enum(v_y -> 'id', array['A', 'B', 'C', 'D']) then v_m := 'id A-D olmalı'; end if;
          if v_m is null and not public._okuma_js_dizge(v_y -> 'metin', null, 1, 300) then v_m := 'metin 1-300 karakter olmalı'; end if;
          if v_m is not null then
            v_h := v_h || (v_ad || '.secenekler: ' || v_m);
          elsif (v_y ->> 'id') = any (v_secenek_idleri) then
            v_h := v_h || (v_ad || '.secenekler: yinelenen id ' || (v_y ->> 'id'));
          else
            v_secenek_idleri := array_append(v_secenek_idleri, v_y ->> 'id');
          end if;
        end loop;
      end if;
      if not public._okuma_js_enum(v_x -> 'dogru', array['A', 'B', 'C', 'D']) then
        v_h := v_h || (v_ad || '.dogru A-D olmalı');
      elsif cardinality(v_secenek_idleri) > 0 and (v_x ->> 'dogru') <> all (v_secenek_idleri) then
        v_h := v_h || (v_ad || '.dogru, seçenekler arasında yok');
      end if;
    end loop;
  end if;

  -- ---------------- üretim ----------------
  v_x := p -> 'uretim';
  v_m := public._okuma_anahtar_hatasi(v_x, array['kaynak', 'tarih'], array['model', 'prompt_surumu']);
  if v_m is not null then
    v_h := v_h || ('uretim: ' || v_m);
  else
    if not public._okuma_js_enum(v_x -> 'kaynak', array['elle', 'llm_taslak']) then v_h := v_h || 'uretim.kaynak geçersiz'::text; end if;
    if not public._okuma_js_dizge(v_x -> 'tarih', '^[0-9]{4}-[0-9]{2}-[0-9]{2}$', 10, 10) then
      v_h := v_h || 'uretim.tarih YYYY-AA-GG olmalı'::text;
    else
      begin
        perform (v_x ->> 'tarih')::date;
      exception when others then
        v_h := v_h || 'uretim.tarih geçerli bir tarih değil'::text;
      end;
    end if;
    if v_x ? 'model' and jsonb_typeof(v_x -> 'model') not in ('string', 'null') then v_h := v_h || 'uretim.model metin ya da null olmalı'::text; end if;
    if v_x ? 'prompt_surumu' and jsonb_typeof(v_x -> 'prompt_surumu') not in ('string', 'null') then v_h := v_h || 'uretim.prompt_surumu metin ya da null olmalı'::text; end if;
  end if;

  return to_jsonb(v_h[1:40]);
end;
$$;

revoke execute on function
  public._okuma_js_tam(jsonb, integer, integer), public._okuma_js_dizge(jsonb, text, integer, integer),
  public._okuma_js_enum(jsonb, text[]), public._okuma_js_dizi(jsonb, text[], text, integer, integer, boolean),
  public._okuma_anahtar_hatasi(jsonb, text[], text[]), public._okuma_parca_hatasi(jsonb),
  public._okuma_parcalar_hatasi(jsonb), public._okuma_paket_hatalari(jsonb)
  from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 3. İçe aktarma (kuru çalıştırma destekli)
-- ---------------------------------------------------------------------
create or replace function public.okuma_paket_ice_aktar(p_paket jsonb, p_kuru boolean default true)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := (select auth.uid());
  v_kuru    boolean := coalesce(p_kuru, true);
  v_hatalar jsonb;
  v_uyarilar text[] := '{}';
  v_sha     text;
  v_hik     jsonb;
  v_et      jsonb;
  v_slug    text;
  v_hikaye  uuid;
  v_mevcut  public.okuma_hikaye_surumleri%rowtype;
  v_no      integer;
  v_surum   uuid;
  v_paket_den jsonb;
  v_den     jsonb;
  v_hedef   jsonb;
  v_eski    public.okuma_ogrenme_hedefleri%rowtype;
  v_ozet    jsonb;
begin
  perform public.require_admin();

  v_hatalar := public._okuma_paket_hatalari(p_paket);
  if jsonb_array_length(v_hatalar) > 0 then
    perform public.log_admin_action('okuma_paket_reddedildi', jsonb_build_object(
      'kuru', v_kuru, 'hata_sayisi', jsonb_array_length(v_hatalar)));
    return jsonb_build_object('gecerli', false, 'yazildi', false, 'kuru', v_kuru,
                              'hatalar', v_hatalar, 'uyarilar', '[]'::jsonb);
  end if;

  v_hik := p_paket -> 'hikaye';
  v_et := v_hik -> 'etiketler';
  v_slug := v_hik ->> 'slug';
  -- jsonb metni kanonik sıradadır: aynı içerik her zaman aynı özeti verir
  v_sha := encode(sha256(convert_to(p_paket::text, 'UTF8')), 'hex');

  if v_hik ->> 'durum' <> 'taslak' then
    v_uyarilar := array_append(v_uyarilar, 'hikaye.durum "' || (v_hik ->> 'durum') || '" yok sayıldı; sürüm taslak olarak girer');
  end if;
  v_paket_den := v_et -> 'denetim';
  if v_paket_den ->> 'insan' <> 'pending' then
    v_uyarilar := array_append(v_uyarilar, 'denetim.insan pakette beyan edilmiş; sunucu bunu yok sayar (insan onayı yalnız okuma_surum_durum_degistir ile verilir)');
  end if;

  select id into v_hikaye from public.okuma_hikayeleri where slug = v_slug;
  if v_hikaye is not null then
    select * into v_mevcut from public.okuma_hikaye_surumleri where hikaye_id = v_hikaye and sha256 = v_sha;
    if found then
      perform public.log_admin_action('okuma_paket_tekrar', jsonb_build_object('slug', v_slug, 'surum_id', v_mevcut.id, 'kuru', v_kuru));
      return jsonb_build_object('gecerli', true, 'yazildi', false, 'kuru', v_kuru, 'mevcut', true,
                                'surum_id', v_mevcut.id, 'hikaye_id', v_hikaye, 'surum_no', v_mevcut.surum_no, 'sha256', v_sha,
                                'hatalar', '[]'::jsonb, 'uyarilar', to_jsonb(v_uyarilar));
    end if;
    select coalesce(max(surum_no), 0) + 1 into v_no from public.okuma_hikaye_surumleri where hikaye_id = v_hikaye;
  else
    v_no := 1;
  end if;

  -- Hedef kataloğuyla çakışmalar (uyarı)
  for v_hedef in select e from jsonb_array_elements(v_et -> 'ogrenme_hedefleri') e loop
    select * into v_eski from public.okuma_ogrenme_hedefleri where id = v_hedef ->> 'id';
    if found and (v_eski.tur <> v_hedef ->> 'tur' or v_eski.etiket <> v_hedef ->> 'etiket') then
      v_uyarilar := array_append(v_uyarilar, 'hedef "' || (v_hedef ->> 'id') || '" katalogdakinden farklı tanımlı; katalog değişmedi');
    elsif found and not v_eski.onayli then
      v_uyarilar := array_append(v_uyarilar, 'hedef "' || (v_hedef ->> 'id') || '" henüz onaysız');
    elsif not found then
      v_uyarilar := array_append(v_uyarilar, 'hedef "' || (v_hedef ->> 'id') || '" katalogda yok; onaysız olarak eklenecek');
    end if;
  end loop;

  v_ozet := jsonb_build_object(
    'slug', v_slug, 'baslik', v_hik ->> 'baslik', 'ana_sinif', (v_et ->> 'ana_sinif')::integer,
    'sayfa_sayisi', jsonb_array_length(p_paket -> 'sayfalar'), 'soru_sayisi', jsonb_array_length(p_paket -> 'sorular'),
    'hedef_sayisi', jsonb_array_length(v_et -> 'ogrenme_hedefleri'));

  if v_kuru then
    perform public.log_admin_action('okuma_paket_kuru', jsonb_build_object('slug', v_slug, 'sha256', v_sha, 'surum_no', v_no));
    return jsonb_build_object('gecerli', true, 'yazildi', false, 'kuru', true, 'mevcut', false,
                              'surum_no', v_no, 'sha256', v_sha, 'ozet', v_ozet,
                              'hatalar', '[]'::jsonb, 'uyarilar', to_jsonb(v_uyarilar));
  end if;

  -- ---- Yazma ----
  if v_hikaye is null then
    insert into public.okuma_hikayeleri (slug) values (v_slug) returning id into v_hikaye;
  end if;

  v_den := jsonb_build_object(
    'ajan_a', case when v_paket_den ->> 'ajan_a' in ('pass', 'fail', 'review_needed') then v_paket_den ->> 'ajan_a' else 'pending' end,
    'ajan_b', case when v_paket_den ->> 'ajan_b' in ('pass', 'fail', 'review_needed') then v_paket_den ->> 'ajan_b' else 'pending' end,
    'insan', 'pending');

  insert into public.okuma_hikaye_surumleri (
    hikaye_id, surum_no, durum, icerik, sha256, baslik, tanitim, tur, konu, sinif_alt, sinif_ust, okuma_bandi,
    dunya_tipi, izinli_turler, deger_anahtarlari, yetiskin_uygun, sayfa_sayisi, soru_sayisi,
    olusturan_id, denetim, paket_denetimi)
  values (
    v_hikaye, v_no, 'taslak', p_paket, v_sha, v_hik ->> 'baslik', nullif(v_hik ->> 'tanitim', ''), v_hik ->> 'tur',
    v_hik ->> 'konu', (v_hik ->> 'sinif_alt')::smallint, (v_hik ->> 'sinif_ust')::smallint,
    (v_hik ->> 'okuma_bandi')::smallint, v_hik ->> 'dunya_tipi',
    array(select jsonb_array_elements_text(v_hik -> 'izinli_turler')),
    array(select jsonb_array_elements_text(v_hik -> 'deger_anahtarlari')),
    (v_hik ->> 'yetiskin_uygun')::boolean, jsonb_array_length(p_paket -> 'sayfalar'),
    jsonb_array_length(p_paket -> 'sorular'), v_uid, v_den, v_paket_den)
  returning id into v_surum;

  insert into public.okuma_hikaye_etiketleri (
    surum_id, hikaye_id, ana_sinif, okuma_zorlugu, kavram_zorlugu, ilgi_egilimi, temalar, ders_baglantisi,
    ana_deger, yardimci_deger, cati_degerler, kanit_duzeyi, program_surumu, olculen)
  values (
    v_surum, v_hikaye, (v_et ->> 'ana_sinif')::smallint, (v_et ->> 'okuma_zorlugu')::smallint,
    (v_et ->> 'kavram_zorlugu')::smallint, v_et ->> 'ilgi_egilimi',
    array(select jsonb_array_elements_text(v_et -> 'temalar')),
    array(select jsonb_array_elements_text(v_et -> 'ders_baglantisi')),
    v_et #>> '{maarif,ana_deger}', v_et #>> '{maarif,yardimci_deger}',
    array(select jsonb_array_elements_text(coalesce(v_et #> '{maarif,cati_degerler}', '[]'::jsonb))),
    v_et ->> 'kanit_duzeyi', v_et ->> 'program_surumu', coalesce(v_et -> 'olculen', '{}'::jsonb));

  for v_hedef in select e from jsonb_array_elements(v_et -> 'ogrenme_hedefleri') e loop
    insert into public.okuma_ogrenme_hedefleri (id, tur, etiket, sinif, kanit_duzeyi, onayli, olusturan_id)
    values (v_hedef ->> 'id', v_hedef ->> 'tur', v_hedef ->> 'etiket', (v_et ->> 'ana_sinif')::smallint,
            v_et ->> 'kanit_duzeyi', false, v_uid)
    on conflict (id) do nothing;
    insert into public.okuma_hikaye_hedefleri (surum_id, hedef_id, yuva, islev)
    values (v_surum, v_hedef ->> 'id', v_hedef ->> 'yuva', v_hedef ->> 'islev');
  end loop;

  perform public.log_admin_action('okuma_paket_ice_aktarildi', jsonb_build_object(
    'slug', v_slug, 'surum_id', v_surum, 'surum_no', v_no, 'sha256', v_sha));

  return jsonb_build_object('gecerli', true, 'yazildi', true, 'kuru', false, 'mevcut', false,
                            'surum_id', v_surum, 'hikaye_id', v_hikaye, 'surum_no', v_no, 'sha256', v_sha,
                            'ozet', v_ozet, 'hatalar', '[]'::jsonb, 'uyarilar', to_jsonb(v_uyarilar));
end;
$$;

revoke all on function public.okuma_paket_ice_aktar(jsonb, boolean) from public, anon;
grant execute on function public.okuma_paket_ice_aktar(jsonb, boolean) to authenticated;

-- ---------------------------------------------------------------------
-- 4. Durum geçişi: yayın kapısı + dört göz
--    taslak → incelemede → yayinda → arsiv. Aynı durumda p_denetim ile denetim kaydı güncellenir.
-- ---------------------------------------------------------------------
create or replace function public.okuma_surum_durum_degistir(
  p_surum_id uuid,
  p_durum    text,
  p_denetim  jsonb default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := (select auth.uid());
  v_s     public.okuma_hikaye_surumleri%rowtype;
  v_den   jsonb;
  v_anahtar text;
  v_onceki_yayin uuid;
  v_inceleyen uuid;
begin
  perform public.require_admin();

  if p_durum is null or p_durum not in ('taslak', 'incelemede', 'yayinda', 'arsiv') then
    raise exception 'BAD_DURUM' using errcode = '22023';
  end if;

  select * into v_s from public.okuma_hikaye_surumleri where id = p_surum_id for update;
  if not found then
    raise exception 'SURUM_BULUNAMADI' using errcode = 'P0002';
  end if;

  if not (
       (v_s.durum = 'taslak'     and p_durum in ('taslak', 'incelemede', 'arsiv'))
    or (v_s.durum = 'incelemede' and p_durum in ('incelemede', 'taslak', 'yayinda', 'arsiv'))
    or (v_s.durum = 'yayinda'    and p_durum = 'arsiv')
    or (v_s.durum = 'arsiv'      and p_durum = 'taslak')
  ) then
    raise exception 'GECERSIZ_GECIS' using errcode = '22023';
  end if;

  -- Denetim birleştirme: yalnız tanımlı anahtarlar ve değerler
  v_den := v_s.denetim;
  v_inceleyen := v_s.inceleyen_id;
  if p_denetim is not null then
    if jsonb_typeof(p_denetim) <> 'object' then
      raise exception 'BAD_DENETIM' using errcode = '22023';
    end if;
    if v_s.durum = 'yayinda' then
      raise exception 'SURUM_DEGISMEZ' using errcode = '55000';
    end if;
    for v_anahtar in select jsonb_object_keys(p_denetim) loop
      if v_anahtar not in ('ajan_a', 'ajan_b', 'insan') then
        raise exception 'BAD_DENETIM' using errcode = '22023';
      end if;
    end loop;
    if p_denetim ? 'ajan_a' and (p_denetim ->> 'ajan_a') not in ('pending', 'pass', 'fail', 'review_needed') then
      raise exception 'BAD_DENETIM' using errcode = '22023';
    end if;
    if p_denetim ? 'ajan_b' and (p_denetim ->> 'ajan_b') not in ('pending', 'pass', 'fail', 'review_needed') then
      raise exception 'BAD_DENETIM' using errcode = '22023';
    end if;
    if p_denetim ? 'insan' then
      if (p_denetim ->> 'insan') not in ('pending', 'approved', 'rejected') then
        raise exception 'BAD_DENETIM' using errcode = '22023';
      end if;
      -- İnsan kararı: taslağı oluşturan kendi sürümünü onaylayamaz (dört göz)
      if (p_denetim ->> 'insan') in ('approved', 'rejected') then
        if v_s.olusturan_id is not distinct from v_uid then
          raise exception 'DORT_GOZ' using errcode = '42501';
        end if;
        v_inceleyen := v_uid;
      end if;
    end if;
    v_den := v_den || p_denetim;
  end if;

  if p_durum = 'yayinda' then
    if v_s.olusturan_id is not distinct from v_uid then
      raise exception 'DORT_GOZ' using errcode = '42501';
    end if;
    if v_den ->> 'ajan_a' is distinct from 'pass'
       or v_den ->> 'ajan_b' is distinct from 'pass'
       or v_den ->> 'insan' is distinct from 'approved' then
      raise exception 'YAYIN_KAPISI' using errcode = '22023';
    end if;
    if v_inceleyen is null then v_inceleyen := v_uid; end if;

    -- Hikâye başına tek yayında sürüm: öncekini arşive al
    select id into v_onceki_yayin from public.okuma_hikaye_surumleri
     where hikaye_id = v_s.hikaye_id and durum = 'yayinda' and id <> v_s.id;
    if v_onceki_yayin is not null then
      update public.okuma_hikaye_surumleri set durum = 'arsiv', arsiv_at = now() where id = v_onceki_yayin;
    end if;

    update public.okuma_hikaye_surumleri
       set durum = 'yayinda', denetim = v_den, inceleyen_id = v_inceleyen, yayin_at = now()
     where id = v_s.id;
  elsif p_durum = 'arsiv' then
    update public.okuma_hikaye_surumleri set durum = 'arsiv', arsiv_at = now() where id = v_s.id;
  elsif p_durum = 'taslak' and v_s.durum in ('incelemede', 'arsiv') then
    -- Geri çekilen sürümde insan kararı sıfırlanır; arşivden dönüşte tüm denetim sıfırlanır
    update public.okuma_hikaye_surumleri
       set durum = 'taslak',
           denetim = case when v_s.durum = 'arsiv'
                          then '{"ajan_a":"pending","ajan_b":"pending","insan":"pending"}'::jsonb
                          else v_den || '{"insan":"pending"}'::jsonb end,
           inceleyen_id = null, arsiv_at = null
     where id = v_s.id;
  else
    update public.okuma_hikaye_surumleri
       set durum = p_durum, denetim = v_den, inceleyen_id = v_inceleyen
     where id = v_s.id;
  end if;

  perform public.log_admin_action('okuma_surum_durum', jsonb_build_object(
    'surum_id', p_surum_id, 'onceki', v_s.durum, 'yeni', p_durum, 'denetim_degisti', p_denetim is not null));

  return jsonb_build_object('surum_id', p_surum_id, 'onceki', v_s.durum, 'durum', p_durum,
                            'denetim', (select denetim from public.okuma_hikaye_surumleri where id = p_surum_id));
end;
$$;

revoke all on function public.okuma_surum_durum_degistir(uuid, text, jsonb) from public, anon;
grant execute on function public.okuma_surum_durum_degistir(uuid, text, jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- 5. Yönetim listesi ve içerik önizleme (admin; çocuk verisi yok)
-- ---------------------------------------------------------------------
create or replace function public.okuma_yonetim_liste(
  p_durum    text default null,
  p_ana_sinif integer default null,
  p_limit    integer default 50,
  p_offset   integer default 0
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_limit  integer := least(greatest(coalesce(p_limit, 50), 1), 200);
  v_offset integer := greatest(coalesce(p_offset, 0), 0);
  v_toplam integer;
  v_satirlar jsonb;
begin
  perform public.require_admin();
  if p_durum is not null and p_durum not in ('taslak', 'incelemede', 'yayinda', 'arsiv') then
    raise exception 'BAD_DURUM' using errcode = '22023';
  end if;

  select count(*)::integer into v_toplam
    from public.okuma_hikaye_surumleri s
    join public.okuma_hikaye_etiketleri e on e.surum_id = s.id
   where (p_durum is null or s.durum = p_durum) and (p_ana_sinif is null or e.ana_sinif = p_ana_sinif);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.olusturuldu_at desc), '[]'::jsonb) into v_satirlar
    from (
      select h.id as hikaye_id, h.slug, s.id as surum_id, s.surum_no, s.durum, s.baslik, s.sha256,
             e.ana_sinif, e.okuma_zorlugu, e.kavram_zorlugu, e.temalar, e.ders_baglantisi, e.ana_deger, e.yardimci_deger,
             s.soru_sayisi, s.sayfa_sayisi, s.denetim, s.olusturan_id, s.inceleyen_id,
             s.olusturuldu_at, s.yayin_at,
             (select count(*)::integer from public.okuma_oturumlari o where o.surum_id = s.id) as oturum_sayisi
        from public.okuma_hikaye_surumleri s
        join public.okuma_hikayeleri h on h.id = s.hikaye_id
        join public.okuma_hikaye_etiketleri e on e.surum_id = s.id
       where (p_durum is null or s.durum = p_durum) and (p_ana_sinif is null or e.ana_sinif = p_ana_sinif)
       order by s.olusturuldu_at desc
       limit v_limit offset v_offset
    ) x;

  perform public.log_admin_action('okuma_yonetim_liste', jsonb_build_object('durum', p_durum, 'ana_sinif', p_ana_sinif));
  return jsonb_build_object('toplam', v_toplam, 'satirlar', v_satirlar);
end;
$$;

revoke all on function public.okuma_yonetim_liste(text, integer, integer, integer) from public, anon;
grant execute on function public.okuma_yonetim_liste(text, integer, integer, integer) to authenticated;

-- Yönetici incelemesi: tam paket (soru anahtarı DAHİL). Yalnız admin.
create or replace function public.okuma_surum_icerik_getir(p_surum_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_s public.okuma_hikaye_surumleri%rowtype;
begin
  perform public.require_admin();
  select * into v_s from public.okuma_hikaye_surumleri where id = p_surum_id;
  if not found then
    raise exception 'SURUM_BULUNAMADI' using errcode = 'P0002';
  end if;
  perform public.log_admin_action('okuma_surum_icerik_getir', jsonb_build_object('surum_id', p_surum_id));
  return jsonb_build_object('surum_id', v_s.id, 'hikaye_id', v_s.hikaye_id, 'surum_no', v_s.surum_no, 'durum', v_s.durum,
                            'sha256', v_s.sha256, 'denetim', v_s.denetim, 'paket_denetimi', v_s.paket_denetimi,
                            'olusturan_id', v_s.olusturan_id, 'inceleyen_id', v_s.inceleyen_id, 'paket', v_s.icerik);
end;
$$;

revoke all on function public.okuma_surum_icerik_getir(uuid) from public, anon;
grant execute on function public.okuma_surum_icerik_getir(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- 6. Ayarlar (beyaz liste + doğrulama)
-- ---------------------------------------------------------------------
create or replace function public.okuma_ayarlari_getir()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.require_admin();
  return (select coalesce(jsonb_object_agg(anahtar, deger), '{}'::jsonb) from public.okuma_ayarlari);
end;
$$;

revoke all on function public.okuma_ayarlari_getir() from public, anon;
grant execute on function public.okuma_ayarlari_getir() to authenticated;

create or replace function public.okuma_ayar_yaz(p_anahtar text, p_deger jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_e   jsonb;
  v_diger integer;
begin
  perform public.require_admin();

  if p_anahtar is null or not exists (select 1 from public.okuma_ayarlari where anahtar = p_anahtar) then
    raise exception 'BAD_AYAR_ANAHTARI' using errcode = '22023';
  end if;

  case p_anahtar
    when 'aktif' then
      if jsonb_typeof(p_deger) is distinct from 'boolean' then raise exception 'BAD_AYAR: aktif true|false olmalı' using errcode = '22023'; end if;
    when 'pilot_siniflari' then
      if jsonb_typeof(p_deger) is distinct from 'array' or jsonb_array_length(p_deger) > 8
         or exists (select 1 from jsonb_array_elements(p_deger) e where not public._okuma_js_tam(e, 1, 8)) then
        raise exception 'BAD_AYAR: pilot_siniflari 1-8 arası tam sayı listesi olmalı' using errcode = '22023';
      end if;
    when 'izinli_kullanicilar' then
      if jsonb_typeof(p_deger) is distinct from 'array' or jsonb_array_length(p_deger) > 200 then
        raise exception 'BAD_AYAR: izinli_kullanicilar en çok 200 kimlik listesi olmalı' using errcode = '22023';
      end if;
      for v_e in select e from jsonb_array_elements(p_deger) e loop
        if not public._okuma_js_dizge(v_e, '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', 36, 36)
           or not exists (select 1 from public.profiles p where p.id = (v_e #>> '{}')::uuid) then
          raise exception 'BAD_AYAR: izinli_kullanicilar geçerli profil kimliği olmalı' using errcode = '22023';
        end if;
      end loop;
    when 'okuma_gunluk_hikaye' then
      if not public._okuma_js_tam(p_deger, 0, 50) then raise exception 'BAD_AYAR: 0-50 olmalı' using errcode = '22023'; end if;
    when 'okuma_pdf_aylik_ucretsiz' then
      if not public._okuma_js_tam(p_deger, 0, 100) then raise exception 'BAD_AYAR: 0-100 olmalı' using errcode = '22023'; end if;
    when 'xp_tamamlama', 'xp_dogru_bonus' then
      -- award_xp_and_streak 10/20/30 adımlarıyla çalışır: değer 10'un katı, toplam en çok 30
      if not public._okuma_js_tam(p_deger, 0, 30) or ((p_deger #>> '{}')::integer % 10) <> 0 then
        raise exception 'BAD_AYAR: 0,10,20 veya 30 olmalı' using errcode = '22023';
      end if;
      select (deger #>> '{}')::integer into v_diger from public.okuma_ayarlari
       where anahtar = case p_anahtar when 'xp_tamamlama' then 'xp_dogru_bonus' else 'xp_tamamlama' end;
      if (p_deger #>> '{}')::integer + coalesce(v_diger, 0) > 30 then
        raise exception 'BAD_AYAR: xp_tamamlama + xp_dogru_bonus en çok 30 olabilir' using errcode = '22023';
      end if;
    when 'dogru_orani_esik' then
      if not public._okuma_js_tam(p_deger, 1, 100) then raise exception 'BAD_AYAR: 1-100 olmalı' using errcode = '22023'; end if;
    when 'xp_gunluk_hikaye_tavani' then
      if not public._okuma_js_tam(p_deger, 0, 20) then raise exception 'BAD_AYAR: 0-20 olmalı' using errcode = '22023'; end if;
    when 'min_n' then
      if not public._okuma_js_tam(p_deger, 3, 100) then raise exception 'BAD_AYAR: min_n 3-100 olmalı' using errcode = '22023'; end if;
    when 'saatlik_baslatma_siniri' then
      if not public._okuma_js_tam(p_deger, 1, 200) then raise exception 'BAD_AYAR: 1-200 olmalı' using errcode = '22023'; end if;
    else
      raise exception 'BAD_AYAR_ANAHTARI' using errcode = '22023';
  end case;

  update public.okuma_ayarlari
     set deger = p_deger, guncelleyen_id = v_uid, guncellendi_at = now()
   where anahtar = p_anahtar;

  perform public.log_admin_action('okuma_ayar_yaz', jsonb_build_object('anahtar', p_anahtar, 'deger', p_deger));
  return jsonb_build_object('anahtar', p_anahtar, 'deger', p_deger);
end;
$$;

revoke all on function public.okuma_ayar_yaz(text, jsonb) from public, anon;
grant execute on function public.okuma_ayar_yaz(text, jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- 7. Sözlük ve hedef kataloğu (basit; hedefte dört göz)
-- ---------------------------------------------------------------------
create or replace function public.okuma_sozluk_kaydet(
  p_tur text, p_anahtar text, p_ad text, p_aktif boolean default true)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.require_admin();
  if p_tur not in ('tema', 'ders', 'deger', 'cati_deger') then
    raise exception 'BAD_TUR' using errcode = '22023';
  end if;
  if p_anahtar is null
     or (p_tur = 'deger' and p_anahtar !~ '^D([1-9]|1[0-9]|20)$')
     or (p_tur <> 'deger' and p_anahtar !~ '^[a-z][a-z0-9_]{1,39}$') then
    raise exception 'BAD_ANAHTAR' using errcode = '22023';
  end if;
  if p_ad is null or length(trim(p_ad)) not between 1 and 80 then
    raise exception 'BAD_AD' using errcode = '22023';
  end if;

  insert into public.okuma_etiket_sozlugu (tur, anahtar, ad, aktif)
  values (p_tur, p_anahtar, trim(p_ad), coalesce(p_aktif, true))
  on conflict (tur, anahtar) do update set ad = excluded.ad, aktif = excluded.aktif;

  perform public.log_admin_action('okuma_sozluk_kaydet', jsonb_build_object('tur', p_tur, 'anahtar', p_anahtar, 'aktif', coalesce(p_aktif, true)));
  return jsonb_build_object('tur', p_tur, 'anahtar', p_anahtar, 'ad', trim(p_ad), 'aktif', coalesce(p_aktif, true));
end;
$$;

revoke all on function public.okuma_sozluk_kaydet(text, text, text, boolean) from public, anon;
grant execute on function public.okuma_sozluk_kaydet(text, text, text, boolean) to authenticated;

-- p_onayla = true: hedefi onaylar; onaylayan, hedefi oluşturandan farklı olmalı (dört göz).
-- Onaylı hedefin tanımı (tür/etiket) değişirse onay düşer.
create or replace function public.okuma_hedef_kaydet(
  p_id text, p_tur text, p_etiket text, p_sinif integer default null,
  p_kanit_duzeyi text default 'C', p_onayla boolean default false)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_h   public.okuma_ogrenme_hedefleri%rowtype;
begin
  perform public.require_admin();
  if p_id is null or p_id !~ '^[a-z0-9_]{1,80}$' then
    raise exception 'BAD_ID' using errcode = '22023';
  end if;
  if p_tur is null or p_tur not in ('lexeme', 'idiom', 'proverb', 'homonym', 'concept', 'fact', 'misconception', 'value') then
    raise exception 'BAD_TUR' using errcode = '22023';
  end if;
  if p_etiket is null or length(trim(p_etiket)) not between 2 and 120 then
    raise exception 'BAD_ETIKET' using errcode = '22023';
  end if;
  if p_sinif is not null and p_sinif not between 1 and 8 then
    raise exception 'BAD_SINIF' using errcode = '22023';
  end if;
  if p_kanit_duzeyi is null or p_kanit_duzeyi not in ('A', 'B', 'C', 'D') then
    raise exception 'BAD_KANIT' using errcode = '22023';
  end if;

  select * into v_h from public.okuma_ogrenme_hedefleri where id = p_id for update;
  if not found then
    if coalesce(p_onayla, false) then
      raise exception 'DORT_GOZ' using errcode = '42501';   -- kendi oluşturduğunu onaylayamaz
    end if;
    insert into public.okuma_ogrenme_hedefleri (id, tur, etiket, sinif, kanit_duzeyi, onayli, olusturan_id)
    values (p_id, p_tur, trim(p_etiket), p_sinif::smallint, p_kanit_duzeyi, false, v_uid);
  else
    if coalesce(p_onayla, false) then
      if v_h.olusturan_id is not distinct from v_uid then
        raise exception 'DORT_GOZ' using errcode = '42501';
      end if;
      update public.okuma_ogrenme_hedefleri
         set onayli = true, onaylayan_id = v_uid, onaylandi_at = now()
       where id = p_id;
    else
      update public.okuma_ogrenme_hedefleri
         set tur = p_tur, etiket = trim(p_etiket), sinif = p_sinif::smallint, kanit_duzeyi = p_kanit_duzeyi,
             onayli = case when tur = p_tur and etiket = trim(p_etiket) then onayli else false end,
             onaylayan_id = case when tur = p_tur and etiket = trim(p_etiket) then onaylayan_id else null end,
             onaylandi_at = case when tur = p_tur and etiket = trim(p_etiket) then onaylandi_at else null end
       where id = p_id;
    end if;
  end if;

  perform public.log_admin_action('okuma_hedef_kaydet', jsonb_build_object('id', p_id, 'onayla', coalesce(p_onayla, false)));
  return (select to_jsonb(h) - 'olusturan_id' - 'onaylayan_id' from public.okuma_ogrenme_hedefleri h where h.id = p_id);
end;
$$;

revoke all on function public.okuma_hedef_kaydet(text, text, text, integer, text, boolean) from public, anon;
grant execute on function public.okuma_hedef_kaydet(text, text, text, integer, text, boolean) to authenticated;

-- ---------------------------------------------------------------------
-- 8. İçerik boşluk haritası (sınıf × tema × değer; çocuk verisi yok)
-- ---------------------------------------------------------------------
create or replace function public.okuma_icerik_bosluk_haritasi()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_hucreler jsonb;
begin
  perform public.require_admin();

  select coalesce(jsonb_agg(to_jsonb(x) order by x.ana_sinif, x.tema, x.deger), '[]'::jsonb) into v_hucreler
    from (
      select e.ana_sinif, t.tema, d.deger,
             count(distinct s.hikaye_id) filter (where s.durum = 'yayinda')::integer as yayinda,
             count(distinct s.hikaye_id) filter (where s.durum = 'incelemede')::integer as incelemede
        from public.okuma_hikaye_surumleri s
        join public.okuma_hikaye_etiketleri e on e.surum_id = s.id
        cross join lateral unnest(e.temalar) as t(tema)
        cross join lateral unnest(array_remove(array[e.ana_deger, e.yardimci_deger], null)) as d(deger)
       where s.durum in ('yayinda', 'incelemede')
       group by e.ana_sinif, t.tema, d.deger
    ) x;

  perform public.log_admin_action('okuma_icerik_bosluk_haritasi', '{}'::jsonb);
  return jsonb_build_object(
    'hucreler', v_hucreler,
    'temalar', (select coalesce(jsonb_agg(anahtar order by anahtar), '[]'::jsonb) from public.okuma_etiket_sozlugu where tur = 'tema' and aktif),
    'degerler', (select coalesce(jsonb_agg(anahtar order by length(anahtar), anahtar), '[]'::jsonb) from public.okuma_etiket_sozlugu where tur = 'deger' and aktif),
    'siniflar', '[1,2,3,4,5,6,7,8]'::jsonb);
end;
$$;

revoke all on function public.okuma_icerik_bosluk_haritasi() from public, anon;
grant execute on function public.okuma_icerik_bosluk_haritasi() to authenticated;

-- ---------------------------------------------------------------------
-- 9. Hikâye karnesi (min-N: örnek asgari sayının altındaysa metrikler null, yeterli=false)
-- ---------------------------------------------------------------------
create or replace function public.okuma_hikaye_karnesi(p_hikaye_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_min_n   integer := coalesce((public._okuma_ayar('min_n'))::integer, 5);
  v_hik     public.okuma_hikayeleri%rowtype;
  s         record;
  v_baslatan integer;
  v_tamamlayan integer;
  v_oturum  integer;
  v_tam_oturum integer;
  v_oy      integer;
  v_yeterli boolean;
  v_surumler jsonb := '[]'::jsonb;
  v_ozet    jsonb;
begin
  perform public.require_admin();
  select * into v_hik from public.okuma_hikayeleri where id = p_hikaye_id;
  if not found then
    raise exception 'HIKAYE_BULUNAMADI' using errcode = 'P0002';
  end if;

  for s in select * from public.okuma_hikaye_surumleri where hikaye_id = p_hikaye_id order by surum_no desc loop
    select count(*)::integer, count(distinct ogrenci_id)::integer,
           count(*) filter (where tamamlandi_at is not null)::integer,
           count(distinct ogrenci_id) filter (where tamamlandi_at is not null)::integer
      into v_oturum, v_baslatan, v_tam_oturum, v_tamamlayan
      from public.okuma_oturumlari where surum_id = s.id;
    v_yeterli := v_baslatan >= v_min_n;
    select count(*)::integer into v_oy
      from public.okuma_geri_bildirimleri g join public.okuma_oturumlari o on o.id = g.oturum_id
     where o.surum_id = s.id;

    v_ozet := jsonb_build_object(
      'surum_id', s.id, 'surum_no', s.surum_no, 'durum', s.durum, 'min_n', v_min_n,
      'baslatan_ogrenci', v_baslatan, 'yeterli', v_yeterli);

    if v_yeterli then
      v_ozet := v_ozet || jsonb_build_object(
        'oturum_sayisi', v_oturum,
        'tamamlama_orani', case when v_oturum > 0 then round(100.0 * v_tam_oturum / v_oturum, 1) end,
        'ort_yildiz', case when v_oy >= v_min_n then
            (select round(avg(g.yildiz)::numeric, 2) from public.okuma_geri_bildirimleri g
               join public.okuma_oturumlari o on o.id = g.oturum_id where o.surum_id = s.id) end,
        'oy_sayisi', v_oy,
        'sorun_kodlari', case when v_oy >= v_min_n then
            (select coalesce(jsonb_object_agg(kod, adet), '{}'::jsonb) from (
               select k as kod, count(*)::integer as adet
                 from public.okuma_geri_bildirimleri g join public.okuma_oturumlari o on o.id = g.oturum_id
                 cross join lateral unnest(g.sorun_kodlari) k
                where o.surum_id = s.id group by k) q) end,
        'birakilan_sayfa', (select coalesce(jsonb_object_agg(son_sayfa::text, adet), '{}'::jsonb) from (
             select o.son_sayfa, count(*)::integer as adet from public.okuma_oturumlari o
              where o.surum_id = s.id and o.tamamlandi_at is null and o.baslangic_at < now() - interval '2 hours'
              group by o.son_sayfa) b),
        'sorular', (select coalesce(jsonb_agg(q.satir order by q.soru_id), '[]'::jsonb) from (
             select c.soru_id,
                    case when count(*) >= v_min_n then jsonb_build_object(
                      'soru_id', c.soru_id, 'yeterli', true, 'cevap_sayisi', count(*)::integer,
                      'dogru_orani', round(100.0 * count(*) filter (where c.dogru) / count(*), 1),
                      'secenek_dagilimi', jsonb_build_object(
                        'A', count(*) filter (where c.secenek_id = 'A')::integer,
                        'B', count(*) filter (where c.secenek_id = 'B')::integer,
                        'C', count(*) filter (where c.secenek_id = 'C')::integer,
                        'D', count(*) filter (where c.secenek_id = 'D')::integer))
                    else jsonb_build_object('soru_id', c.soru_id, 'yeterli', false) end as satir
               from public.okuma_cevaplari c join public.okuma_oturumlari o on o.id = c.oturum_id
              where o.surum_id = s.id group by c.soru_id) q));
    end if;
    v_surumler := v_surumler || jsonb_build_array(v_ozet);
  end loop;

  perform public.log_admin_action('okuma_hikaye_karnesi', jsonb_build_object('hikaye_id', p_hikaye_id));
  return jsonb_build_object('hikaye_id', v_hik.id, 'slug', v_hik.slug, 'surumler', v_surumler);
end;
$$;

revoke all on function public.okuma_hikaye_karnesi(uuid) from public, anon;
grant execute on function public.okuma_hikaye_karnesi(uuid) to authenticated;
