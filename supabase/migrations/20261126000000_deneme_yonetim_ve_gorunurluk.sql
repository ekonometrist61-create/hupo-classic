-- =====================================================================
--  Deneme sınırları: varsayılan değer düzeltmesi, yönetici okuma, görünürlük
--  Tarih : 2026-10-29
--
--  1) Varsayılan sınırlar: Kelime Evreni ve çarpım şifreleri 20 (proje sahibi kararı).
--     20261125 bu değerleri 30 / 40 yazmıştı; bu migration yalnız o iki sınırı günceller.
--  2) admin_get_deneme_sinirlari(): yönetici ekranı için okuma (yazma admin_set_deneme_sinirlari).
--  3) deneme_hak_durumu(p_ogrenci): çocuk kendi, veli kendi çocuğunun durumunu görür.
--     Kullanılan sayısı ve kalan hak, deneme_sinir_tetik ile aynı pencere mantığıyla hesaplanır.
--
--  Not: Uzak veritabanına yalnızca proje sahibinin onayıyla uygulanır.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Varsayılan düzeltmesi
-- ---------------------------------------------------------------------
update public.app_settings
   set value = jsonb_set(
                 jsonb_set(value, '{varsayilan,kelime_evreni,sinir}', '20'::jsonb),
                 '{varsayilan,carpim_sifresi,sinir}', '20'::jsonb),
       updated_at = now()
 where key = 'deneme_sinirlari';

-- ---------------------------------------------------------------------
-- 2. Yönetici okuma
-- ---------------------------------------------------------------------
create or replace function public.admin_get_deneme_sinirlari()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.require_admin();
  return coalesce((select s.value from public.app_settings s where s.key = 'deneme_sinirlari'), '{}'::jsonb);
end;
$$;

revoke execute on function public.admin_get_deneme_sinirlari() from public, anon;
grant  execute on function public.admin_get_deneme_sinirlari() to authenticated;

-- ---------------------------------------------------------------------
-- 3. Özellik kullanımı (deneme_sinir_tetik ile aynı pencere)
-- ---------------------------------------------------------------------
create or replace function public._deneme_ozellik_sayisi(p_ogrenci uuid, p_ozellik text, p_pencere text)
returns bigint
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_bas  timestamptz;
  v_bit  timestamptz := 'infinity'::timestamptz;
  v_sayi bigint := 0;
begin
  if p_pencere = 'deneme' then
    select max(d.baslangic) into v_bas
      from public.deneme_donemleri d
     where d.veli_id = public._deneme_sahibi(p_ogrenci) and d.bitis > now();
  else
    v_bas := ((now() at time zone 'Europe/Istanbul')::date)::timestamp at time zone 'Europe/Istanbul';
    v_bit := v_bas + interval '1 day';
  end if;
  if v_bas is null then
    return 0;
  end if;

  if p_ozellik = 'soru' then
    select count(*) into v_sayi from public.answer_events
     where student_id = p_ogrenci and created_at >= v_bas and created_at < v_bit;
  elsif p_ozellik = 'kelime_evreni' then
    select count(*) into v_sayi from public.kelime_denemeleri
     where ogrenci_id = p_ogrenci and created_at >= v_bas and created_at < v_bit;
  elsif p_ozellik = 'carpim_sifresi' then
    select count(*) into v_sayi from public.carpim_deneme_log
     where user_id = p_ogrenci and created_at >= v_bas and created_at < v_bit;
  elsif p_ozellik = 'okuma_hikayesi' then
    select count(*) into v_sayi from public.okuma_oturumlari
     where ogrenci_id = p_ogrenci and baslangic_at >= v_bas and baslangic_at < v_bit;
  elsif p_ozellik = 'meydan_okuma' then
    select count(*) into v_sayi from public.meydan_okumalar
     where davet_eden = p_ogrenci and olusturulma >= v_bas and olusturulma < v_bit;
  elsif p_ozellik = 'deneme_sinavi' then
    select count(*) into v_sayi from public.deneme_sinavi_katilimlari
     where student_id = p_ogrenci and kayit_zamani >= v_bas and kayit_zamani < v_bit;
  end if;
  return v_sayi;
end;
$$;

revoke execute on function public._deneme_ozellik_sayisi(uuid, text, text) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 4. Görünürlük: çocuğun (veya velinin kendi hanesinin) deneme ve sınır durumu
-- ---------------------------------------------------------------------
create or replace function public.deneme_hak_durumu(p_ogrenci uuid default null)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := (select auth.uid());
  v_ogr     uuid := coalesce(p_ogrenci, v_uid);
  v_bitis   timestamptz;
  v_son     timestamptz;
  v_premium boolean;
  v_ozellik text;
  v_sinir   jsonb;
  v_limit   integer;
  v_pencere text;
  v_kullan  bigint;
  v_satir   jsonb := '[]'::jsonb;
  v_liste   text[] := array['soru', 'kelime_evreni', 'carpim_sifresi', 'okuma_hikayesi', 'meydan_okuma', 'deneme_sinavi'];
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  if v_ogr is distinct from v_uid
     and not exists (select 1 from public.profiles c where c.id = v_ogr and c.parent_id = v_uid) then
    raise exception 'Bu öğrenci için yetkiniz yok' using errcode = '42501';
  end if;

  v_premium := public.is_premium(v_ogr);
  select max(d.bitis) into v_bitis
    from public.deneme_donemleri d
   where d.veli_id = public._deneme_sahibi(v_ogr) and d.bitis > now();

  if v_premium or v_bitis is null then
    -- Deneme bitmişse son bitiş tarihi (veli "deneme bitti" bilgisini bununla gösterir).
    select max(d.bitis) into v_son
      from public.deneme_donemleri d
     where d.veli_id = public._deneme_sahibi(v_ogr);
    return jsonb_build_object('deneme', false, 'premium', v_premium, 'bitis', null,
                              'son_bitis', v_son, 'kalan_gun', null, 'ozellikler', '[]'::jsonb);
  end if;

  foreach v_ozellik in array v_liste loop
    v_sinir := public._deneme_sinir(v_ogr, v_ozellik);
    if v_sinir is null then
      -- Soru için ayar yoksa deneme.gunluk_soru geçerlidir.
      if v_ozellik <> 'soru' then
        continue;
      end if;
      v_limit   := (select a.gunluk_soru from public._deneme_ayar() a);
      v_pencere := 'gunluk';
    else
      v_limit   := (v_sinir ->> 'sinir')::integer;
      v_pencere := coalesce(v_sinir ->> 'pencere', 'gunluk');
    end if;

    v_kullan := public._deneme_ozellik_sayisi(v_ogr, v_ozellik, v_pencere);
    v_satir := v_satir || jsonb_build_array(jsonb_build_object(
      'ozellik', v_ozellik,
      'sinir', v_limit,
      'pencere', v_pencere,
      'kullanilan', v_kullan,
      'kalan', greatest(v_limit - v_kullan, 0)));
  end loop;

  return jsonb_build_object(
    'deneme', true,
    'premium', false,
    'bitis', v_bitis,
    'kalan_gun', greatest(ceil(extract(epoch from (v_bitis - now())) / 86400.0)::integer, 0),
    'ozellikler', v_satir);
end;
$$;

revoke execute on function public.deneme_hak_durumu(uuid) from public, anon;
grant  execute on function public.deneme_hak_durumu(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- 5. Sınır mesajları: deneme_sinir_tetik yeniden tanımlanır (20261125 sürümünün
--    yalnız mesaj metni değişti; tetikleyiciler aynı fonksiyonu çağırır).
-- ---------------------------------------------------------------------
create or replace function public.deneme_sinir_tetik()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_ogrenci uuid := (to_jsonb(new) ->> TG_ARGV[0])::uuid;
  v_zaman   text := TG_ARGV[1];
  v_ozellik text := TG_ARGV[2];
  v_etiket  text := TG_ARGV[3];
  v_sinir   jsonb;
  v_pencere text;
  v_limit   integer;
  v_bas     timestamptz;
  v_bit     timestamptz := 'infinity'::timestamptz;
  v_sayi    bigint;
begin
  -- Yalnız oturumlu (istemci) yazımları; servis ve sunucu yazımları etkilenmez.
  if (select auth.uid()) is null or v_ogrenci is null then
    return new;
  end if;
  if public.is_premium(v_ogrenci) or not public._deneme_aktif(v_ogrenci) then
    return new;
  end if;

  v_sinir := public._deneme_sinir(v_ogrenci, v_ozellik);
  if v_sinir is null then
    return new;
  end if;
  v_limit   := (v_sinir ->> 'sinir')::integer;
  v_pencere := coalesce(v_sinir ->> 'pencere', 'gunluk');

  if v_pencere = 'deneme' then
    select max(d.baslangic) into v_bas
      from public.deneme_donemleri d
     where d.veli_id = public._deneme_sahibi(v_ogrenci) and d.bitis > now();
  else
    v_bas := ((now() at time zone 'Europe/Istanbul')::date)::timestamp at time zone 'Europe/Istanbul';
    v_bit := v_bas + interval '1 day';
  end if;

  -- AFTER INSERT: sayım yeni satırı içerir; idempotent (ON CONFLICT) tekrarlar insert
  -- tetikleyicisini ateşlemez, bu yüzden tekrar gönderim sınıra takılmaz.
  execute format(
    'select count(*) from public.%I where %I = $1 and %I >= $2 and %I < $3',
    TG_TABLE_NAME, TG_ARGV[0], v_zaman, v_zaman)
    into v_sayi using v_ogrenci, v_bas, v_bit;

  if v_sayi > v_limit then
    raise exception '%', case when v_pencere = 'deneme'
        then format('Bu denemedeki %s hakkın doldu.', v_etiket)
        else format('Bugünlük %s hakkın doldu. Yarın yeniden açılır.', v_etiket) end
      using errcode = 'P0402';
  end if;
  return new;
end;
$$;

revoke execute on function public.deneme_sinir_tetik() from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 6. Premium gating açık (mar-oto-ai kararı, proje sahibi onayı):
--    Deneme bitince ücretsiz hesap günlük 20 soru ile sınırlanır. Deneme dalı
--    bu ayardan bağımsızdır (remaining_free_questions deneme önceliklidir).
-- ---------------------------------------------------------------------
insert into public.app_settings (key, value)
values ('premium_gating', '{"aktif": true, "ucretsiz_gunluk_soru": 20}'::jsonb)
on conflict (key) do update set value = excluded.value, updated_at = now();
