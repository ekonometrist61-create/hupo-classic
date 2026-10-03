// Genel Çarpım Tablosu Alıştırması ekranı.
//
// Öğrencinin istediği çarpım tablosunu seçip (1-10 veya Karışık) pratik yapmasını sağlar.

import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/haptics.dart';
import '../../widgets/ui/chunky_button.dart';
import '../../widgets/ui/game_card.dart';
import '../../widgets/ui/responsive_page.dart';

class GenelAlistirmaScreen extends StatefulWidget {
  const GenelAlistirmaScreen({super.key});

  @override
  State<GenelAlistirmaScreen> createState() => _GenelAlistirmaScreenState();
}

class _GenelAlistirmaScreenState extends State<GenelAlistirmaScreen> {
  int? _selectedTable; // null ise Karışık (1-10)
  bool _isPlaying = false;
  int _factorA = 2;
  int _factorB = 3;
  int _score = 0;
  int _questionCount = 0;
  final _answerController = TextEditingController();
  bool? _isLastCorrect;
  final _random = Random();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _generateQuestion() {
    setState(() {
      _factorA = _selectedTable ?? (_random.nextInt(9) + 2);
      _factorB = _random.nextInt(9) + 1;
      _answerController.clear();
      _isLastCorrect = null;
    });
  }

  void _submit() {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;
    final ans = int.tryParse(text);
    if (ans == null) return;

    final correct = ans == (_factorA * _factorB);
    setState(() {
      _questionCount++;
      if (correct) _score++;
      _isLastCorrect = correct;
    });

    if (correct) {
      AppHaptics.success();
    } else {
      AppHaptics.error();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Genel Çarpım Alıştırması',
          style:
              appText(size: 18, weight: FontWeight.w800, color: AppColors.ink),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsivePage(
          child: _isPlaying ? _buildGameView() : _buildSelectionView(),
        ),
      ),
    );
  }

  Widget _buildSelectionView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'İstediğin tabloyu seç, hızlıca pratik yap!',
          textAlign: TextAlign.center,
          style: appText(
              size: 15, weight: FontWeight.w500, color: AppColors.muted),
        ),
        const SizedBox(height: 20),
        GameCard(
          color: _selectedTable == null
              ? AppColors.primarySoft
              : AppColors.surface,
          borderColor:
              _selectedTable == null ? AppColors.primary : AppColors.line,
          onTap: () {
            AppHaptics.selection();
            setState(() => _selectedTable = null);
          },
          child: Row(
            children: [
              const Icon(Icons.shuffle_rounded, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'Karışık (1-10 hepsi)',
                style: appText(
                    size: 16, weight: FontWeight.w800, color: AppColors.ink),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
            ),
            itemCount: 10,
            itemBuilder: (ctx, idx) {
              final num = idx + 1;
              final isSel = _selectedTable == num;
              return InkWell(
                onTap: () {
                  AppHaptics.selection();
                  setState(() => _selectedTable = num);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.primarySoft : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSel ? AppColors.primary : AppColors.line,
                      width: isSel ? 2.5 : 1.5,
                    ),
                  ),
                  child: Text(
                    '$num\'ler',
                    style: appText(
                      size: 16,
                      weight: isSel ? FontWeight.w800 : FontWeight.w600,
                      color: isSel ? AppColors.primaryDark : AppColors.ink,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        ChunkyButton(
          label: 'Alıştırmaya Başla',
          icon: Icons.play_arrow_rounded,
          color: AppColors.mint,
          shadowColor: AppColors.mintDark,
          onPressed: () {
            setState(() {
              _isPlaying = true;
              _score = 0;
              _questionCount = 0;
            });
            _generateQuestion();
          },
        ),
      ],
    );
  }

  Widget _buildGameView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Doğru: $_score / $_questionCount',
              style: appText(
                  size: 15, weight: FontWeight.w800, color: AppColors.mintDark),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => setState(() => _isPlaying = false),
              child: Text(
                'Farklı tablo seç',
                style: appText(
                    size: 14,
                    weight: FontWeight.w700,
                    color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GameCard(
          child: Column(
            children: [
              Text(
                '$_factorA × $_factorB = ?',
                style: appText(
                    size: 36, weight: FontWeight.w800, color: AppColors.ink),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _answerController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: appText(
                    size: 26, weight: FontWeight.w800, color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: 'Cevap',
                  hintStyle: appText(size: 20, color: AppColors.muted),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: AppColors.line, width: 2),
                  ),
                ),
                onSubmitted: (_) {
                  if (_isLastCorrect == null) {
                    _submit();
                  } else {
                    _generateQuestion();
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_isLastCorrect != null)
          GameCard(
            color: _isLastCorrect! ? AppColors.mintSoft : AppColors.coralSoft,
            borderColor: _isLastCorrect! ? AppColors.mint : AppColors.coral,
            child: Row(
              children: [
                Icon(
                  _isLastCorrect!
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: _isLastCorrect!
                      ? AppColors.mintDark
                      : AppColors.coralDark,
                ),
                const SizedBox(width: 8),
                Text(
                  _isLastCorrect!
                      ? 'Harikasın, doğru!'
                      : 'Doğru cevap: ${_factorA * _factorB}',
                  style: appText(
                    size: 16,
                    weight: FontWeight.w800,
                    color: _isLastCorrect!
                        ? AppColors.mintDark
                        : AppColors.coralDark,
                  ),
                ),
              ],
            ),
          ),
        const Spacer(),
        if (_isLastCorrect == null)
          ChunkyButton(
            label: 'Cevapla',
            icon: Icons.check_rounded,
            color: AppColors.primary,
            shadowColor: AppColors.primaryDark,
            onPressed: _submit,
          )
        else
          ChunkyButton(
            label: 'Sonraki Soru',
            icon: Icons.arrow_forward_rounded,
            color: AppColors.mint,
            shadowColor: AppColors.mintDark,
            onPressed: _generateQuestion,
          ),
      ],
    );
  }
}
