import 'package:flutter/material.dart';

import '../../models/kelime_models.dart';
import '../../theme/app_theme.dart';

/// Oyun türüne göre başlık, hedef cümlesi, renk ve simge. Metinler arayüz dilidir (Türkçe, 2. tekil şahıs).
extension KelimeIliskiTemasi on KelimeIliskiTuru {
  String get baslik => switch (this) {
        KelimeIliskiTuru.esAnlamli => 'Anlam Köprüleri',
        KelimeIliskiTuru.zitAnlamli => 'Zıtlık Vadisi',
        KelimeIliskiTuru.esSesli => 'Aynalar Ormanı',
      };

  String get hedef => switch (this) {
        KelimeIliskiTuru.esAnlamli => 'Aynı anlama sahip kelimeyi bul.',
        KelimeIliskiTuru.zitAnlamli => 'Karşıt anlamlı kelimeyi bul.',
        KelimeIliskiTuru.esSesli => 'Aynı yazılan kelimenin doğru anlamını bul.',
      };

  String get kisaAciklama => switch (this) {
        KelimeIliskiTuru.esAnlamli => 'Eş anlamlı kelimeler',
        KelimeIliskiTuru.zitAnlamli => 'Zıt anlamlı kelimeler',
        KelimeIliskiTuru.esSesli => 'Eş sesli kelimeler',
      };

  Color get renk => switch (this) {
        KelimeIliskiTuru.esAnlamli => AppColors.mint,
        KelimeIliskiTuru.zitAnlamli => AppColors.coral,
        KelimeIliskiTuru.esSesli => AppColors.sky,
      };

  Color get renkYumusak => switch (this) {
        KelimeIliskiTuru.esAnlamli => AppColors.mintSoft,
        KelimeIliskiTuru.zitAnlamli => AppColors.coralSoft,
        KelimeIliskiTuru.esSesli => AppColors.primarySoft,
      };

  Color get renkKoyu => switch (this) {
        KelimeIliskiTuru.esAnlamli => AppColors.mintDark,
        KelimeIliskiTuru.zitAnlamli => AppColors.coralDark,
        KelimeIliskiTuru.esSesli => AppColors.skyDark,
      };

  /// Yumuşak zemin üstündeki metin rengi (kontrast için koyu ton).
  Color get renkMetin => switch (this) {
        KelimeIliskiTuru.esAnlamli => AppColors.mintDark,
        KelimeIliskiTuru.zitAnlamli => AppColors.coralDark,
        KelimeIliskiTuru.esSesli => AppColors.navySoft,
      };

  IconData get simge => switch (this) {
        KelimeIliskiTuru.esAnlamli => Icons.link_rounded,
        KelimeIliskiTuru.zitAnlamli => Icons.swap_horiz_rounded,
        KelimeIliskiTuru.esSesli => Icons.hearing_rounded,
      };
}
