// Duyuru şeridi: ana ekranın üstünde, kapatılabilir kart.
// Öğrenci ve veli hesabında aynı şekilde görünür. Duyuru yoksa, yükleniyorsa
// veya hata olduysa hiçbir şey çizmez.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/duyuru_models.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';

// Web sitesi şeridiyle uyumlu renkler. Tema'da karşılığı yok; tema token'ı
// eklenene kadar yalnızca bu widget'a yereldir.
const Color _duyuruYesil = Color(0xFF027A48); // zemin, beyaz metin ≈ 5.4:1
const Color _duyuruAltin = Color(0xFFF5C842); // etiket zemini

const String _etiket = 'Duyuru';
const String _kapatEtiketi = 'Duyuruyu kapat';

class DuyuruSeridi extends ConsumerStatefulWidget {
  const DuyuruSeridi({super.key});

  @override
  ConsumerState<DuyuruSeridi> createState() => _DuyuruSeridiState();
}

class _DuyuruSeridiState extends ConsumerState<DuyuruSeridi> {
  /// Kapatılan duyurunun kimliği. Yeniden çekim bitene kadar şeridi hemen gizler.
  String? _kapaliId;

  Future<void> _kapat(Duyuru duyuru) async {
    setState(() => _kapaliId = duyuru.id);
    await ref.read(duyuruKapatmaProvider).kapat(duyuru);
    if (mounted) ref.invalidate(aktifDuyuruProvider);
  }

  @override
  Widget build(BuildContext context) {
    final duyuru = ref.watch(aktifDuyuruProvider).valueOrNull;
    if (duyuru == null || duyuru.id == _kapaliId) return const SizedBox.shrink();
    return _DuyuruKutu(duyuru: duyuru, onKapat: () => _kapat(duyuru));
  }
}

class _DuyuruKutu extends StatelessWidget {
  const _DuyuruKutu({required this.duyuru, required this.onKapat});

  final Duyuru duyuru;
  final VoidCallback onKapat;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$_etiket: ${duyuru.baslik}',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 14),
        decoration: BoxDecoration(
          color: _duyuruYesil,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _duyuruAltin,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _etiket,
                  // Varsayılan renk AppColors.ink (#17324D, lacivert): altın zeminde ≈ 8.3:1.
                  style: appText(size: 12, weight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    duyuru.baslik,
                    style: appText(
                      weight: FontWeight.w900,
                      color: AppColors.surface,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    duyuru.metin,
                    style: appText(
                      size: 14,
                      color: AppColors.surface,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              button: true,
              label: _kapatEtiketi,
              child: InkWell(
                onTap: onKapat,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.close_rounded, color: AppColors.surface, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
