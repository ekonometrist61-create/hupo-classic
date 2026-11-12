// Halka açık örnek çalışma soruları (3–7. sınıf, sınıf başına 5 soru).
// Tüm sorular bu dosyada Hupo için özgün yazılmıştır; MEB veya yayınevi sorusu çoğaltılmaz, resmî sınav sorusu değildir.
// Cevap anahtarı tek ve kesindir; seçenek sırası harf dağılımı çeşitli olsun diye bilerek karıştırılmıştır,
// doğru cevap harf değil `dogru` dizini ile tutulur. Hiçbir yere kaydedilmez.
// Kazanım kodu yazılmaz (kaynak teyidi yok); 4. sınıf önceki programdadır, TYMM kodu kullanılmaz.
// Şekilli sorularda şekil `sekil` ile tanımlanır ve DemoFigure.tsx içinde koddan çizilir; cevap şekilden okunur.

export type DemoSinif = 3 | 4 | 5 | 6 | 7;

/** Veli özetinde gruplanan beceri kodları; metinler messages dosyalarında (demo.beceri.<kod>). */
export type DemoBeceri = "sozcuk" | "dilbilgisi" | "sayilar" | "geometri" | "veri" | "fen" | "sosyal";

export type DemoSekil =
  | { tip: "kesir"; parca: number; boyali: number; alt: string }
  | { tip: "sutun"; baslik: string; veri: { ad: string; deger: number }[]; max: number; adim: number; alt: string }
  | { tip: "dikdortgen"; en: number; boy: number; birim: string; alt: string }
  | { tip: "devre"; anahtarAcik: boolean; alt: string }
  | {
      tip: "sayidogrusu";
      min: number;
      max: number;
      adim: number;
      etiketAdim: number;
      noktalar: { ad: string; deger: number }[];
      alt: string;
    }
  | { tip: "gruplar"; a: { ad: string; sayi: number }; b: { ad: string; sayi: number }; alt: string }
  | { tip: "ucgen"; a: number; b: number; alt: string }
  | {
      tip: "grafik";
      xEtiket: string;
      yEtiket: string;
      xMax: number;
      yMax: number;
      yAdim: number;
      noktalar: [number, number][];
      alt: string;
    };

export interface DemoQuestion {
  id: string;
  sinif: DemoSinif;
  ders: string;
  beceri: DemoBeceri;
  /** **kalın** işaretli kısımlar altı çizili vurgulanır. */
  soru: string;
  sekil?: DemoSekil;
  /** Seçeneklerde de **altı çizili** işaret kullanılabilir. */
  secenekler: [string, string, string, string];
  /** `secenekler` içindeki doğru seçeneğin dizini (0-3). */
  dogru: 0 | 1 | 2 | 3;
  adimlar: string[];
  /** Yanlış seçeneğin neden cazip göründüğünü kısaca anlatır; yanlış seçilen seçenek için gösterilir. */
  tuzaklar?: Partial<Record<0 | 1 | 2 | 3, string>>;
}

export const DEMO_SINIFLAR: DemoSinif[] = [3, 4, 5, 6, 7];

export const DEMO_QUESTIONS: DemoQuestion[] = [
  // ───────────── 3. sınıf ─────────────
  {
    id: "D3-01",
    sinif: 3,
    ders: "Türkçe",
    beceri: "sozcuk",
    soru: "“Sabah hava çok **soğuktu**.” cümlesinde altı çizili sözcüğün zıt anlamlısı aşağıdakilerden hangisidir?",
    secenekler: ["serindi", "yağmurluydu", "sıcaktı", "karanlıktı"],
    dogru: 2,
    adimlar: [
      "Zıt anlamlı sözcükler, anlamca birbirinin tersi olan sözcüklerdir.",
      "“Soğuk” sözcüğünün tersi “sıcak”tır.",
      "“Yağmurlu” ve “karanlık” sıcaklıkla ilgili değildir. “Serin” ise soğuğa yakın bir anlam taşır.",
    ],
    tuzaklar: { 0: "“Serin”, soğuğa çok yakındır. Yani zıt değil, yakın anlamlıdır." },
  },
  {
    id: "D3-02",
    sinif: 3,
    ders: "Matematik",
    beceri: "sayilar",
    soru: "Şekilde **taralı** kısım, bütünün kaçta kaçıdır?",
    sekil: {
      tip: "kesir",
      parca: 8,
      boyali: 3,
      alt: "Eş 8 parçaya bölünmüş bir şerit. Soldan 3 parça taralı, 5 parça boş.",
    },
    secenekler: ["5/8", "3/8", "3/5", "1/3"],
    dogru: 1,
    adimlar: [
      "Bütün 8 eş parçaya bölünmüş; bu yüzden payda 8’dir.",
      "Taralı parça sayısı 3’tür; bu yüzden pay 3’tür.",
      "Taralı kısım 3/8’dir. Taranmamış 5 parça ise 5/8’dir.",
    ],
    tuzaklar: {
      0: "5/8, taranmamış kısmı gösterir. Soru taralı kısmı soruyor.",
      2: "Payda, bütünün kaç eş parçaya bölündüğünü (8) gösterir; boş parçaların sayısını (5) değil.",
    },
  },
  {
    id: "D3-03",
    sinif: 3,
    ders: "Matematik",
    beceri: "veri",
    soru: "Grafiğe göre en çok oy alan meyve ile en az oy alan meyve arasındaki **fark** kaç oydur?",
    sekil: {
      tip: "sutun",
      baslik: "Sınıfın en sevdiği meyve (oy sayısı)",
      veri: [
        { ad: "Elma", deger: 6 },
        { ad: "Muz", deger: 9 },
        { ad: "Çilek", deger: 4 },
        { ad: "Kiraz", deger: 7 },
      ],
      max: 10,
      adim: 2,
      alt: "Sütun grafiği, sınıfın en sevdiği meyve oy sayıları: Elma 6, Muz 9, Çilek 4, Kiraz 7.",
    },
    secenekler: ["3", "7", "5", "13"],
    dogru: 2,
    adimlar: [
      "En çok oyu Muz almış: 9 oy.",
      "En az oyu Çilek almış: 4 oy.",
      "Fark için çıkarma yapılır: 9 − 4 = 5.",
    ],
    tuzaklar: {
      3: "13, iki sayının toplamıdır (9 + 4). Fark için çıkarma yapılır.",
      1: "7, Kiraz’ın oy sayısıdır; ne en çok ne en az oy alan meyvedir.",
    },
  },
  {
    id: "D3-04",
    sinif: 3,
    ders: "Fen Bilimleri",
    beceri: "fen",
    soru: "Gitarın teline dokununca ses duyarız. **Sesin** oluşmasının nedeni aşağıdakilerden hangisidir?",
    secenekler: ["Telin rengi değişir.", "Hava tamamen durur.", "Tel ısınıp erir.", "Tel titreşir."],
    dogru: 3,
    adimlar: [
      "Ses, titreşen cisimlerden yayılır.",
      "Gitar teli çalınınca hızla ileri geri hareket eder; yani titreşir.",
      "Bu titreşim havayı da titreştirir ve kulağımıza ulaşınca sesi duyarız.",
    ],
  },
  {
    id: "D3-05",
    sinif: 3,
    ders: "Sosyal Bilgiler",
    beceri: "sosyal",
    soru: "Doğu yönüne bakan bir çocuğun **sağ eli** hangi yönü gösterir?",
    secenekler: ["Güney", "Kuzey", "Batı", "Doğu"],
    dogru: 0,
    adimlar: [
      "Doğuya bakan kişinin önü doğu, arkası batıdır.",
      "Sol eli kuzeyi, sağ eli güneyi gösterir.",
      "Kolay hatırlama: Güneşin doğduğu yöne bakınca sol elin kuzeye, sağ elin güneye uzanır; yani sağ el güneyi gösterir.",
    ],
    tuzaklar: { 1: "Kuzey, sol elin gösterdiği yöndür. Sağ ve sol karışmış olabilir." },
  },

  // ───────────── 4. sınıf ─────────────
  {
    id: "D4-01",
    sinif: 4,
    ders: "Türkçe",
    beceri: "dilbilgisi",
    soru: "“Dere kenarında **minik** kuşlar ötüyordu.” cümlesinde altı çizili sözcük kuşların hangi özelliğini bildirir?",
    secenekler: ["Rengini", "Boyutunu", "Sayısını", "Bulunduğu yeri"],
    dogru: 1,
    adimlar: [
      "Varlıkların özelliğini bildiren sözcüklere sıfat denir. “Nasıl kuşlar?” sorusuyla bulunur.",
      "“Minik”, küçüklüğü, yani boyutu anlatır.",
      "Renk ve sayı cümlede hiç verilmemiş. “Dere kenarında” ise yeri bildirir; altı çizili sözcük değildir.",
    ],
    tuzaklar: { 3: "“Dere kenarında” yeri bildirir. Altı çizili “minik” ise kuşları tanıtır." },
  },
  {
    id: "D4-02",
    sinif: 4,
    ders: "Matematik",
    beceri: "geometri",
    soru: "Şekildeki dikdörtgenin **çevresi** kaç santimetredir?",
    sekil: {
      tip: "dikdortgen",
      en: 9,
      boy: 4,
      birim: "cm",
      alt: "Dikdörtgen: uzun kenarı 9 cm, kısa kenarı 4 cm.",
    },
    secenekler: ["26", "13", "36", "52"],
    dogru: 0,
    adimlar: [
      "Çevre, bütün kenar uzunluklarının toplamıdır.",
      "Karşılıklı kenarlar eşit olduğundan 9 + 4 + 9 + 4 = 26 cm bulunur.",
    ],
    tuzaklar: {
      1: "13, yalnız iki komşu kenarın toplamıdır (9 + 4). Çevre için dört kenarın hepsi toplanır.",
      2: "36, alandır (9 × 4). Soru çevreyi istiyor.",
    },
  },
  {
    id: "D4-03",
    sinif: 4,
    ders: "Matematik",
    beceri: "sayilar",
    soru: "Bir pakete 12 kalem konuluyor. 50 kalem **en çok** kaç tam paketi doldurur?",
    secenekler: ["5", "4", "6", "3"],
    dogru: 1,
    adimlar: [
      "50 ÷ 12 işleminde bölüm 4, kalan 2’dir.",
      "4 paket 4 × 12 = 48 kalem alır; geriye 2 kalem artar.",
      "Paket tam dolmak zorunda olduğu için cevap 4’tür.",
    ],
    tuzaklar: { 0: "5 paketi doldurmak için 60 kalem gerekir. Elimizde 50 var." },
  },
  {
    id: "D4-04",
    sinif: 4,
    ders: "Fen Bilimleri",
    beceri: "fen",
    soru: "Şekildeki devrede ampul **yanmıyor**. Ampulün yanması için ne yapılmalıdır?",
    sekil: {
      tip: "devre",
      anahtarAcik: true,
      alt: "Pil, ampul ve anahtardan oluşan elektrik devresi. Anahtar açık olduğu için devre anahtarın yerinde kesik.",
    },
    secenekler: [
      "Pili devreden çıkarıp kenara koymak",
      "Kabloları daha uzun kablolarla değiştirmek",
      "Anahtarı kapatıp devreyi tamamlamak",
      "Anahtarı olabildiğince çok açmak",
    ],
    dogru: 2,
    adimlar: [
      "Ampulün yanması için akımın pilden çıkıp ampulden geçerek pile dönebileceği kapalı bir yol gerekir.",
      "Şekilde anahtar açık olduğu için yol kesilmiş; akım geçemiyor.",
      "Anahtar kapatılınca devre tamamlanır ve ampul yanar.",
    ],
  },
  {
    id: "D4-05",
    sinif: 4,
    ders: "Sosyal Bilgiler",
    beceri: "sosyal",
    soru: "Her çocuğun okula gitme hakkı vardır. Aşağıdakilerden hangisi okula giden bir öğrencinin **sorumluluğudur**?",
    secenekler: [
      "Teneffüste arkadaşlarıyla oyun oynamak",
      "Okulun eşyalarına zarar vermemek",
      "Sınıfta izin almadan konuşmak",
      "Derse istediği saatte girmek",
    ],
    dogru: 1,
    adimlar: [
      "Hak, bir kişinin sahip olduğu ve kullanabildiği imkândır. Sorumluluk ise yapmamız gereken görevdir.",
      "Okulun ortak eşyalarını korumak, öğrencinin görevlerinden biridir.",
      "Oyun oynamak çocuğun bir hakkıdır. Diğer iki seçenek ise okul kurallarına aykırıdır.",
    ],
    tuzaklar: { 0: "Oyun oynamak çocuğun bir hakkıdır; görev (sorumluluk) değildir." },
  },

  // ───────────── 5. sınıf ─────────────
  {
    id: "D5-01",
    sinif: 5,
    ders: "Türkçe",
    beceri: "sozcuk",
    soru: "Aşağıdaki cümlelerin hangisinde altı çizili sözcük **mecaz anlamda** kullanılmıştır?",
    secenekler: [
      "Ali **soğuk** suyu bir dikişte içti.",
      "Komşumuz bize hep **soğuk** davrandı.",
      "**Soğuk** içecekleri buzdolabına koydu.",
      "Kış gecesinin **soğuk** havası camı buğulandırdı.",
    ],
    dogru: 1,
    adimlar: [
      "Gerçek anlam, sözcüğün asıl anlamıdır. Mecaz anlam ise sözcüğün asıl anlamından uzaklaşıp başka bir anlamda kullanılmasıdır.",
      "Soğuk su, soğuk içecek ve soğuk hava, sıcaklığı anlatır; hepsi gerçek anlamdır.",
      "“Soğuk davrandı” ise sıcaklığı değil, ilgisiz ve mesafeli olmayı anlatır; bu mecazdır.",
    ],
    tuzaklar: { 0: "“Soğuk su”, sıcaklığı düşük olan suyu anlatır; gerçek anlamdır." },
  },
  {
    id: "D5-02",
    sinif: 5,
    ders: "Matematik",
    beceri: "sayilar",
    soru: "Sayı doğrusunda **A** noktasına karşılık gelen ondalık gösterim hangisidir?",
    sekil: {
      tip: "sayidogrusu",
      min: 0,
      max: 1,
      adim: 0.1,
      etiketAdim: 10,
      noktalar: [{ ad: "A", deger: 0.7 }],
      alt: "0’dan 1’e kadar 10 eş aralığa bölünmüş sayı doğrusu. A noktası, 0’dan sonraki yedinci çizgidedir.",
    },
    secenekler: ["0,07", "0,17", "0,7", "7,0"],
    dogru: 2,
    adimlar: [
      "0 ile 1 arası 10 eş parçaya bölünmüş; her parça 0,1’dir.",
      "A noktası 0’dan 7 parça uzaktadır: 7 × 0,1 = 0,7.",
    ],
    tuzaklar: { 0: "0,07 “yüzde yedi”dir. A noktası ise “onda yedi”dedir." },
  },
  {
    id: "D5-03",
    sinif: 5,
    ders: "Matematik",
    beceri: "veri",
    soru: "Grafiğe göre dört günde toplam kaç sayfa **okunmuştur**?",
    sekil: {
      tip: "sutun",
      baslik: "Günlük okunan sayfa sayısı",
      veri: [
        { ad: "Pzt", deger: 25 },
        { ad: "Sal", deger: 40 },
        { ad: "Çar", deger: 15 },
        { ad: "Per", deger: 35 },
      ],
      max: 40,
      adim: 10,
      alt: "Sütun grafiği, günlük okunan sayfa sayısı: Pazartesi 25, Salı 40, Çarşamba 15, Perşembe 35.",
    },
    secenekler: ["115", "105", "125", "95"],
    dogru: 0,
    adimlar: [
      "Her sütunun üstündeki sayıyı oku: 25, 40, 15 ve 35.",
      "25 + 40 = 65 ve 15 + 35 = 50.",
      "Toplam: 65 + 50 = 115 sayfa.",
    ],
  },
  {
    id: "D5-04",
    sinif: 5,
    ders: "Fen Bilimleri",
    beceri: "fen",
    soru: "Sıcak bir odada bırakılan **buz** parçası zamanla su hâline geliyor. Bu olaya ne ad verilir?",
    secenekler: ["Donma", "Buharlaşma", "Yoğuşma", "Erime"],
    dogru: 3,
    adimlar: [
      "Katı bir maddenin ısı alarak sıvı hâle geçmesine erime denir.",
      "Buz katıdır, su ise sıvıdır; sıcak oda buza ısı verir.",
      "Donma bunun tersidir (sıvıdan katıya). Buharlaşma sıvıdan gaza geçmedir; yoğuşma ise gazdan sıvıya geçmedir.",
    ],
    tuzaklar: { 0: "Donma, sıvının katıya dönüşmesidir. Burada ise katı sıvıya dönüşüyor." },
  },
  {
    id: "D5-05",
    sinif: 5,
    ders: "Sosyal Bilgiler",
    beceri: "sosyal",
    soru: "Haritanın **ölçeği** “1 cm = 50 km” ise iki şehir arası haritada 4 cm olduğunda, gerçekte kaç km’dir?",
    secenekler: ["54", "200", "20", "2 000"],
    dogru: 1,
    adimlar: [
      "Ölçek, haritadaki 1 cm’nin gerçekte kaç km olduğunu söyler: 1 cm = 50 km.",
      "Haritada 4 cm varsa gerçek uzaklık 4 × 50 = 200 km’dir.",
    ],
    tuzaklar: { 0: "54, 4 ile 50’nin toplamıdır. Her santimetre 50 km olduğundan çarpma yapılır." },
  },

  // ───────────── 6. sınıf ─────────────
  {
    id: "D6-01",
    sinif: 6,
    ders: "Türkçe",
    beceri: "dilbilgisi",
    soru: "Aşağıdaki cümlelerin hangisinde **yazım yanlışı** vardır?",
    secenekler: [
      "Kitabı **yarın** getireceğim.",
      "**Herkez** toplantıya zamanında katıldı.",
      "Ödevini **bitirmiş** miydi?",
      "**Hiçbir** şey söylemedi.",
    ],
    dogru: 1,
    adimlar: [
      "“Herkes” sözcüğü sonunda “s” ile yazılır; “herkez” yazımı yanlıştır.",
      "“Yarın”, “bitirmiş” ve “hiçbir” sözcüklerinin yazımı doğrudur.",
    ],
    tuzaklar: { 3: "“Hiçbir” bitişik, “şey” ayrı yazılır. Bu cümle doğrudur." },
  },
  {
    id: "D6-02",
    sinif: 6,
    ders: "Matematik",
    beceri: "sayilar",
    soru: "Sayı doğrusunda **A** ile **B** noktaları arasındaki uzaklık kaç birimdir?",
    sekil: {
      tip: "sayidogrusu",
      min: -5,
      max: 5,
      adim: 1,
      etiketAdim: 1,
      noktalar: [
        { ad: "A", deger: -3 },
        { ad: "B", deger: 2 },
      ],
      alt: "−5’ten 5’e kadar tam sayıların gösterildiği sayı doğrusu. A noktası −3’te, B noktası 2’dedir.",
    },
    secenekler: ["1", "6", "5", "7"],
    dogru: 2,
    adimlar: [
      "A noktası −3’te, B noktası 2’dedir.",
      "A’dan 0’a 3 birim, 0’dan B’ye 2 birim vardır.",
      "Uzaklık: 3 + 2 = 5 birim.",
    ],
    tuzaklar: {
      0: "−3 + 2 = −1 işlemi iki noktanın toplamıdır. Uzaklık için aradaki birimler sayılır.",
      1: "6, A ve B noktalarını da sayınca çıkar. Uzaklık, noktalar arasındaki aralıkların sayısıdır.",
    },
  },
  {
    id: "D6-03",
    sinif: 6,
    ders: "Matematik",
    beceri: "sayilar",
    soru: "Şekildeki kız öğrenci sayısının erkek öğrenci sayısına **oranı** kaçtır?",
    sekil: {
      tip: "gruplar",
      a: { ad: "Kız öğrenci", sayi: 12 },
      b: { ad: "Erkek öğrenci", sayi: 18 },
      alt: "İki sıra: 12 daire kız öğrencileri, 18 kare erkek öğrencileri gösteriyor.",
    },
    secenekler: ["2/3", "3/2", "2/5", "3/5"],
    dogru: 0,
    adimlar: [
      "Kız öğrenci sayısı 12, erkek öğrenci sayısı 18’dir.",
      "Oran 12/18 olur. İkisi de 6’ya bölünür: 12/18 = 2/3.",
    ],
    tuzaklar: {
      1: "3/2, ters orandır (erkek / kız).",
      2: "2/5, kızların tüm öğrencilere oranıdır (12/30). Soru erkeklerle karşılaştırıyor.",
    },
  },
  {
    id: "D6-04",
    sinif: 6,
    ders: "Fen Bilimleri",
    beceri: "fen",
    soru: "Kanı kalpten **uzaklaştırıp** organlara doğru taşıyan kan damarı hangisidir?",
    secenekler: ["Toplardamar", "Atardamar", "Kılcal damar", "Soluk borusu"],
    dogru: 1,
    adimlar: [
      "Kanı kalpten çıkarıp organlara doğru taşıyan damarlara atardamar denir.",
      "Toplardamarlar kanı vücuttan kalbe doğru taşır.",
      "Kılcal damarlar çok incedir; kanla hücreler arasında madde alışverişi yapılır. Soluk borusu ise kan damarı değildir.",
    ],
    tuzaklar: { 0: "Toplardamar kanı kalbe doğru taşır; soru kalpten uzaklaşan kanı taşıyan damarı soruyor." },
  },
  {
    id: "D6-05",
    sinif: 6,
    ders: "Sosyal Bilgiler",
    beceri: "sosyal",
    soru: "Dünya’yı kuzey ve güney yarım küre olarak **ikiye ayıran** hayalî çizgi hangisidir?",
    secenekler: ["Başlangıç meridyeni", "Oğlak dönencesi", "Kuzey kutup dairesi", "Ekvator"],
    dogru: 3,
    adimlar: [
      "Dünya’yı kuzey ve güney yarım küre olarak ikiye ayıran çizgi Ekvator’dur (0° enlem).",
      "Başlangıç meridyeni ise Dünya’yı doğu ve batı yarım küre olarak ikiye ayırır.",
      "Dönenceler ve kutup daireleri bu iki yarım küreyi ayırmaz.",
    ],
    tuzaklar: { 0: "Başlangıç meridyeni doğu–batıyı ayırır; kuzey–güney için enlem çizgilerine bakılır." },
  },

  // ───────────── 7. sınıf ─────────────
  {
    id: "D7-01",
    sinif: 7,
    ders: "Türkçe",
    beceri: "dilbilgisi",
    soru: "“**Koşarak** okula yetişti.” cümlesinde altı çizili sözcük hangi fiilimsidir?",
    secenekler: ["Sıfat-fiil", "İsim-fiil", "Çekimli fiil", "Zarf-fiil"],
    dogru: 3,
    adimlar: [
      "Fiilimsiler, fiil kökünden türeyen ama fiil gibi çekimlenmeyen sözcüklerdir: isim-fiil, sıfat-fiil ve zarf-fiil.",
      "“Koşarak”, yetişme işinin nasıl yapıldığını bildirir; “-arak” eki zarf-fiil yapar.",
      "Cümlenin yüklemi “yetişti”dir; “koşarak” yüklem değil, fiilimsidir.",
    ],
    tuzaklar: { 2: "Çekimli fiil, cümlenin yüklemidir; burada yüklem “yetişti”dir." },
  },
  {
    id: "D7-02",
    sinif: 7,
    ders: "Matematik",
    beceri: "sayilar",
    soru: "Aynı cins elmanın fiyatı kilogramla **doğru orantılıdır**. 3 kg elma 45 TL ise 5 kg elma kaç TL’dir?",
    secenekler: ["60 TL", "75 TL", "90 TL", "225 TL"],
    dogru: 1,
    adimlar: [
      "3 kg elma 45 TL ise 1 kg elma 45 ÷ 3 = 15 TL’dir.",
      "5 kg elma 5 × 15 = 75 TL eder.",
    ],
    tuzaklar: {
      0: "60 TL, 4 kg elmanın fiyatıdır. 5 kg için bir kilo daha eklenmeli.",
      3: "45 TL zaten 3 kg içindir; onu 5 ile çarpmak 15 kg’ın fiyatını verir.",
    },
  },
  {
    id: "D7-03",
    sinif: 7,
    ders: "Matematik",
    beceri: "geometri",
    soru: "Şekildeki üçgende iki açı 50° ve 60° ise **soru işaretiyle** gösterilen açı kaç derecedir?",
    sekil: {
      tip: "ucgen",
      a: 50,
      b: 60,
      alt: "Bir üçgenin iki alt köşesinde 50° ve 60° yazıyor; üst köşedeki açı soru işaretiyle gösterilmiş.",
    },
    secenekler: ["110°", "90°", "70°", "100°"],
    dogru: 2,
    adimlar: [
      "Bir üçgenin iç açıları toplamı 180°’dir.",
      "Bilinen iki açının toplamı 50° + 60° = 110°’dir.",
      "Üçüncü açı: 180° − 110° = 70°.",
    ],
    tuzaklar: { 0: "110°, bilinen iki açının toplamıdır. Üçüncü açı için bunu 180°’den çıkarmak gerekir." },
  },
  {
    id: "D7-04",
    sinif: 7,
    ders: "Fen Bilimleri",
    beceri: "fen",
    soru: "Grafikte bir aracın **sabit hızla** aldığı yol gösteriliyor. Aracın hızı kaç km/sa’tir?",
    sekil: {
      tip: "grafik",
      xEtiket: "Zaman (saat)",
      yEtiket: "Yol (km)",
      xMax: 3,
      yMax: 240,
      yAdim: 60,
      noktalar: [
        [0, 0],
        [1, 80],
        [2, 160],
        [3, 240],
      ],
      alt: "Yol–zaman grafiği: doğru, başlangıç noktasından 3. saatte 240 km yola kadar düz çıkıyor.",
    },
    secenekler: ["80", "60", "240", "720"],
    dogru: 0,
    adimlar: [
      "Hız = yol ÷ zaman. Grafikte 3 saatte 240 km yol alınmış.",
      "240 ÷ 3 = 80 km/sa.",
      "Doğru düz bir çizgi olduğu için hız her an aynıdır; yani hız sabittir.",
    ],
    tuzaklar: { 3: "720, yolu zamanla çarpınca çıkar (240 × 3). Hız için yol zamana bölünür." },
  },
  {
    id: "D7-05",
    sinif: 7,
    ders: "Sosyal Bilgiler",
    beceri: "sosyal",
    soru: "Birçok tarihçi, İstanbul’un fethini (1453) bir çağın **sonu** ve bir sonraki çağın başlangıcı olarak kabul eder. Sona eren çağ hangisidir?",
    secenekler: ["İlk Çağ", "Yeni Çağ", "Yakın Çağ", "Orta Çağ"],
    dogru: 3,
    adimlar: [
      "Tarih çağları sırasıyla İlk Çağ, Orta Çağ, Yeni Çağ ve Yakın Çağ’dır.",
      "İstanbul’un fethi Orta Çağ’ın sonu, Yeni Çağ’ın başlangıcı sayılan olaylardan biridir.",
      "Çağların başlangıcı için tek bir olay kesin kabul edilmez; bu, yaygın kullanılan bir kabuldür.",
    ],
    tuzaklar: { 1: "Yeni Çağ, bu olayla başlayan çağdır; sona eren değil." },
  },
];

export function getDemoQuestions(sinif: DemoSinif): DemoQuestion[] {
  return DEMO_QUESTIONS.filter((q) => q.sinif === sinif);
}

export function isDemoSinif(v: number): v is DemoSinif {
  return (DEMO_SINIFLAR as number[]).includes(v);
}
