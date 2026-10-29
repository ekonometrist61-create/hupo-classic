begin;
select set_config('request.jwt.claims', json_build_object('sub', (select id from public.profiles where role = 'admin' order by id limit 1), 'role', 'authenticated')::text, true);
do $olcek$
declare v_id uuid; v_anlam uuid;
begin
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('tereddüt', 'Karar verirken duraksama, kararsız kalma durumu.', 'kelime', 'isim', 8, 8, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 8, null, '“Sınav öncesinde yaşadığı tereddüt, kararını geciktirdi.” cümlesindeki “tereddüt” sözcüğüyle eş anlamlı olan hangisidir?', '["duraksama","coşku","pişmanlık","kıskançlık"]'::jsonb, 0, null, null, 'Tereddüt, karar verirken duraksamak demektir; duraksama eş anlamlıdır. Coşku, pişmanlık ve kıskançlık başka duygulardır.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ihtiyatlı', 'Olası tehlikelere karşı önlem alarak dikkatli davranan.', 'kelime', 'sifat', 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 8, null, '“Yolun buzlu olduğunu bilen sürücü ihtiyatlı davrandı.” cümlesindeki “ihtiyatlı” sözcüğüyle eş anlamlı olan hangisidir?', '["aceleci","temkinli","kayıtsız","cömert"]'::jsonb, 1, null, null, 'İhtiyatlı, tehlikeye karşı önlem alan demektir; temkinli eş anlamlıdır. Aceleci ve kayıtsız karşıt davranışlardır, cömert ilgisizdir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('mevcut', 'Şu anda var olan, bulunan.', 'kelime', 'sifat', 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 8, null, '“Kütüphanede mevcut kitapların listesi çıkarıldı.” cümlesindeki “mevcut” sözcüğüyle eş anlamlı olan hangisidir?', '["eski","ödünç","bulunan","değerli"]'::jsonb, 2, null, null, 'Mevcut, var olan demektir; bulunan eş anlamlıdır. Eski, ödünç ve değerli kitabın başka özelliklerini anlatır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ivedi', 'Hemen yapılması gereken, çabuk sonuç isteyen.', 'kelime', 'sifat', 8, 8, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 8, null, '“İvedi bir toplantı için herkes salona çağrıldı.” cümlesindeki “ivedi” sözcüğüyle eş anlamlı olan hangisidir?', '["uzun","gizli","sıradan","acil"]'::jsonb, 3, null, null, 'İvedi, hemen yapılması gereken demektir; acil eş anlamlıdır. Uzun, gizli ve sıradan bu anlama gelmez.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('belirgin', 'Kolayca fark edilen, açıkça görülen.', 'kelime', 'sifat', 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 8, null, '“Fotoğraftaki gölgeler belirgin biçimde görülüyordu.” cümlesindeki “belirgin” sözcüğüyle eş anlamlı olan hangisidir?', '["net","soluk","küçük","yumuşak"]'::jsonb, 0, null, null, 'Belirgin, açıkça seçilen demektir; net eş anlamlıdır. Soluk karşıt anlamlıya yakındır, küçük ve yumuşak ilgisizdir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('mümkün', 'Olabilecek, gerçekleşmesi olanaklı olan.', 'kelime', 'sifat', 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 8, null, '“Bu işi tek günde bitirmek mümkün değildi.” cümlesindeki “mümkün” sözcüğüyle eş anlamlı olan hangisidir?', '["gerekli","olanaklı","kolay","yararlı"]'::jsonb, 1, null, null, 'Mümkün, olabilir demektir; olanaklı eş anlamlıdır. Gerekli, kolay ve yararlı farklı niteliklerdir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('çağdaş', 'İçinde yaşanılan çağa uygun, yeni anlayışa sahip.', 'kelime', 'sifat', 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 8, null, '“Mimar, çağdaş bir yapı tasarlamak istediğini söyledi.” cümlesindeki “çağdaş” sözcüğüyle eş anlamlı olan hangisidir?', '["tarihî","sağlam","modern","gösterişli"]'::jsonb, 2, null, null, 'Çağdaş, çağın anlayışına uygun demektir; modern eş anlamlıdır. Tarihî karşıt anlamlıya yakındır; sağlam ve gösterişli başka özelliklerdir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('müsait', 'Bir iş için uygun, elverişli olan.', 'kelime', 'sifat', 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 8, null, '“Hava müsait olursa yarın gezintiye çıkarız.” cümlesindeki “müsait” sözcüğüyle eş anlamlı olan hangisidir?', '["soğuk","yağışlı","değişken","elverişli"]'::jsonb, 3, null, null, 'Müsait, uygun demektir; elverişli eş anlamlıdır. Soğuk, yağışlı ve değişken havanın durumunu anlatır ama uygunluk bildirmez.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('alçakgönüllü', 'Kendini üstün görmeyen, gösterişten kaçınan.', 'kelime', 'sifat', 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 8, null, '“Büyük başarılara imza atmasına karşın alçakgönüllü biri olarak kaldı.” cümlesindeki “alçakgönüllü” sözcüğüyle zıt anlamlı olan hangisidir?', '["sakin","kibirli","çalışkan","cesur"]'::jsonb, 1, null, null, 'Alçakgönüllünün zıddı, kendini üstün gören kibirlidir. Sakin, çalışkan ve cesur karşıt bir anlam taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ilkel', 'Gelişmemiş, başlangıç düzeyinde olan.', 'kelime', 'sifat', 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 8, null, '“İlk çağlarda insanlar ilkel araçlarla avlanırdı.” cümlesindeki “ilkel” sözcüğüyle zıt anlamlı olan hangisidir?', '["keskin","ağır","gelişmiş","sert"]'::jsonb, 2, null, null, 'İlkelin zıddı gelişmiştir. Keskin, ağır ve sert araçların gelişmişlik düzeyini anlatmaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('gerçek', 'Var olan, uydurma olmayan.', 'kelime', 'sifat', 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 8, null, '“Romanın kahramanı gerçek bir kişiydi.” cümlesindeki “gerçek” sözcüğüyle zıt anlamlı olan hangisidir?', '["ünlü","uzak","yaşlı","hayalî"]'::jsonb, 3, null, null, 'Gerçeğin zıddı hayalîdir; hayalî olan yalnızca düşüncede vardır. Ünlü, uzak ve yaşlı gerçeklikle ilgili karşıtlık kurmaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('peşin', 'Bir malın bedeli alışverişte hemen ödenen.', 'kelime', 'sifat', 8, 8, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 8, null, '“Ürünün bedelini peşin ödedi.” cümlesindeki “peşin” sözcüğüyle zıt anlamlı olan hangisidir?', '["veresiye","yüksek","tam","pahalı"]'::jsonb, 0, null, null, 'Peşinin zıddı veresiyedir; bedel sonra ödenir. Yüksek, tam ve pahalı ödeme zamanıyla ilgili değildir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('soğukkanlı', 'Zor durumda paniğe kapılmayan, sakin davranan.', 'kelime', 'sifat', 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 8, null, '“Yangın çıkınca soğukkanlı davranan görevli herkesi sakinleştirdi.” cümlesindeki “soğukkanlı” sözcüğüyle zıt anlamlı olan hangisidir?', '["sessiz","telaşlı","yavaş","yorgun"]'::jsonb, 1, null, null, 'Soğukkanlının zıddı telaşlıdır. Sessiz, yavaş ve yorgun paniğe kapılma durumunun karşıtı değildir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('tutumlu', 'Parayı ve eşyayı gereksiz harcamayan.', 'kelime', 'sifat', 8, 8, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 8, null, '“Harçlığını tutumlu kullanan biri ay sonunda para biriktirir.” cümlesindeki “tutumlu” sözcüğüyle zıt anlamlı olan hangisidir?', '["ihtiyatlı","çalışkan","savurgan","yoksul"]'::jsonb, 2, null, null, 'Tutumlunun zıddı savurgandır. İhtiyatlı tutumluya yakındır; çalışkan ve yoksul harcama biçimini anlatmaz.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('esnek', 'Kolay bükülen, duruma göre değişebilen.', 'kelime', 'sifat', 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 8, null, '“Okulun yeni ders programı esnek bir yapıya sahipti.” cümlesindeki “esnek” sözcüğüyle zıt anlamlı olan hangisidir?', '["ince","hızlı","hafif","katı"]'::jsonb, 3, null, null, 'Esneğin zıddı katıdır; katı olan kolay değişmez. İnce, hızlı ve hafif bu özelliğin karşıtı değildir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('gizli', 'Başkalarından saklanan, bilinmeyen.', 'kelime', 'sifat', 8, 8, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 8, null, '“Toplantıda alınan karar kamuoyundan gizli tutuldu.” cümlesindeki “gizli” sözcüğüyle zıt anlamlı olan hangisidir?', '["aleni","yakın","sert","küçük"]'::jsonb, 0, null, null, 'Gizlinin zıddı alenidir; aleni olan herkesçe bilinir. Yakın, sert ve küçük gizlilikle ilgili değildir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('baş göstermek', 'Daha önce görünmeyen bir durumun ortaya çıkması.', 'deyim', null, 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 8, null, '“Kuraklık yüzünden bölgede su sıkıntısı baş gösterdi.” cümlesindeki “baş göstermek” deyimi hangi anlamda kullanılmıştır?', '["ortaya çıkmak","yok olmak","azalmak","geri çekilmek"]'::jsonb, 0, null, null, 'Baş göstermek, bir durumun ortaya çıkması demektir. Yok olmak, azalmak ve geri çekilmek tam tersi ya da farklı anlamlardır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
end
$olcek$;
commit;