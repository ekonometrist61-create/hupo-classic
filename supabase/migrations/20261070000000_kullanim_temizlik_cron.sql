-- Kullanım süresi verisi 300 gün sonra silinir (KULLANIM_SURESI_KVKK_NOTU.md).
-- 20261066 pg_cron yoksa işi sessizce atlıyordu; burada eklenti zorunlu kılınır, iş yoksa kurulur.
-- pg_cron kullanılamazsa migration bilerek hata verir: sessiz atlanmaz.

create extension if not exists pg_cron with schema pg_catalog;

do $$
begin
  if not exists (select 1 from cron.job where jobname = 'kullanim_olaylari_temizle') then
    perform cron.schedule('kullanim_olaylari_temizle', '15 3 * * *', 'select public.kullanim_olaylari_temizle()');
  end if;
  if not exists (select 1 from cron.job where jobname = 'kullanim_olaylari_temizle') then
    raise exception 'kullanim_olaylari_temizle zamanlayıcısı kurulamadı';
  end if;
end $$;
