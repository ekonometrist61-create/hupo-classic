-- Halka açık site için okuma kataloğunun toplulaştırılmış özeti (kimlik/içerik yok, yalnız sayılar).
-- Site metni sabit sayı yazmaz; bu özetten üretir. Modül kapalıysa ya da yayında hikâye yoksa boş döner.

create or replace function public.okuma_site_ozeti()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with y as (
    select s.tur, s.sinif_alt, s.sinif_ust, s.sayfa_sayisi
      from public.okuma_hikaye_surumleri s
     where s.durum = 'yayinda'
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
  'Site için yayındaki hikâye sayısı, sınıf aralığı ve tür dağılımı. Yalnız toplulaştırılmış sayılar.';

revoke all on function public.okuma_site_ozeti() from public;
grant execute on function public.okuma_site_ozeti() to anon, authenticated;
