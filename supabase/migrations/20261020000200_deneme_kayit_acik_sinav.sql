-- =====================================================================
-- Herkese açık deneme sınavı ön kayıt için açık sınav bilgisi
-- get_open_exam_for_registration(): id + ad + baslangic_zamani + siniflar
-- Koşul: aktif, başlamamış (kayıt penceresi açık)
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function public.get_open_exam_for_registration()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id',               id,
    'ad',               ad,
    'baslangic_zamani', baslangic_zamani,
    'siniflar',         siniflar
  )
  from public.deneme_sinavlari
  where aktif and baslangic_zamani > now()
  order by baslangic_zamani asc
  limit 1;
$$;

revoke execute on function public.get_open_exam_for_registration() from public, authenticated;
grant  execute on function public.get_open_exam_for_registration() to anon;
grant  execute on function public.get_open_exam_for_registration() to authenticated;
