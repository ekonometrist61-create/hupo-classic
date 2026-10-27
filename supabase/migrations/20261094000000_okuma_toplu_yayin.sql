-- =====================================================================
-- Okuma Dünyası — yönetimde toplu yayın (yayına al / yayından çek)
--   okuma_toplu_yayin(p_hikaye_idler, p_islem, p_kuru)
--     p_islem = 'yayina_al'    : hikâyenin taslak/incelemedeki, Ajan A + Ajan B "pass" ve insan "approved"
--                                olan EN YENİ sürümünü yayına alır. Taslaksa önce incelemeye alınır.
--                                Önceki yayındaki sürüm okuma_surum_durum_degistir kuralıyla arşive gider.
--     p_islem = 'yayindan_cek' : hikâyenin yayındaki sürümünü arşive alır (çocuklara gösterilmez).
--   Yayın kapısı yeniden yazılmaz: okuma_surum_durum_degistir ve okuma_surum_yayin_kapisi zorlar.
--   Kuru çalıştırma (varsayılan) gerçek işlemi dener ve geri alır; önizleme ile gerçek sonuç aynıdır.
--   Yanıt: { islem, kuru, basarili, atlanan, sonuclar: [{ hikaye_id, slug, sonuc, neden, ayrinti,
--            etkilenen_surum }] } — öğrenci kimliği dönmez.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function public.okuma_toplu_yayin(
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
  v_sid      uuid;
  v_sdurum   text;
  v_n        integer;
  v_sonuclar jsonb := '[]'::jsonb;
  v_ok       integer := 0;
  v_atla     integer := 0;
  v_neden    text;
  v_ayrinti  text;
begin
  perform public.require_admin();

  if p_islem is null or p_islem not in ('yayina_al', 'yayindan_cek') then
    raise exception 'BAD_ISLEM: işlem yayina_al veya yayindan_cek olmalı' using errcode = '22023';
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
    v_neden := null; v_ayrinti := null; v_n := 0; v_sid := null;

    if not found then
      v_neden := 'HIKAYE_BULUNAMADI';
    else
      begin
        if p_islem = 'yayina_al' then
          -- Aday: dört kapıdan (Ajan A, Ajan B, insan, inceleyen) geçen en yeni taslak/incelemedeki sürüm.
          select s.id, s.durum into v_sid, v_sdurum
            from public.okuma_hikaye_surumleri s
           where s.hikaye_id = v_id and s.durum in ('taslak', 'incelemede')
             and s.denetim ->> 'ajan_a' = 'pass' and s.denetim ->> 'ajan_b' = 'pass'
             and s.denetim ->> 'insan' = 'approved'
           order by s.surum_no desc limit 1;
          if v_sid is null then
            if exists (select 1 from public.okuma_hikaye_surumleri s where s.hikaye_id = v_id and s.durum = 'yayinda') then
              raise exception 'ZATEN_YAYINDA: yayındaki sürümden başka yeni onaylı sürüm yok' using errcode = '55000';
            end if;
            raise exception 'YAYIN_KAPISI: Ajan A, Ajan B ve insan onayı tamamlanmış taslak veya incelemede sürüm yok' using errcode = '22023';
          end if;
          if v_sdurum = 'taslak' then
            perform public.okuma_surum_durum_degistir(v_sid, 'incelemede', null);
          end if;
          perform public.okuma_surum_durum_degistir(v_sid, 'yayinda', null);
          v_n := 1;
        else
          for v_sid in select s.id from public.okuma_hikaye_surumleri s
                        where s.hikaye_id = v_id and s.durum = 'yayinda' loop
            perform public.okuma_surum_durum_degistir(v_sid, 'arsiv', null);
            v_n := v_n + 1;
          end loop;
          if v_n = 0 then
            raise exception 'YAYINDA_DEGIL: hikâyenin yayında sürümü yok' using errcode = '55000';
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

  perform public.log_admin_action('okuma_toplu_yayin', jsonb_build_object(
    'islem', p_islem, 'kuru', v_kuru, 'secilen', cardinality(v_idler), 'basarili', v_ok, 'atlanan', v_atla));

  return jsonb_build_object('islem', p_islem, 'kuru', v_kuru, 'basarili', v_ok, 'atlanan', v_atla,
                            'sonuclar', v_sonuclar);
end;
$$;

revoke all on function public.okuma_toplu_yayin(uuid[], text, boolean) from public, anon;
grant execute on function public.okuma_toplu_yayin(uuid[], text, boolean) to authenticated;
