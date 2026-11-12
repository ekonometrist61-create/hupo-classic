-- Site özeti yalnız 3–7. sınıf aralığına denk gelen yayındaki hikâyeleri sayar (2026-11-12 kararı).
-- Sınıf aralığı da bu bantla sınırlanır; 2. veya 8. sınıfa ait sürümler sitedeki sayıya girmez.

create or replace function public.okuma_site_ozeti()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with y as (
    select s.tur, greatest(s.sinif_alt, 3) as sinif_alt, least(s.sinif_ust, 7) as sinif_ust, s.sayfa_sayisi
      from public.okuma_hikaye_surumleri s
     where s.durum = 'yayinda'
       and s.sinif_alt <= 7
       and s.sinif_ust >= 3
       and coalesce((select a.deger from public.okuma_ayarlari a where a.anahtar = 'aktif'), 'false'::jsonb) = 'true'::jsonb
  )
  select case when (select count(*) from y) = 0 then '{}'::jsonb else jsonb_build_object(
    'hikaye_sayisi', (select count(*) from y),
    'sinif_alt', (select min(sinif_alt) from y),
    'sinif_ust', (select max(sinif_ust) from y),
    'turler', (select coalesce(jsonb_agg(jsonb_build_object('tur', t.tur, 'adet', t.adet) order by t.adet desc, t.tur), '[]'::jsonb)
                 from (select tur, count(*)::integer as adet from y group by tur) t)
  ) end;
$$;

comment on function public.okuma_site_ozeti() is
  'Site için 3–7. sınıf aralığındaki yayındaki hikâye sayısı, sınıf aralığı ve tür dağılımı. Yalnız toplulaştırılmış sayılar.';

revoke all on function public.okuma_site_ozeti() from public;
grant execute on function public.okuma_site_ozeti() to anon, authenticated;
