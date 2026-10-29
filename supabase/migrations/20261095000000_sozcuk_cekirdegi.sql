-- =====================================================================
-- SÖZCÜK ÇEKİRDEĞİ — Faz 1 (docs/kelime-evreni/AR_GE_PLANI.md)
--
-- Kullanıcı kararları (2026-10-25):
--   * Dört göz kuralı kalkar. Yeni yayın kuralı: İKİ FARKLI AİLEDEN AI MODELİ "pass" + insan kontrolü.
--     "İnsan kontrolü" = yöneticinin yayın/onay RPC'sini kendisinin çağırması.
--   * Arena kelime modunda doğru puanı zorluğa göre 3/4/5, yanlış -1, en az 0; 4 kolay / 4 orta / 2 zor.
--     Genel soru Arena'sı (oyun_turu = 'soru') değişmez.
--   * Deyim ve atasözü oyun alanı olarak eklenir (seçmeli; meydan okuyan alanı seçer).
--
-- Kapsam: ek-only. Mevcut verinin hiçbir satırı silinmez ya da değişmez.
--   1. kelime_anlamlari: tur, ornek_cumle, sinif_alt/ust, zorluk; sozcuk_turu genişler.
--   2. kelime_sorulari: yeni soru türleri; kanit_duzeyi.
--   3. kelime_denetim_kayitlari + kelime_denetim_kaydet(): model denetimi kaydı.
--   4. Dört göz CHECK'leri kaldırılır; kelime_iliski_onayla / kelime_soru_durum_degistir yeni kural.
--   5. okuma_sozluk_girdi_onayla(): hikâye sözlüğü toplu onay (K-0141 açık işi).
--   6. kelime_hikaye_baglari: çekirdek anlam <-> hikâye sözlüğü girdisi köprüsü.
--   7. Arena: create_kelime_challenge (dengeli dağılım, yeni türler), submit_challenge (kelime puanı).
-- Ön koşul: 20261022000000..20261023000000 (Kelime Evreni), 20261050000400 (okuma sözlüğü).
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. kelime_anlamlari
-- ---------------------------------------------------------------------
alter table public.kelime_anlamlari
  add column if not exists tur         text not null default 'kelime',
  add column if not exists ornek_cumle text,
  add column if not exists sinif_alt   smallint,
  add column if not exists sinif_ust   smallint,
  add column if not exists zorluk      smallint;

alter table public.kelime_anlamlari drop constraint if exists kelime_anlamlari_tur_check;
alter table public.kelime_anlamlari add constraint kelime_anlamlari_tur_check
  check (tur in ('kelime', 'deyim', 'atasozu'));
alter table public.kelime_anlamlari drop constraint if exists kelime_anlamlari_ornek_cumle_check;
alter table public.kelime_anlamlari add constraint kelime_anlamlari_ornek_cumle_check
  check (ornek_cumle is null or length(btrim(ornek_cumle)) between 5 and 300);
alter table public.kelime_anlamlari drop constraint if exists kelime_anlamlari_sinif_check;
alter table public.kelime_anlamlari add constraint kelime_anlamlari_sinif_check
  check ((sinif_alt is null and sinif_ust is null)
         or (sinif_alt between 1 and 8 and sinif_ust between 1 and 8 and sinif_alt <= sinif_ust));
alter table public.kelime_anlamlari drop constraint if exists kelime_anlamlari_zorluk_check;
alter table public.kelime_anlamlari add constraint kelime_anlamlari_zorluk_check
  check (zorluk is null or zorluk between 1 and 3);

alter table public.kelime_anlamlari drop constraint if exists kelime_anlamlari_sozcuk_turu_check;
alter table public.kelime_anlamlari add constraint kelime_anlamlari_sozcuk_turu_check
  check (sozcuk_turu is null or sozcuk_turu in
    ('isim', 'sifat', 'fiil', 'zarf', 'baglac', 'zamir', 'edat', 'unlem', 'diger'));

comment on column public.kelime_anlamlari.zorluk is
  'Editoryal başlangıç zorluğu (1-3). Ölçülen zorluk gerçek denemelerden ayrıca hesaplanır.';

-- ---------------------------------------------------------------------
-- 2. kelime_sorulari: yeni soru türleri ve kanıt düzeyi
-- ---------------------------------------------------------------------
alter table public.kelime_sorulari drop constraint if exists kelime_sorulari_iliski_turu_check;
alter table public.kelime_sorulari add constraint kelime_sorulari_iliski_turu_check
  check (iliski_turu in ('es_anlamli', 'zit_anlamli', 'es_sesli', 'deyim', 'atasozu', 'sozcuk_turu', 'baglamda_anlam'));

alter table public.kelime_sorulari
  add column if not exists kanit_duzeyi text not null default 'source_pending';
alter table public.kelime_sorulari drop constraint if exists kelime_sorulari_kanit_duzeyi_check;
alter table public.kelime_sorulari add constraint kelime_sorulari_kanit_duzeyi_check
  check (kanit_duzeyi in ('A', 'B', 'C', 'source_pending'));

alter table public.meydan_okumalar drop constraint if exists meydan_okumalar_kelime_iliski_turu_check;
alter table public.meydan_okumalar add constraint meydan_okumalar_kelime_iliski_turu_check
  check (kelime_iliski_turu is null
         or kelime_iliski_turu in ('es_anlamli', 'zit_anlamli', 'es_sesli', 'deyim', 'atasozu', 'sozcuk_turu', 'baglamda_anlam'));

-- Tür listesini sabit yazan iki mevcut fonksiyonun gövdesinde yalnızca listeyi genişletir.
do $$
declare
  r      record;
  v_def  text;
  v_eski constant text := '(''es_anlamli'', ''zit_anlamli'', ''es_sesli'')';
  v_yeni constant text := '(''es_anlamli'', ''zit_anlamli'', ''es_sesli'', ''deyim'', ''atasozu'', ''sozcuk_turu'', ''baglamda_anlam'')';
begin
  for r in
    select p.oid, p.proname
      from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.proname in ('kelime_oyun_getir', 'kelime_soru_kaydet')
  loop
    v_def := pg_get_functiondef(r.oid);
    if position(v_eski in v_def) = 0 then
      raise exception 'tur listesi % gövdesinde bulunamadı', r.proname;
    end if;
    execute replace(v_def, v_eski, v_yeni);
  end loop;
end
$$;

-- ---------------------------------------------------------------------
-- 3. Model denetim kayıtları
-- ---------------------------------------------------------------------
create table if not exists public.kelime_denetim_kayitlari (
  id            uuid primary key default gen_random_uuid(),
  hedef_tur     text not null check (hedef_tur in ('soru', 'iliski', 'sozluk')),
  hedef_id      text not null check (length(hedef_id) between 1 and 80),
  denetci_model text not null check (length(btrim(denetci_model)) between 2 and 60),
  denetci_aile  text not null check (denetci_aile in ('claude', 'gemini', 'gpt', 'diger')),
  karar         text not null check (karar in ('pass', 'review_needed', 'fail')),
  not_metni     text check (not_metni is null or length(not_metni) <= 1000),
  olusturan_id  uuid references auth.users (id) on delete set null,
  created_at    timestamptz not null default now()
);
create index if not exists kelime_denetim_hedef_idx
  on public.kelime_denetim_kayitlari (hedef_tur, hedef_id, created_at desc);

alter table public.kelime_denetim_kayitlari enable row level security;
revoke all on public.kelime_denetim_kayitlari from public, anon, authenticated;
drop policy if exists "kelime denetim yonetici okur" on public.kelime_denetim_kayitlari;
create policy "kelime denetim yonetici okur"
  on public.kelime_denetim_kayitlari for select to authenticated
  using ((select public.is_admin()));

-- İki FARKLI AİLEDEN model "pass" verdi mi? Her model için son karar geçerlidir; herhangi bir son karar
-- pass değilse kapı kapalıdır. p_sonra doluysa yalnızca o andan sonraki kayıtlar sayılır.
create or replace function public._kelime_iki_model_gecti(p_tur text, p_id text, p_sonra timestamptz)
returns boolean
language sql
stable
set search_path = ''
as $$
  select coalesce(
           count(distinct t.denetci_aile) filter (where t.karar = 'pass') >= 2
           and bool_and(t.karar = 'pass'),
           false)
    from (
      select distinct on (k.denetci_model) k.denetci_model, k.denetci_aile, k.karar
        from public.kelime_denetim_kayitlari k
       where k.hedef_tur = p_tur and k.hedef_id = p_id
         and (p_sonra is null or k.created_at >= p_sonra)
       order by k.denetci_model, k.created_at desc
    ) t;
$$;
revoke all on function public._kelime_iki_model_gecti(text, text, timestamptz) from public, anon, authenticated;

create or replace function public.kelime_denetim_kaydet(
  p_hedef_tur text,
  p_hedef_id  text,
  p_model     text,
  p_aile      text,
  p_karar     text,
  p_not       text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id uuid;
begin
  perform public.kelime_yonetici_kontrol();

  if p_hedef_tur = 'soru' then
    if not exists (select 1 from public.kelime_sorulari
                    where id::text = p_hedef_id and durum = 'incelemede') then
      raise exception 'DENETIM_HEDEFI_INCELEMEDE_DEGIL' using errcode = '22023';
    end if;
  elsif p_hedef_tur = 'iliski' then
    if not exists (select 1 from public.kelime_iliskileri where id::text = p_hedef_id) then
      raise exception 'ILISKI_BULUNAMADI' using errcode = 'P0002';
    end if;
  elsif p_hedef_tur = 'sozluk' then
    if not exists (select 1 from public.okuma_sozluk_girdileri where id = p_hedef_id) then
      raise exception 'GIRDI_BULUNAMADI' using errcode = 'P0002';
    end if;
  else
    raise exception 'BAD_HEDEF' using errcode = '22023';
  end if;

  insert into public.kelime_denetim_kayitlari
    (hedef_tur, hedef_id, denetci_model, denetci_aile, karar, not_metni, olusturan_id, created_at)
  values
    (p_hedef_tur, p_hedef_id, btrim(p_model), p_aile, p_karar, nullif(btrim(p_not), ''), (select auth.uid()),
     clock_timestamp())
  returning id into v_id;

  perform public.log_admin_action('kelime_denetim_kaydet', jsonb_build_object(
    'hedef_tur', p_hedef_tur, 'hedef_id', p_hedef_id, 'model', p_model, 'karar', p_karar));
  return v_id;
end;
$$;
revoke all on function public.kelime_denetim_kaydet(text, text, text, text, text, text) from public, anon;
grant execute on function public.kelime_denetim_kaydet(text, text, text, text, text, text) to authenticated;

-- ---------------------------------------------------------------------
-- 4. Dört göz kalkar; yerine model denetimi
-- ---------------------------------------------------------------------
alter table public.kelime_sorulari drop constraint if exists kelime_sorulari_yayin_dort_goz;
alter table public.kelime_sorulari drop constraint if exists kelime_sorulari_yayin_kosullari;
alter table public.kelime_sorulari add constraint kelime_sorulari_yayin_kosullari
  check (durum <> 'yayinda' or (inceleyen_id is not null and yayin_tarihi is not null));

alter table public.okuma_sozluk_girdileri drop constraint if exists okuma_sozluk_girdi_dort_goz;
alter table public.okuma_sozluk_girdileri drop constraint if exists okuma_sozluk_girdi_onay_kosulu;
alter table public.okuma_sozluk_girdileri add constraint okuma_sozluk_girdi_onay_kosulu
  check (durum <> 'onayli' or onaylayan_id is not null);

do $$
declare
  r record;
begin
  for r in
    select c.conname
      from pg_constraint c
     where c.conrelid = 'public.kelime_iliskileri'::regclass and c.contype = 'c'
       and pg_get_constraintdef(c.oid) ilike '%DISTINCT FROM olusturan_id%'
  loop
    execute format('alter table public.kelime_iliskileri drop constraint %I', r.conname);
  end loop;
end
$$;

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
  if not public._kelime_iki_model_gecti('iliski', p_iliski_id::text, null) then
    raise exception 'DENETIM_EKSIK' using errcode = '42501';
  end if;

  update public.kelime_iliskileri
     set onaylayan_id = v_uid, onay_tarihi = now()
   where id = p_iliski_id;

  perform public.log_admin_action('kelime_iliski_onayla', jsonb_build_object('iliski_id', p_iliski_id));
end;
$$;
revoke all on function public.kelime_iliski_onayla(uuid) from public, anon;
grant execute on function public.kelime_iliski_onayla(uuid) to authenticated;

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
    -- Yeni kural: son düzenlemeden sonra iki farklı aileden model "pass" vermiş olmalı.
    if not public._kelime_iki_model_gecti('soru', p_id::text, v_s.updated_at) then
      raise exception 'DENETIM_EKSIK' using errcode = '42501';
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
-- 5. Hikâye sözlüğü: toplu onay (yalnızca iki modelden pass alan, taslak/incelemedeki girdiler)
-- ---------------------------------------------------------------------
create or replace function public.okuma_sozluk_girdi_onayla(p_ids text[])
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid       uuid := (select auth.uid());
  v_id        text;
  v_g         public.okuma_sozluk_girdileri%rowtype;
  v_onaylanan integer := 0;
  v_atlanan   jsonb := '[]'::jsonb;
begin
  perform public.kelime_yonetici_kontrol();

  if p_ids is null or coalesce(array_length(p_ids, 1), 0) not between 1 and 500 then
    raise exception 'BAD_LISTE' using errcode = '22023';
  end if;

  foreach v_id in array p_ids loop
    select * into v_g from public.okuma_sozluk_girdileri where id = v_id for update;
    if not found then
      v_atlanan := v_atlanan || jsonb_build_object('id', v_id, 'neden', 'yok');
    elsif v_g.durum = 'onayli' then
      null; -- idempotent
    elsif v_g.durum not in ('taslak', 'incelemede') then
      v_atlanan := v_atlanan || jsonb_build_object('id', v_id, 'neden', 'durum');
    elsif not public._kelime_iki_model_gecti('sozluk', v_id, v_g.guncellendi_at) then
      v_atlanan := v_atlanan || jsonb_build_object('id', v_id, 'neden', 'denetim_eksik');
    else
      update public.okuma_sozluk_girdileri
         set durum = 'onayli', onaylayan_id = v_uid, onaylandi_at = now()
       where id = v_id;
      v_onaylanan := v_onaylanan + 1;
    end if;
  end loop;

  perform public.log_admin_action('okuma_sozluk_girdi_onayla', jsonb_build_object(
    'istenen', array_length(p_ids, 1), 'onaylanan', v_onaylanan));
  return jsonb_build_object('onaylanan', v_onaylanan, 'atlanan', v_atlanan);
end;
$$;
revoke all on function public.okuma_sozluk_girdi_onayla(text[]) from public, anon;
grant execute on function public.okuma_sozluk_girdi_onayla(text[]) to authenticated;

-- ---------------------------------------------------------------------
-- 6. Çekirdek anlam <-> hikâye sözlüğü köprüsü (otomatik eşleşme kanıt sayılmaz: oneri -> onayli)
-- ---------------------------------------------------------------------
create table if not exists public.kelime_hikaye_baglari (
  anlam_id        uuid not null references public.kelime_anlamlari (id) on delete cascade,
  sozluk_girdi_id text not null references public.okuma_sozluk_girdileri (id) on delete cascade,
  durum           text not null default 'oneri' check (durum in ('oneri', 'onayli', 'red')),
  created_at      timestamptz not null default now(),
  primary key (anlam_id, sozluk_girdi_id)
);
create index if not exists kelime_hikaye_baglari_girdi_idx on public.kelime_hikaye_baglari (sozluk_girdi_id);

alter table public.kelime_hikaye_baglari enable row level security;
revoke all on public.kelime_hikaye_baglari from public, anon, authenticated;
drop policy if exists "kelime hikaye baglari yonetici okur" on public.kelime_hikaye_baglari;
create policy "kelime hikaye baglari yonetici okur"
  on public.kelime_hikaye_baglari for select to authenticated
  using ((select public.is_admin()));

-- ---------------------------------------------------------------------
-- 7. Arena
-- ---------------------------------------------------------------------
create or replace function public.create_kelime_challenge(p_iliski_turu text default null)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := auth.uid();
  v_sinif   smallint;
  v_kod     text;
  v_sorular jsonb;
  v_id      uuid;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'STUDENT_ONLY' using errcode = '42501';
  end if;

  select p.sinif into v_sinif from public.profiles p where p.id = v_uid;
  if v_sinif is null then
    raise exception 'SINIF_GEREKLI' using errcode = '22023';
  end if;

  if p_iliski_turu is not null and p_iliski_turu not in
     ('es_anlamli', 'zit_anlamli', 'es_sesli', 'deyim', 'atasozu', 'sozcuk_turu', 'baglamda_anlam') then
    raise exception 'BAD_RELATION' using errcode = '22023';
  end if;

  for i in 1..5 loop
    v_kod := public._uret_meydan_kod();
    exit when not exists (select 1 from public.meydan_okumalar where kod = v_kod);
  end loop;

  -- Dengeli dağılım: kolay 4 / orta 4 / zor 2. Bir zorlukta yetmezse kalan kontenjan öteki sorularla dolar.
  select jsonb_agg(
           jsonb_build_object(
             'id',         q.id,
             'soru_metni', q.soru_metni,
             'siklar',     q.siklar,
             'konu',       q.konu,
             'zorluk',     q.zorluk
           ) order by q.rastgele)
    into v_sorular
    from (
      select * from (
        select s.id,
               s.soru_metni,
               (select jsonb_object_agg(chr((64 + e.ord)::int), e.val)
                  from jsonb_array_elements_text(s.secenekler) with ordinality as e(val, ord)) as siklar,
               case s.iliski_turu
                 when 'es_anlamli'     then 'Anlam Köprüleri'
                 when 'zit_anlamli'    then 'Zıtlık Vadisi'
                 when 'es_sesli'       then 'Aynalar Ormanı'
                 when 'deyim'          then 'Deyimler Diyarı'
                 when 'atasozu'        then 'Atasözü Pınarı'
                 when 'sozcuk_turu'    then 'Tür Bahçesi'
                 else 'Bağlam Yolu'
               end as konu,
               s.zorluk,
               random() as rastgele,
               row_number() over (partition by s.zorluk order by random()) as sira
          from public.kelime_sorulari s
         where s.durum = 'yayinda'
           and s.sinif = v_sinif
           and (p_iliski_turu is null or s.iliski_turu = p_iliski_turu)
      ) x
      order by (x.sira <= case x.zorluk when 1 then 4 when 2 then 4 else 2 end) desc, x.rastgele
      limit 10
    ) q;

  if v_sorular is null or jsonb_array_length(v_sorular) < 3 then
    raise exception 'Yeterli soru bulunamadı';
  end if;

  insert into public.meydan_okumalar (kod, davet_eden, sorular, oyun_turu, kelime_iliski_turu)
  values (v_kod, v_uid, v_sorular, 'kelime', p_iliski_turu)
  returning id into v_id;

  return jsonb_build_object(
    'id',           v_id,
    'kod',          v_kod,
    'sorular',      v_sorular,
    'sure_dakika',  5,
    'durum',        'bekliyor',
    'oyun_turu',    'kelime'
  );
end;
$$;
revoke execute on function public.create_kelime_challenge(text) from public, anon;
grant  execute on function public.create_kelime_challenge(text) to authenticated;

-- submit_challenge: 20261022000002 sürümü + kelime puanı. Kelime meydanında doğru puanı 2 + zorluk
-- (3/4/5), yanlış -1, en az 0. Genel soru meydanı aynı: doğru x 4 - yanlış.
create or replace function public.submit_challenge(
  p_meydan_id uuid,
  p_cevaplar  jsonb   -- [{question_id: uuid, secilen_sik: text|null}]
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid        uuid := auth.uid();
  v_row        public.meydan_okumalar;
  v_dogru      int := 0;
  v_yanlis     int := 0;
  v_kazanc     int := 0;
  v_puan       numeric;
  v_cevap      jsonb;
  v_soru_id    uuid;
  v_dogru_sik  text;
  v_dogru_idx  smallint;
  v_zorluk     smallint;
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı';
  end if;

  select * into v_row from public.meydan_okumalar where id = p_meydan_id;

  if not found then
    raise exception 'Meydan okuma bulunamadı';
  end if;
  if v_uid is distinct from v_row.davet_eden and v_uid is distinct from v_row.davet_edilen then
    raise exception 'Bu meydan okumaya erişim yok';
  end if;
  if v_row.durum = 'bekliyor' then
    raise exception 'Meydan okuma henüz başlamadı';
  end if;

  if exists (
    select 1 from public.meydan_okuma_cevaplar
    where meydan_okuma_id = p_meydan_id and student_id = v_uid
      and bitis_zamani is not null
  ) then
    select jsonb_build_object(
      'dogru_sayisi', dogru_sayisi,
      'yanlis_sayisi', yanlis_sayisi,
      'puan', puan
    ) into v_cevap
    from public.meydan_okuma_cevaplar
    where meydan_okuma_id = p_meydan_id and student_id = v_uid;
    return v_cevap;
  end if;

  for v_cevap in select * from jsonb_array_elements(p_cevaplar) loop
    v_soru_id := (v_cevap->>'question_id')::uuid;

    if not exists (
      select 1 from jsonb_array_elements(v_row.sorular) s
       where (s->>'id')::uuid = v_soru_id
    ) then
      continue;
    end if;

    if v_row.oyun_turu = 'kelime' then
      select k.dogru_indeks, k.zorluk into v_dogru_idx, v_zorluk
        from public.kelime_sorulari k where k.id = v_soru_id;
      v_dogru_sik := chr(65 + v_dogru_idx);
    else
      select q.dogru_sik into v_dogru_sik
        from public.questions q where q.id = v_soru_id;
      v_zorluk := null;
    end if;

    if (v_cevap->>'secilen_sik') is not null then
      if (v_cevap->>'secilen_sik') = v_dogru_sik then
        v_dogru := v_dogru + 1;
        v_kazanc := v_kazanc + case when v_row.oyun_turu = 'kelime' then 2 + coalesce(v_zorluk, 2) else 4 end;
      else
        v_yanlis := v_yanlis + 1;
      end if;
    end if;
  end loop;

  v_puan := greatest(0, v_kazanc - v_yanlis);

  insert into public.meydan_okuma_cevaplar
    (meydan_okuma_id, student_id, cevaplar, dogru_sayisi, yanlis_sayisi, puan, bitis_zamani)
  values
    (p_meydan_id, v_uid, p_cevaplar, v_dogru, v_yanlis, v_puan, now())
  on conflict (meydan_okuma_id, student_id)
  do update set
    cevaplar     = excluded.cevaplar,
    dogru_sayisi = excluded.dogru_sayisi,
    yanlis_sayisi = excluded.yanlis_sayisi,
    puan         = excluded.puan,
    bitis_zamani = excluded.bitis_zamani;

  if (
    select count(*) from public.meydan_okuma_cevaplar
    where meydan_okuma_id = p_meydan_id and bitis_zamani is not null
  ) >= 2 then
    update public.meydan_okumalar set durum = 'bitti' where id = p_meydan_id;
  end if;

  return jsonb_build_object(
    'dogru_sayisi',  v_dogru,
    'yanlis_sayisi', v_yanlis,
    'puan',          v_puan
  );
end;
$$;
revoke execute on function public.submit_challenge(uuid, jsonb) from public, anon;
grant  execute on function public.submit_challenge(uuid, jsonb) to authenticated;
