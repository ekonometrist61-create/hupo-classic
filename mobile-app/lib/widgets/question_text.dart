import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Soru metnini gösterir; `**kalın**` işaretli kısımları kalın ve altı çizili yazar
/// ("altı koyu yazılı sözcük" gibi sorularda vurgu kaybolmasın). Altı çizgi, web'deki
/// örnek soru ile aynı amber tondadır (AppColors.sunDark).
class SoruMetni extends StatelessWidget {
  const SoruMetni(this.metin, {super.key, this.style, this.textAlign});

  final String metin;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final taban = style ?? DefaultTextStyle.of(context).style;
    final parcalar = metin.split('**');
    return Text.rich(
      TextSpan(
        style: taban,
        children: [
          for (var i = 0; i < parcalar.length; i++)
            TextSpan(
              text: parcalar[i],
              style: i.isOdd
                  ? const TextStyle(
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.sunDark,
                      decorationThickness: 2.5,
                    )
                  : null,
            ),
        ],
      ),
      textAlign: textAlign,
    );
  }
}
