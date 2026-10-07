/// Uygulamada ses tetikleyen tüm domain olayları.
///
/// Her olay tek bir ses dosyasına eşlenir ([AudioAssets]).
/// Priority değeri yükseldikçe olay daha önemlidir; çakışmada
/// yüksek priority kazanır.
enum AudioEvent {
  // ── Öğrenme ──────────────────────────────────────────────
  correct(priority: 30),
  retry(priority: 20),
  xpGain(priority: 40),

  // ── İlerleme ─────────────────────────────────────────────
  streakSuccess(priority: 50),
  badgeUnlocked(priority: 55),
  levelUp(priority: 60),

  // ── Karakter ─────────────────────────────────────────────
  characterUnlocked(priority: 65),
  rareUnlocked(priority: 70),
  epicUnlocked(priority: 75),
  legendaryUnlocked(priority: 80), // TODO: ses dosyası henüz yok
  mythicUnlocked(priority: 85), // TODO: ses dosyası henüz yok

  // ── WOW ──────────────────────────────────────────────────
  classUnlocked(priority: 90),

  // ── Marka ────────────────────────────────────────────────
  brand(priority: 100);

  const AudioEvent({required this.priority});

  final int priority;
}
