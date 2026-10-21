// "Senin Hikâyen" tarayıcı önizlemesi (yalnız geliştirme/QA aracı; uygulamaya GİRMEZ).
//
// Gerçek Supabase'e bağlanmaz: RPC'ler henüz uzak veritabanına uygulanmadığı için sahte depo kullanır.
// Derleme: flutter build web --release -t tool/okuma_onizleme/main.dart -o build/okuma_onizleme
// URL parametreleri: ?kota=1 (bugünkü hak doldu)  ?kapali=1 (bayrak kapalı)  ?sade=1 (okuma modu)

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ogrenci_hazirlik/models/models.dart';
import 'package:ogrenci_hazirlik/models/okuma_models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/providers/okuma_providers.dart';
import 'package:ogrenci_hazirlik/services/okuma_repository.dart';
import 'package:ogrenci_hazirlik/settings/app_settings.dart';
import 'package:ogrenci_hazirlik/theme/app_theme.dart';
import 'package:ogrenci_hazirlik/widgets/okuma/okuma_bugun_karti.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onizleme_veri.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sorgu = Uri.base.queryParameters;
  final prefs = await SharedPreferences.getInstance();
  if (sorgu['sade'] == '1') await prefs.setString('okuma_modu', 'sade');
  final depo = OnizlemeOkumaRepository(kapali: sorgu['kapali'] == '1', kotaDolu: sorgu['kota'] == '1');
  runApp(
    ProviderScope(
      overrides: [
        okumaRepositoryProvider.overrideWithValue(depo),
        sharedPreferencesProvider.overrideWithValue(prefs),
        currentUserIdProvider.overrideWithValue('onizleme'),
        okumaCikisAkisiProvider.overrideWithValue(const Stream<void>.empty()),
        profileProvider.overrideWith((ref) async => const Profile(id: 'x', role: 'ogrenci', fullName: 'Ayşe Yılmaz')),
      ],
      child: const _Onizleme(),
    ),
  );
}

class _Onizleme extends ConsumerWidget {
  const _Onizleme();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayar = ref.watch(settingsProvider);
    return MaterialApp(
      title: 'Senin Hikâyen önizleme',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(fontFamily: ayar.font.family),
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            disableAnimations: mq.disableAnimations || ayar.reduceMotion,
            textScaler: TextScaler.linear((mq.textScaler.scale(1) * ayar.textSize.scale).clamp(0.8, 2.0).toDouble()),
          ),
          child: child!,
        );
      },
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Öğren (önizleme)', style: appText(size: 30, weight: FontWeight.w900)),
                    const SizedBox(height: 24),
                    const OkumaBugunKarti(),
                    Text('Dersler', style: appText(size: 19, weight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Web'de çalışan sahte depo (sunucu davranışını taklit eder; cevap anahtarı yalnız burada).
class OnizlemeOkumaRepository implements OkumaRepository {
  OnizlemeOkumaRepository({this.kapali = false, this.kotaDolu = false})
      : _tam = jsonDecode(kOnizlemePaket) as Map<String, dynamic> {
    _tam['sozluk'] = jsonDecode(kOnizlemeSozluk);
    (_tam['hikaye'] as Map<String, dynamic>)['tanitim'] = 'Fener bir gece söndü. Işığı kim yakıyor?';
  }

  final bool kapali;
  final bool kotaDolu;
  final Map<String, dynamic> _tam;
  final Map<String, String> _secimler = {};

  static const _id = '11111111-1111-1111-1111-111111111111';

  OkumaKatalogSatiri get _satir => const OkumaKatalogSatiri(
        hikayeId: _id,
        surumId: 's1',
        surumNo: 1,
        slug: 'feneri-kim-yakiyor',
        baslik: 'Feneri Kim Yakıyor?',
        tanitim: 'Fener bir gece söndü. Işığı kim yakıyor?',
        tur: 'macera',
        anaSinif: 4,
        sha256: 'sha-1',
        izinliTurler: ['hayvan', 'hayali', 'ben', 'baska_biri'],
        tahminiSureDk: 3,
        soruSayisi: 4,
        gorulmedi: true,
      );

  String _dogru(String soruId) => ((_tam['sorular'] as List).cast<Map<String, dynamic>>().firstWhere((s) => s['id'] == soruId))['dogru'] as String;

  @override
  Future<OkumaOzellikDurumu> ozellikDurumu() async => OkumaOzellikDurumu(erisim: !kapali);

  @override
  Future<List<OkumaKatalogSatiri>> katalog({String? kahramanTuru, int limit = 24}) async =>
      [if (kahramanTuru == null || _satir.izinliTurler.contains(kahramanTuru)) _satir];

  @override
  Future<OkumaPaketi> hikayeGetir(String hikayeId) async {
    final kopya = jsonDecode(jsonEncode(_tam)) as Map<String, dynamic>..remove('uretim');
    kopya['sorular'] = [
      for (final s in (kopya['sorular'] as List)) {...(s as Map<String, dynamic>)}..remove('dogru')..remove('aciklama'),
    ];
    return OkumaPaketi(hikayeId: hikayeId, surumId: 's1', surum: 1, sha256: 'sha-1', minMotorSurumu: 1, paket: kopya);
  }

  @override
  Future<OkumaOturum> oturumBaslat({
    required String hikayeId,
    required String kahramanTuru,
    required bool yoldasVar,
    required String okumaModu,
    required String istemciAnahtari,
  }) async =>
      OkumaOturum(oturumId: '22222222-2222-2222-2222-222222222222', hikayeId: hikayeId, soruSayisi: 4);

  @override
  Future<void> ilerlemeKaydet({required String oturumId, required int sayfa}) async {}

  @override
  Future<OkumaCevapSonucu> cevapKontrol({required String oturumId, required String soruId, required String secenekId}) async {
    final secilen = _secimler.putIfAbsent(soruId, () => secenekId);
    final soru = (_tam['sorular'] as List).cast<Map<String, dynamic>>().firstWhere((s) => s['id'] == soruId);
    return OkumaCevapSonucu(
      dogru: secilen == _dogru(soruId),
      aciklama: soru['aciklama'] as String,
      dogruSecenekId: _dogru(soruId),
      tekrar: secilen != secenekId,
    );
  }

  @override
  Future<OkumaSonuc> oturumBitir({required String oturumId, List<String> dokunulan = const []}) async {
    final dogru = _secimler.entries.where((e) => e.value == _dogru(e.key)).length;
    return OkumaSonuc(
      soruSayisi: 4,
      dogruSayisi: dogru,
      dogruOrani: dogru * 25,
      kazanilanXp: dogru >= 3 ? 20 : 10,
      ilkTamamlama: true,
      seri: const OkumaSeri(seriSayisi: 3, seriDevam: true),
    );
  }

  @override
  Future<void> geriBildirimGonder({required String oturumId, required OkumaAnketYaniti yanit}) async {}

  @override
  Future<OkumaSeriVeOneri> seriVeOneri() async => OkumaSeriVeOneri(
        seri: const OkumaSeri(seriSayisi: 3, seriDevam: true),
        kotaDolu: kotaDolu,
        oneri: kotaDolu ? null : _satir,
      );

  @override
  Future<OkumaPdfHakki> pdfHakkiKullan(String hikayeId) async => const OkumaPdfHakki(izin: true, kalan: 2);
}
