import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'ui/chunky_button.dart';

/// Çocuğun velisine göstereceği hazır mesaj. Çocuk adı, kod veya kişisel veri içermez;
/// baskı ya da suçluluk dili kullanılmaz.
const String kVeliMesaji =
    "Merhaba, Hupolingo'da bugünkü ücretsiz sorularımı tamamladım. "
    "Yarın yeni sorularla devam edebilirim. Premium'u veli panelinden açabilir misin?";

// Çocuk uygulamasında satın alma bağlantısı YOKTUR (Apple 3.1.1 / Google Play ödeme politikası).
// Bu sayfa yalnızca mesajı kopyalatır; velinin ödeme/üyelik adımını kendi cihazında yapması beklenir.
const String _baslik = 'Velin için mesaj';
const String _aciklama =
    'Bu mesajı kopyalayıp velinle paylaşabilirsin. Ücretli sürüm kararı velinin.';
const String _kopyalaEtiketi = 'Mesajı kopyala';
const String _kapatEtiketi = 'Kapat';
const String _kopyalandi = 'Mesaj kopyalandı. Velinle paylaşabilirsin.';
const String _kopyalanamadi = 'Mesaj kopyalanamadı. Metni elle seçip kopyalayabilirsin.';

/// Veliye gösterilecek mesaj ve veli panelinin bağlantısını içeren alt sayfa.
Future<void> showVeliMesajiSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _VeliMesajiSheet(),
  );
}

class _VeliMesajiSheet extends StatefulWidget {
  const _VeliMesajiSheet();

  @override
  State<_VeliMesajiSheet> createState() => _VeliMesajiSheetState();
}

class _VeliMesajiSheetState extends State<_VeliMesajiSheet> {
  // Alt sayfa, ScaffoldMessenger snackbar'ını örtebildiği için geri bildirim sayfanın içinde.
  String? _geriBildirim;

  Future<void> _kopyala() async {
    try {
      await Clipboard.setData(const ClipboardData(text: kVeliMesaji));
      if (mounted) setState(() => _geriBildirim = _kopyalandi);
    } catch (_) {
      if (mounted) setState(() => _geriBildirim = _kopyalanamadi);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_baslik, style: appText(size: 20, weight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(
              _aciklama,
              style: appText(size: 14, weight: FontWeight.w700, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: SelectableText(
                kVeliMesaji,
                style: appText(weight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 16),
            ChunkyButton(
              label: _kopyalaEtiketi,
              icon: Icons.copy_rounded,
              onPressed: _kopyala,
              height: 52,
            ),
            if (_geriBildirim != null) ...[
              const SizedBox(height: 10),
              Semantics(
                liveRegion: true,
                child: Text(
                  _geriBildirim!,
                  textAlign: TextAlign.center,
                  style: appText(size: 14, weight: FontWeight.w800, color: AppColors.mintDark),
                ),
              ),
            ],
            const SizedBox(height: 10),
            ChunkyButton.light(
              label: _kapatEtiketi,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
