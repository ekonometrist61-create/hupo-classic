import 'package:flutter/widgets.dart';

/// Hareketi azalt: işletim sisteminin "animasyonları kaldır" ayarı VEYA uygulamadaki
/// "Hareketi azalt" anahtarı açıksa true (ikisi de MediaQuery.disableAnimations'a yansıtılır).
bool reducedMotion(BuildContext context) => MediaQuery.disableAnimationsOf(context);

/// Hareket azaltılmışsa süre 0, aksi halde verilen milisaniye.
Duration motionMs(BuildContext context, int milliseconds) =>
    reducedMotion(context) ? Duration.zero : Duration(milliseconds: milliseconds);
