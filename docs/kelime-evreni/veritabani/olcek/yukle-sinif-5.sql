begin;
select set_config('request.jwt.claims', json_build_object('sub', (select id from public.profiles where role = 'admin' order by id limit 1), 'role', 'authenticated')::text, true);
do $olcek$
declare v_id uuid; v_anlam uuid;
begin
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('soğumak', 'Sıcaklığı azalıp serinlemek.', 'kelime', 'fiil', 5, 5, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 5, null, '“Süt ocaktan alınınca soğumak için mutfakta bekletildi.” cümlesindeki “soğumak” sözcüğünün zıt anlamlısı hangisidir?', '["kurumak","ısınmak","donmak","titremek"]'::jsonb, 1, null, null, 'Soğumanın zıddı ısınmaktır. Kurumak, donmak ve titremek sıcaklığın artması anlamına gelmez.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('çay', 'Küçük akarsu, dere.', 'kelime', 'isim', 5, 5, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_sesli', 5, null, 'Aşağıdakilerden hangisinde “çay” sözcüğü küçük akarsu anlamında kullanılmıştır?', '["Kahvaltıda bir bardak sıcak çay içtik.","Annem demlediği çayı bardaklara doldurdu.","Köyün kenarından akan çayda ördekler yüzüyordu.","Çay bahçesinde oturup manzarayı izledik."]'::jsonb, 2, null, null, 'Üçüncü cümlede çay, akan küçük su anlamındadır. Diğerlerinde çay, içilen sıcak içecek veya onunla ilgili yerdir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ben', 'Deride bulunan küçük koyu lekedir.', 'kelime', 'isim', 5, 5, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_sesli', 5, null, 'Aşağıdakilerden hangisinde “ben” sözcüğü deride bulunan küçük koyu leke anlamında kullanılmıştır?', '["Ben bu akşam erkenden yatacağım.","Ben o kitabı geçen hafta bitirdim.","Ben yarın okula erken gideceğim.","Kardeşimin yanağında küçük bir ben var."]'::jsonb, 3, null, null, 'Son cümlede ben, deride bulunan lekedir. Diğerlerinde ben, konuşanı gösteren zamirdir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('titiz', 'Yaptığı işe çok özen gösteren.', 'kelime', 'sifat', 5, 5, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 5, null, '“Ressam, tablosundaki her çizgiyi günlerce kontrol edip düzeltecek kadar titizdi.” cümlesinde “titizdi” sözcüğü ne anlama gelir?', '["İşini yarım bırakan","Her şeye kolay kızan","Başkasına hep yardım eden","Yaptığı işe çok özen gösteren"]'::jsonb, 3, null, null, 'Her çizgiyi günlerce kontrol edip düzeltmek, işe çok özen göstermenin belirtisidir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('bitkin', 'Gücü tükenmiş, hâlsiz.', 'kelime', 'sifat', 5, 5, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 5, null, '“Uzun yürüyüşün sonunda bitkin düştü; ayakları tutmuyor, gözleri kapanıyordu.” cümlesinde “bitkin” sözcüğü ne anlama gelir?', '["Gücü tükenmiş","Çok sevinmiş","Biraz utanmış","Hemen kızmış"]'::jsonb, 0, null, null, 'Ayakların tutmaması ve gözlerin kapanması gücün tükendiğini gösterir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
end
$olcek$;
commit;