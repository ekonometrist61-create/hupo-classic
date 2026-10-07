// Karakter Koleksiyonu ekranı — 8 sınıf × 5 karakter
//
// Brawl Stars tarzı: kilitli karakterler gölge/silhouette olarak gösterilir.
// Sınıflar yatay sekme veya dikey bölüm olarak listelenir.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/character_models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/character/character_card_widget.dart';
import '../widgets/character/character_detail_sheet.dart';
import '../widgets/ui/responsive_page.dart';

class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key, this.embedded = false});

  /// Alt sekme olarak gömülüyse geri düğmesi gösterilmez.
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncKarakterler = ref.watch(myCharactersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        title: Text(
          'Karakterlerim',
          style: appText(size: 20, weight: FontWeight.w800),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: asyncKarakterler.when(
        data: (karakterler) => _KoleksiyonListesi(karakterler: karakterler),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Karakterler yüklenemedi, birazdan tekrar dene!',
            textAlign: TextAlign.center,
            style: appText(size: 15, color: AppColors.muted),
          ),
        ),
      ),
    );
  }
}

// ── Koleksiyon listesi ───────────────────────────────────────────────────────

class _KoleksiyonListesi extends StatelessWidget {
  const _KoleksiyonListesi({required this.karakterler});

  final List<CharacterCard> karakterler;

  @override
  Widget build(BuildContext context) {
    final gruplar = KarakterSinifGrubu.grupla(karakterler);
    final toplamKazanilan = karakterler.where((k) => k.kazanildi).length;

    return ResponsivePage(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 20),
              child: _IlerlemeOzeti(
                kazanilan: toplamKazanilan,
                toplam: karakterler.length,
              ),
            ),
          ),
          for (final grup in gruplar)
            SliverToBoxAdapter(
              child: _SinifBolumu(grup: grup),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ── Üst ilerleme özeti ───────────────────────────────────────────────────────

class _IlerlemeOzeti extends StatelessWidget {
  const _IlerlemeOzeti({required this.kazanilan, required this.toplam});

  final int kazanilan;
  final int toplam;

  @override
  Widget build(BuildContext context) {
    final oran = toplam == 0 ? 0.0 : kazanilan / toplam;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$kazanilan / $toplam karakter',
                  style: appText(size: 18, weight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: oran,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  kazanilan == toplam
                      ? 'Tüm karakterleri topladın! Efsanesin! 🎉'
                      : '${toplam - kazanilan} karakter seni bekliyor',
                  style: appText(size: 12, color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sınıf bölümü ─────────────────────────────────────────────────────────────

class _SinifBolumu extends StatelessWidget {
  const _SinifBolumu({required this.grup});

  final KarakterSinifGrubu grup;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SinifBaslik(grup: grup),
          const SizedBox(height: 12),
          _KarakterIzgara(karakterler: grup.karakterler),
        ],
      ),
    );
  }
}

class _SinifBaslik extends StatelessWidget {
  const _SinifBaslik({required this.grup});

  final KarakterSinifGrubu grup;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: grup.sinif.renk,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          grup.sinif.ad,
          style: appText(weight: FontWeight.w800),
        ),
        const Spacer(),
        Text(
          '${grup.kazanilanSayi}/${grup.karakterler.length}',
          style: appText(size: 13, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _KarakterIzgara extends StatelessWidget {
  const _KarakterIzgara({required this.karakterler});

  final List<CharacterCard> karakterler;

  @override
  Widget build(BuildContext context) {
    // Beş kart var; yazı boyutu büyüse de satır içeriğine göre uzasın diye ListView yerine Row.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < karakterler.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            CharacterCardWidget(
              karakter: karakterler[i],
              onTap: () => _karakterDetayi(context, karakterler[i]),
            ),
          ],
        ],
      ),
    );
  }

  void _karakterDetayi(BuildContext context, CharacterCard karakter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CharacterDetailSheet(karakter: karakter),
    );
  }
}
