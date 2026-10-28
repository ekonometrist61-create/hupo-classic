-- questions.ders içinde "Din Kültürü" (kısa ad, sınıf 4/6/7/8; 40 soru) müfredattaki
-- "Din Kültürü ve Ahlak Bilgisi" dersinin ad varyantıdır. Eşleme eklenir.
-- DKAB 4 ve 8 için 2026-27 planı yok: bu sorular haritada "plan yok" olarak görünür, etiketlenemez.
insert into public.mufredat_ders_eslesme (soru_ders, mufredat_ders)
values ('Din Kültürü', 'Din Kültürü ve Ahlak Bilgisi')
on conflict (soru_ders) do nothing;
