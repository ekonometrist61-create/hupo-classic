-- =====================================================================
-- Görselli soru paketi içe aktarma (v3) — 2026-11-08
--   * Girdi: tools/gorsel-motoru çıktısı, paket biçimi surum "2" (paket-v2 sorular.json dizileri).
--   * Her satır, mevcut içe aktarıcının (admin_import_questions_v2, surum "1") biçimine çevrilir;
--     doğrulama ve tekrar kontrolü onda yapılır. Gorsel alanları (svg, alt metin, tip, spec)
--     yeni eklenen satırlara bu RPC'de yazılır.
--   * Yeni içerik HER ZAMAN 'beklemede' girer. Onay p_onayla ile değil, ayrı bir yayın kararıyla verilir.
--   * dis_soru_id = 'gorsel-' || kazanım kodu || '-' || paket soru kimliği. Paket kimlikleri
--     kazanımlar arasında çakışıyor (örn. MAT5-GEO-S1-001 üç pakette), bu yüzden kazanım kodu eklenir.
--   * gorsel_spec yalnız admin RPC ve service_role ile okunur (istemci yetkisi yok, 20261128).
-- Uygulama: 'supabase db query --linked -f' ile tek dosya olarak (idempotent; db push kullanılmaz).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Görselli satırı içe aktarıcının v1 biçimine çevirir
-- ---------------------------------------------------------------------
create or replace function public._gorsel_satir_v1(p jsonb)
returns jsonb
language sql
immutable
set search_path = ''
as $$
  select jsonb_build_object(
    'soru_id', 'gorsel-' || replace(lower(p ->> 'kazanim_kodu'), '.', '-') || '-' || lower(p ->> 'id'),
    'okul', case when (p ->> 'sinif')::int <= 4 then 'ilkokul' else 'ortaokul' end,
    'sinif', (p ->> 'sinif')::int,
    'ders', p ->> 'ders',
    'konu', p ->> 'konu',
    'alt_konu', p ->> 'alt_konu',
    'zorluk', (p ->> 'zorluk')::int,
    'soru_metni', p ->> 'soru_metni',
    'siklar', p -> 'siklar',
    'dogru_sik', p ->> 'dogru_sik',
    'cozum_adimlari', coalesce(p -> 'cozum_adimlari', '[]'::jsonb),
    'ipuclari', case when nullif(trim(coalesce(p ->> 'ipucu', '')), '') is null
                     then '[]'::jsonb else jsonb_build_array(p ->> 'ipucu') end,
    'yanlis_sik_geri_bildirimi', p -> 'celdirici_gerekce',
    'kazanim_kodu', p ->> 'kazanim_kodu',
    'kaynak_turu', 'uretilen',
    'uretim_yontemi', 'sablon',
    'gorsel_gerekli', true
  );
$$;

revoke execute on function public._gorsel_satir_v1(jsonb) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. Görselli paket içe aktarma (admin)
-- ---------------------------------------------------------------------
create or replace function public.admin_import_gorsel_paketi(
  p_paket jsonb,
  p_hepsi_veya_hicbiri boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_parti      text;
  v_sorular    jsonb;
  v_satir      jsonb;
  v_v1         jsonb;
  v_v1_liste   jsonb := '[]'::jsonb;
  v_gorsel     jsonb := '[]'::jsonb;
  v_hatali     jsonb := '[]'::jsonb;
  v_hata       text;
  v_i          integer := 0;
  v_sonuc      jsonb;
  v_guncellenen integer;
begin
  perform public.require_admin();

  if jsonb_typeof(p_paket) is distinct from 'object' or (p_paket ->> 'surum') is distinct from '2' then
    raise exception 'Görselli paket sürümü 2 olmalı' using errcode = '22023';
  end if;

  v_parti := nullif(trim(coalesce(p_paket #>> '{parti,parti_id}', '')), '');
  if v_parti is null or v_parti !~ '^[a-z0-9][a-z0-9-]{5,63}$' then
    raise exception 'Geçersiz parti_id' using errcode = '22023';
  end if;

  v_sorular := coalesce(p_paket -> 'sorular', '[]'::jsonb);
  if jsonb_typeof(v_sorular) is distinct from 'array' then
    raise exception 'sorular liste olmalı' using errcode = '22023';
  end if;
  if jsonb_array_length(v_sorular) > 1000 then
    raise exception 'Tek seferde en fazla 1000 soru' using errcode = '22023';
  end if;

  -- Görsel kuralları (v1 doğrulamasından önce): svg dolu ve 30 KB altında, alt metin ve tip dolu.
  for v_satir in select * from jsonb_array_elements(v_sorular) loop
    v_i := v_i + 1;
    v_hata := case
      when nullif(trim(coalesce(v_satir #>> '{gorsel,svg}', '')), '') is null then 'gorsel.svg boş'
      when octet_length(v_satir #>> '{gorsel,svg}') > 30000 then 'gorsel.svg 30 KB sınırını aşıyor'
      when nullif(trim(coalesce(v_satir #>> '{gorsel,alt_metin}', '')), '') is null then 'gorsel.alt_metin boş'
      when nullif(trim(coalesce(v_satir #>> '{gorsel,tip_id}', '')), '') is null then 'gorsel.tip_id boş'
      when nullif(trim(coalesce(v_satir ->> 'kazanim_kodu', '')), '') is null then 'kazanim_kodu boş'
      else null end;

    if v_hata is not null then
      v_hatali := v_hatali || jsonb_build_array(jsonb_build_object(
        'satir', v_i, 'soru_id', v_satir ->> 'id', 'hata', v_hata));
      continue;
    end if;

    v_v1 := public._gorsel_satir_v1(v_satir);
    v_v1_liste := v_v1_liste || jsonb_build_array(v_v1);
    v_gorsel := v_gorsel || jsonb_build_array(jsonb_build_object(
      'dis', v_v1 ->> 'soru_id',
      'svg', v_satir #>> '{gorsel,svg}',
      'alt', v_satir #>> '{gorsel,alt_metin}',
      'tip', v_satir #>> '{gorsel,tip_id}',
      'spec', v_satir -> 'gorsel_spec'));
  end loop;

  if p_hepsi_veya_hicbiri and jsonb_array_length(v_hatali) > 0 then
    return jsonb_build_object('parti_id', v_parti, 'eklenen', 0, 'tekrar', 0,
                              'hatali', jsonb_array_length(v_hatali), 'hatalar', v_hatali,
                              'gorsel_guncellenen', 0);
  end if;

  -- Mevcut içe aktarıcıya devret: doğrulama, tekrar kontrolü ve parti kaydı orada yapılır.
  v_sonuc := public.admin_import_questions_v2(
    jsonb_build_object(
      'surum', '1',
      'parti', jsonb_build_object('parti_id', v_parti, 'aciklama', p_paket #>> '{parti,aciklama}'),
      'sorular', v_v1_liste),
    false,
    p_hepsi_veya_hicbiri);

  if p_hepsi_veya_hicbiri and jsonb_array_length(coalesce(v_sonuc -> 'hatalar', '[]'::jsonb)) > 0 then
    return v_sonuc;
  end if;

  -- Yalnız bu partide yeni eklenen satırlara görsel alanlarını yaz.
  update public.questions q
     set gorsel_svg = g ->> 'svg',
         gorsel_alt_metin = g ->> 'alt',
         gorsel_tip = g ->> 'tip',
         gorsel_spec = g -> 'spec'
    from jsonb_array_elements(v_gorsel) as g
   where q.dis_soru_id = g ->> 'dis'
     and q.uretim_partisi = v_parti;
  get diagnostics v_guncellenen = row_count;

  v_hatali := v_hatali || coalesce(v_sonuc -> 'hatalar', '[]'::jsonb);

  perform public.log_admin_action('gorselli_paket_ice_aktarildi', jsonb_build_object(
    'parti_id', v_parti, 'eklenen', v_sonuc -> 'eklenen', 'tekrar', v_sonuc -> 'tekrar',
    'hatali', jsonb_array_length(v_hatali), 'gorsel_guncellenen', v_guncellenen));

  return jsonb_build_object('parti_id', v_parti,
                            'eklenen', v_sonuc -> 'eklenen',
                            'tekrar', v_sonuc -> 'tekrar',
                            'hatali', jsonb_array_length(v_hatali),
                            'hatalar', v_hatali,
                            'gorsel_guncellenen', v_guncellenen);
end;
$function$;

comment on function public.admin_import_gorsel_paketi(jsonb, boolean) is
  'Görselli soru paketi (surum 2) içe aktarır. Yeni içerik beklemededir; gorsel alanları yalnız yeni satırlara yazılır.';

revoke execute on function public.admin_import_gorsel_paketi(jsonb, boolean) from public, anon;
grant  execute on function public.admin_import_gorsel_paketi(jsonb, boolean) to authenticated;
