-- =====================================================================
--  Çarpım Tablosu Şifreleri — Başlangıç İçerik Verisi (Seed)
--  Tarih: 2026-09-28
--
--  Tablo: public.carpim_sifreleri
--  Kısıtlar:
--    * sira unique, anahtar unique
--    * renk: ^#[0-9A-Fa-f]{6}$
--    * ornek: {soru, adimlar[]}
--    * alistirma: 2-5 soruluk dizi [{soru, cevap, cozum[]}]
--    * test: 2-5 soruluk dizi [{soru, cevap, cozum[]}]
-- =====================================================================

insert into public.carpim_sifreleri (
  sira, anahtar, isim, ikon, renk, kapsam, kesif, tanim, formul, ornek, alistirma, test
)
values
(
  1,
  '2ler',
  'İkiler Şifresi',
  'bolt',
  '#22C58B',
  '2 ile çarpma: sayının kendisiyle toplanması (çift katı)',
  'Bir sayıyı 2 ile çarpmak, onu kendisiyle iki kez toplamaktır.',
  '2 ile çarpmak sayının çift katını almaktır. Sayıyı kendisiyle topla!',
  'n × 2 = n + n',
  jsonb_build_object(
    'soru', '7 × 2 kaçtır?',
    'adimlar', jsonb_build_array('7 sayısını kendisiyle topla: 7 + 7', '7 + 7 = 14', 'Cevap: 14')
  ),
  jsonb_build_array(
    jsonb_build_object(
      'soru', '4 × 2',
      'cevap', 8,
      'cozum', jsonb_build_array('4 + 4 = 8')
    ),
    jsonb_build_object(
      'soru', '6 × 2',
      'cevap', 12,
      'cozum', jsonb_build_array('6 + 6 = 12')
    ),
    jsonb_build_object(
      'soru', '8 × 2',
      'cevap', 16,
      'cozum', jsonb_build_array('8 + 8 = 16')
    )
  ),
  jsonb_build_array(
    jsonb_build_object(
      'soru', '5 × 2 = ?',
      'cevap', 10,
      'cozum', jsonb_build_array('5 + 5 = 10')
    ),
    jsonb_build_object(
      'soru', '9 × 2 = ?',
      'cevap', 18,
      'cozum', jsonb_build_array('9 + 9 = 18')
    ),
    jsonb_build_object(
      'soru', '7 × 2 = ?',
      'cevap', 14,
      'cozum', jsonb_build_array('7 + 7 = 14')
    )
  )
),
(
  2,
  '3ler',
  'Üçler Şifresi',
  'calculate',
  '#2FB8FF',
  '3 ile çarpma: iki katına bir tane daha ekle',
  '3 ile çarpmak için önce sayının 2 katını bul, sonra sayıyı bir kez daha ekle.',
  'Önce çift katını al (×2), sonra sayının kendisini bir kez daha ekle (+n).',
  'n × 3 = (n × 2) + n',
  jsonb_build_object(
    'soru', '6 × 3 kaçtır?',
    'adimlar', jsonb_build_array('6''nın iki katını al: 6 × 2 = 12', 'Üzerine 6 ekle: 12 + 6 = 18', 'Cevap: 18')
  ),
  jsonb_build_array(
    jsonb_build_object(
      'soru', '4 × 3',
      'cevap', 12,
      'cozum', jsonb_build_array('(4 × 2) + 4 = 8 + 4 = 12')
    ),
    jsonb_build_object(
      'soru', '5 × 3',
      'cevap', 15,
      'cozum', jsonb_build_array('(5 × 2) + 5 = 10 + 5 = 15')
    ),
    jsonb_build_object(
      'soru', '7 × 3',
      'cevap', 21,
      'cozum', jsonb_build_array('(7 × 2) + 7 = 14 + 7 = 21')
    )
  ),
  jsonb_build_array(
    jsonb_build_object(
      'soru', '8 × 3 = ?',
      'cevap', 24,
      'cozum', jsonb_build_array('16 + 8 = 24')
    ),
    jsonb_build_object(
      'soru', '9 × 3 = ?',
      'cevap', 27,
      'cozum', jsonb_build_array('18 + 9 = 27')
    ),
    jsonb_build_object(
      'soru', '6 × 3 = ?',
      'cevap', 18,
      'cozum', jsonb_build_array('12 + 6 = 18')
    )
  )
),
(
  3,
  '4ler',
  'Dörtler Şifresi',
  'shield',
  '#6C4DF6',
  '4 ile çarpma: iki kere iki katını al',
  'Bir sayıyı 4 ile çarpmak, iki defa çift katını almaktır.',
  'Sayıyı 2 ile çarp, çıkan sonucu bir kez daha 2 ile çarp!',
  'n × 4 = (n × 2) × 2',
  jsonb_build_object(
    'soru', '7 × 4 kaçtır?',
    'adimlar', jsonb_build_array('7''nin ilk katı: 7 × 2 = 14', '14''ün ikinci katı: 14 × 2 = 28', 'Cevap: 28')
  ),
  jsonb_build_array(
    jsonb_build_object(
      'soru', '3 × 4',
      'cevap', 12,
      'cozum', jsonb_build_array('3 × 2 = 6, 6 × 2 = 12')
    ),
    jsonb_build_object(
      'soru', '5 × 4',
      'cevap', 20,
      'cozum', jsonb_build_array('5 × 2 = 10, 10 × 2 = 20')
    ),
    jsonb_build_object(
      'soru', '6 × 4',
      'cevap', 24,
      'cozum', jsonb_build_array('6 × 2 = 12, 12 × 2 = 24')
    )
  ),
  jsonb_build_array(
    jsonb_build_object(
      'soru', '8 × 4 = ?',
      'cevap', 32,
      'cozum', jsonb_build_array('8 × 2 = 16, 16 × 2 = 32')
    ),
    jsonb_build_object(
      'soru', '9 × 4 = ?',
      'cevap', 36,
      'cozum', jsonb_build_array('9 × 2 = 18, 18 × 2 = 36')
    ),
    jsonb_build_object(
      'soru', '7 × 4 = ?',
      'cevap', 28,
      'cozum', jsonb_build_array('7 × 2 = 14, 14 × 2 = 28')
    )
  )
),
(
  4,
  '5ler',
  'Beşler Şifresi',
  'star',
  '#FFC533',
  '5 ile çarpma: 10 ile çarpıp yarısını al (sonu 0 veya 5 biter)',
  '5 ile çarpılan tek sayılar 5 ile, çift sayılar 0 ile biter.',
  'Sayıyı 10 ile çarp (sonuna 0 koy), sonra yarısını al!',
  'n × 5 = (n × 10) ÷ 2',
  jsonb_build_object(
    'soru', '8 × 5 kaçtır?',
    'adimlar', jsonb_build_array('8''i 10 ile çarp: 80', '80''in yarısını al: 80 ÷ 2 = 40', 'Cevap: 40')
  ),
  jsonb_build_array(
    jsonb_build_object(
      'soru', '6 × 5',
      'cevap', 30,
      'cozum', jsonb_build_array('60 ÷ 2 = 30')
    ),
    jsonb_build_object(
      'soru', '7 × 5',
      'cevap', 35,
      'cozum', jsonb_build_array('70 ÷ 2 = 35')
    ),
    jsonb_build_object(
      'soru', '9 × 5',
      'cevap', 45,
      'cozum', jsonb_build_array('90 ÷ 2 = 45')
    )
  ),
  jsonb_build_array(
    jsonb_build_object(
      'soru', '4 × 5 = ?',
      'cevap', 20,
      'cozum', jsonb_build_array('40 ÷ 2 = 20')
    ),
    jsonb_build_object(
      'soru', '8 × 5 = ?',
      'cevap', 40,
      'cozum', jsonb_build_array('80 ÷ 2 = 40')
    ),
    jsonb_build_object(
      'soru', '5 × 5 = ?',
      'cevap', 25,
      'cozum', jsonb_build_array('50 ÷ 2 = 25')
    )
  )
),
(
  5,
  '6lar',
  'Altılar Şifresi',
  'school',
  '#3B82F6',
  '6 ile çarpma: 5 katına bir tane daha ekle',
  '6 ile çarpmak için 5 katını bulup sayıyı bir kez ekleyebilirsin.',
  'Önce 5 katını al, sonra sayının kendisini bir kez daha ekle (+n).',
  'n × 6 = (n × 5) + n',
  jsonb_build_object(
    'soru', '7 × 6 kaçtır?',
    'adimlar', jsonb_build_array('7''nin 5 katı: 7 × 5 = 35', 'Üzerine 7 ekle: 35 + 7 = 42', 'Cevap: 42')
  ),
  jsonb_build_array(
    jsonb_build_object('soru', '4 × 6', 'cevap', 24, 'cozum', jsonb_build_array('(4 × 5) + 4 = 20 + 4 = 24')),
    jsonb_build_object('soru', '8 × 6', 'cevap', 48, 'cozum', jsonb_build_array('(8 × 5) + 8 = 40 + 8 = 48')),
    jsonb_build_object('soru', '9 × 6', 'cevap', 54, 'cozum', jsonb_build_array('(9 × 5) + 9 = 45 + 9 = 54'))
  ),
  jsonb_build_array(
    jsonb_build_object('soru', '6 × 6 = ?', 'cevap', 36, 'cozum', jsonb_build_array('30 + 6 = 36')),
    jsonb_build_object('soru', '7 × 6 = ?', 'cevap', 42, 'cozum', jsonb_build_array('35 + 7 = 42')),
    jsonb_build_object('soru', '8 × 6 = ?', 'cevap', 48, 'cozum', jsonb_build_array('40 + 8 = 48'))
  )
),
(
  6,
  '7ler',
  'Yediler Şifresi',
  'auto_stories',
  '#8B5CF6',
  '7 ile çarpma: 5 katı ile 2 katının toplamı',
  'Yediler için sayının 5 katı ile 2 katını toplayabilirsin.',
  'Sayıyı 5 ile çarp, sonra 2 ile çarp, iki sonucu topla!',
  'n × 7 = (n × 5) + (n × 2)',
  jsonb_build_object(
    'soru', '8 × 7 kaçtır?',
    'adimlar', jsonb_build_array('8''in 5 katı: 8 × 5 = 40', '8''in 2 katı: 8 × 2 = 16', 'İkisini topla: 40 + 16 = 56', 'Cevap: 56')
  ),
  jsonb_build_array(
    jsonb_build_object('soru', '4 × 7', 'cevap', 28, 'cozum', jsonb_build_array('20 + 8 = 28')),
    jsonb_build_object('soru', '6 × 7', 'cevap', 42, 'cozum', jsonb_build_array('30 + 12 = 42')),
    jsonb_build_object('soru', '9 × 7', 'cevap', 63, 'cozum', jsonb_build_array('45 + 18 = 63'))
  ),
  jsonb_build_array(
    jsonb_build_object('soru', '7 × 7 = ?', 'cevap', 49, 'cozum', jsonb_build_array('35 + 14 = 49')),
    jsonb_build_object('soru', '8 × 7 = ?', 'cevap', 56, 'cozum', jsonb_build_array('40 + 16 = 56')),
    jsonb_build_object('soru', '6 × 7 = ?', 'cevap', 42, 'cozum', jsonb_build_array('30 + 12 = 42'))
  )
),
(
  7,
  '8ler',
  'Sekizler Şifresi',
  'psychology',
  '#EC4899',
  '8 ile çarpma: üç defa iki katını al (2 x 2 x 2)',
  '8 ile çarpmak, sayıyı arka arkaya üç kere ikiye katlamaktır.',
  'Çift katını al, sonucun çift katını al, tekrar çift katını al!',
  'n × 8 = ((n × 2) × 2) × 2',
  jsonb_build_object(
    'soru', '6 × 8 kaçtır?',
    'adimlar', jsonb_build_array('1. kat: 6 × 2 = 12', '2. kat: 12 × 2 = 24', '3. kat: 24 × 2 = 48', 'Cevap: 48')
  ),
  jsonb_build_array(
    jsonb_build_object('soru', '4 × 8', 'cevap', 32, 'cozum', jsonb_build_array('4 -> 8 -> 16 -> 32')),
    jsonb_build_object('soru', '7 × 8', 'cevap', 56, 'cozum', jsonb_build_array('7 -> 14 -> 28 -> 56')),
    jsonb_build_object('soru', '9 × 8', 'cevap', 72, 'cozum', jsonb_build_array('9 -> 18 -> 36 -> 72'))
  ),
  jsonb_build_array(
    jsonb_build_object('soru', '5 × 8 = ?', 'cevap', 40, 'cozum', jsonb_build_array('5 -> 10 -> 20 -> 40')),
    jsonb_build_object('soru', '8 × 8 = ?', 'cevap', 64, 'cozum', jsonb_build_array('8 -> 16 -> 32 -> 64')),
    jsonb_build_object('soru', '7 × 8 = ?', 'cevap', 56, 'cozum', jsonb_build_array('7 -> 14 -> 28 -> 56'))
  )
),
(
  8,
  '9lar',
  'Dokuzlar Şifresi',
  'rocket',
  '#FF5470',
  '9 ile çarpma: 10 ile çarpıp kendisini çıkar (rakamlar toplamı 9 dur)',
  '9 ile çarpmanın sonucu 10 katından sayının kendisi eksiktir. Basamaklar toplamı daima 9 dur!',
  'Sayıyı 10 ile çarp (sonuna 0 koy) ve sayının kendisini çıkar!',
  'n × 9 = (n × 10) − n',
  jsonb_build_object(
    'soru', '7 × 9 kaçtır?',
    'adimlar', jsonb_build_array('7''yi 10 ile çarp: 70', 'Kendisini çıkar: 70 − 7 = 63', 'Kontrol: 6 + 3 = 9. Doğru!')
  ),
  jsonb_build_array(
    jsonb_build_object(
      'soru', '4 × 9',
      'cevap', 36,
      'cozum', jsonb_build_array('40 − 4 = 36 (3 + 6 = 9)')
    ),
    jsonb_build_object(
      'soru', '6 × 9',
      'cevap', 54,
      'cozum', jsonb_build_array('60 − 6 = 54 (5 + 4 = 9)')
    ),
    jsonb_build_object(
      'soru', '8 × 9',
      'cevap', 72,
      'cozum', jsonb_build_array('80 − 8 = 72 (7 + 2 = 9)')
    )
  ),
  jsonb_build_array(
    jsonb_build_object(
      'soru', '5 × 9 = ?',
      'cevap', 45,
      'cozum', jsonb_build_array('50 − 5 = 45')
    ),
    jsonb_build_object(
      'soru', '7 × 9 = ?',
      'cevap', 63,
      'cozum', jsonb_build_array('70 − 7 = 63')
    ),
    jsonb_build_object(
      'soru', '9 × 9 = ?',
      'cevap', 81,
      'cozum', jsonb_build_array('90 − 9 = 81')
    )
  )
),
(
  9,
  '10lar',
  'Onlar Şifresi',
  'lightbulb',
  '#10B981',
  '10 ile çarpma: sayının sonuna bir sıfır ekle',
  'En kolay şifre! Bir sayıyı 10 ile çarpmak için sağ tarafına bir sıfır koyman yeterlidir.',
  'Sayıyı aynen yaz, sonuna bir tane 0 yapıştır!',
  'n × 10 = n0',
  jsonb_build_object(
    'soru', '8 × 10 kaçtır?',
    'adimlar', jsonb_build_array('8 sayısını yaz: 8', 'Sağına 0 ekle: 80', 'Cevap: 80')
  ),
  jsonb_build_array(
    jsonb_build_object('soru', '4 × 10', 'cevap', 40, 'cozum', jsonb_build_array('4 ve sonuna 0 -> 40')),
    jsonb_build_object('soru', '7 × 10', 'cevap', 70, 'cozum', jsonb_build_array('7 ve sonuna 0 -> 70')),
    jsonb_build_object('soru', '9 × 10', 'cevap', 90, 'cozum', jsonb_build_array('9 ve sonuna 0 -> 90'))
  ),
  jsonb_build_array(
    jsonb_build_object('soru', '6 × 10 = ?', 'cevap', 60, 'cozum', jsonb_build_array('60')),
    jsonb_build_object('soru', '8 × 10 = ?', 'cevap', 80, 'cozum', jsonb_build_array('80')),
    jsonb_build_object('soru', '10 × 10 = ?', 'cevap', 100, 'cozum', jsonb_build_array('100'))
  )
),
(
  10,
  '11ler',
  'On Birler Şifresi',
  'military_tech',
  '#F59E0B',
  '11 ile çarpma: tek basamaklı sayıyı yan yana iki kez yaz',
  '11 ile tek basamaklı bir sayıyı çarparsan o rakam çift olarak tekrarlar.',
  'Tek basamaklı sayıyı yan yana iki defa yaz!',
  'n × 11 = nn',
  jsonb_build_object(
    'soru', '7 × 11 kaçtır?',
    'adimlar', jsonb_build_array('7 sayısını iki kere yan yana yaz: 77', 'Cevap: 77')
  ),
  jsonb_build_array(
    jsonb_build_object('soru', '3 × 11', 'cevap', 33, 'cozum', jsonb_build_array('3 yan yana 2 kez -> 33')),
    jsonb_build_object('soru', '5 × 11', 'cevap', 55, 'cozum', jsonb_build_array('5 yan yana 2 kez -> 55')),
    jsonb_build_object('soru', '8 × 11', 'cevap', 88, 'cozum', jsonb_build_array('8 yan yana 2 kez -> 88'))
  ),
  jsonb_build_array(
    jsonb_build_object('soru', '4 × 11 = ?', 'cevap', 44, 'cozum', jsonb_build_array('44')),
    jsonb_build_object('soru', '6 × 11 = ?', 'cevap', 66, 'cozum', jsonb_build_array('66')),
    jsonb_build_object('soru', '9 × 11 = ?', 'cevap', 99, 'cozum', jsonb_build_array('99'))
  )
)
on conflict (anahtar) do update set
  sira      = excluded.sira,
  isim      = excluded.isim,
  ikon      = excluded.ikon,
  renk      = excluded.renk,
  kapsam    = excluded.kapsam,
  kesif     = excluded.kesif,
  tanim     = excluded.tanim,
  formul    = excluded.formul,
  ornek     = excluded.ornek,
  alistirma = excluded.alistirma,
  test      = excluded.test;
