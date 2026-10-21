-- =====================================================================
-- Okuma Dünyası — sözlük katmanı: kelime / deyim / atasözü yuvaları
--
--   * Hikâye paketi {kelime:yuva}, {atasozu:yuva}, [[deyim:yuva]] yuvalarını parça (t + yuva) olarak taşır;
--     anlam ve aday listesi bu migration'ın tablolarından gelir (sozluk.v1 şeması).
--   * Tablolarda RLS açık, istemci rollerinin doğrudan erişimi YOK (yalnız SECURITY DEFINER RPC).
--   * Girdinin 'onayli' olması dört göz kuralına bağlıdır: oluşturan ≠ onaylayan.
--   * Öğrenci RPC'si serbest metin almaz (yalnız uuid). Yetkisiz / hikâye yoksa boş döner.
--   * Ek-only: mevcut nesnelere dokunmaz. Dağıtım ayrı onayla yapılır.
-- Bağımlılık: 20261050000000..300 (okuma_dunyasi).
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Tablolar
-- ---------------------------------------------------------------------
create table public.okuma_sozluk_girdileri (
  id             text primary key check (id ~ '^[a-z0-9_]{1,80}$'),
  tur            text not null check (tur in ('kelime', 'deyim', 'atasozu')),
  yazim          text not null check (length(yazim) between 1 and 120),
  anlam          text not null check (length(anlam) between 5 and 200),
  sinif_alt      smallint not null check (sinif_alt between 1 and 8),
  sinif_ust      smallint not null check (sinif_ust between 1 and 8),
  kaynak_turu    text not null check (kaynak_turu in ('editor_onerisi', 'meb_kaynakli')),
  kazanim_kodu   text check (kazanim_kodu is null or length(kazanim_kodu) between 1 and 40),
  durum          text not null default 'taslak' check (durum in ('taslak', 'incelemede', 'onayli', 'arsiv')),
  olusturan_id   uuid references public.profiles (id) on delete set null,
  onaylayan_id   uuid references public.profiles (id) on delete set null,
  onaylandi_at   timestamptz,
  guncellendi_at timestamptz not null default now(),
  constraint okuma_sozluk_girdi_aralik check (sinif_alt <= sinif_ust),
  constraint okuma_sozluk_girdi_dort_goz check (
    durum <> 'onayli'
    or (onaylayan_id is not null and onaylayan_id is distinct from olusturan_id)
  )
);
create index okuma_sozluk_girdi_durum_idx on public.okuma_sozluk_girdileri (durum, tur);

create table public.okuma_sozluk_yuvalari (
  tur            text not null check (tur in ('kelime', 'deyim', 'atasozu')),
  ad             text not null check (ad ~ '^[a-z0-9_]{1,80}$'),
  guncellendi_at timestamptz not null default now(),
  primary key (tur, ad)
);

create table public.okuma_sozluk_adaylari (
  yuva_tur text not null,
  yuva_ad  text not null,
  girdi_id text not null references public.okuma_sozluk_girdileri (id),
  sira     smallint not null check (sira >= 0),
  primary key (yuva_tur, yuva_ad, girdi_id),
  foreign key (yuva_tur, yuva_ad) references public.okuma_sozluk_yuvalari (tur, ad) on delete cascade
);
create index okuma_sozluk_aday_girdi_idx on public.okuma_sozluk_adaylari (girdi_id);

create table public.okuma_sozluk_kavramlari (
  kelime text primary key check (length(kelime) between 1 and 60),
  ikon   text not null check (length(ikon) between 1 and 8)
);

do $$
declare
  t text;
begin
  foreach t in array array['okuma_sozluk_girdileri', 'okuma_sozluk_yuvalari', 'okuma_sozluk_adaylari', 'okuma_sozluk_kavramlari']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from public, anon, authenticated', t);
    execute format('create policy %I on public.%I for select to authenticated using (public.is_admin())',
                   t || '_admin_select', t);
  end loop;
end $$;

-- ---------------------------------------------------------------------
-- 2. Simge (emoji) yardımcısı: sunucuda yalnız basit kontrol.
--    Kesin yasak kodlar ikon_kutuphanesi/KURALLAR.json kesin_yasak.kodlar listesinden alınmıştır
--    (FE0F varyasyon seçicisi atılarak). Katalog / inceleme kontrolü istemci ve atölye işidir.
-- ---------------------------------------------------------------------
create or replace function public._okuma_ikon_yasakli(p text)
returns boolean
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_yasak text[] := array[
    '1F376','1F377','1F378','1F379','1F37A','1F37B','1F37E','1F383','1F384','1F385','1F38C','1F3B0','1F3E9',
    '1F3F3-200D-1F308','1F3F3-200D-26A7','1F3F4','1F3F4-200D-2620','1F416','1F437','1F43D','1F459','1F46C',
    '1F46D','1F46F','1F479','1F47A','1F47B','1F47F','1F480','1F48B','1F48D','1F48F','1F491','1F492','1F4A3',
    '1F51E','1F52A','1F52B','1F52E','1F52F','1F549','1F54D','1F54E','1F595','1F5E1','1F5FD','1F608','1F617',
    '1F618','1F619','1F61A','1F63D','1F6AC','1F6D0','1F6D5','1F918','1F936','1F942','1F943',
    '1F9D1-200D-1F384','1F9DB','1F9DF','1F9E7','1FA71','1FA72','1FA94','1FAA6','1FAAC','1FAAF','1FAE6',
    '2620','2626','262F','2638','2648','2649','264A','264B','264C','264D','264E','264F','2650','2651','2652',
    '2653','2694','26A7','26B0','26B1','26CE','26E9','26EA','271D','2721'];
  v_kodlar text[];
begin
  if p is null then return true; end if;
  select coalesce(array_agg(upper(to_hex(ascii(t.c))) order by t.o), '{}') into v_kodlar
    from regexp_split_to_table(p, '') with ordinality as t(c, o)
   where ascii(t.c) <> 65039;                                   -- FE0F
  return array_to_string(v_kodlar, '-') = any (v_yasak)
      or exists (select 1 from unnest(v_kodlar) k where k = any (v_yasak));
end;
$$;

-- ---------------------------------------------------------------------
-- 3. Şema doğrulaması (sozluk.v1): hata listesi (boşsa geçerli)
-- ---------------------------------------------------------------------
create or replace function public._okuma_sozluk_hatalari(p jsonb)
returns jsonb
language plpgsql
stable
set search_path = ''
as $$
declare
  v_h      text[] := '{}';
  v_m      text;
  v_turler text[] := array['kelime', 'deyim', 'atasozu'];
  v_durumlar text[] := array['taslak', 'incelemede', 'onayli', 'arsiv'];
  v_i      integer;
  v_j      integer;
  g        jsonb;
  y        jsonb;
  a        jsonb;
  k        jsonb;
  v_idtur  jsonb := '{}'::jsonb;     -- bu yükteki girdi id -> tur
  v_yuvalar text[] := '{}';
  v_kelimeler text[] := '{}';
  v_tur    text;
begin
  v_m := public._okuma_anahtar_hatasi(p, array['sozluk_surumu', 'girdiler', 'yuvalar'], array['kavramlar']);
  if v_m is not null then return to_jsonb(array['sözlük: ' || v_m]); end if;
  if not public._okuma_js_tam(p -> 'sozluk_surumu', 1, 1) then
    v_h := array_append(v_h, 'sozluk_surumu 1 olmalı');
  end if;
  if jsonb_typeof(p -> 'girdiler') is distinct from 'array' then
    v_h := array_append(v_h, 'girdiler dizi olmalı');
  elsif jsonb_array_length(p -> 'girdiler') > 2000 then
    v_h := array_append(v_h, 'girdiler en çok 2000 olabilir');
  end if;
  if jsonb_typeof(p -> 'yuvalar') is distinct from 'array' then
    v_h := array_append(v_h, 'yuvalar dizi olmalı');
  elsif jsonb_array_length(p -> 'yuvalar') > 1000 then
    v_h := array_append(v_h, 'yuvalar en çok 1000 olabilir');
  end if;
  if p ? 'kavramlar' then
    if jsonb_typeof(p -> 'kavramlar') is distinct from 'array' then
      v_h := array_append(v_h, 'kavramlar dizi olmalı');
    elsif jsonb_array_length(p -> 'kavramlar') > 1000 then
      v_h := array_append(v_h, 'kavramlar en çok 1000 olabilir');
    end if;
  end if;
  if cardinality(v_h) > 0 then return to_jsonb(v_h); end if;

  -- girdiler
  v_i := 0;
  for g in select value from jsonb_array_elements(p -> 'girdiler') loop
    v_i := v_i + 1;
    v_m := public._okuma_anahtar_hatasi(g,
      array['id', 'tur', 'yazim', 'anlam', 'sinif_alt', 'sinif_ust', 'kaynak_turu', 'durum'], array['kazanim_kodu']);
    if v_m is not null then
      v_h := array_append(v_h, 'girdiler[' || v_i || ']: ' || v_m);
      continue;
    end if;
    if not public._okuma_js_dizge(g -> 'id', '^[a-z0-9_]+$', 1, 80) then v_h := array_append(v_h, 'girdiler[' || v_i || '].id geçersiz'); end if;
    if not public._okuma_js_enum(g -> 'tur', v_turler) then v_h := array_append(v_h, 'girdiler[' || v_i || '].tur geçersiz'); end if;
    if not public._okuma_js_dizge(g -> 'yazim', null, 1, 120) then v_h := array_append(v_h, 'girdiler[' || v_i || '].yazim 1-120 karakter olmalı'); end if;
    if not public._okuma_js_dizge(g -> 'anlam', null, 5, 200) then v_h := array_append(v_h, 'girdiler[' || v_i || '].anlam 5-200 karakter olmalı'); end if;
    if not public._okuma_js_tam(g -> 'sinif_alt', 1, 8) then v_h := array_append(v_h, 'girdiler[' || v_i || '].sinif_alt 1-8 olmalı'); end if;
    if not public._okuma_js_tam(g -> 'sinif_ust', 1, 8) then v_h := array_append(v_h, 'girdiler[' || v_i || '].sinif_ust 1-8 olmalı'); end if;
    if public._okuma_js_tam(g -> 'sinif_alt', 1, 8) and public._okuma_js_tam(g -> 'sinif_ust', 1, 8)
       and (g ->> 'sinif_alt')::integer > (g ->> 'sinif_ust')::integer then
      v_h := array_append(v_h, 'girdiler[' || v_i || ']: sinif_alt sinif_ust değerinden büyük olamaz');
    end if;
    if not public._okuma_js_enum(g -> 'kaynak_turu', array['editor_onerisi', 'meb_kaynakli']) then v_h := array_append(v_h, 'girdiler[' || v_i || '].kaynak_turu geçersiz'); end if;
    if not public._okuma_js_enum(g -> 'durum', v_durumlar) then v_h := array_append(v_h, 'girdiler[' || v_i || '].durum geçersiz'); end if;
    if g ? 'kazanim_kodu' and jsonb_typeof(g -> 'kazanim_kodu') <> 'null'
       and not public._okuma_js_dizge(g -> 'kazanim_kodu', null, 1, 40) then
      v_h := array_append(v_h, 'girdiler[' || v_i || '].kazanim_kodu geçersiz');
    end if;
    if public._okuma_js_dizge(g -> 'id', '^[a-z0-9_]+$', 1, 80) then
      if v_idtur ? (g ->> 'id') then
        v_h := array_append(v_h, 'girdiler[' || v_i || '].id yinelenen: ' || (g ->> 'id'));
      elsif public._okuma_js_enum(g -> 'tur', v_turler) then
        v_idtur := v_idtur || jsonb_build_object(g ->> 'id', g ->> 'tur');
      end if;
    end if;
    exit when cardinality(v_h) >= 50;
  end loop;

  -- yuvalar
  v_i := 0;
  for y in select value from jsonb_array_elements(p -> 'yuvalar') loop
    exit when cardinality(v_h) >= 50;
    v_i := v_i + 1;
    v_m := public._okuma_anahtar_hatasi(y, array['ad', 'tur', 'adaylar'], null);
    if v_m is not null then
      v_h := array_append(v_h, 'yuvalar[' || v_i || ']: ' || v_m);
      continue;
    end if;
    if not public._okuma_js_dizge(y -> 'ad', '^[a-z0-9_]+$', 1, 80) then v_h := array_append(v_h, 'yuvalar[' || v_i || '].ad geçersiz'); end if;
    if not public._okuma_js_enum(y -> 'tur', v_turler) then v_h := array_append(v_h, 'yuvalar[' || v_i || '].tur geçersiz'); end if;
    if public._okuma_js_dizge(y -> 'ad', '^[a-z0-9_]+$', 1, 80) and public._okuma_js_enum(y -> 'tur', v_turler) then
      if (y ->> 'tur') || ':' || (y ->> 'ad') = any (v_yuvalar) then
        v_h := array_append(v_h, 'yuvalar[' || v_i || '] yinelenen: ' || (y ->> 'tur') || ':' || (y ->> 'ad'));
      end if;
      v_yuvalar := array_append(v_yuvalar, (y ->> 'tur') || ':' || (y ->> 'ad'));
    end if;
    if jsonb_typeof(y -> 'adaylar') is distinct from 'array'
       or jsonb_array_length(y -> 'adaylar') not between 1 and 50 then
      v_h := array_append(v_h, 'yuvalar[' || v_i || '].adaylar 1-50 elemanlı dizi olmalı');
      continue;
    end if;
    v_j := 0;
    for a in select value from jsonb_array_elements(y -> 'adaylar') loop
      v_j := v_j + 1;
      v_m := public._okuma_anahtar_hatasi(a, array['girdi'], null);
      if v_m is not null then
        v_h := array_append(v_h, 'yuvalar[' || v_i || '].adaylar[' || v_j || ']: ' || v_m);
        continue;
      end if;
      if not public._okuma_js_dizge(a -> 'girdi', '^[a-z0-9_]+$', 1, 80) then
        v_h := array_append(v_h, 'yuvalar[' || v_i || '].adaylar[' || v_j || '].girdi geçersiz');
        continue;
      end if;
      -- aday ya bu yükte ya da veritabanında bulunmalı; türü yuvanın türüyle aynı olmalı
      v_tur := coalesce(v_idtur ->> (a ->> 'girdi'),
                        (select s.tur from public.okuma_sozluk_girdileri s where s.id = a ->> 'girdi'));
      if v_tur is null then
        v_h := array_append(v_h, 'yuvalar[' || v_i || '].adaylar[' || v_j || '].girdi bilinmiyor: ' || (a ->> 'girdi'));
      elsif public._okuma_js_enum(y -> 'tur', v_turler) and v_tur <> (y ->> 'tur') then
        v_h := array_append(v_h, 'yuvalar[' || v_i || '].adaylar[' || v_j || ']: girdi türü yuva türüyle uyuşmuyor');
      end if;
      if (select count(*) from jsonb_array_elements(y -> 'adaylar') e where e ->> 'girdi' = a ->> 'girdi') > 1 then
        v_h := array_append(v_h, 'yuvalar[' || v_i || '].adaylar[' || v_j || '] yinelenen aday');
      end if;
    end loop;
  end loop;

  -- kavramlar (isteğe bağlı): kelime -> ikon
  if p ? 'kavramlar' then
    v_i := 0;
    for k in select value from jsonb_array_elements(p -> 'kavramlar') loop
      exit when cardinality(v_h) >= 50;
      v_i := v_i + 1;
      v_m := public._okuma_anahtar_hatasi(k, array['kelime', 'ikon'], null);
      if v_m is not null then
        v_h := array_append(v_h, 'kavramlar[' || v_i || ']: ' || v_m);
        continue;
      end if;
      if not public._okuma_js_dizge(k -> 'kelime', null, 1, 60) then
        v_h := array_append(v_h, 'kavramlar[' || v_i || '].kelime 1-60 karakter olmalı');
      elsif (k ->> 'kelime') = any (v_kelimeler) then
        v_h := array_append(v_h, 'kavramlar[' || v_i || '].kelime yinelenen: ' || (k ->> 'kelime'));
      else
        v_kelimeler := array_append(v_kelimeler, k ->> 'kelime');
      end if;
      if not public._okuma_js_dizge(k -> 'ikon', null, 1, 8) or (k ->> 'ikon') ~ '[A-Za-z0-9\s]' then
        v_h := array_append(v_h, 'kavramlar[' || v_i || '].ikon geçersiz (1-8 karakter, harf/rakam/boşluk yok)');
      elsif public._okuma_ikon_yasakli(k ->> 'ikon') then
        v_h := array_append(v_h, 'kavramlar[' || v_i || '].ikon yasaklı simge');
      end if;
    end loop;
  end if;

  return to_jsonb(v_h);
end;
$$;

-- ---------------------------------------------------------------------
-- 4. Yönetim: sözlük içe aktarma (kuru çalıştırma varsayılan)
--    Dört göz: girdiyi 'onayli' yapan kişi, girdinin içeriğini son yazan kişiden farklı olmalı.
--    İçerik (tür/yazım/anlam/sınıf/kaynak/kazanım) değişirse onay düşer ve değiştiren oluşturan sayılır.
--    Yuvaların aday listesi yükteki haliyle değiştirilir; yükte olmayan yuvalara dokunulmaz.
-- ---------------------------------------------------------------------
create or replace function public.okuma_sozluk_ice_aktar(p_sozluk jsonb, p_kuru boolean default true)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid    uuid := (select auth.uid());
  v_kuru   boolean := coalesce(p_kuru, true);
  v_hatalar jsonb;
  v_h      text[] := '{}';
  g        jsonb;
  y        jsonb;
  k        jsonb;
  a        jsonb;
  v_sira   integer;
  v_e      public.okuma_sozluk_girdileri%rowtype;
  v_var    boolean;
  v_ayni   boolean;
  v_durum  text;
  v_yeni integer := 0; v_guncel integer := 0; v_onay integer := 0; v_yuva integer := 0; v_aday integer := 0; v_kav integer := 0;
begin
  perform public.require_admin();

  v_hatalar := public._okuma_sozluk_hatalari(p_sozluk);
  if jsonb_array_length(v_hatalar) > 0 then
    perform public.log_admin_action('okuma_sozluk_ice_aktar', jsonb_build_object(
      'kuru', v_kuru, 'sonuc', 'reddedildi', 'hata_sayisi', jsonb_array_length(v_hatalar)));
    return jsonb_build_object('gecerli', false, 'yazildi', false, 'kuru', v_kuru, 'hatalar', v_hatalar);
  end if;

  -- girdiler (önce dört göz ön kontrolü; sonra yazım)
  for g in select value from jsonb_array_elements(p_sozluk -> 'girdiler') loop
    select * into v_e from public.okuma_sozluk_girdileri where id = g ->> 'id' for update;
    v_var := found;
    v_ayni := v_var
      and v_e.tur = g ->> 'tur' and v_e.yazim = g ->> 'yazim' and v_e.anlam = g ->> 'anlam'
      and v_e.sinif_alt = (g ->> 'sinif_alt')::smallint and v_e.sinif_ust = (g ->> 'sinif_ust')::smallint
      and v_e.kaynak_turu = g ->> 'kaynak_turu'
      and v_e.kazanim_kodu is not distinct from (g ->> 'kazanim_kodu');
    v_durum := g ->> 'durum';

    if v_durum = 'onayli' and not (v_var and v_ayni and (v_e.durum = 'onayli' or v_e.olusturan_id is distinct from v_uid)) then
      v_h := array_append(v_h, 'DORT_GOZ: ' || (g ->> 'id') || ' kendi yazdığın içeriği onaylayamazsın (başka bir yönetici onaylamalı)');
      continue;
    end if;

    if not v_kuru then
      if not v_var then
        insert into public.okuma_sozluk_girdileri
          (id, tur, yazim, anlam, sinif_alt, sinif_ust, kaynak_turu, kazanim_kodu, durum, olusturan_id)
        values (g ->> 'id', g ->> 'tur', g ->> 'yazim', g ->> 'anlam', (g ->> 'sinif_alt')::smallint,
                (g ->> 'sinif_ust')::smallint, g ->> 'kaynak_turu', g ->> 'kazanim_kodu', v_durum, v_uid);
      elsif v_durum = 'onayli' then
        if v_e.durum = 'onayli' then
          null;                                                     -- zaten onaylı; onaylayan korunur
        else
          update public.okuma_sozluk_girdileri
             set durum = 'onayli', onaylayan_id = v_uid, onaylandi_at = now(), guncellendi_at = now()
           where id = v_e.id;
        end if;
      else
        update public.okuma_sozluk_girdileri
           set tur = g ->> 'tur', yazim = g ->> 'yazim', anlam = g ->> 'anlam',
               sinif_alt = (g ->> 'sinif_alt')::smallint, sinif_ust = (g ->> 'sinif_ust')::smallint,
               kaynak_turu = g ->> 'kaynak_turu', kazanim_kodu = g ->> 'kazanim_kodu',
               durum = v_durum,
               olusturan_id = case when v_ayni then olusturan_id else v_uid end,
               onaylayan_id = null, onaylandi_at = null, guncellendi_at = now()
         where id = v_e.id;
      end if;
    end if;
    if v_var then v_guncel := v_guncel + 1; else v_yeni := v_yeni + 1; end if;
    if v_durum = 'onayli' and not (v_var and v_e.durum = 'onayli') then v_onay := v_onay + 1; end if;
  end loop;

  if cardinality(v_h) > 0 then
    perform public.log_admin_action('okuma_sozluk_ice_aktar', jsonb_build_object(
      'kuru', v_kuru, 'sonuc', 'dort_goz', 'hata_sayisi', cardinality(v_h)));
    return jsonb_build_object('gecerli', false, 'yazildi', false, 'kuru', v_kuru, 'hatalar', to_jsonb(v_h));
  end if;

  -- yuvalar ve adaylar
  for y in select value from jsonb_array_elements(p_sozluk -> 'yuvalar') loop
    v_yuva := v_yuva + 1;
    v_aday := v_aday + jsonb_array_length(y -> 'adaylar');
    if not v_kuru then
      insert into public.okuma_sozluk_yuvalari (tur, ad) values (y ->> 'tur', y ->> 'ad')
      on conflict (tur, ad) do update set guncellendi_at = now();
      delete from public.okuma_sozluk_adaylari where yuva_tur = y ->> 'tur' and yuva_ad = y ->> 'ad';
      v_sira := 0;
      for a in select value from jsonb_array_elements(y -> 'adaylar') loop
        insert into public.okuma_sozluk_adaylari (yuva_tur, yuva_ad, girdi_id, sira)
        values (y ->> 'tur', y ->> 'ad', a ->> 'girdi', v_sira);
        v_sira := v_sira + 1;
      end loop;
    end if;
  end loop;

  -- kavram -> ikon
  if p_sozluk ? 'kavramlar' then
    for k in select value from jsonb_array_elements(p_sozluk -> 'kavramlar') loop
      v_kav := v_kav + 1;
      if not v_kuru then
        insert into public.okuma_sozluk_kavramlari (kelime, ikon) values (k ->> 'kelime', k ->> 'ikon')
        on conflict (kelime) do update set ikon = excluded.ikon;
      end if;
    end loop;
  end if;

  perform public.log_admin_action('okuma_sozluk_ice_aktar', jsonb_build_object(
    'kuru', v_kuru, 'sonuc', case when v_kuru then 'kuru' else 'yazildi' end,
    'girdi_yeni', v_yeni, 'girdi_guncel', v_guncel, 'yuva', v_yuva, 'kavram', v_kav));
  return jsonb_build_object('gecerli', true, 'yazildi', not v_kuru, 'kuru', v_kuru,
    'hatalar', '[]'::jsonb,
    'ozet', jsonb_build_object('girdi_yeni', v_yeni, 'girdi_guncel', v_guncel, 'onaylanan', v_onay,
                               'yuva', v_yuva, 'aday', v_aday, 'kavram', v_kav));
end;
$$;

-- ---------------------------------------------------------------------
-- 5. Öğrenci: bir hikâyenin sözlüğü
--    * Hikâyenin görünen sürümündeki yuvalar için aday + anlam. Yalnız 'onayli' girdiler;
--      önizleme izinli hesaplarda taslak / incelemedeki girdiler de gelir ('onayli': false ile).
--    * Adaylar çocuğun sınıfına uyar (sinif_alt <= sınıf <= sinif_ust). Sınıfı olmayan hesapta süzme yok.
--    * Kavram -> simge listesi: yasaklı simge kodları çıkarılır.
--    * Özellik kapalı / yetkisiz / hikâye yok: boş sonuç (hata değil).
-- ---------------------------------------------------------------------
create or replace function public.okuma_sozluk_getir(p_hikaye_id uuid)
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
  v_sinif smallint;
  v_ic    jsonb;
  v_yuvalar jsonb;
  v_kavram  jsonb;
begin
  select * into v_e from public._okuma_erisim(v_uid);
  if p_hikaye_id is null or not coalesce(v_e.erisim, false) then
    return jsonb_build_object('hikaye_id', p_hikaye_id, 'onizleme', false, 'yuvalar', '[]'::jsonb, 'kavramlar', '[]'::jsonb);
  end if;
  v_sid := public._okuma_gorunen_surum(p_hikaye_id, v_e.onizleme);
  if v_sid is null then
    return jsonb_build_object('hikaye_id', p_hikaye_id, 'onizleme', false, 'yuvalar', '[]'::jsonb, 'kavramlar', '[]'::jsonb);
  end if;

  select s.icerik into v_ic from public.okuma_hikaye_surumleri s where s.id = v_sid;
  select p.sinif into v_sinif from public.profiles p where p.id = v_uid;

  select coalesce(jsonb_agg(jsonb_build_object('tur', q.tur, 'yuva', q.ad, 'adaylar', q.adaylar) order by q.tur, q.ad), '[]'::jsonb)
    into v_yuvalar
    from (
      select yu.tur, yu.ad,
             jsonb_agg(jsonb_build_object(
               'id', g.id, 'tur', g.tur, 'yazim', g.yazim, 'anlam', g.anlam,
               'sinif_alt', g.sinif_alt, 'sinif_ust', g.sinif_ust, 'onayli', g.durum = 'onayli')
               order by a.sira, g.id) as adaylar
        from (select distinct e ->> 't' as tur, e ->> 'yuva' as ad
                from jsonb_path_query(v_ic, '$.** ? (@.t == "kelime" || @.t == "atasozu" || @.t == "deyim")', '{}'::jsonb, true) e) sl
        join public.okuma_sozluk_yuvalari yu on yu.tur = sl.tur and yu.ad = sl.ad
        join public.okuma_sozluk_adaylari a on a.yuva_tur = yu.tur and a.yuva_ad = yu.ad
        join public.okuma_sozluk_girdileri g on g.id = a.girdi_id
       where (g.durum = 'onayli' or (v_e.onizleme and g.durum in ('taslak', 'incelemede')))
         and (v_sinif is null or v_sinif between g.sinif_alt and g.sinif_ust)
       group by yu.tur, yu.ad
    ) q;

  select coalesce(jsonb_agg(jsonb_build_object('kelime', k.kelime, 'ikon', k.ikon) order by k.kelime), '[]'::jsonb)
    into v_kavram
    from (select kk.kelime, kk.ikon from public.okuma_sozluk_kavramlari kk
           where not public._okuma_ikon_yasakli(kk.ikon) order by kk.kelime limit 500) k;

  return jsonb_build_object('hikaye_id', p_hikaye_id, 'onizleme', v_e.onizleme,
                            'yuvalar', v_yuvalar, 'kavramlar', v_kavram);
end;
$$;

-- ---------------------------------------------------------------------
-- 6. Yetkiler
-- ---------------------------------------------------------------------
revoke execute on function
  public._okuma_ikon_yasakli(text), public._okuma_sozluk_hatalari(jsonb)
  from public, anon, authenticated;
revoke all on function public.okuma_sozluk_ice_aktar(jsonb, boolean) from public, anon;
grant execute on function public.okuma_sozluk_ice_aktar(jsonb, boolean) to authenticated;
revoke all on function public.okuma_sozluk_getir(uuid) from public, anon;
grant execute on function public.okuma_sozluk_getir(uuid) to authenticated;
