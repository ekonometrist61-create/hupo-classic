// Maarif değerleri (D1–D20). Adlar `okuma_etiket_sozlugu` (tur = 'deger') ile birebir aynıdır;
// sözlük değişirse bu tablo da güncellenir. Bilinmeyen kod, kendisiyle gösterilir (ekran çökmez).

const Map<String, String> okumaDegerAdlari = {
  'D1': 'Adalet',
  'D2': 'Aile Bütünlüğü',
  'D3': 'Çalışkanlık',
  'D4': 'Dostluk',
  'D5': 'Duyarlılık',
  'D6': 'Dürüstlük',
  'D7': 'Estetik',
  'D8': 'Mahremiyet',
  'D9': 'Merhamet',
  'D10': 'Mütevazılık',
  'D11': 'Özgürlük',
  'D12': 'Sabır',
  'D13': 'Sağlıklı Yaşam',
  'D14': 'Saygı',
  'D15': 'Sevgi',
  'D16': 'Sorumluluk',
  'D17': 'Tasarruf',
  'D18': 'Temizlik',
  'D19': 'Vatanseverlik',
  'D20': 'Yardımseverlik',
};

/// Değer kodunu okunabilir ada çevirir; tanımsız kodda kodun kendisini döner.
String okumaDegerAdi(String kod) => okumaDegerAdlari[kod] ?? kod;

/// D-kodlarını sayısal sırayla sıralar (D2 < D10).
int okumaDegerSirasi(String kod) => int.tryParse(kod.substring(1)) ?? 999;
