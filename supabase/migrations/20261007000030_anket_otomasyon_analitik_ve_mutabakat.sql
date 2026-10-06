-- =====================================================================
--  Anketler (NPS/CSAT, koşullu soru, anonimlik), destek görevleri, otomasyon
--  taslakları, analitik özeti ve ödeme mutabakat kontrolü
--  Proje : Hupo / Yönetim Merkezi  (Aşama C + E)
--  Tarih : 2026-10-07
--  Ön koşul: 20261007000010 ve 20261007000020 migration'ları
--
--  NE EKLİYOR?
--    tablolar : anketler, anket_yanitlari, anket_katilimlari, destek_gorevleri,
--               otomasyonlar
--    iç       : _anket_sorulari_hatasi                       (istemciye KAPALI)
--    veli RPC : anket_aktif_listem, anket_yanit_gonder
--    admin RPC: admin_anket_listele/kaydet/durum/sonuc,
--               admin_destek_gorevleri_listele/kapat,
--               admin_otomasyon_listele/kaydet/durum,
--               admin_analitik_ozet, admin_odeme_mutabakat
--
--  KURALLAR
--    * Anonim anket: yanıtta veli_id NULL ve zaman damgası güne yuvarlanır → CRM
--      kişisiyle ilişkilendirilemez. Katılım (tekrar gösterim) ayrı tabloda tutulur,
--      yanıt içeriği tutmaz. Anonimlik yanıt geldikten sonra DEĞİŞTİRİLEMEZ.
--    * Anket yanıtı ticari iletişim izni yerine GEÇMEZ; izinler iletisim_tercihleri'nden.
--    * Düşük NPS (0-6, kimlikli) yalnızca bir DESTEK İNCELEME GÖREVİ oluşturur;
--      otomatik indirim/teklif/izin üretmez.
--    * Otomasyonlar yalnızca TASLAK/HAZIR olarak saklanır; çalıştıran worker yoktur.
--    * Mutabakat, sağlayıcı olayını DOĞRULAMAZ (sağlayıcı entegrasyonu yok); yalnızca
--      kayıtlar arası tutarsızlıkları listeler.
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Tablolar
-- ---------------------------------------------------------------------
create table if not exists public.anketler (
  id                   uuid primary key default gen_random_uuid(),
  ad                   text not null,
  hedef                text not null default 'veli',
  anonim               boolean not null default false,
  durum                text not null default 'taslak',
  sorular              jsonb not null default '[]'::jsonb,
  surum                integer not null default 1,
  tekrar_gosterim_gun  integer not null default 30,
  created_by           uuid references public.profiles (id) on delete set null,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),
  constraint anketler_ad check (char_length(btrim(ad)) between 2 and 120),
  constraint anketler_hedef check (hedef = 'veli'),
  constraint anketler_durum check (durum in ('taslak', 'yayinda', 'kapali')),
  constraint anketler_sorular_dizi check (jsonb_typeof(sorular) = 'array'),
  constraint anketler_tekrar check (tekrar_gosterim_gun between 1 and 365)
);

create table if not exists public.anket_yanitlari (
  id          uuid primary key default gen_random_uuid(),
  anket_id    uuid not null references public.anketler (id) on delete cascade,
  surum       integer not null,
  veli_id     uuid references public.profiles (id) on delete set null,
  yanitlar    jsonb not null,
  nps         smallint,
  created_at  timestamptz not null default now(),
  constraint anket_yanitlari_nesne check (jsonb_typeof(yanitlar) = 'object'),
  constraint anket_yanitlari_nps check (nps is null or nps between 0 and 10)
);
create index if not exists anket_yanitlari_anket_idx on public.anket_yanitlari (anket_id, created_at desc);

create table if not exists public.anket_katilimlari (
  anket_id  uuid not null references public.anketler (id) on delete cascade,
  veli_id   uuid not null references public.profiles (id) on delete cascade,
  son_at    timestamptz not null default now(),
  primary key (anket_id, veli_id)
);

create table if not exists public.destek_gorevleri (
  id              uuid primary key default gen_random_uuid(),
  veli_id         uuid not null references public.profiles (id) on delete cascade,
  kaynak          text not null default 'anket_dusuk_nps',
  anket_yanit_id  uuid references public.anket_yanitlari (id) on delete set null,
  durum           text not null default 'acik',
  kapatma_notu    text,
  created_at      timestamptz not null default now(),
  kapatildi_at    timestamptz,
  constraint destek_gorevleri_durum check (durum in ('acik', 'kapali')),
  constraint destek_gorevleri_kaynak check (kaynak in ('anket_dusuk_nps'))
);
create index if not exists destek_gorevleri_durum_idx on public.destek_gorevleri (durum, created_at desc);

create table if not exists public.otomasyonlar (
  id           uuid primary key default gen_random_uuid(),
  ad           text not null,
  giris_olayi  text not null,
  adimlar      jsonb not null default '[]'::jsonb,
  durum        text not null default 'taslak',
  surum        integer not null default 1,
  created_by   uuid references public.profiles (id) on delete set null,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  constraint otomasyonlar_ad check (char_length(btrim(ad)) between 2 and 120),
  constraint otomasyonlar_giris check (giris_olayi in
    ('veli_kayit', 'ilk_gorev_bekleyen', 'yenileme_yaklasan', 'pasif_7_gun')),
  constraint otomasyonlar_adimlar_dizi check (jsonb_typeof(adimlar) = 'array'),
  constraint otomasyonlar_durum check (durum in ('taslak', 'hazir', 'duraklatildi'))
);

alter table public.anketler          enable row level security;
alter table public.anket_yanitlari   enable row level security;
alter table public.anket_katilimlari enable row level security;
alter table public.destek_gorevleri  enable row level security;
alter table public.otomasyonlar      enable row level security;

revoke all on table public.anketler          from public, anon, authenticated;
revoke all on table public.anket_yanitlari   from public, anon, authenticated;
revoke all on table public.anket_katilimlari from public, anon, authenticated;
revoke all on table public.destek_gorevleri  from public, anon, authenticated;
revoke all on table public.otomasyonlar      from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. İç doğrulayıcı: anket soruları
--    [{id, tur, baslik, secenekler?, kosul?:{soru_id, op, deger}}]
-- ---------------------------------------------------------------------
create or replace function public._anket_sorulari_hatasi(p jsonb)
returns text
language plpgsql
immutable
set search_path = ''
as $function$
declare
  q      jsonb;
  v_ids  text[] := '{}';
  v_id   text;
  v_tur  text;
  v_kos  jsonb;
begin
  if p is null or jsonb_typeof(p) <> 'array' then return 'sorular dizi olmalı'; end if;
  if jsonb_array_length(p) > 30 then return 'en fazla 30 soru olabilir'; end if;

  for q in select * from jsonb_array_elements(p) loop
    if jsonb_typeof(q) <> 'object' then return 'her soru nesne olmalı'; end if;
    v_id  := q ->> 'id';
    v_tur := q ->> 'tur';
    if v_id is null or v_id !~ '^[a-z0-9_]{1,40}$' then return 'soru kimliği geçersiz'; end if;
    if v_id = any (v_ids) then return 'soru kimliği tekrar ediyor: ' || v_id; end if;
    if v_tur is null or v_tur not in ('kisa_metin', 'uzun_metin', 'tek_secim', 'nps', 'csat', 'onay') then
      return 'soru türü geçersiz: ' || coalesce(v_tur, 'boş');
    end if;
    if char_length(btrim(coalesce(q ->> 'baslik', ''))) not between 1 and 200 then
      return 'soru başlığı 1-200 karakter olmalı';
    end if;
    if v_tur = 'tek_secim' then
      if jsonb_typeof(q -> 'secenekler') <> 'array' or jsonb_array_length(q -> 'secenekler') < 2 then
        return 'tek seçimde en az 2 seçenek gerekir';
      end if;
    end if;
    v_kos := q -> 'kosul';
    if v_kos is not null and jsonb_typeof(v_kos) <> 'null' then
      if jsonb_typeof(v_kos) <> 'object'
         or not (v_ids @> array[coalesce(v_kos ->> 'soru_id', '')])
         or coalesce(v_kos ->> 'op', '') not in ('lte', 'gte', 'eq')
         or jsonb_typeof(v_kos -> 'deger') <> 'number' then
        return 'koşul yalnızca önceki bir soruya, lte/gte/eq ve sayısal değerle bağlanabilir';
      end if;
    end if;
    v_ids := v_ids || v_id;
  end loop;
  return null;
end;
$function$;

revoke execute on function public._anket_sorulari_hatasi(jsonb) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 3. ADMIN RPC — anket yönetimi
-- ---------------------------------------------------------------------
create or replace function public.admin_anket_listele()
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
      select a.id, a.ad, a.anonim, a.durum, a.sorular, a.surum, a.tekrar_gosterim_gun, a.created_at,
             (select count(*)::integer from public.anket_yanitlari y where y.anket_id = a.id) as yanit_sayisi
        from public.anketler a
    ) x;
  return v_res;
end;
$function$;

create or replace function public.admin_anket_kaydet(
  p_id        uuid,
  p_ad        text,
  p_anonim    boolean,
  p_sorular   jsonb,
  p_tekrar_gun integer default 30
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_id     uuid := p_id;
  v_hata   text;
  a        public.anketler%rowtype;
begin
  perform public.require_admin();
  v_hata := public._anket_sorulari_hatasi(p_sorular);
  if v_hata is not null then
    raise exception 'Anket soruları geçersiz: %', v_hata using errcode = '22023';
  end if;
  if p_anonim is null then
    raise exception 'Anonimlik seçilmeli.' using errcode = '22023';
  end if;

  if v_id is null then
    insert into public.anketler (ad, anonim, sorular, tekrar_gosterim_gun, created_by)
    values (btrim(coalesce(p_ad, '')), p_anonim, p_sorular, coalesce(p_tekrar_gun, 30), (select auth.uid()))
    returning id into v_id;
  else
    select * into a from public.anketler where id = v_id for update;
    if not found then
      raise exception 'Anket bulunamadı' using errcode = 'P0002';
    end if;
    if a.durum = 'kapali' then
      raise exception 'Kapalı anket düzenlenemez.' using errcode = '23514';
    end if;
    if a.anonim is distinct from p_anonim
       and exists (select 1 from public.anket_yanitlari where anket_id = v_id) then
      raise exception 'Yanıt alındıktan sonra anonimlik değiştirilemez.' using errcode = '23514';
    end if;
    update public.anketler
       set ad = btrim(coalesce(p_ad, '')), anonim = p_anonim, sorular = p_sorular,
           tekrar_gosterim_gun = coalesce(p_tekrar_gun, 30),
           -- Yayındaki anket değişirse yeni sürüm: yanıtlar kendi sürümüne bağlı kalır.
           surum = case when a.durum = 'yayinda' and a.sorular is distinct from p_sorular
                        then a.surum + 1 else a.surum end,
           updated_at = now()
     where id = v_id;
  end if;

  perform public.log_admin_action('anket_kaydedildi', jsonb_build_object('anket_id', v_id));
  return v_id;
end;
$function$;

create or replace function public.admin_anket_durum(p_id uuid, p_durum text)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  a public.anketler%rowtype;
begin
  perform public.require_admin();
  if p_durum not in ('yayinda', 'kapali') then
    raise exception 'Geçersiz durum.' using errcode = '22023';
  end if;
  select * into a from public.anketler where id = p_id for update;
  if not found then
    raise exception 'Anket bulunamadı' using errcode = 'P0002';
  end if;
  if a.durum = 'kapali' then
    raise exception 'Kapalı anket yeniden açılamaz; kopyasını oluşturun.' using errcode = '23514';
  end if;
  if p_durum = 'yayinda' and jsonb_array_length(a.sorular) = 0 then
    raise exception 'Soru içermeyen anket yayımlanamaz.' using errcode = '23514';
  end if;

  update public.anketler set durum = p_durum, updated_at = now() where id = p_id;
  perform public.log_admin_action('anket_durumu_degisti',
    jsonb_build_object('anket_id', p_id, 'durum', p_durum));
end;
$function$;

-- Sonuçlar: kimlik İÇERMEZ (anonim olsun olmasın yalnızca toplulaştırma + metinler).
create or replace function public.admin_anket_sonuc(p_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  a        public.anketler%rowtype;
  v_n      integer;
  v_nps_n  integer;
  v_des    integer;
  v_pas    integer;
  v_ele    integer;
  v_sorular jsonb;
  v_metin  jsonb;
begin
  perform public.require_admin();
  select * into a from public.anketler where id = p_id;
  if not found then
    raise exception 'Anket bulunamadı' using errcode = 'P0002';
  end if;

  select count(*)::integer,
         (count(*) filter (where nps is not null))::integer,
         (count(*) filter (where nps >= 9))::integer,
         (count(*) filter (where nps between 7 and 8))::integer,
         (count(*) filter (where nps <= 6))::integer
    into v_n, v_nps_n, v_des, v_pas, v_ele
    from public.anket_yanitlari where anket_id = p_id;

  select coalesce(jsonb_agg(jsonb_build_object(
           'soru_id', q ->> 'id', 'baslik', q ->> 'baslik', 'tur', q ->> 'tur',
           'yanit', agg.n, 'ortalama', agg.ort
         ) order by o), '[]'::jsonb)
    into v_sorular
    from jsonb_array_elements(a.sorular) with ordinality as t(q, o)
    cross join lateral (
      select count(*) filter (where y.yanitlar ? (t.q ->> 'id'))::integer as n,
             round(avg(case when jsonb_typeof(y.yanitlar -> (t.q ->> 'id')) = 'number'
                            then (y.yanitlar ->> (t.q ->> 'id'))::numeric end), 2) as ort
        from public.anket_yanitlari y
       where y.anket_id = p_id
    ) agg;

  select coalesce(jsonb_agg(jsonb_build_object('soru_id', m.soru_id, 'metin', m.metin, 'tarih', m.tarih)), '[]'::jsonb)
    into v_metin
    from (
      select t.q ->> 'id' as soru_id, y.yanitlar ->> (t.q ->> 'id') as metin, y.created_at as tarih
        from public.anket_yanitlari y
        cross join lateral jsonb_array_elements(a.sorular) as t(q)
       where y.anket_id = p_id
         and t.q ->> 'tur' in ('kisa_metin', 'uzun_metin')
         and nullif(btrim(coalesce(y.yanitlar ->> (t.q ->> 'id'), '')), '') is not null
       order by y.created_at desc
       limit 20
    ) m;

  return jsonb_build_object(
    'anket', jsonb_build_object('id', a.id, 'ad', a.ad, 'anonim', a.anonim, 'surum', a.surum, 'durum', a.durum),
    'yanit_sayisi', v_n,
    'nps', jsonb_build_object(
      'n', v_nps_n, 'destekleyen', v_des, 'pasif', v_pas, 'elestiren', v_ele,
      'skor', case when v_nps_n > 0 then round((v_des - v_ele) * 100.0 / v_nps_n) end),
    'sorular', v_sorular,
    'metinler', v_metin
  );
end;
$function$;

-- ---------------------------------------------------------------------
-- 4. VELİ RPC — aktif anketler + yanıt gönderme
-- ---------------------------------------------------------------------
create or replace function public.anket_aktif_listem()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_uid uuid := (select auth.uid());
  v_res jsonb;
begin
  if v_uid is null or not exists (select 1 from public.profiles where id = v_uid and role = 'veli') then
    raise exception 'Bu işlem yalnızca veli hesabı içindir.' using errcode = '42501';
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
           'id', a.id, 'ad', a.ad, 'anonim', a.anonim, 'sorular', a.sorular) order by a.created_at), '[]'::jsonb)
    into v_res
    from public.anketler a
   where a.durum = 'yayinda' and a.hedef = 'veli'
     and not exists (select 1 from public.anket_katilimlari k
                      where k.anket_id = a.id and k.veli_id = v_uid
                        and k.son_at > now() - make_interval(days => a.tekrar_gosterim_gun));
  return v_res;
end;
$function$;

create or replace function public.anket_yanit_gonder(p_anket_id uuid, p_yanitlar jsonb)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_uid   uuid := (select auth.uid());
  a       public.anketler%rowtype;
  q       jsonb;
  v_id    text;
  v_val   jsonb;
  v_nps   smallint;
  v_yanit uuid;
begin
  if v_uid is null or not exists (select 1 from public.profiles where id = v_uid and role = 'veli') then
    raise exception 'Bu işlem yalnızca veli hesabı içindir.' using errcode = '42501';
  end if;
  if p_yanitlar is null or jsonb_typeof(p_yanitlar) <> 'object' then
    raise exception 'Yanıtlar nesne olmalı.' using errcode = '22023';
  end if;

  select * into a from public.anketler where id = p_anket_id and durum = 'yayinda' and hedef = 'veli';
  if not found then
    raise exception 'Anket bulunamadı veya yayında değil.' using errcode = 'P0002';
  end if;
  if exists (select 1 from public.anket_katilimlari k
              where k.anket_id = a.id and k.veli_id = v_uid
                and k.son_at > now() - make_interval(days => a.tekrar_gosterim_gun)) then
    raise exception 'Bu ankete yakın zamanda katıldınız.' using errcode = '23505';
  end if;

  -- Yalnızca tanımlı sorulara, türüne uygun değerlerle yanıt kabul edilir.
  if exists (select 1 from jsonb_object_keys(p_yanitlar) k
              where not exists (select 1 from jsonb_array_elements(a.sorular) s where s ->> 'id' = k)) then
    raise exception 'Tanımsız soru yanıtı.' using errcode = '22023';
  end if;

  for q in select * from jsonb_array_elements(a.sorular) loop
    v_id  := q ->> 'id';
    v_val := p_yanitlar -> v_id;
    continue when v_val is null or jsonb_typeof(v_val) = 'null';
    case q ->> 'tur'
      when 'nps' then
        if jsonb_typeof(v_val) <> 'number' or (v_val #>> '{}')::numeric not between 0 and 10
           or (v_val #>> '{}')::numeric <> trunc((v_val #>> '{}')::numeric) then
          raise exception 'NPS 0-10 arası tam sayı olmalı.' using errcode = '22023';
        end if;
        if v_nps is null then v_nps := (v_val #>> '{}')::numeric::smallint; end if;
      when 'csat' then
        if jsonb_typeof(v_val) <> 'number' or (v_val #>> '{}')::numeric not between 1 and 5 then
          raise exception 'Memnuniyet 1-5 arası olmalı.' using errcode = '22023';
        end if;
      when 'onay' then
        if jsonb_typeof(v_val) <> 'boolean' then
          raise exception 'Onay evet/hayır olmalı.' using errcode = '22023';
        end if;
      when 'tek_secim' then
        if jsonb_typeof(v_val) <> 'string' or not (q -> 'secenekler') @> to_jsonb(v_val #>> '{}') then
          raise exception 'Seçenek geçersiz.' using errcode = '22023';
        end if;
      else
        if jsonb_typeof(v_val) <> 'string' or char_length(v_val #>> '{}') > 2000 then
          raise exception 'Metin yanıtı en fazla 2000 karakter olmalı.' using errcode = '22023';
        end if;
    end case;
  end loop;

  insert into public.anket_yanitlari (anket_id, surum, veli_id, yanitlar, nps, created_at)
  values (a.id, a.surum,
          case when a.anonim then null else v_uid end,
          p_yanitlar, v_nps,
          case when a.anonim then date_trunc('day', now()) else now() end)
  returning id into v_yanit;

  insert into public.anket_katilimlari (anket_id, veli_id, son_at)
  values (a.id, v_uid, now())
  on conflict (anket_id, veli_id) do update set son_at = now();

  -- Kimlikli ve düşük skor → yalnızca destek İNCELEME görevi (indirim/teklif/izin yok).
  if not a.anonim and v_nps is not null and v_nps <= 6
     and not exists (select 1 from public.destek_gorevleri
                      where veli_id = v_uid and kaynak = 'anket_dusuk_nps' and durum = 'acik') then
    insert into public.destek_gorevleri (veli_id, kaynak, anket_yanit_id)
    values (v_uid, 'anket_dusuk_nps', v_yanit);
  end if;
end;
$function$;

-- ---------------------------------------------------------------------
-- 5. Destek görevleri
-- ---------------------------------------------------------------------
create or replace function public.admin_destek_gorevleri_listele(p_durum text default 'acik')
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
      select g.id, g.veli_id, p.full_name as veli_ad, g.kaynak, g.durum, g.kapatma_notu,
             g.created_at, g.kapatildi_at, y.nps
        from public.destek_gorevleri g
        join public.profiles p on p.id = g.veli_id
        left join public.anket_yanitlari y on y.id = g.anket_yanit_id
       where p_durum is null or g.durum = p_durum
       order by g.created_at desc
       limit 100
    ) x;
  return v_res;
end;
$function$;

create or replace function public.admin_destek_gorevi_kapat(p_id uuid, p_not text)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
begin
  perform public.require_admin();
  update public.destek_gorevleri
     set durum = 'kapali', kapatma_notu = nullif(btrim(coalesce(p_not, '')), ''), kapatildi_at = now()
   where id = p_id and durum = 'acik';
  if not found then
    raise exception 'Görev bulunamadı veya zaten kapalı.' using errcode = 'P0002';
  end if;
  perform public.log_admin_action('destek_gorevi_kapatildi', jsonb_build_object('gorev_id', p_id));
end;
$function$;

-- ---------------------------------------------------------------------
-- 6. Otomasyon taslakları (çalıştıran worker YOK)
-- ---------------------------------------------------------------------
create or replace function public._otomasyon_adimlari_hatasi(p jsonb)
returns text
language plpgsql
immutable
set search_path = ''
as $function$
declare
  s     jsonb;
  v_tur text;
begin
  if p is null or jsonb_typeof(p) <> 'array' then return 'adımlar dizi olmalı'; end if;
  if jsonb_array_length(p) > 20 then return 'en fazla 20 adım olabilir'; end if;
  for s in select * from jsonb_array_elements(p) loop
    if jsonb_typeof(s) <> 'object' then return 'her adım nesne olmalı'; end if;
    v_tur := s ->> 'tur';
    if v_tur = 'bekle' then
      if jsonb_typeof(s -> 'saat') <> 'number' or (s ->> 'saat')::numeric not between 1 and 720 then
        return 'bekleme süresi 1-720 saat olmalı';
      end if;
    elsif v_tur = 'kosul' then
      if coalesce(s ->> 'olcut', '') not in ('ilk_gorev_tamamlandi', 'abonelik_aktif', 'izin_var') then
        return 'koşul ölçütü geçersiz';
      end if;
    elsif v_tur = 'mesaj' then
      if coalesce(s ->> 'kanal', '') not in ('eposta', 'push', 'sms', 'uygulama_ici')
         or char_length(btrim(coalesce(s ->> 'baslik', ''))) not between 1 and 100 then
        return 'mesaj adımında kanal ve başlık (1-100) gerekir';
      end if;
    else
      return 'adım türü geçersiz';
    end if;
  end loop;
  return null;
end;
$function$;

revoke execute on function public._otomasyon_adimlari_hatasi(jsonb) from public, anon, authenticated;

create or replace function public.admin_otomasyon_listele()
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
  select coalesce(jsonb_agg(to_jsonb(o) order by o.created_at desc), '[]'::jsonb) into v_res
    from (select id, ad, giris_olayi, adimlar, durum, surum, created_at from public.otomasyonlar) o;
  return v_res;
end;
$function$;

create or replace function public.admin_otomasyon_kaydet(
  p_id           uuid,
  p_ad           text,
  p_giris_olayi  text,
  p_adimlar      jsonb
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_id   uuid := p_id;
  v_hata text;
begin
  perform public.require_admin();
  v_hata := public._otomasyon_adimlari_hatasi(p_adimlar);
  if v_hata is not null then
    raise exception 'Otomasyon adımları geçersiz: %', v_hata using errcode = '22023';
  end if;

  if v_id is null then
    insert into public.otomasyonlar (ad, giris_olayi, adimlar, created_by)
    values (btrim(coalesce(p_ad, '')), p_giris_olayi, p_adimlar, (select auth.uid()))
    returning id into v_id;
  else
    update public.otomasyonlar
       set ad = btrim(coalesce(p_ad, '')), giris_olayi = p_giris_olayi, adimlar = p_adimlar,
           surum = surum + 1, durum = 'taslak', updated_at = now()
     where id = v_id;
    if not found then
      raise exception 'Otomasyon bulunamadı' using errcode = 'P0002';
    end if;
  end if;

  perform public.log_admin_action('otomasyon_kaydedildi', jsonb_build_object('otomasyon_id', v_id));
  return v_id;
end;
$function$;

create or replace function public.admin_otomasyon_durum(p_id uuid, p_durum text)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
begin
  perform public.require_admin();
  if p_durum not in ('taslak', 'hazir', 'duraklatildi') then
    raise exception 'Geçersiz durum.' using errcode = '22023';
  end if;
  if p_durum = 'hazir' and not exists (
       select 1 from public.otomasyonlar
        where id = p_id and jsonb_array_length(adimlar) > 0
          and exists (select 1 from jsonb_array_elements(adimlar) s where s ->> 'tur' = 'mesaj')) then
    raise exception 'Hazır olması için en az bir mesaj adımı gerekir.' using errcode = '23514';
  end if;
  update public.otomasyonlar set durum = p_durum, updated_at = now() where id = p_id;
  if not found then
    raise exception 'Otomasyon bulunamadı' using errcode = 'P0002';
  end if;
  perform public.log_admin_action('otomasyon_durumu_degisti',
    jsonb_build_object('otomasyon_id', p_id, 'durum', p_durum));
end;
$function$;

-- ---------------------------------------------------------------------
-- 7. Analitik özeti (aynı cohort huni + haftalık öğrenmeye dönüş + öğrenme göstergeleri)
-- ---------------------------------------------------------------------
create or replace function public.admin_analitik_ozet(p_gun integer default 30)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_gun      integer := least(greatest(coalesce(p_gun, 30), 1), 365);
  v_bas      timestamptz;
  v_kayit    integer;
  v_cocuk    integer;
  v_ogrenme  integer;
  v_ucretli  integer;
  v_kohort   jsonb;
  v_ogr      integer;
  v_aktif7   integer;
  v_dogruluk numeric;
  v_tekrar   integer;
begin
  perform public.require_admin();
  v_bas := now() - make_interval(days => v_gun);

  with c as (
    select p.id
      from public.profiles p
     where p.role = 'veli' and p.created_at >= v_bas
  )
  select (select count(*) from c)::integer,
         (select count(*) from c where exists (select 1 from public.profiles k where k.parent_id = c.id))::integer,
         (select count(*) from c where exists (
            select 1 from public.profiles k join public.user_answers ua on ua.student_id = k.id
             where k.parent_id = c.id))::integer,
         (select count(*) from c where exists (
            select 1 from public.payments pa where pa.veli_id = c.id and pa.durum = 'basarili'))::integer
    into v_kayit, v_cocuk, v_ogrenme, v_ucretli;

  with hafta as (
    select date_trunc('week', now()) - make_interval(weeks => i) as bas
      from generate_series(0, 4) as i
  ),
  kohort as (
    select h.bas, p.id as ogr
      from hafta h
      join public.profiles p
        on p.role = 'ogrenci' and p.created_at >= h.bas and p.created_at < h.bas + interval '7 days'
  ),
  boyut as (
    select h.bas, count(k.ogr) as n
      from hafta h left join kohort k on k.bas = h.bas
     group by h.bas
  ),
  hucre as (
    select b.bas, g.k,
           case
             when b.n = 0 or b.bas + make_interval(weeks => g.k) > now() then null
             else round(100.0 * (
                    select count(distinct ua.student_id)
                      from public.user_answers ua
                      join kohort ko on ko.ogr = ua.student_id and ko.bas = b.bas
                     where ua.created_at >= b.bas + make_interval(weeks => g.k)
                       and ua.created_at <  b.bas + make_interval(weeks => g.k + 1)
                  ) / b.n)
           end as pct
      from boyut b cross join generate_series(0, 4) as g(k)
  )
  select coalesce(jsonb_agg(jsonb_build_object(
           'hafta', to_char(b.bas, 'DD.MM'), 'boyut', b.n,
           'tutma', (select jsonb_agg(hu.pct order by hu.k) from hucre hu where hu.bas = b.bas)
         ) order by b.bas), '[]'::jsonb)
    into v_kohort
    from boyut b;

  select count(*)::integer into v_ogr from public.profiles where role = 'ogrenci';
  select count(*)::integer into v_aktif7
    from public.student_stats where last_active_date >= current_date - 6;
  select round(100.0 * sum(dogru_sayisi) / nullif(sum(deneme_sayisi), 0), 1) into v_dogruluk
    from public.user_answers;
  select count(*)::integer into v_tekrar from public.user_answers where sonraki_tekrar_tarihi <= now();

  return jsonb_build_object(
    'gun', v_gun,
    'huni', jsonb_build_object('kayit', v_kayit, 'cocuk_bagladi', v_cocuk,
                               'ilk_ogrenme', v_ogrenme, 'ucretli', v_ucretli),
    'kohort', v_kohort,
    'ogrenme', jsonb_build_object(
      'ogrenci', v_ogr, 'aktif_7_gun', v_aktif7, 'dogruluk_yuzde', v_dogruluk,
      'tekrar_zamani_gelen', v_tekrar)
  );
end;
$function$;

-- ---------------------------------------------------------------------
-- 8. Ödeme mutabakat kontrolü (kayıtlar arası tutarsızlıklar; sağlayıcıyı DOĞRULAMAZ)
-- ---------------------------------------------------------------------
create or replace function public.admin_odeme_mutabakat()
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

  select coalesce(jsonb_agg(to_jsonb(x) order by x.tarih desc), '[]'::jsonb) into v_res
    from (
      (select 'bekleyen_eski'::text as tur, pa.id as kayit_id, p.full_name as veli_ad,
              pa.tutar_kurus, pa.created_at as tarih
         from public.payments pa left join public.profiles p on p.id = pa.veli_id
        where pa.durum = 'beklemede' and pa.created_at < now() - interval '3 days'
        limit 100)
      union all
      (select 'abonelik_yok', pa.id, p.full_name, pa.tutar_kurus, pa.created_at
         from public.payments pa left join public.profiles p on p.id = pa.veli_id
        where pa.durum = 'basarili' and pa.subscription_id is null
        limit 100)
      union all
      (select 'suresi_gecmis_aktif', sb.id, p.full_name, null::integer, sb.bitis
         from public.subscriptions sb left join public.profiles p on p.id = sb.veli_id
        where sb.durum = 'aktif' and sb.bitis < now()
        limit 100)
      union all
      (select 'yinelenen', pa.id, p.full_name, pa.tutar_kurus, pa.created_at
         from public.payments pa left join public.profiles p on p.id = pa.veli_id
        where pa.durum = 'basarili'
          and exists (select 1 from public.payments o
                       where o.id <> pa.id and o.veli_id = pa.veli_id and o.tutar_kurus = pa.tutar_kurus
                         and o.durum = 'basarili'
                         and o.created_at between pa.created_at - interval '10 minutes' and pa.created_at
                         and (o.created_at < pa.created_at or o.id < pa.id))
        limit 100)
    ) x;

  return v_res;
end;
$function$;

-- ---------------------------------------------------------------------
-- 9. REVOKE / GRANT
-- ---------------------------------------------------------------------
revoke execute on function public.admin_anket_listele()                                          from public, anon;
revoke execute on function public.admin_anket_kaydet(uuid, text, boolean, jsonb, integer)        from public, anon;
revoke execute on function public.admin_anket_durum(uuid, text)                                  from public, anon;
revoke execute on function public.admin_anket_sonuc(uuid)                                        from public, anon;
revoke execute on function public.anket_aktif_listem()                                           from public, anon;
revoke execute on function public.anket_yanit_gonder(uuid, jsonb)                                from public, anon;
revoke execute on function public.admin_destek_gorevleri_listele(text)                           from public, anon;
revoke execute on function public.admin_destek_gorevi_kapat(uuid, text)                          from public, anon;
revoke execute on function public.admin_otomasyon_listele()                                      from public, anon;
revoke execute on function public.admin_otomasyon_kaydet(uuid, text, text, jsonb)                from public, anon;
revoke execute on function public.admin_otomasyon_durum(uuid, text)                              from public, anon;
revoke execute on function public.admin_analitik_ozet(integer)                                   from public, anon;
revoke execute on function public.admin_odeme_mutabakat()                                        from public, anon;

grant execute on function public.admin_anket_listele()                                          to authenticated;
grant execute on function public.admin_anket_kaydet(uuid, text, boolean, jsonb, integer)        to authenticated;
grant execute on function public.admin_anket_durum(uuid, text)                                  to authenticated;
grant execute on function public.admin_anket_sonuc(uuid)                                        to authenticated;
grant execute on function public.anket_aktif_listem()                                           to authenticated;
grant execute on function public.anket_yanit_gonder(uuid, jsonb)                                to authenticated;
grant execute on function public.admin_destek_gorevleri_listele(text)                           to authenticated;
grant execute on function public.admin_destek_gorevi_kapat(uuid, text)                          to authenticated;
grant execute on function public.admin_otomasyon_listele()                                      to authenticated;
grant execute on function public.admin_otomasyon_kaydet(uuid, text, text, jsonb)                to authenticated;
grant execute on function public.admin_otomasyon_durum(uuid, text)                              to authenticated;
grant execute on function public.admin_analitik_ozet(integer)                                   to authenticated;
grant execute on function public.admin_odeme_mutabakat()                                        to authenticated;
