// Hatalı veya anlaşılmayan soruları bildirme butonu ve alt sayfası.
//
// Öğrencinin soruyu 'yanlis_cevap', 'anlasilmiyor', 'yazim', 'diger' nedenleriyle
// bildirmesini sağlar (public.report_question() RPC'si).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptics.dart';
import 'ui/chunky_button.dart';

class ReportQuestionButton extends StatelessWidget {
  const ReportQuestionButton({
    super.key,
    required this.questionId,
    this.size = 20,
  });

  final String questionId;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: size,
      icon: const Icon(Icons.outlined_flag_rounded, color: AppColors.muted),
      tooltip: 'Soruyu Bildir',
      onPressed: () => showReportQuestionSheet(context, questionId: questionId),
    );
  }
}

Future<void> showReportQuestionSheet(
  BuildContext context, {
  required String questionId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => ReportQuestionSheet(questionId: questionId),
  );
}

class ReportQuestionSheet extends ConsumerStatefulWidget {
  const ReportQuestionSheet({
    super.key,
    required this.questionId,
  });

  final String questionId;

  @override
  ConsumerState<ReportQuestionSheet> createState() =>
      _ReportQuestionSheetState();
}

class _ReportQuestionSheetState extends ConsumerState<ReportQuestionSheet> {
  String _selectedReason = 'yanlis_cevap';
  final _notController = TextEditingController();
  bool _isSubmitting = false;

  final _reasons = const [
    ('yanlis_cevap', 'Doğru cevap yanlış'),
    ('anlasilmiyor', 'Soru anlaşılmıyor'),
    ('yazim', 'Yazım hatası'),
    ('diger', 'Başka'),
  ];

  @override
  void dispose() {
    _notController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    AppHaptics.light();

    try {
      final repo = ref.read(quizRepositoryProvider);
      await repo.reportQuestion(
        questionId: widget.questionId,
        neden: _selectedReason,
        notMetni: _notController.text.trim().isEmpty
            ? null
            : _notController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Teşekkürler, inceleyeceğiz!',
              style: appText(size: 14, color: Colors.white),
            ),
            backgroundColor: AppColors.mintDark,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errText = e.toString();
        final isAlreadyReported =
            errText.contains('23505') || errText.contains('zaten bildirdin');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAlreadyReported
                  ? 'Bu soruyu zaten bildirmiştin, teşekkürler!'
                  : 'Şu an gönderemedik, sorun değil! Biraz sonra tekrar dener misin?',
              style: appText(size: 14, color: Colors.white),
            ),
            backgroundColor:
                isAlreadyReported ? AppColors.sunDark : AppColors.coral,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: AppColors.coral),
              const SizedBox(width: 8),
              Text(
                'Sorun Bildir',
                style: appText(
                    size: 18, weight: FontWeight.w800, color: AppColors.ink),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RadioGroup<String>(
            groupValue: _selectedReason,
            onChanged: (val) {
              if (val != null) setState(() => _selectedReason = val);
            },
            child: Column(
              children: _reasons
                  .map((r) => RadioListTile<String>(
                        value: r.$1,
                        title: Text(r.$2,
                            style: appText(size: 15, weight: FontWeight.w600)),
                        contentPadding: EdgeInsets.zero,
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notController,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Kısa not (isteğe bağlı)',
              hintStyle: appText(size: 14, color: AppColors.muted),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.line),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ChunkyButton(
            label: _isSubmitting ? 'Gönderiliyor...' : 'Gönder',
            icon: Icons.send_rounded,
            color: AppColors.primary,
            shadowColor: AppColors.primaryDark,
            onPressed: _isSubmitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}
