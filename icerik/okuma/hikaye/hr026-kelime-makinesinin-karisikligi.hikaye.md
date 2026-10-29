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
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Yoldaşın cümlesindeki yüz sözcüğü neyi anlatıyor?", secenekler: [{id: A, metin: "Sayıyı, yüz tane sayfayı"}, {id: B, metin: "İnsanın suratını"}, {id: C, metin: "Bir yüzeyi"}], dogru: A, aciklama: "Mert'in cümlesinde yüz sayı anlamında kullanılıyor."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 3, metin: "Kahraman cümlelerdeki anlamı nasıl buldu?", secenekler: [{id: A, metin: "Makineyi kapatarak"}, {id: B, metin: "Kartları karıştırarak"}, {id: C, metin: "Kelimenin yanındaki sözcüklerden yararlanarak"}], dogru: C, aciklama: "Yanındaki sözcükler anlamı seçmeye yardımcı oluyordu."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 3, metin: "Kahramanın “Sorular bazen cevaptan daha işe yarar” düşüncesi neyi gösterir?", secenekler: [{id: A, metin: "Soru sormanın öğrenmeyi desteklediğini"}, {id: B, metin: "Soru işareti çizilmemesi gerektiğini"}, {id: C, metin: "Dedenin hiç cevap vermediğini"}], dogru: A, aciklama: "Makinenin hatasını bulmak için sorular sormak, çocukları düşündürdü."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 2, metin: "“Bize kâr kaldı” cümlesinde kâr sözcüğü ne anlama gelir?", secenekler: [{id: A, metin: "Kar yağışı"}, {id: B, metin: "Kırmızı renk"}, {id: C, metin: "Kazanç, para artışı"}], dogru: C, aciklama: "Kâr, bir işten elde edilen kazançtır."}
deyim_cumleleri:
  hr026_iki_buklum: "{yoldas:yalin|bir arkadaş} gülmekten iki büklüm oldu."
---
@omurga
{kahraman:ilgi} dedesi, kelimelerle oynayan küçük bir makine yapmıştı. Makinenin üstünde üç düğme vardı: Oku, Düşün, Söyle. {kahraman} ilk düğmeye bastığında ekranda şu cümle belirdi: Bahçedeki {kelime:hr026_gul} bana güldü.

“Çiçek mi kahkaha attı?” diye sordu kardeşi {yoldas:yalin|bir arkadaş}.

Makine cümleyi yorumlamak yerine masaya kırmızı bir gül resmi çizdi ve yanına kahkaha işareti koydu. {kahraman}, “İkisi de gül diye yazılıyor ama aynı anlama gelmiyor,” dedi.

Dede gülümsedi. “Demek ki bir kelimenin nerede kullanıldığını anlamak gerekiyor.”

{yoldas:yalin|bir arkadaş} yeni cümleyi söyledi: “Dedem {kelime:hr026_yuz} sayfasını okudu.” Makine masaya yüz tane yüz resmi çizdi.[[deyim:hr026_iki_buklum]] “Ben sayıyı söyledim!”
---
@omurga
{kahraman} defterine örnekleri yazdı. Bir tarafta yüz sayısı, diğer tarafta yüz sözcüğünün insanın suratı anlamı vardı. Sonra kardeşinden yeni bir örnek istedi. {yoldas:yalin|bir arkadaş} hemen, “Yaz geldi, sen de yaz!” dedi. Makine ekrana güneş resmi ve bir kalem çizdi. Bu kez doğruya yaklaşmıştı. {isaret:kitap}

Dede, masaya iki kart daha koydu. Birinde “Kışın {kelime:hr026_kar} yağdı”, diğerinde “Bize kâr kaldı” yazıyordu. {kahraman} harfleri dikkatle inceledi. “Bunlar aynı yazılmıyor; sesleri de tam aynı değil,” dedi. Dede onayladı: “Her benzer kelimeyi aynı gruba koyamayız.” {yoldas:yalin|bir arkadaş} de yeni bir kart istedi. “O zaman yalnız gerçekten aynı yazılan ve farklı anlamlara gelen örneklerle başlayalım.”
---
@omurga
Makine bu uyarıyı duyunca ekrana büyük bir soru işareti çıkardı. {kahraman}, “**Sorular bazen cevaptan daha işe yarar**,” diye düşündü. Makinenin hatasını bulmak, düğmelerine rastgele basmaktan daha çok zaman almış ama daha eğlenceli olmuştu.

{kahraman} bütün cümlelerin küçük bir ipucu taşıdığını fark etti. “Yaz geldi” derken mevsimden söz ediyorlardı. “Sen de yaz” derken ise kalemle bir şeyler yazmayı istiyorlardı. Kelimenin yanındaki başka sözcükler anlamı bulmalarını sağlıyordu.

Dede, “Peki makinenin hatasını nasıl azaltacağız?” diye sordu. {kahraman} bir kural kartı hazırladı: Önce tüm cümleyi oku; sonra kelimenin anlamını seç. Kartı makinenin yanına koydular.
---
@omurga
Son denemede {yoldas:yalin|bir arkadaş}, “Çay kıyısında çay içtik,” dedi. Makine bu kez su akan bir dere ile iki fincan çizdi. İki kardeş sevinçle alkışladı.

Ancak makine beklenmedik bir soru sordu: “Peki kelimelerin iki anlamı varsa, insanların da bazen birden fazla duygusu olur mu?”

{kahraman} biraz düşündü. “Olur,” dedi. “Hem heyecanlı hem çekingen olabilirim.” Dede ona bakıp gülümsedi. Bir kelime oyunu, o gün yeni bir konuşmanın kapısını açmıştı.

Dil hedefi: sesteş/homograf kullanımlar: gül, yüz, yaz, çay; Kavram/değer: bağlam, çok anlamlılık, esnek düşünme. İkon önerileri: robot, sözlük, konuşma balonu. Okuma sonrası: “Yaz geldi, sen de yaz” cümlesindeki iki yazın anlamı nedir?
