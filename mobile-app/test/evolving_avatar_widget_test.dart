import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/widgets/evolving_avatar/avatar_models.dart';
import 'package:ogrenci_hazirlik/widgets/evolving_avatar/evolving_avatar_widget.dart';

Widget _wrap(Widget child, {bool reduced = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(body: Center(child: child)),
      ),
    );

void main() {
  group('EvolvingAvatarWidget', () {
    for (final tier in AvatarTier.values) {
      testWidgets('${tier.name}: çizilir ve semantik etiketi doğru', (tester) async {
        await tester.pumpWidget(
          _wrap(EvolvingAvatarWidget(currentXP: 0, tier: tier), reduced: true),
        );
        expect(tester.takeException(), isNull);
        expect(find.bySemanticsLabel('${tier.title} avatarı'), findsOneWidget);
      });
    }

    for (final xp in [0, 500, 1500, 3500, 7500]) {
      testWidgets('xp $xp: doğru evre çizilir', (tester) async {
        await tester.pumpWidget(_wrap(EvolvingAvatarWidget(currentXP: xp, size: 80), reduced: true));
        expect(tester.takeException(), isNull);
        final tier = AvatarEvolutionManager.getTierFromXP(xp);
        expect(find.bySemanticsLabel('${tier.title} avatarı'), findsOneWidget);
      });
    }

    testWidgets('hareket azaltılmışsa efsanevi animasyonu çalışmaz', (tester) async {
      await tester.pumpWidget(
        _wrap(const EvolvingAvatarWidget(currentXP: 0, tier: AvatarTier.efsanevi), reduced: true),
      );
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('hareket açıkken efsanevi animasyonu çalışır', (tester) async {
      await tester.pumpWidget(
        _wrap(const EvolvingAvatarWidget(currentXP: 0, tier: AvatarTier.efsanevi)),
      );
      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('bronz evrede animasyon yoktur', (tester) async {
      await tester.pumpWidget(
        _wrap(const EvolvingAvatarWidget(currentXP: 0, tier: AvatarTier.bronz)),
      );
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('evre efsanevi olunca animasyon başlar, düşünce durur', (tester) async {
      await tester.pumpWidget(_wrap(const EvolvingAvatarWidget(currentXP: 100)));
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpWidget(_wrap(const EvolvingAvatarWidget(currentXP: 8000)));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpWidget(_wrap(const EvolvingAvatarWidget(currentXP: 100)));
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
