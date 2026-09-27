// Türkçe biçim yardımcıları: tarih GG.AA.YYYY, para birimi ₺.

/// 2026-09-12 → "12.09.2026"
String formatDate(DateTime d) {
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  return '$dd.$mm.${d.year}';
}

/// 1234.5 → "₺1.234,50"  (binlik ayırıcı nokta, ondalık ayırıcı virgül)
String formatTry(num amount) {
  final negative = amount < 0;
  final fixed = amount.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '${negative ? '-' : ''}₺$whole,${parts[1]}';
}

/// "Üyelik süresi" cümlesi: 0 gün → "Bugün aramıza katıldın!", sonra gün/ay/yıl.
String membershipLabel(DateTime joined, DateTime now) {
  final days = DateTime(now.year, now.month, now.day)
      .difference(DateTime(joined.year, joined.month, joined.day))
      .inDays;
  if (days <= 0) return 'Bugün aramıza katıldın!';
  if (days < 30) return '$days gündür aramızdasın';
  if (days < 365) return '${days ~/ 30} aydır aramızdasın';
  return '${days ~/ 365} yıldır aramızdasın';
}

/// Kalan süre: "3 gün 4 saat", "5 saat 20 dk", "12 dk".
String formatRemaining(int seconds) {
  final s = seconds < 0 ? 0 : seconds;
  final days = s ~/ 86400;
  final hours = (s % 86400) ~/ 3600;
  final minutes = (s % 3600) ~/ 60;
  if (days > 0) return '$days gün $hours saat';
  if (hours > 0) return '$hours saat $minutes dk';
  return '${minutes < 1 ? 1 : minutes} dk';
}

/// Bildirim zamanı: "Az önce", "5 dk önce", "3 sa önce", "Dün", sonra GG.AA.YYYY.
String relativeTime(DateTime time, DateTime now) {
  final diff = now.difference(time);
  if (diff.inMinutes < 1) return 'Az önce';
  if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
  if (diff.inHours < 24) return '${diff.inHours} sa önce';
  final days = DateTime(now.year, now.month, now.day)
      .difference(DateTime(time.year, time.month, time.day))
      .inDays;
  if (days == 1) return 'Dün';
  return formatDate(time);
}
