-- =====================================================================
--  MOBİL KOTA GÖSTERİMİ: bugünkü kullanım ve kalan hak (salt okuma)
--  Tarih : 2026-10-29
--  Önkoşul: 20261134 (ücretsiz taban kotaları), 20261125 (deneme sınırları, app_settings)
--
--  my_kota_durumu(): giriş yapan kullanıcının (çocuk) modül bazlı kota durumu.
--    Yalnız 'sinirli' erişimde ve günlük kotası olan modüller döner.
--    Sayım, sınır tetikleyicisiyle AYNI kuralı izler:
--      - deneme penceresi (premium değil, deneme aktif) → deneme_sinirlari (legacy) ve pencere
--      - aksi halde paket matrisinin gunluk_kota'sı, Istanbul günü
--    Değer: { modul: {erisim, gunluk_kota, kullanilan, kalan, pencere} }
--  Güvenlik: yalnız oturumlu kullanıcı; yalnız kendi sayımı. Veri değiştirmez.
-- =====================================================================

create or replace function public.my_kota_durumu()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := (select auth.uid());
  v_harita  jsonb := '{}'::jsonb;
  v_modul   text;
  v_erisim  jsonb;
  v_limit   integer;
  v_bas     timestamptz;
  v_bit     timestamptz := 'infinity'::timestamptz;
  v_pencere text := 'gunluk';
  v_ozellik text;
  v_sinir   jsonb;
  v_kullan  bigint := 0;
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;

  foreach v_modul in array array['soru_cevap', 'kelime_evreni', 'carpma', 'okuma', 'deneme'] loop
    v_ozellik := case v_modul
      when 'soru_cevap' then 'soru'
      when 'kelime_evreni' then 'kelime_evreni'
      when 'carpma' then 'carpim_sifresi'
      when 'okuma' then 'okuma_hikayesi'
      when 'deneme' then 'deneme_sinavi' end;

    -- Deneme penceresi (premium değil): legacy sınır ve pencere; erişim 'tam' olsa da geçerli
    -- (deneme paketi tam erişim verir ama sınırlar tetikleyicide legacy ile uygulanır).
    v_sinir := null;
    if not public.is_premium(v_uid) and public._deneme_aktif(v_uid) then
      v_sinir := public._deneme_sinir(v_uid, v_ozellik);
    end if;

    if v_sinir is not null then
      v_limit := (v_sinir ->> 'sinir')::integer;
      v_pencere := coalesce(v_sinir ->> 'pencere', 'gunluk');
    else
      v_erisim := public.has_access(v_uid, v_modul);
      if v_erisim ->> 'erisim' <> 'sinirli' or v_erisim ->> 'gunluk_kota' is null then
        continue;
      end if;
      v_limit := (v_erisim ->> 'gunluk_kota')::integer;
      v_pencere := 'gunluk';
    end if;

    v_bas := ((now() at time zone 'Europe/Istanbul')::date)::timestamp at time zone 'Europe/Istanbul';
    v_bit := v_bas + interval '1 day';
    if v_pencere = 'deneme' then
      select max(d.baslangic) into v_bas
        from public.deneme_donemleri d
       where d.veli_id = public._deneme_sahibi(v_uid) and d.bitis > now();
      v_bit := 'infinity'::timestamptz;
    end if;

    -- Kullanım sayımı: modül başına kendi tablosu (tetikleyicilerle aynı sütunlar)
    v_kullan := case v_modul
      when 'soru_cevap' then (select count(*) from public.answer_events e
                               where e.student_id = v_uid and e.created_at >= v_bas and e.created_at < v_bit)
      when 'kelime_evreni' then (select count(*) from public.kelime_denemeleri k
                               where k.ogrenci_id = v_uid and k.created_at >= v_bas and k.created_at < v_bit)
      when 'carpma' then (select count(*) from public.carpim_deneme_log c
                               where c.user_id = v_uid and c.created_at >= v_bas and c.created_at < v_bit)
      when 'okuma' then (select count(*) from public.okuma_oturumlari o
                               where o.ogrenci_id = v_uid and o.baslangic_at >= v_bas and o.baslangic_at < v_bit)
      when 'deneme' then (select count(*) from public.deneme_sinavi_katilimlari d
                               where d.student_id = v_uid and d.kayit_zamani >= v_bas and d.kayit_zamani < v_bit)
      else 0 end;

    v_harita := v_harita || jsonb_build_object(v_modul, jsonb_build_object(
      'erisim', 'sinirli',
      'gunluk_kota', v_limit,
      'kullanilan', v_kullan,
      'kalan', greatest(v_limit - v_kullan, 0),
      'pencere', v_pencere));
  end loop;

  return v_harita;
end;
$$;

revoke execute on function public.my_kota_durumu() from public, anon;
grant  execute on function public.my_kota_durumu() to authenticated;
