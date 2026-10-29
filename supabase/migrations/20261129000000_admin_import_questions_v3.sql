-- =====================================================================
-- Görselli soru paketi içe aktarma (v3). v2 değişmez; v3 onun üstüne kurulur.
--   * Paket sürümü "1" (eski) ve "2" (görselli) kabul edilir.
--   * Görselli soru isteğe bağlı "gorsel": {svg, alt_metin, tip_id} ve "gorsel_spec" taşır.
--   * gorsel_gerekli = true ise SVG ve alt metin zorunlu. SVG yalnızca <svg> ile başlayabilir;
--     script, foreignObject, iframe ve olay öznitelikleri reddedilir.
--   * gorsel_spec yalnız admin RPC ve service_role ile okunur (istemci yetkisi yok, 20261128).
--   * Yazma yalnızca bu RPC ile yapılır; geri alma v2 ile aynı (admin_geri_al_parti).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. SVG güvenlik ve biçim kontrolü
-- ---------------------------------------------------------------------
create or replace function public._gorsel_svg_hatasi(p_svg text)
returns text
language plpgsql
immutable
set search_path = ''
as $$
begin
  if p_svg is null or length(trim(p_svg)) = 0 then
    return 'görsel SVG boş';
  end if;
  if octet_length(p_svg) > 30000 then
    return 'görsel SVG 30 KB sınırını aşıyor';
  end if;
  if p_svg !~* '^\s*(<\?xml[^>]*>\s*)?<svg[\s>]' then
    return 'görsel SVG <svg> etiketiyle başlamalı';
  end if;
  if p_svg ~* '<script|<foreignobject|<iframe|<object|<embed|javascript:|\son[a-z]+\s*=' then
    return 'görsel SVG güvenli değil (script, iframe ya da olay öznitelikleri yasak)';
  end if;
  return null;
end;
$$;

revoke execute on function public._gorsel_svg_hatasi(text) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. Görsel alanları doğrulaması (satır için)
-- ---------------------------------------------------------------------
create or replace function public._gorsel_paket_hatasi(p jsonb)
returns text
language plpgsql
stable
set search_path = ''
as $$
declare
  v_hata text;
begin
  if p ->> 'gorsel_gerekli' = 'true' and (p -> 'gorsel') is null then
    return 'gorsel_gerekli işaretli ama görsel alanı yok';
  end if;

  if p ? 'gorsel' and p -> 'gorsel' is not null then
    if jsonb_typeof(p -> 'gorsel') is distinct from 'object' then
      return 'gorsel nesne olmalı';
    end if;

    v_hata := public._gorsel_svg_hatasi(p #>> '{gorsel,svg}');
    if v_hata is not null then return v_hata; end if;

    if nullif(trim(coalesce(p #>> '{gorsel,alt_metin}', '')), '') is null then
      return 'görsel alt metni zorunlu (erişilebilirlik)';
    end if;

    if nullif(trim(coalesce(p #>> '{gorsel,tip_id}', '')), '') is null then
      return 'görsel tip_id zorunlu';
    end if;
  end if;

  if p ? 'gorsel_spec' and p -> 'gorsel_spec' is not null
     and jsonb_typeof(p -> 'gorsel_spec') is distinct from 'object' then
    return 'gorsel_spec nesne olmalı';
  end if;

  return null;
end;
$$;

revoke execute on function public._gorsel_paket_hatasi(jsonb) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 3. Paket içe aktarma (admin, sürüm 1 ve 2)
--   p_onayla = true ise yalnızca insan onayı (onay/duzeltildi) taşıyan sorular
--   'onaylandi' olur; diğerleri 'beklemede' girer. Yeni içerik varsayılan olarak beklemededir.
-- ---------------------------------------------------------------------
create or replace function public.admin_import_questions_v3(
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
  v_gorselli  integer := 0;
  v_tekrar    integer := 0;
  v_durum     text;
  v_kaynak    jsonb;
begin
  perform public.require_admin();

  if jsonb_typeof(p_paket) is distinct from 'object'
     or coalesce(p_paket ->> 'surum', '') not in ('1', '2') then
    raise exception 'Paket sürümü 1 veya 2 olmalı' using errcode = '22023';
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
    v_hata := coalesce(public._soru_paket_hatasi(v_row, v_kaynaklar), public._gorsel_paket_hatasi(v_row));
    if v_hata is not null then
      v_hatalar := v_hatalar || jsonb_build_array(jsonb_build_object('satir', v_i, 'soru_id', v_row ->> 'soru_id', 'hata', v_hata));
    end if;
  end loop;

  if p_hepsi_veya_hicbiri and jsonb_array_length(v_hatalar) > 0 then
    return jsonb_build_object('parti_id', v_parti, 'eklenen', 0, 'tekrar', 0, 'gorselli', 0,
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
    if coalesce(public._soru_paket_hatasi(v_row, v_kaynaklar), public._gorsel_paket_hatasi(v_row)) is not null then
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
       insan_onayi_kim, insan_onayi_zaman, insan_onayi_karar,
       gorsel_svg, gorsel_alt_metin, gorsel_tip, gorsel_spec)
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
       v_row #>> '{insan_onayi,karar}',
       nullif(v_row #>> '{gorsel,svg}', ''), nullif(trim(v_row #>> '{gorsel,alt_metin}'), ''),
       nullif(trim(v_row #>> '{gorsel,tip_id}'), ''), v_row -> 'gorsel_spec');

    v_eklenen := v_eklenen + 1;
    if v_row ? 'gorsel' and v_row -> 'gorsel' is not null then
      v_gorselli := v_gorselli + 1;
    end if;
  end loop;

  insert into public.soru_importlari (parti_id, olusturan, aciklama, istenen, eklenen, tekrar, hatali, onayli)
  values (v_parti, (select auth.uid()), nullif(p_paket #>> '{parti,aciklama}', ''),
          jsonb_array_length(v_sorular), v_eklenen, v_tekrar, jsonb_array_length(v_hatalar), p_onayla);

  perform public.log_admin_action('soru_paketi_ice_aktarildi', jsonb_build_object(
    'parti_id', v_parti, 'eklenen', v_eklenen, 'tekrar', v_tekrar, 'gorselli', v_gorselli,
    'hatali', jsonb_array_length(v_hatalar), 'onayli', p_onayla));

  return jsonb_build_object('parti_id', v_parti, 'eklenen', v_eklenen, 'tekrar', v_tekrar,
                            'gorselli', v_gorselli,
                            'hatali', jsonb_array_length(v_hatalar), 'hatalar', v_hatalar);
end;
$function$;

comment on function public.admin_import_questions_v3(jsonb, boolean, boolean) is
  'Soru paketi içe aktarma (sürüm 1 ve 2). Sürüm 2 görselli soruları taşır: SVG, alt metin, tip ve gorsel_spec (yalnız admin).';

revoke execute on function public.admin_import_questions_v3(jsonb, boolean, boolean) from public, anon;
grant  execute on function public.admin_import_questions_v3(jsonb, boolean, boolean) to authenticated;
