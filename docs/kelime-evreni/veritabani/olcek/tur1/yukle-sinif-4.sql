begin;
select set_config('request.jwt.claims', json_build_object('sub', (select id from public.profiles where role = 'admin' order by id limit 1), 'role', 'authenticated')::text, true);
do $olcek$
declare v_id uuid; v_anlam uuid;
begin
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('cesur', 'Korkmadan zor işlere atılan', 'kelime', 'sifat', 4, 4, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 4, null, '“Cesur itfaiyeci alevlerin içine girdi.” cümlesindeki “cesur” sözcüğüyle eş anlamlı olan hangisidir?', '["yürekli","telaşlı","kurnaz","sabırlı"]'::jsonb, 0, null, null, 'Cesur ile yürekli, korkusuz anlamda eş anlamlıdır; telaşlı, kurnaz ve sabırlı başka özellikleri anlatır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('hızlı', 'Çabuk giden ya da çabuk yapan', 'kelime', 'sifat', 4, 4, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 4, null, '“Hızlı yürüyerek servisi yakaladık.” cümlesindeki “hızlı” sözcüğüyle eş anlamlı olan hangisidir?', '["yavaş","çabuk","dikkatli","sessiz"]'::jsonb, 1, null, null, 'Hızlı ve çabuk aynı anlamdadır; yavaş zıt anlamlıdır, dikkatli ve sessiz başka anlamlardır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kolay', 'Yapması güç olmayan', 'kelime', 'sifat', 4, 4, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 4, null, '“Bu kolay soruyu hemen çözdüm.” cümlesindeki “kolay” sözcüğüyle eş anlamlı olan hangisidir?', '["zor","uzun","basit","ilginç"]'::jsonb, 2, null, null, 'Kolay ve basit, güç olmayan anlamında eş anlamlıdır; zor zıt anlamlıdır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('yorgun', 'Gücü tükenmiş, dinlenmeye ihtiyacı olan', 'kelime', 'sifat', 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 4, null, '“Uzun yolculuktan sonra yorgun düştük.” cümlesindeki “yorgun” sözcüğüyle eş anlamlı olan hangisidir?', '["hasta","üzgün","uykulu","bitkin"]'::jsonb, 3, null, null, 'Yorgun ve bitkin gücü tükenmiş olmayı anlatır; hasta, üzgün ve uykulu başka durumlardır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('zengin', 'Çok malı ve parası olan', 'kelime', 'sifat', 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 4, null, '“Zengin tüccar köye bir kütüphane yaptırdı.” cümlesindeki “zengin” sözcüğüyle eş anlamlı olan hangisidir?', '["varlıklı","kibar","yaşlı","tembel"]'::jsonb, 0, null, null, 'Zengin ve varlıklı, malı mülkü çok olan demektir; diğer şıklar başka özellikleri anlatır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kılavuz', 'Yol gösteren kimse', 'kelime', 'isim', 4, 4, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 4, null, '“Dağ yolunda kılavuz bizi doğru patikaya götürdü.” cümlesindeki “kılavuz” sözcüğüyle eş anlamlı olan hangisidir?', '["yolcu","harita","rehber","pusula"]'::jsonb, 2, null, null, 'Kılavuz ve rehber yol gösteren kişidir; harita ve pusula araçtır, yolcu yol gösteren değildir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('hediye', 'Bir kimseyi sevindirmek için verilen şey', 'kelime', 'isim', 4, 4, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 4, null, '“Doğum gününde bana güzel bir hediye aldılar.” cümlesindeki “hediye” sözcüğüyle eş anlamlı olan hangisidir?', '["kutu","mektup","kart","armağan"]'::jsonb, 3, null, null, 'Hediye ve armağan aynı anlamdadır; kutu, mektup ve kart farklı nesnelerdir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('erken', 'Beklenen ya da olması gereken zamandan önce', 'kelime', 'zarf', 4, 4, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 4, null, '“Bu sabah okula erken vardık.” cümlesindeki “erken” sözcüğünün zıt anlamlısı hangisidir?', '["önce","geç","hemen","bugün"]'::jsonb, 1, null, null, 'Erken sözcüğünün zıttı geçtir; önce, hemen ve bugün zaman bildirir ama zıt anlamlı değildir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kuru', 'Nemi ve suyu olmayan', 'kelime', 'sifat', 4, 4, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 4, null, '“Kuru çamaşırları sepete koydu.” cümlesindeki “kuru” sözcüğünün zıt anlamlısı hangisidir?', '["sert","temiz","ıslak","soğuk"]'::jsonb, 2, null, null, 'Kuru nemsiz demektir, zıttı ıslaktır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('hafif', 'Tartıda az gelen', 'kelime', 'sifat', 4, 4, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 4, null, '“Hafif çanta sırtımı yormadı.” cümlesindeki “hafif” sözcüğünün zıt anlamlısı hangisidir?', '["büyük","dolu","eski","ağır"]'::jsonb, 3, null, null, 'Hafifin zıttı ağırdır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('cömert', 'Elindekini isteyerek paylaşan', 'kelime', 'sifat', 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 4, null, '“Cömert bir insan elindekini paylaşır.” cümlesindeki “cömert” sözcüğünün zıt anlamlısı hangisidir?', '["cimri","zengin","sessiz","kibar"]'::jsonb, 0, null, null, 'Cömertin zıttı cimridir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('genç', 'Yaşça küçük, yaşlanmamış', 'kelime', 'sifat', 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 4, null, '“Genç ağaç rüzgârda eğildi.” cümlesindeki “genç” sözcüğünün zıt anlamlısı hangisidir?', '["ince","yaşlı","kısa","boş"]'::jsonb, 1, null, null, 'Gençin zıttı yaşlıdır; ince, kısa ve boş zıt anlamlı değildir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('doğru', 'Gerçeğe uygun olan', 'kelime', 'sifat', 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 4, null, '“Sorunun doğru cevabını buldum.” cümlesindeki “doğru” sözcüğünün zıt anlamlısı hangisidir?', '["kısa","zor","yanlış","güzel"]'::jsonb, 2, null, null, 'Doğrunun zıttı yanlıştır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('açık', 'Kapalı olmayan', 'kelime', 'sifat', 4, 4, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 4, null, '“Pencere açık olduğu için oda soğudu.” cümlesindeki “açık” sözcüğünün zıt anlamlısı hangisidir?', '["dar","karanlık","sessiz","kapalı"]'::jsonb, 3, null, null, 'Pencere açık olmanın karşıtı kapalı olmaktır.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('alçak', 'Yerden yüksekliği az olan', 'kelime', 'sifat', 4, 4, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 4, null, '“Alçak duvarın üstüne çıkıp bahçeye baktık.” cümlesindeki “alçak” sözcüğünün zıt anlamlısı hangisidir?', '["yüksek","kalın","eski","boş"]'::jsonb, 0, null, null, 'Alçağın zıttı yüksektir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('at', 'binek hayvanı', 'kelime', 'isim', 4, 4, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_sesli', 4, null, 'Aşağıdakilerden hangisinde “at” sözcüğü binek hayvanı anlamında kullanılmıştır?', '["Topu bana doğru at, ben tutarım.","Çöpü yolda bırakma, kutuya at.","Çiftlikte beyaz bir at otluyordu.","Kâğıdı yırtıp sepete at lütfen."]'::jsonb, 2, null, null, 'Birinci cümledeki at, binek hayvanıdır; diğerlerinde atmak eylemi vardır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('pas', 'demirde oluşan kırmızımsı tabaka', 'kelime', 'isim', 4, 4, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_sesli', 4, null, 'Aşağıdakilerden hangisinde “pas” sözcüğü demirde oluşan kırmızımsı tabaka anlamında kullanılmıştır?', '["Takım arkadaşına uzun bir pas verdi.","Son pas golü getirdi ve alkış koptu.","Oyuncu topu hızla pas edip ilerledi.","Eski bisikletin zincirini pas kaplamıştı."]'::jsonb, 3, null, null, 'Demirde pas oluşur; diğer cümlelerde pas topun arkadaşa gönderilmesidir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ben', 'vücutta oluşan küçük koyu leke', 'kelime', 'isim', 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_sesli', 4, null, 'Aşağıdakilerden hangisinde “ben” sözcüğü vücutta oluşan küçük koyu leke anlamında kullanılmıştır?', '["Yanağındaki küçük ben ona çok yakışıyor.","Ben bu akşam erken yatacağım.","Bu kitabı ben seçtim, çok güzel.","Yarın ben de sana yardım ederim."]'::jsonb, 0, null, null, 'Yalnız ilk cümlede ben, ciltteki lekedir; diğerleri kişi zamiridir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('saz', 'bir çalgı aleti', 'kelime', 'isim', 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_sesli', 4, null, 'Aşağıdakilerden hangisinde “saz” sözcüğü bir çalgı aleti anlamında kullanılmıştır?', '["Göl kıyısında boylu boyunca saz bitmişti.","Dedem akşamları saz çalıp türkü söyler.","Sazdan yapılmış kulübe suya yakındı.","Saz demetleriyle bir sepet ördüler."]'::jsonb, 1, null, null, 'Dedemin çaldığı saz çalgıdır; diğer cümlelerde saz, su kenarında biten bitkidir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kaz', 'bir su kuşu', 'kelime', 'isim', 4, 4, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_sesli', 4, null, 'Aşağıdakilerden hangisinde “kaz” sözcüğü bir su kuşu anlamında kullanılmıştır?', '["Bahçede küçük bir çukur kaz, fidanı dikelim.","Gölde beyaz bir kaz yavrularını yüzdürdü.","Toprağı biraz daha kaz, kök görünsün.","Kuyuyu derin kaz ki su çıksın."]'::jsonb, 1, null, null, 'Gölde yüzen kaz bir kuştur; diğerlerinde kaz, kazmak eyleminin emir biçimidir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('göz yummak', 'Görmezden gelmek', 'deyim', null, 4, 4, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 4, null, '“Yöneticiler yapılan küçük hataya göz yumdu.” cümlesindeki “göz yummak” deyimi ne anlama gelir?', '["Çok sinirlenmek","Dikkatle incelemek","Uykuya dalmak","Görmezden gelmek"]'::jsonb, 3, null, null, 'Göz yummak, bir şeyi bilerek görmezden gelmektir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kulak vermek', 'Dikkatle dinlemek', 'deyim', null, 4, 4, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 4, null, '“Yaşlı adam anlatırken herkes ona kulak verdi.” cümlesindeki “kulak vermek” deyimi ne anlama gelir?', '["Dikkatle dinlemek","Yüksek sesle bağırmak","Sözü kesmek","Sessizce uzaklaşmak"]'::jsonb, 0, null, null, 'Kulak vermek, dikkatle dinlemek demektir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('içi içine sığmamak', 'Çok heyecanlanmak', 'deyim', null, 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 4, null, '“Sonuçları beklerken içi içine sığmıyordu.” cümlesindeki “içi içine sığmamak” deyimi ne anlama gelir?', '["Aşırı yorulmak","Çok heyecanlanmak","Hemen vazgeçmek","Birden susmak"]'::jsonb, 1, null, null, 'İçi içine sığmamak, heyecandan duramamaktır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('burnu havada olmak', 'Kendini üstün görmek', 'deyim', null, 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 4, null, '“Yarışmayı kazanan kişi artık burnu havada dolaşıyor.” cümlesindeki “burnu havada olmak” deyimi ne anlama gelir?', '["Sürekli hasta olmak","Koku almamak","Kendini üstün görmek","Çok merak etmek"]'::jsonb, 2, null, null, 'Burnu havada olmak, kibirli davranmak ve kendini üstün görmektir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ağzı kulaklarına varmak', 'Çok sevinmek', 'deyim', null, 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 4, null, '“Karnesini görünce ağzı kulaklarına vardı.” cümlesindeki “ağzı kulaklarına varmak” deyimi ne anlama gelir?', '["Çok kızmak","Çok şaşırmak","Çok korkmak","Çok sevinmek"]'::jsonb, 3, null, null, 'Ağzı kulaklarına varmak, çok sevinmek demektir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('eli açık olmak', 'Cömert olmak', 'deyim', null, 4, 4, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 4, null, '“Eli açık biri olduğu için yanında hiç para kalmaz.” cümlesindeki “eli açık olmak” deyimi ne anlama gelir?', '["Cömert olmak","Tutumlu olmak","Dikkatsiz olmak","Güçlü olmak"]'::jsonb, 0, null, null, 'Eli açık olmak, cömert ve bol harcayan olmak demektir; tutumlu olmanın tersidir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Damlaya damlaya göl olur.', 'Azlar birikerek büyük bir şey oluşturur.', 'atasozu', null, 4, 4, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 4, null, '“Damlaya damlaya göl olur.” atasözü hangi durumu anlatır?', '["Göl kenarında yaşayan mutlu olur.","Azlar birikince büyük bir şey olur.","Yağmurlu günler çabuk geçer.","Her damla temiz su demektir."]'::jsonb, 1, null, null, 'Atasözü, küçük birikimlerin zamanla büyük olacağını anlatır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Sakla samanı, gelir zamanı.', 'Bugün saklanan şey ileride işe yarar.', 'atasozu', null, 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 4, null, '“Sakla samanı, gelir zamanı.” atasözü hangi durumu anlatır?', '["Saman ambarı her zaman dolu tutulur.","Zaman geçtikçe her şey değerini yitirir.","Samanlar hep kışın toplanır.","Bugün biriktirilen şey ileride işe yarar."]'::jsonb, 3, null, null, 'Atasözü, değersiz görünen şeyin bile ileride işe yarayabileceğini ve tutumlu olmayı anlatır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Komşu komşunun külüne muhtaçtır.', 'İnsanlar birbirinin yardımına ihtiyaç duyar.', 'atasozu', null, 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 4, null, '“Komşu komşunun külüne muhtaçtır.” atasözü hangi durumu anlatır?', '["İnsanlar birbirinin yardımına ihtiyaç duyar.","Her evin ocağı sürekli yanık tutulmalı.","Kül, ateşi söndürmek için kullanılır.","Yakın oturanlar sık sık tartışır."]'::jsonb, 0, null, null, 'Atasözü, insanların birbirine yardıma ihtiyaç duyduğunu anlatır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Bir elin nesi var, iki elin sesi var.', 'Birlikte çalışmak işi kolaylaştırır.', 'atasozu', null, 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 4, null, '“Bir elin nesi var, iki elin sesi var.” atasözü hangi durumu anlatır?', '["Elleri temiz olanın işi bereketli olur.","Birlik içinde çalışmak işi kolaylaştırır.","Alkış sesi insanları mutlu eder.","Gürültü içinde iş yapılmaz."]'::jsonb, 1, null, null, 'Atasözü, işbirliğinin gücünü anlatır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Acele işe şeytan karışır.', 'Telaşla yapılan işlerde hata çıkar.', 'atasozu', null, 4, 4, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 4, null, '“Acele işe şeytan karışır.” atasözü hangi durumu anlatır?', '["Hızlı koşan herkes yarışı kazanır.","Her iş gece yapılırsa daha iyi olur.","Telaşla yapılan işlerde sık hata çıkar.","İşe erken başlayan her zaman yorulur."]'::jsonb, 2, null, null, 'Atasözü, aceleyle yapılan işlerde hata yapılacağını anlatır.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('sağanak', 'Birden bastıran şiddetli yağmur', 'kelime', null, 4, 4, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 4, null, '“Gökyüzü karardı, sağanak başlayınca herkes saçak altına sığındı.” cümlesinde “sağanak” sözcüğü ne anlama gelir?', '["Hafif esen rüzgâr","Kalın sis tabakası","Kuru ve soğuk hava","Ani ve şiddetli yağmur"]'::jsonb, 3, null, null, 'Herkesin saçak altına sığınması, birden başlayan şiddetli yağmura işaret eder.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('mahcup', 'Utanmış, ezilmiş', 'kelime', null, 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 4, null, '“Verdiği sözü tutamayınca mahcup oldu, yüzü kıpkırmızı kesilip başını öne eğdi.” cümlesinde “mahcup” sözcüğü ne anlama gelir?', '["Utanmış","Şaşırmış","Yorulmuş","Sevinmiş"]'::jsonb, 0, null, null, 'Yüzünün kızarması ve başını eğmesi utanma belirtisidir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ıssız', 'İnsanın bulunmadığı', 'kelime', null, 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 4, null, '“Kasabanın ıssız sokaklarında tek bir ses duyulmuyor, kimse görünmüyordu.” cümlesinde “ıssız” sözcüğü ne anlama gelir?', '["Karanlık ve dar","İnsansız ve sessiz","Kalabalık ve gürültülü","Temiz ve düzenli"]'::jsonb, 1, null, null, 'Kimsenin görünmemesi ve ses gelmemesi sokağın ıssız olduğunu gösterir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('titizlikle', 'Çok özenle, ince eleyip sık dokuyarak', 'kelime', null, 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 4, null, '“Resmi bitirmeden önce her ayrıntıyı titizlikle kontrol etti; hiçbir hatanın kalmasını istemedi.” cümlesinde “titizlikle” sözcüğü ne anlama gelir?', '["Aceleyle, üstünkörü","Sevinçle, yüksek sesle","Özenle, dikkatle","Korkuyla, çekinerek"]'::jsonb, 2, null, null, 'Hiçbir hata kalmasın diye her ayrıntıyı kontrol etmek özenle yapılan davranıştır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('çevik', 'Hareketleri çabuk ve hafif olan', 'kelime', null, 4, 4, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 4, null, '“Çevik kedi bir anda çitten atlayıp ağaca tırmandı.” cümlesinde “çevik” sözcüğü ne anlama gelir?', '["Hızlı ve atik","Ağır ve yavaş","Sessiz ve ürkek","Büyük ve güçlü"]'::jsonb, 0, null, null, 'Bir anda atlayıp tırmanmak, çabuk ve atik hareket etmeyi gösterir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('tasarruf', 'Gereksiz harcamadan kaçınıp artırma', 'kelime', null, 4, 4, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 4, null, '“Ailemiz paranın boşa gitmemesi için su ve elektrikte tasarruf yapıyor.” cümlesinde “tasarruf” sözcüğü ne anlama gelir?', '["Daha fazla satın alma","Gereksiz harcamayı azaltma","Eşyaları paylaşma","Parayı borç verme"]'::jsonb, 1, null, null, 'Paranın boşa gitmemesi için yapılan şey, gereksiz harcamayı azaltmaktır.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
end
$olcek$;
commit;