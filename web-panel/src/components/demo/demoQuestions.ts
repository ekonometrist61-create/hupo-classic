// Halka açık örnek çalışma soruları.
// Kaynak: soru-bankasi/*.md (taslak_ornek, 4. sınıf kazanımlarına göre Hupo için hazırlanmış).
// Resmî sınav sorusu değildir; cevap anahtarı tek ve kesindir. Hiçbir yere kaydedilmez.
// Seçenek sırası cevap harfi dağılımı çeşitli olsun diye bilerek karıştırılmıştır;
// doğru cevap harf değil, `dogru` dizini ile tutulur.

export interface DemoQuestion {
  id: string;
  ders: string;
  /** **kalın** işaretli kısımlar vurgulanır. */
  soru: string;
  secenekler: [string, string, string, string];
  /** `secenekler` içindeki doğru seçeneğin dizini (0-3). */
  dogru: 0 | 1 | 2 | 3;
  adimlar: string[];
}

export const DEMO_QUESTIONS: DemoQuestion[] = [
  {
    id: "TUR-001",
    ders: "Türkçe",
    soru: "“Bu güzel haberi duyunca çok **sevindi**.” cümlesindeki koyu yazılı sözcüğün eş anlamlısı aşağıdakilerden hangisidir?",
    secenekler: ["üzüldü", "kızdı", "mutlu oldu", "korktu"],
    dogru: 2,
    adimlar: [
      "Eş anlamlı sözcük, bir sözcüğün yerine kullanıldığında cümlenin anlamını değiştirmeyen sözcüktür.",
      "“Sevinmek”, mutlu olmak demektir. Üzülmek, kızmak ve korkmak ise olumsuz duygulardır.",
      "“Sevindi” yerine “mutlu oldu” getirildiğinde cümlenin anlamı bozulmaz.",
    ],
  },
  {
    id: "MAT-002",
    ders: "Matematik",
    soru: "Okunuşu “Sekiz yüz beş bin kırk iki” olan doğal sayı aşağıdakilerden hangisidir?",
    secenekler: ["805 042", "850 042", "805 420", "85 042"],
    dogru: 0,
    adimlar: [
      "Binler bölüğü “Sekiz yüz beş” yani 805’tir.",
      "Birler bölüğü üç basamaklı olmalıdır. “Kırk iki” sayısı, yüzler basamağına sıfır konarak “042” yazılır.",
      "Bölükleri birleştirdiğimizde sayımız 805 042 olur.",
    ],
  },
  {
    id: "FEN-002",
    ders: "Fen Bilimleri",
    soru: "Dünya üzerinde gece ve gündüzün oluşmasının temel nedeni aşağıdakilerden hangisidir?",
    secenekler: [
      "Dünya’nın Güneş’in çevresinde dolanması",
      "Dünya’nın kendi ekseni etrafında dönmesi",
      "Ay’ın Dünya çevresinde dönmesi",
      "Mevsimlerin değişmesi",
    ],
    dogru: 1,
    adimlar: [
      "Dünya kendi ekseni etrafında bir günde (24 saatte) bir tam tur döner.",
      "Dönerken Güneş’e dönük olan kısımda gündüz, karanlıkta kalan kısımda gece yaşanır.",
      "Güneş çevresindeki dolanma ise mevsimleri oluşturur; gece ve gündüzü değil.",
    ],
  },
  {
    id: "SOS-002",
    ders: "Sosyal Bilgiler",
    soru: "23 Nisan Ulusal Egemenlik ve Çocuk Bayramı, hangi önemli olayın yıl dönümünde kutlanır?",
    secenekler: [
      "Cumhuriyet’in ilan edilmesi",
      "İstanbul’un fethi",
      "Kurtuluş Savaşı’nın kazanılması",
      "Türkiye Büyük Millet Meclisi’nin (TBMM) açılması",
    ],
    dogru: 3,
    adimlar: [
      "23 Nisan 1920’de Türkiye Büyük Millet Meclisi (TBMM) açılmıştır.",
      "Meclisin açılması, milletin kendi kendini yönetmesinin, yani ulusal egemenliğin başlangıcıdır.",
      "Atatürk bu bayramı dünya çocuklarına armağan etmiştir.",
    ],
  },
  {
    id: "MAT-003",
    ders: "Matematik",
    soru: "“536 348” doğal sayısındaki “3” rakamlarının basamak değerleri arasındaki fark kaçtır?",
    secenekler: ["27 000", "29 970", "29 700", "30 300"],
    dogru: 2,
    adimlar: [
      "İlk 3 rakamı on binler basamağındadır: basamak değeri 3 × 10 000 = 30 000.",
      "İkinci 3 rakamı yüzler basamağındadır: basamak değeri 3 × 100 = 300.",
      "İkisi arasındaki fark: 30 000 − 300 = 29 700.",
    ],
  },
];
