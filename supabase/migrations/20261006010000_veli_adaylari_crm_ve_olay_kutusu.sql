-- =====================================================================
--  CRM: veli adayları (leads) + olay kutusu (domain outbox)
--  Proje : Öğrenci Hazırlık / Hupo
--  Tarih : 2026-10-06
--
--  KAYNAK / GEREKÇE
--    Hupolingo_Starter_v1 paketindeki `leads` + `domain_outbox` desenleri
--    referans alınarak, kendi Supabase RPC + RLS mimarimize çevrildi.
--    Starter Drizzle/Better-Auth kullanıyordu; biz fail-closed SECURITY
--    DEFINER + RLS desenini (20260927000130 kupon/kampanya ile aynı) koruyoruz.
--
--  NE EKLİYOR?
--    tablolar     : public.veli_adaylari, public.olay_kutusu
--    public RPC   : veli_adayi_olustur            (web sitesi formu; anon+auth)
--    admin RPC    : admin_list_veli_adaylari, admin_veli_adayi_asama,
--                   admin_veli_adayi_detay
--
--  GÜVENLİK
--    * Tablolara istemci (anon/authenticated) DOĞRUDAN erişemez (fail-closed):
--      RLS açık + tüm yetkiler revoke; yalnızca SECURITY DEFINER RPC okur/yazar.
--    * PII (e-posta, ad) olay_kutusu payload'ına YAZILMAZ (AGENTS.md §5.5).
--      Outbox yalnızca veli_adayi_id referansı tutar; e-posta gönderici worker
--      gerektiğinde veli_adaylari'ndan okur (tek doğruluk kaynağı — INTEGRATIONS).
--    * KVKK: pazarlama_izni açık onaydır; izin_at damgası ne zaman verildiğini
--      saklar. İzin yoksa pazarlama worker'ı o adaya gönderim yapmamalıdır.
--    * veli_adayi_olustur() anon'a açıktır (kayıt öncesi ziyaretçi). Spam'e karşı
--      e-posta tekilleştirme (upsert) + alan doğrulaması vardır; IP bazlı hız
--      sınırı RPC'de yapılamaz → web kenarında Turnstile/captcha ZORUNLU.
--      TODO(web): public form route'una captcha + edge rate-limit ekle.
--
--  OUTBOX NOTU (INTEGRATIONS.md)
--    Bu pakette GÖNDERİCİ WORKER YOKTUR. olay_kutusu.islendi_at hiçbir gerçek
--    teslim olmadan işaretlenmez. Worker ayrı sprintte eklenecektir
--    (event id ile dedupe, lock/lease, retry/backoff, dead-letter, receipt).
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. veli_adaylari — pazarlama/satış hunisi kayıtları (leads)
--    asama makinesi: yeni → iletisim → deneme → musteri → kapandi
-- ---------------------------------------------------------------------
create table if not exists public.veli_adaylari (
  id             uuid primary key default gen_random_uuid(),
  email          text not null,
  ad             text not null,
  telefon        text,
  kaynak         text not null default 'web_form',
  asama          text not null default 'yeni',
  pazarlama_izni boolean not null default false,
  izin_at        timestamptz,
  notlar         text,
  -- Aday gerçek bir veli hesabına dönüştüğünde bağlanır (tek kaynak).
  veli_id        uuid references public.profiles (id) on delete set null,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),

  -- E-posta RPC içinde lower(btrim(...)) ile normalize edilip yazılır.
  constraint veli_adaylari_email_benzersiz unique (email),
  constraint veli_adaylari_email_format check (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  constraint veli_adaylari_ad_uzunluk check (char_length(btrim(ad)) between 2 and 80),
  constraint veli_adaylari_asama_check
    check (asama in ('yeni', 'iletisim', 'deneme', 'musteri', 'kapandi')),
  constraint veli_adaylari_kaynak_uzunluk check (char_length(btrim(kaynak)) between 2 and 40)
);

create index if not exists veli_adaylari_asama_idx   on public.veli_adaylari (asama, created_at desc);
create index if not exists veli_adaylari_veli_idx    on public.veli_adaylari (veli_id);

comment on table public.veli_adaylari is
  'Veli adayı (lead) kayıtları. veli_adayi_olustur() yazar, admin_* RPC''leri yönetir. PII içerir; olay_kutusu''na kopyalanmaz.';
comment on column public.veli_adaylari.pazarlama_izni is
  'KVKK açık onayı. false ise pazarlama gönderimi yapılmaz; izin_at onay zamanıdır.';

-- ---------------------------------------------------------------------
-- 2. olay_kutusu — domain outbox (işlemle atomik yazılır)
--    Worker bu kayıtları okuyup teslim eder ve ANCAK teslim sonrası
--    islendi_at yazar. payload PII içermez; yalnızca id + PII olmayan alan.
-- ---------------------------------------------------------------------
create table if not exists public.olay_kutusu (
  id         uuid primary key default gen_random_uuid(),
  tur        text not null,
  payload    jsonb not null default '{}'::jsonb,
  deneme     integer not null default 0,
  created_at timestamptz not null default now(),
  islendi_at timestamptz,

  constraint olay_kutusu_tur_uzunluk check (char_length(btrim(tur)) between 2 and 60),
  constraint olay_kutusu_deneme_check check (deneme >= 0)
);

-- Worker "bekleyen" kayıtları hızlı çeksin diye kısmi indeks.
create index if not exists olay_kutusu_bekleyen_idx
  on public.olay_kutusu (created_at)
  where islendi_at is null;

comment on table public.olay_kutusu is
  'Domain outbox. Olaylar kaynak işlemle AYNI transaction''da yazılır. Gönderici worker ayrı sprintte; islendi_at yalnızca gerçek teslim sonrası yazılır. PII tutmaz.';

-- ---------------------------------------------------------------------
-- 3. RLS + yetkiler (fail-closed) — yalnızca RPC erişir
-- ---------------------------------------------------------------------
alter table public.veli_adaylari enable row level security;
alter table public.olay_kutusu   enable row level security;

revoke all on table public.veli_adaylari from public, anon, authenticated;
revoke all on table public.olay_kutusu   from public, anon, authenticated;

-- =====================================================================
-- 4. PUBLIC RPC — web sitesi lead yakalama (anon + authenticated)
--    Alanları doğrular, e-postayı normalize eder, tekilleştirir (upsert),
--    ve AYNI transaction''da outbox olayı yazar.
-- =====================================================================
create or replace function public.veli_adayi_olustur(
  p_email          text,
  p_ad             text,
  p_telefon        text    default null,
  p_kaynak         text    default 'web_form',
  p_pazarlama_izni boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_email   text := lower(btrim(coalesce(p_email, '')));
  v_ad      text := btrim(coalesce(p_ad, ''));
  v_tel     text := nullif(btrim(coalesce(p_telefon, '')), '');
  v_kaynak  text := nullif(btrim(coalesce(p_kaynak, '')), '');
  v_izin    boolean := coalesce(p_pazarlama_izni, false);
  v_id      uuid;
  v_yeni    boolean;
begin
  if v_email = '' or v_email !~* '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    raise exception 'Geçerli bir e-posta gir.' using errcode = '22023';
  end if;
  if char_length(v_ad) < 2 or char_length(v_ad) > 80 then
    raise exception 'Adını 2-80 karakter arasında gir.' using errcode = '22023';
  end if;
  if v_tel is not null and v_tel !~ '^[0-9+()\s-]{7,20}$' then
    raise exception 'Telefon numarası geçersiz.' using errcode = '22023';
  end if;
  v_kaynak := coalesce(v_kaynak, 'web_form');
  if char_length(v_kaynak) > 40 then
    v_kaynak := substr(v_kaynak, 1, 40);
  end if;

  -- Tekilleştir: aynı e-posta tekrar gelirse ad/telefon tazelenir, onay yalnızca
  -- "açık" yönde güncellenir (verilen onay geri alınmış gibi gösterilmez).
  insert into public.veli_adaylari (email, ad, telefon, kaynak, pazarlama_izni, izin_at)
  values (v_email, v_ad, v_tel, v_kaynak, v_izin, case when v_izin then now() end)
  on conflict (email) do update
    set ad             = excluded.ad,
        telefon        = coalesce(excluded.telefon, public.veli_adaylari.telefon),
        pazarlama_izni = public.veli_adaylari.pazarlama_izni or excluded.pazarlama_izni,
        izin_at        = case
                           when (public.veli_adaylari.pazarlama_izni or excluded.pazarlama_izni)
                             then coalesce(public.veli_adaylari.izin_at, now())
                           else null
                         end,
        updated_at     = now()
  returning id, (xmax::text = '0') into v_id, v_yeni;

  -- Outbox olayı: PII YOK, yalnızca referans + PII olmayan alanlar.
  insert into public.olay_kutusu (tur, payload)
  values (
    case when v_yeni then 'veli_adayi_olusturuldu' else 'veli_adayi_guncellendi' end,
    jsonb_build_object('veli_adayi_id', v_id, 'kaynak', v_kaynak, 'pazarlama_izni', v_izin)
  );

  return jsonb_build_object('ok', true, 'yeni', v_yeni);
end;
$function$;

comment on function public.veli_adayi_olustur(text, text, text, text, boolean) is
  'Web sitesi lead yakalama. Alanları doğrular, e-postayı tekilleştirir, outbox olayı yazar. Edge''de captcha ZORUNLU.';

-- =====================================================================
-- 5. ADMIN RPC — veli adaylarını yönet
-- =====================================================================

-- 5.1 admin_list_veli_adaylari — filtre + sayfalama ({toplam, satirlar})
create or replace function public.admin_list_veli_adaylari(
  p_asama  text    default null,
  p_arama  text    default null,
  p_limit  integer default 25,
  p_offset integer default 0
)
returns jsonb
language plpgsql
stable security definer
set search_path = ''
as $function$
declare
  v_limit  integer := least(greatest(coalesce(p_limit, 25), 1), 100);
  v_offset integer := greatest(coalesce(p_offset, 0), 0);
  v_asama  text := nullif(btrim(coalesce(p_asama, '')), '');
  v_ara    text := nullif(lower(btrim(coalesce(p_arama, ''))), '');
  v_toplam integer;
  v_satir  jsonb;
begin
  perform public.require_admin();

  select count(*)::integer into v_toplam
    from public.veli_adaylari a
   where (v_asama is null or a.asama = v_asama)
     and (v_ara is null or position(v_ara in lower(a.email)) > 0 or position(v_ara in lower(a.ad)) > 0);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id), '[]'::jsonb) into v_satir
    from (
      select a.id, a.email, a.ad, a.telefon, a.kaynak, a.asama, a.pazarlama_izni,
             a.izin_at, a.veli_id, a.created_at, a.updated_at
        from public.veli_adaylari a
       where (v_asama is null or a.asama = v_asama)
         and (v_ara is null or position(v_ara in lower(a.email)) > 0 or position(v_ara in lower(a.ad)) > 0)
       order by a.created_at desc, a.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('toplam', v_toplam, 'satirlar', v_satir);
end;
$function$;

-- 5.2 admin_veli_adayi_asama — aşama güncelle (+ opsiyonel not), outbox olayı
create or replace function public.admin_veli_adayi_asama(
  p_id    uuid,
  p_asama text,
  p_not   text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_asama text := nullif(btrim(coalesce(p_asama, '')), '');
  v_eski  text;
begin
  perform public.require_admin();
  if v_asama is null or v_asama not in ('yeni', 'iletisim', 'deneme', 'musteri', 'kapandi') then
    raise exception 'Geçersiz aşama.' using errcode = '22023';
  end if;

  select asama into v_eski from public.veli_adaylari where id = p_id;
  if not found then
    raise exception 'Veli adayı bulunamadı' using errcode = 'P0002';
  end if;

  update public.veli_adaylari
     set asama      = v_asama,
         notlar     = coalesce(nullif(btrim(coalesce(p_not, '')), ''), notlar),
         updated_at = now()
   where id = p_id;

  -- Aşama gerçekten değiştiyse outbox olayı yaz (PII yok).
  if v_eski is distinct from v_asama then
    insert into public.olay_kutusu (tur, payload)
    values ('veli_adayi_asama_degisti',
            jsonb_build_object('veli_adayi_id', p_id, 'eski', v_eski, 'yeni', v_asama));
  end if;

  perform public.log_admin_action('veli_adayi_asama_degisti',
    jsonb_build_object('veli_adayi_id', p_id, 'eski', v_eski, 'yeni', v_asama));
end;
$function$;

-- 5.3 admin_veli_adayi_detay — tek aday + aşama zaman çizelgesi (outbox'tan)
create or replace function public.admin_veli_adayi_detay(p_id uuid)
returns jsonb
language plpgsql
stable security definer
set search_path = ''
as $function$
declare
  v_aday jsonb;
  v_olay jsonb;
begin
  perform public.require_admin();

  select to_jsonb(a) into v_aday from public.veli_adaylari a where a.id = p_id;
  if v_aday is null then
    raise exception 'Veli adayı bulunamadı' using errcode = 'P0002';
  end if;

  select coalesce(jsonb_agg(to_jsonb(o) order by o.created_at), '[]'::jsonb) into v_olay
    from (
      select k.tur, k.payload, k.created_at, k.islendi_at
        from public.olay_kutusu k
       where k.payload ->> 'veli_adayi_id' = p_id::text
       order by k.created_at
    ) o;

  return jsonb_build_object('aday', v_aday, 'olaylar', v_olay);
end;
$function$;

-- =====================================================================
-- 6. REVOKE / GRANT
--    veli_adayi_olustur : anon + authenticated (kayıt öncesi ziyaretçi)
--    admin_*            : yalnızca authenticated (içeride require_admin kontrol)
-- =====================================================================
revoke execute on function public.veli_adayi_olustur(text, text, text, text, boolean) from public;
grant  execute on function public.veli_adayi_olustur(text, text, text, text, boolean) to anon, authenticated;

revoke execute on function public.admin_list_veli_adaylari(text, text, integer, integer) from public, anon;
grant  execute on function public.admin_list_veli_adaylari(text, text, integer, integer) to authenticated;

revoke execute on function public.admin_veli_adayi_asama(uuid, text, text) from public, anon;
grant  execute on function public.admin_veli_adayi_asama(uuid, text, text) to authenticated;

revoke execute on function public.admin_veli_adayi_detay(uuid) from public, anon;
grant  execute on function public.admin_veli_adayi_detay(uuid) to authenticated;
