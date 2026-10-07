// Alt gezinmeli ana kabuk: Ana Sayfa · Öğren · Arena · Koleksiyon · Profil.
// Sekmeler ilk açıldığında kurulur (gereksiz ağ isteği yok) ve durumlarını korur.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import 'arena_screen.dart';
import 'collection_screen.dart';
import 'home_screen.dart';
import 'learn_screen.dart';
import 'profile_screen.dart';

class _Sekme {
  const _Sekme(this.etiket, this.simge, this.seciliSimge);

  final String etiket;
  final IconData simge;
  final IconData seciliSimge;
}

const _sekmeler = [
  _Sekme('Ana Sayfa', Icons.home_outlined, Icons.home_rounded),
  _Sekme('Öğren', Icons.menu_book_outlined, Icons.menu_book_rounded),
  _Sekme('Arena', Icons.sports_esports_outlined, Icons.sports_esports_rounded),
  _Sekme('Koleksiyon', Icons.shield_outlined, Icons.shield_rounded),
  _Sekme('Profil', Icons.person_outline_rounded, Icons.person_rounded),
];

class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  final _acilanlar = <int>{0};

  Widget _sekmeGovdesi(int i) {
    if (!_acilanlar.contains(i)) return const SizedBox.shrink();
    return switch (i) {
      0 => const HomeScreen(),
      1 => const LearnScreen(),
      2 => const ArenaScreen(),
      3 => const CollectionScreen(embedded: true),
      _ => const ProfileScreen(embedded: true),
    };
  }

  @override
  Widget build(BuildContext context) {
    final secili = ref.watch(shellTabProvider);
    _acilanlar.add(secili);

    // Geri tuşu: Ana Sayfa dışındaki sekmeden önce Ana Sayfa'ya döner, sonra çıkar.
    return PopScope(
      canPop: secili == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(shellTabProvider.notifier).state = 0;
      },
      child: Scaffold(
        body: IndexedStack(
          index: secili,
          children: [for (var i = 0; i < _sekmeler.length; i++) _sekmeGovdesi(i)],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: secili,
          onDestinationSelected: (i) => ref.read(shellTabProvider.notifier).state = i,
          destinations: [
            for (final s in _sekmeler)
              NavigationDestination(
                icon: Icon(s.simge),
                selectedIcon: Icon(s.seciliSimge, color: AppColors.primary),
                label: s.etiket,
              ),
          ],
        ),
      ),
    );
  }
}
