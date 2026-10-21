-- =====================================================================
-- OKUMA DÜNYASI TEST SENARYOLARI (PGlite harness: kos.mjs)
-- Kapsam: 20261050000000..300 migration'ları
--   yetki matrisi, içe aktarma (gerçek paketler dahil), yayın kapısı + dört göz, değişmezlik,
--   özellik bayrağı / pilot / önizleme, katalog, paket teslimi (anahtar sızıntısı taraması),
--   idempotent oturum, tek denemeli cevap, XP + günlük tavan, hedef durumu, kota (premium / deneme),
--   PDF sayacı, geri bildirim, veli (rıza, min-N), öğretmen (yetki, min-N), karne, harita,
--   serbest metin parametre meta testi, cascade silme, denetim günlüğü.
-- Kalıcı kayıt bırakmaz (PGlite geçici). Her senaryo kendi hatasını yakalar.
-- =====================================================================

set client_encoding = 'UTF8';

create temp table sonuc (no serial primary key, senaryo text, gecti boolean, detay text);

create or replace function pg_temp.k(p_ad text, p_gecti boolean, p_detay text default '')
returns void language plpgsql as $fn$
begin
  insert into pg_temp.sonuc (senaryo, gecti, detay) values (p_ad, coalesce(p_gecti, false), left(coalesce(p_detay, ''), 800));
  raise notice 'K [%] % :: %', case when coalesce(p_gecti, false) then 'OK' else 'FAIL' end, p_ad, left(coalesce(p_detay, ''), 300);
end $fn$;

-- Kullanıcı olarak RPC çağırır (p_uid null => anon). Hata olursa rolü sıfırlayıp yeniden fırlatır.
create or replace function pg_temp.c(p_uid uuid, p_sql text) returns jsonb
language plpgsql as $fn$
declare r jsonb;
begin
  perform set_config('request.jwt.claims', case when p_uid is null then '' else json_build_object('sub', p_uid, 'role', 'authenticated')::text end, false);
  perform set_config('role', case when p_uid is null then 'anon' else 'authenticated' end, false);
  begin
    execute 'select ' || p_sql into r;
  exception when others then
    perform set_config('role', 'none', false);
    perform set_config('request.jwt.claims', '', false);
    raise;
  end;
  perform set_config('role', 'none', false);
  perform set_config('request.jwt.claims', '', false);
  return r;
end $fn$;

-- Hata beklenir: p_kod null ise sqlstate 42501; aksi halde mesaj veya sqlstate p_kod'u içermeli.
create or replace function pg_temp.h(p_uid uuid, p_sql text, p_kod text default null) returns boolean
language plpgsql as $fn$
begin
  perform set_config('request.jwt.claims', case when p_uid is null then '' else json_build_object('sub', p_uid, 'role', 'authenticated')::text end, false);
  perform set_config('role', case when p_uid is null then 'anon' else 'authenticated' end, false);
  begin
    execute 'select ' || p_sql;
  exception when others then
    perform set_config('role', 'none', false);
    perform set_config('request.jwt.claims', '', false);
    perform set_config('okuma.son_hata', sqlstate || ' ' || sqlerrm, false);
    if p_kod is null then return sqlstate = '42501'; end if;
    return sqlerrm like '%' || p_kod || '%' or sqlstate = p_kod;
  end;
  perform set_config('role', 'none', false);
  perform set_config('request.jwt.claims', '', false);
  perform set_config('okuma.son_hata', 'HATA YOK', false);
  return false;
end $fn$;

create or replace function pg_temp.son_hata() returns text language sql as $$ select current_setting('okuma.son_hata', true) $$;

-- jsonb içinde (iç içe) anahtar var mı
create or replace function pg_temp.anahtar_var(j jsonb, k text) returns boolean
language plpgsql as $fn$
declare e jsonb;
begin
  if jsonb_typeof(j) = 'object' then
    if j ? k then return true; end if;
    for e in select value from jsonb_each(j) loop
      if pg_temp.anahtar_var(e, k) then return true; end if;
    end loop;
  elsif jsonb_typeof(j) = 'array' then
    for e in select value from jsonb_array_elements(j) loop
      if pg_temp.anahtar_var(e, k) then return true; end if;
    end loop;
  end if;
  return false;
end $fn$;

-- Küçük, geçerli paket üretici
create or replace function pg_temp.paket(
  p_slug text, p_sinif int default 4, p_tema text default 'gizem', p_deger text default 'D6',
  p_yard text default null, p_pre text default null, p_turler jsonb default '["ben","anne","hayvan"]'::jsonb)
returns jsonb language sql as $fn$
  select jsonb_build_object(
    'paket_surumu', 1,
    'hikaye', jsonb_build_object(
      'slug', p_slug, 'baslik', 'Deneme ' || p_slug, 'tur', 'gizem', 'konu', 'kutuphane',
      'sinif_alt', p_sinif, 'sinif_ust', p_sinif, 'okuma_bandi', 2, 'dunya_tipi', 'gercekci',
      'izinli_turler', p_turler,
      'deger_anahtarlari', case when p_yard is null then jsonb_build_array(p_deger) else jsonb_build_array(p_deger, p_yard) end,
      'yetiskin_uygun', true, 'durum', 'taslak', 'tanitim', 'Kısa tanıtım ' || p_slug,
      'etiketler', jsonb_build_object(
        'ana_sinif', p_sinif, 'okuma_zorlugu', 2, 'kavram_zorlugu', 1, 'ilgi_egilimi', 'ortak',
        'temalar', jsonb_build_array(p_tema), 'ders_baglantisi', jsonb_build_array('turkce'),
        'maarif', case when p_yard is null then jsonb_build_object('ana_deger', p_deger)
                       else jsonb_build_object('ana_deger', p_deger, 'yardimci_deger', p_yard) end,
        'ogrenme_hedefleri', jsonb_build_array(
          jsonb_build_object('id', 'ha_' || coalesce(p_pre, replace(p_slug, '-', '_')), 'tur', 'lexeme', 'etiket', 'gizemli', 'yuva', 'gizemli_sifat', 'islev', 'first_hint'),
          jsonb_build_object('id', 'hb_' || coalesce(p_pre, replace(p_slug, '-', '_')), 'tur', 'idiom', 'etiket', 'el ele vermek', 'yuva', 'el_ele', 'islev', 'application')),
        'kanit_duzeyi', 'C', 'program_surumu', 'TYMM test sürümü',
        'denetim', jsonb_build_object('ajan_a', 'pending', 'ajan_b', 'pending', 'insan', 'pending'),
        'olculen', jsonb_build_object('kelime_sayisi', 300, 'tahmini_sure_dk', 3))),
    'sayfalar', jsonb_build_array(
      jsonb_build_object('omurga', true, 'parcalar', jsonb_build_array(jsonb_build_object('t', 'metin', 'v', 'Bir gün '), jsonb_build_object('t', 'kahraman', 'hal', 'yalin'), jsonb_build_object('t', 'metin', 'v', ' bir şey buldu.'))),
      jsonb_build_object('omurga', true, 'parcalar', jsonb_build_array(jsonb_build_object('t', 'metin', 'v', 'Sonra gizemli bir kapı gördü.'))),
      jsonb_build_object('omurga', false, 'parcalar', jsonb_build_array(jsonb_build_object('t', 'metin', 'v', 'Kapıyı '), jsonb_build_object('t', 'vurgu', 'v', 'dikkatle'), jsonb_build_object('t', 'metin', 'v', ' açtı.')))),
    'sorular', jsonb_build_array(
      jsonb_build_object('id', 's1', 'beceri', 'hatirlama', 'dayanak_sayfa', 1, 'metin', 'Kahraman ne buldu?', 'hedef_id', 'ha_' || coalesce(p_pre, replace(p_slug, '-', '_')),
        'secenekler', jsonb_build_array(jsonb_build_object('id', 'A', 'metin', 'Şık A'), jsonb_build_object('id', 'B', 'metin', 'Şık B'), jsonb_build_object('id', 'C', 'metin', 'Şık C'), jsonb_build_object('id', 'D', 'metin', 'Şık D')),
        'dogru', 'B', 'aciklama', 'GIZLI_ACIKLAMA_1_' || p_slug),
      jsonb_build_object('id', 's2', 'beceri', 'cikarim', 'dayanak_sayfa', 2, 'metin', 'Kapı neden gizemliydi?', 'hedef_id', 'hb_' || coalesce(p_pre, replace(p_slug, '-', '_')), 'olcme_turu', 'transfer',
        'secenekler', jsonb_build_array(jsonb_build_object('id', 'A', 'metin', 'Birinci'), jsonb_build_object('id', 'B', 'metin', 'İkinci'), jsonb_build_object('id', 'C', 'metin', 'Üçüncü')),
        'dogru', 'C', 'aciklama', 'GIZLI_ACIKLAMA_2_' || p_slug),
      jsonb_build_object('id', 's3', 'beceri', 'yorumlama', 'dayanak_sayfa', 3, 'metin', 'Hikayenin ana fikri nedir?',
        'secenekler', jsonb_build_array(jsonb_build_object('id', 'A', 'metin', 'Merak'), jsonb_build_object('id', 'B', 'metin', 'Korku'), jsonb_build_object('id', 'C', 'metin', 'Sıkıntı')),
        'dogru', 'A', 'aciklama', 'GIZLI_ACIKLAMA_3_' || p_slug)),
    'uretim', jsonb_build_object('kaynak', 'elle', 'tarih', '2026-10-18'));
$fn$;

-- İçe aktar (taslak) ve yayına al (adm1 oluşturur, adm2 onaylar/yayınlar); sürüm id'sini döner
create or replace function pg_temp.ice(p_adm uuid, p_paket jsonb) returns jsonb
language plpgsql as $fn$
begin
  return pg_temp.c(p_adm, format('public.okuma_paket_ice_aktar(%L::jsonb, false)', p_paket));
end $fn$;

create or replace function pg_temp.incele(p_adm1 uuid, p_adm2 uuid, p_sid uuid) returns void
language plpgsql as $fn$
begin
  perform pg_temp.c(p_adm1, format('public.okuma_surum_durum_degistir(%L, %L, null)', p_sid, 'incelemede'));
  perform pg_temp.c(p_adm2, format('public.okuma_surum_durum_degistir(%L, %L, %L::jsonb)', p_sid, 'incelemede',
    '{"ajan_a":"pass","ajan_b":"pass","insan":"approved"}'));
end $fn$;

create or replace function pg_temp.yayinla(p_adm1 uuid, p_adm2 uuid, p_paket jsonb) returns jsonb
language plpgsql as $fn$
declare r jsonb;
begin
  r := pg_temp.ice(p_adm1, p_paket);
  perform pg_temp.incele(p_adm1, p_adm2, (r ->> 'surum_id')::uuid);
  perform pg_temp.c(p_adm2, format('public.okuma_surum_durum_degistir(%L, %L, null)', r ->> 'surum_id', 'yayinda'));
  return r;
end $fn$;

-- Sözlük içe aktarma yükü (dört göz ve sınıf süzmesi senaryoları için)
create or replace function pg_temp.soz(p_d1 text default 'taslak', p_a1 text default 'Ne olduğu anlaşılamayan, sır taşıyan.',
  p_d2 text default 'taslak', p_kav jsonb default '[]'::jsonb) returns jsonb
language sql as $fn$
  select jsonb_build_object('sozluk_surumu', 1,
    'girdiler', jsonb_build_array(
      jsonb_build_object('id', 't_gizemli', 'tur', 'kelime', 'yazim', 'gizemli', 'anlam', p_a1, 'sinif_alt', 4, 'sinif_ust', 5,
        'kaynak_turu', 'editor_onerisi', 'kazanim_kodu', null, 'durum', p_d1),
      jsonb_build_object('id', 't_tuhaf', 'tur', 'kelime', 'yazim', 'tuhaf', 'anlam', 'Alışılmadık, insanı şaşırtan.', 'sinif_alt', 4, 'sinif_ust', 5,
        'kaynak_turu', 'editor_onerisi', 'kazanim_kodu', null, 'durum', 'taslak'),
      jsonb_build_object('id', 't_dar', 'tur', 'kelime', 'yazim', 'küçük', 'anlam', 'Boyutu az olan şey.', 'sinif_alt', 1, 'sinif_ust', 2,
        'kaynak_turu', 'meb_kaynakli', 'kazanim_kodu', 'T.1.3.4', 'durum', p_d2),
      jsonb_build_object('id', 't_elele', 'tur', 'deyim', 'yazim', 'el ele vermek', 'anlam', 'Birlikte çalışmak, yardımlaşmak.', 'sinif_alt', 4, 'sinif_ust', 5,
        'kaynak_turu', 'editor_onerisi', 'kazanim_kodu', null, 'durum', 'taslak')),
    'yuvalar', jsonb_build_array(
      jsonb_build_object('ad', 'gizemli_sifat', 'tur', 'kelime', 'adaylar',
        jsonb_build_array(jsonb_build_object('girdi', 't_gizemli'), jsonb_build_object('girdi', 't_tuhaf'), jsonb_build_object('girdi', 't_dar'))),
      jsonb_build_object('ad', 'el_ele', 'tur', 'deyim', 'adaylar', jsonb_build_array(jsonb_build_object('girdi', 't_elele')))),
    'kavramlar', p_kav);
$fn$;
create or replace function pg_temp.okuma_testleri()
returns table (no integer, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  adm1 uuid := '00000000-0000-4000-8000-00000000a001';
  adm2 uuid := '00000000-0000-4000-8000-00000000a002';
  oa   uuid := '00000000-0000-4000-8000-00000000b001';  -- sınıf 4, veli v1
  ob   uuid := '00000000-0000-4000-8000-00000000b002';  -- sınıf 4, veli v2
  oc   uuid := '00000000-0000-4000-8000-00000000b003';  -- sınıf 5, velisiz
  od   uuid := '00000000-0000-4000-8000-00000000b004';  -- sınıf 4, velisiz (ücretsiz)
  oe   uuid := '00000000-0000-4000-8000-00000000b005';  -- sınıf 4, veli v3 (premium)
  off  uuid := '00000000-0000-4000-8000-00000000b006';  -- sınıf 4, veli v4 (deneme)
  v1   uuid := '00000000-0000-4000-8000-00000000c001';
  v2   uuid := '00000000-0000-4000-8000-00000000c002';
  v3   uuid := '00000000-0000-4000-8000-00000000c003';
  v4   uuid := '00000000-0000-4000-8000-00000000c004';
  t1   uuid := '00000000-0000-4000-8000-00000000d001';
  t2   uuid := '00000000-0000-4000-8000-00000000d002';
  k1   uuid := '00000000-0000-4000-8000-00000000e001';  -- t1 sınıfı: oa,ob,oc,od,oe
  k2   uuid := '00000000-0000-4000-8000-00000000e002';  -- t2 sınıfı: boş
  k3   uuid := '00000000-0000-4000-8000-00000000e003';  -- t1 sınıfı: yalnız ob, oc (2 öğrenci)
  rastgele uuid := '00000000-0000-4000-8000-0000000000ff';

  r jsonb; r2 jsonb; r3 jsonb; kd jsonb; bozuk jsonb; ex jsonb; ex2 jsonb;
  n integer; n2 integer; t text; ok boolean;
  s1 uuid; s2 uuid; s3 uuid; s4 uuid; s5 uuid; sk uuid;      -- sürüm kimlikleri
  h1 uuid; h2 uuid; h3 uuid; h4 uuid; h5 uuid; hk uuid;      -- hikâye kimlikleri
  o1 uuid; o2 uuid; o3 uuid; o4 uuid;                         -- oturumlar
  cagri_once integer;
  hatalar text := '';
  rec record;
  prm record;
begin
  -- =================================================================
  -- KURULUM (süper kullanıcı)
  -- =================================================================
  insert into auth.users (id, email) select x, x::text || '@example.test' from unnest(array[adm1, adm2, oa, ob, oc, od, oe, off, v1, v2, v3, v4, t1, t2]) x;
  insert into public.profiles (id, role, full_name, sinif, parent_id) values
    (adm1, 'admin', 'Yonetici Bir', null, null), (adm2, 'admin', 'Yonetici Iki', null, null),
    (v1, 'veli', 'Veli Bir', null, null), (v2, 'veli', 'Veli Iki', null, null),
    (v3, 'veli', 'Veli Uc', null, null), (v4, 'veli', 'Veli Dort', null, null),
    (t1, 'ogretmen', 'Ogretmen Bir', null, null), (t2, 'ogretmen', 'Ogretmen Iki', null, null);
  insert into public.profiles (id, role, full_name, sinif, parent_id) values
    (oa, 'ogrenci', 'ZXQ_AYLIN_ADI', 4, v1), (ob, 'ogrenci', 'ZXQ_BORA_ADI', 4, v2),
    (oc, 'ogrenci', 'ZXQ_CEREN_ADI', 5, null), (od, 'ogrenci', 'ZXQ_DENIZ_ADI', 4, null),
    (oe, 'ogrenci', 'ZXQ_EFE_ADI', 4, v3), (off, 'ogrenci', 'ZXQ_FIDAN_ADI', 4, v4);
  insert into public.siniflar (id, ad, sinif_seviyesi, ogretmen_id) values
    (k1, 'Sinif Bir', 4, t1), (k2, 'Sinif Iki', 5, t2), (k3, 'Sinif Uc', 4, t1);
  insert into public.sinif_uyelikleri (sinif_id, ogrenci_id) values
    (k1, oa), (k1, ob), (k1, oc), (k1, od), (k1, oe), (k3, ob), (k3, oc);

  -- =================================================================
  -- A. GÜVENLİK YÜZEYİ (yetki, RLS, envanter)
  -- =================================================================
  select count(*) into n from pg_proc p join pg_namespace ns on ns.oid = p.pronamespace
   where ns.nspname = 'public' and p.proname like '%okuma\_%' and has_function_privilege('anon', p.oid, 'execute');
  perform pg_temp.k('anon hiçbir okuma_* / _okuma_* fonksiyonunu çalıştıramaz', n = 0, 'anon çalıştırabilen: ' || n);

  select count(*) into n from pg_proc p join pg_namespace ns on ns.oid = p.pronamespace
   where ns.nspname = 'public' and p.proname like '\_okuma\_%' and has_function_privilege('authenticated', p.oid, 'execute');
  perform pg_temp.k('iç yardımcılar (_okuma_*) authenticated için de kapalı', n = 0, 'açık: ' || n);

  select string_agg(p.proname, ',' order by p.proname) into t from pg_proc p join pg_namespace ns on ns.oid = p.pronamespace
   where ns.nspname = 'public' and p.proname like 'okuma\_%' and not has_function_privilege('authenticated', p.oid, 'execute');
  -- Envanter kilidi: yeni okuma_* RPC eklenince sayı bilinçli olarak güncellenir.
  -- 27 = önceki RPC'ler; +2 = okuma_fis_ice_aktar, okuma_fis_listele (20261057000000).
  perform pg_temp.k('29 RPC authenticated için açık (envanter)',
    t is null and (select count(*) from pg_proc p join pg_namespace ns on ns.oid = p.pronamespace
                    where ns.nspname = 'public' and p.proname like 'okuma\_%') = 29,
    coalesce(t, 'kapalı yok') || ' / toplam ' || (select count(*) from pg_proc p join pg_namespace ns on ns.oid = p.pronamespace where ns.nspname = 'public' and p.proname like 'okuma\_%'));

  select string_agg(c.relname, ',') into t from pg_class c join pg_namespace ns on ns.oid = c.relnamespace
   where ns.nspname = 'public' and c.relname like 'okuma\_%' and c.relkind = 'r'
     and (has_table_privilege('anon', c.oid, 'select,insert,update,delete')
          or has_table_privilege('authenticated', c.oid, 'select')
          or has_table_privilege('authenticated', c.oid, 'insert')
          or has_table_privilege('authenticated', c.oid, 'update')
          or has_table_privilege('authenticated', c.oid, 'delete'));
  perform pg_temp.k('okuma_* tablolarında anon/authenticated doğrudan erişimi yok', t is null, coalesce(t, ''));

  select string_agg(c.relname, ',') into t from pg_class c join pg_namespace ns on ns.oid = c.relnamespace
   where ns.nspname = 'public' and c.relname like 'okuma\_%' and c.relkind = 'r' and not c.relrowsecurity;
  perform pg_temp.k('okuma_* tablolarının hepsinde RLS açık', t is null, coalesce(t, ''));

  ok := pg_temp.h(oa, 'count(*) from public.okuma_hikaye_surumleri', 'permission denied')
    and pg_temp.h(oa, 'count(*) from public.okuma_oturumlari', 'permission denied')
    and pg_temp.h(null, 'count(*) from public.okuma_hikayeleri', 'permission denied');
  perform pg_temp.k('doğrudan tablo okuması reddedilir (öğrenci ve anon)', ok, pg_temp.son_hata());

  -- rol x RPC matrisi: yanlış roller 42501 alır
  for rec in
    select * from (values
      ('ogr', 'public.okuma_ozellik_durumu()'),
      ('ogr', format('public.okuma_katalog_filtre(null,null,null,null,1,5,null,24)')),
      ('ogr', format('public.okuma_hikaye_getir(%L)', rastgele)),
      ('ogr', format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', rastgele, 'ben', 'zengin', 'anahtar-0001')),
      ('ogr', format('public.okuma_ilerleme_kaydet(%L,1)', rastgele)),
      ('ogr', format('public.okuma_cevap_kontrol(%L,%L,%L)', rastgele, 's1', 'A')),
      ('ogr', format('public.okuma_oturum_bitir(%L,%L::text[])', rastgele, '{}')),
      ('ogr', format('public.okuma_geri_bildirim_gonder(%L,3,%L::text[],false,false,%L::text[])', rastgele, '{}', '{}')),
      ('ogr', 'public.okuma_seri_ve_oneri()')
    ) as m(rol, sql)
  loop
    -- veli, öğretmen ve anon reddedilir
    if not (pg_temp.h(v1, rec.sql, 'STUDENT_ONLY') and pg_temp.h(t1, rec.sql, 'STUDENT_ONLY') and pg_temp.h(null, rec.sql)) then
      hatalar := hatalar || rec.sql || ' => ' || pg_temp.son_hata() || E'\n';
    end if;
  end loop;
  perform pg_temp.k('öğrenci RPC''leri veli/öğretmen/anon için reddedilir', hatalar = '', hatalar);

  hatalar := '';
  for rec in
    select * from (values
      (format('public.okuma_paket_ice_aktar(%L::jsonb, true)', '{}')),
      (format('public.okuma_surum_durum_degistir(%L,%L,null)', rastgele, 'incelemede')),
      ('public.okuma_yonetim_liste(null,null,10,0)'),
      (format('public.okuma_surum_icerik_getir(%L)', rastgele)),
      ('public.okuma_ayarlari_getir()'),
      (format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'aktif', 'true')),
      (format('public.okuma_sozluk_kaydet(%L,%L,%L,true)', 'tema', 'deneme_tema', 'Deneme')),
      (format('public.okuma_hedef_kaydet(%L,%L,%L,4,%L,false)', 'h_deneme', 'lexeme', 'deneme', 'C')),
      ('public.okuma_icerik_bosluk_haritasi()'),
      (format('public.okuma_hikaye_karnesi(%L)', rastgele))
    ) as m(sql)
  loop
    if not (pg_temp.h(oa, rec.sql) and pg_temp.h(v1, rec.sql) and pg_temp.h(t1, rec.sql) and pg_temp.h(null, rec.sql)) then
      hatalar := hatalar || rec.sql || ' => ' || pg_temp.son_hata() || E'\n';
    end if;
  end loop;
  perform pg_temp.k('yönetim RPC''leri öğrenci/veli/öğretmen/anon için reddedilir (42501)', hatalar = '', hatalar);

  hatalar := '';
  for rec in
    select * from (values
      ('public.okuma_degerleri_listele()'),
      (format('public.okuma_veli_degerleri_getir(%L)', oa)),
      (format('public.okuma_veli_degerleri_ayarla(%L,%L::text[])', oa, '{D1}')),
      (format('public.okuma_veli_ozeti(%L,30)', oa)),
      (format('public.okuma_ogretmen_sinif_ozeti(%L,30)', k1))
    ) as m(sql)
  loop
    if not (pg_temp.h(oa, rec.sql) and pg_temp.h(null, rec.sql)) then
      hatalar := hatalar || rec.sql || ' => ' || pg_temp.son_hata() || E'\n';
    end if;
  end loop;
  perform pg_temp.k('veli/öğretmen RPC''leri öğrenci ve anon için reddedilir', hatalar = '', hatalar);

  -- =================================================================
  -- B. İÇE AKTARMA (gerçek paket: kayip-defter)
  -- =================================================================
  select icerik into kd from public.test_paketler where ad = 'kayip-defter';
  perform pg_temp.k('test paketi yüklü (kayip-defter)', kd is not null, 'paket yok');

  r := pg_temp.c(adm1, format('public.okuma_paket_ice_aktar(%L::jsonb, true)', kd));
  select count(*) into n from public.okuma_hikaye_surumleri;
  perform pg_temp.k('kayip-defter kuru çalıştırma: geçerli, yazılmadı',
    (r ->> 'gecerli')::boolean and not (r ->> 'yazildi')::boolean and n = 0 and length(r ->> 'sha256') = 64,
    r::text);

  r := pg_temp.ice(adm1, kd);
  s1 := (r ->> 'surum_id')::uuid;
  select count(*) into n from public.okuma_hikaye_surumleri where id = s1 and durum = 'taslak' and denetim ->> 'insan' = 'pending' and olusturan_id = adm1;
  select count(*) into n2 from public.okuma_hikaye_etiketleri where surum_id = s1 and ana_sinif = 4 and ana_deger = 'D20' and yardimci_deger = 'D6';
  perform pg_temp.k('kayip-defter gerçek yazım: taslak sürüm + etiketler',
    (r ->> 'yazildi')::boolean and n = 1 and n2 = 1 and (r ->> 'surum_no')::int = 1, r::text);

  select count(*) into n from public.okuma_hikaye_hedefleri where surum_id = s1;
  select count(*) into n2 from public.okuma_ogrenme_hedefleri where olusturan_id = adm1 and not onayli;
  perform pg_temp.k('hedefler katalogda onaysız oluşturulur ve sürüme bağlanır', n = 4 and n2 = 4, n || '/' || n2);

  r2 := pg_temp.ice(adm1, kd);
  select count(*) into n from public.okuma_hikaye_surumleri;
  perform pg_temp.k('aynı paket tekrar: mevcut (yinelenen sürüm yok)', (r2 ->> 'mevcut')::boolean and not (r2 ->> 'yazildi')::boolean and n = 1, r2::text);

  r2 := pg_temp.ice(adm1, jsonb_set(kd, '{hikaye,baslik}', '"Kayıp Defter (düzeltildi)"'));
  perform pg_temp.k('değişen paket: yeni sürüm numarası, eski değişmedi', (r2 ->> 'surum_no')::int = 2 and (r2 ->> 'yazildi')::boolean, r2::text);

  r2 := pg_temp.ice(adm1, jsonb_set(jsonb_set(kd, '{hikaye,slug}', '"kayip-defter-onayli"'), '{hikaye,etiketler,denetim,insan}', '"approved"'));
  select denetim ->> 'insan' into t from public.okuma_hikaye_surumleri where id = (r2 ->> 'surum_id')::uuid;
  perform pg_temp.k('pakette beyan edilen insan onayı yok sayılır (pending) ve uyarı verilir',
    t = 'pending' and r2::text like '%insan pakette beyan%', t || ' ' || (r2 -> 'uyarilar')::text);

  -- bilinçli bozuk paketler
  select count(*) into n from public.okuma_hikaye_surumleri;
  hatalar := '';
  for rec in
    select * from (values
      ('doğru alanı eksik', kd #- '{sorular,0,dogru}', 'eksik alan'),
      ('slug büyük harf', jsonb_set(kd, '{hikaye,slug}', '"Kayip Defter"'), 'slug'),
      ('üst düzey fazla alan', kd || '{"ekstra":1}'::jsonb, 'tanımsız alan'),
      ('sözlükte olmayan tema', jsonb_set(kd, '{hikaye,etiketler,temalar}', '["uzay"]'), 'temalar'),
      ('ana_deger deger_anahtarlari dışında', jsonb_set(kd, '{hikaye,etiketler,maarif,ana_deger}', '"D3"'), 'deger_anahtarlari içinde'),
      ('geçersiz doğru şık', jsonb_set(kd, '{sorular,0,dogru}', '"E"'), 'dogru'),
      ('iki sayfa', jsonb_set(kd, '{sayfalar}', (kd -> 'sayfalar') - 0 - 0 - 0 - 0 - 0 - 0), 'sayfalar'),
      ('hedef_id katalogda yok', jsonb_set(kd, '{sorular,0,hedef_id}', '"yok_boyle_hedef"'), 'hedef_id'),
      ('bilinmeyen parça türü', jsonb_set(kd, '{sayfalar,0,parcalar,0}', '{"t":"ses","v":"x"}'), 'bilinmeyen parça'),
      ('ana_sinif aralık dışı', jsonb_set(kd, '{hikaye,etiketler,ana_sinif}', '7'), 'ana_sinif'),
      ('dizi olması gereken paket', '[]'::jsonb, 'paket bir nesne'),
      ('boş paket (null)', null, 'paket bir nesne'),
      ('denetim değeri geçersiz', jsonb_set(kd, '{hikaye,etiketler,denetim,ajan_a}', '"belki"'), 'denetim')
    ) as m(ad, paket, beklenen)
  loop
    r := pg_temp.c(adm1, format('public.okuma_paket_ice_aktar(%L::jsonb, false)', rec.paket));
    if (r ->> 'gecerli')::boolean or (r ->> 'yazildi')::boolean or (r -> 'hatalar')::text not like '%' || rec.beklenen || '%' then
      hatalar := hatalar || rec.ad || ' => ' || left(r::text, 200) || E'\n';
    end if;
  end loop;
  select count(*) into n2 from public.okuma_hikaye_surumleri;
  perform pg_temp.k('bozuk paketler reddedilir ve hiçbir şey yazılmaz', hatalar = '' and n = n2, hatalar || ' sürüm ' || n || '->' || n2);

  -- 29 gerçek paketin hepsi doğrulayıcıdan geçer (kuru)
  n := 0; n2 := 0; hatalar := '';
  for rec in select ad, icerik from public.test_paketler order by ad loop
    r := pg_temp.c(adm1, format('public.okuma_paket_ice_aktar(%L::jsonb, true)', rec.icerik));
    n2 := n2 + 1;
    if (r ->> 'gecerli')::boolean then n := n + 1;
    else hatalar := hatalar || rec.ad || ': ' || left((r -> 'hatalar')::text, 160) || E'\n'; end if;
  end loop;
  perform pg_temp.k('atölyedeki tüm gerçek paketler doğrulayıcıdan geçer (' || n || '/' || n2 || ')', n = n2 and n2 > 0, hatalar);

  -- sözlük düzenlemesi doğrulayıcıyı etkiler
  r := pg_temp.c(adm1, format('public.okuma_paket_ice_aktar(%L::jsonb, true)', jsonb_set(kd, '{hikaye,etiketler,temalar}', '["uzay"]')));
  perform pg_temp.c(adm1, format('public.okuma_sozluk_kaydet(%L,%L,%L,true)', 'tema', 'uzay', 'Uzay ve gökyüzü'));
  r2 := pg_temp.c(adm1, format('public.okuma_paket_ice_aktar(%L::jsonb, true)', jsonb_set(kd, '{hikaye,etiketler,temalar}', '["uzay"]')));
  perform pg_temp.k('okuma_sozluk_kaydet: yeni tema sonrası paket geçerli olur', not (r ->> 'gecerli')::boolean and (r2 ->> 'gecerli')::boolean, r2::text);
  perform pg_temp.c(adm1, format('public.okuma_sozluk_kaydet(%L,%L,%L,false)', 'tema', 'uzay', 'Uzay ve gökyüzü'));
  perform pg_temp.k('sözlük kaydı pasife alınınca tema tekrar reddedilir',
    not (pg_temp.c(adm1, format('public.okuma_paket_ice_aktar(%L::jsonb, true)', jsonb_set(kd, '{hikaye,etiketler,temalar}', '["uzay"]'))) ->> 'gecerli')::boolean, '');
  perform pg_temp.k('sözlük: geçersiz anahtar / tür reddedilir',
    pg_temp.h(adm1, format('public.okuma_sozluk_kaydet(%L,%L,%L,true)', 'deger', 'D99', 'x'), 'BAD_ANAHTAR')
    and pg_temp.h(adm1, format('public.okuma_sozluk_kaydet(%L,%L,%L,true)', 'renk', 'kirmizi', 'x'), 'BAD_TUR'), pg_temp.son_hata());

  -- =================================================================
  -- C. YAYIN KAPISI, DÖRT GÖZ, DEĞİŞMEZLİK
  -- =================================================================
  r := pg_temp.ice(adm1, pg_temp.paket('kapi-deneme', 4, 'gizem', 'D6', null, 'kapi'));
  sk := (r ->> 'surum_id')::uuid; hk := (r ->> 'hikaye_id')::uuid;
  perform pg_temp.k('taslak doğrudan yayına geçemez', pg_temp.h(adm2, format('public.okuma_surum_durum_degistir(%L,%L,null)', sk, 'yayinda'), 'GECERSIZ_GECIS'), pg_temp.son_hata());
  perform pg_temp.c(adm1, format('public.okuma_surum_durum_degistir(%L,%L,null)', sk, 'incelemede'));
  perform pg_temp.k('denetim eksik: incelemedeki sürüm yayına geçemez (YAYIN_KAPISI)',
    pg_temp.h(adm2, format('public.okuma_surum_durum_degistir(%L,%L,null)', sk, 'yayinda'), 'YAYIN_KAPISI'), pg_temp.son_hata());
  perform pg_temp.k('oluşturan kendi sürümünü insan olarak onaylayamaz (DORT_GOZ)',
    pg_temp.h(adm1, format('public.okuma_surum_durum_degistir(%L,%L,%L::jsonb)', sk, 'incelemede', '{"insan":"approved"}'), 'DORT_GOZ'), pg_temp.son_hata());
  perform pg_temp.k('geçersiz denetim değeri / anahtarı reddedilir',
    pg_temp.h(adm2, format('public.okuma_surum_durum_degistir(%L,%L,%L::jsonb)', sk, 'incelemede', '{"insan":"belki"}'), 'BAD_DENETIM')
    and pg_temp.h(adm2, format('public.okuma_surum_durum_degistir(%L,%L,%L::jsonb)', sk, 'incelemede', '{"baska":"pass"}'), 'BAD_DENETIM'), pg_temp.son_hata());
  perform pg_temp.c(adm2, format('public.okuma_surum_durum_degistir(%L,%L,%L::jsonb)', sk, 'incelemede', '{"ajan_a":"pass","insan":"approved"}'));
  perform pg_temp.k('ajan_b pending iken yayın kapısı kapalı',
    pg_temp.h(adm2, format('public.okuma_surum_durum_degistir(%L,%L,null)', sk, 'yayinda'), 'YAYIN_KAPISI'), pg_temp.son_hata());
  perform pg_temp.c(adm2, format('public.okuma_surum_durum_degistir(%L,%L,%L::jsonb)', sk, 'incelemede', '{"ajan_b":"pass"}'));
  perform pg_temp.k('denetim tamam olsa da oluşturan yayınlayamaz (dört göz)',
    pg_temp.h(adm1, format('public.okuma_surum_durum_degistir(%L,%L,null)', sk, 'yayinda'), 'DORT_GOZ'), pg_temp.son_hata());
  r := pg_temp.c(adm2, format('public.okuma_surum_durum_degistir(%L,%L,null)', sk, 'yayinda'));
  select count(*) into n from public.okuma_hikaye_surumleri where id = sk and durum = 'yayinda' and inceleyen_id = adm2 and yayin_at is not null;
  perform pg_temp.k('admin2 üç onayla yayınlar (inceleyen = adm2)', n = 1, r::text);

  -- tablo düzeyi kapı (RPC atlanırsa)
  perform pg_temp.c(adm1, format('public.okuma_surum_durum_degistir(%L,%L,null)', s1, 'incelemede'));
  begin
    update public.okuma_hikaye_surumleri set durum = 'yayinda' where id = s1;
    ok := false; t := 'hata yok';
  exception when others then ok := sqlstate = '23514'; t := sqlstate || ' ' || sqlerrm;
  end;
  perform pg_temp.k('doğrudan UPDATE ile yayına alma CHECK kapısına takılır (23514)', ok, t);
  begin
    update public.okuma_hikaye_surumleri set durum = 'yayinda', denetim = '{"ajan_a":"pass","ajan_b":"pass","insan":"approved"}', inceleyen_id = olusturan_id where id = s1;
    ok := false; t := 'hata yok';
  exception when others then ok := sqlstate = '23514'; t := sqlstate || ' ' || sqlerrm;
  end;
  perform pg_temp.k('doğrudan UPDATE ile oluşturan = onaylayan olamaz (CHECK dört göz)', ok, t);

  -- değişmezlik
  ok := true; t := '';
  begin update public.okuma_hikaye_surumleri set icerik = '{}'::jsonb where id = sk; ok := false; t := t || 'icerik/yayinda ';
  exception when others then if sqlstate <> '55000' then ok := false; t := t || sqlstate; end if; end;
  begin update public.okuma_hikaye_surumleri set baslik = 'degisti' where id = sk; ok := false; t := t || 'baslik/yayinda ';
  exception when others then if sqlstate <> '55000' then ok := false; t := t || sqlstate; end if; end;
  begin update public.okuma_hikaye_surumleri set denetim = denetim || '{"insan":"rejected"}' where id = sk; ok := false; t := t || 'denetim/yayinda ';
  exception when others then if sqlstate <> '55000' then ok := false; t := t || sqlstate; end if; end;
  begin update public.okuma_hikaye_surumleri set durum = 'taslak' where id = sk; ok := false; t := t || 'durum/yayinda ';
  exception when others then if sqlstate <> '55000' then ok := false; t := t || sqlstate; end if; end;
  begin delete from public.okuma_hikaye_surumleri where id = sk; ok := false; t := t || 'silme/yayinda ';
  exception when others then if sqlstate <> '55000' then ok := false; t := t || sqlstate; end if; end;
  perform pg_temp.k('yayınlanan sürüm güncellenemez ve silinemez (SURUM_DEGISMEZ)', ok, t);

  ok := true; t := '';
  begin update public.okuma_hikaye_surumleri set icerik = '{}'::jsonb where id = s1; ok := false; t := 'taslak icerik değişti';
  exception when others then if sqlstate <> '55000' then ok := false; t := sqlstate; end if; end;
  begin update public.okuma_hikaye_surumleri set sha256 = repeat('a', 64) where id = s1; ok := false; t := 'sha değişti';
  exception when others then if sqlstate <> '55000' then ok := false; t := sqlstate; end if; end;
  perform pg_temp.k('taslak sürümün de içeriği/özeti değişmez (yeni sürüm gerekir)', ok, t);

  -- yeni sürüm yayınlanınca öncekiler arşive alınır; tek yayında
  r := pg_temp.yayinla(adm1, adm2, jsonb_set(pg_temp.paket('kapi-deneme', 4, 'gizem', 'D6', null, 'kapi'), '{hikaye,baslik}', '"Kapı v2"'));
  select count(*) filter (where durum = 'yayinda'), count(*) filter (where durum = 'arsiv') into n, n2
    from public.okuma_hikaye_surumleri where hikaye_id = hk;
  perform pg_temp.k('yeni sürüm yayında: eskisi arşive, hikâye başına tek yayında', n = 1 and n2 = 1 and (r ->> 'surum_no')::int = 2, n || '/' || n2);
  perform pg_temp.k('arşiv sürüm doğrudan yayına alınamaz; yayındaki sürüm taslağa dönemez',
    pg_temp.h(adm2, format('public.okuma_surum_durum_degistir(%L,%L,null)', sk, 'yayinda'), 'GECERSIZ_GECIS')
    and pg_temp.h(adm2, format('public.okuma_surum_durum_degistir(%L,%L,null)', r ->> 'surum_id', 'taslak'), 'GECERSIZ_GECIS'), pg_temp.son_hata());
  perform pg_temp.c(adm2, format('public.okuma_surum_durum_degistir(%L,%L,null)', sk, 'taslak'));
  select denetim::text into t from public.okuma_hikaye_surumleri where id = sk;
  perform pg_temp.k('arşivden taslağa dönüşte denetim sıfırlanır', t like '%"insan": "pending"%' and t like '%"ajan_a": "pending"%', t);

  -- =================================================================
  -- D. SAHNE: yayınlanmış hikâyeler
  -- =================================================================
  r := pg_temp.yayinla(adm1, adm2, pg_temp.paket('hik-bir', 4, 'gizem', 'D6', null, 'x'));          s1 := (r ->> 'surum_id')::uuid; h1 := (r ->> 'hikaye_id')::uuid;
  r := pg_temp.yayinla(adm1, adm2, pg_temp.paket('hik-iki', 4, 'doga', 'D3', 'D6', 'x'));           s2 := (r ->> 'surum_id')::uuid; h2 := (r ->> 'hikaye_id')::uuid;
  r := pg_temp.yayinla(adm1, adm2, pg_temp.paket('hik-uc', 5, 'aile', 'D2', null, 'y'));            s3 := (r ->> 'surum_id')::uuid; h3 := (r ->> 'hikaye_id')::uuid;
  r := pg_temp.yayinla(adm1, adm2, pg_temp.paket('hik-bes', 4, 'okul', 'D14', null, 'x', '["ben"]'::jsonb)); s5 := (r ->> 'surum_id')::uuid; h5 := (r ->> 'hikaye_id')::uuid;
  r := pg_temp.ice(adm1, pg_temp.paket('hik-dort', 4, 'mizah', 'D4', null, 'z'));                   s4 := (r ->> 'surum_id')::uuid; h4 := (r ->> 'hikaye_id')::uuid;
  perform pg_temp.incele(adm1, adm2, s4);   -- yalnız incelemede (önizleme)
  select count(*) into n from public.okuma_hikaye_surumleri where durum = 'yayinda';
  perform pg_temp.k('sahne: 5 yayında sürüm (kapi-deneme v2 dahil), 2 incelemede (hik-dort + kayip-defter v1)', n = 5 and (select count(*) from public.okuma_hikaye_surumleri where durum = 'incelemede') = 2, n::text);

  -- =================================================================
  -- E. ÖZELLİK BAYRAĞI / PİLOT / ÖNİZLEME
  -- =================================================================
  r := pg_temp.c(oa, 'public.okuma_ozellik_durumu()');
  perform pg_temp.k('varsayılan: bayrak KAPALI (erişim yok)', not (r ->> 'erisim')::boolean and not (r ->> 'onizleme')::boolean, r::text);
  perform pg_temp.k('bayrak kapalıyken katalog / getir / başlat OKUMA_KAPALI',
    pg_temp.h(oa, 'public.okuma_katalog_filtre()', 'OKUMA_KAPALI')
    and pg_temp.h(oa, format('public.okuma_hikaye_getir(%L)', h1), 'OKUMA_KAPALI')
    and pg_temp.h(oa, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h1, 'ben', 'zengin', 'anahtar-kapali'), 'OKUMA_KAPALI')
    and pg_temp.h(oa, 'public.okuma_seri_ve_oneri()', 'OKUMA_KAPALI'), pg_temp.son_hata());

  perform pg_temp.k('okuma_ayar_yaz doğrulaması: anahtar / tür / tutarsız XP / bilinmeyen kullanıcı',
    pg_temp.h(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'bilinmeyen', 'true'), 'BAD_AYAR_ANAHTARI')
    and pg_temp.h(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'aktif', '"evet"'), 'BAD_AYAR')
    and pg_temp.h(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'xp_tamamlama', '15'), 'BAD_AYAR')
    and pg_temp.h(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'xp_tamamlama', '30'), 'BAD_AYAR')
    and pg_temp.h(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'izinli_kullanicilar', to_jsonb(array[rastgele])::text), 'BAD_AYAR')
    and pg_temp.h(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'min_n', '1'), 'BAD_AYAR')
    and pg_temp.h(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'pilot_siniflari', '[0]'), 'BAD_AYAR'), pg_temp.son_hata());

  -- önizleme: izinli hesap incelemedeki hikâyeyi görür
  perform pg_temp.c(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'izinli_kullanicilar', to_jsonb(array[oa])::text));
  r := pg_temp.c(oa, 'public.okuma_ozellik_durumu()');
  r2 := pg_temp.c(oa, 'public.okuma_katalog_filtre()');
  perform pg_temp.k('izinli hesap bayrak kapalıyken de önizleme erişimi alır ve incelemedeki hikâyeyi görür',
    (r ->> 'erisim')::boolean and (r ->> 'onizleme')::boolean and (r2::text like '%hik-dort%') and (r2::text like '%hik-bir%'), r2::text);
  perform pg_temp.k('izinsiz hesap (bayrak kapalı) hâlâ kapalı', not (pg_temp.c(ob, 'public.okuma_ozellik_durumu()') ->> 'erisim')::boolean, '');
  r3 := pg_temp.c(oa, format('public.okuma_hikaye_getir(%L)', h4));
  perform pg_temp.k('önizleme: incelemedeki paket getirilir (onizleme=true)', (r3 ->> 'onizleme')::boolean and (r3 ->> 'surum_id')::uuid = s4, left(r3::text, 120));
  perform pg_temp.c(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'izinli_kullanicilar', '[]'));

  -- genel açılış
  perform pg_temp.c(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'aktif', 'true'));
  r := pg_temp.c(ob, 'public.okuma_katalog_filtre()');
  perform pg_temp.k('bayrak açık: yalnız yayındakiler görünür (incelemede gizli)', (r::text like '%hik-bir%') and (r::text not like '%hik-dort%'), r::text);
  perform pg_temp.k('izinsiz hesap incelemedeki hikâyeyi getiremez', pg_temp.h(ob, format('public.okuma_hikaye_getir(%L)', h4), 'HIKAYE_BULUNAMADI'), pg_temp.son_hata());

  perform pg_temp.c(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'pilot_siniflari', '[5]'));
  perform pg_temp.k('pilot sınıf: yalnız 5. sınıf erişir',
    not (pg_temp.c(ob, 'public.okuma_ozellik_durumu()') ->> 'erisim')::boolean and (pg_temp.c(oc, 'public.okuma_ozellik_durumu()') ->> 'erisim')::boolean, '');
  perform pg_temp.c(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'pilot_siniflari', '[]'));

  -- =================================================================
  -- F. KATALOG
  -- =================================================================
  r := pg_temp.c(ob, 'public.okuma_katalog_filtre()');
  perform pg_temp.k('katalog: görülmemiş önce, sınıfa yakın, slug sırası (veli değeri yokken)',
    r -> 'hikayeler' -> 0 ->> 'slug' = 'hik-bes' and (r -> 'hikayeler' -> 0 ->> 'gorulmedi')::boolean, (select string_agg(x ->> 'slug', ',') from jsonb_array_elements(r -> 'hikayeler') x));
  perform pg_temp.k('katalog filtreleri: sınıf / tema / ders / değer / zorluk / limit',
    (select count(*) from jsonb_array_elements(pg_temp.c(ob, 'public.okuma_katalog_filtre(5)') -> 'hikayeler')) = 1
    and (select count(*) from jsonb_array_elements(pg_temp.c(ob, format('public.okuma_katalog_filtre(null,%L)', 'doga')) -> 'hikayeler')) = 1
    and (select count(*) from jsonb_array_elements(pg_temp.c(ob, format('public.okuma_katalog_filtre(null,null,%L)', 'turkce')) -> 'hikayeler')) = 5
    and (select count(*) from jsonb_array_elements(pg_temp.c(ob, format('public.okuma_katalog_filtre(null,null,null,%L)', 'D6')) -> 'hikayeler')) = 3
    and (select count(*) from jsonb_array_elements(pg_temp.c(ob, 'public.okuma_katalog_filtre(null,null,null,null,3,5)') -> 'hikayeler')) = 0
    and (select count(*) from jsonb_array_elements(pg_temp.c(ob, 'public.okuma_katalog_filtre(null,null,null,null,1,5,null,2)') -> 'hikayeler')) = 2,
    'ders=5 değer=3 beklenir');
  r := pg_temp.c(ob, format('public.okuma_katalog_filtre(null,null,null,null,1,5,%L)', 'anne'));
  perform pg_temp.k('katalog: izinli_turler uyumu (yalnız "ben" izinli hikâye anne için gelmez)', r::text not like '%hik-bes%' and r::text like '%hik-bir%', r::text);

  -- veli değeri sıralaması
  perform pg_temp.k('değer listesi 20 kalem; veli en çok 5 seçer',
    jsonb_array_length(pg_temp.c(v2, 'public.okuma_degerleri_listele()')) = 20
    and pg_temp.h(v2, format('public.okuma_veli_degerleri_ayarla(%L,%L::text[])', ob, '{D1,D2,D3,D4,D5,D6}'), 'EN_FAZLA_BES')
    and pg_temp.h(v2, format('public.okuma_veli_degerleri_ayarla(%L,%L::text[])', ob, '{D1,D1}'), 'TEKRARLI_DEGER')
    and pg_temp.h(v2, format('public.okuma_veli_degerleri_ayarla(%L,%L::text[])', ob, '{D99}'), 'GECERSIZ_DEGER')
    and pg_temp.h(v2, format('public.okuma_veli_degerleri_ayarla(%L,%L::text[])', ob, '{Efe}'), 'GECERSIZ_DEGER'), pg_temp.son_hata());
  perform pg_temp.k('veli yalnız kendi çocuğunun değerlerini yazar/okur (başka veli ve öğrenci reddedilir)',
    pg_temp.h(v1, format('public.okuma_veli_degerleri_ayarla(%L,%L::text[])', ob, '{D1}'), 'FORBIDDEN')
    and pg_temp.h(v1, format('public.okuma_veli_degerleri_getir(%L)', ob), 'FORBIDDEN'), pg_temp.son_hata());
  perform pg_temp.c(v2, format('public.okuma_veli_degerleri_ayarla(%L,%L::text[])', ob, '{D3}'));
  r := pg_temp.c(ob, 'public.okuma_katalog_filtre()');
  perform pg_temp.k('veli değeri (D3) eşleşen hikâyeyi öne alır; kısıtlamaz',
    r -> 'hikayeler' -> 0 ->> 'slug' = 'hik-iki' and (r -> 'hikayeler' -> 0 ->> 'deger_eslesmesi')::boolean and jsonb_array_length(r -> 'hikayeler') = 5,
    (select string_agg(x ->> 'slug', ',') from jsonb_array_elements(r -> 'hikayeler') x));
  perform pg_temp.k('veli değer tercihi okunur', pg_temp.c(v2, format('public.okuma_veli_degerleri_getir(%L)', ob)) -> 'degerler' = '["D3"]'::jsonb, '');

  -- katalog çıktısı: anahtar ve cinsiyet izi yok
  perform pg_temp.k('katalog çıktısında dogru/aciklama/ilgi_egilimi/cinsiyet izi yok',
    not pg_temp.anahtar_var(r, 'dogru') and not pg_temp.anahtar_var(r, 'aciklama') and not pg_temp.anahtar_var(r, 'ilgi_egilimi')
    and r::text !~* '(cinsiyet|kiz_egilimli|erkek_egilimli|GIZLI_ACIKLAMA)', left(r::text, 200));

  -- =================================================================
  -- G. PAKET TESLİMİ
  -- =================================================================
  r := pg_temp.c(oa, format('public.okuma_hikaye_getir(%L)', h1));
  perform pg_temp.k('getir: dogru/aciklama anahtarları ve gizli açıklama metinleri yok',
    not pg_temp.anahtar_var(r, 'dogru') and not pg_temp.anahtar_var(r, 'aciklama') and r::text not like '%GIZLI_ACIKLAMA%'
    and not pg_temp.anahtar_var(r, 'denetim') and not pg_temp.anahtar_var(r, 'uretim'), left(r::text, 200));
  perform pg_temp.k('getir: sha256 + surum döner; soru ve şık sırası veri sırası',
    length(r ->> 'sha256') = 64 and (r ->> 'surum')::int = 1
    and (select string_agg(q ->> 'id', ',') from jsonb_array_elements(r -> 'paket' -> 'sorular') q) = 's1,s2,s3'
    and (select string_agg(o ->> 'id', ',') from jsonb_array_elements(r -> 'paket' -> 'sorular' -> 0 -> 'secenekler') o) = 'A,B,C,D'
    and jsonb_array_length(r -> 'paket' -> 'sayfalar') = 3 and (r -> 'paket' -> 'sorular' -> 0) ? 'metin', left(r::text, 120));
  r2 := pg_temp.c(adm1, format('public.okuma_surum_icerik_getir(%L)', s1));
  perform pg_temp.k('yönetici incelemesi tam paketi (anahtar dahil) görür; öğrenci göremez',
    pg_temp.anahtar_var(r2, 'dogru') and pg_temp.h(oa, format('public.okuma_surum_icerik_getir(%L)', s1)), '');
  perform pg_temp.k('getir: bilinmeyen hikâye', pg_temp.h(oa, format('public.okuma_hikaye_getir(%L)', rastgele), 'HIKAYE_BULUNAMADI'), pg_temp.son_hata());

  -- =================================================================
  -- H. OTURUM, CEVAP, BİTİR, XP
  -- =================================================================
  r := pg_temp.c(oa, format('public.okuma_oturum_baslat(%L,%L,true,%L,%L)', h1, 'ben', 'zengin', 'oturum-anahtar-a1'));
  o1 := (r ->> 'oturum_id')::uuid;
  perform pg_temp.k('oturum başlat: oturum_id döner, anahtar sızmaz', o1 is not null and not (r ->> 'tekrar')::boolean and not pg_temp.anahtar_var(r, 'dogru') and not pg_temp.anahtar_var(r, 'aciklama'), r::text);
  r2 := pg_temp.c(oa, format('public.okuma_oturum_baslat(%L,%L,true,%L,%L)', h1, 'ben', 'zengin', 'oturum-anahtar-a1'));
  select count(*) into n from public.okuma_oturumlari where ogrenci_id = oa;
  perform pg_temp.k('oturum başlat idempotent: aynı anahtar aynı oturum', (r2 ->> 'oturum_id')::uuid = o1 and (r2 ->> 'tekrar')::boolean and n = 1, r2::text);
  perform pg_temp.k('aynı anahtar farklı hikâye/tür: IDEMPOTENCY_CONFLICT',
    pg_temp.h(oa, format('public.okuma_oturum_baslat(%L,%L,true,%L,%L)', h2, 'ben', 'zengin', 'oturum-anahtar-a1'), 'IDEMPOTENCY_CONFLICT')
    and pg_temp.h(oa, format('public.okuma_oturum_baslat(%L,%L,true,%L,%L)', h1, 'anne', 'zengin', 'oturum-anahtar-a1'), 'IDEMPOTENCY_CONFLICT'), pg_temp.son_hata());
  perform pg_temp.k('başlat doğrulamaları: tür, mod, anahtar biçimi, uygun olmayan kahraman türü',
    pg_temp.h(oa, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h1, 'Efe', 'zengin', 'oturum-anahtar-x1'), 'BAD_KAHRAMAN_TURU')
    and pg_temp.h(oa, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h1, 'ben', 'dev', 'oturum-anahtar-x1'), 'BAD_OKUMA_MODU')
    and pg_temp.h(oa, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h1, 'ben', 'zengin', 'Efe ve Ayşe'), 'INVALID_ATTEMPT_KEY')
    and pg_temp.h(oa, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h1, 'ben', 'zengin', 'kisa'), 'INVALID_ATTEMPT_KEY')
    and pg_temp.h(oa, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h5, 'anne', 'zengin', 'oturum-anahtar-x2'), 'KAHRAMAN_TURU_UYGUN_DEGIL')
    and pg_temp.h(oa, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h4, 'ben', 'zengin', 'oturum-anahtar-x3'), 'HIKAYE_BULUNAMADI'), pg_temp.son_hata());

  -- öğrenci A/B izolasyonu
  perform pg_temp.k('başka öğrencinin oturumu: cevap / bitir / ilerleme / geri bildirim reddedilir (OTURUM_BULUNAMADI)',
    pg_temp.h(ob, format('public.okuma_cevap_kontrol(%L,%L,%L)', o1, 's1', 'B'), 'OTURUM_BULUNAMADI')
    and pg_temp.h(ob, format('public.okuma_oturum_bitir(%L,%L::text[])', o1, '{}'), 'OTURUM_BULUNAMADI')
    and pg_temp.h(ob, format('public.okuma_ilerleme_kaydet(%L,2)', o1), 'OTURUM_BULUNAMADI')
    and pg_temp.h(ob, format('public.okuma_geri_bildirim_gonder(%L,4,%L::text[],false,false,%L::text[])', o1, '{}', '{}'), 'OTURUM_BULUNAMADI'), pg_temp.son_hata());

  perform pg_temp.k('cevap doğrulamaları: soru/şık biçimi, olmayan şık',
    pg_temp.h(oa, format('public.okuma_cevap_kontrol(%L,%L,%L)', o1, 'Efe', 'B'), 'BAD_SORU')
    and pg_temp.h(oa, format('public.okuma_cevap_kontrol(%L,%L,%L)', o1, 's1', 'Efe'), 'BAD_OPTION')
    and pg_temp.h(oa, format('public.okuma_cevap_kontrol(%L,%L,%L)', o1, 's9', 'A'), 'SORU_BULUNAMADI')
    and pg_temp.h(oa, format('public.okuma_cevap_kontrol(%L,%L,%L)', o1, 's2', 'D'), 'BAD_OPTION'), pg_temp.son_hata());

  perform pg_temp.c(oa, format('public.okuma_ilerleme_kaydet(%L,2)', o1));
  select son_sayfa into n from public.okuma_oturumlari where id = o1;
  perform pg_temp.k('ilerleme kaydı: son sayfa güncellenir, geri gitmez', n = 2 and (pg_temp.c(oa, format('public.okuma_ilerleme_kaydet(%L,1)', o1)) ->> 'son_sayfa')::int = 2
                    and pg_temp.h(oa, format('public.okuma_ilerleme_kaydet(%L,99)', o1), 'BAD_SAYFA'), n::text);

  -- cevaplar (hepsi doğru)
  r := pg_temp.c(oa, format('public.okuma_cevap_kontrol(%L,%L,%L)', o1, 's1', 'B'));
  perform pg_temp.k('cevap: doğru → dogru, açıklama, doğru şık döner', (r ->> 'dogru')::boolean and r ->> 'dogru_secenek_id' = 'B' and r ->> 'aciklama' like 'GIZLI_ACIKLAMA_1%', r::text);
  perform pg_temp.c(oa, format('public.okuma_cevap_kontrol(%L,%L,%L)', o1, 's2', 'C'));
  perform pg_temp.c(oa, format('public.okuma_cevap_kontrol(%L,%L,%L)', o1, 's3', 'A'));
  r2 := pg_temp.c(oa, format('public.okuma_cevap_kontrol(%L,%L,%L)', o1, 's1', 'A'));
  perform pg_temp.k('tek deneme: cevap değiştirilemez, kayıtlı sonuç döner', (r2 ->> 'dogru')::boolean and (r2 ->> 'tekrar')::boolean
    and (select count(*) from public.okuma_cevaplari where oturum_id = o1) = 3, r2::text);

  select count(*) into cagri_once from public.stub_xp_cagrilari;
  r := pg_temp.c(oa, format('public.okuma_oturum_bitir(%L,%L::text[])', o1, '{ha_x,hb_x}'));
  select count(*) into n from public.stub_xp_cagrilari where student_id = oa;
  perform pg_temp.k('bitir: %100 doğru → 20 XP (tamamlama 10 + bonus 10), award çağrısı zorluk 2',
    (r ->> 'kazanilan_xp')::int = 20 and (r ->> 'ilk_tamamlama')::boolean and (r ->> 'dogru_orani')::int = 100
    and exists (select 1 from public.stub_xp_cagrilari where student_id = oa and zorluk = 2 and xp_ver and xp = 20) and n = 1, r::text);
  perform pg_temp.k('bitir: beceri sonuçları ve hedef özeti döner',
    r #>> '{beceri_sonuclari,hatirlama,dogru}' = '1' and jsonb_array_length(r -> 'hedefler') = 2 and (r -> 'seri' ->> 'streak_count')::int >= 1, r::text);
  select string_agg(hedef_id || ':' || durum, ',' order by hedef_id) into t from public.okuma_ogrenci_hedef_durumu where ogrenci_id = oa;
  perform pg_temp.k('hedef durumu: ilk doğru cevapla tanışıldı → recognized', t = 'ha_x:recognized,hb_x:recognized', t);
  r2 := pg_temp.c(oa, format('public.okuma_oturum_bitir(%L,%L::text[])', o1, '{}'));
  select count(*) into n2 from public.stub_xp_cagrilari where student_id = oa;
  perform pg_temp.k('aynı oturum yeniden bitirilirse XP/seri tekrar işlenmez (kayıtlı sonuç)', (r2 ->> 'tekrar')::boolean and (r2 ->> 'kazanilan_xp')::int = 20 and n2 = 1, r2::text);

  -- aynı hikâye ikinci kez: XP yok
  r := pg_temp.c(oa, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h1, 'anne', 'sade', 'oturum-anahtar-a2'));
  o2 := (r ->> 'oturum_id')::uuid;
  perform pg_temp.c(oa, format('public.okuma_cevap_kontrol(%L,%L,%L)', o2, 's1', 'B'));
  r := pg_temp.c(oa, format('public.okuma_oturum_bitir(%L,%L::text[])', o2, '{}'));
  perform pg_temp.k('aynı hikâye tekrar tamamlanınca XP yok (ilk_tamamlama=false); seri için award yine çağrılır',
    (r ->> 'kazanilan_xp')::int = 0 and not (r ->> 'ilk_tamamlama')::boolean
    and exists (select 1 from public.stub_xp_cagrilari where student_id = oa and not xp_ver), r::text);
  select count(*) into n from public.okuma_oturumlari where ogrenci_id = oa and hikaye_id = h1 and ilk_tamamlama;
  perform pg_temp.k('(öğrenci, hikâye) başına tek ilk_tamamlama', n = 1, n::text);

  -- düşük doğru oranı: 10 XP (bonus yok)
  r := pg_temp.c(ob, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h1, 'hayvan', 'zengin', 'oturum-anahtar-b1'));
  o3 := (r ->> 'oturum_id')::uuid;
  perform pg_temp.c(ob, format('public.okuma_cevap_kontrol(%L,%L,%L)', o3, 's1', 'A'));
  r2 := pg_temp.c(ob, format('public.okuma_cevap_kontrol(%L,%L,%L)', o3, 's2', 'A'));
  perform pg_temp.k('yanlış cevap: dogru=false, doğru şık + açıklama cevaptan sonra döner', not (r2 ->> 'dogru')::boolean and r2 ->> 'dogru_secenek_id' = 'C' and r2 ->> 'aciklama' like 'GIZLI_ACIKLAMA_2%', r2::text);
  perform pg_temp.c(ob, format('public.okuma_cevap_kontrol(%L,%L,%L)', o3, 's3', 'A'));
  r := pg_temp.c(ob, format('public.okuma_oturum_bitir(%L,%L::text[])', o3, '{ha_x}'));
  perform pg_temp.k('doğru oranı %33 (<%67): yalnız tamamlama XP''si (10)', (r ->> 'kazanilan_xp')::int = 10 and (r ->> 'dogru_orani')::int = 33
    and exists (select 1 from public.stub_xp_cagrilari where student_id = ob and zorluk = 1 and xp_ver and xp = 10), r::text);
  select string_agg(hedef_id || ':' || durum, ',' order by hedef_id) into t from public.okuma_ogrenci_hedef_durumu where ogrenci_id = ob;
  perform pg_temp.k('yanlış cevaplanan hedef introduced kalır, hata türü kaydedilir',
    t = 'ha_x:introduced,hb_x:introduced' and (select hata_turu from public.okuma_ogrenci_hedef_durumu where ogrenci_id = ob and hedef_id = 'ha_x') = 'hatirlama', t);

  perform pg_temp.k('dokunulan kimlikler yalnız kayıtlı hedefler olabilir (serbest metin / başka hikâye hedefi reddedilir)',
    pg_temp.h(ob, format('public.okuma_oturum_bitir(%L,%L::text[])', o3, '{Efe}'), 'BAD_HEDEF'), pg_temp.son_hata());
  r := pg_temp.c(ob, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h2, 'ben', 'zengin', 'oturum-anahtar-b2'));
  o4 := (r ->> 'oturum_id')::uuid;
  perform pg_temp.k('bitir: serbest metin ve başka hikâyenin hedefi BAD_HEDEF',
    pg_temp.h(ob, format('public.okuma_oturum_bitir(%L,%L::text[])', o4, '{Ayse Hanim}'), 'BAD_HEDEF')
    and pg_temp.h(ob, format('public.okuma_oturum_bitir(%L,%L::text[])', o4, '{hedef_baska_yerden}'), 'BAD_HEDEF')
    and pg_temp.h(ob, format('public.okuma_oturum_bitir(%L,%L::text[])', o4, '{ha_x,NULL}'), 'BAD_HEDEF'), pg_temp.son_hata());
  select dokunulan_hedefler::text into t from public.okuma_oturumlari where id = o3;
  perform pg_temp.k('geçerli dokunulan hedef kaydedilir', t = '{ha_x}', t);

  -- hedef ilerlemesi: oa, hik-iki (aynı hedefler), recognized → retrieved (gecikmeli doğru)
  update public.okuma_ogrenci_hedef_durumu set son_dogru_at = now() - interval '2 days' where ogrenci_id = oa;
  r := pg_temp.c(oa, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h2, 'ben', 'zengin', 'oturum-anahtar-a3'));
  o1 := (r ->> 'oturum_id')::uuid;
  perform pg_temp.c(oa, format('public.okuma_cevap_kontrol(%L,%L,%L)', o1, 's1', 'B'));
  perform pg_temp.c(oa, format('public.okuma_cevap_kontrol(%L,%L,%L)', o1, 's2', 'C'));
  perform pg_temp.c(oa, format('public.okuma_cevap_kontrol(%L,%L,%L)', o1, 's3', 'A'));
  perform pg_temp.c(oa, format('public.okuma_oturum_bitir(%L,%L::text[])', o1, '{}'));
  select string_agg(hedef_id || ':' || durum, ',' order by hedef_id) into t from public.okuma_ogrenci_hedef_durumu where ogrenci_id = oa;
  perform pg_temp.k('hedef durumu: gecikmeli doğru cevapla recognized → retrieved', t = 'ha_x:retrieved,hb_x:retrieved', t);
  r := pg_temp.c(oa, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h5, 'ben', 'zengin', 'oturum-anahtar-a4'));
  o1 := (r ->> 'oturum_id')::uuid;
  perform pg_temp.c(oa, format('public.okuma_cevap_kontrol(%L,%L,%L)', o1, 's1', 'B'));
  perform pg_temp.c(oa, format('public.okuma_cevap_kontrol(%L,%L,%L)', o1, 's2', 'C'));
  perform pg_temp.c(oa, format('public.okuma_oturum_bitir(%L,%L::text[])', o1, '{}'));
  select string_agg(hedef_id || ':' || durum, ',' order by hedef_id) into t from public.okuma_ogrenci_hedef_durumu where ogrenci_id = oa;
  perform pg_temp.k('hedef durumu: transfer sorusu doğru → retrieved → transferred (yalnız transfer hedefi)', t = 'ha_x:retrieved,hb_x:transferred', t);
  r := pg_temp.c(oa, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h1, 'ben', 'zengin', 'oturum-anahtar-a5'));
  o1 := (r ->> 'oturum_id')::uuid;
  perform pg_temp.c(oa, format('public.okuma_cevap_kontrol(%L,%L,%L)', o1, 's1', 'D'));
  perform pg_temp.c(oa, format('public.okuma_oturum_bitir(%L,%L::text[])', o1, '{}'));
  select string_agg(hedef_id || ':' || durum, ',' order by hedef_id) into t from public.okuma_ogrenci_hedef_durumu where ogrenci_id = oa;
  perform pg_temp.k('hedef durumu: pekişmiş hedefte yanlış cevap → refresh_due (tekrar_at yarın)',
    t like 'ha_x:refresh_due%' and (select tekrar_at from public.okuma_ogrenci_hedef_durumu where ogrenci_id = oa and hedef_id = 'ha_x') > now(), t);

  -- günlük XP tavanı (3 hikâye aynı gün): oc
  r := pg_temp.c(oc, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h1, 'ben', 'zengin', 'oturum-anahtar-c1'));
  perform pg_temp.c(oc, format('public.okuma_oturum_bitir(%L,%L::text[])', r ->> 'oturum_id', '{}'));
  r := pg_temp.c(oc, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h2, 'ben', 'zengin', 'oturum-anahtar-c2'));
  perform pg_temp.c(oc, format('public.okuma_oturum_bitir(%L,%L::text[])', r ->> 'oturum_id', '{}'));
  r := pg_temp.c(oc, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h3, 'ben', 'zengin', 'oturum-anahtar-c3'));
  r2 := pg_temp.c(oc, format('public.okuma_oturum_bitir(%L,%L::text[])', r ->> 'oturum_id', '{}'));
  select count(*) filter (where xp_ver), count(*) filter (where not xp_ver) into n, n2 from public.stub_xp_cagrilari where student_id = oc;
  perform pg_temp.k('günde en çok 2 hikâyenin XP''si: 3. hikâye XP vermez ama seri için award çağrılır',
    (r2 ->> 'kazanilan_xp')::int = 0 and (r2 ->> 'xp_tavani_doldu')::boolean and n = 2 and n2 = 1, r2::text);
  update public.okuma_oturumlari set tamamlandi_at = tamamlandi_at - interval '1 day', gun = gun - 1 where ogrenci_id = oc;
  r := pg_temp.c(oc, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h5, 'ben', 'zengin', 'oturum-anahtar-c4'));
  r2 := pg_temp.c(oc, format('public.okuma_oturum_bitir(%L,%L::text[])', r ->> 'oturum_id', '{}'));
  perform pg_temp.k('ertesi gün tavan sıfırlanır (yeni hikâye XP verir)', (r2 ->> 'kazanilan_xp')::int > 0, r2::text);

  -- saatlik başlatma sınırı
  perform pg_temp.c(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'saatlik_baslatma_siniri', '2'));
  select count(*) into n from public.okuma_oturumlari where ogrenci_id = oa and baslangic_at > now() - interval '1 hour';
  perform pg_temp.k('saatlik sınır: aşılınca RATE_LIMIT (aynı anahtar tekrarı hâlâ çalışır)',
    pg_temp.h(oa, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h3, 'ben', 'zengin', 'oturum-anahtar-a9'), 'RATE_LIMIT')
    and (pg_temp.c(oa, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h1, 'ben', 'zengin', 'oturum-anahtar-a5')) ->> 'tekrar')::boolean, n::text);
  perform pg_temp.c(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'saatlik_baslatma_siniri', '12'));

  -- =================================================================
  -- I. GERİ BİLDİRİM
  -- =================================================================
  r := pg_temp.c(oa, format('public.okuma_geri_bildirim_gonder(%L,5,%L::text[],true,false,%L::text[])', o1, '{daha_komik,daha_gizemli}', '{ad_yanlis_yazilmis}'));
  perform pg_temp.k('geri bildirim: kayıt + beyaz liste kodları', (r ->> 'kaydedildi')::boolean
    and (select yildiz from public.okuma_geri_bildirimleri where oturum_id = o1) = 5
    and (select sorun_kodlari::text from public.okuma_geri_bildirimleri where oturum_id = o1) = '{ad_yanlis_yazilmis}', r::text);
  perform pg_temp.c(oa, format('public.okuma_geri_bildirim_gonder(%L,3,%L::text[],false,true,%L::text[])', o1, '{}', '{}'));
  select count(*) into n from public.okuma_geri_bildirimleri where oturum_id = o1;
  perform pg_temp.k('geri bildirim tek kayıt (yeniden gönderme günceller)', n = 1 and (select yildiz from public.okuma_geri_bildirimleri where oturum_id = o1) = 3, n::text);
  perform pg_temp.k('geri bildirim: yıldız aralığı ve serbest metin kodu reddedilir',
    pg_temp.h(oa, format('public.okuma_geri_bildirim_gonder(%L,6,%L::text[],false,false,%L::text[])', o1, '{}', '{}'), 'BAD_YILDIZ')
    and pg_temp.h(oa, format('public.okuma_geri_bildirim_gonder(%L,3,%L::text[],false,false,%L::text[])', o1, '{Cok guzeldi Efe}', '{}'), 'BAD_KOD')
    and pg_temp.h(oa, format('public.okuma_geri_bildirim_gonder(%L,3,%L::text[],false,false,%L::text[])', o1, '{}', '{Efe}'), 'BAD_KOD'), pg_temp.son_hata());
  begin
    insert into public.okuma_geri_bildirimleri (oturum_id, yildiz, sorun_kodlari) values (o3, 3, '{serbest metin}');
    ok := false; t := 'hata yok';
  exception when others then ok := sqlstate = '23514'; t := sqlstate;
  end;
  perform pg_temp.k('tablo CHECK''i de serbest metin kodunu reddeder (23514)', ok, t);

  perform pg_temp.c(ob, format('public.okuma_geri_bildirim_gonder(%L,4,%L::text[],false,false,%L::text[])', o3, '{}', '{soru_hatali}'));

  -- =================================================================
  -- J. KOTA (premium_gating, premium, deneme) ve PDF
  -- =================================================================
  r := pg_temp.c(od, 'public.okuma_ozellik_durumu()');
  perform pg_temp.k('premium_gating kapalıyken kota yok (sınırsız)', not (r -> 'gunluk_kota' ->> 'sinirli')::boolean and (r -> 'gunluk_kota' -> 'kalan') = 'null'::jsonb, r::text);
  update public.app_settings set value = '{"aktif": true, "ucretsiz_gunluk_soru": 20}' where key = 'premium_gating';
  r := pg_temp.c(od, 'public.okuma_ozellik_durumu()');
  perform pg_temp.k('premium_gating açık: ücretsiz öğrenci günde 1 hikâye', (r -> 'gunluk_kota' ->> 'sinirli')::boolean and (r -> 'gunluk_kota' ->> 'kalan')::int = 1, r::text);
  r := pg_temp.c(od, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h1, 'ben', 'zengin', 'oturum-anahtar-d1'));
  o1 := (r ->> 'oturum_id')::uuid;
  perform pg_temp.k('kota: ikinci farklı hikâye başlatılamaz (KOTA_DOLDU)', pg_temp.h(od, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h2, 'ben', 'zengin', 'oturum-anahtar-d2'), 'KOTA_DOLDU'), pg_temp.son_hata());
  perform pg_temp.k('kota: paket indirme de bağlıdır; bugünkü hikâye serbest', pg_temp.h(od, format('public.okuma_hikaye_getir(%L)', h2), 'KOTA_DOLDU')
    and (pg_temp.c(od, format('public.okuma_hikaye_getir(%L)', h1)) ->> 'surum') is not null, pg_temp.son_hata());
  r := pg_temp.c(od, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h1, 'anne', 'zengin', 'oturum-anahtar-d3'));
  perform pg_temp.k('kota: aynı hikâyeyi bugün yeniden başlatmak serbest', (r ->> 'oturum_id') is not null, r::text);
  r := pg_temp.c(od, format('public.okuma_cevap_kontrol(%L,%L,%L)', o1, 's1', 'B'));
  r2 := pg_temp.c(od, format('public.okuma_geri_bildirim_gonder(%L,4,%L::text[],false,false,%L::text[])', o1, '{}', '{}'));
  perform pg_temp.k('kota dolu iken sorular ve geri bildirim kısıtlanmaz', (r ->> 'dogru')::boolean and (r2 ->> 'kaydedildi')::boolean, '');
  perform pg_temp.c(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'okuma_gunluk_hikaye', '2'));
  perform pg_temp.k('okuma_gunluk_hikaye=2: ikinci hikâye açılır, üçüncü açılmaz',
    (pg_temp.c(od, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h2, 'ben', 'zengin', 'oturum-anahtar-d4')) ->> 'oturum_id') is not null
    and pg_temp.h(od, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h3, 'ben', 'zengin', 'oturum-anahtar-d5'), 'KOTA_DOLDU'), pg_temp.son_hata());
  perform pg_temp.c(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'okuma_gunluk_hikaye', '1'));
  update public.okuma_oturumlari set gun = gun - 1 where ogrenci_id = od;
  perform pg_temp.k('ertesi gün kota sıfırlanır (İstanbul günü)',
    (pg_temp.c(od, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h3, 'ben', 'zengin', 'oturum-anahtar-d6')) ->> 'oturum_id') is not null, '');

  -- premium (veli aboneliği) ve deneme: sınırsız
  insert into public.subscriptions (veli_id, bitis) values (v3, now() + interval '30 days');
  perform pg_temp.c(oe, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h1, 'ben', 'zengin', 'oturum-anahtar-e1'));
  perform pg_temp.c(oe, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h2, 'ben', 'zengin', 'oturum-anahtar-e2'));
  r := pg_temp.c(oe, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h3, 'ben', 'zengin', 'oturum-anahtar-e3'));
  perform pg_temp.k('premium öğrenci: kota yok (3 farklı hikâye)', (r ->> 'oturum_id') is not null and r -> 'kota_kalan' = 'null'::jsonb, r::text);
  insert into public.deneme_donemleri (veli_id, bitis) values (v4, now() + interval '10 days');
  perform pg_temp.c(off, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h1, 'ben', 'zengin', 'oturum-anahtar-f1'));
  perform pg_temp.c(off, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h2, 'ben', 'zengin', 'oturum-anahtar-f2'));
  r := pg_temp.c(off, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h3, 'ben', 'zengin', 'oturum-anahtar-f3'));
  perform pg_temp.k('deneme (14 gün) öğrencisi: kota yok', (r ->> 'oturum_id') is not null, r::text);
  update public.deneme_donemleri set bitis = now() - interval '1 day' where veli_id = v4;
  update public.okuma_oturumlari set gun = gun - 1 where ogrenci_id = off and hikaye_id <> h1;   -- bugün yalnız h1 sayılır
  perform pg_temp.k('deneme bitince ücretsiz kota geri gelir',
    pg_temp.h(off, format('public.okuma_oturum_baslat(%L,%L,false,%L,%L)', h5, 'ben', 'zengin', 'oturum-anahtar-f4'), 'KOTA_DOLDU'), pg_temp.son_hata());

  -- PDF sayacı (od: ücretsiz; gating açık)
  r := pg_temp.c(od, format('public.okuma_pdf_hakki_kullan(%L)', h1));
  perform pg_temp.k('PDF: ilk hak (kalan 2)', (r ->> 'izin')::boolean and (r ->> 'kalan')::int = 2, r::text);
  r := pg_temp.c(od, format('public.okuma_pdf_hakki_kullan(%L)', h1));
  perform pg_temp.k('PDF: aynı hikâye aynı ay ikinci hak tüketmez', (r ->> 'izin')::boolean and (r ->> 'tekrar')::boolean and (r ->> 'kalan')::int = 2, r::text);
  perform pg_temp.c(od, format('public.okuma_pdf_hakki_kullan(%L)', h2));
  r := pg_temp.c(od, format('public.okuma_pdf_hakki_kullan(%L)', h3));
  r2 := pg_temp.c(od, format('public.okuma_pdf_hakki_kullan(%L)', h5));
  perform pg_temp.k('PDF: ayda 3 hikâyeden sonra izin yok', (r ->> 'kalan')::int = 0 and not (r2 ->> 'izin')::boolean, r2::text);
  update public.okuma_pdf_kullanimlari set ay = (ay - interval '1 month')::date where kullanici_id = od;
  perform pg_temp.k('PDF: ay değişince sayaç sıfırlanır', (pg_temp.c(od, format('public.okuma_pdf_hakki_kullan(%L)', h5)) ->> 'izin')::boolean, '');
  r := pg_temp.c(oe, format('public.okuma_pdf_hakki_kullan(%L)', h1));
  perform pg_temp.k('PDF: premium sınırsız (kalan null)', (r ->> 'izin')::boolean and r -> 'kalan' = 'null'::jsonb, r::text);
  perform pg_temp.k('PDF: bilinmeyen hikâye, anon ve öğretmen reddedilir',
    pg_temp.h(od, format('public.okuma_pdf_hakki_kullan(%L)', rastgele), 'HIKAYE_BULUNAMADI')
    and pg_temp.h(null, format('public.okuma_pdf_hakki_kullan(%L)', h1))
    and pg_temp.h(t1, format('public.okuma_pdf_hakki_kullan(%L)', h1), 'FORBIDDEN'), pg_temp.son_hata());
  update public.app_settings set value = '{"aktif": false, "ucretsiz_gunluk_soru": 20}' where key = 'premium_gating';

  -- =================================================================
  -- K. SERİ VE ÖNERİ
  -- =================================================================
  r := pg_temp.c(oa, 'public.okuma_seri_ve_oneri()');
  perform pg_temp.k('seri_ve_oneri: seri bilgisi + bugünkü öneri, anahtar sızmaz',
    (r -> 'seri' ->> 'streak_count')::int >= 1 and (r -> 'seri' ->> 'bugun_okudu')::boolean and r -> 'oneri' ? 'hikaye_id'
    and not pg_temp.anahtar_var(r, 'dogru') and not pg_temp.anahtar_var(r, 'aciklama'), r::text);
  r := pg_temp.c(off, 'public.okuma_seri_ve_oneri()');
  perform pg_temp.k('seri_ve_oneri: hiç tamamlamamış öğrencide bugun_okudu=false', not (r -> 'seri' ->> 'bugun_okudu')::boolean and (r ->> 'toplam_tamamlanan')::int = 0, r::text);

  -- =================================================================
  -- L. VELİ ÖZETİ (rıza, premium, min-N)
  -- =================================================================
  r := pg_temp.c(v1, format('public.okuma_veli_ozeti(%L,30)', oa));
  perform pg_temp.k('veli özeti: rıza yok → {riza:false, ozet:null}', (r ->> 'riza')::boolean is false and r -> 'ozet' = 'null'::jsonb, r::text);
  perform pg_temp.k('veli özeti: bağlı olmayan veli / öğrenci / anon reddedilir',
    pg_temp.h(v2, format('public.okuma_veli_ozeti(%L,30)', oa), 'FORBIDDEN') and pg_temp.h(oa, format('public.okuma_veli_ozeti(%L,30)', oa), 'FORBIDDEN')
    and pg_temp.h(null, format('public.okuma_veli_ozeti(%L,30)', oa)), pg_temp.son_hata());
  insert into public.consents (cocuk_id, tur, created_at) values (oa, 'veli_acik_riza', now() - interval '2 days');
  r := pg_temp.c(v1, format('public.okuma_veli_ozeti(%L,30)', oa));
  perform pg_temp.k('veli özeti: rıza verildi, ücretsiz → temel (okunan/tamamlanan), ayrıntı yok',
    (r ->> 'riza')::boolean and not (r #>> '{ozet,detay}')::boolean and (r #>> '{ozet,okunan_hikaye}')::int >= 3
    and (r #>> '{ozet,tamamlanan_hikaye}')::int >= 3 and not (r -> 'ozet' ? 'soru_dogrulugu') and not (r -> 'ozet' ? 'hedef_durumlari'), r::text);
  insert into public.subscriptions (veli_id, bitis) values (v1, now() + interval '30 days');
  r := pg_temp.c(v1, format('public.okuma_veli_ozeti(%L,30)', oa));
  perform pg_temp.k('veli özeti: premium → ayrıntılı (işlem türüne göre doğruluk, tema/değer/ders, hedef durumları)',
    (r #>> '{ozet,detay}')::boolean and (r #> '{ozet,soru_dogrulugu}') ? 'hatirlama' and (r #> '{ozet,tema_dagilimi}') is not null
    and jsonb_array_length(r #> '{ozet,deger_dagilimi}') > 0 and (r #> '{ozet,hedef_durumlari}') is not null, left(r::text, 300));
  perform pg_temp.k('veli özeti min-N: yeterli örnek varsa oran, yoksa yeterli=false ve oran yok',
    (r #>> '{ozet,soru_dogrulugu,hatirlama,yeterli}')::boolean and (r #> '{ozet,soru_dogrulugu,hatirlama}') ? 'oran'
    and not (r #>> '{ozet,soru_dogrulugu,degerlendirme,yeterli}')::boolean and not ((r #> '{ozet,soru_dogrulugu,degerlendirme}') ? 'oran'),
    (r #> '{ozet,soru_dogrulugu}')::text);
  perform pg_temp.k('veli özeti min-N: çocuk puanı 3 oydan azsa verilmez', r #> '{ozet,cocuk_puani,ortalama}' = 'null'::jsonb, (r #> '{ozet,cocuk_puani}')::text);
  perform pg_temp.k('veli özeti: cinsiyet kırılımı/izi yok', r::text !~* '(cinsiyet|gender|kiz_egilimli|erkek_egilimli|ilgi_egilimi)', '');
  insert into public.consents (cocuk_id, tur, created_at) values (oa, 'veli_riza_geri_cekildi', now() - interval '1 day');
  r := pg_temp.c(v1, format('public.okuma_veli_ozeti(%L,30)', oa));
  perform pg_temp.k('veli özeti: rıza geri çekilince tekrar {riza:false, ozet:null}', (r ->> 'riza')::boolean is false and r -> 'ozet' = 'null'::jsonb and r ->> 'riza_durumu' = 'geri_cekildi', r::text);
  insert into public.consents (cocuk_id, tur, created_at) values (oa, 'veli_acik_riza', now());
  delete from public.subscriptions where veli_id = v1;
  r := pg_temp.c(v1, format('public.okuma_veli_ozeti(%L,30)', oa));
  perform pg_temp.k('veli özeti: rıza yeniden verilince açılır, premium bitince temel', (r ->> 'riza')::boolean and not (r #>> '{ozet,detay}')::boolean, r::text);

  -- =================================================================
  -- M. ÖĞRETMEN SINIF ÖZETİ
  -- =================================================================
  r := pg_temp.c(t1, format('public.okuma_ogretmen_sinif_ozeti(%L,30)', k1));
  perform pg_temp.k('öğretmen: kendi sınıfı, ≥3 okuyan → toplulaştırma (işlem türüne göre, hedef, tema)',
    (r ->> 'yeterli')::boolean and (r #> '{ozet,soru_dogrulugu}') ? 'hatirlama' and (r #> '{ozet,tema_ilgisi}') is not null and (r #> '{ozet,zorlanilan_hedefler}') is not null,
    left(r::text, 400));
  perform pg_temp.k('öğretmen çıktısında öğrenci adı / kimliği yok',
    r::text !~ 'ZXQ_' and r::text not like '%' || oa::text || '%' and r::text not like '%' || ob::text || '%' and r::text !~* '(ogrenci_id|cinsiyet|full_name)', '');
  r := pg_temp.c(t1, format('public.okuma_ogretmen_sinif_ozeti(%L,30)', k3));
  perform pg_temp.k('öğretmen min-N: 2 okuyanlı sınıfta özet gizli (yeterli=false, ozet=null)', not (r ->> 'yeterli')::boolean and r -> 'ozet' = 'null'::jsonb and (r ->> 'okuyan_ogrenci')::int = 2, r::text);
  perform pg_temp.k('öğretmen: başkasının sınıfı / veli / öğrenci reddedilir; admin her sınıfı görür',
    pg_temp.h(t2, format('public.okuma_ogretmen_sinif_ozeti(%L,30)', k1), 'FORBIDDEN')
    and pg_temp.h(t1, format('public.okuma_ogretmen_sinif_ozeti(%L,30)', k2), 'FORBIDDEN')
    and pg_temp.h(v1, format('public.okuma_ogretmen_sinif_ozeti(%L,30)', k1), 'FORBIDDEN')
    and pg_temp.h(oa, format('public.okuma_ogretmen_sinif_ozeti(%L,30)', k1), 'FORBIDDEN')
    and pg_temp.c(adm1, format('public.okuma_ogretmen_sinif_ozeti(%L,30)', k1)) ->> 'yeterli' = 'true'
    and pg_temp.h(t1, format('public.okuma_ogretmen_sinif_ozeti(%L,30)', rastgele), 'FORBIDDEN'), pg_temp.son_hata());
  r := pg_temp.c(t2, format('public.okuma_ogretmen_sinif_ozeti(%L,30)', k2));
  perform pg_temp.k('öğretmen: boş sınıf güvenli (okuyan 0)', (r ->> 'okuyan_ogrenci')::int = 0 and not (r ->> 'yeterli')::boolean, r::text);

  -- =================================================================
  -- N. YÖNETİM: liste, karne (min-N), harita, hedef dört göz
  -- =================================================================
  r := pg_temp.c(adm1, 'public.okuma_yonetim_liste(null,null,100,0)');
  perform pg_temp.k('yönetim listesi: sürümler, denetim ve oturum sayısı',
    (r ->> 'toplam')::int = jsonb_array_length(r -> 'satirlar') and (r ->> 'toplam')::int >= 10, (r ->> 'toplam'));
  r := pg_temp.c(adm1, format('public.okuma_yonetim_liste(%L,4,100,0)', 'incelemede'));
  perform pg_temp.k('yönetim listesi filtresi (durum, sınıf)', (r ->> 'toplam')::int >= 1 and r::text like '%hik-dort%'
    and pg_temp.h(adm1, format('public.okuma_yonetim_liste(%L,null,10,0)', 'uydurma'), 'BAD_DURUM'), (r ->> 'toplam'));

  r := pg_temp.c(adm1, format('public.okuma_hikaye_karnesi(%L)', h3));
  perform pg_temp.k('karne min-N: 5''ten az öğrenci → yeterli=false, metrik yok',
    not (r #>> '{surumler,0,yeterli}')::boolean and not (r #> '{surumler,0}') ? 'sorular' and not (r #> '{surumler,0}') ? 'ort_yildiz', left(r::text, 300));
  r := pg_temp.c(adm1, format('public.okuma_hikaye_karnesi(%L)', h1));
  perform pg_temp.k('karne: hikâye-1 en az 5 öğrenci başlattı → metrikler gelir; ort. yıldız 5 oydan azsa gizli',
    (r #>> '{surumler,0,yeterli}')::boolean and (r #>> '{surumler,0,tamamlama_orani}') is not null and (r #> '{surumler,0}') ? 'sorular'
    and r #> '{surumler,0,ort_yildiz}' = 'null'::jsonb, left(r::text, 300));
  perform pg_temp.c(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'min_n', '3'));
  r := pg_temp.c(adm1, format('public.okuma_hikaye_karnesi(%L)', h1));
  perform pg_temp.k('karne (min_n=3): soru madde analizi doğru oranı + şık dağılımı',
    (r #>> '{surumler,0,sorular,0,yeterli}')::boolean and (r #>> '{surumler,0,sorular,0,dogru_orani}') is not null
    and (r #> '{surumler,0,sorular,0,secenek_dagilimi}') ? 'A' and r #> '{surumler,0,ort_yildiz}' <> 'null'::jsonb,
    (r #> '{surumler,0,sorular,0}')::text);
  perform pg_temp.k('karne: sorun kodları sayılır', r #>> '{surumler,0,sorun_kodlari,soru_hatali}' = '1', (r #> '{surumler,0,sorun_kodlari}')::text);
  perform pg_temp.c(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'min_n', '5'));

  r := pg_temp.c(adm1, 'public.okuma_icerik_bosluk_haritasi()');
  perform pg_temp.k('boşluk haritası: sınıf × tema × değer hücreleri (yayında/incelemede sayıları)',
    exists (select 1 from jsonb_array_elements(r -> 'hucreler') x where x ->> 'tema' = 'gizem' and x ->> 'deger' = 'D6' and (x ->> 'ana_sinif')::int = 4 and (x ->> 'yayinda')::int >= 1)
    and exists (select 1 from jsonb_array_elements(r -> 'hucreler') x where x ->> 'tema' = 'mizah' and (x ->> 'incelemede')::int = 1 and (x ->> 'yayinda')::int = 0)
    and jsonb_array_length(r -> 'degerler') = 20, left(r::text, 200));

  -- hedef kataloğu dört göz
  perform pg_temp.k('hedef onayı: oluşturan onaylayamaz (DORT_GOZ), ikinci yönetici onaylar',
    pg_temp.h(adm1, format('public.okuma_hedef_kaydet(%L,%L,%L,4,%L,true)', 'ha_x', 'lexeme', 'gizemli', 'C'), 'DORT_GOZ')
    and (pg_temp.c(adm2, format('public.okuma_hedef_kaydet(%L,%L,%L,4,%L,true)', 'ha_x', 'lexeme', 'gizemli', 'C')) ->> 'onayli')::boolean, pg_temp.son_hata());
  r := pg_temp.c(adm2, format('public.okuma_hedef_kaydet(%L,%L,%L,4,%L,false)', 'ha_x', 'lexeme', 'gizemli sözcüğü', 'C'));
  perform pg_temp.k('onaylı hedefin tanımı değişirse onay düşer', not (r ->> 'onayli')::boolean, r::text);
  begin
    update public.okuma_ogrenme_hedefleri set onayli = true, onaylayan_id = olusturan_id where id = 'hb_x';
    ok := false; t := 'hata yok';
  exception when others then ok := sqlstate = '23514'; t := sqlstate;
  end;
  perform pg_temp.k('tablo CHECK''i: kendi hedefini onaylama engelli', ok, t);

  -- =================================================================
  -- O. META TESTLER
  -- =================================================================
  -- serbest metin parametre yok: öğrenci/veli/öğretmen RPC'lerinde text yalnız kod parametreleri
  hatalar := '';
  for prm in
    select pr.proname, a.ad, format_type(a.tip, null) as tip
      from pg_proc pr join pg_namespace ns on ns.oid = pr.pronamespace,
           lateral (select unnest(pr.proargnames) as ad, unnest(string_to_array(pr.proargtypes::text, ' ')::oid[]) as tip) a
     where ns.nspname = 'public' and pr.proname like 'okuma\_%'
       and pr.proname in ('okuma_ozellik_durumu', 'okuma_katalog_filtre', 'okuma_hikaye_getir', 'okuma_oturum_baslat',
                          'okuma_ilerleme_kaydet', 'okuma_cevap_kontrol', 'okuma_oturum_bitir', 'okuma_geri_bildirim_gonder',
                          'okuma_seri_ve_oneri', 'okuma_pdf_hakki_kullan', 'okuma_degerleri_listele',
                          'okuma_veli_degerleri_getir', 'okuma_veli_degerleri_ayarla', 'okuma_veli_ozeti',
                          'okuma_ogretmen_sinif_ozeti')
  loop
    if prm.tip not in ('uuid', 'integer', 'boolean', 'text', 'text[]') then
      hatalar := hatalar || prm.proname || '.' || prm.ad || ' tipi ' || prm.tip || E'\n';
    elsif prm.tip in ('text', 'text[]') and prm.ad not in (
        'p_tema', 'p_ders', 'p_deger', 'p_kahraman_turu', 'p_okuma_modu', 'p_istemci_anahtari', 'p_soru_id', 'p_secenek_id',
        'p_dokunulan', 'p_iyilestirme_kodlari', 'p_sorun_kodlari', 'p_degerler') then
      hatalar := hatalar || prm.proname || '.' || prm.ad || ' serbest metin olabilir' || E'\n';
    end if;
  end loop;
  perform pg_temp.k('meta: öğrenci/veli/öğretmen RPC''lerinde serbest metin parametre yok (yalnız kod parametreleri)', hatalar = '', hatalar);

  perform pg_temp.k('serbest metin değerleri kod parametrelerinde reddedilir (ad sızıntısı yolu yok)',
    pg_temp.h(oa, format('public.okuma_katalog_filtre(null,%L)', 'Ayşe''nin hikayesi'), 'BAD_TEMA')
    and pg_temp.h(oa, format('public.okuma_katalog_filtre(null,null,%L)', 'Efe'), 'BAD_DERS')
    and pg_temp.h(oa, format('public.okuma_katalog_filtre(null,null,null,%L)', 'Efe'), 'BAD_DEGER')
    and pg_temp.h(oa, format('public.okuma_katalog_filtre(null,null,null,null,1,5,%L)', 'Efe'), 'BAD_KAHRAMAN_TURU'), pg_temp.son_hata());

  -- hiçbir okuma_ tablosunda ad / cinsiyet kolonu yok
  select string_agg(table_name || '.' || column_name, ',') into t from information_schema.columns
   where table_schema = 'public' and table_name like 'okuma\_%'
     and column_name ~* '(cinsiyet|gender|sex|cocuk_ad|kahraman_ad|yoldas_ad|full_name|ad_soyad|isim|soyad|email|eposta)';
  perform pg_temp.k('meta: okuma_* tablolarında cinsiyet / ad / e-posta kolonu yok', t is null, coalesce(t, ''));

  -- tüm okuma fonksiyonlarında search_path sabit; RPC'ler SECURITY DEFINER
  select string_agg(pr.proname, ',') into t from pg_proc pr join pg_namespace ns on ns.oid = pr.pronamespace
   where ns.nspname = 'public' and pr.proname like '%okuma\_%'
     and not exists (select 1 from unnest(coalesce(pr.proconfig, '{}')) c where c like 'search_path=%');
  perform pg_temp.k('meta: tüm okuma fonksiyonlarında search_path sabit', t is null, coalesce(t, ''));
  select string_agg(pr.proname, ',') into t from pg_proc pr join pg_namespace ns on ns.oid = pr.pronamespace
   where ns.nspname = 'public' and pr.proname like 'okuma\_%' and not pr.prosecdef;
  perform pg_temp.k('meta: okuma_* RPC''lerinin hepsi SECURITY DEFINER', t is null, coalesce(t, ''));

  -- yönetim işlemleri denetim günlüğüne yazar
  select string_agg(i, ',') into t from unnest(array[
    'okuma_paket_ice_aktarildi', 'okuma_paket_kuru', 'okuma_paket_reddedildi', 'okuma_paket_tekrar', 'okuma_surum_durum',
    'okuma_yonetim_liste', 'okuma_surum_icerik_getir', 'okuma_ayar_yaz', 'okuma_sozluk_kaydet', 'okuma_hedef_kaydet',
    'okuma_icerik_bosluk_haritasi', 'okuma_hikaye_karnesi']) i
   where not exists (select 1 from public.admin_audit_log l where l.islem = i);
  perform pg_temp.k('meta: tüm yönetim işlemleri log_admin_action kaydı bırakır', t is null, 'eksik: ' || coalesce(t, ''));

  -- cascade silme: profil silinince öğrenciye ait her şey gider, içerik kalır
  perform pg_temp.c(v4, format('public.okuma_veli_degerleri_ayarla(%L,%L::text[])', off, '{D2}'));
  perform pg_temp.c(off, format('public.okuma_geri_bildirim_gonder(%L,4,%L::text[],false,false,%L::text[])',
    (select id from public.okuma_oturumlari where ogrenci_id = off limit 1), '{}', '{}'));
  update public.app_settings set value = '{"aktif": false, "ucretsiz_gunluk_soru": 20}' where key = 'premium_gating';
  perform pg_temp.c(off, format('public.okuma_pdf_hakki_kullan(%L)', h1));
  insert into public.okuma_ogrenci_hedef_durumu (ogrenci_id, hedef_id) values (off, 'ha_x') on conflict do nothing;
  insert into public.okuma_cevaplari (oturum_id, soru_id, secenek_id, dogru, beceri)
    select id, 's1', 'A', false, 'hatirlama' from public.okuma_oturumlari where ogrenci_id = off limit 1;
  select (select count(*) from public.okuma_oturumlari where ogrenci_id = off)
       + (select count(*) from public.okuma_cevaplari c join public.okuma_oturumlari o on o.id = c.oturum_id where o.ogrenci_id = off)
       + (select count(*) from public.okuma_geri_bildirimleri g join public.okuma_oturumlari o on o.id = g.oturum_id where o.ogrenci_id = off)
       + (select count(*) from public.okuma_ogrenci_hedef_durumu where ogrenci_id = off)
       + (select count(*) from public.okuma_pdf_kullanimlari where kullanici_id = off)
       + (select count(*) from public.okuma_cocuk_tercihleri where cocuk_id = off) into n;
  select count(*) into n2 from public.okuma_hikaye_surumleri;
  delete from auth.users where id = off;
  select (select count(*) from public.okuma_oturumlari where ogrenci_id = off)
       + (select count(*) from public.okuma_ogrenci_hedef_durumu where ogrenci_id = off)
       + (select count(*) from public.okuma_pdf_kullanimlari where kullanici_id = off)
       + (select count(*) from public.okuma_cocuk_tercihleri where cocuk_id = off)
       + (select count(*) from public.okuma_cevaplari c where not exists (select 1 from public.okuma_oturumlari o where o.id = c.oturum_id))
       + (select count(*) from public.okuma_geri_bildirimleri g where not exists (select 1 from public.okuma_oturumlari o where o.id = g.oturum_id)) into cagri_once;
  perform pg_temp.k('cascade: profil silinince oturum / cevap / geri bildirim / hedef durumu / PDF / tercih gider (önce ' || n || ' satır)',
    n >= 6 and cagri_once = 0 and (select count(*) from public.okuma_hikaye_surumleri) = n2, 'önce ' || n || ' sonra ' || cagri_once);

  -- gerçek paket uçtan uca: yayınla, öğrenciye ver, anahtar sızmıyor
  r := pg_temp.yayinla(adm1, adm2, kd);
  hk := (r ->> 'hikaye_id')::uuid;
  r2 := pg_temp.c(oc, format('public.okuma_hikaye_getir(%L)', hk));
  perform pg_temp.k('gerçek paket (kayip-defter) yayınlanır; öğrenciye 4 soru, anahtarsız teslim edilir',
    jsonb_array_length(r2 #> '{paket,sorular}') = 4 and not pg_temp.anahtar_var(r2, 'dogru') and not pg_temp.anahtar_var(r2, 'aciklama')
    and r2::text not like '%Defter, kütüphanenin en arka rafındaki%', left(r2::text, 160));
  -- =================================================================
  -- P. SÖZLÜK (20261050000400) ve export_my_data 'okuma' (20261050000500)
  -- =================================================================
  perform pg_temp.c(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'aktif', 'true'));
  perform pg_temp.c(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'pilot_siniflari', '[]'));
  perform pg_temp.c(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'izinli_kullanicilar', '[]'));

  -- yetki
  perform pg_temp.k('sözlük: öğrenci / veli / anon içe aktaramaz (42501)',
    pg_temp.h(oa, format('public.okuma_sozluk_ice_aktar(%L::jsonb,false)', pg_temp.soz()))
    and pg_temp.h(v1, format('public.okuma_sozluk_ice_aktar(%L::jsonb,false)', pg_temp.soz()))
    and pg_temp.h(null, format('public.okuma_sozluk_ice_aktar(%L::jsonb,false)', pg_temp.soz())), pg_temp.son_hata());
  perform pg_temp.k('sözlük: tablolara istemci erişimi yok (RLS + revoke)',
    not exists (select 1 from pg_class c where c.relname like 'okuma\_sozluk\_%' and c.relkind = 'r'
                 and (has_table_privilege('anon', c.oid, 'select,insert,update,delete')
                      or has_table_privilege('authenticated', c.oid, 'select,insert,update,delete')))
    and (select count(*) from pg_class c where c.relname like 'okuma\_sozluk\_%' and c.relkind = 'r' and c.relrowsecurity) = 4, '');

  -- kuru çalıştırma yazmaz
  r := pg_temp.c(adm1, format('public.okuma_sozluk_ice_aktar(%L::jsonb,true)', pg_temp.soz()));
  select count(*) into n from public.okuma_sozluk_girdileri;
  perform pg_temp.k('sözlük: kuru çalıştırma geçerli, hiçbir şey yazmaz',
    (r ->> 'gecerli')::boolean and not (r ->> 'yazildi')::boolean and (r -> 'ozet' ->> 'girdi_yeni') = '4' and n = 0, r::text);

  -- geçersiz yükler reddedilir (yazım yok)
  r := pg_temp.c(adm1, format('public.okuma_sozluk_ice_aktar(%L::jsonb,false)',
        jsonb_set(pg_temp.soz(), '{girdiler,0,tur}', '"yanlis"')));
  r2 := pg_temp.c(adm1, format('public.okuma_sozluk_ice_aktar(%L::jsonb,false)',
        jsonb_set(pg_temp.soz(), '{girdiler,1,anlam}', '"kısa"')));
  r3 := pg_temp.c(adm1, format('public.okuma_sozluk_ice_aktar(%L::jsonb,false)',
        pg_temp.soz() || '{"fazla": 1}'::jsonb));
  perform pg_temp.k('sözlük: geçersiz tür / kısa anlam / tanımsız alan reddedilir, tabloya yazılmaz',
    not (r ->> 'gecerli')::boolean and not (r2 ->> 'gecerli')::boolean and not (r3 ->> 'gecerli')::boolean
    and (select count(*) from public.okuma_sozluk_girdileri) = 0, r::text || r2::text || r3::text);
  r := pg_temp.c(adm1, format('public.okuma_sozluk_ice_aktar(%L::jsonb,false)',
        jsonb_set(pg_temp.soz(), '{yuvalar,0,adaylar,0,girdi}', '"yok_boyle_girdi"')));
  r2 := pg_temp.c(adm1, format('public.okuma_sozluk_ice_aktar(%L::jsonb,false)',
        jsonb_set(pg_temp.soz(), '{yuvalar,1,adaylar,0,girdi}', '"t_gizemli"')));
  perform pg_temp.k('sözlük: bilinmeyen aday ve tür uyuşmayan aday reddedilir',
    not (r ->> 'gecerli')::boolean and r::text like '%bilinmiyor%' and not (r2 ->> 'gecerli')::boolean and r2::text like '%uyuşmuyor%', r::text || r2::text);
  r := pg_temp.c(adm1, format('public.okuma_sozluk_ice_aktar(%L::jsonb,false)',
        pg_temp.soz('taslak', 'Ne olduğu anlaşılamayan, sır taşıyan.', 'taslak',
          jsonb_build_array(jsonb_build_object('kelime', 'haç', 'ikon', E'\u271D\uFE0F')))));
  r2 := pg_temp.c(adm1, format('public.okuma_sozluk_ice_aktar(%L::jsonb,false)',
        pg_temp.soz('taslak', 'Ne olduğu anlaşılamayan, sır taşıyan.', 'taslak',
          jsonb_build_array(jsonb_build_object('kelime', 'ev', 'ikon', 'ev')))));
  perform pg_temp.k('sözlük: yasaklı simge (haç) ve harf içeren simge reddedilir',
    not (r ->> 'gecerli')::boolean and r::text like '%yasaklı%' and not (r2 ->> 'gecerli')::boolean and r2::text like '%ikon geçersiz%', r::text || r2::text);

  -- gerçek içe aktarma (adm1 oluşturur)
  r := pg_temp.c(adm1, format('public.okuma_sozluk_ice_aktar(%L::jsonb,false)',
        pg_temp.soz('taslak', 'Ne olduğu anlaşılamayan, sır taşıyan.', 'taslak',
          jsonb_build_array(jsonb_build_object('kelime', 'deniz', 'ikon', E'\U0001F30A'), jsonb_build_object('kelime', 'kitap', 'ikon', E'\U0001F4D6')))));
  perform pg_temp.k('sözlük: gerçek içe aktarma yazar (4 girdi, 2 yuva, 4 aday, 2 kavram)',
    (r ->> 'yazildi')::boolean and (select count(*) from public.okuma_sozluk_girdileri) = 4
    and (select count(*) from public.okuma_sozluk_yuvalari) = 2 and (select count(*) from public.okuma_sozluk_adaylari) = 4
    and (select count(*) from public.okuma_sozluk_kavramlari) = 2, r::text);

  -- dört göz
  r := pg_temp.c(adm1, format('public.okuma_sozluk_ice_aktar(%L::jsonb,false)', pg_temp.soz('onayli')));
  perform pg_temp.k('sözlük dört göz: oluşturan kendi girdisini onaylayamaz (DORT_GOZ)',
    not (r ->> 'gecerli')::boolean and r::text like '%DORT_GOZ%' and (select durum from public.okuma_sozluk_girdileri where id = 't_gizemli') = 'taslak', r::text);
  r := pg_temp.c(adm2, format('public.okuma_sozluk_ice_aktar(%L::jsonb,false)', pg_temp.soz('onayli', 'Ne olduğu anlaşılamayan, sır taşıyan.', 'onayli')));
  perform pg_temp.k('sözlük dört göz: ikinci yönetici onaylar (onaylayan ≠ oluşturan)',
    (r ->> 'gecerli')::boolean and (select durum = 'onayli' and onaylayan_id = adm2 and olusturan_id = adm1
                                      from public.okuma_sozluk_girdileri where id = 't_gizemli')
    and (select durum from public.okuma_sozluk_girdileri where id = 't_tuhaf') = 'taslak', r::text);
  r := pg_temp.c(adm2, format('public.okuma_sozluk_ice_aktar(%L::jsonb,false)', pg_temp.soz('onayli', 'Değiştirilmiş anlam metni burada.', 'onayli')));
  perform pg_temp.k('sözlük dört göz: içeriği değiştirip aynı çağrıda onaylamak yasak',
    not (r ->> 'gecerli')::boolean and r::text like '%DORT_GOZ%'
    and (select anlam from public.okuma_sozluk_girdileri where id = 't_gizemli') = 'Ne olduğu anlaşılamayan, sır taşıyan.', r::text);
  r := pg_temp.c(adm2, format('public.okuma_sozluk_ice_aktar(%L::jsonb,false)', pg_temp.soz('taslak', 'Değiştirilmiş anlam metni burada.', 'onayli')));
  perform pg_temp.k('sözlük dört göz: içerik değişince onay düşer, değiştiren oluşturan olur',
    (r ->> 'gecerli')::boolean and (select durum = 'taslak' and onaylayan_id is null and olusturan_id = adm2
                                      from public.okuma_sozluk_girdileri where id = 't_gizemli'), r::text);
  r := pg_temp.c(adm1, format('public.okuma_sozluk_ice_aktar(%L::jsonb,false)', pg_temp.soz('onayli', 'Değiştirilmiş anlam metni burada.', 'onayli')));
  perform pg_temp.k('sözlük dört göz: karşı yönetici (adm1) onaylayınca geçerli; mevcut onaylı girdi korunur',
    (r ->> 'gecerli')::boolean and (select durum = 'onayli' and onaylayan_id = adm1 and olusturan_id = adm2
                                      from public.okuma_sozluk_girdileri where id = 't_gizemli')
    and (select onaylayan_id from public.okuma_sozluk_girdileri where id = 't_dar') = adm2, r::text);

  -- öğrenci RPC: hikâye yayında (kayip-defter) — yuvalar: gizemli_sifat, el_ele, isbirligi
  r := pg_temp.c(oa, format('public.okuma_sozluk_getir(%L)', hk));
  r2 := pg_temp.c(ob, format('public.okuma_sozluk_getir(%L)', hk));
  perform pg_temp.k('sözlük getir: yalnız onaylı + sınıfa uyan aday (taslak ve sınıf dışı gizli), anlam alanıyla',
    jsonb_array_length(r -> 'yuvalar') = 1 and r #>> '{yuvalar,0,yuva}' = 'gizemli_sifat'
    and jsonb_array_length(r #> '{yuvalar,0,adaylar}') = 1 and r #>> '{yuvalar,0,adaylar,0,id}' = 't_gizemli'
    and r #>> '{yuvalar,0,adaylar,0,anlam}' = 'Değiştirilmiş anlam metni burada.' and not (r ->> 'onizleme')::boolean
    and jsonb_array_length(r -> 'kavramlar') = 2, left(r::text, 400));
  perform pg_temp.k('sözlük getir: öğrenci A/B aynı içeriği görür; kişisel / iç alan yok (olusturan, onaylayan, durum)',
    r = r2 and not pg_temp.anahtar_var(r, 'olusturan_id') and not pg_temp.anahtar_var(r, 'onaylayan_id') and not pg_temp.anahtar_var(r, 'durum')
    and r::text not like '%ZXQ_%', left(r2::text, 200));
  update public.profiles set sinif = 2 where id = oa;
  r3 := pg_temp.c(oa, format('public.okuma_sozluk_getir(%L)', hk));
  update public.profiles set sinif = 4 where id = oa;
  perform pg_temp.k('sözlük getir: sınıf 2 öğrencisi yalnız 1-2. sınıf adayını görür (t_dar)',
    jsonb_array_length(r3 -> 'yuvalar') = 1 and r3 #>> '{yuvalar,0,adaylar,0,id}' = 't_dar'
    and jsonb_array_length(r3 #> '{yuvalar,0,adaylar}') = 1, left(r3::text, 300));
  perform pg_temp.k('sözlük getir: hikâye yoksa / null ise boş (hata yok)',
    jsonb_array_length(pg_temp.c(oa, format('public.okuma_sozluk_getir(%L)', rastgele)) -> 'yuvalar') = 0
    and jsonb_array_length(pg_temp.c(oa, format('public.okuma_sozluk_getir(%L)', rastgele)) -> 'kavramlar') = 0
    and jsonb_array_length(pg_temp.c(oa, 'public.okuma_sozluk_getir(null)') -> 'yuvalar') = 0, '');
  perform pg_temp.k('sözlük getir: veli ve anon reddedilir (42501)',
    pg_temp.h(v1, format('public.okuma_sozluk_getir(%L)', hk)) and pg_temp.h(null, format('public.okuma_sozluk_getir(%L)', hk)), pg_temp.son_hata());
  perform pg_temp.c(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'aktif', 'false'));
  r3 := pg_temp.c(oa, format('public.okuma_sozluk_getir(%L)', hk));
  perform pg_temp.c(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'aktif', 'true'));
  perform pg_temp.k('sözlük getir: özellik bayrağı kapalıyken boş (yetkisiz)',
    jsonb_array_length(r3 -> 'yuvalar') = 0 and jsonb_array_length(r3 -> 'kavramlar') = 0, left(r3::text, 200));

  -- önizleme / taslak ayrımı: yalnız incelemede olan hikâye
  r := pg_temp.ice(adm1, jsonb_set(kd, '{hikaye,slug}', '"kayip-defter-onizleme"'));
  perform pg_temp.incele(adm1, adm2, (r ->> 'surum_id')::uuid);
  h5 := (r ->> 'hikaye_id')::uuid;
  perform pg_temp.c(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'izinli_kullanicilar', to_jsonb(array[od])::text));
  r2 := pg_temp.c(od, format('public.okuma_sozluk_getir(%L)', h5));
  r3 := pg_temp.c(oa, format('public.okuma_sozluk_getir(%L)', h5));
  perform pg_temp.c(adm1, format('public.okuma_ayar_yaz(%L,%L::jsonb)', 'izinli_kullanicilar', '[]'));
  perform pg_temp.k('sözlük getir: incelemedeki hikâyede önizleme hesabı taslak adayları da görür (onayli=false), normal öğrenci boş',
    (r2 ->> 'onizleme')::boolean and jsonb_array_length(r2 -> 'yuvalar') = 2
    and exists (select 1 from jsonb_path_query(r2, '$.yuvalar[*].adaylar[*] ? (@.id == "t_tuhaf" && @.onayli == false)'))
    and exists (select 1 from jsonb_path_query(r2, '$.yuvalar[*].adaylar[*] ? (@.id == "t_gizemli" && @.onayli == true)'))
    and jsonb_array_length(r3 -> 'yuvalar') = 0 and jsonb_array_length(r3 -> 'kavramlar') = 0, left(r2::text, 500));

  -- savunma: tabloya doğrudan girmiş yasaklı simge çıktıdan süzülür
  insert into public.okuma_sozluk_kavramlari (kelime, ikon) values ('agac_noel', E'\U0001F384');
  r := pg_temp.c(oa, format('public.okuma_sozluk_getir(%L)', hk));
  delete from public.okuma_sozluk_kavramlari where kelime = 'agac_noel';
  perform pg_temp.k('sözlük getir: yasaklı simge kodu çıktıdan süzülür', jsonb_array_length(r -> 'kavramlar') = 2
    and r::text not like '%' || E'\U0001F384' || '%', left(r::text, 200));

  -- gerçek örnek sözlük (atölye çıktısı) kuru ve gerçek içe aktarma
  if exists (select 1 from public.test_sozlukler where ad = 'sozluk.ornek') then
    r := pg_temp.c(adm1, format('public.okuma_sozluk_ice_aktar(%L::jsonb,true)', (select icerik from public.test_sozlukler where ad = 'sozluk.ornek')));
    -- Örnekte tek şema ihlali var: id 'sabreden_derviş' (ş) — şema ^[a-z0-9_]+$ ister; sunucu bunu yakalar.
    r2 := pg_temp.c(adm1, format('public.okuma_sozluk_ice_aktar(%L::jsonb,true)',
            replace((select icerik::text from public.test_sozlukler where ad = 'sozluk.ornek'), 'sabreden_derviş', 'sabreden_dervis')::jsonb));
    perform pg_temp.k('sözlük: gerçek örnek sözlük yalnız id "sabreden_derviş" nedeniyle reddedilir; düzeltilince şemaya uyar (kuru)',
      not (r ->> 'gecerli')::boolean and jsonb_array_length(r -> 'hatalar') = 2 and r::text like '%girdiler[23].id%'
      and (r2 ->> 'gecerli')::boolean, left(r::text, 300) || ' || ' || left(r2::text, 300));
  end if;

  select count(*) into n from public.admin_audit_log where islem = 'okuma_sozluk_ice_aktar';
  perform pg_temp.k('sözlük: her içe aktarma denetim günlüğüne yazılır', n >= 15, 'kayıt: ' || n);

  -- export_my_data: 'okuma' anahtarı, mevcut anahtarlar korunur, yalnız kendi verisi, anahtar sızmaz
  select count(*) into n from public.okuma_cevaplari c join public.okuma_oturumlari o on o.id = c.oturum_id where o.ogrenci_id = ob;
  if n = 0 then
    insert into public.okuma_cevaplari (oturum_id, soru_id, secenek_id, dogru, beceri)
      select id, 's9', 'C', true, 'cikarim' from public.okuma_oturumlari where ogrenci_id = ob limit 1;
  end if;
  insert into public.okuma_cocuk_tercihleri (cocuk_id, degerler) values (ob, '{D4}') on conflict (cocuk_id) do update set degerler = '{D4}';
  ex := pg_temp.c(ob, 'public.export_my_data()');
  ex2 := pg_temp.c(oa, 'public.export_my_data()');
  perform pg_temp.k('export: mevcut tüm anahtarlar korunur ve yeni okuma anahtarı var',
    ex ?& array['olusturulma_tarihi', 'profil', 'istatistikler', 'cevaplar', 'rozetler', 'bildirimler', 'xp_gecmisi', 'onaylar', 'kelime', 'okuma']
    and ex -> 'okuma' ?& array['oturumlari', 'cevaplari', 'geri_bildirimleri', 'ogrenci_hedef_durumu', 'pdf_kullanimlari', 'cocuk_tercihleri'],
    (select string_agg(k, ',') from jsonb_object_keys(ex) k));
  perform pg_temp.k('export: okuma verisi eksiksiz (oturum / cevap sayısı tablolarla eşit) ve çocuk tercihi gelir',
    jsonb_array_length(ex #> '{okuma,oturumlari}') = (select count(*) from public.okuma_oturumlari where ogrenci_id = ob)
    and jsonb_array_length(ex #> '{okuma,oturumlari}') >= 1
    and jsonb_array_length(ex #> '{okuma,cevaplari}') = (select count(*) from public.okuma_cevaplari c join public.okuma_oturumlari o on o.id = c.oturum_id where o.ogrenci_id = ob)
    and jsonb_array_length(ex #> '{okuma,cevaplari}') >= 1
    and ex #>> '{okuma,cocuk_tercihleri,degerler,0}' = 'D4',
    'oturum ' || jsonb_array_length(ex #> '{okuma,oturumlari}') || ' cevap ' || jsonb_array_length(ex #> '{okuma,cevaplari}'));
  perform pg_temp.k('export: başkasının verisi yok (A ile B oturum kümeleri ayrık; veli çocuğunun okuma verisini almaz)',
    not exists (select 1 from jsonb_array_elements(ex #> '{okuma,oturumlari}') x join jsonb_array_elements(ex2 #> '{okuma,oturumlari}') y on x ->> 'oturum_id' = y ->> 'oturum_id')
    and not exists (select 1 from jsonb_array_elements(ex2 #> '{okuma,oturumlari}') y
                     where (y ->> 'oturum_id')::uuid not in (select id from public.okuma_oturumlari where ogrenci_id = oa))
    and ex2::text not like '%ZXQ_BORA_ADI%'
    and jsonb_array_length(pg_temp.c(v1, 'public.export_my_data()') #> '{okuma,oturumlari}') = 0
    and jsonb_array_length(pg_temp.c(v1, 'public.export_my_data()') #> '{okuma,cevaplari}') = 0
    and (pg_temp.c(v1, 'public.export_my_data()') #> '{okuma,cocuk_tercihleri}') = 'null'::jsonb, '');
  perform pg_temp.k('export: cevap anahtarı sızmaz (cevaplarda dogru / aciklama anahtarı, gizli açıklama metni, iç alanlar yok)',
    not pg_temp.anahtar_var(ex #> '{okuma,cevaplari}', 'dogru') and not pg_temp.anahtar_var(ex -> 'okuma', 'aciklama')
    and not pg_temp.anahtar_var(ex #> '{okuma,geri_bildirimleri}', 'dogru') and not pg_temp.anahtar_var(ex #> '{okuma,oturumlari}', 'dogru_cevap')
    and not pg_temp.anahtar_var(ex -> 'okuma', 'istemci_anahtari') and not pg_temp.anahtar_var(ex -> 'okuma', 'surum_id')
    and not pg_temp.anahtar_var(ex -> 'okuma', 'icerik') and ex::text not like '%GIZLI_ACIKLAMA%'
    and exists (select 1 from jsonb_array_elements(ex #> '{okuma,cevaplari}') c where c ? 'dogru_mu' and c ? 'secilen_sik'), left((ex -> 'okuma')::text, 300));
  perform pg_temp.k('export: anon çağıramaz, işlev güvenlik kalıbı korunur (definer, sabit search_path)',
    pg_temp.h(null, 'public.export_my_data()')
    and (select p.prosecdef and exists (select 1 from unnest(p.proconfig) c where c like 'search_path=%')
                and not has_function_privilege('anon', p.oid, 'execute') and has_function_privilege('authenticated', p.oid, 'execute')
           from pg_proc p where p.proname = 'export_my_data' and p.pronamespace = 'public'::regnamespace), pg_temp.son_hata());

  -- ---------------- Düşün alanı (20261051000000): isteğe bağlı hikaye.dusun ----------------
  perform pg_temp.k('düşün: dusun alanı olmayan gerçek paket doğrulayıcıdan geçer (geriye uyum)',
    exists (select 1 from public.test_paketler where public._okuma_paket_hatalari(icerik) = '[]'::jsonb), '');
  perform pg_temp.k('düşün: 2 geçerli soru kabul edilir',
    (select public._okuma_paket_hatalari(jsonb_set(icerik, '{hikaye,dusun}', '[{"id":"d1","metin":"Bu sözü kendi hayatından düşün."},{"id":"d2","metin":"Sabrın sonunda ne bulunur?"}]'::jsonb)) = '[]'::jsonb
       from public.test_paketler where public._okuma_paket_hatalari(icerik) = '[]'::jsonb order by ad limit 1), '');
  perform pg_temp.k('düşün: 4 kayıt reddedilir (en fazla 3)',
    (select public._okuma_paket_hatalari(jsonb_set(icerik, '{hikaye,dusun}', '[{"id":"d1","metin":"Birinci düşünme sorusu."},{"id":"d2","metin":"İkinci düşünme sorusu."},{"id":"d3","metin":"Üçüncü düşünme sorusu."},{"id":"d4","metin":"Dördüncü düşünme sorusu."}]'::jsonb))::text like '%en fazla 3%'
       from public.test_paketler where public._okuma_paket_hatalari(icerik) = '[]'::jsonb order by ad limit 1), '');
  perform pg_temp.k('düşün: dusun dizi değilse reddedilir',
    (select public._okuma_paket_hatalari(jsonb_set(icerik, '{hikaye,dusun}', '{"id":"d1","metin":"Tek nesne, dizi değil."}'::jsonb))::text like '%en fazla 3%'
       from public.test_paketler where public._okuma_paket_hatalari(icerik) = '[]'::jsonb order by ad limit 1), '');
  perform pg_temp.k('düşün: 10 karakterden kısa metin reddedilir',
    (select public._okuma_paket_hatalari(jsonb_set(icerik, '{hikaye,dusun}', '[{"id":"d1","metin":"Kısa"}]'::jsonb))::text like '%hikaye.dusun.metin%'
       from public.test_paketler where public._okuma_paket_hatalari(icerik) = '[]'::jsonb order by ad limit 1), '');
  perform pg_temp.k('düşün: bilinmeyen alan ve büyük harfli id reddedilir',
    (select public._okuma_paket_hatalari(jsonb_set(icerik, '{hikaye,dusun}', '[{"id":"d1","metin":"Yeterince uzun bir düşünme sorusu.","ekstra":1}]'::jsonb))::text like '%tanımsız alan%'
       and public._okuma_paket_hatalari(jsonb_set(icerik, '{hikaye,dusun}', '[{"id":"D1","metin":"Yeterince uzun bir düşünme sorusu."}]'::jsonb))::text like '%hikaye.dusun.id%'
       from public.test_paketler where public._okuma_paket_hatalari(icerik) = '[]'::jsonb order by ad limit 1), '');
end;
$fn$;

-- Sonuçları döndüren sarmalayıcı (kos.mjs bunu çağırır)
create or replace function pg_temp.okuma_testleri_sonuc()
returns table (no integer, senaryo text, gecti boolean, detay text)
language plpgsql as $fn$
begin
  perform pg_temp.okuma_testleri();
  return query select s.no, s.senaryo, s.gecti, s.detay from pg_temp.sonuc s order by s.no;
end $fn$;
