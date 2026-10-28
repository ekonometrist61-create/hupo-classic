-- =====================================================================
-- Okuma Dünyası — yönetimde toplu işlem (Faz 3 yaşam döngüsü)
--   okuma_toplu_islem(p_hikaye_idler, p_islem, p_kuru)
--     p_islem = 'arsiv' : hikâyenin arşivde olmayan tüm sürümlerini arşive alır.
--     p_islem = 'sil'   : okuma_hikaye_sil kurallarıyla hikâyeyi tüm sürümleriyle siler
--                         (yayında / incelemede sürüm veya okuma oturumu varsa ATLANIR).
--   Kurallar yeniden yazılmaz: mevcut RPC'ler (okuma_surum_durum_degistir, okuma_hikaye_sil) hikâye
--   başına bir alt işlemde çağrılır; biri hata verirse yalnız o hikâye geri alınır ve nedeniyle
--   birlikte "atlandi" döner, diğerleri sürer. Kuru çalıştırma (varsayılan) gerçek işlemi dener ve
--   sonunda geri alır; böylece önizleme ile gerçek sonuç aynı kuralları kullanır.
--   Yanıt: { islem, kuru, basarili, atlanan, sonuclar: [{ hikaye_id, slug, baslik, sonuc, neden,
--            ayrinti, etkilenen_surum }] }  — öğrenci kimliği dönmez.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function public.okuma_toplu_islem(
  p_hikaye_idler uuid[],
  p_islem        text,
  p_kuru         boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_kuru     boolean := coalesce(p_kuru, true);
  v_idler    uuid[];
  v_id       uuid;
  v_h        record;
  v_s        record;
  v_n        integer;
  v_r        jsonb;
  v_sonuclar jsonb := '[]'::jsonb;
  v_ok       integer := 0;
  v_atla     integer := 0;
  v_neden    text;
  v_ayrinti  text;
begin
  perform public.require_admin();

  if p_islem is null or p_islem not in ('arsiv', 'sil') then
    raise exception 'BAD_ISLEM: işlem arsiv veya sil olmalı' using errcode = '22023';
  end if;
  if p_hikaye_idler is null or coalesce(cardinality(p_hikaye_idler), 0) = 0 then
    raise exception 'BAD_LISTE: en az bir hikâye seçilmeli' using errcode = '22023';
  end if;

  select coalesce(array_agg(distinct x), '{}') into v_idler from unnest(p_hikaye_idler) x where x is not null;
  if cardinality(v_idler) > 100 then
    raise exception 'BAD_LISTE: en fazla 100 hikâye seçilebilir' using errcode = '22023';
  end if;

  foreach v_id in array v_idler loop
    select id, slug into v_h from public.okuma_hikayeleri where id = v_id;
    v_neden := null; v_ayrinti := null; v_n := 0;

    if not found then
      v_neden := 'HIKAYE_BULUNAMADI';
    else
      begin
        if p_islem = 'sil' then
          v_r := public.okuma_hikaye_sil(v_id);
          v_n := coalesce((v_r ->> 'silinen_surum')::integer, 0);
        else
          v_n := 0;
          for v_s in select id from public.okuma_hikaye_surumleri
                      where hikaye_id = v_id and durum <> 'arsiv' order by surum_no loop
            perform public.okuma_surum_durum_degistir(v_s.id, 'arsiv', null);
            v_n := v_n + 1;
          end loop;
          if v_n = 0 then
            raise exception 'ZATEN_ARSIV: hikâyenin arşivde olmayan sürümü yok' using errcode = '55000';
          end if;
        end if;
        if v_kuru then
          raise exception 'KURU_GERI' using errcode = 'P0001';
        end if;
      exception when others then
        if sqlerrm <> 'KURU_GERI' then
          v_neden := split_part(sqlerrm, ':', 1);
          v_ayrinti := nullif(btrim(substr(sqlerrm, length(v_neden) + 2)), '');
        end if;
      end;
    end if;

    if v_neden is null then
      v_ok := v_ok + 1;
    else
      v_atla := v_atla + 1;
    end if;

    v_sonuclar := v_sonuclar || jsonb_build_array(jsonb_build_object(
      'hikaye_id', v_id,
      'slug', v_h.slug,
      'sonuc', case when v_neden is null then 'basarili' else 'atlandi' end,
      'neden', v_neden,
      'ayrinti', v_ayrinti,
      'etkilenen_surum', case when v_neden is null then v_n else null end));
  end loop;

  perform public.log_admin_action('okuma_toplu_islem', jsonb_build_object(
    'islem', p_islem, 'kuru', v_kuru, 'secilen', cardinality(v_idler), 'basarili', v_ok, 'atlanan', v_atla));

  return jsonb_build_object('islem', p_islem, 'kuru', v_kuru, 'basarili', v_ok, 'atlanan', v_atla,
                            'sonuclar', v_sonuclar);
end;
$$;

revoke all on function public.okuma_toplu_islem(uuid[], text, boolean) from public, anon;
grant execute on function public.okuma_toplu_islem(uuid[], text, boolean) to authenticated;
