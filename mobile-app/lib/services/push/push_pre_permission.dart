import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/hupo/hupo.dart';

/// Cihazın resmi izin penceresinden ÖNCE gösterilen Hupo ön izin ekranı.
///
/// Neden: Sistem izin penceresi çoğu cihazda bir kez çıkar; önce değeri anlatmak, o tek şansı
/// bilinçli bir seçime çevirir. Kurallar:
///  * "Evet" ve "Şimdilik değil" eşit ağırlıktadır; ikisi de geçerli bir seçimdir.
///  * Yalnızca uygulama hizmeti bildirimlerinden söz eder. Çocuklara reklam ya da indirim bildirimi
///    gönderilmez (öğrenci hesapları pazarlama kanalının dışındadır); bu ekranda pazarlama dili yoktur.
///  * Aciliyet, suçlama ya da "kaçırırsın" dili kullanılmaz.
///  * "Şimdilik değil" sistem penceresini açmaz. Ayarlar'daki anahtar her zaman erişilebilir kalır.
///
/// Dönüş: kullanıcı "Evet"e bastıysa true. Sistem izni bundan sonra ayrıca istenir.
Future<bool> showPushPrePermission(BuildContext context) async {
  final sonuc = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Hupo(pose: HupoPose.merakEdiyor, size: 96),
          const SizedBox(height: 16),
          Text(
            'Hupo sana haber versin mi?',
            textAlign: TextAlign.center,
            style: appText(size: 20, weight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            'Yeni rozetlerin, seviye atlamaların ve günlük hedefin olduğunda telefondan sana haber verebilirim. '
            "İstediğin zaman Ayarlar'dan kapatabilirsin. "
            'Sana reklam ya da indirim bildirimi göndermem. '
            'Akşam 20:00 ile sabah 08:00 arasında bildirim göndermem.',
            textAlign: TextAlign.center,
            style: appText(
                size: 14, weight: FontWeight.w700, color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Şimdilik değil'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Evet, haber versin'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  return sonuc == true;
}
