-- =====================================================================
-- Deneme sınavı: katılım onayı ile pazarlama onayının ayrılması (TASKS §20, K6)
--
-- Sorun (canlı migration zinciri incelemesi):
-- 1. public.consents.tur kısıtı yalnızca ('aydinlatma_okundu', 'veli_acik_riza',
--    'veli_riza_geri_cekildi') kabul ediyordu. set_exam_marketing_consent
--    ('sinav_pazarlama_izni') bu kısıt yüzünden her zaman hata veriyordu.
-- 2. register_for_mock_exam, katılım/hizmet onayını ayırmadan yalnızca
--    'sinav_pazarlama_izni' arıyordu: sınav kaydı pazarlama rızasına bağlıydı.
--
-- Bu migration:
-- - consents.tur kısıtına 'sinav_katilim_onayi' ve 'sinav_pazarlama_izni' ekler.
-- - set_exam_katilim_onayi(p_cocuk_id, p_surum): veli katılım onayını kendi türüyle kaydeder.
-- - register_for_mock_exam: kayıt için 'sinav_katilim_onayi' arar. Pazarlama onayı zorunlu değildir.
--
-- Uygulama: bu dosya yazıldı ve PGlite testiyle (supabase/tests/sinav_katilim) sınandı.
-- Uzak veritabanına UYGULANMADI; uygulama ayrı onay gerektirir.
-- Sıra: bu migration, veli-paneli istemci sürümünden ÖNCE uygulanmalıdır.
-- =====================================================================

-- 1. consents.tur kısıtı: mevcut tür kısıtlarını ada bakmadan düşür, yenisini ekle.
do $$
declare
  r record;
begin
  for r in
    select c.conname
      from pg_constraint c
     where c.conrelid = 'public.consents'::regclass
       and c.contype = 'c'
       and pg_get_constraintdef(c.oid) ilike '%tur%'
  loop
    execute format('alter table public.consents drop constraint %I', r.conname);
  end loop;
end
$$;

alter table public.consents
  add constraint consents_tur_check
  check (tur in (
    'aydinlatma_okundu',
    'veli_acik_riza',
    'veli_riza_geri_cekildi',
    'sinav_katilim_onayi',
    'sinav_pazarlama_izni'
  ));

-- 2. Katılım onayı RPC'si (veli, yalnızca kendi çocuğu için).
create or replace function public.set_exam_katilim_onayi(p_cocuk_id uuid, p_surum text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'Yalnızca çocuğun velisi bu onayı verebilir' using errcode = '42501';
  end if;
  if p_surum is null or length(trim(p_surum)) = 0 then
    raise exception 'Sürüm gerekli' using errcode = '22023';
  end if;

  insert into public.consents (cocuk_id, veli_id, tur, surum)
  values (p_cocuk_id, v_uid, 'sinav_katilim_onayi', p_surum);
end;
$$;

revoke execute on function public.set_exam_katilim_onayi(uuid, text) from public, anon, authenticated, service_role;
grant  execute on function public.set_exam_katilim_onayi(uuid, text) to authenticated;
grant  execute on function public.set_exam_katilim_onayi(uuid, text) to service_role;

-- 3. Sınav kaydı: artık katılım onayını arar; pazarlama onayı kayıt için gerekmez.
create or replace function public.register_for_mock_exam(p_exam_id uuid, p_cocuk_id uuid, p_telefon text, p_surum text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid  uuid := (select auth.uid());
  v_exam public.deneme_sinavlari%rowtype;
  v_sinif smallint;
  v_ana  uuid := public.deneme_ana_profil(p_cocuk_id);
begin
  if v_uid is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'Yalnızca çocuğun velisi kayıt yapabilir' using errcode = '42501';
  end if;
  if p_telefon is null or length(trim(p_telefon)) < 7 or length(trim(p_telefon)) > 20 then
    raise exception 'Geçerli bir telefon numarası girin' using errcode = '22023';
  end if;

  select * into v_exam from public.deneme_sinavlari where id = p_exam_id;
  if not found or not v_exam.aktif then
    raise exception 'Sınav bulunamadı' using errcode = 'P0002';
  end if;
  if now() >= v_exam.baslangic_zamani then
    raise exception 'Bu sınav için kayıtlar kapandı' using errcode = '42501';
  end if;

  select sinif into v_sinif from public.profiles where id = p_cocuk_id;
  if v_sinif is null or v_sinif <> all (v_exam.siniflar) then
    raise exception 'Bu sınav öğrencinin sınıfı için açık değil' using errcode = '22023';
  end if;

  if not exists (
    select 1 from public.consents
     where cocuk_id = p_cocuk_id and tur = 'sinav_katilim_onayi' and surum = p_surum
  ) then
    raise exception 'Önce sınav katılım onayı verilmeli' using errcode = '42501';
  end if;

  insert into public.deneme_sinavi_katilimlari (exam_id, student_id, veli_id, telefon)
  values (p_exam_id, v_ana, v_uid, trim(p_telefon))
  on conflict (exam_id, student_id) do update set telefon = excluded.telefon;

  update public.profiles set telefon = trim(p_telefon) where id = v_ana;
end;
$$;

revoke execute on function public.register_for_mock_exam(uuid, uuid, text, text) from public, anon, authenticated, service_role;
grant  execute on function public.register_for_mock_exam(uuid, uuid, text, text) to authenticated;
grant  execute on function public.register_for_mock_exam(uuid, uuid, text, text) to service_role;
