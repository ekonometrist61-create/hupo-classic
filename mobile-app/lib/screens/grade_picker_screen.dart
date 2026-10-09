// Sınıf seçimi ve değiştirme ekranı.
//
// Öğrencinin sınıfını seçmesini veya veli kuralına göre değiştirmesini sağlar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptics.dart';
import '../widgets/ui/chunky_button.dart';
import '../widgets/ui/responsive_page.dart';

class GradePickerScreen extends ConsumerStatefulWidget {
  const GradePickerScreen({super.key});

  @override
  ConsumerState<GradePickerScreen> createState() => _GradePickerScreenState();
}

class _GradePickerScreenState extends ConsumerState<GradePickerScreen> {
  int? _selectedGrade;
  bool _isSaving = false;

  Future<void> _saveGrade() async {
    if (_selectedGrade == null || _isSaving) return;
    setState(() => _isSaving = true);
    AppHaptics.light();

    try {
      final repo = ref.read(quizRepositoryProvider);
      await repo.setMyGrade(_selectedGrade!);
      ref.invalidate(profileProvider);
      ref.invalidate(subjectsProvider);
      ref.invalidate(statsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$_selectedGrade. Sınıf olarak güncellendi.',
              style: appText(size: 14, color: Colors.white),
            ),
            backgroundColor: AppColors.mintDark,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        final err = e.toString();
        final isLimit = err.contains('22023') ||
            err.contains('30 gün') ||
            err.contains('zaten değiştirdin');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isLimit
                  ? 'Sınıf değiştirme süren doldu, velinden yardım al.'
                  : 'Sınıfın kaydedilemedi, bir kez daha dener misin?',
              style: appText(size: 14, color: Colors.white),
            ),
            backgroundColor: AppColors.coral,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradesAsync = ref.watch(supportedGradesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Sınıfını Seç',
          style:
              appText(size: 18, weight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsivePage(
          child: gradesAsync.when(
            data: (grades) {
              if (grades.isEmpty) {
                return const _EmptyGradesState();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sorularını senin sınıfına göre hazırlayabilmemiz için seç.',
                    textAlign: TextAlign.center,
                    style: appText(
                        size: 15,
                        weight: FontWeight.w500,
                        color: AppColors.muted),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _GradeList(
                      grades: grades,
                      selectedGrade: _selectedGrade,
                      onSelect: (g) => setState(() => _selectedGrade = g),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ChunkyButton(
                    label: _isSaving ? 'Kaydediliyor...' : 'Devam Et',
                    icon: Icons.check_circle_rounded,
                    onPressed:
                        _selectedGrade == null || _isSaving ? null : _saveGrade,
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sınıf listesi yüklenemedi, tekrar deneyelim.',
                    style: appText(size: 14, color: AppColors.coral),
                  ),
                  const SizedBox(height: 12),
                  ChunkyButton(
                    label: 'Tekrar Dene',
                    icon: Icons.refresh_rounded,
                    onPressed: () => ref.invalidate(supportedGradesProvider),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradeList extends StatelessWidget {
  const _GradeList({
    required this.grades,
    required this.selectedGrade,
    required this.onSelect,
  });

  final List<int> grades;
  final int? selectedGrade;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: grades.length,
      itemBuilder: (ctx, idx) {
        final g = grades[idx];
        return _GradePill(
          grade: g,
          isSelected: g == selectedGrade,
          onTap: () => onSelect(g),
        );
      },
    );
  }
}

class _GradePill extends StatelessWidget {
  const _GradePill({
    required this.grade,
    required this.isSelected,
    required this.onTap,
  });

  final int grade;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppHaptics.selection();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.line,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Text(
          '$grade. Sınıf',
          style: appText(
            weight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppColors.primaryDark : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _EmptyGradesState extends StatelessWidget {
  const _EmptyGradesState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school_outlined, size: 64, color: AppColors.muted),
            const SizedBox(height: 16),
            Text(
              'Sınıf seçenekleri yakında burada!',
              textAlign: TextAlign.center,
              style: appText(
                  size: 18, weight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Şimdilik seçecek bir sınıf yok, ama bunu senin için hallediyoruz.',
              textAlign: TextAlign.center,
              style: appText(size: 14, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
