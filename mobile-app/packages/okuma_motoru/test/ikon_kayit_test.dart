import 'package:okuma_motoru/hikaye_cozucu.dart';
import 'package:okuma_motoru/ikon_kayit.dart';
import 'package:test/test.dart';

void main() {
  group('ikon kataloğu', () {
    test('89 benzersiz kavram ve her biri için renkli + sade dosya adı', () {
      expect(ikonKatalogu, hasLength(89));
      final ids = ikonKatalogu.map((k) => k.id).toSet();
      expect(ids, hasLength(89));
      for (final k in ikonKatalogu) {
        expect(k.renkliDosya, '${k.id}.svg');
        expect(k.sadeDosya, '${k.id}.muted.svg');
        expect(k.etiket, isNotEmpty);
      }
    });

    test('kimlik ile kayıt bulunur, bilinmeyen kimlik null döner', () {
      expect(ikonBul('lighthouse')?.etiket, 'Deniz feneri');
      expect(ikonBul('yok-boyle-bir-kavram'), isNull);
    });

    test('kavram etiketleri Türkçe karakterleri korur', () {
      expect(ikonBul('gear')?.etiket, 'Mekanizma');
      expect(ikonBul('curiosity')?.etiket, 'Merak');
      expect(ikonBul('teamwork')?.etiket, 'İş birliği');
    });
  });

  group('kaynak çözümleme (eski kod, emoji, kimlik)', () {
    test('mevcut on altı emoji kodu katalog kimliğine bağlanır', () {
      const beklenen = {
        'ipucu': 'magnifier',
        'yildiz': 'star',
        'kitap': 'book',
        'anahtar': 'key',
        'roket': 'rocket',
        'kalp': 'heart',
        'kedi': 'cat',
        'kus': 'bird',
        'ay': 'moon',
        'bulut': 'cloud',
        'ucak': 'plane',
        'balik': 'fish',
        'orman': 'forest',
        'deniz': 'wave',
        'gunes': 'sun',
      };
      for (final e in beklenen.entries) {
        expect(ikonKimligiCoz(e.key), e.value, reason: e.key);
        expect(ikonBul(e.value), isNotNull, reason: e.value);
      }
    });

    test('maskot ayrı kimliktir ve katalogda çizim gerektirmez', () {
      expect(ikonKimligiCoz('hupo'), kMaskotIkonKimligi);
      expect(ikonBul(kMaskotIkonKimligi), isNull);
    });

    test('ham emoji (varyasyon seçicili olsun olmasın) çözülür; bilinmeyen null', () {
      expect(ikonKimligiCoz('☁️'), 'cloud');
      expect(ikonKimligiCoz('☁'), 'cloud');
      expect(ikonKimligiCoz('🌊'), 'wave');
      expect(ikonKimligiCoz('🦄'), isNull);
    });
  });

  group('çözücü ikon kimliğini taşır', () {
    test('işaret ve ikon parçaları ikonId ile gelir, metin değişmez', () {
      final hikaye = Hikaye(
        sayfalar: const [
          [
            Metin('Deniz'),
            Isaret('deniz'),
            Ikon('🔑'),
          ],
        ],
        izinliTurler: const ['kedi'],
      );
      final cikti = sayfalariCoz(
        hikaye,
        const Baglam(kahramanAdi: 'Ece', kahramanTuru: 'kedi', sinif: 4),
      ).single;

      expect(cikti[0].ikonId, isNull);
      expect(cikti[1].metin, '🌊');
      expect(cikti[1].ikonId, 'wave');
      expect(cikti[1].stil, Stil.isaret);
      expect(cikti[2].ikonId, 'key');
    });

    test('bilinmeyen ham emoji metni korur, ikonId null kalır', () {
      final hikaye = Hikaye(
        sayfalar: const [
          [Ikon('🦄')],
        ],
        izinliTurler: const ['kedi'],
      );
      final cikti = sayfalariCoz(
        hikaye,
        const Baglam(kahramanAdi: 'Ece', kahramanTuru: 'kedi', sinif: 4),
      ).single;
      expect(cikti.single.metin, '🦄');
      expect(cikti.single.ikonId, isNull);
    });
  });
}
