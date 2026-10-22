-- =====================================================================
-- Okuma Dünyası — hikâye yayın kuralı: dört göz yerine ÜÇ GÖZ (kullanıcı kararı, 2026-10-22).
--   * İlk iki göz yapay zekâ denetçileri (ajan_a, ajan_b = pass); üçüncü göz insan (insan = approved).
--   * Oluşturan ile onaylayan aynı yönetici hesabı olabilir (içeriği zaten yapay zekâ üretir ve
--     kullanıcı sunar); inceleyen_id yine zorunludur.
--   * Yalnız hikâye sürümleri için geçerlidir; sözlük ve hedef onayları dört göz kalır.
-- =====================================================================

set client_encoding = 'UTF8';

alter table public.okuma_hikaye_surumleri drop constraint if exists okuma_surum_yayin_kapisi;
alter table public.okuma_hikaye_surumleri add constraint okuma_surum_yayin_kapisi check (
  durum <> 'yayinda'
  or (
    denetim ->> 'ajan_a' = 'pass'
    and denetim ->> 'ajan_b' = 'pass'
    and denetim ->> 'insan' = 'approved'
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
      -- İnsan kararı (üçüncü göz): onaylayan yönetici incelemeyi üstlenir (üç göz: Ajan A, Ajan B, insan)
      if (p_denetim ->> 'insan') in ('approved', 'rejected') then
        v_inceleyen := v_uid;
      end if;
    end if;
    v_den := v_den || p_denetim;
  end if;

  if p_durum = 'yayinda' then
    if v_den ->> 'ajan_a' is distinct from 'pass'
       or v_den ->> 'ajan_b' is distinct from 'pass'
       or v_den ->> 'insan' is distinct from 'approved' then
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
