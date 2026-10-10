-- =====================================================================
-- KELİME EVRENİ — eş anlamlı, zıt anlamlı ve eş sesli kelime oyunları
--
-- Mevcut sisteme bağlanma (yeni kullanıcı sistemi veya adaptör tablosu YOK):
--   * Öğrenci / veli  : public.profiles (role, parent_id). Veli kontrolü public.is_parent_of().
--   * Yönetici        : public.is_admin() (profiles.role = 'admin').
--   * XP / seri / lig : public.award_xp_and_streak() — XP'nin tek yazım yolu (xp_events defteri).
--   * Soru bankası    : public.questions KULLANILMAZ. Kelime soruları ayrı bir içerik türüdür
--                       (sözcük ilişkisi + çeldirici şıklar). Onay akışı taslak → inceleme →
--                       yayın şeklindedir ve yayını yapan kişi, taslağı yazan kişi olamaz (dört göz).
--
-- Güvenlik:
--   * Tüm tablolarda RLS açık; anon hiçbir tabloya erişemez.
--   * İstemci tablolara doğrudan erişmez; okuma ve yazma SECURITY DEFINER RPC'lerle yapılır.
--   * Doğru şık ve açıklama, öğrenci cevabı gönderilmeden istemciye çıkmaz.
--   * Veli yalnızca parent_id ile bağlı çocuğunun toplu özetini görür (kişisel veri yok).
--
-- Ön koşullar: 20260920000000 (profiles), 20260920000700 (xp_events / award_xp_and_streak),
--              20260920000900 (is_admin, log_admin_action).
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Sözcük envanteri: her satır bir kelimenin bir anlamı
-- ---------------------------------------------------------------------
create table if not exists public.kelime_anlamlari (
  id            uuid primary key default gen_random_uuid(),
  kelime        text not null check (length(btrim(kelime)) between 1 and 60),
  anlam         text not null check (length(btrim(anlam)) between 2 and 300),
  sozcuk_turu   text check (sozcuk_turu is null or sozcuk_turu in ('isim', 'sifat', 'fiil', 'zarf', 'baglac', 'diger')),
  olusturan_id  uuid references auth.users (id) on delete set null,
  created_at    timestamptz not null default now(),

  unique (kelime, anlam)
);

comment on table public.kelime_anlamlari is
  'Kelime Evreni sözlüğü. Bir kelimenin her anlamı ayrı satırdır (eş sesli kelimeler için).';

-- ---------------------------------------------------------------------
-- 2. Sözcük ilişkileri (editör onaylı)
-- ---------------------------------------------------------------------
create table if not exists public.kelime_iliskileri (
  id               uuid primary key default gen_random_uuid(),
  kaynak_anlam_id  uuid not null references public.kelime_anlamlari (id) on delete cascade,
  hedef_anlam_id   uuid not null references public.kelime_anlamlari (id) on delete cascade,
  iliski_turu      text not null check (iliski_turu in ('es_anlamli', 'zit_anlamli', 'es_sesli')),
  olusturan_id     uuid references auth.users (id) on delete set null,
  onaylayan_id     uuid references auth.users (id) on delete set null,
  onay_tarihi      timestamptz,
  created_at       timestamptz not null default now(),

  check (kaynak_anlam_id <> hedef_anlam_id),
  -- Onay tarihi ve onaylayan birlikte dolar ya da birlikte boş kalır
  check ((onay_tarihi is null) = (onaylayan_id is null)),
  -- Dört göz: ilişkiyi kuran kişi kendi kaydını onaylayamaz
  check (onaylayan_id is null or onaylayan_id is distinct from olusturan_id)
);

-- İlişki çift yönlüdür: (A,B) ile (B,A) tek kayıt olmalıdır
create unique index if not exists kelime_iliskileri_cift_idx
  on public.kelime_iliskileri (
    least(kaynak_anlam_id, hedef_anlam_id),
    greatest(kaynak_anlam_id, hedef_anlam_id),
    iliski_turu
  );

-- ---------------------------------------------------------------------
-- 3. Oyun soruları (taslak → inceleme → yayın → arşiv)
-- ---------------------------------------------------------------------
create table if not exists public.kelime_sorulari (
  id               uuid primary key default gen_random_uuid(),
  anlam_id         uuid not null references public.kelime_anlamlari (id) on delete restrict,
  iliski_turu      text not null check (iliski_turu in ('es_anlamli', 'zit_anlamli', 'es_sesli')),
  sinif            smallint not null check (sinif between 1 and 12),
  kazanim_kodu     text check (kazanim_kodu is null or length(kazanim_kodu) between 1 and 40),
  soru_metni       text not null check (length(btrim(soru_metni)) between 5 and 400),
  secenekler       jsonb not null check (jsonb_typeof(secenekler) = 'array' and jsonb_array_length(secenekler) between 2 and 4),
  dogru_indeks     smallint not null check (dogru_indeks >= 0),
  -- Doğru şıkkın hangi anlama karşılık geldiği; doluysa onaylı bir ilişkiyle desteklenmelidir
  dogru_anlam_id   uuid references public.kelime_anlamlari (id) on delete restrict,
  ipucu            text check (ipucu is null or length(btrim(ipucu)) between 1 and 200),
  aciklama         text not null check (length(btrim(aciklama)) between 5 and 500),
  durum            text not null default 'taslak' check (durum in ('taslak', 'incelemede', 'yayinda', 'arsiv')),
  olusturan_id     uuid references auth.users (id) on delete set null,
  inceleyen_id     uuid references auth.users (id) on delete set null,
  yayin_tarihi     timestamptz,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),

  constraint kelime_sorulari_dogru_indeks_aralik
    check (dogru_indeks < jsonb_array_length(secenekler)),
  -- Yayın: onaylayan dolu, yayın tarihi dolu ve taslağı yazan kişiden farklı
  constraint kelime_sorulari_yayin_dort_goz
    check (durum <> 'yayinda' or (inceleyen_id is not null and yayin_tarihi is not null
                                  and inceleyen_id is distinct from olusturan_id))
);

comment on column public.kelime_sorulari.dogru_indeks is
  'Doğru şıkkın indeksi. Yalnızca RPC''ler okur; istemciye gönderilmez.';
comment on column public.kelime_sorulari.aciklama is
  'Cevap sonrası gösterilen açıklama. Cevap gönderilmeden istemciye çıkmaz.';

create index if not exists kelime_sorulari_oyun_idx
  on public.kelime_sorulari (sinif, iliski_turu) where durum = 'yayinda';
create index if not exists kelime_sorulari_anlam_idx on public.kelime_sorulari (anlam_id);
create index if not exists kelime_sorulari_durum_idx on public.kelime_sorulari (durum, updated_at desc);

create trigger kelime_sorulari_set_updated_at
  before update on public.kelime_sorulari
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- 4. Öğrenci denemeleri (idempotent; ipucu ve XP ayrı raporlanır)
-- ---------------------------------------------------------------------
create table if not exists public.kelime_denemeleri (
  id                 uuid primary key default gen_random_uuid(),
  ogrenci_id         uuid not null references public.profiles (id) on delete cascade,
  soru_id            uuid not null references public.kelime_sorulari (id) on delete cascade,
  anlam_id           uuid not null references public.kelime_anlamlari (id) on delete cascade,
  deneme_anahtari    text not null check (length(deneme_anahtari) between 8 and 100),
  secilen_indeks     smallint not null check (secilen_indeks >= 0),
  dogru_mu           boolean not null,
  ipucu_kullanildi   boolean not null default false,
  kazanilan_xp       integer not null default 0 check (kazanilan_xp between 0 and 10),
  created_at         timestamptz not null default now(),

  unique (ogrenci_id, deneme_anahtari)
);

create index if not exists kelime_denemeleri_ogrenci_idx on public.kelime_denemeleri (ogrenci_id, created_at desc);
create index if not exists kelime_denemeleri_soru_idx on public.kelime_denemeleri (ogrenci_id, soru_id);

-- ---------------------------------------------------------------------
-- 5. Ustalık ve aralıklı tekrar (öğrenci × anlam × beceri)
--    MVP yalnızca 'taninma' becerisini yazar. Tanıma en fazla 3 seviyeye çıkar;
--    seçenekle tanımak tam ustalık sayılmaz (bağlam / hatırlama / üretim gerekir).
-- ---------------------------------------------------------------------
create table if not exists public.kelime_ustaliklari (
  ogrenci_id             uuid not null references public.profiles (id) on delete cascade,
  anlam_id               uuid not null references public.kelime_anlamlari (id) on delete cascade,
  beceri                 text not null check (beceri in ('taninma', 'baglam', 'hatirlama', 'uretim')),
  basari_seviyesi        smallint not null default 0 check (basari_seviyesi between 0 and 5),
  sonraki_tekrar_tarihi  timestamptz not null default now(),
  son_cevap_tarihi       timestamptz,
  guncellendi            timestamptz not null default now(),

  primary key (ogrenci_id, anlam_id, beceri)
);

create index if not exists kelime_ustaliklari_tekrar_idx
  on public.kelime_ustaliklari (ogrenci_id, sonraki_tekrar_tarihi);

-- ---------------------------------------------------------------------
-- 6. Öğrencinin kaydettiği (zorlandığı) kelimeler
-- ---------------------------------------------------------------------
create table if not exists public.kelime_kaydedilenler (
  ogrenci_id  uuid not null references public.profiles (id) on delete cascade,
  anlam_id    uuid not null references public.kelime_anlamlari (id) on delete cascade,
  created_at  timestamptz not null default now(),

  primary key (ogrenci_id, anlam_id)
);

-- ---------------------------------------------------------------------
-- 7. RLS: tüm tablolarda açık. Tablo yetkileri de kapalı; erişim RPC üzerinden.
--    Politikalar ileride tablo yetkisi verilirse de veriyi korur (ikinci savunma hattı).
-- ---------------------------------------------------------------------
alter table public.kelime_anlamlari     enable row level security;
alter table public.kelime_iliskileri    enable row level security;
alter table public.kelime_sorulari      enable row level security;
alter table public.kelime_denemeleri    enable row level security;
alter table public.kelime_ustaliklari   enable row level security;
alter table public.kelime_kaydedilenler enable row level security;

revoke all on public.kelime_anlamlari, public.kelime_iliskileri, public.kelime_sorulari,
              public.kelime_denemeleri, public.kelime_ustaliklari, public.kelime_kaydedilenler
  from public, anon, authenticated;

create policy "kelime anlamlari yonetici okur"
  on public.kelime_anlamlari for select to authenticated
  using ((select public.is_admin()));

create policy "kelime iliskileri yonetici okur"
  on public.kelime_iliskileri for select to authenticated
  using ((select public.is_admin()));

create policy "kelime sorulari yonetici okur"
  on public.kelime_sorulari for select to authenticated
  using ((select public.is_admin()));

create policy "kelime denemeleri ogrenci ve veli okur"
  on public.kelime_denemeleri for select to authenticated
  using (ogrenci_id = (select auth.uid()) or (select public.is_parent_of(ogrenci_id)));

create policy "kelime ustaliklari ogrenci ve veli okur"
  on public.kelime_ustaliklari for select to authenticated
  using (ogrenci_id = (select auth.uid()) or (select public.is_parent_of(ogrenci_id)));

create policy "kelime kaydedilenler kendi kaydi"
  on public.kelime_kaydedilenler for all to authenticated
  using (ogrenci_id = (select auth.uid()))
  with check (ogrenci_id = (select auth.uid()));

-- ---------------------------------------------------------------------
-- 8. Yardımcı fonksiyonlar (istemciye açık değil)
-- ---------------------------------------------------------------------

-- Yönetici değilse hata verir. Yönetim RPC'lerinin ilk satırıdır.
create or replace function public.kelime_yonetici_kontrol()
returns void
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_admin() then
    raise exception 'ADMIN_ONLY' using errcode = '42501';
  end if;
end;
$$;

revoke all on function public.kelime_yonetici_kontrol() from public, anon, authenticated;

-- Eş anlamlı / zıt / eş sesli ilişkinin onaylı olup olmadığını iki yönde de arar.
create or replace function public.kelime_iliski_onayli_mi(
  p_a uuid,
  p_b uuid,
  p_iliski_turu text
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
      from public.kelime_iliskileri i
     where i.iliski_turu = p_iliski_turu
       and i.onay_tarihi is not null
       and ((i.kaynak_anlam_id = p_a and i.hedef_anlam_id = p_b)
         or (i.kaynak_anlam_id = p_b and i.hedef_anlam_id = p_a))
  );
$$;

revoke all on function public.kelime_iliski_onayli_mi(uuid, uuid, text) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 9. ÖĞRENCİ: oyun sorularını getir (due-queue önceliği ile)
--    Öncelik: 0 = tekrar zamanı gelmiş anlam, 1 = hiç çalışılmamış anlam, 2 = diğer.
--    Aynı anlamdaki en az denenmiş soru seçilir; böylece tek bir cevabı ezberletmek yerine
--    aynı kelimenin farklı soruları dönüşümlü gelir.
--    Doğru şık ve açıklama BU çıktıda yoktur.
-- ---------------------------------------------------------------------
create or replace function public.kelime_oyun_getir(
  p_iliski_turu text,
  p_limit       integer default 8
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := (select auth.uid());
  v_sinif   smallint;
  v_limit   integer := least(greatest(coalesce(p_limit, 8), 1), 20);
  v_sorular jsonb;
  v_tekrar  integer;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'STUDENT_ONLY' using errcode = '42501';
  end if;

  select p.sinif into v_sinif from public.profiles p where p.id = v_uid;
  if v_sinif is null then
    raise exception 'SINIF_GEREKLI' using errcode = '22023';
  end if;

  if p_iliski_turu not in ('es_anlamli', 'zit_anlamli', 'es_sesli') then
    raise exception 'BAD_RELATION' using errcode = '22023';
  end if;

  with vadesi_gelen as (
    select distinct u.anlam_id
      from public.kelime_ustaliklari u
     where u.ogrenci_id = v_uid and u.sonraki_tekrar_tarihi <= now()
  ),
  aday as (
    select s.id,
           s.anlam_id,
           s.soru_metni,
           s.secenekler,
           s.ipucu,
           case
             when exists (select 1 from vadesi_gelen v where v.anlam_id = s.anlam_id) then 0
             when not exists (select 1 from public.kelime_ustaliklari u
                               where u.ogrenci_id = v_uid and u.anlam_id = s.anlam_id) then 1
             else 2
           end as oncelik,
           (select count(*) from public.kelime_denemeleri d
             where d.ogrenci_id = v_uid and d.soru_id = s.id) as deneme_sayisi,
           random() as rastgele
      from public.kelime_sorulari s
     where s.durum = 'yayinda'
       and s.sinif = v_sinif
       and s.iliski_turu = p_iliski_turu
  ),
  secili as (
    select * from aday
     order by oncelik, deneme_sayisi, rastgele
     limit v_limit
  )
  select coalesce(jsonb_agg(
           jsonb_build_object(
             'id', s.id,
             'anlam_id', s.anlam_id,
             'soru_metni', s.soru_metni,
             'secenekler', s.secenekler,
             'ipucu', s.ipucu
           )
           order by s.oncelik, s.deneme_sayisi, s.rastgele), '[]'::jsonb)
    into v_sorular
    from secili s;

  select count(distinct u.anlam_id) into v_tekrar
    from public.kelime_ustaliklari u
   where u.ogrenci_id = v_uid and u.sonraki_tekrar_tarihi <= now();

  return jsonb_build_object(
    'sinif', v_sinif,
    'iliski_turu', p_iliski_turu,
    'sorular', v_sorular,
    'tekrar_bekleyen', v_tekrar
  );
end;
$$;

revoke all on function public.kelime_oyun_getir(text, integer) from public, anon;
grant execute on function public.kelime_oyun_getir(text, integer) to authenticated;

-- ---------------------------------------------------------------------
-- 10. ÖĞRENCİ: cevap gönder (tek yazım yolu)
--
--  * Idempotent: aynı deneme_anahtari ile gelen tekrar, kayıtlı sonucu döner; yeniden puanlamaz.
--  * Yarış koşulu: kullanıcı başına advisory lock; aynı soruda iki eşzamanlı doğru XP veremez.
--  * XP kuralı: XP yalnızca bu soruda İLK doğru ve İPUCUSUZ cevapta verilir (10 XP).
--    Diğer doğru cevaplar seri/aktiflik sayar ama XP vermez (mevcut submit_answer ile aynı desen).
--  * Ustalık: doğru → seviye +1 (en fazla 3); ipucu ile doğru → seviye değişmez;
--    yanlış → seviye 0. Sonraki tekrar: 1 / 3 / 7 gün.
--  * Hız sınırı: kullanıcı başına dakikada en fazla 30 deneme.
-- ---------------------------------------------------------------------
create or replace function public.kelime_cevap_gonder(
  p_soru_id           uuid,
  p_secilen_indeks    integer,
  p_ipucu_kullanildi  boolean,
  p_deneme_anahtari   text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid         uuid := (select auth.uid());
  v_sinif       smallint;
  v_soru        public.kelime_sorulari%rowtype;
  v_onceki      public.kelime_denemeleri%rowtype;
  v_ipucu       boolean := coalesce(p_ipucu_kullanildi, false);
  v_dogru       boolean;
  v_ilk_dogru   boolean;
  v_xp          integer := 0;
  v_award       jsonb;
  v_onceki_seviye smallint := 0;
  v_yeni_seviye smallint;
  v_gun         integer;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'STUDENT_ONLY' using errcode = '42501';
  end if;

  -- Aynı kullanıcının eşzamanlı istekleri sırayla işlenir
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_uid::text, 0));

  if p_deneme_anahtari is null or length(p_deneme_anahtari) not between 8 and 100 then
    raise exception 'INVALID_ATTEMPT_KEY' using errcode = '22023';
  end if;
  if p_secilen_indeks is null or p_secilen_indeks < 0 then
    raise exception 'BAD_OPTION' using errcode = '22023';
  end if;

  -- Ağ yeniden denemesi: kayıtlı sonucu dön, XP/ustalık tekrar işlenmesin
  select * into v_onceki
    from public.kelime_denemeleri
   where ogrenci_id = v_uid and deneme_anahtari = p_deneme_anahtari;
  if found then
    if v_onceki.soru_id <> p_soru_id
       or v_onceki.secilen_indeks <> p_secilen_indeks
       or v_onceki.ipucu_kullanildi <> v_ipucu then
      raise exception 'IDEMPOTENCY_CONFLICT' using errcode = '22023';
    end if;
    select * into v_soru from public.kelime_sorulari where id = p_soru_id;
    return jsonb_build_object(
      'dogru', v_onceki.dogru_mu,
      'dogru_indeks', v_soru.dogru_indeks,
      'aciklama', v_soru.aciklama,
      'kazanilan_xp', v_onceki.kazanilan_xp,
      'tekrar', true
    );
  end if;

  select p.sinif into v_sinif from public.profiles p where p.id = v_uid;

  -- Yalnızca yayındaki ve öğrencinin sınıfındaki sorular cevaplanabilir
  select * into v_soru
    from public.kelime_sorulari
   where id = p_soru_id and durum = 'yayinda' and sinif = v_sinif;
  if not found then
    raise exception 'SORU_BULUNAMADI' using errcode = 'P0002';
  end if;

  if p_secilen_indeks >= jsonb_array_length(v_soru.secenekler) then
    raise exception 'BAD_OPTION' using errcode = '22023';
  end if;

  if (select count(*) from public.kelime_denemeleri d
       where d.ogrenci_id = v_uid and d.created_at > now() - interval '1 minute') >= 30 then
    raise exception 'RATE_LIMIT' using errcode = '53400';
  end if;

  v_dogru := p_secilen_indeks = v_soru.dogru_indeks;

  v_ilk_dogru := v_dogru and not v_ipucu and not exists (
    select 1 from public.kelime_denemeleri d
     where d.ogrenci_id = v_uid and d.soru_id = v_soru.id
       and d.dogru_mu and not d.ipucu_kullanildi
  );

  if v_dogru then
    -- Tek XP yazım yolu: mevcut ledger ve seri/lig mantığı. Zorluk 1 = 10 XP.
    v_award := public.award_xp_and_streak(v_uid, 1::smallint, v_ilk_dogru);
    v_xp := coalesce((v_award ->> 'kazanilan_xp')::integer, 0);
  end if;

  insert into public.kelime_denemeleri (
    ogrenci_id, soru_id, anlam_id, deneme_anahtari, secilen_indeks, dogru_mu, ipucu_kullanildi, kazanilan_xp
  ) values (
    v_uid, v_soru.id, v_soru.anlam_id, p_deneme_anahtari, p_secilen_indeks, v_dogru, v_ipucu, v_xp
  );

  select coalesce(max(u.basari_seviyesi), 0) into v_onceki_seviye
    from public.kelime_ustaliklari u
   where u.ogrenci_id = v_uid and u.anlam_id = v_soru.anlam_id and u.beceri = 'taninma';

  if not v_dogru then
    v_yeni_seviye := 0;
    v_gun := 1;
  elsif v_ipucu then
    v_yeni_seviye := v_onceki_seviye;
    v_gun := 1;
  else
    v_yeni_seviye := least(v_onceki_seviye + 1, 3);
    v_gun := case v_yeni_seviye when 1 then 1 when 2 then 3 else 7 end;
  end if;

  insert into public.kelime_ustaliklari as k (
    ogrenci_id, anlam_id, beceri, basari_seviyesi, sonraki_tekrar_tarihi, son_cevap_tarihi, guncellendi
  ) values (
    v_uid, v_soru.anlam_id, 'taninma', v_yeni_seviye, now() + make_interval(days => v_gun), now(), now()
  )
  on conflict (ogrenci_id, anlam_id, beceri) do update
    set basari_seviyesi       = excluded.basari_seviyesi,
        sonraki_tekrar_tarihi = excluded.sonraki_tekrar_tarihi,
        son_cevap_tarihi      = excluded.son_cevap_tarihi,
        guncellendi           = excluded.guncellendi;

  return jsonb_build_object(
    'dogru', v_dogru,
    'dogru_indeks', v_soru.dogru_indeks,
    'aciklama', v_soru.aciklama,
    'kazanilan_xp', v_xp,
    'tekrar', false,
    'ustalik', jsonb_build_object(
      'beceri', 'taninma',
      'seviye', v_yeni_seviye,
      'sonraki_tekrar_tarihi', now() + make_interval(days => v_gun)
    )
  );
end;
$$;

revoke all on function public.kelime_cevap_gonder(uuid, integer, boolean, text) from public, anon;
grant execute on function public.kelime_cevap_gonder(uuid, integer, boolean, text) to authenticated;

-- ---------------------------------------------------------------------
-- 11. ÖĞRENCİ: kaydet / kaldır (zorlandığım kelimeler)
-- ---------------------------------------------------------------------
create or replace function public.kelime_kaydet(
  p_anlam_id uuid,
  p_kaydet   boolean default true
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'STUDENT_ONLY' using errcode = '42501';
  end if;
  if not exists (select 1 from public.kelime_anlamlari where id = p_anlam_id) then
    raise exception 'ANLAM_BULUNAMADI' using errcode = 'P0002';
  end if;

  if coalesce(p_kaydet, true) then
    insert into public.kelime_kaydedilenler (ogrenci_id, anlam_id)
    values (v_uid, p_anlam_id)
    on conflict (ogrenci_id, anlam_id) do nothing;
  else
    delete from public.kelime_kaydedilenler
     where ogrenci_id = v_uid and anlam_id = p_anlam_id;
  end if;
end;
$$;

revoke all on function public.kelime_kaydet(uuid, boolean) from public, anon;
grant execute on function public.kelime_kaydet(uuid, boolean) to authenticated;

-- ---------------------------------------------------------------------
-- 12. ÖĞRENCİ: ana ekran özeti
-- ---------------------------------------------------------------------
create or replace function public.kelime_ogrenci_ozeti()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'STUDENT_ONLY' using errcode = '42501';
  end if;

  return jsonb_build_object(
    'tekrar_bekleyen', (select count(distinct u.anlam_id) from public.kelime_ustaliklari u
                         where u.ogrenci_id = v_uid and u.sonraki_tekrar_tarihi <= now()),
    'tanima_tamam', (select count(*) from public.kelime_ustaliklari u
                      where u.ogrenci_id = v_uid and u.beceri = 'taninma' and u.basari_seviyesi >= 3),
    'calisilan_kelime', (select count(distinct u.anlam_id) from public.kelime_ustaliklari u
                          where u.ogrenci_id = v_uid),
    'kaydedilen', (select count(*) from public.kelime_kaydedilenler k where k.ogrenci_id = v_uid),
    'bugun_cozulen', (select count(*) from public.kelime_denemeleri d
                       where d.ogrenci_id = v_uid
                         and d.created_at >= ((now() at time zone 'Europe/Istanbul')::date)::timestamp
                                             at time zone 'Europe/Istanbul')
  );
end;
$$;

revoke all on function public.kelime_ogrenci_ozeti() from public, anon;
grant execute on function public.kelime_ogrenci_ozeti() to authenticated;

-- ---------------------------------------------------------------------
-- 13. ÖĞRENCİ: kaydedilen kelimeler listesi (ana ekran / tekrar)
-- ---------------------------------------------------------------------
create or replace function public.kelime_kaydedilenler_listele()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'STUDENT_ONLY' using errcode = '42501';
  end if;

  return coalesce((
    select jsonb_agg(jsonb_build_object(
             'anlam_id', a.id, 'kelime', a.kelime, 'anlam', a.anlam, 'kaydedilme', k.created_at)
             order by k.created_at desc)
      from public.kelime_kaydedilenler k
      join public.kelime_anlamlari a on a.id = k.anlam_id
     where k.ogrenci_id = v_uid
  ), '[]'::jsonb);
end;
$$;

revoke all on function public.kelime_kaydedilenler_listele() from public, anon;
grant execute on function public.kelime_kaydedilenler_listele() to authenticated;

-- ---------------------------------------------------------------------
-- 14. VELİ: çocuğun kelime gelişim özeti (toplu; kişisel cevap listesi YOK)
--     Yetki: yalnızca profiles.parent_id ile bağlı öğrenci.
--     Öneriler kod olarak döner; metni istemci (i18n) yazar.
-- ---------------------------------------------------------------------
create or replace function public.kelime_veli_ozeti(p_cocuk_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid        uuid := (select auth.uid());
  v_deneme     integer;
  v_dogru      integer;
  v_ipucusuz   integer;
  v_ipucusuz_dogru integer;
  v_ipucu      integer;
  v_tekrar     integer;
  v_zorlanilan jsonb;
  v_son_hafta  integer;
  v_oneriler   text[] := '{}';
begin
  if v_uid is null
     or not public.is_parent_of(p_cocuk_id)
     or not exists (select 1 from public.profiles p where p.id = p_cocuk_id and p.role = 'ogrenci') then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;

  select count(*),
         count(*) filter (where d.dogru_mu),
         count(*) filter (where not d.ipucu_kullanildi),
         count(*) filter (where d.dogru_mu and not d.ipucu_kullanildi),
         count(*) filter (where d.ipucu_kullanildi),
         count(*) filter (where d.created_at > now() - interval '7 days')
    into v_deneme, v_dogru, v_ipucusuz, v_ipucusuz_dogru, v_ipucu, v_son_hafta
    from public.kelime_denemeleri d
   where d.ogrenci_id = p_cocuk_id;

  select count(distinct u.anlam_id) into v_tekrar
    from public.kelime_ustaliklari u
   where u.ogrenci_id = p_cocuk_id and u.sonraki_tekrar_tarihi <= now();

  select coalesce(jsonb_agg(z.satir order by z.yanlis desc), '[]'::jsonb) into v_zorlanilan
    from (
      select jsonb_build_object(
               'kelime', a.kelime,
               'anlam', a.anlam,
               'iliski_turu', s.iliski_turu,
               'yanlis_sayisi', count(*)
             ) as satir,
             count(*) as yanlis
        from public.kelime_denemeleri d
        join public.kelime_anlamlari a on a.id = d.anlam_id
        join public.kelime_sorulari s on s.id = d.soru_id
       where d.ogrenci_id = p_cocuk_id and not d.dogru_mu
       group by a.kelime, a.anlam, s.iliski_turu, d.anlam_id
       order by count(*) desc
       limit 5
    ) z;

  if v_tekrar > 0 then v_oneriler := array_append(v_oneriler, 'tekrar_bekleyen'); end if;
  if jsonb_array_length(v_zorlanilan) > 0 then v_oneriler := array_append(v_oneriler, 'zorlanilan_tekrar'); end if;
  if v_son_hafta = 0 then v_oneriler := array_append(v_oneriler, 'haftalik_calisma_yok'); end if;
  if cardinality(v_oneriler) = 0 then v_oneriler := array['devam']; end if;

  return jsonb_build_object(
    'deneme_sayisi', v_deneme,
    'dogru_orani', case when v_deneme = 0 then null else round(100.0 * v_dogru / v_deneme) end,
    'ipucusuz_dogru_orani', case when v_ipucusuz = 0 then null else round(100.0 * v_ipucusuz_dogru / v_ipucusuz) end,
    'ipucu_kullanim_orani', case when v_deneme = 0 then null else round(100.0 * v_ipucu / v_deneme) end,
    'tekrar_bekleyen', v_tekrar,
    'son_7_gun_deneme', v_son_hafta,
    'zorlanilan', v_zorlanilan,
    'oneriler', to_jsonb(v_oneriler)
  );
end;
$$;

revoke all on function public.kelime_veli_ozeti(uuid) from public, anon;
grant execute on function public.kelime_veli_ozeti(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- 15. YÖNETİM: anlam ekle / düzenle
-- ---------------------------------------------------------------------
create or replace function public.kelime_anlam_kaydet(
  p_kelime     text,
  p_anlam      text,
  p_sozcuk_turu text default null,
  p_id         uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_id  uuid;
begin
  perform public.kelime_yonetici_kontrol();

  if length(btrim(coalesce(p_kelime, ''))) not between 1 and 60 then
    raise exception 'BAD_KELIME' using errcode = '22023';
  end if;
  if length(btrim(coalesce(p_anlam, ''))) not between 2 and 300 then
    raise exception 'BAD_ANLAM' using errcode = '22023';
  end if;

  if p_id is null then
    insert into public.kelime_anlamlari (kelime, anlam, sozcuk_turu, olusturan_id)
    values (btrim(p_kelime), btrim(p_anlam), p_sozcuk_turu, v_uid)
    returning id into v_id;
  else
    update public.kelime_anlamlari
       set kelime = btrim(p_kelime), anlam = btrim(p_anlam), sozcuk_turu = p_sozcuk_turu
     where id = p_id
    returning id into v_id;
    if v_id is null then
      raise exception 'ANLAM_BULUNAMADI' using errcode = 'P0002';
    end if;
  end if;

  perform public.log_admin_action('kelime_anlam_kaydet', jsonb_build_object('anlam_id', v_id));
  return v_id;
end;
$$;

revoke all on function public.kelime_anlam_kaydet(text, text, text, uuid) from public, anon;
grant execute on function public.kelime_anlam_kaydet(text, text, text, uuid) to authenticated;

-- ---------------------------------------------------------------------
-- 16. YÖNETİM: ilişki öner (aynı ilişki varsa mevcut kaydı döner) ve onayla
-- ---------------------------------------------------------------------
create or replace function public.kelime_iliski_kaydet(
  p_kaynak_anlam_id uuid,
  p_hedef_anlam_id  uuid,
  p_iliski_turu     text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_id  uuid;
begin
  perform public.kelime_yonetici_kontrol();

  if p_iliski_turu not in ('es_anlamli', 'zit_anlamli', 'es_sesli') then
    raise exception 'BAD_RELATION' using errcode = '22023';
  end if;
  if p_kaynak_anlam_id is null or p_hedef_anlam_id is null or p_kaynak_anlam_id = p_hedef_anlam_id then
    raise exception 'BAD_RELATION_PAIR' using errcode = '22023';
  end if;
  if not exists (select 1 from public.kelime_anlamlari where id = p_kaynak_anlam_id)
     or not exists (select 1 from public.kelime_anlamlari where id = p_hedef_anlam_id) then
    raise exception 'ANLAM_BULUNAMADI' using errcode = 'P0002';
  end if;

  select i.id into v_id
    from public.kelime_iliskileri i
   where i.iliski_turu = p_iliski_turu
     and ((i.kaynak_anlam_id = p_kaynak_anlam_id and i.hedef_anlam_id = p_hedef_anlam_id)
       or (i.kaynak_anlam_id = p_hedef_anlam_id and i.hedef_anlam_id = p_kaynak_anlam_id));
  if found then
    return v_id;
  end if;

  insert into public.kelime_iliskileri (kaynak_anlam_id, hedef_anlam_id, iliski_turu, olusturan_id)
  values (p_kaynak_anlam_id, p_hedef_anlam_id, p_iliski_turu, v_uid)
  returning id into v_id;

  perform public.log_admin_action('kelime_iliski_kaydet', jsonb_build_object('iliski_id', v_id, 'iliski_turu', p_iliski_turu));
  return v_id;
end;
$$;

revoke all on function public.kelime_iliski_kaydet(uuid, uuid, text) from public, anon;
grant execute on function public.kelime_iliski_kaydet(uuid, uuid, text) to authenticated;

create or replace function public.kelime_iliski_onayla(p_iliski_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_row public.kelime_iliskileri%rowtype;
begin
  perform public.kelime_yonetici_kontrol();

  select * into v_row from public.kelime_iliskileri where id = p_iliski_id for update;
  if not found then
    raise exception 'ILISKI_BULUNAMADI' using errcode = 'P0002';
  end if;
  if v_row.onay_tarihi is not null then
    return; -- zaten onaylı: idempotent
  end if;
  if v_row.olusturan_id is not distinct from v_uid then
    raise exception 'DORT_GOZ' using errcode = '42501';
  end if;

  update public.kelime_iliskileri
     set onaylayan_id = v_uid, onay_tarihi = now()
   where id = p_iliski_id;

  perform public.log_admin_action('kelime_iliski_onayla', jsonb_build_object('iliski_id', p_iliski_id));
end;
$$;

revoke all on function public.kelime_iliski_onayla(uuid) from public, anon;
grant execute on function public.kelime_iliski_onayla(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- 17. YÖNETİM: soru taslağı kaydet / düzenle
--     Düzenleme yalnızca taslak ve incelemedeki sorularda yapılır; değişiklik
--     soruyu yeniden taslağa alır (yeniden inceleme gerekir).
-- ---------------------------------------------------------------------
create or replace function public.kelime_soru_kaydet(
  p_id              uuid,
  p_anlam_id        uuid,
  p_iliski_turu     text,
  p_sinif           integer,
  p_kazanim_kodu    text,
  p_soru_metni      text,
  p_secenekler      jsonb,
  p_dogru_indeks    integer,
  p_dogru_anlam_id  uuid,
  p_ipucu           text,
  p_aciklama        text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_sec jsonb;
  v_id  uuid;
begin
  perform public.kelime_yonetici_kontrol();

  if p_iliski_turu not in ('es_anlamli', 'zit_anlamli', 'es_sesli') then
    raise exception 'BAD_RELATION' using errcode = '22023';
  end if;
  if p_sinif is null or p_sinif not between 1 and 12 then
    raise exception 'BAD_SINIF' using errcode = '22023';
  end if;
  if length(btrim(coalesce(p_soru_metni, ''))) not between 5 and 400 then
    raise exception 'BAD_SORU_METNI' using errcode = '22023';
  end if;
  if length(btrim(coalesce(p_aciklama, ''))) not between 5 and 500 then
    raise exception 'BAD_ACIKLAMA' using errcode = '22023';
  end if;
  if p_ipucu is not null and length(btrim(p_ipucu)) > 200 then
    raise exception 'BAD_IPUCU' using errcode = '22023';
  end if;

  -- Şıklar: 2-4 adet, boş olmayan metin, tekrarsız (büyük/küçük harf ve boşluk farkı yok sayılır)
  if jsonb_typeof(p_secenekler) is distinct from 'array' then
    raise exception 'BAD_SECENEK_SAYISI' using errcode = '22023';
  end if;
  if jsonb_array_length(p_secenekler) not between 2 and 4 then
    raise exception 'BAD_SECENEK_SAYISI' using errcode = '22023';
  end if;
  if exists (
       select 1 from jsonb_array_elements(p_secenekler) e
        where jsonb_typeof(e.value) <> 'string'
           or length(btrim(e.value #>> '{}')) not between 1 and 120
     ) then
    raise exception 'BAD_SECENEK' using errcode = '22023';
  end if;
  select coalesce(jsonb_agg(to_jsonb(btrim(e.value #>> '{}')) order by e.ord), '[]'::jsonb)
    into v_sec
    from jsonb_array_elements(p_secenekler) with ordinality as e(value, ord);
  if (select count(distinct lower(e.value #>> '{}')) from jsonb_array_elements(v_sec) e)
     <> jsonb_array_length(v_sec) then
    raise exception 'SECENEK_TEKRARI' using errcode = '22023';
  end if;

  if p_dogru_indeks is null or p_dogru_indeks < 0 or p_dogru_indeks >= jsonb_array_length(v_sec) then
    raise exception 'BAD_DOGRU_INDEKS' using errcode = '22023';
  end if;

  if not exists (select 1 from public.kelime_anlamlari where id = p_anlam_id) then
    raise exception 'ANLAM_BULUNAMADI' using errcode = 'P0002';
  end if;

  -- Doğru şık bir anlamsa, bu anlam ile soru anlamı arasında ONAYLI ilişki olmalı
  if p_dogru_anlam_id is not null
     and not public.kelime_iliski_onayli_mi(p_anlam_id, p_dogru_anlam_id, p_iliski_turu) then
    raise exception 'ILISKI_ONAYSIZ' using errcode = '22023';
  end if;

  if p_id is null then
    insert into public.kelime_sorulari (
      anlam_id, iliski_turu, sinif, kazanim_kodu, soru_metni, secenekler, dogru_indeks,
      dogru_anlam_id, ipucu, aciklama, durum, olusturan_id
    ) values (
      p_anlam_id, p_iliski_turu, p_sinif, nullif(btrim(p_kazanim_kodu), ''), btrim(p_soru_metni), v_sec, p_dogru_indeks,
      p_dogru_anlam_id, nullif(btrim(p_ipucu), ''), btrim(p_aciklama), 'taslak', v_uid
    )
    returning id into v_id;
  else
    update public.kelime_sorulari
       set anlam_id = p_anlam_id,
           iliski_turu = p_iliski_turu,
           sinif = p_sinif,
           kazanim_kodu = nullif(btrim(p_kazanim_kodu), ''),
           soru_metni = btrim(p_soru_metni),
           secenekler = v_sec,
           dogru_indeks = p_dogru_indeks,
           dogru_anlam_id = p_dogru_anlam_id,
           ipucu = nullif(btrim(p_ipucu), ''),
           aciklama = btrim(p_aciklama),
           durum = 'taslak',
           inceleyen_id = null,
           yayin_tarihi = null
     where id = p_id and durum in ('taslak', 'incelemede')
    returning id into v_id;

    if v_id is null then
      if exists (select 1 from public.kelime_sorulari where id = p_id) then
        raise exception 'DUZENLENEMEZ' using errcode = '22023';
      end if;
      raise exception 'SORU_BULUNAMADI' using errcode = 'P0002';
    end if;
  end if;

  perform public.log_admin_action('kelime_soru_kaydet', jsonb_build_object('soru_id', v_id));
  return v_id;
end;
$$;

revoke all on function public.kelime_soru_kaydet(uuid, uuid, text, integer, text, text, jsonb, integer, uuid, text, text) from public, anon;
grant execute on function public.kelime_soru_kaydet(uuid, uuid, text, integer, text, text, jsonb, integer, uuid, text, text) to authenticated;

-- ---------------------------------------------------------------------
-- 18. YÖNETİM: durum geçişi (taslak → incelemede → yayında → arşiv)
--     Yayın yalnızca incelemedeki soruda ve taslağı yazandan FARKLI bir yönetici tarafından yapılır.
-- ---------------------------------------------------------------------
create or replace function public.kelime_soru_durum_degistir(
  p_id     uuid,
  p_hedef  text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_s   public.kelime_sorulari%rowtype;
begin
  perform public.kelime_yonetici_kontrol();

  if p_hedef not in ('taslak', 'incelemede', 'yayinda', 'arsiv') then
    raise exception 'BAD_DURUM' using errcode = '22023';
  end if;

  select * into v_s from public.kelime_sorulari where id = p_id for update;
  if not found then
    raise exception 'SORU_BULUNAMADI' using errcode = 'P0002';
  end if;

  if not (
       (v_s.durum = 'taslak'     and p_hedef = 'incelemede')
    or (v_s.durum = 'incelemede' and p_hedef in ('taslak', 'yayinda'))
    or (v_s.durum = 'yayinda'    and p_hedef = 'arsiv')
    or (v_s.durum = 'arsiv'      and p_hedef = 'taslak')
  ) then
    raise exception 'GECERSIZ_GECIS' using errcode = '22023';
  end if;

  if p_hedef = 'yayinda' then
    if v_s.olusturan_id is not distinct from v_uid then
      raise exception 'DORT_GOZ' using errcode = '42501';
    end if;
    if v_s.dogru_anlam_id is not null
       and not public.kelime_iliski_onayli_mi(v_s.anlam_id, v_s.dogru_anlam_id, v_s.iliski_turu) then
      raise exception 'ILISKI_ONAYSIZ' using errcode = '22023';
    end if;

    update public.kelime_sorulari
       set durum = 'yayinda', inceleyen_id = v_uid, yayin_tarihi = now()
     where id = p_id;
  else
    update public.kelime_sorulari
       set durum = p_hedef,
           inceleyen_id = case when p_hedef = 'arsiv' then inceleyen_id else null end,
           yayin_tarihi = case when p_hedef in ('taslak', 'incelemede') then null else yayin_tarihi end
     where id = p_id;
  end if;

  perform public.log_admin_action('kelime_soru_durum', jsonb_build_object(
    'soru_id', p_id, 'onceki', v_s.durum, 'yeni', p_hedef));

  return jsonb_build_object('id', p_id, 'durum', p_hedef);
end;
$$;

revoke all on function public.kelime_soru_durum_degistir(uuid, text) from public, anon;
grant execute on function public.kelime_soru_durum_degistir(uuid, text) to authenticated;

-- ---------------------------------------------------------------------
-- 19. YÖNETİM: listeler (toplam + satırlar; kişisel veri yok)
-- ---------------------------------------------------------------------
create or replace function public.kelime_yonetim_liste(
  p_durum      text default null,
  p_sinif      smallint default null,
  p_iliski_turu text default null,
  p_limit      integer default 200
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_limit   integer := least(greatest(coalesce(p_limit, 200), 1), 500);
  v_toplam  integer;
  v_satirlar jsonb;
begin
  perform public.kelime_yonetici_kontrol();

  select count(*) into v_toplam
    from public.kelime_sorulari s
   where (p_durum is null or s.durum = p_durum)
     and (p_sinif is null or s.sinif = p_sinif)
     and (p_iliski_turu is null or s.iliski_turu = p_iliski_turu);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.guncellendi desc), '[]'::jsonb) into v_satirlar
    from (
      select s.id, a.kelime, a.anlam, s.anlam_id, s.iliski_turu, s.sinif, s.kazanim_kodu,
             s.soru_metni, s.secenekler, s.dogru_indeks, s.dogru_anlam_id, s.ipucu, s.aciklama,
             s.durum, s.olusturan_id, s.inceleyen_id, s.yayin_tarihi,
             s.updated_at as guncellendi
        from public.kelime_sorulari s
        join public.kelime_anlamlari a on a.id = s.anlam_id
       where (p_durum is null or s.durum = p_durum)
         and (p_sinif is null or s.sinif = p_sinif)
         and (p_iliski_turu is null or s.iliski_turu = p_iliski_turu)
       order by s.updated_at desc
       limit v_limit
    ) x;

  return jsonb_build_object('toplam', v_toplam, 'satirlar', v_satirlar);
end;
$$;

revoke all on function public.kelime_yonetim_liste(text, smallint, text, integer) from public, anon;
grant execute on function public.kelime_yonetim_liste(text, smallint, text, integer) to authenticated;

create or replace function public.kelime_yonetim_anlamlar()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.kelime_yonetici_kontrol();

  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.kelime, x.anlam)
      from (
        select a.id, a.kelime, a.anlam, a.sozcuk_turu,
               (select count(*) from public.kelime_iliskileri i
                 where i.onay_tarihi is not null
                   and (i.kaynak_anlam_id = a.id or i.hedef_anlam_id = a.id)) as onayli_iliski
          from public.kelime_anlamlari a
         limit 1000
      ) x
  ), '[]'::jsonb);
end;
$$;

revoke all on function public.kelime_yonetim_anlamlar() from public, anon;
grant execute on function public.kelime_yonetim_anlamlar() to authenticated;

create or replace function public.kelime_yonetim_iliskiler()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.kelime_yonetici_kontrol();

  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.olusturuldu desc)
      from (
        select i.id, i.iliski_turu,
               ka.kelime as kaynak_kelime, ka.anlam as kaynak_anlam,
               ha.kelime as hedef_kelime, ha.anlam as hedef_anlam,
               i.onay_tarihi, i.olusturan_id, i.onaylayan_id,
               i.created_at as olusturuldu
          from public.kelime_iliskileri i
          join public.kelime_anlamlari ka on ka.id = i.kaynak_anlam_id
          join public.kelime_anlamlari ha on ha.id = i.hedef_anlam_id
         order by i.created_at desc
         limit 500
      ) x
  ), '[]'::jsonb);
end;
$$;

revoke all on function public.kelime_yonetim_iliskiler() from public, anon;
grant execute on function public.kelime_yonetim_iliskiler() to authenticated;

-- ---------------------------------------------------------------------
-- 20. YÖNETİM: metrikler (toplu; öğrenci bazında kırılım yok)
--     İpucu ile bağımsız doğruluk ayrı raporlanır (A/B öğrenme ölçümü).
-- ---------------------------------------------------------------------
create or replace function public.kelime_metrikleri()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.kelime_yonetici_kontrol();

  return jsonb_build_object(
    'durumlar', coalesce((
      select jsonb_object_agg(d.durum, d.adet)
        from (select s.durum, count(*) as adet from public.kelime_sorulari s group by s.durum) d
    ), '{}'::jsonb),
    'yayinda_dagilim', coalesce((
      select jsonb_agg(jsonb_build_object('sinif', g.sinif, 'iliski_turu', g.iliski_turu, 'adet', g.adet)
                       order by g.sinif, g.iliski_turu)
        from (select s.sinif, s.iliski_turu, count(*) as adet
                from public.kelime_sorulari s
               where s.durum = 'yayinda'
               group by s.sinif, s.iliski_turu) g
    ), '[]'::jsonb),
    'son_7_gun', (
      select jsonb_build_object(
               'deneme', count(*),
               'ogrenci', count(distinct d.ogrenci_id),
               'dogru_orani', case when count(*) = 0 then null
                              else round(100.0 * count(*) filter (where d.dogru_mu) / count(*)) end,
               'ipucu_orani', case when count(*) = 0 then null
                              else round(100.0 * count(*) filter (where d.ipucu_kullanildi) / count(*)) end,
               'ipucusuz_dogru_orani', case when count(*) filter (where not d.ipucu_kullanildi) = 0 then null
                              else round(100.0 * count(*) filter (where d.dogru_mu and not d.ipucu_kullanildi)
                                         / count(*) filter (where not d.ipucu_kullanildi)) end
             )
        from public.kelime_denemeleri d
       where d.created_at > now() - interval '7 days'
    )
  );
end;
$$;

revoke all on function public.kelime_metrikleri() from public, anon;
grant execute on function public.kelime_metrikleri() to authenticated;
