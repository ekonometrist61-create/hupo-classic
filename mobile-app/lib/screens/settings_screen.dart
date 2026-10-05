import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/privacy_models.dart';
import '../providers/app_providers.dart';
import '../services/push/push_settings_card.dart';
import '../settings/app_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/ui/chunky_button.dart';
import '../widgets/ui/game_card.dart';
import '../widgets/ui/hero_header.dart';
import 'privacy_notice_screen.dart';

/// Ayarlar: okunabilirlik/erişilebilirlik, günlük hedef, gizlilik ve veri hakları.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _copyData(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final data = await ref.read(quizRepositoryProvider).exportMyData();
      final text = const JsonEncoder.withIndent('  ').convert(data);
      await Clipboard.setData(ClipboardData(text: text));
      messenger.showSnackBar(const SnackBar(
        content: Text(
            'Bilgilerin panoya kopyalandı. Bir yere yapıştırıp saklayabilirsin.'),
      ));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
            content:
                Text('Bilgilerin alınamadı, biraz sonra tekrar deneyelim.')),
      );
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _DeleteAccountDialog(),
    );
    if (confirmed != true) return;

    try {
      await ref.read(quizRepositoryProvider).deleteMyAccount();
      navigator.popUntil((route) => route.isFirst);
      messenger.showSnackBar(
        const SnackBar(
            content: Text('Hesabın ve bilgilerin silindi. Görüşmek üzere!')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
            content: Text('Hesap silinemedi, biraz sonra tekrar deneyelim.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final goal = ref.watch(dailyGoalProvider).valueOrNull;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          HeroHeader(
            padding: const EdgeInsets.fromLTRB(12, 4, 20, 22),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Geri',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 28),
                ),
                Text(
                  'Ayarlar',
                  style: appText(
                      size: 24, weight: FontWeight.w900, color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Okunabilirlik'),
                GameCard(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Yazı tipi'),
                        const SizedBox(height: 8),
                        _ChoiceRow<AppFont>(
                          values: AppFont.values,
                          selected: settings.font,
                          labelOf: (f) => f.label,
                          onSelected: notifier.setFont,
                        ),
                        const SizedBox(height: 16),
                        const _Label('Yazı boyutu'),
                        const SizedBox(height: 8),
                        _ChoiceRow<TextSizeOption>(
                          values: TextSizeOption.values,
                          selected: settings.textSize,
                          labelOf: (s) => s.label,
                          onSelected: notifier.setTextSize,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const _SectionTitle('Hareket ve titreşim'),
                GameCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Column(
                    children: [
                      _SwitchRow(
                        title: 'Hareketi azalt',
                        subtitle:
                            'Konfeti, sallanma ve hareketli animasyonlar kapanır',
                        value: settings.reduceMotion,
                        onChanged: notifier.setReduceMotion,
                      ),
                      const Divider(height: 1, color: AppColors.line),
                      _SwitchRow(
                        title: 'Titreşim',
                        subtitle: 'Cevap verince ve düğmelere basınca titreşim',
                        value: settings.haptics,
                        onChanged: notifier.setHaptics,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const _SectionTitle('Günlük hedef'),
                GameCard(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Günde kaç soru çözmek istersin?'),
                        const SizedBox(height: 8),
                        _ChoiceRow<int>(
                          values: DailyGoal.options,
                          selected: goal?.goal,
                          labelOf: (g) => '$g soru',
                          onSelected: (g) async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await ref
                                  .read(quizRepositoryProvider)
                                  .setDailyGoal(g);
                              ref.invalidate(dailyGoalProvider);
                            } catch (_) {
                              messenger.showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Hedef değiştirilemedi, tekrar deneyelim.')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const _SectionTitle('Bildirimler'),
                const PushSettingsCard(),
                const SizedBox(height: 20),
                const _SectionTitle('Gizlilik ve bilgilerin'),
                _ActionTile(
                  icon: Icons.privacy_tip_rounded,
                  title: 'Gizlilik bildirimi',
                  subtitle: 'Bilgilerin nasıl korunuyor?',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const PrivacyNoticeScreen()),
                  ),
                ),
                const SizedBox(height: 10),
                _ActionTile(
                  icon: Icons.content_copy_rounded,
                  title: 'Bilgilerimi kopyala',
                  subtitle: 'Bizde tuttuğumuz bilgilerini panoya kopyalar',
                  onTap: () => _copyData(context, ref),
                ),
                const SizedBox(height: 10),
                _ActionTile(
                  icon: Icons.delete_forever_rounded,
                  title: 'Hesabımı sil',
                  subtitle: 'Hesabın ve tüm bilgilerin kalıcı olarak silinir',
                  danger: true,
                  onTap: () => _deleteAccount(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: appText(size: 20, weight: FontWeight.w900)),
      );
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style:
            appText(size: 14, weight: FontWeight.w800, color: AppColors.muted),
      );
}

/// Seçenek düğmeleri (tek seçim).
class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final List<T> values;
  final T? selected;
  final String Function(T) labelOf;
  final void Function(T) onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final v in values)
          Semantics(
            button: true,
            selected: v == selected,
            label: labelOf(v),
            child: GestureDetector(
              onTap: () => onSelected(v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: v == selected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        v == selected ? AppColors.primaryDark : AppColors.line,
                    width: 2,
                  ),
                ),
                child: ExcludeSemantics(
                  child: Text(
                    labelOf(v),
                    style: appText(
                      size: 14,
                      weight: FontWeight.w800,
                      color: v == selected ? Colors.white : AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: appText(weight: FontWeight.w900)),
                  Text(
                    subtitle,
                    style: appText(
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.coralDark : AppColors.primary;
    return GameCard(
      onTap: onTap,
      color: danger ? AppColors.coralSoft : AppColors.surface,
      borderColor: danger ? AppColors.coral : AppColors.line,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: appText(
                        weight: FontWeight.w900,
                        color: danger ? color : AppColors.ink)),
                Text(subtitle,
                    style: appText(
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.muted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}

/// Geri alınamaz işlem: "SİL" yazılmadan onaylanamaz.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _controller = TextEditingController();

  /// Türkçe klavyede İ/ı karışıklığı olmasın diye büyük/küçük harf ve noktalı İ normalize edilir.
  static String _normalize(String s) => s
      .trim()
      .replaceAll('İ', 'I')
      .replaceAll('ı', 'I')
      .replaceAll('i', 'I')
      .toUpperCase();

  bool get _matches => _normalize(_controller.text) == 'SIL';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Hesabını silmek istiyor musun?',
          style: appText(size: 20, weight: FontWeight.w900)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hesabın, çözdüğün sorular, rozetlerin ve tüm ilerlemen kalıcı olarak silinir. '
            'Bu işlem geri alınamaz.',
            style: appText(
                size: 14,
                weight: FontWeight.w700,
                color: AppColors.muted,
                height: 1.4),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration:
                const InputDecoration(labelText: 'Onaylamak için SİL yaz'),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Vazgeç'),
        ),
        SizedBox(
          width: 130,
          child: ChunkyButton.danger(
            label: 'Hesabı sil',
            onPressed: _matches ? () => Navigator.of(context).pop(true) : null,
          ),
        ),
      ],
    );
  }
}
