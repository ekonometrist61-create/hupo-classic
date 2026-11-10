---
baslik: "Kelime Makinesinin Karışıklığı"
slug: "hr026-kelime-makinesinin-karisikligi"
fis_kodu: "HR-026"
tur: bilim_kurgu
konu: cok_anlamlilik
sinif_alt: 3
sinif_ust: 3
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler: [ben, arkadas, hayali]
deger_anahtarlari: [D14, D6]
yetiskin_uygun: false
tanitim: "Makine neden gülü yanlış anlıyor? Aynı yazılan kelimeler farklı anlam taşıyınca ne olur?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 3
  okuma_zorlugu: 3
  kavram_zorlugu: 3
  ilgi_egilimi: ortak
  temalar: [okul, mizah]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D14
    yardimci_deger: D6
  ogrenme_hedefleri:
    - {id: gul_hr026, tur: lexeme, etiket: "gül", yuva: hr026_gul, islev: first_hint}
    - {id: yuz_hr026, tur: lexeme, etiket: "yüz", yuva: hr026_yuz, islev: application}
    - {id: kar_hr026, tur: lexeme, etiket: "kâr", yuva: hr026_kar, islev: application}
    - {id: deyim_hr026, tur: idiom, etiket: "İki büklüm olmak", yuva: hr026_iki_buklum, islev: application}
    - {id: kavram_hr026, tur: concept, etiket: "Bağlama göre anlam", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (3. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: review_needed, ajan_b: review_needed, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 2, dayanak: "Makine masaya yüz tane insan yüzü çizdi.", metin: "Makine, “Dedem yüz sayfa okudu” cümlesi için ne çizdi?", secenekler: [{id: A, metin: "Bir kitap ve bir kalem"}, {id: B, metin: "Yüz tane insan yüzü"}, {id: C, metin: "Kırmızı bir gül resmi"}], dogru: B, aciklama: "Makine yüz sözcüğünü insan yüzü sanıp yüz tane yüz çizdi."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 3, dayanak: "“Yaz geldi” derken mevsimden söz ediyorlardı.", metin: "Makine “Yaz geldi, sen de yaz!” cümlesi için neden hem güneş hem kalem çizdi?", secenekler: [{id: A, metin: "Çizim yapmayı her zaman çok severdi"}, {id: B, metin: "Cümlenin yarısını eksik okumuştu"}, {id: C, metin: "Cümledeki iki yaz ayrı anlamdaydı"}], dogru: C, aciklama: "Birinci yaz mevsimi, ikinci yaz kalemle yazmayı anlatıyordu; makine ikisini de gösterdi."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 3, dayanak: "Cümleyi ikiye böldü ve her parçayı yanındaki sözcüklerle birlikte okudu.", metin: "Makinenin hatasını bulmada hangi yol işe yaradı?", secenekler: [{id: A, metin: "Düğmelere art arda rastgele basmak"}, {id: B, metin: "Cümleyi yanındaki sözcüklerle okumak"}, {id: C, metin: "Dededen yepyeni bir makine istemek"}], dogru: B, aciklama: "Düğmelere basmak işe yaramadı; cümleyi yanındaki sözcüklerle okuyunca anlam anlaşıldı."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 4, dayanak: "Dede kâr sözcüğünün bir işten geriye kalan kazanç olduğunu söyledi.", metin: "“Bize kâr kaldı” sözünde kâr ne demektir?", secenekler: [{id: A, metin: "Bir işten kalan kazanç"}, {id: B, metin: "Gökten düşen beyaz taneler"}, {id: C, metin: "Kırmızı bir gül rengi"}], dogru: A, aciklama: "Kâr, bir işten geriye kalan kazanç demektir."}
deyim_cumleleri:
  hr026_iki_buklum: "{yoldas:yalin|bir arkadaş} gülmekten iki büklüm oldu."
---
@omurga
{kahraman:ilgi} dedesi, kelimelerle oynayan küçük bir makine yapmıştı. Makinenin üstünde üç düğme vardı: Oku, Düşün, Söyle. {kahraman} ilk düğmeye bastığında ekranda şu cümle belirdi: Bahçedeki {kelime:hr026_gul} bana güldü.

“Çiçek mi kahkaha attı?” diye sordu kardeşi {yoldas:yalin|bir arkadaş}.

Makine cümleyi yorumlamak yerine masaya kırmızı bir gül resmi çizdi ve yanına kahkaha işareti koydu. {kahraman}, “İkisi de gül diye yazılıyor ama aynı anlama gelmiyor,” dedi. Dede gülümseyip makineye yeni bir cümle yazdırdı. Makinenin fanı hafifçe vızıldadı.
---
@omurga
{yoldas:yalin|bir arkadaş} yeni cümleyi yüksek sesle okudu: “Dedem {kelime:hr026_yuz} sayfa okudu.” Makine masaya yüz tane insan yüzü çizdi. [[deyim:hr026_iki_buklum]] {kahraman}, “Makine, o yüz değil, sayı olan yüz!” dedi.

{kahraman} defterine iki sütun çizdi. Bir yanına yüz sayısını, öbür yanına insan yüzünü yazdı. Sonra kardeşinden yeni bir örnek istedi. {yoldas:yalin|bir arkadaş} hemen, “Yaz geldi, sen de yaz!” dedi. Makine ekrana bir güneş ve bir kalem çizdi. {isaret:kitap}
---
@omurga
{kahraman} önce düğmelere rastgele bastı. Makine ekrana kalem, güneş ve bir bulut çizip ışıklarını yanıp söndürdü. “Böyle olmayacak,” dedi {kahraman}.

Cümleyi ikiye böldü ve her parçayı yanındaki sözcüklerle birlikte okudu. “Yaz geldi” derken mevsimden söz ediyorlardı. “Sen de yaz” derken ise kalemle bir şeyler yazmayı istiyorlardı. Makine bu kez ekrana yalnızca bir güneş çizdi, hemen altına da “Sen de yaz” diye yazdı.

Dede yanlarına oturup gözlüğünü düzeltti. “Makinenin hatasını nasıl azaltacağız?” diye sordu. {kahraman} bir kural kartı hazırladı: Önce tüm cümleyi oku. Kartı makinenin yanına koydular.
---
@omurga
Dede masaya iki kart daha koydu. Birinde “Kışın kar yağdı”, ötekinde “Bize {kelime:hr026_kar} kaldı” yazıyordu. {kahraman} kartlara dikkatle baktı. “Bunlar aynı yazılmıyor,” dedi. “Birinin üstünde şapka var.” Dede kâr sözcüğünün bir işten geriye kalan kazanç olduğunu söyledi.

{yoldas:yalin|bir arkadaş} ikinci kartı makineye okuttu. Makine bu kez karlı bir dağ yerine bozuk paralarla dolu bir kutu çizdi.

Son denemede {yoldas:yalin|bir arkadaş}, “Çay kıyısında çay içtik,” dedi. Makine su akan bir dere ile iki fincan çizdi. İki kardeş sevinçle alkışladı.

Makine beklenmedik bir soru sordu: “Kelimelerin iki anlamı olabiliyorsa, insanın aynı anda iki duygusu olur mu?” {kahraman} biraz düşündü. “Olur,” dedi. “Hem heyecanlı hem çekingen olabilirim.” Dede ona bakıp gülümsedi.
