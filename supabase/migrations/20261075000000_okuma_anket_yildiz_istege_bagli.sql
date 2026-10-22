-- Anket puanı isteğe bağlı (kullanıcı kararı, 2026-10-23): çocuk puanlamadan da gönderebilir.
-- Yıldız sütunu boş olabilir; ortalamalar boş değerleri zaten dışarıda bırakır.
alter table public.okuma_geri_bildirimleri alter column yildiz drop not null;

create or replace function public.okuma_geri_bildirim_gonder(
  p_oturum_id uuid,
  p_yildiz integer,
  p_iyilestirme_kodlari text[] default '{}',
  p_baska_kahraman boolean default false,
  p_ayni_turden boolean default false,
  p_sorun_kodlari text[] default '{}')
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public._okuma_ogrenci();
  v_iy  text[] := coalesce(p_iyilestirme_kodlari, '{}');
  v_so  text[] := coalesce(p_sorun_kodlari, '{}');
begin
  -- Puan isteğe bağlıdır: boş bırakılabilir; girilirse 1–5 olmalı.
  if p_yildiz is not null and p_yildiz not between 1 and 5 then
    raise exception 'BAD_YILDIZ' using errcode = '22023';
  end if;
  if cardinality(v_iy) > 8 or exists (select 1 from unnest(v_iy) k where k is null or k <> all (array[
       'daha_kisa', 'daha_uzun', 'daha_komik', 'daha_gizemli', 'daha_kolay', 'daha_zor',
       'daha_cok_macera', 'daha_cok_bilgi'])) then
    raise exception 'BAD_KOD' using errcode = '22023';
  end if;
  if cardinality(v_so) > 8 or exists (select 1 from unnest(v_so) k where k is null or k <> all (array[
       'ad_yanlis_yazilmis', 'anlasilmayan_sozcuk', 'soru_hatali', 'cevap_hatali',
       'cok_zor', 'cok_kolay', 'yazi_hatasi', 'uygunsuz_icerik'])) then
    raise exception 'BAD_KOD' using errcode = '22023';
  end if;
  if not exists (select 1 from public.okuma_oturumlari o where o.id = p_oturum_id and o.ogrenci_id = v_uid) then
    raise exception 'OTURUM_BULUNAMADI' using errcode = 'P0002';
  end if;

  insert into public.okuma_geri_bildirimleri (
    oturum_id, yildiz, iyilestirme_kodlari, baska_kahraman, ayni_turden, sorun_kodlari)
  values (
    p_oturum_id, p_yildiz::smallint, (select coalesce(array_agg(distinct k), '{}') from unnest(v_iy) k),
    coalesce(p_baska_kahraman, false), coalesce(p_ayni_turden, false),
    (select coalesce(array_agg(distinct k), '{}') from unnest(v_so) k))
  on conflict (oturum_id) do update
    set yildiz = excluded.yildiz, iyilestirme_kodlari = excluded.iyilestirme_kodlari,
        baska_kahraman = excluded.baska_kahraman, ayni_turden = excluded.ayni_turden,
        sorun_kodlari = excluded.sorun_kodlari;

  return jsonb_build_object('kaydedildi', true);
end;
$$;
