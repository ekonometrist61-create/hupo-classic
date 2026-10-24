-- =====================================================================
-- GÖR-004: search_path standardizasyonu
--
-- 17 public fonksiyonu search_path = 'public, pg_temp' (ikisi ayrıca 'extensions')
-- kullanıyordu. SECURITY DEFINER dahil; güvenlik kuralı: search_path boş olmalı ve
-- gövdedeki her nesne başvurusu şema ile nitelenmiş olmalı.
--
-- Denetim (20261081 öncesi, canlı tanımlar üzerinde statik tarama):
--   * 17 gövdede public şeması dışında kalan, nitelenmemiş tablo/fonksiyon/tip adı yok;
--     tek istisna create_challenge içindeki _uret_meydan_kod() çağrısıydı (public. ile
--     nitelendi; gövde CREATE OR REPLACE ile yeniden tanımlandı, başka değişiklik yok).
--   * Gövdelerdeki diğer çağrılar PostgreSQL yerleşikleri (pg_catalog): coalesce, now,
--     gen_random_uuid, encode, set_config, jsonb_build_object vb.; search_path'ten bağımsız.
--   * auth.uid() zaten şema niteli.
-- Yalnızca yetki yolu değişir; iş mantığı değişmez.
-- =====================================================================

alter function public.telefon_normalize(text) set search_path = '';
alter function public.admin_upsert_sinif(uuid, text, integer, uuid, text, integer, boolean) set search_path = '';
alter function public.admin_sinif_ogrenci_cikar(uuid, uuid) set search_path = '';
alter function public.admin_sinif_ogrenci_ekle(uuid, uuid) set search_path = '';
alter function public.join_challenge(text) set search_path = '';
alter function public.get_my_characters() set search_path = '';
alter function public.admin_list_siniflar(uuid, integer, boolean, integer, integer) set search_path = '';
alter function public.admin_send_notification(text, text, text, uuid, text) set search_path = '';
alter function public.set_active_character(text) set search_path = '';
alter function public.characters_after_change() set search_path = '';
alter function public.create_parent_link_code() set search_path = '';
alter function public.telefon_kod_uret(uuid, text) set search_path = '';
alter function public.redeem_parent_link_code(text) set search_path = '';
alter function public.telefon_kod_dogrula(text) set search_path = '';
alter function public.admin_list_notifications(integer, integer) set search_path = '';
alter function public.ogretmen_siniflarim() set search_path = '';

-- create_challenge: gövde nitelenmiş çağrıyla yeniden tanımlanır (tanım canlıdan alındı).
CREATE OR REPLACE FUNCTION public.create_challenge()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid        uuid := auth.uid();
  v_sinif      int;
  v_kod        text;
  v_sorular    jsonb;
  v_id         uuid;
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı';
  end if;

  select sinif into v_sinif from public.profiles where id = v_uid;

  -- Benzersiz kod üret (en fazla 5 deneme)
  for i in 1..5 loop
    v_kod := public._uret_meydan_kod();
    exit when not exists (select 1 from public.meydan_okumalar where kod = v_kod);
  end loop;

  -- 10 sınıfa uygun soru (dogru_sik HARİÇ)
  select jsonb_agg(
    jsonb_build_object(
      'id',         q.id,
      'soru_metni', q.soru_metni,
      'siklar',     q.siklar,
      'konu',       q.konu,
      'zorluk',     q.zorluk
    )
  )
  into v_sorular
  from (
    select id, soru_metni, siklar, konu, zorluk
    from   public.questions
    where  onay_durumu = 'onaylandi'
      and  (sinif = v_sinif or sinif is null)
    order by random()
    limit 10
  ) q;

  if v_sorular is null then
    -- Sınıf kısıtı olmadan dene
    select jsonb_agg(
      jsonb_build_object(
        'id', q.id, 'soru_metni', q.soru_metni,
        'siklar', q.siklar, 'konu', q.konu, 'zorluk', q.zorluk
      )
    ) into v_sorular
    from (
      select id, soru_metni, siklar, konu, zorluk
      from public.questions
      where onay_durumu = 'onaylandi'
      order by random()
      limit 10
    ) q;
  end if;

  if v_sorular is null or jsonb_array_length(v_sorular) < 3 then
    raise exception 'Yeterli soru bulunamadı';
  end if;

  insert into public.meydan_okumalar (kod, davet_eden, sorular)
  values (v_kod, v_uid, v_sorular)
  returning id into v_id;

  return jsonb_build_object(
    'id',           v_id,
    'kod',          v_kod,
    'sorular',      v_sorular,
    'sure_dakika',  5,
    'durum',        'bekliyor'
  );
end;
$function$;
