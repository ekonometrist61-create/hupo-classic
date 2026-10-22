// Okuma Dünyası örnek hikâyesi (statik, kayıtsız demo).
// Kaynak: C:\Dev\Senin Hikayen - HupoRead\icerik\pilot-2-sinif\hr014-yagmur-damlasinin-yolculugu.hikaye.md
// Token karşılıkları: {kahraman} -> Ela, {yoldas:yalin|Hupo} -> Hupo, {kelime:...} -> düz metin,
// {isaret:bulut} -> kaldırıldı (çizim işareti), {atasozu:ata_damla} -> "Damlaya damlaya göl olur".
// DURUM: kaynak taslak; insan okuması ve üç göz onayı tamamlanmadı. Bu sayfa yayın kapısına kadar noindex.
// Cevap anahtarı istemci paketindedir; demo kayıt tutmaz ve sunucuda doğrulama yapılmaz.

export type BeceriTuru = "hatirlama" | "cikarim" | "yorumlama" | "sozcuk_baglami";
export type SecenekId = "A" | "B" | "C";

export interface DemoSecenek {
  id: SecenekId;
  metin: string;
}

export interface DemoSoru {
  id: string;
  beceri: BeceriTuru;
  dayanakSayfa: number;
  metin: string;
  secenekler: DemoSecenek[];
  dogru: SecenekId;
  aciklama: string;
}

// Beceri adları veli panelindeki (veli-okuma.tr.json) etiketlerle aynıdır.
export const BECERI_ETIKET: Record<BeceriTuru, string> = {
  hatirlama: "Açık bilgiyi bulma",
  cikarim: "Çıkarım",
  yorumlama: "Yorumlama",
  sozcuk_baglami: "Sözcük anlamı",
};

export interface DemoHikaye {
  baslik: string;
  sinif: number;
  tur: string;
  deger: string;
  sayfalar: string[];
  sorular: DemoSoru[];
}

export const DEMO_HIKAYE: DemoHikaye = {
  baslik: "Yağmur Damlasının Yolculuğu",
  sinif: 2,
  tur: "Bilim",
  deger: "Tasarruf",
  sayfalar: [
    "Ela bir sabah pencereye vuran yağmur damlasını gördü. “Acaba bu damla nereden geldi?” diye sordu. Damla sanki onu duymuş gibi camdan aşağı kaydı. Hupo da yanında merakla bakıyordu.",
    "Ela damlanın bir bulutun içinde olduğunu hayal etti. Çevrede pek çok damlacık vardı. Rüzgâr bulutu sürükleyince hepsi sallandı. Bazı damlacıklar birleşip ağırlaştı ve aşağı düşmeye başladı.",
    "Damla önce bir yaprağa çarptı, sonra toprağa kaydı. Toprak suyu emdi; bir kısmı küçük bir su yoluna karıştı. Su yolu başka sularla birleşip dereye dönüştü. Dar bir yerde su daha hızlı, geniş bir yerde daha yavaş akıyordu.",
    "Güneş çıkınca göl parladı. Damla buharlaşıp görünmez bir buhar olarak havaya yükseldi. Ela bunu öğrenince çok şaşırdı. “Demek yolculuk bitmedi,” dedi. Serin havada yeniden oluşan damlacıklar buluta karışacaktı.",
    "Hupo defterine üç sözcük yazdı: yağış, buharlaşma, yoğunlaşma. Her birinin yanına küçük resimler çizdiler. Bulut, dere, göl ve güneş arasına oklar koydular. Öğretmen bunun su döngüsü olduğunu söyledi.",
    "Ertesi gün öğretmen soğuk bir kabın yüzeyinde su damlaları gösterdi. Havadaki su buharı soğuk yüzeyde yoğunlaşmıştı. Ela küçük bir not kâğıdına bir damla çizdi ve ona “Yolcu” adını verdi. “Yağmur hiç bitiyor mu?” diye sordu. Öğretmen, suyun döngüde sürekli dolaştığını anlattı. Ela gülerek “Damlaya damlaya göl olur” dedi. Ela musluğu açık bırakmamaya karar verdi.",
  ],
  sorular: [
    {
      id: "s1",
      beceri: "hatirlama",
      dayanakSayfa: 3,
      metin: "Dar bir yerde su nasıl akıyordu?",
      secenekler: [
        { id: "A", metin: "Daha hızlı" },
        { id: "B", metin: "Daha yavaş" },
        { id: "C", metin: "Hiç akmıyordu" },
      ],
      dogru: "A",
      aciklama: "Dar bir yerde su daha hızlı akıyordu.",
    },
    {
      id: "s2",
      beceri: "cikarim",
      dayanakSayfa: 4,
      metin: "Güneş çıkınca damla ne oldu?",
      secenekler: [
        { id: "A", metin: "Buharlaşıp havaya yükseldi" },
        { id: "B", metin: "Donup taş oldu" },
        { id: "C", metin: "Toprakta kaldı" },
      ],
      dogru: "A",
      aciklama: "Damla buharlaşıp görünmez bir buhar olarak havaya yükseldi.",
    },
    {
      id: "s3",
      beceri: "yorumlama",
      dayanakSayfa: 6,
      metin: "Musluğu açık bırakmama kararı neyi gösterir?",
      secenekler: [
        { id: "A", metin: "Suya ve onun döngüsüne değer verildiğini" },
        { id: "B", metin: "Suyun kendiliğinden bittiğini" },
        { id: "C", metin: "Yağmurun hiç yağmayacağını" },
      ],
      dogru: "A",
      aciklama: "Su döngüsünü öğrenen çocuk, suyu boşa harcamamaya karar verdi.",
    },
    {
      id: "s4",
      beceri: "sozcuk_baglami",
      dayanakSayfa: 4,
      metin: "Metinde geçen buhar sözcüğü ne anlama gelir?",
      secenekler: [
        { id: "A", metin: "Isınınca havaya karışan, görünmez su hâli" },
        { id: "B", metin: "Bir tür bulut" },
        { id: "C", metin: "Çok soğuk bir rüzgâr" },
      ],
      dogru: "A",
      aciklama: "Damla, güneşle ısınınca buhar olarak havaya karıştı.",
    },
  ],
};
