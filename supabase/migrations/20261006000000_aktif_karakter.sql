-- =====================================================================
--  Aktif karakter — öğrencinin koleksiyondan seçtiği "ben buyum" karakteri
--  Eski 5 evreli avatar (Çaylak Alp → Efsanevi Anka) emekliye ayrıldı;
--  çocuk artık 40 karakterlik koleksiyondan kazandığı birini aktif seçer.
--  Karakter sistemi: 20260928000010_character_system.sql
--  Tarih: 2026-10-06
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) student_stats'a aktif karakter kolonu
--    Kazanılan bir karakterin koduna işaret eder; silinirse null olur.
-- ---------------------------------------------------------------------
alter table public.student_stats
  add column if not exists aktif_karakter text
    references public.character_definitions(kod) on delete set null;

comment on column public.student_stats.aktif_karakter is
  'Öğrencinin aktif (gösterilen) karakterinin kodu. Yalnızca kazanılmış bir karaktere set_active_character ile ayarlanır; null ise istemci en yüksek kademeli kazanılmış karakteri gösterir.';

-- ---------------------------------------------------------------------
-- 2) set_active_character(p_kod) — çocuğun aktif karakterini değiştirir
--    Sunucu-otoriter: yalnızca gerçekten KAZANILMIŞ bir karakter seçilebilir.
-- ---------------------------------------------------------------------
create or replace function public.set_active_character(p_kod text)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı';
  end if;

  -- Karakter gerçekten var mı?
  if not exists (
    select 1 from public.character_definitions where kod = p_kod
  ) then
    raise exception 'Böyle bir karakter yok';
  end if;

  -- Çocuk bu karakteri kazanmış mı? Kilitli karakter aktif yapılamaz.
  if not exists (
    select 1 from public.user_characters
    where student_id = v_uid and karakter_kod = p_kod
  ) then
    raise exception 'Bu karakter henüz kilitli';
  end if;

  update public.student_stats
     set aktif_karakter = p_kod
   where student_id = v_uid;

  if not found then
    raise exception 'Öğrenci istatistiği bulunamadı';
  end if;
end;
$$;

revoke execute on function public.set_active_character(text) from public, anon;
grant  execute on function public.set_active_character(text) to authenticated;
