begin;
select set_config('request.jwt.claims', json_build_object('sub', (select id from public.profiles where role = 'admin' order by id limit 1), 'role', 'authenticated')::text, true);
do $olcek$
declare v_id uuid; v_anlam uuid;
begin
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('dost', 'Güvenilen, sevilen yakın kişi.', 'kelime', 'isim', 5, 5, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 5, null, '“Zor günlerinde yanında olan sadık bir dost bulmuştu.” cümlesindeki “dost” sözcüğüyle eş anlamlı olan hangisidir?', '["arkadaş","komşu","akraba","yabancı"]'::jsonb, 0, null, null, 'Dost ile arkadaş yakın anlamlıdır. Komşu ve akraba yakınlık bildirir ama aynı şey değildir; yabancı ise karşıt anlamlıdır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('fakir', 'Geçimini zor sağlayan, parası az olan.', 'kelime', 'sifat', 5, 5, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 5, null, '“Köydeki fakir aileye kışlık odun götürdük.” cümlesindeki “fakir” sözcüğüyle eş anlamlı olan hangisidir?', '["zengin","yoksul","yorgun","kalabalık"]'::jsonb, 1, null, null, 'Fakir ile yoksul aynı anlamdadır. Zengin zıt anlamlıdır; yorgun ve kalabalık anlamca ilgisizdir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('azim', 'Bir işi bırakmadan sürdürme isteği.', 'kelime', 'isim', 5, 5, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 5, null, '“Dağın tepesine çıkmak büyük bir azim gerektirdi.” cümlesindeki “azim” sözcüğüyle eş anlamlı olan hangisidir?', '["tembellik","korku","kararlılık","merak"]'::jsonb, 2, null, null, 'Azim, kararlılık demektir. Tembellik karşıt, korku ve merak ilgisiz duygulardır.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('yardım', 'Zor durumdaki birine destek olma.', 'kelime', 'isim', 5, 5, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 5, null, '“Zor anımda komşularımın yardımı çok işe yaradı.” cümlesindeki “yardımı” sözcüğüyle eş anlamlı olan hangisidir?', '["engel","ceza","ödül","destek"]'::jsonb, 3, null, null, 'Yardım ile destek yakın anlamlıdır. Engel karşıt; ceza ve ödül ilgisizdir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('sakin', 'Dalgasız, durgun, huzurlu.', 'kelime', 'sifat', 5, 5, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 5, null, '“Fırtınadan sonra deniz çok sakindi.” cümlesindeki “sakindi” sözcüğüyle eş anlamlı olan hangisidir?', '["dingin","dalgalı","derin","soğuk"]'::jsonb, 0, null, null, 'Sakin ile dingin durgunluk bildirir. Dalgalı karşıt anlamlıdır; derin ve soğuk başka özelliklerdir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('imkân', 'Bir şeyi yapmaya elverişli durum.', 'kelime', 'isim', 5, 5, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 5, null, '“Okulumuzda bilgisayar kullanma imkânı vardı.” cümlesindeki “imkânı” sözcüğüyle eş anlamlı olan hangisidir?', '["zorunluluk","olanak","yasak","merak"]'::jsonb, 1, null, null, 'İmkân, olanak demektir. Zorunluluk ve yasak karşıt yönde, merak ilgisizdir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('zahmet', 'Bir iş için çekilen güçlük ve emek.', 'kelime', 'isim', 5, 5, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 5, null, '“Eski kitapları rafa dizmek büyük zahmet istedi.” cümlesindeki “zahmet” sözcüğüyle eş anlamlı olan hangisidir?', '["kazanç","eğlence","güçlük","fırsat"]'::jsonb, 2, null, null, 'Zahmet, güçlük ve emek demektir. Kazanç, eğlence ve fırsat bu anlamı taşımaz.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('mesele', 'Üzerinde durulup çözülmesi gereken konu.', 'kelime', 'isim', 5, 5, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 5, null, '“Bu mesele yarınki toplantıda konuşulacak.” cümlesindeki “mesele” sözcüğüyle eş anlamlı olan hangisidir?', '["yarış","gezi","ödev","sorun"]'::jsonb, 3, null, null, 'Mesele, sorun demektir. Yarış, gezi ve ödev bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('cömert', 'Elindekini paylaşmaktan çekinmeyen.', 'kelime', 'sifat', 5, 5, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 5, null, '“Komşumuz paylaşmayı seven cömert biridir.” cümlesindeki “cömert” sözcüğünün zıt anlamlısı hangisidir?', '["cimri","sessiz","titiz","neşeli"]'::jsonb, 0, null, null, 'Cömert paylaşan, cimri ise elindekini paylaşmayan kişidir; zıt anlamlıdır. Diğerleri ilgisiz özelliklerdir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('yumuşak', 'Dokunulunca bastırılabilen, sert olmayan.', 'kelime', 'sifat', 5, 5, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 5, null, '“Yumuşak minderin üzerine oturdum.” cümlesindeki “yumuşak” sözcüğünün zıt anlamlısı hangisidir?', '["ince","sert","kısa","eski"]'::jsonb, 1, null, null, 'Yumuşağın zıddı serttir. İnce, kısa ve eski başka özelliklerdir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ağır', 'Tartıda çok gelen.', 'kelime', 'sifat', 5, 5, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 5, null, '“Bu çanta çok ağır.” cümlesindeki “ağır” sözcüğünün zıt anlamlısı hangisidir?', '["küçük","dolu","hafif","eski"]'::jsonb, 2, null, null, 'Ağırın zıddı hafiftir. Küçük, dolu ve eski ağırlıkla doğrudan karşıt değildir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('aydınlık', 'Işığı bol olan.', 'kelime', 'sifat', 5, 5, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 5, null, '“Oda gün boyu çok aydınlıktı.” cümlesindeki “aydınlıktı” sözcüğünün zıt anlamlısı hangisidir?', '["geniş","sıcak","sessiz","karanlık"]'::jsonb, 3, null, null, 'Aydınlığın zıddı karanlıktır. Geniş, sıcak ve sessiz ışıkla ilgili değildir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('dar', 'Eni az olan.', 'kelime', 'sifat', 5, 5, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 5, null, '“Bu sokak o kadar dar ki araba giremiyor.” cümlesindeki “dar” sözcüğünün zıt anlamlısı hangisidir?', '["uzun","geniş","düz","eski"]'::jsonb, 1, null, null, 'Darın zıddı geniştir. Uzun, düz ve eski eniyle ilgili karşıt değildir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kolay', 'Yapılması güç olmayan.', 'kelime', 'sifat', 5, 5, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 5, null, '“Bu bulmacayı çözmek çok kolaydı.” cümlesindeki “kolaydı” sözcüğünün zıt anlamlısı hangisidir?', '["kısa","eğlenceli","zor","sessiz"]'::jsonb, 2, null, null, 'Kolayın zıddı zordur. Kısa, eğlenceli ve sessiz karşıt anlam taşımaz.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('yararlı', 'Fayda sağlayan.', 'kelime', 'sifat', 5, 5, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 5, null, '“Yeşil sebze sağlığa çok yararlıdır.” cümlesindeki “yararlıdır” sözcüğünün zıt anlamlısı hangisidir?', '["lezzetli","pahalı","doğal","zararlı"]'::jsonb, 3, null, null, 'Yararlının zıddı zararlıdır. Lezzetli, pahalı ve doğal karşıt değildir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('yüz', 'Sayı olarak doksan dokuzdan sonra gelen sayı.', 'kelime', 'isim', 5, 5, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_sesli', 5, null, 'Aşağıdakilerden hangisinde “yüz” sözcüğü sayı anlamında kullanılmıştır?', '["Bu kutunun içinde yüz tane boncuk var.","Sabah yüzünü sabunla yıkayıp çıktı.","Havuzda kollarını açıp rahatça yüz.","Kumaşın yüzü pürüzsüz, tersi tüylüydü."]'::jsonb, 0, null, null, 'Yalnız ilk cümlede “yüz”, sayı anlamındadır. Diğerleri surat, yüzmek ve kumaşın ön tarafı anlamındadır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kır', 'Şehir dışındaki açık, yeşil alan.', 'kelime', 'isim', 5, 5, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_sesli', 5, null, 'Aşağıdakilerden hangisinde “kır” sözcüğü şehir dışındaki açık alan anlamında kullanılmıştır?', '["Bardağı düşürüp kırma, dikkatli taşı.","Hafta sonu ailece kırda yürüyüşe çıktık.","Kır saçlı amcam bize el salladı.","Küçük bir hata yüzünden kalbini kırma."]'::jsonb, 1, null, null, 'Yalnız ilk cümlede kır, açık alan anlamındadır. Diğerleri kırmak fiili ve saç rengi anlamındadır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('gözden çıkarmak', 'Bir şeyden vazgeçmeyi göze almak.', 'deyim', null, 5, 5, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 5, null, '“Yolculuk için biriktirdiği harçlığı gözden çıkardı.” cümlesindeki “gözden çıkarmak” deyimi ne anlama gelir?', '["Bir şeyden vazgeçmeyi göze almak","Bir şeye çok dikkat etmek","Bir şeyi çok uzaktan görmek","Bir şeyi başkasına armağan etmek"]'::jsonb, 0, null, null, 'Gözden çıkarmak, bir şeyden vazgeçmeyi göze almaktır. Diğerleri deyimin anlamı değildir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ağzı kulaklarına varmak', 'Çok sevinmek.', 'deyim', null, 5, 5, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 5, null, '“Karnesini görünce babasının ağzı kulaklarına vardı.” cümlesindeki “ağzı kulaklarına varmak” deyimi ne anlama gelir?', '["Çok şaşırmak","Çok sevinmek","Çok utanmak","Çok kızmak"]'::jsonb, 1, null, null, 'Ağzı kulaklarına varmak, çok sevinmektir. Diğer duygular deyimin anlamı değildir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kulak vermek', 'Dikkatle dinlemek.', 'deyim', null, 5, 5, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 5, null, '“Konuşmacının söylediklerine kulak verdik.” cümlesindeki “kulak vermek” deyimi ne anlama gelir?', '["Yüksek sesle konuşmak","Duymazlıktan gelmek","Dikkatle dinlemek","Hemen cevap vermek"]'::jsonb, 2, null, null, 'Kulak vermek, dikkatle dinlemektir. Duymazlıktan gelmek ters anlamlıdır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('göz yummak', 'Bir kusuru bilerek görmezden gelmek.', 'deyim', null, 5, 5, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 5, null, '“Öğretmen küçük bir kusura göz yumdu.” cümlesindeki “göz yummak” deyimi ne anlama gelir?', '["Bir hatayı hemen düzeltmek","Bir olayı çok merak etmek","Bir sorunu herkese anlatmak","Bir kusuru görmezden gelmek"]'::jsonb, 3, null, null, 'Göz yummak, bir kusuru görmezden gelmektir. Diğer şıklar deyimin anlamı değildir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('yüreği ağzına gelmek', 'Çok korkmak.', 'deyim', null, 5, 5, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 5, null, '“Karanlık odada bir ses duyunca yüreği ağzına geldi.” cümlesindeki “yüreği ağzına gelmek” deyimi ne anlama gelir?', '["Çok korkmak","Çok üzülmek","Çok yorulmak","Çok utanmak"]'::jsonb, 0, null, null, 'Yüreği ağzına gelmek, çok korkmaktır. Diğer şıklar deyimin anlamı değildir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('pireyi deve yapmak', 'Önemsiz bir şeyi büyütmek.', 'deyim', null, 5, 5, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 5, null, '“Ufak bir çizik için pireyi deve yaptı.” cümlesindeki “pireyi deve yapmak” deyimi ne anlama gelir?', '["Basit bir olayı hemen unutmak","Basit bir olayı fazlaca büyütmek","Basit bir olayı gizli tutmak","Basit bir olaya çok sevinmek"]'::jsonb, 1, null, null, 'Pireyi deve yapmak, basit bir şeyi gereğinden fazla büyütmektir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Damlaya damlaya göl olur.', 'Az az biriken şeyler zamanla çok olur.', 'atasozu', null, 5, 5, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 5, null, '“Damlaya damlaya göl olur.” atasözü hangi durumu anlatır?', '["Yağmurlu havada göller taşar.","Su içmek sağlığa yararlıdır.","Az az biriken şeyler zamanla çoğalır.","Kuraklık her yeri etkiler."]'::jsonb, 2, null, null, 'Atasözü birikimin zamanla büyüdüğünü anlatır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Ağaç yaşken eğilir.', 'Eğitim küçük yaşta daha kolay verilir.', 'atasozu', null, 5, 5, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 5, null, '“Ağaç yaşken eğilir.” atasözü hangi durumu anlatır?', '["Büyükler yeni şeyleri daha çabuk öğrenir.","Ağaçlar sulanınca hızlı büyür.","Rüzgâr fidanları devirir.","Eğitim erken dönemde daha kolay verilir."]'::jsonb, 3, null, null, 'Atasözü, eğitimin erken dönemde daha etkili olduğunu anlatır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Sakla samanı, gelir zamanı.', 'Bugün işe yaramayan şey ileride gerekebilir.', 'atasozu', null, 5, 5, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 5, null, '“Sakla samanı, gelir zamanı.” atasözü hangi durumu anlatır?', '["Bugün işe yaramayan şey ileride gerekebilir.","Eski eşyalar ev içinde yer kaplar.","Çalışmadan kazanılan şey çabuk biter.","Her işin yapılacağı özel bir vakit vardır."]'::jsonb, 0, null, null, 'Atasözü, değersiz görünen şeylerin ileride gerekebileceğini anlatır.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Bir elin nesi var, iki elin sesi var.', 'İş birliği işi kolaylaştırır.', 'atasozu', null, 5, 5, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 5, null, '“Bir elin nesi var, iki elin sesi var.” atasözü hangi durumu anlatır?', '["Alkış tutmak moral verir.","Birlikte çalışmak işi kolaylaştırır.","Tek başına çalışan daha hızlı yapar.","Eller temiz tutulursa hastalık olmaz."]'::jsonb, 1, null, null, 'Atasözü, iş birliğinin gücünü anlatır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('mahcup', 'Utanmış, sıkılmış.', 'kelime', 'sifat', 5, 5, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 5, null, '“Verdiği sözü tutamadığı için mahcup oldu; yüzü kızardı, gözlerini yere indirdi.” cümlesinde “mahcup” sözcüğü ne anlama gelir?', '["Kızgın","Utanmış","Yorgun","Şaşkın"]'::jsonb, 1, null, null, 'Yüzün kızarması ve gözlerin yere inmesi utanmayı gösterir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('tedirgin', 'Huzursuz, rahatı kaçmış.', 'kelime', 'sifat', 5, 5, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 5, null, '“Karanlık koridorda tedirgin bir şekilde bekledi; her sesle yerinden sıçradı.” cümlesinde “tedirgin” sözcüğü ne anlama gelir?', '["Sakin","Öfkeli","Mutlu","Huzursuz"]'::jsonb, 3, null, null, 'Her sesle sıçramak huzursuzluğu gösterir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ibret', 'Bir olaydan çıkarılan ders.', 'kelime', 'isim', 5, 5, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 5, null, '“Bu olaydan ibret aldı; bir daha aynı hatayı yapmamaya karar verdi.” cümlesinde “ibret” sözcüğü ne anlama gelir?', '["Ders çıkarılacak durum","Eğlenceli bir oyun","Değerli bir hediye","Büyük bir kazanç"]'::jsonb, 0, null, null, 'Aynı hatayı yapmamaya karar vermek, olaydan ders alındığını gösterir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kıt', 'Az bulunan.', 'kelime', 'sifat', 5, 5, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 5, null, '“Çölde su kıt olduğundan yolcular her damlayı dikkatle kullandı.” cümlesinde “kıt” sözcüğü ne anlama gelir?', '["Çok tatlı","Az bulunan","Çok soğuk","Bol bulunan"]'::jsonb, 1, null, null, 'Her damlayı dikkatle kullanmak suyun az olduğunu gösterir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
end
$olcek$;
commit;