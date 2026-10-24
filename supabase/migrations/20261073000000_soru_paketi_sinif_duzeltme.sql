-- =====================================================================
-- Soru paketi doğrulayıcısı: sınıf alanını mevcut doğrulayıcıya geçir.
--   * Canlı public._soru_hatasi "sınıf zorunlu ve 1-12" kuralını uygular.
--   * 20261047 sarmalayıcısı bu alanı geçirmediği için her satır reddediliyordu.
--   * Yalnızca bu fonksiyon değişir; tablo/veri değişmez.
-- =====================================================================

create or replace function public._soru_paket_hatasi(p jsonb, p_kaynaklar jsonb)
returns text
language plpgsql
stable
set search_path = ''
as $function$
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

  -- Ortak alan kuralları; sınıf da geçirilir (canlı _soru_hatasi sınıf ister)
  v_hata := public._soru_hatasi(jsonb_build_object(
    'okul', p ->> 'okul', 'ders', p ->> 'ders', 'konu', p ->> 'konu',
    'soru_metni', p ->> 'soru_metni', 'zorluk', p ->> 'zorluk',
    'siklar', p -> 'siklar', 'dogru_sik', p ->> 'dogru_sik', 'onay_durumu', 'beklemede',
    'sinif', p ->> 'sinif'));
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
$function$;
