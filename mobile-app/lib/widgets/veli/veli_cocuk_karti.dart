// Veli ana ekranında bir çocuğun kartı: son 7 günün özeti (süre, soru, tekrar konusu).
// Veri yalnızca sunucu rızası "verildi" iken çizilir; aksi halde sakin bir açıklama
// gösterilir. Kart bilgi amaçlıdır; ayrıntı ve eylem ana düğmededir (veli paneli).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../ui/chunky_button.dart';
import '../ui/game_card.dart';
import 'veli_cocuk_veri.dart';

const String _ozetYukleniyor = 'Özet hazırlanıyor…';
const String _ozetHata = 'Bu çocuğun özeti şu an alınamadı.';
const String _tekrarDene = 'Tekrar dene';
const String _calismaYok = 'Son 7 günde çalışma kaydı yok.';
const String _sureNotu = 'Süre, her soru için en fazla 5 dakika sayılarak hesaplanır.';
const String _onayBekleniyor =
    'Çocuğunuzun çalışma bilgilerini görmek için veli panelinde veri işleme onayı vermeniz gerekiyor.';
const String _onayGeriCekildi =
    'Veri işleme onayını geri çektiniz. Bilgileri yeniden görmek için veli panelinden onay verebilirsiniz.';
const String _onayBilinmiyor =
    'Onay durumu şu an alınamadı. Veli panelinden kontrol edebilirsiniz.';

class VeliCocukKarti extends ConsumerWidget {
  const VeliCocukKarti({super.key, required this.cocuk});

  final VeliCocuk cocuk;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ozet = ref.watch(veliCocukOzetiProvider(cocuk.id));

    return GameCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExcludeSemantics(child: _Avatar(ad: cocuk.gorunenAd)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cocuk.gorunenAd,
                  style: appText(size: 18, weight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ozet.when(
            loading: () => const _Yukleniyor(),
            error: (_, __) => _OzetHata(
              onRetry: () => ref.invalidate(veliCocukOzetiProvider(cocuk.id)),
            ),
            data: (veri) => _OzetIcerik(ozet: veri),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.ad});

  final String ad;

  @override
  Widget build(BuildContext context) {
    final bas = ad.isEmpty ? '?' : ad.substring(0, 1).toUpperCase();
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primarySoft,
        shape: BoxShape.circle,
      ),
      child: Text(
        bas,
        style: appText(size: 18, weight: FontWeight.w900, color: AppColors.primary),
      ),
    );
  }
}

class _Yukleniyor extends StatelessWidget {
  const _Yukleniyor();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        const SizedBox(width: 10),
        Text(
          _ozetYukleniyor,
          style: appText(size: 14, weight: FontWeight.w700, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _OzetHata extends StatelessWidget {
  const _OzetHata({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _ozetHata,
          style: appText(size: 14, weight: FontWeight.w700, color: AppColors.muted),
        ),
        const SizedBox(height: 10),
        ChunkyButton.light(
          label: _tekrarDene,
          expanded: false,
          onPressed: onRetry,
        ),
      ],
    );
  }
}

class _OzetIcerik extends StatelessWidget {
  const _OzetIcerik({required this.ozet});

  final CocukOzeti ozet;

  @override
  Widget build(BuildContext context) {
    if (!ozet.verisiGorunur) return _OnayKutusu(riza: ozet.riza);

    final calisma = ozet.haftaDakika > 0 || ozet.haftaSoru > 0;
    final tekrar = ozet.tekrarKonulari;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _Olcu(deger: '${ozet.haftaDakika.round()} dk', etiket: 'son 7 gün'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Olcu(deger: '${ozet.haftaSoru}', etiket: 'soru çözüldü'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Olcu(deger: '${tekrar.length}', etiket: 'tekrar konusu'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!calisma)
          Text(
            _calismaYok,
            style: appText(size: 14, weight: FontWeight.w700, color: AppColors.muted),
          )
        else if (tekrar.isNotEmpty)
          _TekrarSatiri(konu: tekrar.first),
        const SizedBox(height: 10),
        Text(
          _sureNotu,
          style: appText(size: 12, weight: FontWeight.w700, color: AppColors.muted, height: 1.3),
        ),
        const SizedBox(height: 8),
        // Oyun ilerlemesi ayrı satırda: öğrenme sonucu ile XP karıştırılmaz.
        Text(
          'Oyun ilerlemesi: Seviye ${ozet.seviye} · ${_binlik(ozet.xp)} XP · ${ozet.seriGun} gün seri',
          style: appText(size: 13, weight: FontWeight.w700, color: AppColors.muted, height: 1.3),
        ),
      ],
    );
  }
}

class _Olcu extends StatelessWidget {
  const _Olcu({required this.deger, required this.etiket});

  final String deger;
  final String etiket;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$deger, $etiket',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                deger,
                style: appText(size: 20, weight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              etiket,
              style: appText(size: 12, weight: FontWeight.w700, color: AppColors.muted, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}

class _TekrarSatiri extends StatelessWidget {
  const _TekrarSatiri({required this.konu});

  final String konu;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.replay_rounded, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Önerilen tekrar: $konu',
            style: appText(size: 14, weight: FontWeight.w800, height: 1.35),
          ),
        ),
      ],
    );
  }
}

class _OnayKutusu extends StatelessWidget {
  const _OnayKutusu({required this.riza});

  final VeliRiza riza;

  String get _metin => switch (riza) {
        VeliRiza.yok => _onayBekleniyor,
        VeliRiza.geriCekildi => _onayGeriCekildi,
        _ => _onayBilinmiyor,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _metin,
              style: appText(size: 14, weight: FontWeight.w700, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// 1234 → "1.234" (binlik ayırıcı nokta; format.dart ile aynı kural).
String _binlik(int sayi) => sayi
    .toString()
    .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
