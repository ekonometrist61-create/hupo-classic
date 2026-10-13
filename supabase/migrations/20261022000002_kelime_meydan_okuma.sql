-- =====================================================================
-- KELİME EVRENİ — Arena (meydan okuma) entegrasyonu
--
-- Amaç: çocuklar birbirine kelime oyunundan meydan okuyabilsin.
-- Mevcut Arena kuralları aynen korunur:
--   * Puanlama: doğru × 4 − yanlış (en az 0); doğru şık sunucudan okunur.
--   * XP: Arena XP üretmez (mevcut davranış). Kelime XP'si yalnızca tek oyuncu oyununda verilir.
--   * Kod ile katılım, sohbet ve isim yok.
--
-- Değişiklikler:
--   1. meydan_okumalar: oyun türü (soru | kelime) ve kelime ilişki türü kolonları.
--   2. create_kelime_challenge(): yayındaki, sınıfa uygun kelime sorularından 10 soru.
--      Anlık görüntüde doğru şık, açıklama ve ipucu YOK; şıklar A/B/C biçimindedir (Arena ekranı değişmez).
--   3. submit_challenge(): kelime dalı (doğru şık kelime_sorulari.dogru_indeks'ten) ve
--      listede olmayan soru kimliğine puan verilmemesi (doğru şık sızdırılamaz).
--
-- Ön koşul: 20261010000000_meydan_okuma.sql, 20261022000000_kelime_evreni.sql.
-- =====================================================================

set client_encoding = 'UTF8';

alter table public.meydan_okumalar
  add column if not exists oyun_turu text not null default 'soru'
    check (oyun_turu in ('soru', 'kelime'));

alter table public.meydan_okumalar
  add column if not exists kelime_iliski_turu text
    check (kelime_iliski_turu is null or kelime_iliski_turu in ('es_anlamli', 'zit_anlamli', 'es_sesli'));

-- ---------------------------------------------------------------------
-- create_kelime_challenge: kelime Arena'sı oluşturur (yalnızca öğrenci)
-- p_iliski_turu null ise karışık (üç tür birden) soru seçilir.
-- ---------------------------------------------------------------------
create or replace function public.create_kelime_challenge(p_iliski_turu text default null)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := auth.uid();
  v_sinif   smallint;
  v_kod     text;
  v_sorular jsonb;
  v_id      uuid;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'STUDENT_ONLY' using errcode = '42501';
  end if;

  select p.sinif into v_sinif from public.profiles p where p.id = v_uid;
  if v_sinif is null then
    raise exception 'SINIF_GEREKLI' using errcode = '22023';
  end if;

  if p_iliski_turu is not null and p_iliski_turu not in ('es_anlamli', 'zit_anlamli', 'es_sesli') then
    raise exception 'BAD_RELATION' using errcode = '22023';
  end if;

  -- Benzersiz kod (en fazla 5 deneme); mevcut _uret_meydan_kod kullanılır
  for i in 1..5 loop
    v_kod := public._uret_meydan_kod();
    exit when not exists (select 1 from public.meydan_okumalar where kod = v_kod);
  end loop;

  select jsonb_agg(
           jsonb_build_object(
             'id',         q.id,
             'soru_metni', q.soru_metni,
             'siklar',     q.siklar,
             'konu',       q.konu,
             'zorluk',     q.zorluk
           ) order by q.rastgele)
    into v_sorular
    from (
      select s.id,
             s.soru_metni,
             (select jsonb_object_agg(chr((64 + e.ord)::int), e.val)
                from jsonb_array_elements_text(s.secenekler) with ordinality as e(val, ord)) as siklar,
             case s.iliski_turu
               when 'es_anlamli' then 'Anlam Köprüleri'
               when 'zit_anlamli' then 'Zıtlık Vadisi'
               else 'Aynalar Ormanı'
             end as konu,
             s.zorluk,
             random() as rastgele
        from public.kelime_sorulari s
       where s.durum = 'yayinda'
         and s.sinif = v_sinif
         and (p_iliski_turu is null or s.iliski_turu = p_iliski_turu)
       order by random()
       limit 10
    ) q;

  if v_sorular is null or jsonb_array_length(v_sorular) < 3 then
    raise exception 'Yeterli soru bulunamadı';
  end if;

  insert into public.meydan_okumalar (kod, davet_eden, sorular, oyun_turu, kelime_iliski_turu)
  values (v_kod, v_uid, v_sorular, 'kelime', p_iliski_turu)
  returning id into v_id;

  return jsonb_build_object(
    'id',           v_id,
    'kod',          v_kod,
    'sorular',      v_sorular,
    'sure_dakika',  5,
    'durum',        'bekliyor',
    'oyun_turu',    'kelime'
  );
end;
$$;

revoke execute on function public.create_kelime_challenge(text) from public, anon;
grant  execute on function public.create_kelime_challenge(text) to authenticated;

-- ---------------------------------------------------------------------
-- submit_challenge: 20261010000000 sürümünün birebir kopyası + iki ek kural:
--   * Yalnızca bu meydan okumanın sorularına puan verilir (listede olmayan kimlik sayılmaz).
--   * Kelime meydanında doğru şık kelime_sorulari.dogru_indeks'ten okunur (A/B/C ↔ 0/1/2).
-- Puanlama aynıdır: doğru × 4 − yanlış (en az 0). XP üretilmez.
-- ---------------------------------------------------------------------
create or replace function public.submit_challenge(
  p_meydan_id uuid,
  p_cevaplar  jsonb   -- [{question_id: uuid, secilen_sik: text|null}]
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid        uuid := auth.uid();
  v_row        public.meydan_okumalar;
  v_dogru      int := 0;
  v_yanlis     int := 0;
  v_puan       numeric;
  v_cevap      jsonb;
  v_soru_id    uuid;
  v_dogru_sik  text;
  v_dogru_idx  smallint;
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı';
  end if;

  select * into v_row from public.meydan_okumalar where id = p_meydan_id;

  if not found then
    raise exception 'Meydan okuma bulunamadı';
  end if;
  if v_uid is distinct from v_row.davet_eden and v_uid is distinct from v_row.davet_edilen then
    raise exception 'Bu meydan okumaya erişim yok';
  end if;
  if v_row.durum = 'bekliyor' then
    raise exception 'Meydan okuma henüz başlamadı';
  end if;

  -- Zaten gönderilmişse idempotent dön
  if exists (
    select 1 from public.meydan_okuma_cevaplar
    where meydan_okuma_id = p_meydan_id and student_id = v_uid
      and bitis_zamani is not null
  ) then
    select jsonb_build_object(
      'dogru_sayisi', dogru_sayisi,
      'yanlis_sayisi', yanlis_sayisi,
      'puan', puan
    ) into v_cevap
    from public.meydan_okuma_cevaplar
    where meydan_okuma_id = p_meydan_id and student_id = v_uid;
    return v_cevap;
  end if;

  -- Puanlama: doğru şık sunucudan okunur. Yalnızca bu meydan okumanın sorularına puan verilir.
  for v_cevap in select * from jsonb_array_elements(p_cevaplar) loop
    v_soru_id := (v_cevap->>'question_id')::uuid;

    if not exists (
      select 1 from jsonb_array_elements(v_row.sorular) s
       where (s->>'id')::uuid = v_soru_id
    ) then
      continue;
    end if;

    if v_row.oyun_turu = 'kelime' then
      select k.dogru_indeks into v_dogru_idx
        from public.kelime_sorulari k where k.id = v_soru_id;
      v_dogru_sik := chr(65 + v_dogru_idx);   -- 0 → 'A', 1 → 'B', 2 → 'C'
    else
      select q.dogru_sik into v_dogru_sik
        from public.questions q where q.id = v_soru_id;
    end if;

    if (v_cevap->>'secilen_sik') is not null then
      if (v_cevap->>'secilen_sik') = v_dogru_sik then
        v_dogru := v_dogru + 1;
      else
        v_yanlis := v_yanlis + 1;
      end if;
    end if;
  end loop;

  v_puan := greatest(0, v_dogru * 4 - v_yanlis);

  insert into public.meydan_okuma_cevaplar
    (meydan_okuma_id, student_id, cevaplar, dogru_sayisi, yanlis_sayisi, puan, bitis_zamani)
  values
    (p_meydan_id, v_uid, p_cevaplar, v_dogru, v_yanlis, v_puan, now())
  on conflict (meydan_okuma_id, student_id)
  do update set
    cevaplar     = excluded.cevaplar,
    dogru_sayisi = excluded.dogru_sayisi,
    yanlis_sayisi = excluded.yanlis_sayisi,
    puan         = excluded.puan,
    bitis_zamani = excluded.bitis_zamani;

  -- Her iki oyuncu da bitirdiyse meydan okumayı kapat
  if (
    select count(*) from public.meydan_okuma_cevaplar
    where meydan_okuma_id = p_meydan_id and bitis_zamani is not null
  ) >= 2 then
    update public.meydan_okumalar set durum = 'bitti' where id = p_meydan_id;
  end if;

  return jsonb_build_object(
    'dogru_sayisi',  v_dogru,
    'yanlis_sayisi', v_yanlis,
    'puan',          v_puan
  );
end;
$$;

revoke execute on function public.submit_challenge(uuid, jsonb) from public, anon;
grant  execute on function public.submit_challenge(uuid, jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- get_challenge_result: 20261010000000 sürümü + erişim kontrolü düzeltmesi.
-- davet_edilen henüz boşken (meydan beklerken) "<>" karşılaştırması NULL verip
-- kontrolü atlıyordu; IS DISTINCT FROM ile yabancı kullanıcı sonuç göremez.
-- ---------------------------------------------------------------------
create or replace function public.get_challenge_result(p_meydan_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := auth.uid();
  v_row   public.meydan_okumalar;
  v_ben   jsonb;
  v_rakip jsonb;
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı';
  end if;

  select * into v_row from public.meydan_okumalar where id = p_meydan_id;

  if not found then
    raise exception 'Meydan okuma bulunamadı';
  end if;
  if v_uid is distinct from v_row.davet_eden and v_uid is distinct from v_row.davet_edilen then
    raise exception 'Bu meydan okumaya erişim yok';
  end if;

  select jsonb_build_object(
    'dogru', dogru_sayisi, 'yanlis', yanlis_sayisi, 'puan', puan, 'bitti', bitis_zamani is not null
  ) into v_ben
  from public.meydan_okuma_cevaplar
  where meydan_okuma_id = p_meydan_id and student_id = v_uid;

  select jsonb_build_object(
    'dogru', dogru_sayisi, 'yanlis', yanlis_sayisi, 'puan', puan, 'bitti', bitis_zamani is not null
  ) into v_rakip
  from public.meydan_okuma_cevaplar
  where meydan_okuma_id = p_meydan_id and student_id <> v_uid;

  return jsonb_build_object(
    'id',     p_meydan_id,
    'durum',  v_row.durum,
    'kod',    v_row.kod,
    'ben',    coalesce(v_ben, 'null'::jsonb),
    'rakip',  coalesce(v_rakip, 'null'::jsonb)
  );
end;
$$;

revoke execute on function public.get_challenge_result(uuid) from public, anon;
grant  execute on function public.get_challenge_result(uuid) to authenticated;