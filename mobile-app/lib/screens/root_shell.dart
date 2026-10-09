// Gezinmeli ana kabuk: Ana Sayfa · Öğren · Arena · Koleksiyon · Profil.
// Telefon ve tablette alt çubuk, masaüstünde (>= 1024) sol NavigationRail.
// Sekmeler ilk açıldığında kurulur (gereksiz ağ isteği yok) ve durumlarını korur.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/breakpoints.dart';
import '../widgets/hupo/hupo.dart';
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

  /// Pencere yeniden boyutlanıp düzen (alt çubuk <-> rail) değişse bile sekme
  /// durumlarının korunması için sekme gövdesi sabit anahtarla taşınır.
  final _govdeAnahtari = GlobalKey(debugLabel: 'kabukGovde');

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

  void _sekmeSec(int i) => ref.read(shellTabProvider.notifier).state = i;

  Widget _rail(int secili) {
    return NavigationRail(
      selectedIndex: secili,
      onDestinationSelected: _sekmeSec,
      labelType: NavigationRailLabelType.all,
      minWidth: 96,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primarySoft,
      selectedIconTheme: const IconThemeData(color: AppColors.primary),
      unselectedIconTheme: const IconThemeData(color: AppColors.muted),
      selectedLabelTextStyle: appText(
        size: 12,
        weight: FontWeight.w900,
        color: AppColors.primary,
      ),
      unselectedLabelTextStyle: appText(
        size: 12,
        weight: FontWeight.w700,
        color: AppColors.muted,
      ),
      leading: const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Hupo(mood: HupoMood.greeting, size: 48),
      ),
      destinations: [
        for (final s in _sekmeler)
          NavigationRailDestination(
            icon: Icon(s.simge),
            selectedIcon: Icon(s.seciliSimge),
            label: Text(s.etiket),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final secili = ref.watch(shellTabProvider);
    _acilanlar.add(secili);
    final masaustu = isDesktop(context);

    final govde = IndexedStack(
      key: _govdeAnahtari,
      index: secili,
      children: [for (var i = 0; i < _sekmeler.length; i++) _sekmeGovdesi(i)],
    );

    // Geri tuşu: Ana Sayfa dışındaki sekmeden önce Ana Sayfa'ya döner, sonra çıkar.
    return PopScope(
      canPop: secili == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(shellTabProvider.notifier).state = 0;
      },
      child: Scaffold(
        body: masaustu
            ? Row(
                children: [
                  _rail(secili),
                  const VerticalDivider(
                      width: 1, thickness: 1, color: AppColors.line),
                  Expanded(child: govde),
                ],
              )
            : govde,
        bottomNavigationBar: masaustu
            ? null
            : NavigationBar(
                selectedIndex: secili,
                onDestinationSelected: _sekmeSec,
                destinations: [
                  for (final s in _sekmeler)
                    NavigationDestination(
                      icon: Icon(s.simge),
                      selectedIcon:
                          Icon(s.seciliSimge, color: AppColors.primary),
                      label: s.etiket,
                    ),
                ],
              ),
      ),
    );
  }
}
