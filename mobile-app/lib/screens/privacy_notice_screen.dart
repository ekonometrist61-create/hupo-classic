import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/privacy_notice.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/ui/chunky_button.dart';
import '../widgets/ui/game_card.dart';
import '../widgets/ui/hero_header.dart';
import '../widgets/hupo/hupo.dart';

/// Çocuklara sade dille gizlilik bildirimi.
///
/// [firstRun] true ise ilk girişte gösterilir: "Anladım" ile okunduğu kaydedilir.
/// false ise Ayarlar'dan yalnızca okunur.
class PrivacyNoticeScreen extends ConsumerStatefulWidget {
  const PrivacyNoticeScreen({super.key, this.firstRun = false, this.onAccepted});

  final bool firstRun;
  final VoidCallback? onAccepted;

  @override
  ConsumerState<PrivacyNoticeScreen> createState() => _PrivacyNoticeScreenState();
}

class _PrivacyNoticeScreenState extends ConsumerState<PrivacyNoticeScreen> {
  bool _busy = false;

  Future<void> _accept() async {
    if (!widget.firstRun) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(quizRepositoryProvider).recordNoticeRead(kPrivacyNoticeVersion);
      widget.onAccepted?.call();
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kaydedilemedi, bir kez daha dener misin?')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HeroHeader(
            padding: const EdgeInsets.fromLTRB(12, 4, 20, 20),
            child: Column(
              children: [
                if (!widget.firstRun)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: 'Geri',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                const Hupo(pose: HupoPose.dost, size: 110),
                const SizedBox(height: 4),
                Text(
                  'Bilgilerin nasıl korunuyor?',
                  textAlign: TextAlign.center,
                  style: appText(size: 24, weight: FontWeight.w900, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              children: [
                for (final section in kPrivacySections)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GameCard(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(section.title, style: appText(size: 16, weight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Text(
                              section.body,
                              style: appText(
                                size: 14,
                                weight: FontWeight.w700,
                                color: AppColors.muted,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: ChunkyButton(
                label: widget.firstRun ? 'Anladım' : 'Tamam',
                loading: _busy,
                onPressed: _accept,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
