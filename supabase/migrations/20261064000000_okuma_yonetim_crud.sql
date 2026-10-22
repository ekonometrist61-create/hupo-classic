-- =====================================================================
-- Okuma Dünyası — yönetim CRUD tamamlayıcıları (uyum planı Faz A)
--   * okuma_surum_sil(p_surum_id)    : yalnız taslak/arşiv sürüm; yayında ve oturumlu sürüm reddedilir.
--   * okuma_hikaye_sil(p_hikaye_id)  : oturumu ve yayında sürümü olmayan hikâyeyi tüm sürümleriyle siler;
--                                      fiş bağlantısı (hikaye_slug) boşaltılır, fiş brief_draft olur.
--   * okuma_yonetim_istatistik()     : genel pano (yönetici verisi; min-N yok, öğrenci kimliği dönmez).
--
-- DÜZENLEME İÇİN YENİ RPC YOKTUR (bilinçli tasarım):
--   Sürüm içeriği değişmezdir (_okuma_surum_koru). Düzenleme = arayüz mevcut paketi
--   okuma_surum_icerik_getir ile alır, değiştirir ve okuma_paket_ice_aktar ile gönderir; içerik
--   farklıysa sha256 değişir ve YENİ TASLAK SÜRÜM (surum_no + 1) oluşur, aynıysa mükerrer olarak
--   yakalanır. Yayındaki sürüm bu sırada değişmez; yeni sürüm denetimden ve dört göz kapısından
--   geçip yayınlanınca öncekini arşive alır. Arşivleme: okuma_surum_durum_degistir(..., 'arsiv').
--
--   Tetikleyici değişikliği: _okuma_surum_koru artık arşivdeki sürümün silinmesine de izin verir
--   (önceden yalnız taslak). Güvence RPC katmanındadır: okuma_surum_sil / okuma_hikaye_sil
--   oturumu olan sürümü zaten reddeder (okuma_oturumlari.surum_id FK'si de engeller).
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Silme koruması: taslak ve arşiv silinebilir; yayında / incelemede silinemez
-- ---------------------------------------------------------------------
create or replace function public._okuma_surum_koru()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_degisebilir text[] := array['durum', 'denetim', 'inceleyen_id', 'yayin_at', 'arsiv_at'];
begin
  if tg_op = 'DELETE' then
    if old.durum not in ('taslak', 'arsiv') then
      raise exception 'SURUM_DEGISMEZ: yayında veya incelemedeki sürüm silinemez' using errcode = '55000';
    end if;
    return old;
  end if;

  if (to_jsonb(new) - v_degisebilir) is distinct from (to_jsonb(old) - v_degisebilir) then
    raise exception 'SURUM_DEGISMEZ: sürüm içeriği değiştirilemez; yeni sürüm olarak içe aktarın' using errcode = '55000';
  end if;

  if old.durum = 'yayinda' then
    -- Yayında sürümde yalnız arşive geçilebilir; denetim ve inceleyen sabit kalır.
    if new.durum not in ('yayinda', 'arsiv') then
      raise exception 'SURUM_DEGISMEZ: yayındaki sürüm yalnız arşive alınabilir' using errcode = '55000';
    end if;
    if new.denetim is distinct from old.denetim or new.inceleyen_id is distinct from old.inceleyen_id then
      raise exception 'SURUM_DEGISMEZ: yayındaki sürümün denetim kaydı değiştirilemez' using errcode = '55000';
    end if;
  elsif old.durum = 'arsiv' and new.durum = 'yayinda' then
    raise exception 'SURUM_DEGISMEZ: arşiv sürüm doğrudan yayına alınamaz' using errcode = '55000';
  end if;
  return new;
end;
$$;

-- ---------------------------------------------------------------------
-- 2. Sürüm sil (yalnız taslak / arşiv; oturumu olmayan)
-- ---------------------------------------------------------------------
create or replace function public.okuma_surum_sil(p_surum_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_s      public.okuma_hikaye_surumleri%rowtype;
  v_slug   text;
  v_oturum integer;
begin
  perform public.require_admin();

  select * into v_s from public.okuma_hikaye_surumleri where id = p_surum_id for update;
  if not found then
    raise exception 'SURUM_BULUNAMADI' using errcode = 'P0002';
  end if;

  if v_s.durum = 'yayinda' then
    raise exception 'SURUM_YAYINDA: yayındaki sürüm silinemez; önce arşive alın' using errcode = '55000';
  end if;
  if v_s.durum not in ('taslak', 'arsiv') then
    raise exception 'SURUM_SILINEMEZ: yalnız taslak veya arşiv sürüm silinebilir (durum: %)', v_s.durum using errcode = '55000';
  end if;

  select count(*)::integer into v_oturum from public.okuma_oturumlari where surum_id = p_surum_id;
  if v_oturum > 0 then
    raise exception 'OTURUM_VAR: sürümün % okuma oturumu var; silmek yerine arşive alın', v_oturum using errcode = '55000';
  end if;

  select slug into v_slug from public.okuma_hikayeleri where id = v_s.hikaye_id;

  delete from public.okuma_hikaye_surumleri where id = p_surum_id;   -- etiket ve hedef bağları cascade

  perform public.log_admin_action('okuma_surum_silindi', jsonb_build_object(
    'surum_id', p_surum_id, 'hikaye_id', v_s.hikaye_id, 'slug', v_slug,
    'surum_no', v_s.surum_no, 'durum', v_s.durum, 'sha256', v_s.sha256));

  return jsonb_build_object('surum_id', p_surum_id, 'hikaye_id', v_s.hikaye_id, 'slug', v_slug,
                            'surum_no', v_s.surum_no, 'silindi', true);
end;
$$;

revoke all on function public.okuma_surum_sil(uuid) from public, anon;
grant execute on function public.okuma_surum_sil(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- 3. Hikâye sil (hiç oturumu yok + yayında sürüm yok => tüm sürümlerle birlikte)
-- ---------------------------------------------------------------------
create or replace function public.okuma_hikaye_sil(p_hikaye_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_h      public.okuma_hikayeleri%rowtype;
  v_oturum integer;
  v_surum  integer;
  v_fis    integer;
begin
  perform public.require_admin();

  select * into v_h from public.okuma_hikayeleri where id = p_hikaye_id for update;
  if not found then
    raise exception 'HIKAYE_BULUNAMADI' using errcode = 'P0002';
  end if;

  if exists (select 1 from public.okuma_hikaye_surumleri where hikaye_id = p_hikaye_id and durum = 'yayinda') then
    raise exception 'SURUM_YAYINDA: hikâyenin yayında sürümü var; önce arşive alın' using errcode = '55000';
  end if;
  if exists (select 1 from public.okuma_hikaye_surumleri where hikaye_id = p_hikaye_id and durum = 'incelemede') then
    raise exception 'SURUM_SILINEMEZ: incelemede sürüm var; önce taslağa veya arşive alın' using errcode = '55000';
  end if;

  select count(*)::integer into v_oturum from public.okuma_oturumlari where hikaye_id = p_hikaye_id;
  if v_oturum > 0 then
    raise exception 'OTURUM_VAR: hikâyenin % okuma oturumu var; silmek yerine arşive alın', v_oturum using errcode = '55000';
  end if;

  select count(*)::integer into v_surum from public.okuma_hikaye_surumleri where hikaye_id = p_hikaye_id;

  delete from public.okuma_pdf_kullanimlari where hikaye_id = p_hikaye_id;   -- yalnız PDF hak sayacı
  delete from public.okuma_hikaye_surumleri where hikaye_id = p_hikaye_id;   -- etiket ve hedef bağları cascade
  delete from public.okuma_hikayeleri where id = p_hikaye_id;

  -- Fiş bağlantısını boşalt; fiş yeniden üretime döner
  update public.okuma_hikaye_fisleri
     set hikaye_slug = null, durum = 'brief_draft', guncelleme = now()
   where hikaye_slug = v_h.slug;
  get diagnostics v_fis = row_count;

  perform public.log_admin_action('okuma_hikaye_silindi', jsonb_build_object(
    'hikaye_id', p_hikaye_id, 'slug', v_h.slug, 'silinen_surum', v_surum, 'bosaltilan_fis', v_fis));

  return jsonb_build_object('hikaye_id', p_hikaye_id, 'slug', v_h.slug, 'silinen_surum', v_surum,
                            'bosaltilan_fis', v_fis, 'silindi', true);
end;
$$;

revoke all on function public.okuma_hikaye_sil(uuid) from public, anon;
grant execute on function public.okuma_hikaye_sil(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- 4. Genel istatistik panosu (yönetici verisi; min-N yok; öğrenci kimliği dönmez)
--    Doğruluk: tamamlanan oturumlarda toplam doğru / toplam soru (yüzde, 0-100).
--    Okunan kelime: tamamlanan oturumların sürüm ölçümü (olculen.kelime_sayisi) toplamı.
-- ---------------------------------------------------------------------
create or replace function public.okuma_yonetim_istatistik()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_yayinda     integer;
  v_surumler    jsonb;
  v_oturum      integer;
  v_tamam       integer;
  v_oran        numeric;
  v_dogruluk    numeric;
  v_kelime      bigint;
  v_sinif       jsonb;
  v_tur         jsonb;
  v_okuma_sinif jsonb;
  v_okuma_tur   jsonb;
begin
  perform public.require_admin();

  select count(*)::integer into v_yayinda from public.okuma_hikaye_surumleri where durum = 'yayinda';

  select coalesce(jsonb_object_agg(durum, n), '{}'::jsonb) into v_surumler
    from (select durum, count(*)::integer as n from public.okuma_hikaye_surumleri group by durum) d;

  select count(*)::integer, count(*) filter (where tamamlandi_at is not null)::integer
    into v_oturum, v_tamam
    from public.okuma_oturumlari;

  v_oran := case when v_oturum > 0 then round(v_tamam * 100.0 / v_oturum, 1) else null end;

  select case when coalesce(sum(soru_sayisi), 0) > 0
              then round(sum(dogru_sayisi) * 100.0 / sum(soru_sayisi), 1) else null end
    into v_dogruluk
    from public.okuma_oturumlari where tamamlandi_at is not null;

  select coalesce(sum(case when (e.olculen ->> 'kelime_sayisi') ~ '^[0-9]{1,6}$'
                           then (e.olculen ->> 'kelime_sayisi')::bigint else 0 end), 0)
    into v_kelime
    from public.okuma_oturumlari o
    join public.okuma_hikaye_etiketleri e on e.surum_id = o.surum_id
   where o.tamamlandi_at is not null;

  -- Yayındaki hikâyelerin dağılımı
  select coalesce(jsonb_agg(jsonb_build_object('ana_sinif', ana_sinif, 'hikaye', n) order by ana_sinif), '[]'::jsonb) into v_sinif
    from (select e.ana_sinif, count(*)::integer as n
            from public.okuma_hikaye_surumleri s join public.okuma_hikaye_etiketleri e on e.surum_id = s.id
           where s.durum = 'yayinda' group by e.ana_sinif) x;

  select coalesce(jsonb_agg(jsonb_build_object('tur', tur, 'hikaye', n) order by n desc, tur), '[]'::jsonb) into v_tur
    from (select s.tur, count(*)::integer as n
            from public.okuma_hikaye_surumleri s where s.durum = 'yayinda' group by s.tur) x;

  -- Okuma oturumlarının dağılımı
  select coalesce(jsonb_agg(jsonb_build_object('sinif', sinif, 'oturum', n, 'tamamlanan', t) order by sinif), '[]'::jsonb) into v_okuma_sinif
    from (select sinif, count(*)::integer as n, count(*) filter (where tamamlandi_at is not null)::integer as t
            from public.okuma_oturumlari group by sinif) x;

  select coalesce(jsonb_agg(jsonb_build_object('tur', tur, 'oturum', n, 'tamamlanan', t) order by n desc, tur), '[]'::jsonb) into v_okuma_tur
    from (select s.tur, count(*)::integer as n, count(*) filter (where o.tamamlandi_at is not null)::integer as t
            from public.okuma_oturumlari o join public.okuma_hikaye_surumleri s on s.id = o.surum_id
           group by s.tur) x;

  perform public.log_admin_action('okuma_yonetim_istatistik', '{}'::jsonb);

  return jsonb_build_object(
    'yayinda_hikaye', v_yayinda,
    'surum_durumlari', v_surumler,
    'toplam_oturum', v_oturum,
    'tamamlanan_oturum', v_tamam,
    'tamamlama_orani', v_oran,
    'ortalama_dogruluk', v_dogruluk,
    'okunan_kelime', v_kelime,
    'yayinda_sinif_dagilimi', v_sinif,
    'yayinda_tur_dagilimi', v_tur,
    'oturum_sinif_dagilimi', v_okuma_sinif,
    'oturum_tur_dagilimi', v_okuma_tur);
end;
$$;

revoke all on function public.okuma_yonetim_istatistik() from public, anon;
grant execute on function public.okuma_yonetim_istatistik() to authenticated;
