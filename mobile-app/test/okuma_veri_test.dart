// Okuma Dünyası: model, hata eşleme, sözlük, cihaz önbelleği ve cihaz deposu birim testleri.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/okuma_kahraman.dart';
import 'package:ogrenci_hazirlik/models/okuma_models.dart';
import 'package:ogrenci_hazirlik/services/okuma_cihaz_deposu.dart';
import 'package:ogrenci_hazirlik/services/okuma_geri_donus.dart';
import 'package:ogrenci_hazirlik/services/okuma_repository.dart';
import 'package:ogrenci_hazirlik/services/okuma_sozluk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'okuma_fake_repository.dart';

OkumaPaketi _paket({String id = kTestHikayeId, String sha = kTestSha, Map<String, dynamic>? icerik}) => OkumaPaketi(
      hikayeId: id,
      surumId: 's',
      surum: 1,
      sha256: sha,
      minMotorSurumu: 1,
      paket: icerik ?? const {'paket_surumu': 1},
    );

void main() {
  group('hata eşleme', () {
    test('sunucu kodları Türkçe, ad içermeyen mesaja çevrilir', () {
      expect(okumaHatasiCevir('KOTA_DOLDU').hata, OkumaHatasi.kotaDoldu);
      expect(okumaHatasiCevir('KOTA_DOLDU').mesaj, contains('Yarın yeni bir hikâye'));
      expect(okumaHatasiCevir('RATE_LIMIT').hata, OkumaHatasi.hizSiniri);
      expect(okumaHatasiCevir('OKUMA_KAPALI').hata, OkumaHatasi.kapali);
      expect(okumaHatasiCevir('IDEMPOTENCY_CONFLICT').hata, OkumaHatasi.cakisma);
      expect(okumaHatasiCevir('HIKAYE_BULUNAMADI').hata, OkumaHatasi.hikayeBulunamadi);
      expect(okumaHatasiCevir('BAD_OPTION').hata, OkumaHatasi.gecersizIstek);
      expect(okumaHatasiCevir('bilinmeyen şey').hata, OkumaHatasi.bilinmeyen);
    });

    test('sunucu metni kullanıcıya taşınmaz (ad sızmasın)', () {
      final e = okumaHatasiCevir('KOTA_DOLDU: Efe için sınır');
      expect(e.mesaj.contains('Efe'), isFalse);
      expect(e.toString().contains('Efe'), isFalse);
    });
  });

  group('modeller', () {
    test('özellik durumu: kota ve PDF hakkı', () {
      final d = OkumaOzellikDurumu.fromMap({
        'erisim': true,
        'onizleme': false,
        'gunluk_kota': {'sinirli': true, 'limit': 1, 'kullanilan': 1, 'kalan': 0},
        'pdf': {'sinirli': true, 'aylik_limit': 3, 'kullanilan': 1, 'kalan': 2},
      });
      expect(d.erisim, isTrue);
      expect(d.gunlukKota.bitti, isTrue);
      expect(d.pdf.bitti, isFalse);
      expect(d.pdf.limit, 3);
      expect(OkumaOzellikDurumu.fromMap(const {}).erisim, isFalse);
    });

    test('sınırsız hak bitmiş sayılmaz', () {
      final d = OkumaOzellikDurumu.fromMap({'erisim': true, 'gunluk_kota': {'sinirli': false, 'kalan': null}});
      expect(d.gunlukKota.bitti, isFalse);
    });

    test('seri ve öneri: öneri satırı katalog satırı gibi okunur', () {
      final s = OkumaSeriVeOneri.fromMap({
        'seri': {'streak_count': 4, 'seri_devam': true, 'bugun_okudu': true},
        'bugun_tamamlanan': 1,
        'toplam_tamamlanan': 6,
        'kota_dolu': true,
        'oneri': testSatiri().toMap(),
      });
      expect(s.seri.seriSayisi, 4);
      expect(s.kotaDolu, isTrue);
      expect(s.oneri?.baslik, 'Feneri Kim Yakıyor?');
      expect(OkumaSeriVeOneri.fromMap({'seri': <String, dynamic>{}, 'oneri': null}).oneri, isNull);
    });

    test('paket: sorular anahtarsızdır ve model doğru/açıklama taşımaz', () {
      final p = OkumaPaketi.fromMap({
        'hikaye_id': kTestHikayeId,
        'sha256': kTestSha,
        'paket': anahtarsizPaket(jsonDecode(
          // Fikstürün anahtarlı hali; fake bunu soyar.
          jsonEncode({
            'paket_surumu': 1,
            'hikaye': {'baslik': 'B', 'izinli_turler': ['ben']},
            'sorular': [
              {
                'id': 's1',
                'metin': 'Soru?',
                'dayanak_sayfa': 2,
                'secenekler': [
                  {'id': 'A', 'metin': 'a'},
                  {'id': 'B', 'metin': 'b'},
                ],
                'dogru': 'A',
                'aciklama': 'Çünkü.',
              },
            ],
          }),
        ) as Map<String, dynamic>),
      });
      expect(p.sorular.single.dayanakSayfa, 2);
      expect(p.sorular.single.secenekler.length, 2);
      expect(jsonEncode(p.toMap()).contains('dogru'), isFalse);
      expect(jsonEncode(p.toMap()).contains('Çünkü'), isFalse);
    });

    test('anket yıldızsız gönderilemez (sözleşme 1–5 ister)', () {
      expect(const OkumaAnketYaniti().gonderilebilir, isFalse);
      expect(const OkumaAnketYaniti(yildiz: 4).gonderilebilir, isTrue);
    });
  });

  group('kahraman', () {
    test('ad kuralı: boş, uzun ve geçersiz karakter reddedilir', () {
      expect(adKontrol(''), isNotNull);
      expect(adKontrol('   '), isNotNull);
      expect(adKontrol('A' * 25), isNotNull);
      expect(adKontrol('Ali123'), isNotNull);
      expect(adKontrol('Işık Muhafızı'), isNull);
      expect(adKontrol("Ayşe-Nur O'Neil"), isNull);
    });

    test('yasak ad: küfür, marka karakteri ve gerçek kişi her türde reddedilir', () {
      for (final ad in ['Sik', 'Orospu', 'Batman', 'Pikachu', 'Atatürk', 'Cristiano Ronaldo', 'Tarkan']) {
        expect(adKontrol(ad), kAdYasakli, reason: ad);
        expect(adKontrol(ad, tur: KahramanTuru.ben), kAdYasakli, reason: ad);
      }
    });

    test('yasak ad: din adları yalnız hayvan, araç ve hayalî türde yasak', () {
      expect(adKontrol('Allah', tur: KahramanTuru.hayvan), kAdYasakli);
      expect(adKontrol('Musa', tur: KahramanTuru.arac), kAdYasakli);
      expect(adKontrol('Peygamber', tur: KahramanTuru.hayali), kAdYasakli);
      expect(adKontrol('Musa', tur: KahramanTuru.ben), isNull);
      expect(adKontrol('Muhammed', tur: KahramanTuru.anne), isNull);
    });

    test('yasak ad: Türkçe büyük/küçük harf duyarsız; hazır öneriler geçer', () {
      expect(adKontrol('SİK'), kAdYasakli);
      expect(adKontrol('ATATÜRK'), kAdYasakli);
      expect(adKontrol('Orospuçocuğu'), kAdYasakli);
      for (final t in KahramanTuru.values) {
        for (final ad in kOnerilenIsimler[t] ?? const <String>[]) {
          expect(adKontrol(ad, tur: t), isNull, reason: ad);
        }
      }
      expect(adKontrol('Işık Muhafızı', tur: KahramanTuru.hayali), isNull);
    });

    test('hazır Hupo ad istemez; diğer türler ister; cinsiyet türü yoktur', () {
      expect(KahramanTuru.hazir.adIster, isFalse);
      expect(KahramanTuru.ben.adIster, isTrue);
      expect(KahramanTuru.values.map((t) => t.kod), isNot(anyOf(contains('kiz'), contains('erkek'))));
    });
  });

  group('sözlük', () {
    test('pakette sozluk varsa yuva ve anlamlar ondan gelir', () {
      final sozluk = jsonDecode(
        '{"sozluk_surumu":1,"girdiler":[{"id":"g1","tur":"kelime","yazim":"gizemli","anlam":"Sır taşıyan.","sinif_alt":4,"sinif_ust":5}],'
        '"yuvalar":[{"ad":"gizem","adaylar":[{"girdi":"g1"}]}]}',
      ) as Map<String, dynamic>;
      final s = okumaSozluguKur(_paket(icerik: {'paket_surumu': 1, 'sozluk': sozluk}));
      expect(s.yuvalar['gizem']!.single.metin, 'gizemli');
      expect(s.anlamlar['gizemli'], 'Sır taşıyan.');
    });

    test('sözlük yoksa öğrenme hedeflerinden tek adaylı yuva kurulur, anlam boştur', () {
      final s = okumaSozluguKur(_paket(icerik: {
        'paket_surumu': 1,
        'hikaye': {
          'sinif_alt': 4,
          'etiketler': {
            'ana_sinif': 4,
            'ogrenme_hedefleri': [
              {'id': 'parlak', 'tur': 'lexeme', 'etiket': 'parlak', 'yuva': 'parlak_sifat'},
              {'id': 'deger', 'tur': 'value', 'etiket': 'sabır'},
            ],
          },
        },
      }));
      expect(s.yuvalar.keys, ['parlak_sifat']);
      expect(s.yuvalar['parlak_sifat']!.single.metin, 'parlak');
      expect(s.anlamlar, isEmpty);
    });

    test('dokunulan metinler yalnız pakette kayıtlı hedef kimliklerine çevrilir', () {
      final p = _paket(icerik: {
        'paket_surumu': 1,
        'hikaye': {
          'etiketler': {
            'ogrenme_hedefleri': [
              {'id': 'parlak', 'etiket': 'parlak', 'yuva': 'y'},
              {'id': 'sabir', 'etiket': 'Sabreden derviş muradına ermiş', 'yuva': 's'},
            ],
          },
        },
      });
      expect(dokunulanHedefKimlikleri(p, {'Parlak', 'başka'}), ['parlak']);
      expect(dokunulanHedefKimlikleri(p, {}), isEmpty);
    });
  });

  group('paket önbelleği', () {
    late SharedPreferences prefs;
    late OkumaPaketOnbellegi onbellek;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      onbellek = OkumaPaketOnbellegi(prefs);
    });

    test('sha256 eşleşirse geçerli, değişirse geçersiz (yeniden indir)', () async {
      await onbellek.yaz(_paket());
      expect(onbellek.gecerliPaket(testSatiri()), isNotNull);
      expect(onbellek.gecerliPaket(testSatiri(sha: 'sha-2')), isNull);
      expect(onbellek.oku(kTestHikayeId), isNotNull, reason: 'internet yokken eski sürüm yine okunabilir');
    });

    test('son 20 hikâye tutulur, en eski silinir', () async {
      for (var i = 0; i < kOkumaOnbellekSiniri + 3; i++) {
        await onbellek.yaz(_paket(id: 'h$i'));
      }
      expect(onbellek.kimlikler.length, kOkumaOnbellekSiniri);
      expect(onbellek.oku('h0'), isNull);
      expect(onbellek.oku('h2'), isNull);
      expect(onbellek.oku('h3'), isNotNull);
      expect(onbellek.oku('h22'), isNotNull);
    });

    test('yeniden yazılan hikâye listenin sonuna taşınır (en yeni)', () async {
      await onbellek.yaz(_paket(id: 'a'));
      await onbellek.yaz(_paket(id: 'b'));
      await onbellek.yaz(_paket(id: 'a'));
      expect(onbellek.kimlikler, ['b', 'a']);
    });

    test('bozuk kayıt sessizce yok sayılır', () async {
      await prefs.setString('okuma_paket_x', '{bozuk');
      expect(onbellek.oku('x'), isNull);
    });
  });

  group('cihaz deposu', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('okuma modu varsayılan zengin; sade kalıcı', () async {
      final depo = OkumaCihazDeposu(prefs, kullaniciId: 'u1');
      expect(depo.okumaModu, 'zengin');
      await depo.okumaModuYaz('sade');
      expect(OkumaCihazDeposu(prefs, kullaniciId: 'u1').okumaModu, 'sade');
    });

    test('Kahramanlarım: kayıt, kopya olmaz, silinir', () async {
      final depo = OkumaCihazDeposu(prefs, kullaniciId: 'u1');
      const k = KahramanSecimi(tur: KahramanTuru.hayvan, ad: 'Pati', yoldasAd: 'Ali');
      await depo.kahramanKaydet(k);
      await depo.kahramanKaydet(k);
      expect(depo.kahramanlarim().length, 1);
      expect(depo.kahramanlarim().single.yoldasAd, 'Ali');
      await depo.kahramanSil(k);
      expect(depo.kahramanlarim(), isEmpty);
    });

    test('raf başka hesaba görünmez; çıkışta ad dahil her şey silinir', () async {
      final a = OkumaCihazDeposu(prefs, kullaniciId: 'u1');
      await a.kahramanKaydet(const KahramanSecimi(tur: KahramanTuru.ben, ad: 'Efe'));
      await a.okunduYaz(testSatiri(), simdi: DateTime(2026, 10, 18));
      final b = OkumaCihazDeposu(prefs, kullaniciId: 'u2');
      expect(b.kahramanlarim(), isEmpty);
      expect(b.okuduklarim(), isEmpty);

      await b.baskaHesaplariTemizle();
      expect(a.kahramanlarim(), isEmpty, reason: 'başka hesabın artığı temizlenir');

      await b.kahramanKaydet(const KahramanSecimi(tur: KahramanTuru.anne, ad: 'Ayşe'));
      await b.kisiselVerileriSil();
      expect(prefs.getKeys().any((k) => k.contains('kisisel')), isFalse);
      expect(prefs.getKeys().join().contains('Ayşe'), isFalse);
    });

    test('Okuduklarım: yeniden okunan hikâye başa gelir, son okuma yazılır, sınır uygulanır', () async {
      final depo = OkumaCihazDeposu(prefs, kullaniciId: 'u1');
      await depo.okunduYaz(testSatiri(id: 'a', baslik: 'A'), simdi: DateTime(2026, 10, 10));
      await depo.okunduYaz(testSatiri(id: 'b', baslik: 'B'), simdi: DateTime(2026, 10, 11));
      await depo.okunduYaz(testSatiri(id: 'a', baslik: 'A'), simdi: DateTime(2026, 10, 12));
      expect([for (final o in depo.okuduklarim()) o.satir.baslik], ['A', 'B']);
      expect(depo.sonOkuma, DateTime(2026, 10, 12));
      for (var i = 0; i < kOkuduklarimSiniri + 5; i++) {
        await depo.okunduYaz(testSatiri(id: 'h$i'), simdi: DateTime(2026, 10, 13));
      }
      expect(depo.okuduklarim().length, kOkuduklarimSiniri);
    });
  });

  group('geri dönüş', () {
    final simdi = DateTime(2026, 10, 18);

    test('hiç okumamışsa baskı yok', () => expect(geriDonusGerekli(sonOkuma: null, simdi: simdi), isFalse));

    test('3 gün ve üstü mesaj gerektirir, öncesi gerektirmez', () {
      expect(geriDonusGerekli(sonOkuma: simdi.subtract(const Duration(days: 2)), simdi: simdi), isFalse);
      expect(geriDonusGerekli(sonOkuma: simdi.subtract(const Duration(days: 3)), simdi: simdi), isTrue);
    });

    test('mesaj suçlayıcı değildir', () {
      expect(geriDonusMetni(4), '4 gündür yeni bir hikâye okumadın. Seni bekliyoruz!');
    });
  });
}
