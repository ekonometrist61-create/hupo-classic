import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/widgets/evolving_avatar/avatar_models.dart';

void main() {
  group('Evre sınırları (toplam XP)', () {
    test('her sınırda doğru evre', () {
      expect(AvatarEvolutionManager.getTierFromXP(0), AvatarTier.bronz);
      expect(AvatarEvolutionManager.getTierFromXP(499), AvatarTier.bronz);
      expect(AvatarEvolutionManager.getTierFromXP(500), AvatarTier.gumus);
      expect(AvatarEvolutionManager.getTierFromXP(1499), AvatarTier.gumus);
      expect(AvatarEvolutionManager.getTierFromXP(1500), AvatarTier.altin);
      expect(AvatarEvolutionManager.getTierFromXP(3499), AvatarTier.altin);
      expect(AvatarEvolutionManager.getTierFromXP(3500), AvatarTier.elmas);
      expect(AvatarEvolutionManager.getTierFromXP(7499), AvatarTier.elmas);
      expect(AvatarEvolutionManager.getTierFromXP(7500), AvatarTier.efsanevi);
      expect(AvatarEvolutionManager.getTierFromXP(1000000), AvatarTier.efsanevi);
    });

    test('eksi veya bozuk XP bronz sayılır', () {
      expect(AvatarEvolutionManager.getTierFromXP(-50), AvatarTier.bronz);
    });
  });

  group('Unvan ve kostüm', () {
    test('unvanlar', () {
      expect(AvatarTier.bronz.title, 'Çaylak Alp');
      expect(AvatarTier.gumus.title, 'Genç Kemankeş');
      expect(AvatarTier.altin.title, 'Akıncı');
      expect(AvatarTier.elmas.title, 'Siber Yeniçeri');
      expect(AvatarTier.efsanevi.title, 'Efsanevi Anka');
    });

    test('sonraki hedef XP, son evrede null', () {
      expect(AvatarTier.bronz.nextTargetXp, 500);
      expect(AvatarTier.gumus.nextTargetXp, 1500);
      expect(AvatarTier.altin.nextTargetXp, 3500);
      expect(AvatarTier.elmas.nextTargetXp, 7500);
      expect(AvatarTier.efsanevi.nextTargetXp, isNull);
    });

    test('her evrenin farklı ana rengi ve kutlama cümlesi var', () {
      final colors = {for (final t in AvatarTier.values) t.primaryColor};
      expect(colors.length, AvatarTier.values.length);
      expect(
        AvatarTier.altin.unlockMessage,
        'Tebrikler! Akıncı unvanını ve Akıncı Pelerini ve Sancağı kostümünü kazandın!',
      );
    });

    test('bozkurt/kurt temalı ifade kullanılmaz (siyasi hassasiyet)', () {
      for (final t in AvatarTier.values) {
        final text = '${t.title} ${t.costumeName}'.toLowerCase();
        expect(text.contains('bozkurt'), isFalse);
        expect(text.contains('kurt'), isFalse);
      }
    });
  });

  group('İlerleme', () {
    test('kalan XP', () {
      expect(AvatarEvolutionManager.xpToNextTier(0), 500);
      expect(AvatarEvolutionManager.xpToNextTier(350), 150);
      expect(AvatarEvolutionManager.xpToNextTier(500), 1000);
      expect(AvatarEvolutionManager.xpToNextTier(7500), 0);
      expect(AvatarEvolutionManager.xpToNextTier(99999), 0);
    });

    test('evre içi ilerleme oranı', () {
      expect(AvatarEvolutionManager.progressInTier(0), 0);
      expect(AvatarEvolutionManager.progressInTier(250), closeTo(0.5, 1e-9));
      expect(AvatarEvolutionManager.progressInTier(500), 0); // yeni evrenin başı
      expect(AvatarEvolutionManager.progressInTier(1000), closeTo(0.5, 1e-9));
      expect(AvatarEvolutionManager.progressInTier(8000), 1);
    });

    test('yükselme tespiti', () {
      expect(AvatarEvolutionManager.isPromotion(AvatarTier.gumus, AvatarTier.altin), isTrue);
      expect(AvatarEvolutionManager.isPromotion(AvatarTier.altin, AvatarTier.altin), isFalse);
      expect(AvatarEvolutionManager.isPromotion(AvatarTier.altin, AvatarTier.gumus), isFalse);
    });

    test('motivasyon cümlesi dinamik hesaplanır', () {
      expect(
        AvatarEvolutionManager.motivationText(3000),
        'Siber Yeniçeri olmana ve Neon Siperlik açmana sadece 500 XP kaldı!',
      );
      expect(
        AvatarEvolutionManager.motivationText(8000),
        'Zirvedesin! Efsanevi Anka unvanı sonsuza kadar senin.',
      );
    });
  });
}
