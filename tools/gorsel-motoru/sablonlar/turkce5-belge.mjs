// 5. sınıf Türkçe — duyuru kartı okuma (metnin yüzey anlamı: bilgiyi görselden bulma).
// Çeldiriciler aynı alanın başka olası değerleridir (şıklar duyuru içeriğini ele vermez).
const MUFREDAT = '2026 Maarif Modeli';
const ETKINLIK = ['Kitap Fuarı', 'Fidan Dikme Şenliği', 'Okul Tiyatrosu', 'Bilim Şenliği', 'Spor Şenliği', 'Resim Sergisi'];
const HAVUZ = {
  'Gün': ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma'],
  'Saat': ['09.00', '09.30', '10.00', '10.30', '11.00', '13.30', '14.00', '14.30'],
  'Yer': ['Okul bahçesi', 'Konferans salonu', 'Spor salonu', 'Kütüphane', 'Müzik sınıfı', 'Resim atölyesi'],
  'Düzenleyen': ['5-A sınıfı', '5-B sınıfı', '5-C sınıfı', '5-D sınıfı'],
};
const SORU = {
  'Gün': 'Duyuruya göre etkinlik hangi gün yapılacaktır?',
  'Saat': 'Duyuruya göre etkinlik saat kaçta başlayacaktır?',
  'Yer': 'Duyuruya göre etkinlik nerede yapılacaktır?',
  'Düzenleyen': 'Duyuruya göre etkinliği hangi sınıf düzenlemektedir?',
};

export function kur({ R, sec, karistir, ekle }) {
  function duyuruSorusu() {
    const baslik = sec(ETKINLIK), alan = sec(Object.keys(SORU));
    const satirlar = Object.keys(HAVUZ).map((etiket) => ({ etiket, deger: sec(HAVUZ[etiket]) }));
    const dogru = satirlar.find((s) => s.etiket === alan).deger;
    const cel = karistir(HAVUZ[alan].filter((x) => x !== dogru)).slice(0, 3);
    ekle({ kod: 'T.O.5.6', konu: 'Bilgilendirici Metin', alt_konu: 'Duyuru kartından bilgi bulma', zorluk: 1,
      spec: { tip_id: 'belge-kart', parametreler: { tur: 'Duyuru', baslik, satirlar } },
      kok: SORU[alan], dogru, celdirici: cel,
      gerekce: cel.map((c) => `${c}, duyuruda "${alan}" satırında yazan bilgi değildir.`),
      ipucu: `Duyurudaki "${alan}" satırını bul ve yanındaki bilgiyi oku.`,
      cozum: [`Duyuruda "${alan}" satırı bulunur.`, `Bu satırda ${dogru} yazmaktadır.`],
      dogrulama: [{ yol: ['alanlar', alan], beklenen: dogru }] });
  }
  return { duyuruSorusu };
}

export const KAYIT = [
  { id: 'tr5-duyuru', ders: 'Türkçe', sinif: 5, idOnek: 'TR5-DUY', mufredat_surum: MUFREDAT, kodlar: ['T.O.5.6'], fabrika: kur, uret: (f) => f.duyuruSorusu() },
];
