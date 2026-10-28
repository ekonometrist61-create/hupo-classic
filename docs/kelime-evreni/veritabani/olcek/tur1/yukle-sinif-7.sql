begin;
select set_config('request.jwt.claims', json_build_object('sub', (select id from public.profiles where role = 'admin' order by id limit 1), 'role', 'authenticated')::text, true);
do $olcek$
declare v_id uuid; v_anlam uuid;
begin
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('mahcup', 'Yaptığı bir şeyden dolayı utanç duyan.', 'kelime', 'sifat', 7, 7, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 7, null, '“Yanlış cevap verince mahcup oldu.” cümlesindeki “mahcup” sözcüğüyle eş anlamlı olan hangisidir?', '["utanmış","kızgın","şaşkın","yorgun"]'::jsonb, 0, null, null, 'Mahcup, utanç duyan demektir; kızgın, şaşkın ve yorgun başka duygu ya da durumları anlatır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('tereddüt', 'Karar verirken duraksama, ne yapacağını bilememe.', 'kelime', 'isim', 7, 7, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 7, null, '“Kapıyı çalmadan önce biraz tereddüt yaşadı.” cümlesindeki “tereddüt” sözcüğüyle eş anlamlı olan hangisidir?', '["korkaklık","kararsızlık","umursamazlık","sabırsızlık"]'::jsonb, 1, null, null, 'Tereddüt, karar verememe yani kararsızlıktır; diğer şıklar farklı davranış ya da duygulardır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('zorunlu', 'Mutlaka yapılması gereken.', 'kelime', 'sifat', 7, 7, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 7, null, '“Bu toplantıya katılmak zorunludur.” cümlesindeki “zorunlu” sözcüğüyle eş anlamlı olan hangisidir?', '["gönüllü","ücretli","mecburi","gereksiz"]'::jsonb, 2, null, null, 'Zorunlu ile mecburi aynı anlamdadır; gönüllü, ücretli ve gereksiz bu anlama gelmez.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('gayret', 'Bir işi başarmak için gösterilen çaba.', 'kelime', 'isim', 7, 7, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 7, null, '“Sınavdan önce büyük bir gayret gösterdi.” cümlesindeki “gayret” sözcüğüyle eş anlamlı olan hangisidir?', '["heves","sabır","umut","çaba"]'::jsonb, 3, null, null, 'Gayret çaba demektir; heves, sabır ve umut ilişkili ama eş anlamlı olmayan sözcüklerdir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('inkâr etmek', 'Bir şeyin doğru olduğunu kabul etmemek.', 'kelime', 'fiil', 7, 7, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 7, null, '“Suçunu inkâr etti.” cümlesindeki “inkâr etti” sözüyle eş anlamlı olan hangisidir?', '["yadsıdı","kabullendi","unuttu","hatırladı"]'::jsonb, 0, null, null, 'İnkâr etmek yadsımaktır; kabullenmek ters anlamlıdır, unutmak ve hatırlamak ise başka eylemlerdir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('yoksul', 'Geçimini zor sağlayan, parası az olan.', 'kelime', 'sifat', 7, 7, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 7, null, '“Yoksul ailelere yardım toplandı.” cümlesindeki “yoksul” sözcüğüyle eş anlamlı olan hangisidir?', '["cimri","fakir","yalnız","hasta"]'::jsonb, 1, null, null, 'Yoksul ile fakir aynı anlamdadır; cimri, yalnız ve hasta başka özellikleri anlatır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ender', 'Çok az bulunan, seyrek rastlanan.', 'kelime', 'sifat', 7, 7, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 7, null, '“Bu bitki ender bulunur.” cümlesindeki “ender” sözcüğüyle eş anlamlı olan hangisidir?', '["bol","doğal","nadir","zararlı"]'::jsonb, 2, null, null, 'Ender ile nadir çok az bulunan demektir; bol tam tersidir, doğal ve zararlı ilgisizdir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ihtiyaç', 'Bir şeye duyulan gereksinim.', 'kelime', 'isim', 7, 7, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 7, null, '“Bu iş için daha fazla zamana ihtiyaç var.” cümlesindeki “ihtiyaç” sözcüğüyle eş anlamlı olan hangisidir?', '["tasarruf","istek","fırsat","gereksinim"]'::jsonb, 3, null, null, 'İhtiyaç gereksinimdir; istek bir arzudur, zorunluluk anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('cömert', 'Elindekini isteyerek paylaşan.', 'kelime', 'sifat', 7, 7, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 7, null, '“Komşumuz çok cömert biridir.” cümlesindeki “cömert” sözcüğünün zıt anlamlısı hangisidir?', '["cimri","yoksul","hırslı","kibar"]'::jsonb, 0, null, null, 'Cömert paylaşan, cimri paylaşmayan kişidir; yoksul, hırslı ve kibar zıt anlamlı değildir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('geçici', 'Kısa süre devam eden.', 'kelime', 'sifat', 7, 7, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 7, null, '“Bu çözüm geçici bir önlemdir.” cümlesindeki “geçici” sözcüğünün zıt anlamlısı hangisidir?', '["kısa","kalıcı","ani","gizli"]'::jsonb, 1, null, null, 'Geçici olanın zıddı kalıcı olandır; kısa ona yakın anlamlıdır, ani ve gizli ilgisizdir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('tehlikeli', 'Zarar verme ihtimali olan.', 'kelime', 'sifat', 7, 7, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 7, null, '“Bu yol oldukça tehlikeli.” cümlesindeki “tehlikeli” sözcüğünün zıt anlamlısı hangisidir?', '["dar","uzun","güvenli","ıssız"]'::jsonb, 2, null, null, 'Tehlikeli olanın zıddı güvenli olandır; dar, uzun ve ıssız yolun başka özellikleridir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('somut', 'Duyularla algılanabilen, gözle görülebilen.', 'kelime', 'sifat', 7, 7, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 7, null, '“Konuyu somut bir örnekle anlattı.” cümlesindeki “somut” sözcüğünün zıt anlamlısı hangisidir?', '["soyut","gerçek","açık","kısa"]'::jsonb, 0, null, null, 'Somutun zıddı soyuttur; gerçek ve açık somuta yakın ya da ilgisizdir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ben', 'Ciltte bulunan küçük koyu leke.', 'kelime', 'isim', 7, 7, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_sesli', 7, null, 'Aşağıdakilerden hangisinde “ben” sözcüğü ciltteki küçük koyu leke anlamında kullanılmıştır?', '["Bu işi yarın ben bitireceğim.","Yanağındaki ben onu sevimli gösteriyordu.","Ben bu şarkıyı daha önce dinlemiştim.","Ben her sabah yürüyüşe çıkarım."]'::jsonb, 1, null, null, 'İkinci cümlede ben, ciltteki leke anlamındadır; diğerlerinde kişi zamiridir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('yaz', 'Yılın sıcak mevsimi.', 'kelime', 'isim', 7, 7, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_sesli', 7, null, 'Aşağıdakilerden hangisinde “yaz” sözcüğü mevsim anlamında kullanılmıştır?', '["Adını kâğıdın köşesine yaz.","Cevabını tahtaya kendin yaz.","Yaz tatilinde deniz kenarına gideceğiz.","Notlarını deftere düzgünce yaz."]'::jsonb, 2, null, null, 'Üçüncü cümlede yaz, mevsim adıdır; diğerlerinde yazmak eyleminin emir biçimidir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('al', 'Kırmızı renk.', 'kelime', 'sifat', 7, 7, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_sesli', 7, null, 'Aşağıdakilerden hangisinde “al” sözcüğü kırmızı renk anlamında kullanılmıştır?', '["Çantanı al da hemen yola çık.","Market listesini al ve eve gel.","Bu defteri al, ödevini bitir.","Al bayrak rüzgârda dalgalandı."]'::jsonb, 3, null, null, 'Dördüncü cümlede al, renk bildirir; diğerlerinde almak eyleminin emir biçimidir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('gül', 'Güzel kokulu, dikenli bir çiçek.', 'kelime', 'isim', 7, 7, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_sesli', 7, null, 'Aşağıdakilerden hangisinde “gül” sözcüğü bir çiçek adı olarak kullanılmıştır?', '["Bahçedeki kırmızı gül çok güzel kokuyordu.","Komik sahneyi görünce yüksek sesle gül.","Sıkıntını unut da biraz gül.","Mutlu olunca içinden gelerek gül."]'::jsonb, 0, null, null, 'İlk cümlede gül çiçek adıdır; diğerlerinde gülmek eyleminin emir biçimidir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('göz yummak', 'Bir yanlışı görmezden gelmek.', 'deyim', null, 7, 7, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 7, null, '“Yöneticinin bu hataya göz yumması herkesi şaşırttı.” cümlesindeki “göz yummak” deyimi ne anlama gelir?', '["Bir yanlışı hemen düzeltmek","Bir kusuru yüksek sesle söylemek","Bir yanlışı görmezden gelmek","Bir işi gözetim altında tutmak"]'::jsonb, 2, null, null, 'Göz yummak, yanlışı görmezden gelmektir; diğer şıklar yanlışa tepki vermeyi anlatır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('burnu büyümek', 'Başarı ya da övgü yüzünden kibirlenmek.', 'deyim', null, 7, 7, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 7, null, '“Birinci olunca burnu büyüdü.” cümlesindeki “burnu büyümek” deyimi ne anlama gelir?', '["utanmak","kibirlenmek","yorulmak","heyecanlanmak"]'::jsonb, 1, null, null, 'Burnu büyümek, kibirlenmek demektir; diğer şıklar bu deyimin anlamı değildir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ipin ucunu kaçırmak', 'Bir işin kontrolünü kaybetmek.', 'deyim', null, 7, 7, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 7, null, '“Konuşmaya ara verince ipin ucunu kaçırdı.” cümlesindeki “ipin ucunu kaçırmak” deyimi ne anlama gelir?', '["Zor bir işe başlamak","Sorunu çabuk çözmek","İşin kontrolünü kaybetmek","Sözünü geri almak"]'::jsonb, 2, null, null, 'İpin ucunu kaçırmak, işin gidişini kontrol edememektir; diğer şıklar bu anlama uymaz.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kulak vermek', 'Söyleneni dikkatle dinlemek.', 'deyim', null, 7, 7, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 7, null, '“Arkadaşının derdine kulak verdi.” cümlesindeki “kulak vermek” deyimi ne anlama gelir?', '["sesini yükseltmek","sözü kesmek","uzaktan izlemek","dikkatle dinlemek"]'::jsonb, 3, null, null, 'Kulak vermek, dikkatle dinlemektir; diğer şıklar dinlemenin tersi ya da farklı davranışlardır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ağzı kulaklarına varmak', 'Çok sevinmek.', 'deyim', null, 7, 7, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 7, null, '“Karnesini görünce ağzı kulaklarına vardı.” cümlesindeki “ağzı kulaklarına varmak” deyimi ne anlama gelir?', '["çok şaşırmak","çok sevinmek","çok korkmak","çok utanmak"]'::jsonb, 1, null, null, 'Ağzı kulaklarına varmak, çok sevinip gülümsemektir; diğer duygular bu deyimle anlatılmaz.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('baş başa vermek', 'Bir sorunu çözmek için bir araya gelip birlikte düşünmek.', 'deyim', null, 7, 7, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 7, null, '“Sorunu çözmek için baş başa verdiler.” cümlesindeki “baş başa vermek” deyimi ne anlama gelir?', '["birlikte çalışmak","yarışmaya girmek","kavga etmek","kısa süre dinlenmek"]'::jsonb, 0, null, null, 'Baş başa vermek, birlikte çalışıp düşünmektir; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Damlaya damlaya göl olur.', 'Küçük birikimler zamanla büyür.', 'atasozu', null, 7, 7, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 7, null, '“Damlaya damlaya göl olur.” atasözü aşağıdakilerden hangisini anlatır?', '["Küçük birikimler zamanla büyür.","Sabırsız olanlar işini yarım bırakır.","Büyük işler yalnız kalabalıkla yapılır.","Çok yağan yağmur her şeyi çözer."]'::jsonb, 0, null, null, 'Atasözü, azın azın biriktiğinde çok olacağını söyler; diğer şıklar başka düşüncelerdir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Ayağını yorganına göre uzat.', 'Harcamayı gelirine göre yapmak.', 'atasozu', null, 7, 7, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 7, null, '“Ayağını yorganına göre uzat.” atasözü aşağıdakilerden hangisini anlatır?', '["Soğuk havada üşümemeye dikkat et.","İş yaparken acele etmemelisin.","Harcamalarını elindeki imkâna göre yapmalısın.","Her zaman başkalarının yanında rahat davran."]'::jsonb, 2, null, null, 'Atasözü, gelire göre harcamayı öğütler; diğer şıklar yorgan ve ayağı yalnız harfi harfine yorumlar.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Bir elin nesi var, iki elin sesi var.', 'Birlikte çalışmak işi kolaylaştırır.', 'atasozu', null, 7, 7, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 7, null, '“Bir elin nesi var, iki elin sesi var.” atasözü aşağıdakilerden hangisini anlatır?', '["Her işi tek başına yapmak gerekir.","Çok konuşan çok iş başarır.","Alkış tutmak için iki el yeter.","Birlikte çalışmak işi kolaylaştırır."]'::jsonb, 3, null, null, 'Atasözü, iş birliğinin gücünü anlatır; diğer şıklar bunun tersi ya da ilgisizdir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('hemen', 'Gecikmeden, vakit geçirmeden.', 'kelime', 'zarf', 7, 7, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'sozcuk_turu', 7, null, '“Hemen eve döndü.” cümlesindeki “hemen” sözcüğünün türü hangisidir?', '["zarf","sıfat","isim","fiil"]'::jsonb, 0, null, null, 'Hemen, eylemin zamanını bildiren bir zarftır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ve', 'Eş görevli sözcükleri bağlayan sözcük.', 'kelime', 'baglac', 7, 7, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'sozcuk_turu', 7, null, '“Elma ve armut aldım.” cümlesindeki “ve” sözcüğünün türü hangisidir?', '["zamir","bağlaç","edat","zarf"]'::jsonb, 1, null, null, 'Ve, iki sözcüğü birbirine bağlayan bir bağlaçtır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('için', 'Amaç ya da neden bildiren ilgeç.', 'kelime', 'edat', 7, 7, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'sozcuk_turu', 7, null, '“Sınav için çok çalıştı.” cümlesindeki “için” sözcüğünün türü hangisidir?', '["bağlaç","sıfat","edat","zamir"]'::jsonb, 2, null, null, 'İçin, bir sözcükle birlikte amaç bildiren edattır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('özgürlük', 'Baskı altında olmama durumu.', 'kelime', 'isim', 7, 7, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'sozcuk_turu', 7, null, '“Özgürlük her insanın en doğal hakkıdır.” cümlesindeki “özgürlük” sözcüğünün türü hangisidir?', '["sıfat","zarf","fiil","isim"]'::jsonb, 3, null, null, 'Özgürlük soyut bir varlığı adlandırır; bu nedenle isimdir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ah', 'Duygu bildiren seslenme sözcüğü.', 'kelime', 'unlem', 7, 7, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'sozcuk_turu', 7, null, '“Ah, ne güzel bir manzara!” cümlesindeki “ah” sözcüğünün türü hangisidir?', '["edat","ünlem","zamir","bağlaç"]'::jsonb, 1, null, null, 'Ah, hayranlık duygusunu anlatan bir ünlemdir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kendisi', 'Kişinin bizzat kendisini gösteren sözcük.', 'kelime', 'zamir', 7, 7, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'sozcuk_turu', 7, null, '“Kendisi yarın toplantıya gelecek.” cümlesindeki “kendisi” sözcüğünün türü hangisidir?', '["zamir","isim","sıfat","fiil"]'::jsonb, 0, null, null, 'Kendisi, bir ismin yerini tutan zamirdir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('azim', 'Bir işi sonuna kadar sürdürme kararlılığı.', 'kelime', 'isim', 7, 7, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 7, null, '“Dağcılar tırmanış boyunca yılmaz bir azimle yürüdü; hiçbir zorluk onları vazgeçirmedi.” cümlesindeki “azim” sözcüğü ne anlama gelir?', '["kararlılık","yorgunluk","telaş","merak"]'::jsonb, 0, null, null, 'Zorluklara rağmen vazgeçmemek kararlılığı anlatır; diğer şıklar bağlama uymaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('mütevazı', 'Başarısıyla övünmeyen, alçakgönüllü.', 'kelime', 'sifat', 7, 7, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 7, null, '“Büyük bir başarı kazanmasına rağmen hep mütevazı kaldı; kendisinden hiç övünerek söz etmedi.” cümlesindeki “mütevazı” sözcüğü ne anlama gelir?', '["kıskanç","alçakgönüllü","titiz","sabırsız"]'::jsonb, 1, null, null, 'Övünmemek alçakgönüllülüktür; diğer şıklar cümleyle ilgisizdir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ıssız', 'İnsanın bulunmadığı, tenha.', 'kelime', 'sifat', 7, 7, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 7, null, '“Köyün dışındaki ıssız yolda ne bir ev ne de bir insan görülüyordu.” cümlesindeki “ıssız” sözcüğü ne anlama gelir?', '["dik","aydınlık","tenha","tozlu"]'::jsonb, 2, null, null, 'Ev ve insan görülmemesi yolun tenha olduğunu gösterir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ürkek', 'Kolay korkan, çekingen.', 'kelime', 'sifat', 7, 7, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 7, null, '“Ürkek hayvan, yabancı birini görünce hemen saklandı.” cümlesindeki “ürkek” sözcüğü ne anlama gelir?', '["hızlı","açgözlü","çevik","korkak"]'::jsonb, 3, null, null, 'Yabancıdan hemen saklanmak kolay korkmayı gösterir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('titiz', 'Her ayrıntıya özen gösteren.', 'kelime', 'sifat', 7, 7, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 7, null, '“Terzi, dikişin her ayrıntısına dikkat eden titiz biriydi; en küçük bir kusuru bile düzeltirdi.” cümlesindeki “titiz” sözcüğü ne anlama gelir?', '["tembel","özenli","neşeli","telaşlı"]'::jsonb, 1, null, null, 'Her ayrıntıyla ilgilenip kusuru düzeltmek özenli olmayı anlatır.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kıt', 'Az bulunan, yetersiz.', 'kelime', 'sifat', 7, 7, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 7, null, '“Kuraklık yüzünden bu yıl su kıt; herkes çok az su kullanmak zorunda kaldı.” cümlesindeki “kıt” sözcüğü ne anlama gelir?', '["yetersiz","bol","kirli","soğuk"]'::jsonb, 0, null, null, 'Herkesin az su kullanmak zorunda kalması suyun yetersiz olduğunu gösterir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
end
$olcek$;
commit;