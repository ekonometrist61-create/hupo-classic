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
/// Vurgulu parça, metnin hemen altında kalın bir kenarlıkla çizilir: Flutter'ın varsayılan alt
/// çizgisi konumu ve kalınlığı ayarlanamadığı için çizgi kendi widget'ımızda çizilir
/// ([_cizgiKalinlik] px, metnin [_cizgiBoslugu] px altında).
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

  static const double _cizgiKalinlik = 5;
  static const double _cizgiBoslugu = 2;

  /// Vurgulu parça stili; koyu temada koyu token çiftini kullanır.
  static TextStyle vurguStili(Brightness parlaklik) {
    final koyu = parlaklik == Brightness.dark;
    return TextStyle(
      fontWeight: FontWeight.w700,
      color: koyu ? AppColors.vurguMetinKoyu : AppColors.vurguMetin,
    );
  }

  /// Vurgu alt çizgisinin rengi; koyu temada koyu token çiftini kullanır.
  static Color vurguCizgiRengi(Brightness parlaklik) =>
      parlaklik == Brightness.dark ? AppColors.vurguCizgiKoyu : AppColors.vurguCizgi;

  @override
  Widget build(BuildContext context) {
    final taban = style ?? DefaultTextStyle.of(context).style;
    final parlaklik = Theme.of(context).brightness;
    final vurgu = taban.merge(vurguStili(parlaklik));
    final cizgi = vurguCizgiRengi(parlaklik);

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
            if (p.vurgulu)
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: cizgi, width: _cizgiKalinlik),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: _cizgiBoslugu),
                    child: Text(p.metin, style: vurgu),
                  ),
                ),
              )
            else
              TextSpan(text: p.metin),
        ],
      ),
      textAlign: textAlign,
    );
  }
}

/// Eski ad (mevcut ekranlar bu adı kullanır); [QuestionRichText] ile aynıdır.
typedef SoruMetni = QuestionRichText;
