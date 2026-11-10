---
baslik: "Bulut Postacısının Son Mektubu"
slug: "hr024-bulut-postacisinin-son-mektubu"
fis_kodu: "HR-024"
tur: fantastik
konu: yon_adres
sinif_alt: 3
sinif_ust: 3
okuma_bandi: 2
dunya_tipi: masalsi
izinli_turler: [hayali]
deger_anahtarlari: [D16, D5]
yetiskin_uygun: false
tanitim: "Zarftaki adres yanlış mı, yoksa pusula mı yanılıyor? Pofuduk doğru eve nasıl ulaştı?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 3
  okuma_zorlugu: 2
  kavram_zorlugu: 2
  ilgi_egilimi: ortak
  temalar: [kesif, dostluk]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D16
    yardimci_deger: D5
  ogrenme_hedefleri:
    - {id: pusula_hr024, tur: lexeme, etiket: "pusula", yuva: hr024_pusula, islev: first_hint}
    - {id: adres_hr024, tur: lexeme, etiket: "adres", yuva: hr024_adres, islev: application}
    - {id: yon_hr024, tur: lexeme, etiket: "yön", yuva: hr024_yon, islev: application}
    - {id: deyim_hr024, tur: idiom, etiket: "Gözleri parlamak", yuva: hr024_gozleri_parladi, islev: application}
    - {id: kavram_hr024, tur: concept, etiket: "Yön bilgisi ile süs arasındaki fark", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (3. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pass, ajan_b: pass, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, dayanak: "Zarfın üstünde bir {kelime:hr024_adres} ve bir ad yazılıydı: Kuzey Tepesi, Mavi Pencereli Ev, Sevgi Teyze.", metin: "Zarfın üstündeki adres neresiydi?", secenekler: [{id: A, metin: "Güney Vadisi, Mavi Pencereli Ev"}, {id: B, metin: "Kuzey Tepesi, Mavi Pencereli Ev"}, {id: C, metin: "Kuzey Tepesi, Kırmızı Çatılı Ev"}], dogru: B, aciklama: "Zarfın üstünde Kuzey Tepesi, Mavi Pencereli Ev yazıyordu."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 1, dayanak: "Pusulanın oku kuzeyi gösteriyordu ama kendisi güneye ilerliyordu.", metin: "Postacı yolunu şaşırdığını hangi bilgiyle anladı?", secenekler: [{id: A, metin: "Pusula başka yönü gösteriyordu"}, {id: B, metin: "Çantası aniden hafiflemişti"}, {id: C, metin: "Yağmur Bulutu yolunu kesmişti"}], dogru: A, aciklama: "Pusulanın oku kuzeyi gösteriyordu, postacı ise güneye gidiyordu."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 2, dayanak: "Yıldız yön göstermiyordu; yalnızca pulun süsüydü.", metin: "Pulun üstündeki yıldız postacıya neden yol göstermedi?", secenekler: [{id: A, metin: "Yağmurda silinmişti"}, {id: B, metin: "Çok küçük kalmıştı"}, {id: C, metin: "Yalnızca bir süstü"}], dogru: C, aciklama: "Yıldız yön göstermiyordu; pulun süsüydü."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 2, dayanak: "İkisi birlikte {kelime:hr024_yon} değiştirdi.", metin: "“İkisi birlikte yön değiştirdi” cümlesinde yön ne demektir?", secenekler: [{id: A, metin: "Zarfın üstündeki resim"}, {id: B, metin: "Gidilecek doğrultu"}, {id: C, metin: "Mektubun kâğıdı"}], dogru: B, aciklama: "Yön, bir yere giderken izlenen doğrultudur."}
deyim_cumleleri:
  hr024_gozleri_parladi: "Zarfı açınca gözleri parladı."
---
@omurga
Bulutlar Şehri'nde herkesin bir görevi vardı. Yağmur Bulutu bahçeleri sular, {yoldas:yalin|bir arkadaş} yelkenlere yardım eder, Postacı {kahraman} ise mektupları götürürdü. Sabah güneşi bulutların kenarlarını pembeye boyamıştı. O sabah {kahraman:ilgi} çantasında yalnızca bir zarf kalmıştı. Zarfın üstünde bir {kelime:hr024_adres} ve bir ad yazılıydı: Kuzey Tepesi, Mavi Pencereli Ev, Sevgi Teyze.

{kahraman} kuzeye uçtuğunu sanıyordu. Birkaç dakika sonra altında deniz yerine kocaman bir çöl gördü. “Bu işte bir terslik var,” diye mırıldandı. Çantasından {kelime:hr024_pusula} çıkardı. Pusulanın oku kuzeyi gösteriyordu ama kendisi güneye ilerliyordu.

{yoldas:yalin|bir arkadaş} yanına sokuldu. “Yelkenleri çevirirken seni yanlış yöne ben ittim, özür dilerim.”

“Sorun değil,” dedi {kahraman}. “Ama mektup sahibini bekletmeyelim.”
---
@omurga
İkisi birlikte {kelime:hr024_yon} değiştirdi. Pusulanın okunu izleyip kuzeye döndüler. Aşağıda mısır tarlaları, küçük köyler ve kıvrılan bir dere görünüyordu. {kahraman} her tepeye bakıp pusulayla karşılaştırdı. Derken birbirine benzeyen iki tepe gördüler. Birinde kırmızı çatılı, ötekinde mavi pencereli bir ev vardı. {kahraman} hemen aşağı inecekti ama mavi pencere güneş ışığından mı mavi görünüyordu, yoksa gerçekten maviye mi boyanmıştı?

Aşağıdaki kuş sürüsüne seslendi. Kuşların lideri, mavi pencereli evin ikinci tepede olduğunu söyledi. {kahraman} teşekkür edip ikinci tepeye doğru süzüldü.

Yolda çantasına baktı. Zarfın köşesindeki pulun üstünde küçük bir yıldız vardı. {kahraman} yıldızın yol gösterdiğini düşünüp çevresine bakındı. Yıldız yön göstermiyordu; yalnızca pulun süsüydü. {isaret:yildiz}
---
@omurga
Tam mektubu bırakacağı sırada evin penceresi açıldı. İçeriden bir ses, “Mavi pencereyi mi arıyorsun?” diye sordu. {kahraman} adresi bir kez daha okudu. Zarfın üstündeki adı kapının yanındaki levhayla karşılaştırdı. İkisi de Sevgi Teyze yazıyordu. Ancak ondan sonra yaklaşıp mektubu verdi.

Yaşlı teyze mektubu titreyen elleriyle aldı. [[deyim:hr024_gozleri_parladi]] Uzakta okuyan torunu, kendi yaptığı bir çizimi göndermişti. Altında şöyle yazıyordu: “Büyüyünce bulut ressamı olacağım.”

Teyze çizimi pencerenin önündeki saksının yanına dayadı. Pencereden giren güneş kâğıdın üzerine düştü ve çizimdeki bulutlar gerçekmiş gibi parladı.
---
@omurga
{kahraman}, dönüş yolunda boş çantasını omzunda sallayarak uçtu. Altından geçen bulutlar ona el salladı. Rüzgâr tüylerini okşadı, çantası hafifçe sallandı.

Bulutlar Şehri'ne varınca pusulasını girişteki panoya astı. {yoldas:yalin|bir arkadaş} pusulaya baktı. “Bir dahaki sefere haritayı da birlikte açalım,” dedi. İkisi gülüştü, sonra Yağmur Bulutu'nun bahçeleri suladığı yere doğru yürüdüler.
