begin;
select set_config('request.jwt.claims', json_build_object('sub', (select id from public.profiles where role = 'admin' order by id limit 1), 'role', 'authenticated')::text, true);
do $olcek$
declare v_id uuid; v_anlam uuid;
begin
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('özlem', 'Uzakta olan birini ya da bir şeyi görmek isteme duygusu.', 'kelime', 'isim', 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 4, null, '“Yazın uzaktaki kardeşime duyduğum özlem her gün arttı.” cümlesindeki “özlem” sözcüğüyle eş anlamlı olan hangisidir?', '["utanç","merak","öfke","hasret"]'::jsonb, 3, null, null, 'Özlem ve hasret aynı duyguyu anlatır; utanç, merak ve öfke başka duygulardır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('bin', 'yüz sayısının on katı', 'kelime', 'isim', 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_sesli', 4, null, 'Aşağıdakilerden hangisinde “bin” sözcüğü yüz sayısının on katı anlamında kullanılmıştır?', '["Otobüse bin ve arka koltuğa otur.","Kütüphanede bin kitaptan fazlası var.","Bu güçlü ata bin ve yavaşça yürü.","Sabah servise bin ve okula git."]'::jsonb, 1, null, null, 'İkinci cümlede bin bir sayıdır; diğerlerinde bin, binmek eyleminin emir biçimidir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Gülü seven dikenine katlanır.', 'İstenen bir şey için çıkan zorluklara razı olmak gerekir.', 'atasozu', null, 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 4, null, '“Gülü seven dikenine katlanır.” atasözü hangi durumu anlatır?', '["Çiçekler yalnızca bahar mevsiminde açar.","Dikenli bitkilere asla dokunmamak gerekir.","Güzel şeyler hiç emek vermeden elde edilir.","İstenen bir şey için zorluğa razı olunur."]'::jsonb, 3, null, null, 'Bu söz, istenen bir şeye ulaşmak için zorluklara razı olmak gerektiğini anlatır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
end
$olcek$;
commit;