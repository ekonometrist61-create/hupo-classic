-- =====================================================================
-- Okuma Dünyası — hikâye yayın kuralı: yalnız insan onayı yayını açar (kullanıcı kararı, 2026-11-10).
--   * Yayın için insan kararı "approved" ve inceleyen dolu olmalı. Ajan A / Ajan B sonuçları
--     (pass / review_needed / fail / pending) kaydedilir ve panelde görünür; yayını engellemez.
--     İnsan onayı ajan sonucunu geçersiz kılabilir. Üç onayın hepsi aranmaz.
--   * Önceki kural (20261068): ajan_a = pass ve ajan_b = pass da zorunluydu. Bu migration onu kaldırır.
--   * Mevcut satırlar etkilenmez: kısıt yalnız gevşer; yayındaki sürümler yerinde kalır.
--   * Oluşturan ile onaylayan aynı yönetici olabilir (20261068 ile aynı).
--   * Yalnız hikâye sürümleri için geçerlidir; soru (soru_ajan_kapisi) ve sözlük kuralları değişmez.
--   * okuma_surum_durum_degistir ve okuma_toplu_yayin yeniden tanımlanır; gövdeler öncekilerle
--     aynıdır, yalnız ajan koşulu çıkarılmıştır.
-- =====================================================================

set client_encoding = 'UTF8';

alter table public.okuma_hikaye_surumleri drop constraint if exists okuma_surum_yayin_kapisi;
alter table public.okuma_hikaye_surumleri add constraint okuma_surum_yayin_kapisi check (
  durum <> 'yayinda'
  or (
    denetim ->> 'insan' = 'approved'
    and inceleyen_id is not null
  )
);

create or replace function public.okuma_surum_durum_degistir(
  p_surum_id uuid,
  p_durum    text,
  p_denetim  jsonb default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := (select auth.uid());
  v_s     public.okuma_hikaye_surumleri%rowtype;
  v_den   jsonb;
  v_anahtar text;
  v_onceki_yayin uuid;
  v_inceleyen uuid;
begin
  perform public.require_admin();

  if p_durum is null or p_durum not in ('taslak', 'incelemede', 'yayinda', 'arsiv') then
    raise exception 'BAD_DURUM' using errcode = '22023';
  end if;

  select * into v_s from public.okuma_hikaye_surumleri where id = p_surum_id for update;
  if not found then
    raise exception 'SURUM_BULUNAMADI' using errcode = 'P0002';
  end if;

  if not (
       (v_s.durum = 'taslak'     and p_durum in ('taslak', 'incelemede', 'arsiv'))
    or (v_s.durum = 'incelemede' and p_durum in ('incelemede', 'taslak', 'yayinda', 'arsiv'))
    or (v_s.durum = 'yayinda'    and p_durum = 'arsiv')
    or (v_s.durum = 'arsiv'      and p_durum = 'taslak')
  ) then
    raise exception 'GECERSIZ_GECIS' using errcode = '22023';
  end if;

  -- Denetim birleştirme: yalnız tanımlı anahtarlar ve değerler
  v_den := v_s.denetim;
  v_inceleyen := v_s.inceleyen_id;
  if p_denetim is not null then
    if jsonb_typeof(p_denetim) <> 'object' then
      raise exception 'BAD_DENETIM' using errcode = '22023';
    end if;
    if v_s.durum = 'yayinda' then
      raise exception 'SURUM_DEGISMEZ' using errcode = '55000';
    end if;
    for v_anahtar in select jsonb_object_keys(p_denetim) loop
      if v_anahtar not in ('ajan_a', 'ajan_b', 'insan') then
        raise exception 'BAD_DENETIM' using errcode = '22023';
      end if;
    end loop;
    if p_denetim ? 'ajan_a' and (p_denetim ->> 'ajan_a') not in ('pending', 'pass', 'fail', 'review_needed') then
      raise exception 'BAD_DENETIM' using errcode = '22023';
    end if;
    if p_denetim ? 'ajan_b' and (p_denetim ->> 'ajan_b') not in ('pending', 'pass', 'fail', 'review_needed') then
      raise exception 'BAD_DENETIM' using errcode = '22023';
    end if;
    if p_denetim ? 'insan' then
      if (p_denetim ->> 'insan') not in ('pending', 'approved', 'rejected') then
        raise exception 'BAD_DENETIM' using errcode = '22023';
      end if;
      -- İnsan kararı: onaylayan yönetici incelemeyi üstlenir
      if (p_denetim ->> 'insan') in ('approved', 'rejected') then
        v_inceleyen := v_uid;
      end if;
    end if;
    v_den := v_den || p_denetim;
  end if;

  if p_durum = 'yayinda' then
    -- Yayın kapısı: yalnız insan onayı. Ajan sonuçları yayını engellemez.
    if v_den ->> 'insan' is distinct from 'approved' then
      raise exception 'YAYIN_KAPISI' using errcode = '22023';
    end if;
    if v_inceleyen is null then v_inceleyen := v_uid; end if;

    -- Hikâye başına tek yayında sürüm: öncekini arşive al
    select id into v_onceki_yayin from public.okuma_hikaye_surumleri
     where hikaye_id = v_s.hikaye_id and durum = 'yayinda' and id <> v_s.id;
    if v_onceki_yayin is not null then
      update public.okuma_hikaye_surumleri set durum = 'arsiv', arsiv_at = now() where id = v_onceki_yayin;
    end if;

    update public.okuma_hikaye_surumleri
       set durum = 'yayinda', denetim = v_den, inceleyen_id = v_inceleyen, yayin_at = now()
     where id = v_s.id;
  elsif p_durum = 'arsiv' then
    update public.okuma_hikaye_surumleri set durum = 'arsiv', arsiv_at = now() where id = v_s.id;
  elsif p_durum = 'taslak' and v_s.durum in ('incelemede', 'arsiv') then
    -- Geri çekilen sürümde insan kararı sıfırlanır; arşivden dönüşte tüm denetim sıfırlanır
    update public.okuma_hikaye_surumleri
       set durum = 'taslak',
           denetim = case when v_s.durum = 'arsiv'
                          then '{"ajan_a":"pending","ajan_b":"pending","insan":"pending"}'::jsonb
                          else v_den || '{"insan":"pending"}'::jsonb end,
           inceleyen_id = null, arsiv_at = null
     where id = v_s.id;
  else
    update public.okuma_hikaye_surumleri
       set durum = p_durum, denetim = v_den, inceleyen_id = v_inceleyen
     where id = v_s.id;
  end if;

  perform public.log_admin_action('okuma_surum_durum', jsonb_build_object(
    'surum_id', p_surum_id, 'onceki', v_s.durum, 'yeni', p_durum, 'denetim_degisti', p_denetim is not null));

  return jsonb_build_object('surum_id', p_surum_id, 'onceki', v_s.durum, 'durum', p_durum,
                            'denetim', (select denetim from public.okuma_hikaye_surumleri where id = p_surum_id));
end;
$$;

-- Toplu yayın (20261094): aday yalnız insan onaylı taslak/incelemedeki sürümdür.
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
          -- Aday: insan onayı (inceleyen dolu) verilmiş en yeni taslak/incelemedeki sürüm. Ajan sonuçları aday seçimini etkilemez.
          select s.id, s.durum into v_sid, v_sdurum
            from public.okuma_hikaye_surumleri s
           where s.hikaye_id = v_id and s.durum in ('taslak', 'incelemede')
             and s.denetim ->> 'insan' = 'approved'
             and s.inceleyen_id is not null
           order by s.surum_no desc limit 1;
          if v_sid is null then
            if exists (select 1 from public.okuma_hikaye_surumleri s where s.hikaye_id = v_id and s.durum = 'yayinda') then
              raise exception 'ZATEN_YAYINDA: yayındaki sürümden başka yeni onaylı sürüm yok' using errcode = '55000';
            end if;
            raise exception 'YAYIN_KAPISI: insan onayı verilmiş taslak veya incelemede sürüm yok' using errcode = '22023';
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
