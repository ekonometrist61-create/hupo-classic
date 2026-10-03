import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:ogrenci_hazirlik/models/app_config.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/widgets/maintenance_gate.dart';

AppConfig _config({
  bool bakimda = false,
  String minSurum = '0.0.0',
  String? bakimMesaji,
  String? surumMesaji,
}) =>
    AppConfig(
      bakimModu: BakimModu(aktif: bakimda, mesaj: bakimMesaji),
      minSurum: MinSurum(
        android: minSurum,
        ios: minSurum,
        web: minSurum,
        mesaj: surumMesaji,
      ),
      reklamlar: const ReklamAyarlari(
        ogrenciAcik: false,
        veliPaneliAcik: false,
      ),
    );

Future<void> _pumpGate(
  WidgetTester tester, {
  required AppConfig config,
  String version = '1.0.0',
}) async {
  PackageInfo.setMockInitialValues(
    appName: 'Test',
    packageName: 'com.test',
    version: version,
    buildNumber: '1',
    buildSignature: '',
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigFetcherProvider.overrideWith((ref) async => config),
      ],
      child: const MaterialApp(
        home: MaintenanceGate(child: Text('ana ekran')),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MaintenanceScreen — bakım modu', () {
    testWidgets('başlık ve mesaj gösterir, çekiç simgesi var', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: MaintenanceScreen(
          title: 'Hupo, bakım yapıyor',
          message: 'Birazdan buradayız!',
        ),
      ));
      expect(find.text('Hupo, bakım yapıyor'), findsOneWidget);
      expect(find.text('Birazdan buradayız!'), findsOneWidget);
      expect(find.byIcon(Icons.handyman_rounded), findsOneWidget);
      expect(find.byIcon(Icons.system_update_rounded), findsNothing);
      expect(find.text('Mağazaya Git'), findsNothing);
    });
  });

  group('MaintenanceScreen — güncelleme', () {
    testWidgets('güncelleme simgesi ve Mağazaya Git butonu gösterir',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: MaintenanceScreen(
          title: 'Yeni sürüm hazır!',
          message: 'Lütfen güncelle.',
          isUpdateRequired: true,
        ),
      ));
      expect(find.text('Yeni sürüm hazır!'), findsOneWidget);
      expect(find.byIcon(Icons.system_update_rounded), findsOneWidget);
      expect(find.text('Mağazaya Git'), findsOneWidget);
      expect(find.byIcon(Icons.handyman_rounded), findsNothing);
    });
  });

  group('MaintenanceGate kararları', () {
    testWidgets('bakım modu açıksa bakım ekranı gösterir', (tester) async {
      await _pumpGate(tester, config: _config(bakimda: true));
      expect(find.text('Hupo, bakım yapıyor'), findsOneWidget);
      expect(find.text('ana ekran'), findsNothing);
    });

    testWidgets('sunucu özel bakım mesajını gösterir', (tester) async {
      await _pumpGate(
        tester,
        config: _config(bakimda: true, bakimMesaji: 'Yarın açılacak.'),
      );
      expect(find.text('Yarın açılacak.'), findsOneWidget);
    });

    testWidgets('sürüm eskiyse güncelleme ekranı gösterir', (tester) async {
      await _pumpGate(
        tester,
        config: _config(minSurum: '2.0.0'),
      );
      expect(find.text('Yeni sürüm hazır!'), findsOneWidget);
      expect(find.text('ana ekran'), findsNothing);
    });

    testWidgets('patch sürüm eskiyse güncelleme gerektirir', (tester) async {
      await _pumpGate(
        tester,
        config: _config(minSurum: '1.0.5'),
        version: '1.0.3',
      );
      expect(find.text('Yeni sürüm hazır!'), findsOneWidget);
    });

    testWidgets('güncel sürümde çocuğu gösterir', (tester) async {
      await _pumpGate(
        tester,
        config: _config(minSurum: '1.0.0'),
      );
      expect(find.text('ana ekran'), findsOneWidget);
      expect(find.text('Hupo, bakım yapıyor'), findsNothing);
    });

    testWidgets('daha yeni sürümde de çocuğu gösterir', (tester) async {
      await _pumpGate(
        tester,
        config: _config(minSurum: '1.0.0'),
        version: '2.5.0',
      );
      expect(find.text('ana ekran'), findsOneWidget);
    });

    testWidgets('ağ hatasında çocuğu kilitleme', (tester) async {
      PackageInfo.setMockInitialValues(
        appName: 'Test',
        packageName: 'com.test',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigFetcherProvider.overrideWith(
              (ref) async => throw Exception('Ağ hatası'),
            ),
          ],
          child: const MaterialApp(
            home: MaintenanceGate(child: Text('ana ekran')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ana ekran'), findsOneWidget);
    });
  });
}
