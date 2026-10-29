begin;
select set_config('request.jwt.claims', json_build_object('sub', (select id from public.profiles where role = 'admin' order by id limit 1), 'role', 'authenticated')::text, true);
do $olcek$
declare v_id uuid; v_anlam uuid;
begin
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('uzun', 'Boyu ya da süresi çok olan.', 'kelime', 'sifat', 3, 3, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 3, null, '“uzun” sözcüğünün zıt anlamlısı hangisidir?', '["kısa","dar","ince","alçak"]'::jsonb, 0, null, null, 'Doğru yanıt “kısa” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('sıcak', 'Isısı yüksek olan.', 'kelime', 'sifat', 3, 3, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 3, null, '“sıcak” sözcüğünün zıt anlamlısı hangisidir?', '["ıslak","soğuk","tatlı","hafif"]'::jsonb, 1, null, null, 'Doğru yanıt “soğuk” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('doğru', 'Gerçeğe uygun olan.', 'kelime', 'sifat', 3, 3, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 3, null, '“doğru” sözcüğünün zıt anlamlısı hangisidir?', '["gerçek","düzgün","yanlış","kesin"]'::jsonb, 2, null, null, 'Doğru yanıt “yanlış” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('temiz', 'Kiri olmayan.', 'kelime', 'sifat', 3, 3, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 3, null, '“temiz” sözcüğünün zıt anlamlısı hangisidir?', '["düzgün","parlak","boş","kirli"]'::jsonb, 3, null, null, 'Doğru yanıt “kirli” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('gece', 'Güneşin battığı, karanlık zaman.', 'kelime', 'sifat', 3, 3, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 3, null, '“gece” sözcüğünün zıt anlamlısı hangisidir?', '["gündüz","akşam","sabah","yarın"]'::jsonb, 0, null, null, 'Doğru yanıt “gündüz” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ileri', 'Önde olan yön.', 'kelime', 'sifat', 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 3, null, '“ileri” sözcüğünün zıt anlamlısı hangisidir?', '["yan","geri","üst","yakın"]'::jsonb, 1, null, null, 'Doğru yanıt “geri” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('erken', 'Beklenen zamandan önce olan.', 'kelime', 'sifat', 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 3, null, '“erken” sözcüğünün zıt anlamlısı hangisidir?', '["yavaş","uzak","geç","sonra"]'::jsonb, 2, null, null, 'Doğru yanıt “geç” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('tok', 'Karnı doymuş olan.', 'kelime', 'sifat', 3, 3, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 3, null, '“tok” sözcüğünün zıt anlamlısı hangisidir?', '["susuz","yorgun","hasta","aç"]'::jsonb, 3, null, null, 'Doğru yanıt “aç” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('dolu', 'İçinde boşluk kalmayan.', 'kelime', 'sifat', 3, 3, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 3, null, '“dolu” sözcüğünün zıt anlamlısı hangisidir?', '["boş","kırık","yeni","sıcak"]'::jsonb, 0, null, null, 'Doğru yanıt “boş” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kolay', 'Az çabayla yapılan.', 'kelime', 'sifat', 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 3, null, '“kolay” sözcüğünün zıt anlamlısı hangisidir?', '["sakin","zor","eski","acı"]'::jsonb, 1, null, null, 'Doğru yanıt “zor” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('hediye', 'Sevdiğimiz kişiye verilen şey.', 'kelime', 'isim', 3, 3, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 3, null, '“hediye” sözcüğünün eş anlamlısı hangisidir?', '["mektup","oyuncak","davet","armağan"]'::jsonb, 3, null, null, 'Doğru yanıt “armağan” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('yardım', 'Güç durumdaki birine el uzatma.', 'kelime', 'isim', 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 3, null, '“yardım” sözcüğünün eş anlamlısı hangisidir?', '["destek","ödev","hareket","karşılık"]'::jsonb, 0, null, null, 'Doğru yanıt “destek” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('anne', 'Çocuğunu doğuran ya da büyüten kadın.', 'kelime', 'isim', 3, 3, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 3, null, '“anne” sözcüğünün eş anlamlısı hangisidir?', '["hala","ana","teyze","nine"]'::jsonb, 1, null, null, 'Doğru yanıt “ana” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('yiyecek', 'Yenilen şeylerin genel adı.', 'kelime', 'isim', 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 3, null, '“yiyecek” sözcüğünün eş anlamlısı hangisidir?', '["içecek","sofra","gıda","tabak"]'::jsonb, 2, null, null, 'Doğru yanıt “gıda” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('yaramaz', 'Söz dinlemeyen, haylazlık eden.', 'kelime', 'sifat', 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 3, null, '“yaramaz” sözcüğünün eş anlamlısı hangisidir?', '["haylaz","uslu","korkak","tembel"]'::jsonb, 0, null, null, 'Doğru yanıt “haylaz” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('doktor', 'Hastaları tedavi eden kişi.', 'kelime', 'isim', 3, 3, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 3, null, '“doktor” sözcüğünün eş anlamlısı hangisidir?', '["hemşire","hekim","eczacı","ebe"]'::jsonb, 1, null, null, 'Doğru yanıt “hekim” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('bitirmek', 'Bir işi sonuna getirmek.', 'kelime', 'fiil', 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 3, null, '“bitirmek” sözcüğünün eş anlamlısı hangisidir?', '["bozmak","sürdürmek","tamamlamak","bırakmak"]'::jsonb, 2, null, null, 'Doğru yanıt “tamamlamak” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('yaşlı', 'Yaşı ilerlemiş olan.', 'kelime', 'sifat', 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 3, null, '“yaşlı” sözcüğünün eş anlamlısı hangisidir?', '["hasta","güçsüz","yorgun","ihtiyar"]'::jsonb, 3, null, null, 'Doğru yanıt “ihtiyar” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('göz kulak olmak', 'Korumak ve gözetmek.', 'deyim', null, 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 3, null, '“Abla, tatildeyken küçük kardeşine göz kulak oldu.” cümlesindeki “göz kulak olmak” deyimi ne anlama gelir?', '["korumak ve gözetmek","azarlayıp uyarmak","yalnız bırakmak","oyalayıp eğlendirmek"]'::jsonb, 0, null, null, 'Doğru yanıt “korumak ve gözetmek” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kulak kesilmek', 'Dikkatle dinlemek.', 'deyim', null, 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 3, null, '“Öğretmen masalı anlatırken herkes kulak kesildi.” cümlesindeki “kulak kesilmek” deyimi ne anlama gelir?', '["yüksek sesle konuşmak","dikkatle dinlemek","hemen uyuyakalmak","sessizce dışarı çıkmak"]'::jsonb, 1, null, null, 'Doğru yanıt “dikkatle dinlemek” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ağzı kulaklarına varmak', 'Çok sevinmek.', 'deyim', null, 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 3, null, '“Piknik haberini duyunca ağzı kulaklarına vardı.” cümlesindeki “ağzı kulaklarına varmak” deyimi ne anlama gelir?', '["çok üzülmek","çok korkmak","çok sevinmek","çok yorulmak"]'::jsonb, 2, null, null, 'Doğru yanıt “çok sevinmek” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('yüreği ağzına gelmek', 'Çok korkmak.', 'deyim', null, 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 3, null, '“Karanlık odada bir ses duyunca yüreği ağzına geldi.” cümlesindeki “yüreği ağzına gelmek” deyimi ne anlama gelir?', '["çok acıkmak","çok susamak","çok gülmek","çok korkmak"]'::jsonb, 3, null, null, 'Doğru yanıt “çok korkmak” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('burnu havada olmak', 'Kendini beğenmek.', 'deyim', null, 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 3, null, '“Yarışmayı kazanınca burnu havada dolaşmaya başladı.” cümlesindeki “burnu havada olmak” deyimi ne anlama gelir?', '["kendini beğenmek","utanıp saklanmak","havayı koklamak","yavaş yürümek"]'::jsonb, 0, null, null, 'Doğru yanıt “kendini beğenmek” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('el ele vermek', 'Birlikte çalışmak.', 'deyim', null, 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 3, null, '“Mahalledeki herkes parkı temizlemek için el ele verdi.” cümlesindeki “el ele vermek” deyimi ne anlama gelir?', '["yalnız çalışmak","birlikte çalışmak","gösteri yapmak","elini yıkamak"]'::jsonb, 1, null, null, 'Doğru yanıt “birlikte çalışmak” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Damlaya damlaya göl olur.', 'Azar azar biriken şey zamanla büyür.', 'atasozu', null, 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 3, null, '“Damlaya damlaya göl olur.” atasözü ne anlatır?', '["Su kenarında oturmak güvenlidir","Yağmurlu havada dışarı çıkılmaz","Azar azar biriken şey zamanla büyür","Büyük göller hep temiz kalır"]'::jsonb, 2, null, null, 'Doğru yanıt “Azar azar biriken şey zamanla büyür” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Bir elin nesi var, iki elin sesi var.', 'İşler birlikte yapılınca daha iyi olur.', 'atasozu', null, 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 3, null, '“Bir elin nesi var, iki elin sesi var.” atasözü ne anlatır?', '["Her iş tek başına yapılmalıdır","Eller her zaman temiz tutulmalı","Alkış tutmak çok kolay bir iştir","İşler birlikte yapılınca daha iyi olur"]'::jsonb, 3, null, null, 'Doğru yanıt “İşler birlikte yapılınca daha iyi olur” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Sabreden derviş muradına ermiş.', 'Sabırla bekleyen isteğine kavuşur.', 'atasozu', null, 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 3, null, '“Sabreden derviş muradına ermiş.” atasözü ne anlatır?', '["Sabırla bekleyen isteğine kavuşur","Aceleyle yapılan iş hep kazanır","Beklemek insanı çok yorar","İstenen şey her zaman kolay gelir"]'::jsonb, 0, null, null, 'Doğru yanıt “Sabırla bekleyen isteğine kavuşur” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Ayağını yorganına göre uzat.', 'Harcamayı sahip olduğun paraya göre yap.', 'atasozu', null, 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 3, null, '“Ayağını yorganına göre uzat.” atasözü ne anlatır?', '["Soğuk günlerde kalın örtün","Harcamayı sahip olduğun paraya göre yap","Her zaman rahat bir yatakta uyu","Yatmadan önce ayaklarını yıka"]'::jsonb, 1, null, null, 'Doğru yanıt “Harcamayı sahip olduğun paraya göre yap” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Ağaç yaşken eğilir.', 'Eğitim küçük yaşta daha kolay verilir.', 'atasozu', null, 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 3, null, '“Ağaç yaşken eğilir.” atasözü ne anlatır?', '["Ağaçlar her mevsim yeşil kalır","Yaşlı kişiler çok iyi dinlenir","Eğitim küçük yaşta daha kolay verilir","Eğilmeden büyüyen ağaç güçlenir"]'::jsonb, 2, null, null, 'Doğru yanıt “Eğitim küçük yaşta daha kolay verilir” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Üzüm üzüme baka baka kararır.', 'İnsan çevresindekilerden etkilenir.', 'atasozu', null, 3, 3, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 3, null, '“Üzüm üzüme baka baka kararır.” atasözü ne anlatır?', '["Üzüm yemek sağlık için yararlıdır","Bağdaki üzümler geç olgunlaşır","Her meyve kendi mevsiminde yenir","İnsan çevresindekilerden etkilenir"]'::jsonb, 3, null, null, 'Doğru yanıt “İnsan çevresindekilerden etkilenir” şıkkıdır; diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
end
$olcek$;
commit;