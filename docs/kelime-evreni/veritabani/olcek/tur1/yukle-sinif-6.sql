begin;
select set_config('request.jwt.claims', json_build_object('sub', (select id from public.profiles where role = 'admin' order by id limit 1), 'role', 'authenticated')::text, true);
do $olcek$
declare v_id uuid; v_anlam uuid;
begin
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('titizlikle', 'Büyük özen göstererek, ayrıntıya dikkat ederek.', 'kelime', 'zarf', 6, 6, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 6, null, '“Kardeşim odasını titizlikle topladı.” cümlesindeki “titizlikle” sözcüğüyle eş anlamlı olan hangisidir?', '["özenle","aceleyle","isteksizce","gürültüyle"]'::jsonb, 0, null, null, 'Titizlikle, özenle demektir. Aceleyle zıt yönlü, isteksizce ve gürültüyle ise anlamca ilgisizdir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('cesur', 'Korkmadan zor işlerin üstesinden gelmeye çalışan.', 'kelime', 'sifat', 6, 6, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 6, null, '“Cesur bir dağcı uçuruma sarkan arkadaşına yardıma koştu.” cümlesindeki “cesur” sözcüğüyle eş anlamlı olan hangisidir?', '["telaşlı","yürekli","utangaç","kıskanç"]'::jsonb, 1, null, null, 'Cesur ile yürekli aynı anlama gelir. Telaşlı, utangaç ve kıskanç farklı özellikleri anlatır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('mükemmel', 'Hiçbir eksiği ya da kusuru olmayan.', 'kelime', 'sifat', 6, 6, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 6, null, '“Ressam mükemmel bir tablo çizdi.” cümlesindeki “mükemmel” sözcüğüyle eş anlamlı olan hangisidir?', '["sıradan","soluk","kusursuz","karışık"]'::jsonb, 2, null, null, 'Mükemmel ve kusursuz eksiği olmayan demektir. Diğer şıklar tablonun başka özelliklerini anlatır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kolay', 'Yapması ya da anlaması zahmet gerektirmeyen.', 'kelime', 'sifat', 6, 6, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 6, null, '“Bu bulmaca bana oldukça kolay geldi.” cümlesindeki “kolay” sözcüğüyle eş anlamlı olan hangisidir?', '["zor","uzun","ağır","basit"]'::jsonb, 3, null, null, 'Kolay ile basit eş anlamlıdır. Zor, kolayın karşıtıdır; uzun ve ağır ilgisizdir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('bitkin', 'Gücü tükenmiş, çok yorulmuş.', 'kelime', 'sifat', 6, 6, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 6, null, '“Uzun yürüyüşten sonra bitkin düştük.” cümlesindeki “bitkin” sözcüğüyle eş anlamlı olan hangisidir?', '["neşeli","hevesli","öfkeli","yorgun"]'::jsonb, 3, null, null, 'Bitkin, çok yorgun demektir. Neşeli, hevesli ve öfkeli ruh hâlini anlatır, yorgunlukla ilgili değildir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kararlı', 'Yapmak istediğinden vazgeçmeyen, kesin karar vermiş.', 'kelime', 'sifat', 6, 6, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 6, null, '“Dağcılar zirveye çıkmakta kararlıydı.” cümlesindeki “kararlı” sözcüğüyle eş anlamlı olan hangisidir?', '["kırgın","çekingen","azimli","şüpheli"]'::jsonb, 2, null, null, 'Kararlı ile azimli, vazgeçmeyen anlamında eş anlamlıdır. Çekingen ve şüpheli ters yöndedir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kocaman', 'Çok büyük.', 'kelime', 'sifat', 6, 6, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 6, null, '“Bahçemizde kocaman bir ağaç var.” cümlesindeki “kocaman” sözcüğüyle eş anlamlı olan hangisidir?', '["minik","devasa","ince","genç"]'::jsonb, 1, null, null, 'Kocaman ile devasa çok büyük demektir. Minik karşıtıdır; ince ve genç büyüklükle ilgili değildir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('geniş', 'Yan yana ölçüsü büyük olan, yer bakımından bol.', 'kelime', 'sifat', 6, 6, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 6, null, '“Evin önünden geniş bir yol geçiyordu.” cümlesindeki “geniş” sözcüğünün zıt anlamlısı hangisidir?', '["uzun","dar","derin","yüksek"]'::jsonb, 1, null, null, 'Geniş sözcüğünün zıddı dardır. Uzun, derin ve yüksek başka boyutları anlatır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('yaygın', 'Çok yerde görülen, sık rastlanan.', 'kelime', 'sifat', 6, 6, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 6, null, '“Bu böcek bölgemizde çok yaygındır.” cümlesindeki “yaygın” sözcüğünün zıt anlamlısı hangisidir?', '["bol","çeşitli","nadir","değerli"]'::jsonb, 2, null, null, 'Yaygın sık görülen, nadir ise seyrek rastlanan demektir. Bol, yaygına yakındır; çeşitli ve değerli zıt değildir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('onaylamak', 'Bir öneriye ya da isteğe uygun bulduğunu bildirmek.', 'kelime', 'fiil', 6, 6, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 6, null, '“Müdür, öğrencilerin önerisini onaylamak istedi.” cümlesindeki “onaylamak” sözcüğünün zıt anlamlısı hangisidir?', '["dinlemek","saklamak","bölmek","reddetmek"]'::jsonb, 3, null, null, 'Onaylamanın zıddı reddetmektir. Dinlemek, saklamak ve bölmek kabul ya da ret anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('başlangıç', 'Bir şeyin ilk bölümü, başladığı yer.', 'kelime', 'isim', 6, 6, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 6, null, '“Hikâyenin başlangıç bölümü çok heyecanlıydı.” cümlesindeki “başlangıç” sözcüğünün zıt anlamlısı hangisidir?', '["bitiş","orta","ara","devam"]'::jsonb, 0, null, null, 'Başlangıcın zıddı bitiştir. Orta, ara ve devam başlangıcın karşıtı değildir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('tembel', 'Çalışmayı sevmeyen, işi savsaklayan.', 'kelime', 'sifat', 6, 6, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 6, null, '“Tembel bir öğrenci ödevini hep son güne bıraktı.” cümlesindeki “tembel” sözcüğünün zıt anlamlısı hangisidir?', '["uykucu","çalışkan","utangaç","sessiz"]'::jsonb, 1, null, null, 'Tembelin zıddı çalışkandır. Uykucu tembele yakındır; utangaç ve sessiz ilgisizdir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kalabalık', 'Çok sayıda insanın bulunduğu, dolu.', 'kelime', 'sifat', 6, 6, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 6, null, '“Pazar yeri bugün çok kalabalıktı.” cümlesindeki “kalabalık” sözcüğünün zıt anlamlısı hangisidir?', '["gürültülü","renkli","tenha","dar"]'::jsonb, 2, null, null, 'Kalabalığın zıddı tenhadır. Gürültülü, renkli ve dar kişi sayısını anlatmaz.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('geçici', 'Kısa süre kalan, kalıcı olmayan.', 'kelime', 'sifat', 6, 6, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 6, null, '“Bu boya yüzeyde geçici bir iz bırakır.” cümlesindeki “geçici” sözcüğünün zıt anlamlısı hangisidir?', '["silik","hafif","ince","kalıcı"]'::jsonb, 3, null, null, 'Geçicinin zıddı kalıcıdır. Silik geçiciye yakındır; hafif ve ince zıt değildir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kuru', 'İçinde su ya da nem bulunmayan.', 'kelime', 'sifat', 6, 6, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 6, null, '“Balkondaki çamaşırlar artık kuruydu.” cümlesindeki “kuru” sözcüğünün zıt anlamlısı hangisidir?', '["ıslak","soğuk","temiz","ince"]'::jsonb, 0, null, null, 'Kurunun zıddı ıslaktır. Soğuk, temiz ve ince nemle ilgili değildir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('dolu', 'Havadaki suyun buz tanesi olarak yağması.', 'kelime', 'isim', 6, 6, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_sesli', 6, null, 'Aşağıdakilerden hangisinde “dolu” sözcüğü yağış anlamında kullanılmıştır?', '["Bardak çok dolu olduğu için dikkatle taşıdım.","Gece yağan dolu bahçedeki çiçekleri ezdi.","Sepet elmalarla dolu olduğundan çok ağırdı.","Otobüs sabah saatinde yolcularla dolu geldi."]'::jsonb, 1, null, null, 'İkinci cümlede dolu, buz tanesi hâlinde yağan yağıştır. Diğerlerinde dolu, içi dolmuş anlamındadır.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('göz yummak', 'Bir hatayı bilerek görmezden gelmek.', 'deyim', null, 6, 6, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 6, null, '“Annesi, küçük kardeşinin yaptığı yaramazlığa göz yumdu.” cümlesindeki “göz yummak” deyimi ne anlama gelir?', '["çok dikkatle incelemek","kızarak uyarmak","bilerek görmezden gelmek","gizlice haber vermek"]'::jsonb, 2, null, null, 'Göz yummak, bir hatayı bile bile görmezden gelmektir. Diğer şıklar bu davranışı anlatmaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kulak asmak', 'Söylenene değer verip dikkate almak.', 'deyim', null, 6, 6, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 6, null, '“Dedem, doktorun öğütlerine kulak asmadı.” cümlesindeki “kulak asmak” deyimi ne anlama gelir?', '["dinleyip önemsemek","sessizce izlemek","yüksek sesle konuşmak","hemen unutmak"]'::jsonb, 0, null, null, 'Kulak asmak, söylenene önem verip dikkate almaktır; cümlede olumsuz kullanılmıştır. Diğer şıklar anlamı karşılamaz.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('dilinin ucunda olmak', 'Bildiği bir şeyi o anda hatırlayamamak.', 'deyim', null, 6, 6, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 6, null, '“Cevabı biliyordum ama tam o anda dilimin ucundaydı.” cümlesindeki “dilinin ucunda olmak” deyimi ne anlama gelir?', '["sürekli aynı şeyi söylemek","çok yüksek sesle konuşmak","bir sırrı herkese anlatmak","bildiği hâlde hatırlayamamak"]'::jsonb, 3, null, null, 'Dilinin ucunda olmak, bilinen şeyi o an hatırlayamamaktır. Diğer şıklar konuşma biçimini anlatır.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ayak uydurmak', 'Çevreye ve yeni duruma uyum sağlamak.', 'deyim', null, 6, 6, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 6, null, '“Yeni okulun kurallarına ayak uydurmakta zorlanmadı.” cümlesindeki “ayak uydurmak” deyimi ne anlama gelir?', '["kuralları sürekli değiştirmek","her yere geç gitmek","yeni duruma uyum sağlamak","başkalarını yalnız bırakmak"]'::jsonb, 2, null, null, 'Ayak uydurmak, çevreye ve yeni duruma uyum sağlamaktır. Diğer şıklar anlamı karşılamaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('gözü pek', 'Korkusuz, atılgan.', 'deyim', null, 6, 6, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 6, null, '“Gözü pek bir dağcı sarp kayalıkları tek başına tırmandı.” cümlesindeki “gözü pek” deyimi ne anlama gelir?', '["yavaş ve dikkatli","korkusuz ve atılgan","gözleri iyi gören","uykusuz ve yorgun"]'::jsonb, 1, null, null, 'Gözü pek, korkusuz ve atılgan demektir. Diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Üzüm üzüme baka baka kararır.', 'İnsan, birlikte olduğu kişilere benzer.', 'atasozu', null, 6, 6, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 6, null, '“Üzüm üzüme baka baka kararır.” atasözü hangi anlamı taşır?', '["Meyveler güneşte çabuk olgunlaşır.","İnsanlar çevresindekilere benzer.","Çok bakan kişi çok öğrenir.","Bağ işleri sonbaharda yapılır."]'::jsonb, 1, null, null, 'Atasözü, insanın çevresindekilerden etkilendiğini anlatır. Diğer şıklar anlamı karşılamaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Ayağını yorganına göre uzat.', 'Harcamayı elindeki imkâna göre yap.', 'atasozu', null, 6, 6, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 6, null, '“Ayağını yorganına göre uzat.” atasözü ile verilmek istenen öğüt hangisidir?', '["Soğuk havada sıkı giyinmelisin.","Uyumadan önce yatağını toplamalısın.","Her zaman büyük hedefler koymalısın.","Harcamanı elindeki imkâna göre yapmalısın."]'::jsonb, 3, null, null, 'Atasözü, gelire göre harcama yapmayı öğütler. Diğer şıklar sözcüklerin gerçek anlamına dayanır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Bir elin nesi var, iki elin sesi var.', 'Birlikte çalışmak işi kolaylaştırır.', 'atasozu', null, 6, 6, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 6, null, '“Bir elin nesi var, iki elin sesi var.” atasözü hangi durumu anlatır?', '["Birlikte çalışmak işleri kolaylaştırır.","Her işi yalnız yapmak daha hızlıdır.","Ellerini sık sık yıkamak gerekir.","Kalabalık yerde sessiz kalmalıdır."]'::jsonb, 0, null, null, 'Atasözü, iş birliğinin gücünü anlatır. Diğer şıklar bu anlamla ilgisizdir ya da tersini söyler.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Sakla samanı, gelir zamanı.', 'Bugünkü birikim ileride işe yarar.', 'atasozu', null, 6, 6, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 6, null, '“Sakla samanı, gelir zamanı.” atasözü hangi anlamı taşır?', '["Eskiyen eşyaları hemen atmalısın.","Çok bekleyen kişi hep kaybeder.","Bugünkü birikim ileride işe yarar.","Saman da altın kadar değerlidir."]'::jsonb, 2, null, null, 'Atasözü, bugün biriktirilenin ileride gerekli olacağını anlatır. Diğer şıklar anlamı karşılamaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('hızla', 'Çabuk, süratle.', 'kelime', 'zarf', 6, 6, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'sozcuk_turu', 6, null, '“Kuş dalından hızla havalandı.” cümlesindeki “hızla” sözcüğünün türü hangisidir?', '["isim","sıfat","fiil","zarf"]'::jsonb, 3, null, null, 'Hızla, havalandı eylemini nasıl sorusuyla niteler; bu yüzden zarftır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('yüksek', 'Yerden yukarıya doğru uzunluğu fazla olan.', 'kelime', 'sifat', 6, 6, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'sozcuk_turu', 6, null, '“Yüksek dağın zirvesine tırmandık.” cümlesindeki “yüksek” sözcüğünün türü hangisidir?', '["isim","sıfat","fiil","zarf"]'::jsonb, 1, null, null, 'Yüksek, “dağ” adını niteler; bu yüzden sıfattır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('okudu', 'Yazılı bir metni gözle ya da sesle izledi.', 'kelime', 'fiil', 6, 6, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'sozcuk_turu', 6, null, '“Kütüphanede sessizce okudu.” cümlesindeki “okudu” sözcüğünün türü hangisidir?', '["isim","sıfat","zarf","fiil"]'::jsonb, 3, null, null, 'Okudu, bir iş ve oluş bildirir; bu yüzden fiildir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kedi', 'Evlerde beslenen, tüylü ve dört ayaklı hayvan.', 'kelime', 'isim', 6, 6, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'sozcuk_turu', 6, null, '“Bahçedeki kedi süt içti.” cümlesindeki “kedi” sözcüğünün türü hangisidir?', '["isim","zarf","fiil","zamir"]'::jsonb, 0, null, null, 'Kedi, bir canlıyı adlandırır; bu yüzden isimdir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ama', 'İki cümleyi karşıtlık ilişkisiyle bağlayan sözcük.', 'kelime', 'baglac', 6, 6, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'sozcuk_turu', 6, null, '“Çok çalıştı ama sınavı kazanamadı.” cümlesindeki “ama” sözcüğünün türü hangisidir?', '["zarf","bağlaç","edat","zamir"]'::jsonb, 1, null, null, 'Ama, iki cümleyi karşıtlıkla bağlar; bu yüzden bağlaçtır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kimse', 'Belirsiz bir kişiyi gösteren sözcük.', 'kelime', 'zamir', 6, 6, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'sozcuk_turu', 6, null, '“Kimse bu soruyu çözemedi.” cümlesindeki “kimse” sözcüğünün türü hangisidir?', '["isim","sıfat","fiil","zamir"]'::jsonb, 3, null, null, 'Kimse, bir ismin yerini tutar ve belirsiz bir kişiyi gösterir; bu yüzden zamirdir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ihtiyatlı', 'Tehlikeden sakınarak dikkatle davranan.', 'kelime', 'sifat', 6, 6, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 6, null, '“Dağcı, buzlu yamaçta ihtiyatlı davrandı; her adımını önce yoklayıp sonra attı.” cümlesindeki “ihtiyatlı” sözcüğü ne anlama gelir?', '["hızlı","dikkatli","neşeli","yorgun"]'::jsonb, 1, null, null, 'Her adımı önce yoklamak, dikkatli olmayı gösterir. İhtiyatlı, dikkatli demektir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kadim', 'Çok eski zamandan kalan.', 'kelime', 'sifat', 6, 6, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 6, null, '“Yaşlı balıkçı kadim bir şarkı söylüyordu; bu şarkı yüzlerce yıl önce dedelerinden kalmıştı.” cümlesindeki “kadim” sözcüğü ne anlama gelir?', '["çok yeni","çok kısa","çok sesli","çok eski"]'::jsonb, 3, null, null, 'Şarkının yüzlerce yıl önceden kalması çok eski olduğunu gösterir. Kadim, çok eski demektir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('bitap', 'Gücü kalmamış, çok yorgun.', 'kelime', 'sifat', 6, 6, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 6, null, '“Uzun yolculukta bitap düştük; ayaklarımız artık bizi taşımıyordu.” cümlesindeki “bitap” sözcüğü ne anlama gelir?', '["çok neşeli","çok aç","çok sinirli","çok yorgun"]'::jsonb, 3, null, null, 'Ayakların taşımaması aşırı yorgunluğu gösterir. Bitap, çok yorgun demektir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
end
$olcek$;
commit;