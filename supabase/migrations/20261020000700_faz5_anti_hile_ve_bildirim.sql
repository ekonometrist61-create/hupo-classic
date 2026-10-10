-- =====================================================================
-- Faz 5A: Anti-hile — started_at + supheli tespit
-- Faz 5B: Sonuç e-posta bildirimi — olay_kutusu deneme_sonuc_bildirimi
--
-- Değişiklikler:
--   1. deneme_sinavi_denemeleri: started_at + supheli kolonu
--   2. start_mock_exam_attempt: kayıt yaratırken started_at = now()
--   3. _deneme_sinavi_bitir: supheli flag + olay_kutusu insert
--
-- Anti-hile eşiği: sınav başlayıp 30 saniyeden kısa sürede bitirilirse supheli.
--   Amaç: bot/otomatik gönderimi tespit et; öğrenci akışını bloklamaz.
-- Bildirim: finish ilk kez çağrıldığında exam_id + student_id + puan + sira
--   olay_kutusu'na yazılır (PII yok; yalnızca UUID + sayısal alan).
-- =====================================================================

set client_encoding = 'UTF8';

-- -----------------------------------------------------------------------
-- 1. Tablo değişiklikleri
-- -----------------------------------------------------------------------
alter table public.deneme_sinavi_denemeleri
  add column if not exists started_at timestamptz,
  add column if not exists supheli    boolean not null default false;

comment on column public.deneme_sinavi_denemeleri.started_at is
  'start_mock_exam_attempt çağrıldığı an; anti-hile süre kontrolü için.';
comment on column public.deneme_sinavi_denemeleri.supheli is
  'true ise tamamlama süresi şüpheli derecede kısa (< 30 sn).';

-- -----------------------------------------------------------------------
-- 2. start_mock_exam_attempt: started_at doldur
--    Mevcut imza korunur. Yalnızca INSERT satırına started_at eklendi.
-- -----------------------------------------------------------------------
create or replace function public.start_mock_exam_attempt(p_exam_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid       uuid := (select auth.uid());
  v_exam      public.deneme_sinavlari%rowtype;
  v_sinif     smallint;
  v_bitis     timestamptz;
  v_deneme_id uuid;
  v_sorular   jsonb;
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;

  select * into v_exam from public.deneme_sinavlari where id = p_exam_id;
  if not found or not v_exam.aktif then
    raise exception 'Sınav bulunamadı' using errcode = 'P0002';
  end if;

  v_bitis := public._deneme_bitis_zamani(v_exam);
  if now() < v_exam.baslangic_zamani then
    raise exception 'Bu sınav henüz başlamadı' using errcode = '42501';
  end if;
  if now() >= v_bitis then
    raise exception 'Bu sınavın süresi doldu' using errcode = '42501';
  end if;

  select sinif into v_sinif from public.profiles where id = v_uid;
  if v_sinif is null or v_sinif <> all (v_exam.siniflar) then
    raise exception 'Bu sınav sizin sınıfınız için açık değil' using errcode = '22023';
  end if;

  if not exists (
    select 1 from public.deneme_sinavi_katilimlari
     where exam_id = p_exam_id and student_id = v_uid
  ) then
    raise exception 'Önce veli panelinden bu sınava kaydolmalısınız' using errcode = '42501';
  end if;

  if exists (
    select 1 from public.deneme_sinavi_denemeleri
     where exam_id = p_exam_id and student_id = v_uid
  ) then
    raise exception 'Bu sınava zaten başladınız, tekrar giremezsiniz' using errcode = '42501';
  end if;

  insert into public.deneme_sinavi_denemeleri (exam_id, student_id, sinif, started_at)
  values (p_exam_id, v_uid, v_sinif, now())
  returning id into v_deneme_id;

  -- Doğru şık ASLA istemciye gönderilmez.
  select coalesce(jsonb_agg(to_jsonb(x) order by x.sira), '[]'::jsonb) into v_sorular
    from (
      select s.sira, q.id, q.ders, q.konu, q.zorluk, q.soru_metni, q.siklar
        from public.deneme_sinavi_sorulari s
        join public.questions q on q.id = s.question_id
       where s.exam_id = p_exam_id and s.sinif = v_sinif
    ) x;

  return jsonb_build_object(
    'deneme_id',   v_deneme_id,
    'bitis_zamani', v_bitis,
    'sure_dakika',  v_exam.sure_dakika,
    'sorular',      v_sorular
  );
end;
$$;

-- -----------------------------------------------------------------------
-- 3. _deneme_sinavi_bitir: anti-hile + olay_kutusu
--    Yeni davranış:
--      a) Daha önce bitmiş kaydı idempotent olarak döndürür (değişmedi).
--      b) İlk bitiş: supheli bayrağı + olay_kutusu bildirimi.
-- -----------------------------------------------------------------------
create or replace function public._deneme_sinavi_bitir(p_deneme_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_deneme  public.deneme_sinavi_denemeleri%rowtype;
  v_toplam  integer;
  v_dogru   integer;
  v_yanlis  integer;
  v_bos     integer;
  v_puan    numeric(5, 2);
  v_supheli boolean := false;
  v_sira    bigint;
begin
  select * into v_deneme
    from public.deneme_sinavi_denemeleri
   where id = p_deneme_id
     for update;

  if not found then
    raise exception 'Deneme bulunamadı' using errcode = 'P0002';
  end if;

  -- Zaten bitmiş: idempotent.
  if v_deneme.bitis_zamani is not null then
    return jsonb_build_object(
      'dogru_sayisi',  v_deneme.dogru_sayisi,
      'yanlis_sayisi', v_deneme.yanlis_sayisi,
      'bos_sayisi',    v_deneme.bos_sayisi,
      'puan',          v_deneme.puan
    );
  end if;

  -- Faz 5A: süre kontrolü — started_at varsa ve 30 sn altındaysa supheli işaretle.
  if v_deneme.started_at is not null and now() - v_deneme.started_at < interval '30 seconds' then
    v_supheli := true;
  end if;

  select count(*) into v_toplam
    from public.deneme_sinavi_sorulari
   where exam_id = v_deneme.exam_id and sinif = v_deneme.sinif;

  select count(*) filter (where dogru),
         count(*) filter (where not dogru and secilen_sik is not null)
    into v_dogru, v_yanlis
    from public.deneme_sinavi_cevaplari
   where deneme_id = p_deneme_id;

  v_dogru  := coalesce(v_dogru, 0);
  v_yanlis := coalesce(v_yanlis, 0);
  v_bos    := greatest(v_toplam - v_dogru - v_yanlis, 0);
  v_puan   := case when v_toplam > 0 then round(v_dogru * 100.0 / v_toplam, 2) else 0 end;

  update public.deneme_sinavi_denemeleri
     set bitis_zamani  = now(),
         dogru_sayisi  = v_dogru,
         yanlis_sayisi = v_yanlis,
         bos_sayisi    = v_bos,
         puan          = v_puan,
         supheli       = v_supheli
   where id = p_deneme_id;

  -- Faz 5B: sonuç bildirimi — sınıf içindeki sırayı hesapla ve outbox'a yaz.
  -- PII içermez: yalnızca UUID'ler + sayısal alanlar.
  select count(*) filter (where d2.puan > v_puan) + 1
    into v_sira
    from public.deneme_sinavi_denemeleri d2
   where d2.exam_id  = v_deneme.exam_id
     and d2.sinif    = v_deneme.sinif
     and d2.bitis_zamani is not null
     and d2.id != p_deneme_id;

  insert into public.olay_kutusu (tur, payload)
  values (
    'deneme_sonuc_bildirimi',
    jsonb_build_object(
      'exam_id',    v_deneme.exam_id,
      'student_id', v_deneme.student_id,
      'puan',       v_puan,
      'sira',       v_sira,
      'supheli',    v_supheli
    )
  );

  return jsonb_build_object(
    'dogru_sayisi',  v_dogru,
    'yanlis_sayisi', v_yanlis,
    'bos_sayisi',    v_bos,
    'puan',          v_puan
  );
end;
$$;

-- Yetkiler değişmedi — sadece yeniden tanımlandı.
revoke execute on function public.start_mock_exam_attempt(uuid) from public, anon, authenticated, service_role;
grant  execute on function public.start_mock_exam_attempt(uuid) to authenticated;
grant  execute on function public.start_mock_exam_attempt(uuid) to service_role;

revoke execute on function public._deneme_sinavi_bitir(uuid) from public, anon, authenticated, service_role;
grant  execute on function public._deneme_sinavi_bitir(uuid) to service_role;
