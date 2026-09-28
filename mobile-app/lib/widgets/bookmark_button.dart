// Kayıtlı sorular (Bookmark / Favori) butonu.
//
// Öğrencinin soruyu kaydetmesini ve çıkarmasını sağlar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptics.dart';

class BookmarkButton extends ConsumerStatefulWidget {
  const BookmarkButton({
    super.key,
    required this.questionId,
    this.size = 24,
  });

  final String questionId;
  final double size;

  @override
  ConsumerState<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends ConsumerState<BookmarkButton> {
  bool _isLoading = false;

  Future<void> _toggle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    AppHaptics.light();

    try {
      final saved = await ref.read(bookmarksProvider.notifier).toggle(widget.questionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              saved ? 'Kaydedildi.' : 'Kaydettiklerinden çıkarıldı.',
              style: appText(size: 14, color: Colors.white),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: saved ? AppColors.mintDark : AppColors.muted,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Şu an kaydedemedik, biraz sonra tekrar dener misin?',
              style: appText(size: 14, color: Colors.white),
            ),
            backgroundColor: AppColors.coral,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBookmarked = ref.watch(bookmarksProvider).contains(widget.questionId);

    return IconButton(
      iconSize: widget.size,
      onPressed: _isLoading ? null : _toggle,
      icon: _isLoading
          ? SizedBox(
              width: widget.size * 0.7,
              height: widget.size * 0.7,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isBookmarked ? AppColors.sunDark : AppColors.muted,
            ),
      tooltip: isBookmarked ? 'Kaydı kaldır' : 'Kaydet',
    );
  }
}
