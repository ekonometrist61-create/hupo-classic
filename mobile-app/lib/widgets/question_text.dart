import 'package:flutter/material.dart';

/// Soru metnini gösterir; `**kalın**` işaretli kısımları kalın yazar
/// ("altı koyu yazılı sözcük" gibi sorularda vurgu kaybolmasın).
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
                      decorationThickness: 2,
                    )
                  : null,
            ),
        ],
      ),
      textAlign: textAlign,
    );
  }
}
