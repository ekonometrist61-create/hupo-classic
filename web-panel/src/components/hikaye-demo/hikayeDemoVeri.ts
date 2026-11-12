// Sınıf başına bir hikâye deneyimi. Parçalar, yayında ve insan onaylı (denetim.insan = approved) hikâye
// sürümlerinden birebir alınmıştır; yayın sürümü değişirse bu dosya da güncellenmelidir.
// {ad} kahramanın adı, {yol} yol arkadaşının adı için yer tutucudur. Kahraman adı geçmeyen parçalar olduğu gibi gösterilir.

export type SecenekHarf = "A" | "B" | "C" | "D";

export interface HikayeDemo {
  sinif: 3 | 4 | 5 | 6 | 7;
  baslik: string;
  tur: string;
  anaDeger: string;
  deyim: { ifade: string; anlam: string; cumle: string };
  parca: string;
  soru: {
    metin: string;
    secenekler: { harf: SecenekHarf; metin: string }[];
    dogru: SecenekHarf;
    aciklama: string;
    yanlis: string;
  };
  // Parçada geçen adların varsayılanı (kullanıcı ad yazmazsa).
  varsayilanYol?: string;
  // Soru metni belirli bir karakter adına bağlıysa, yol arkadaşı adı sabittir ve kullanıcı değiştiremez.
  sabitYol?: string;
}

export const HIKAYE_DEMOLARI: HikayeDemo[] = [
  {
    sinif: 3,
    baslik: "Kelime Makinesinin Karışıklığı",
    tur: "bilim_kurgu",
    anaDeger: "Saygı",
    deyim: {
      ifade: "iki büklüm olmak",
      anlam: "çok gülmekten bedeni bükülüp katlanmak",
      cumle: "{yol} gülmekten iki büklüm oldu.",
    },
    parca:
      "{yol} yeni cümleyi yüksek sesle okudu: “Dedem yüz sayfa okudu.” Makine masaya yüz tane insan yüzü çizdi. {yol} gülmekten iki büklüm oldu.",
    soru: {
      metin: "Makinenin hatasını bulmada hangi yol işe yaradı?",
      secenekler: [
        { harf: "A", metin: "Düğmelere art arda rastgele basmak" },
        { harf: "B", metin: "Cümleyi yanındaki sözcüklerle okumak" },
        { harf: "C", metin: "Dededen yepyeni bir makine istemek" },
      ],
      dogru: "B",
      aciklama: "Düğmelere basmak işe yaramadı; cümleyi yanındaki sözcüklerle okuyunca anlam anlaşıldı.",
      yanlis: "Bu kez olmadı. Cümleyi yanındaki sözcüklerle birlikte bir kez daha okuyalım.",
    },
    varsayilanYol: "Deniz",
  },
  {
    sinif: 4,
    baslik: "Kayıp Sandığın Şifresi",
    tur: "macera",
    anaDeger: "Dostluk",
    deyim: {
      ifade: "sözünü kesmek",
      anlam: "konuşan birinin sözünü yarıda bırakıp araya girmek",
      cumle: "Ömer sözünü kesti: “Peki ‘temiz suyu koruyan’ neden dalga olsun?”",
    },
    parca:
      "Kerem, dört cümleyi fotoğraflarla eşleştirmek istedi. “Bizi ısıtan güneş. Büyümemizi sağlayan yaprak,” dedi. Ömer sözünü kesti: “Peki ‘temiz suyu koruyan’ neden dalga olsun?”",
    soru: {
      metin: "Albümdeki “Birlikte ısındık”, “Birlikte büyüttük” gibi yazılar sınıfın neyi önemsediğini gösterir?",
      secenekler: [
        { harf: "A", metin: "Yarışmayı kazanmayı" },
        { harf: "B", metin: "Ortak yaşantıları ve iş birliğini" },
        { harf: "C", metin: "Tek başına çalışmayı" },
        { harf: "D", metin: "Hediye almayı" },
      ],
      dogru: "B",
      aciklama: "Her yazıda “Birlikte” sözcüğü vardı; sınıf yaptıklarını birlikte yapmayı önemsiyordu.",
      yanlis: "Bu kez olmadı. Yazılardaki “Birlikte” sözcüğüne bir daha bakalım.",
    },
  },
  {
    sinif: 5,
    baslik: "Gökyüzündeki Balonun Sırrı",
    tur: "bilim",
    anaDeger: "Dürüstlük",
    deyim: {
      ifade: "kaşlarını çatmak",
      anlam: "kızgınlıkla ya da düşünceyle kaşları birbirine yaklaştırmak",
      cumle: "{yol} bu uzun cümleyi okuyunca kaşlarını çattı.",
    },
    parca:
      "Açıklamasını değiştirdi: “İçindeki ısıtılmış hava, dış havaya göre daha az yoğun olduğunda oluşan kaldırma kuvveti balonun yükselmesine yardımcı olur.” {yol} bu uzun cümleyi okuyunca kaşlarını çattı.",
    soru: {
      metin: "Balonun yükselmesinin temel nedeni neydi?",
      secenekler: [
        { harf: "A", metin: "İç hava ile dış hava arasındaki yoğunluk farkı ve kaldırma kuvveti" },
        { harf: "B", metin: "Balonun parlak renkli olmasının havada süzülmesini sağlaması" },
        { harf: "C", metin: "Kuvvetli bir rüzgârın balonu gökyüzüne doğru itmesi ve sürüklemesi" },
        { harf: "D", metin: "Balonun çok küçük ve hafif bir kumaştan yapılmış olması" },
      ],
      dogru: "A",
      aciklama: "Isınan iç hava daha az yoğun olduğunda kaldırma kuvveti balonu yukarı taşır.",
      yanlis: "Bu kez olmadı. Balonun içindeki havanın nasıl değiştiğine yeniden bakalım.",
    },
    varsayilanYol: "Deniz",
  },
  {
    sinif: 6,
    baslik: "Deyim Dedektifleri Kulübü",
    tur: "mizah",
    anaDeger: "Dürüstlük",
    deyim: {
      ifade: "kulak misafiri olmak",
      anlam: "istemeden başkasının konuşmasını duymak",
      cumle:
        "Okulun duyuru ekranında “Kulak misafiri olmak” deyiminin karşısına “Başkasını gizlice dinlemek her zaman eğlencelidir” yazılmıştı.",
    },
    parca:
      "İkinci gün daha büyük bir karışıklık yaşandı. Okulun duyuru ekranında “Kulak misafiri olmak” deyiminin karşısına “Başkasını gizlice dinlemek her zaman eğlencelidir” yazılmıştı.",
    soru: {
      metin: "Kulüp afişlerin neden sorunlu olduğunu düşündü?",
      secenekler: [
        { harf: "A", metin: "Renkleri çok parlak olduğu için" },
        {
          harf: "B",
          metin: "Deyimlerin görünür anlamıyla kastedilen anlamın karıştırılması ve yanlış bilgi vermesi nedeniyle",
        },
        { harf: "C", metin: "Yazılar çok küçük olduğu için" },
        { harf: "D", metin: "Okul kapandığı için" },
      ],
      dogru: "B",
      aciklama: "Afişler, deyimleri gerçek anlamıyla yorumlatarak çocukları yanıltabilirdi.",
      yanlis: "Bu kez olmadı. Afişin altındaki cümleyi deyimin gerçek anlamıyla karşılaştıralım.",
    },
  },
  {
    sinif: 7,
    baslik: "Çevrilmeyen Son Sayfa",
    tur: "gizem",
    anaDeger: "Dürüstlük",
    deyim: {
      ifade: "görmezden gelmek",
      anlam: "bilmezlikten gelmek, yok saymak",
      cumle: "Hata yapmanın kötü yanı, onu saklamak değil, görmezden gelmekti.",
    },
    parca:
      "{yol} ekranı kapatırken yüzü kızardı. Bir arama sonucunun üstte görünmesi onun doğru olduğu anlamına gelmiyordu. {ad} bu küçük yanılgıyı araştırma defterlerine eklemeyi önerdi. Hata yapmanın kötü yanı, onu saklamak değil, görmezden gelmekti.",
    soru: {
      metin: "Nehir'in harita hakkında vardığı sonuç nedir?",
      secenekler: [
        { harf: "A", metin: "Haritada görünen her yol kesinlikle vardır" },
        { harf: "B", metin: "Haritada görünmemek, var olmadığı anlamına gelmez" },
        { harf: "C", metin: "Haritalar hiç kullanılmamalıdır" },
        { harf: "D", metin: "Harita yalnız süs amaçlıdır" },
      ],
      dogru: "B",
      aciklama: "Bir yolun haritada görünmemesi, o yolun hiç olmadığını kanıtlamaz.",
      yanlis: "Bu kez olmadı. Haritada görünmeyen bir şeyin var olup olmadığını bir kez daha düşünelim.",
    },
    // Soru metni "Nehir" adına bağlı; yol arkadaşı adı sabit tutulur ki soru ile parça tutarlı kalsın.
    sabitYol: "Nehir",
  },
];
