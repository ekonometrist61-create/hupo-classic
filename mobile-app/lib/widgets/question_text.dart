import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/soru_vurgu.dart';

/// Soru kökünü akıllı vurgu ile gösterir: kalın (700) + altın alt çizgi.
///
/// Girdi: ham metin + [highlights] ([VurguAraligi], kod noktası ofseti, soru köküne göre;
/// sözleşme `utils/soru_vurgu.dart` içinde). Metin değişmez. Aralıklar geçersizse düz metin
/// gösterilir. Yalnız soru köküne uygulanır; seçenek metni/doğru cevap durumuyla ilgisi yoktur.
///
/// Geçiş uyumu: [highlights] boşsa ve metinde eski `**kalın**` işaretleri varsa onlar vurgulanır
/// (yeni verideki ofset vurgusu bu işaretlerin yerini alacak).
///
/// Çizgi kalınlığı Flutter'da yazı tipinin varsayılan kalınlığının katıdır (2,5 kat: 17-21 px'te
/// yaklaşık 2,5-3 px) ve yazı büyütmeyle ölçeklenir. Flutter'da alt çizgi mesafesi (underline
/// offset) ve skip-ink ayarı yoktur; çizgi motorun varsayılan konumundadır.
class QuestionRichText extends StatelessWidget {
  const QuestionRichText(
    this.metin, {
    super.key,
    this.highlights,
    this.style,
    this.textAlign,
  });

  final String metin;
  final List<VurguAraligi>? highlights;
  final TextStyle? style;
  final TextAlign? textAlign;

  /// Vurgulu parça stili; koyu temada koyu token çiftini kullanır.
  static TextStyle vurguStili(Brightness parlaklik) {
    final koyu = parlaklik == Brightness.dark;
    return TextStyle(
      fontWeight: FontWeight.w700,
      color: koyu ? AppColors.vurguMetinKoyu : AppColors.vurguMetin,
      decoration: TextDecoration.underline,
      decorationColor: koyu ? AppColors.vurguCizgiKoyu : AppColors.vurguCizgi,
      decorationThickness: 2.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final taban = style ?? DefaultTextStyle.of(context).style;
    final vurgu = vurguStili(Theme.of(context).brightness);

    final List<VurguParcasi> parcalar;
    if (highlights != null && highlights!.isNotEmpty) {
      parcalar = vurguParcalari(metin, highlights);
    } else if (metin.contains('**')) {
      final p = metin.split('**');
      parcalar = [
        for (var i = 0; i < p.length; i++) VurguParcasi(p[i], i.isOdd),
      ];
    } else {
      parcalar = [VurguParcasi(metin, false)];
    }

    return Text.rich(
      TextSpan(
        style: taban,
        children: [
          for (final p in parcalar)
            TextSpan(text: p.metin, style: p.vurgulu ? vurgu : null),
        ],
      ),
      textAlign: textAlign,
    );
  }
}

/// Eski ad (mevcut ekranlar bu adı kullanır); [QuestionRichText] ile aynıdır.
typedef SoruMetni = QuestionRichText;
