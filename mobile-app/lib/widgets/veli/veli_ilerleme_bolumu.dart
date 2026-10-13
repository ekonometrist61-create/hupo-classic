// Veli ana ekranının çocuk bölümü: ana eylem (veli panelini aç), çocuk kartları ve
// her durum için anlaşılır metin (yükleniyor, çocuk yok, hata, veri).
//
// Ayrıntılar (konu ilerlemesi, rapor, deneme, abonelik) veli panelindedir (web).
// Burada ödeme/satın alma çağrısı, sahte kanıt veya puan garantisi yoktur.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/web_links.dart';
import '../../theme/app_theme.dart';
import '../hupo/hupo_loading.dart';
import '../ui/chunky_button.dart';
import '../ui/game_card.dart';
import 'veli_cocuk_karti.dart';
import 'veli_cocuk_veri.dart';

/// Veli panelinin kök yolu. Web'de locale öneki yok (localePrefix: "never").
const String kVeliPanelYolu = '/veli-paneli';

const String _bolumBasligi = 'Çocuklarınız';
const String _ctaCocuk = 'Çocuğumun ilerlemesi';
const String _ctaPanel = 'Veli panelini aç';
const String _ctaAciklama =
    'Konu bazında ilerleme, tekrar önerileri ve çalışma geçmişi veli panelinde.';
const String _cocukYukleniyor = 'Çocuklarınız yükleniyor…';
const String _cocukHata = 'Çocuk bilgileri şu an yüklenemedi.';
const String _tekrarDene = 'Tekrar dene';
const String _panelAcilamadi = 'Veli paneli açılamadı. Birazdan tekrar deneyin.';
const String _baglantiBaslik = 'Henüz bağlı çocuk yok';
const String _baglantiMetni =
    'Çocuğunuzu eklemek için veli panelinde “Çocuğunu ekle” bölümünden bir kod oluşturun. '
    'Çocuğunuz kodu Hupolingo uygulamasında Ayarlar → Veline bağlan bölümüne yazar. '
    'Kod 24 saat geçerli ve tek kullanımlıktır.';

/// Veli panelini dış tarayıcıda açar. Açılamazsa kısa bir uyarı gösterir.
Future<void> veliPaneliniAc(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final acildi = await openWebPage(kVeliPanelYolu);
  if (!acildi) {
    messenger.showSnackBar(const SnackBar(content: Text(_panelAcilamadi)));
  }
}

class VeliIlerlemeBolumu extends ConsumerWidget {
  const VeliIlerlemeBolumu({super.key, required this.onPanelAc});

  /// Ana eylemin davranışı. Üretimde [veliPaneliniAc]; testte taklit edilir.
  final VoidCallback onPanelAc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cocuklar = ref.watch(veliCocuklarProvider);
    // Çocuk listesi kesin olarak boşsa ana eylem, kod oluşturma adımına yönlendirir.
    final cocukYok = cocuklar.valueOrNull?.isEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_bolumBasligi, style: appText(size: 21, weight: FontWeight.w900)),
        const SizedBox(height: 12),
        ChunkyButton(
          label: cocukYok ? _ctaPanel : _ctaCocuk,
          icon: Icons.insights_rounded,
          onPressed: onPanelAc,
        ),
        const SizedBox(height: 8),
        Text(
          _ctaAciklama,
          style: appText(size: 14, weight: FontWeight.w700, color: AppColors.muted, height: 1.35),
        ),
        const SizedBox(height: 16),
        cocuklar.when(
          loading: () => const HupoLoading(message: _cocukYukleniyor, compact: true),
          error: (_, __) => _HataKarti(
            onRetry: () => ref.invalidate(veliCocuklarProvider),
          ),
          data: (liste) => liste.isEmpty
              ? const _BaglantiKarti()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final cocuk in liste) ...[
                      VeliCocukKarti(key: ValueKey(cocuk.id), cocuk: cocuk),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

/// Çocuk listesi yüklenemediğinde sakin bir uyarı ve yeniden deneme. Sayfanın geri kalanı çalışır.
class _HataKarti extends StatelessWidget {
  const _HataKarti({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GameCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _cocukHata,
            style: appText(size: 15, weight: FontWeight.w700, color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          ChunkyButton.light(
            label: _tekrarDene,
            expanded: false,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

/// Bağlı çocuk yokken: çocuğun eklenmesi için panelde izlenecek adım.
class _BaglantiKarti extends StatelessWidget {
  const _BaglantiKarti();

  @override
  Widget build(BuildContext context) {
    return GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.family_restroom_rounded, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _baglantiBaslik,
                  style: appText(size: 17, weight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _baglantiMetni,
            style: appText(size: 14, weight: FontWeight.w700, color: AppColors.muted, height: 1.4),
          ),
        ],
      ),
    );
  }
}
