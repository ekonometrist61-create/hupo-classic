// Karakter koleksiyonu kutlama dinleyicisi.
//
// myCharactersProvider her yenilendiğinde yeni açılan karakterleri algılar;
// ilk kez kazanılan her karakter için CharacterUnlockDialog açar.
// TierCelebrationListener ile aynı SharedPreferences+listenManual desenini kullanır.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/character_models.dart';
import '../../providers/app_providers.dart';
import '../../settings/app_settings.dart';
import 'character_unlock_dialog.dart';

class CharacterCelebrationListener extends ConsumerStatefulWidget {
  const CharacterCelebrationListener({super.key, required this.child});

  final Widget child;

  static String storageKey(String userId) => 'unlocked_chars_$userId';

  @override
  ConsumerState<CharacterCelebrationListener> createState() =>
      _CharacterCelebrationListenerState();
}

class _CharacterCelebrationListenerState
    extends ConsumerState<CharacterCelebrationListener> {
  ProviderSubscription<AsyncValue<List<CharacterCard>>>? _subscription;
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    _subscription = ref.listenManual(
      myCharactersProvider,
      (previous, next) {
        final list = next.valueOrNull;
        if (list != null) _check(list);
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }

  Future<void> _check(List<CharacterCard> karakterler) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final prefs = ref.read(sharedPreferencesProvider);
    final key = CharacterCelebrationListener.storageKey(userId);

    final simdikiKazanilan = karakterler
        .where((k) => k.kazanildi)
        .map((k) => k.kod)
        .toSet();

    final eskiKodlar = (prefs.getStringList(key) ?? <String>[]).toSet();

    // İlk yükleme — sadece kaydet, kutlama yapma
    if (eskiKodlar.isEmpty && simdikiKazanilan.isNotEmpty) {
      await prefs.setStringList(key, simdikiKazanilan.toList());
      return;
    }

    final yeniAcilanlar = simdikiKazanilan.difference(eskiKodlar);
    if (yeniAcilanlar.isEmpty) return;

    await prefs.setStringList(key, simdikiKazanilan.toList());

    final kutlanacak = karakterler
        .where((k) => yeniAcilanlar.contains(k.kod))
        .firstOrNull;
    if (kutlanacak == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _showing) return;
      _showing = true;
      await showCharacterUnlockDialog(context, kutlanacak);
      _showing = false;
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
