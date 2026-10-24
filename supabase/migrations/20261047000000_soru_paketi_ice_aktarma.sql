-- =====================================================================
-- Soru Atölyesi → yönetim paneli: JSON soru paketi içe aktarma (Faz 6)
--   * questions'a Soru Atölyesi alanları (hepsi nullable).
--   * Yeni alanlara İSTEMCİ yetkisi VERİLMEZ: öğrenci uygulaması ipucu/yanlış şık
--     açıklamalarını göremez (cevaptan önce sızıntı olmasın).
--   * Yazma yalnızca admin RPC'leriyle (security definer) yapılır.
--   * Sınıf zorunlu ve 1–8. Eski CSV yolunun sınıf boşluğu bu RPC'de kapanır.
--   * Geri alma soruyu SİLMEZ; onay_durumu'nu 'reddedildi' yapar (cevap geçmişi korunur).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. questions: yeni alanlar
-- ---------------------------------------------------------------------
alter table public.questions
  add column if not exists dis_soru_id text,
  add column if not exists ipuclari jsonb,
  add column if not exists kisa_aciklama text,
  add column if not exists yanlis_sik_geri_bildirimi jsonb,
  add column if not exists kazanim_kodu text,
  add column if not exists kazanim_metni text,
  add column if not exists unite text,
  add column if not exists beceri text,
  add column if not exists bilissel_duzey text,
  add column if not exists zorluk_gerekcesi text,
  add column if not exists tahmini_sure_sn smallint,
  add column if not exists kaynak_id text,
  add column if not exists kaynak_sayfa integer,
  add column if not exists kaynak_turu text,
  add column if not exists uretim_yontemi text,
  add column if not exists ebeveyn_dis_id text,
  add column if not exists uretim_partisi text,
  add column if not exists prompt_surumu text,
  add column if not exists model text,
  add column if not exists kalite_durumu text,
  add column if not exists gorsel_gerekli boolean not null default false,
  add column if not exists insan_onayi_kim text,
  add column if not exists insan_onayi_zaman timestamptz,
  add column if not exists insan_onayi_karar text;

alter table public.questions drop constraint if exists questions_kaynak_turu_check;
alter table public.questions add constraint questions_kaynak_turu_check
  check (kaynak_turu is null or kaynak_turu in ('birebir', 'uyarlama', 'uretilen'));

alter table public.questions drop constraint if exists questions_uretim_yontemi_check;
alter table public.questions add constraint questions_uretim_yontemi_check
  check (uretim_yontemi is null or uretim_yontemi in ('pdf', 'sablon', 'llm', 'elle'));

alter table public.questions drop constraint if exists questions_kalite_durumu_check;
alter table public.questions add constraint questions_kalite_durumu_check
  check (kalite_durumu is null or kalite_durumu in ('yesil', 'sari', 'kirmizi'));

alter table public.questions drop constraint if exists questions_insan_onayi_karar_check;
alter table public.questions add constraint questions_insan_onayi_karar_check
  check (insan_onayi_karar is null or insan_onayi_karar in ('onay', 'duzeltildi', 'red'));

-- Dış kimlik (paketteki soru_id) tekil olsun: aynı soru iki kez girilemez.
create unique index if not exists questions_dis_soru_id_uidx
  on public.questions (dis_soru_id) where dis_soru_id is not null;

create index if not exists questions_uretim_partisi_idx
  on public.questions (uretim_partisi) where uretim_partisi is not null;

-- ---------------------------------------------------------------------
-- 2. Parti ve kaynak kayıtları (yalnız admin okur; yazma RPC ile)
-- ---------------------------------------------------------------------
create table if not exists public.soru_importlari (
  id                uuid primary key default gen_random_uuid(),
  parti_id          text not null unique,
  olusturan         uuid references auth.users (id) on delete set null,
  olusturuldu       timestamptz not null default now(),
  aciklama          text,
  istenen           integer not null default 0,
  eklenen           integer not null default 0,
  tekrar            integer not null default 0,
  hatali            integer not null default 0,
  onayli            boolean not null default false,
  durum             text not null default 'aktif' check (durum in ('aktif', 'geri_alindi')),
  geri_alindi_zaman timestamptz
);

create table if not exists public.soru_kaynaklari (
  kaynak_id       text primary key check (kaynak_id ~ '^[a-z0-9][a-z0-9-]{2,63}$'),
  baslik          text not null,
  yayinci         text,
  yil             integer,
  url             text,
  sha256          text,
  sinif           smallint check (sinif between 1 and 8),
  ders            text,
  lisans_durumu   text not null check (lisans_durumu in ('kullanici_beyani_serbest', 'acik_lisans', 'yazili_izin', 'belirsiz')),
  lisans_dayanagi text,
  indirme_tarihi  date,
  eklendi         timestamptz not null default now()
);

alter table public.soru_importlari enable row level security;
alter table public.soru_kaynaklari enable row level security;

drop policy if exists soru_importlari_admin_select on public.soru_importlari;
create policy soru_importlari_admin_select on public.soru_importlari
  for select to authenticated using (public.is_admin());

drop policy if exists soru_kaynaklari_admin_select on public.soru_kaynaklari;
create policy soru_kaynaklari_admin_select on public.soru_kaynaklari
  for select to authenticated using (public.is_admin());

revoke all on public.soru_importlari from anon, authenticated;
revoke all on public.soru_kaynaklari from anon, authenticated;
grant select on public.soru_importlari to authenticated;
grant select on public.soru_kaynaklari to authenticated;

-- ---------------------------------------------------------------------
-- 3. Tek soru doğrulaması (paket satırı için)
-- ---------------------------------------------------------------------
create or replace function public._soru_paket_hatasi(p jsonb, p_kaynaklar jsonb)
returns text
language plpgsql
stable
set search_path = ''
as $$
declare
  v_hata text;
  v_kaynak jsonb;
begin
  if nullif(trim(coalesce(p ->> 'soru_id', '')), '') is null
     or (p ->> 'soru_id') !~ '^[a-z0-9][a-z0-9-]{5,80}$' then
    return 'soru_id geçersiz (küçük harf, rakam, tire; 6–81 karakter)';
  end if;

  if coalesce(p ->> 'sinif', '') !~ '^[1-8]$' then
    return 'sınıf zorunlu ve 1–8 arasında olmalı';
  end if;

  if p ->> 'okul' is distinct from
     (case when (p ->> 'sinif')::int <= 4 then 'ilkokul' else 'ortaokul' end) then
    return 'okul, sınıfla uyuşmuyor (1–4 ilkokul, 5–8 ortaokul)';
  end if;

  -- Ortak alan kuralları (ders, konu, metin, zorluk, şıklar, doğru şık) mevcut doğrulayıcıdan
  v_hata := public._soru_hatasi(jsonb_build_object(
    'okul', p ->> 'okul', 'ders', p ->> 'ders', 'konu', p ->> 'konu',
    'soru_metni', p ->> 'soru_metni', 'zorluk', p ->> 'zorluk',
    'siklar', p -> 'siklar', 'dogru_sik', p ->> 'dogru_sik', 'onay_durumu', 'beklemede'));
  if v_hata is not null then return v_hata; end if;

  if jsonb_typeof(p -> 'cozum_adimlari') is distinct from 'array'
     or jsonb_array_length(p -> 'cozum_adimlari') < 1 then
    return 'çözüm adımları en az bir adım içermeli';
  end if;

  if p ->> 'kalite_durumu' = 'kirmizi' then
    return 'kalite kırmızı; içe aktarılamaz';
  end if;

  if p ->> 'kaynak_turu' = 'birebir' then
    select e into v_kaynak
      from jsonb_array_elements(coalesce(p_kaynaklar, '[]'::jsonb)) as e
     where e ->> 'kaynak_id' = p ->> 'kaynak_id'
     limit 1;
    if v_kaynak is null then
      return 'birebir soru için paketinde kaynak kaydı yok';
    end if;
    if nullif(trim(coalesce(v_kaynak ->> 'lisans_dayanagi', '')), '') is null then
      return 'birebir aktarım için kaynağın lisans dayanağı boş';
    end if;
  end if;

  if p ? 'insan_onayi' and jsonb_typeof(p -> 'insan_onayi') = 'object' then
    begin
      perform (p #>> '{insan_onayi,ne_zaman}')::timestamptz;
    exception when others then
      return 'insan_onayi.ne_zaman geçersiz tarih';
    end;
  end if;

  return null;
end;
$$;

revoke execute on function public._soru_paket_hatasi(jsonb, jsonb) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 4. Paket içe aktarma (admin)
--   p_onayla = true ise yalnızca insan onayı (onay/duzeltildi) taşıyan sorular
--   'onaylandi' olur; diğerleri 'beklemede' girer. Yeni içerik varsayılan olarak beklemededir.
-- ---------------------------------------------------------------------
create or replace function public.admin_import_questions_v2(
  p_paket jsonb,
  p_onayla boolean default false,
  p_hepsi_veya_hicbiri boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_parti     text;
  v_sorular   jsonb;
  v_kaynaklar jsonb;
  v_row       jsonb;
  v_i         integer := 0;
  v_hata      text;
  v_hatalar   jsonb := '[]'::jsonb;
  v_eklenen   integer := 0;
  v_tekrar    integer := 0;
  v_durum     text;
  v_kaynak    jsonb;
begin
  perform public.require_admin();

  if jsonb_typeof(p_paket) is distinct from 'object' or (p_paket ->> 'surum') is distinct from '1' then
    raise exception 'Paket sürümü 1 olmalı' using errcode = '22023';
  end if;

  v_parti := nullif(trim(coalesce(p_paket #>> '{parti,parti_id}', '')), '');
  if v_parti is null or v_parti !~ '^[a-z0-9][a-z0-9-]{5,63}$' then
    raise exception 'Geçersiz parti_id' using errcode = '22023';
  end if;
  if exists (select 1 from public.soru_importlari where parti_id = v_parti) then
    raise exception 'Bu parti zaten içe aktarılmış: %', v_parti using errcode = '23505';
  end if;

  v_sorular := coalesce(p_paket -> 'sorular', '[]'::jsonb);
  if jsonb_typeof(v_sorular) is distinct from 'array' then
    raise exception 'sorular liste olmalı' using errcode = '22023';
  end if;
  if jsonb_array_length(v_sorular) > 1000 then
    raise exception 'Tek seferde en fazla 1000 soru' using errcode = '22023';
  end if;
  v_kaynaklar := coalesce(p_paket -> 'kaynaklar', '[]'::jsonb);

  -- Doğrulama: her satır için hata (sıra numarasıyla)
  for v_row in select * from jsonb_array_elements(v_sorular) loop
    v_i := v_i + 1;
    v_hata := public._soru_paket_hatasi(v_row, v_kaynaklar);
    if v_hata is not null then
      v_hatalar := v_hatalar || jsonb_build_array(jsonb_build_object('satir', v_i, 'soru_id', v_row ->> 'soru_id', 'hata', v_hata));
    end if;
  end loop;

  if p_hepsi_veya_hicbiri and jsonb_array_length(v_hatalar) > 0 then
    return jsonb_build_object('parti_id', v_parti, 'eklenen', 0, 'tekrar', 0,
                              'hatali', jsonb_array_length(v_hatalar), 'hatalar', v_hatalar);
  end if;

  -- Kaynak kayıtları (varsa, mevcut olanı değiştirmez)
  for v_kaynak in select * from jsonb_array_elements(v_kaynaklar) loop
    insert into public.soru_kaynaklari
      (kaynak_id, baslik, yayinci, yil, url, sha256, sinif, ders, lisans_durumu, lisans_dayanagi, indirme_tarihi)
    values
      (v_kaynak ->> 'kaynak_id', v_kaynak ->> 'baslik', v_kaynak ->> 'yayinci',
       nullif(v_kaynak ->> 'yil', '')::int, v_kaynak ->> 'url', v_kaynak ->> 'sha256',
       nullif(v_kaynak ->> 'sinif', '')::smallint, v_kaynak ->> 'ders',
       v_kaynak ->> 'lisans_durumu', v_kaynak ->> 'lisans_dayanagi',
       nullif(v_kaynak ->> 'indirme_tarihi', '')::date)
    on conflict (kaynak_id) do nothing;
  end loop;

  -- Yazma: hatalı satırlar atlanır, tekrarlar atlanır
  for v_row in select * from jsonb_array_elements(v_sorular) loop
    if public._soru_paket_hatasi(v_row, v_kaynaklar) is not null then
      continue;
    end if;

    if exists (select 1 from public.questions q where q.dis_soru_id = (v_row ->> 'soru_id'))
       or exists (
         select 1 from public.questions q
          where q.ders = trim(v_row ->> 'ders') and q.konu = trim(v_row ->> 'konu')
            and q.sinif = (v_row ->> 'sinif')::smallint
            and public.tr_normalize(q.soru_metni) = public.tr_normalize(trim(v_row ->> 'soru_metni'))
       ) then
      v_tekrar := v_tekrar + 1;
      continue;
    end if;

    v_durum := case
      when p_onayla and (v_row #>> '{insan_onayi,karar}') in ('onay', 'duzeltildi') then 'onaylandi'
      else 'beklemede' end;

    insert into public.questions
      (okul, sinif, ders, konu, alt_konu, zorluk, soru_metni, siklar, dogru_sik,
       cozum_adimlari, onay_durumu, created_by,
       dis_soru_id, ipuclari, kisa_aciklama, yanlis_sik_geri_bildirimi,
       kazanim_kodu, kazanim_metni, unite, beceri, bilissel_duzey, zorluk_gerekcesi, tahmini_sure_sn,
       kaynak_id, kaynak_sayfa, kaynak_turu, uretim_yontemi, ebeveyn_dis_id,
       uretim_partisi, prompt_surumu, model, kalite_durumu, gorsel_gerekli,
       insan_onayi_kim, insan_onayi_zaman, insan_onayi_karar)
    values
      (trim(v_row ->> 'okul'), (v_row ->> 'sinif')::smallint, trim(v_row ->> 'ders'), trim(v_row ->> 'konu'),
       nullif(trim(coalesce(v_row ->> 'alt_konu', '')), ''),
       (v_row ->> 'zorluk')::smallint, trim(v_row ->> 'soru_metni'),
       v_row -> 'siklar', upper(v_row ->> 'dogru_sik'),
       coalesce(v_row -> 'cozum_adimlari', '[]'::jsonb), v_durum, (select auth.uid()),
       v_row ->> 'soru_id', coalesce(v_row -> 'ipuclari', '[]'::jsonb), nullif(v_row ->> 'kisa_aciklama', ''),
       v_row -> 'yanlis_sik_geri_bildirimi',
       nullif(v_row ->> 'kazanim_kodu', ''), nullif(v_row ->> 'kazanim_metni', ''), nullif(v_row ->> 'unite', ''),
       nullif(v_row ->> 'beceri', ''), nullif(v_row ->> 'bilissel_duzey', ''), nullif(v_row ->> 'zorluk_gerekcesi', ''),
       nullif(v_row ->> 'tahmini_sure_sn', '')::smallint,
       nullif(v_row ->> 'kaynak_id', ''), nullif(v_row ->> 'kaynak_sayfa', '')::int,
       nullif(v_row ->> 'kaynak_turu', ''), nullif(v_row ->> 'uretim_yontemi', ''), nullif(v_row ->> 'ebeveyn_soru_id', ''),
       v_parti, nullif(v_row ->> 'prompt_surumu', ''), nullif(v_row ->> 'model', ''),
       nullif(v_row ->> 'kalite_durumu', ''), coalesce((v_row ->> 'gorsel_gerekli')::boolean, false),
       v_row #>> '{insan_onayi,kim}', nullif(v_row #>> '{insan_onayi,ne_zaman}', '')::timestamptz,
       v_row #>> '{insan_onayi,karar}');
    v_eklenen := v_eklenen + 1;
  end loop;

  insert into public.soru_importlari (parti_id, olusturan, aciklama, istenen, eklenen, tekrar, hatali, onayli)
  values (v_parti, (select auth.uid()), nullif(p_paket #>> '{parti,aciklama}', ''),
          jsonb_array_length(v_sorular), v_eklenen, v_tekrar, jsonb_array_length(v_hatalar), p_onayla);

  perform public.log_admin_action('soru_paketi_ice_aktarildi', jsonb_build_object(
    'parti_id', v_parti, 'eklenen', v_eklenen, 'tekrar', v_tekrar,
    'hatali', jsonb_array_length(v_hatalar), 'onayli', p_onayla));

  return jsonb_build_object('parti_id', v_parti, 'eklenen', v_eklenen, 'tekrar', v_tekrar,
                            'hatali', jsonb_array_length(v_hatalar), 'hatalar', v_hatalar);
end;
$function$;

comment on function public.admin_import_questions_v2(jsonb, boolean, boolean) is
  'Soru Atölyesi JSON paketini içe aktarır. Sınıf zorunlu; birebir soru lisans dayanağı ister; kırmızı kalite reddedilir.';

revoke execute on function public.admin_import_questions_v2(jsonb, boolean, boolean) from public, anon;
grant  execute on function public.admin_import_questions_v2(jsonb, boolean, boolean) to authenticated;

-- ---------------------------------------------------------------------
-- 5. Parti geri alma (silmez; onay_durumu = reddedildi)
-- ---------------------------------------------------------------------
create or replace function public.admin_geri_al_parti(p_parti_id text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_adet integer;
begin
  perform public.require_admin();

  update public.questions
     set onay_durumu = 'reddedildi'
   where uretim_partisi = p_parti_id
     and onay_durumu <> 'reddedildi';
  get diagnostics v_adet = row_count;

  update public.soru_importlari
     set durum = 'geri_alindi', geri_alindi_zaman = now()
   where parti_id = p_parti_id;

  perform public.log_admin_action('soru_paketi_geri_alindi',
    jsonb_build_object('parti_id', p_parti_id, 'geri_alinan', v_adet));

  return jsonb_build_object('parti_id', p_parti_id, 'geri_alinan', v_adet);
end;
$function$;

comment on function public.admin_geri_al_parti(text) is
  'Bir içe aktarma partisini geri alır: sorular silinmez, reddedildi olur.';

revoke execute on function public.admin_geri_al_parti(text) from public, anon;
grant  execute on function public.admin_geri_al_parti(text) to authenticated;
