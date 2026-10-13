import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/kelime_models.dart';
import 'package:ogrenci_hazirlik/services/kelime_repository.dart';

void main() {
  group('KelimeIliskiTuru', () {
    test('veritabanı değerleri sunucu kısıtıyla aynıdır', () {
      expect(KelimeIliskiTuru.esAnlamli.veritabani, 'es_anlamli');
      expect(KelimeIliskiTuru.zitAnlamli.veritabani, 'zit_anlamli');
      expect(KelimeIliskiTuru.esSesli.veritabani, 'es_sesli');
    });

    test('bilinmeyen değer FormatException verir', () {
      expect(() => KelimeIliskiTuru.fromVeritabani('bilinmeyen'), throwsFormatException);
    });
  });

  group('KelimeSoru.fromMap', () {
    test('doğru şık ve açıklama alanı olmadan okur', () {
      final soru = KelimeSoru.fromMap({
        'id': 's1',
        'anlam_id': 'a1',
        'soru_metni': 'Mutlu kelimesinin eş anlamlısı?',
        'secenekler': ['Üzgün', 'Sevinçli'],
        'ipucu': null,
      });
      expect(soru.secenekler, ['Üzgün', 'Sevinçli']);
      expect(soru.ipucu, isNull);
    });

    test('tek şıklı soruyu reddeder', () {
      expect(
        () => KelimeSoru.fromMap({
          'id': 's1',
          'anlam_id': 'a1',
          'soru_metni': 'Soru metni',
          'secenekler': ['Tek'],
        }),
        throwsFormatException,
      );
    });

    test('beş şıklı soruyu reddeder', () {
      expect(
        () => KelimeSoru.fromMap({
          'id': 's1',
          'anlam_id': 'a1',
          'soru_metni': 'Soru metni',
          'secenekler': ['a', 'b', 'c', 'd', 'e'],
        }),
        throwsFormatException,
      );
    });
  });

  group('KelimeCevapSonucu.fromMap', () {
    test('yanlış cevap açıklamasını ve seviyeyi okur', () {
      final sonuc = KelimeCevapSonucu.fromMap({
        'dogru': false,
        'dogru_indeks': 1,
        'aciklama': 'Mutlu ve sevinçli eş anlamlıdır.',
        'kazanilan_xp': 0,
        'tekrar': false,
        'ustalik': {'beceri': 'taninma', 'seviye': 0, 'sonraki_tekrar_tarihi': '2026-10-11T00:00:00Z'},
      });
      expect(sonuc.dogru, isFalse);
      expect(sonuc.dogruIndeks, 1);
      expect(sonuc.aciklama, 'Mutlu ve sevinçli eş anlamlıdır.');
      expect(sonuc.kazanilanXp, 0);
      expect(sonuc.ustalikSeviyesi, 0);
    });

    test('ustalik alanı yoksa seviye null kalır', () {
      final sonuc = KelimeCevapSonucu.fromMap({
        'dogru': true,
        'dogru_indeks': 0,
        'aciklama': 'Açıklama',
        'kazanilan_xp': 10,
        'tekrar': true,
      });
      expect(sonuc.ustalikSeviyesi, isNull);
      expect(sonuc.tekrar, isTrue);
    });
  });

  group('KelimeVeliOzeti.fromMap', () {
    test('boş veride oranlar null, listeler boş gelir', () {
      final ozet = KelimeVeliOzeti.fromMap({
        'deneme_sayisi': 0,
        'dogru_orani': null,
        'ipucusuz_dogru_orani': null,
        'ipucu_kullanim_orani': null,
        'tekrar_bekleyen': 0,
        'son_7_gun_deneme': 0,
        'zorlanilan': [],
        'oneriler': ['devam'],
      });
      expect(ozet.dogruOrani, isNull);
      expect(ozet.zorlanilan, isEmpty);
      expect(ozet.oneriler, ['devam']);
    });

    test('zorlanılan kelime satırını iliski türüyle okur', () {
      final ozet = KelimeVeliOzeti.fromMap({
        'deneme_sayisi': 7,
        'dogru_orani': 71,
        'ipucusuz_dogru_orani': 60,
        'ipucu_kullanim_orani': 14,
        'tekrar_bekleyen': 1,
        'son_7_gun_deneme': 7,
        'zorlanilan': [
          {'kelime': 'yüz', 'anlam': 'insan başı', 'iliski_turu': 'es_sesli', 'yanlis_sayisi': 2},
        ],
        'oneriler': ['tekrar_bekleyen', 'zorlanilan_tekrar'],
      });
      expect(ozet.zorlanilan.single.iliski, KelimeIliskiTuru.esSesli);
      expect(ozet.zorlanilan.single.yanlisSayisi, 2);
      expect(ozet.oneriler, contains('zorlanilan_tekrar'));
    });
  });

  group('kelimeHatasiCevir (sunucu hatası → Türkçe mesaj)', () {
    test('bilinen sunucu kodları doğru hata sınıfına çevrilir', () {
      expect(kelimeHatasiCevir('SINIF_GEREKLI').hata, KelimeHatasi.sinifGerekli);
      expect(kelimeHatasiCevir('STUDENT_ONLY').hata, KelimeHatasi.yetkisiz);
      expect(kelimeHatasiCevir('AUTH_REQUIRED').hata, KelimeHatasi.yetkisiz);
      expect(kelimeHatasiCevir('SORU_BULUNAMADI').hata, KelimeHatasi.soruBulunamadi);
      expect(kelimeHatasiCevir('RATE_LIMIT').hata, KelimeHatasi.hizSiniri);
      expect(kelimeHatasiCevir('IDEMPOTENCY_CONFLICT').hata, KelimeHatasi.cevapCakismasi);
      expect(kelimeHatasiCevir('INVALID_ATTEMPT_KEY').hata, KelimeHatasi.gecersizDeneme);
      expect(kelimeHatasiCevir('BAD_OPTION').hata, KelimeHatasi.gecersizDeneme);
    });

    test('bilinmeyen metin ham hata yerine genel Türkçe mesaja düşer', () {
      final hata = kelimeHatasiCevir('relation "kelime_sorulari" does not exist');
      expect(hata.hata, KelimeHatasi.bilinmeyen);
      expect(hata.mesaj, isNot(contains('relation')));
      expect(hata.mesaj, isNotEmpty);
    });
  });
}
