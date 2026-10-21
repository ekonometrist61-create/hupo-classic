-- Okuma Dünyası: Düşün alanı (direktör ortak kararı K2 / K6, F3).
-- hikaye.dusun isteğe bağlıdır: en çok 3 kayıt, her biri {id, metin}. Alan yoksa paketler
-- eskisi gibi geçer; mevcut yayınlanmış sürümler değişmez.
-- Yalnız _okuma_paket_hatalari yeniden tanımlanır: 20261050000100 sürümünün birebir kopyası
-- + dusun kontrolü. Kopya, betikle kaynaktan üretildi (elle düzenleme yok).
-- Uzak veritabanına yalnız kullanıcı onayıyla uygulanır.
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
            'izinli_turler', 'deger_anahtarlari', 'yetiskin_uygun', 'durum', 'etiketler'], array['tanitim', 'dusun']);
    if v_m is not null then v_h := v_h || ('hikaye: ' || v_m); end if;

    -- Düşün soruları (isteğe bağlı): en çok 3 kayıt; her biri yalnız id ve metin taşır.
    if v_hik ? 'dusun' then
      if jsonb_typeof(v_hik -> 'dusun') is distinct from 'array' or jsonb_array_length(v_hik -> 'dusun') > 3 then
        v_h := v_h || 'hikaye.dusun en fazla 3 kayıtlı bir dizi olmalı'::text;
      else
        for v_x in select value from jsonb_array_elements(v_hik -> 'dusun') loop
          v_m := public._okuma_anahtar_hatasi(v_x, array['id', 'metin'], null);
          if v_m is not null then v_h := v_h || ('hikaye.dusun: ' || v_m); end if;
          if not public._okuma_js_dizge(v_x -> 'id', '^[a-z0-9_-]+$', 1, 40) then v_h := v_h || 'hikaye.dusun.id geçersiz'::text; end if;
          if not public._okuma_js_dizge(v_x -> 'metin', null, 10, 200) then v_h := v_h || 'hikaye.dusun.metin 10-200 karakter olmalı'::text; end if;
        end loop;
      end if;
    end if;
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
