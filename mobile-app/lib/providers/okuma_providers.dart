// Okuma Dünyası: Riverpod sağlayıcıları. Ekranlar yalnız bunları kullanır.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/okuma_models.dart';
import '../services/okuma_cihaz_deposu.dart';
import '../services/okuma_pdf_hizmeti.dart';
import '../services/okuma_repository.dart';
import '../settings/app_settings.dart';
import 'app_providers.dart';
import 'okuma_akis.dart';

final okumaRepositoryProvider = Provider<OkumaRepository>(
  (ref) => SupabaseOkumaRepository(ref.watch(supabaseProvider)),
);

final okumaOnbellekProvider = Provider<OkumaPaketOnbellegi>(
  (ref) => OkumaPaketOnbellegi(ref.watch(sharedPreferencesProvider)),
);

/// Cihaz tercihleri ve hesaba bağlı kişisel raflar (kahramanlarım, okuduklarım).
final okumaCihazDeposuProvider = Provider<OkumaCihazDeposu>(
  (ref) => OkumaCihazDeposu(
    ref.watch(sharedPreferencesProvider),
    kullaniciId: ref.watch(currentUserIdProvider),
  ),
);

/// PDF üreticisi. Testlerde sahtesiyle değiştirilir; gerçeği ertelenmiş yüklenir.
final okumaPdfUreticiProvider = Provider<OkumaPdfUretici>((ref) => okumaPdfUret);

/// Saat kaynağı (testte sabitlenir).
final okumaSimdiProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Çıkış olaylarını bildirir. Supabase başlatılmamışsa (test) boş akış döner.
final okumaCikisAkisiProvider = Provider<Stream<void>>((ref) {
  try {
    return ref
        .watch(supabaseProvider)
        .auth
        .onAuthStateChange
        .where((s) => s.event == AuthChangeEvent.signedOut)
        .map((_) {});
  } on Object {
    return const Stream<void>.empty();
  }
});

/// Çıkışta kişisel okuma verilerini (kahramanlarım dahil) siler; hesap değişiminde başka
/// hesabın artıklarını temizler. Öğren kartı bunu izler (sekme açıkken her zaman canlıdır).
final okumaOturumBekciProvider = Provider<void>((ref) {
  final OkumaCihazDeposu depo;
  try {
    depo = ref.watch(okumaCihazDeposuProvider);
  } on Object {
    return; // tercih deposu hazır değilse (ör. izole widget testi) bekçi çalışmaz; kart zaten görünmez
  }
  unawaited(depo.baskaHesaplariTemizle());
  final abonelik = ref.watch(okumaCikisAkisiProvider).listen((_) => unawaited(depo.kisiselVerileriSil()));
  ref.onDispose(abonelik.cancel);
});

/// Özellik bayrağı. Hata ya da kapalı → modül HİÇ görünmez (sessiz).
final okumaOzellikProvider = FutureProvider.autoDispose<OkumaOzellikDurumu>((ref) async {
  try {
    return await ref.watch(okumaRepositoryProvider).ozellikDurumu();
  } on Object {
    // Bayrak okunamadıysa kart gösterilmez; kullanıcıya gürültü yapılmaz.
    return OkumaOzellikDurumu.kapali;
  }
});

/// Öğren kartı: bugünkü hikâye önerisi ve okuma serisi. Başarısızsa null (kart yalın kalır).
final okumaSeriOneriProvider = FutureProvider.autoDispose<OkumaSeriVeOneri?>((ref) async {
  try {
    return await ref.watch(okumaRepositoryProvider).seriVeOneri();
  } on Object {
    return null;
  }
});

/// Cihazdaki "Sözlüğüm" listesi: kullanıcının "Sözlüğe ekle" ile kaydettiği atasözleri.
final okumaSozlugumProvider = Provider.autoDispose<List<OkumaSozlukKaydi>>(
  (ref) => ref.watch(okumaCihazDeposuProvider).sozlugum(),
);

/// Yarım kalan hikâye (yalnız cihazda). Yoksa null.
final okumaDevamProvider = Provider.autoDispose<OkumaDevam?>((ref) => ref.watch(okumaCihazDeposuProvider).devam());

/// Vitrin için hikâye kataloğu (kategori sayıları, Tüm hikâyeler). Hata AsyncError olarak kalır;
/// ekran "yüklenemedi" ile "hikâye yok" durumlarını ayırt eder.
final okumaVitrinKatalogProvider = FutureProvider.autoDispose<List<OkumaKatalogSatiri>>(
  (ref) => ref.watch(okumaRepositoryProvider).katalog(limit: 48),
);

/// Öğrencinin sınıfı (`my_sinif()`; sunucu belirler). Okunamazsa null: görseller varsayılan
/// (2–4. sınıf) dilinde kalır.
final okumaSinifProvider = FutureProvider.autoDispose<int?>((ref) async {
  try {
    final v = await ref.watch(supabaseProvider).rpc('my_sinif');
    return v is num ? v.toInt() : null;
  } on Object {
    return null;
  }
});

/// Cihazdaki "Okuduklarım" rafı.
final okumaOkuduklarimProvider = Provider.autoDispose<List<OkunanHikaye>>(
  (ref) => ref.watch(okumaCihazDeposuProvider).okuduklarim(),
);

/// Bir okuma akışı. Ekran kapanınca bellekteki kahraman adı da gider.
final okumaAkisProvider = StateNotifierProvider.autoDispose<OkumaAkisDenetleyici, OkumaAkisDurumu>((ref) {
  final depo = ref.watch(okumaCihazDeposuProvider);
  return OkumaAkisDenetleyici(
    repo: ref.watch(okumaRepositoryProvider),
    onbellek: ref.watch(okumaOnbellekProvider),
    depo: depo,
    pdfUretici: ref.watch(okumaPdfUreticiProvider),
    simdi: ref.watch(okumaSimdiProvider),
    okumaModu: () => depo.okumaModu,
  );
});
