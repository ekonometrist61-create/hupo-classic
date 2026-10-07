import 'audio_channel.dart';
import 'audio_event.dart';

class _Entry {
  const _Entry(this.path, this.channel, this.volume);
  final String path;
  final AudioChannel channel;
  final double volume;
}

/// Merkezi ses varlık kaydı — event → dosya yolu, kanal, varsayılan volume.
///
/// Yeni ses eklendiğinde yalnızca burası güncellenir.
/// [path] `null` ise o event için henüz ses dosyası yoktur (sessiz kalır).
abstract final class AudioAssets {
  static const _root = 'assets/audio';

  static const Map<AudioEvent, _Entry> _map = {
    AudioEvent.brand: _Entry('$_root/brand/hupo_marka_sesi.mp3', AudioChannel.wow, 0.80),

    AudioEvent.correct: _Entry('$_root/learning/hupo_dogru_cevap.mp3', AudioChannel.learning, 0.60),
    AudioEvent.retry: _Entry('$_root/learning/hupo_bir_daha_dene.mp3', AudioChannel.learning, 0.55),

    AudioEvent.xpGain: _Entry('$_root/progression/hupo_xp_kazanildi.mp3', AudioChannel.learning, 0.60),
    AudioEvent.streakSuccess: _Entry('$_root/progression/hupo_seri_devam_ediyor.mp3', AudioChannel.reward, 0.75),
    AudioEvent.levelUp: _Entry('$_root/progression/hupo_seviye_atladi.mp3', AudioChannel.reward, 0.80),

    AudioEvent.badgeUnlocked: _Entry('$_root/rewards/hupo_rozet_kazanildi.mp3', AudioChannel.reward, 0.75),
    AudioEvent.characterUnlocked: _Entry('$_root/rewards/hupo_yeni_karakter_acildi.mp3', AudioChannel.reward, 0.85),
    AudioEvent.classUnlocked: _Entry('$_root/rewards/hupo_yeni_sinif_acildi.mp3', AudioChannel.wow, 0.90),

    AudioEvent.rareUnlocked: _Entry('$_root/rarity/hupo_nadir_karakter_acildi.mp3', AudioChannel.reward, 0.85),
    AudioEvent.epicUnlocked: _Entry('$_root/rarity/hupo_epik_karakter_acildi.mp3', AudioChannel.wow, 0.90),

    // Henüz ses dosyası olmayan event'ler haritada yer almaz → sessiz kalır.
    // AudioEvent.legendaryUnlocked
    // AudioEvent.mythicUnlocked
  };

  /// Event'e karşılık gelen asset yolu; yoksa `null`.
  static String? pathOf(AudioEvent event) => _map[event]?.path;

  /// Event'in varsayılan volume'u (0.0 – 1.0).
  static double volumeOf(AudioEvent event) => _map[event]?.volume ?? 0.0;

  /// Event'in mantıksal kanalı.
  static AudioChannel channelOf(AudioEvent event) =>
      _map[event]?.channel ?? AudioChannel.ui;

  /// Uygulama başlangıcında önceden yüklenecek sık kullanılan sesler.
  static const List<AudioEvent> preloadEvents = [
    AudioEvent.correct,
    AudioEvent.retry,
    AudioEvent.xpGain,
  ];
}
