begin;
select set_config('request.jwt.claims', json_build_object('sub', (select id from public.profiles where role = 'admin' order by id limit 1), 'role', 'authenticated')::text, true);
do $olcek$
declare v_id uuid; v_anlam uuid;
begin
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('göz yummak', 'Bir yanlışı bile bile görmezden gelmek.', 'deyim', null, 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 8, null, '“Müdür, küçük hatalara göz yumdu.” cümlesindeki “göz yummak” deyimi ne anlama gelir?', '["görmezlikten gelmek","hemen cezalandırmak","yakından incelemek","çok önemsemek"]'::jsonb, 0, null, null, 'Göz yummak, bir yanlışı bilerek görmezden gelmek demektir. Diğer şıklar tam tersi bir tutumu anlatır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('burnu büyümek', 'Başarı ya da övgüyle kendini diğerlerinden üstün görmek.', 'deyim', null, 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 8, null, '“Ödül alınca burnu büyüdü.” cümlesindeki “burnu büyümek” deyimi ne anlama gelir?', '["çok sevinmek","sinirlenmek","korkmak","kendini beğenmek"]'::jsonb, 3, null, null, 'Burnu büyümek, kendini beğenip böbürlenmek demektir. Sevinmek, sinirlenmek ve korkmak bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ipin ucunu kaçırmak', 'Bir işin gidişatını denetleyemez olmak.', 'deyim', null, 8, 8, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 8, null, '“Konuşmayı uzatınca ipin ucunu kaçırdı.” cümlesindeki “ipin ucunu kaçırmak” deyimi ne anlama gelir?', '["işi bitirmek","kontrolü yitirmek","işten vazgeçmek","yardım istemek"]'::jsonb, 1, null, null, 'İpin ucunu kaçırmak, işin denetimini kaybetmek demektir. Diğer şıklar bu anlama uymaz.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('dört elle sarılmak', 'Bir işe büyük istek ve gayretle başlamak.', 'deyim', null, 8, 8, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 8, null, '“Yeni projeye dört elle sarıldı.” cümlesindeki “dört elle sarılmak” deyimi ne anlama gelir?', '["aceleyle bırakmak","korkarak denemek","uzaktan izlemek","büyük istekle girişmek"]'::jsonb, 3, null, null, 'Dört elle sarılmak, bir işe bütün gücüyle ve isteyerek girişmek demektir. Diğer şıklar bu anlamı taşımaz.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ayak uydurmak', 'Yeni bir duruma ya da düzene uyum sağlamak.', 'deyim', null, 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 8, null, '“Yeni düzene kısa sürede ayak uydurdu.” cümlesindeki “ayak uydurmak” deyimi ne anlama gelir?', '["uyum sağlamak","yön değiştirmek","hızlanmak","geri kalmak"]'::jsonb, 0, null, null, 'Ayak uydurmak, yeni duruma uyum sağlamak demektir. Diğer şıklar bu anlamı karşılamaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Damlaya damlaya göl olur.', 'Azar azar biriken şeyler zamanla büyük miktara ulaşır.', 'atasozu', null, 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 8, null, '“Damlaya damlaya göl olur.” atasözü aşağıdaki durumlardan hangisini anlatır?', '["Büyük işlerin çabuk bitmesi","Harcamaların hiç bitmemesi","Küçük birikimlerin zamanla büyümesi","Yağmurun sürekli yağması"]'::jsonb, 2, null, null, 'Atasözü, küçük birikimlerin zamanla büyük bir değer olacağını anlatır. Diğer şıklar bu anlama uymaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Ağaç yaşken eğilir.', 'Eğitim ve alışkanlık küçük yaşta daha kolay kazandırılır.', 'atasozu', null, 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 8, null, '“Ağaç yaşken eğilir.” atasözü aşağıdaki durumlardan hangisini anlatır?', '["Eğitimin küçük yaşta daha etkili olması","Ağaçların nemli toprakta güçlü büyümesi","Bitkilerin güneşte hızla gelişmesi","Büyüklerin eski huylarını bırakması"]'::jsonb, 0, null, null, 'Yaş ağaç kolay eğilir; çocuklar da kolay yönlendirilir. Diğer şıklar bu söze uygun değildir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Sakla samanı, gelir zamanı.', 'Şimdi değersiz görünen şey ileride işe yarayabilir.', 'atasozu', null, 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 8, null, '“Sakla samanı, gelir zamanı.” atasözü aşağıdaki durumlardan hangisini anlatır?', '["Saman satmanın çok kazandırması","Elde olanın ileride işe yarayabilmesi","Zamanı boşa harcamanın zararı","Her işin bir mevsiminin olması"]'::jsonb, 1, null, null, 'Atasözü, elindeki şeyi atmayıp saklamanın ileride yarar sağlayacağını anlatır. Diğer şıklar bu anlama uymaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('Bir elin nesi var, iki elin sesi var.', 'Birlikte yapılan işlerde başarı daha kolaydır.', 'atasozu', null, 8, 8, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'atasozu', 8, null, '“Bir elin nesi var, iki elin sesi var.” atasözü aşağıdaki durumlardan hangisini anlatır?', '["Elleri güçlü insanın çok çalışması","Sesi güzel olanın çok alkış alması","Tek başına çalışanın daha hızlı bitirmesi","Birlikte yapılan işin daha güçlü olması"]'::jsonb, 3, null, null, 'Atasözü, iş birliğinin tek başına çalışmaktan daha güçlü olduğunu anlatır. Diğer şıklar bu anlama uymaz.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('çabucak', 'Çok hızlı bir biçimde.', 'kelime', 'zarf', 8, 8, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'sozcuk_turu', 8, null, '“Yolcu otobüse çabucak bindi.” cümlesindeki “çabucak” sözcüğünün türü nedir?', '["zarf","sıfat","isim","fiil"]'::jsonb, 0, null, null, 'Çabucak, bindi eyleminin nasıl yapıldığını bildirir; zarftır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('yüksek', 'Yerden uzaklığı çok olan.', 'kelime', 'sifat', 8, 8, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'sozcuk_turu', 8, null, '“Yüksek dağın tepesinde kar vardı.” cümlesindeki “yüksek” sözcüğünün türü nedir?', '["zarf","sıfat","isim","fiil"]'::jsonb, 1, null, null, 'Yüksek, dağ adını niteler; sıfattır.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('yandı', 'Işık vermeye başladı.', 'kelime', 'fiil', 8, 8, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'sozcuk_turu', 8, null, '“Akşam olunca sokak lambaları yandı.” cümlesindeki “yandı” sözcüğünün türü nedir?', '["zarf","sıfat","fiil","isim"]'::jsonb, 2, null, null, 'Yandı, bir iş ya da oluş bildirir; fiildir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('sessizlik', 'Hiç ses olmama durumu.', 'kelime', 'isim', 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'sozcuk_turu', 8, null, '“Kütüphanedeki sessizlik herkesi etkiledi.” cümlesindeki “sessizlik” sözcüğünün türü nedir?', '["fiil","zarf","sıfat","isim"]'::jsonb, 3, null, null, 'Sessizlik, varlık ya da durum adıdır; isimdir. Fiil, zarf ve sıfat değildir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('herkes', 'Bir topluluktaki bütün kişiler.', 'kelime', 'zamir', 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'sozcuk_turu', 8, null, '“Herkes toplantıya zamanında geldi.” cümlesindeki “herkes” sözcüğünün türü nedir?', '["zamir","isim","sıfat","zarf"]'::jsonb, 0, null, null, 'Herkes, belli bir kişinin adı yerine geçen belgisiz bir zamirdir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('ama', 'Karşıtlık bildiren sözcük.', 'kelime', 'baglac', 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'sozcuk_turu', 8, null, '“Çok çalıştı ama sonuç alamadı.” cümlesindeki “ama” sözcüğünün türü nedir?', '["zamir","bağlaç","zarf","sıfat"]'::jsonb, 1, null, null, 'Ama, iki cümleyi karşıtlık ilişkisiyle bağlar; bağlaçtır.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('mahcup', 'Utanmış, çekinmiş.', 'kelime', 'sifat', 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 8, null, '“Kalabalık salonda mahcup olan konuşmacının yüzü kızardı, sözleri boğazında düğümlendi.” cümlesindeki “mahcup” sözcüğü ne anlama gelir?', '["öfkeli","heyecanlı","yorgun","utanmış"]'::jsonb, 3, null, null, 'Yüzün kızarması ve sözlerin düğümlenmesi utancı gösterir. Mahcup, utanmış demektir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('azim', 'Bir işi yapmakta kararlı olma.', 'kelime', 'isim', 8, 8, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 8, null, '“Sınav haftasında azimle çalışan öğrenci, yorulsa da bırakmadı ve sonunda hedefine ulaştı.” cümlesindeki “azimle” sözcüğü ne anlama gelir?', '["kararlılıkla","tembellikle","telaşla","korkuyla"]'::jsonb, 0, null, null, 'Yorulsa da bırakmayıp hedefe ulaşmak kararlılığı gösterir. Azim, kararlılık demektir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('mamur', 'Bakımlı, gelişmiş, bayındır.', 'kelime', 'sifat', 8, 8, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 8, null, '“Köyün mamur sokaklarında yeni evler, temiz yollar ve çiçekli bahçeler vardı.” cümlesindeki “mamur” sözcüğü ne anlama gelir?', '["ıssız ve karanlık","dar ve kalabalık","soğuk ve karlı","gelişmiş ve düzenli"]'::jsonb, 3, null, null, 'Yeni evler, temiz yollar ve çiçekli bahçeler gelişmiş ve düzenli bir yeri anlatır. Mamur bu demektir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('haberci', 'Bir şeyin geleceğini önceden bildiren.', 'kelime', 'isim', 8, 8, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 8, null, '“Hava bulutlandı, rüzgâr sertleşti; denizciler fırtınanın habercisi olan bu belirtileri hemen fark etti.” cümlesindeki “habercisi” sözcüğü ne anlama gelir?', '["önceden bildiren","sonradan gelen","sakinleştiren","yok eden"]'::jsonb, 0, null, null, 'Bulutlanma ve sert rüzgâr fırtınanın geleceğini önceden bildirir. Haberci, önceden bildiren demektir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('mahir', 'Bir işi çok iyi yapan, becerikli.', 'kelime', 'sifat', 8, 8, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 8, null, '“Yaşlı usta, mahir elleriyle birkaç dakikada bozuk saati onardı.” cümlesindeki “mahir” sözcüğü ne anlama gelir?', '["titrek","yorgun","nasırlı","becerikli"]'::jsonb, 3, null, null, 'Bozuk saati birkaç dakikada onarmak ustalık ve beceriyi gösterir. Mahir, becerikli demektir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
end
$olcek$;
commit;