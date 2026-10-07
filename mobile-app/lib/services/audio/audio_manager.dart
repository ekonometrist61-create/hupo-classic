import 'dart:async';
import 'dart:developer' as dev;

import 'package:audioplayers/audioplayers.dart' hide AudioEvent;
import 'package:flutter/foundation.dart';

import 'audio_assets.dart';
import 'audio_event.dart';

/// Merkezi ses yöneticisi.
///
/// * Preload / lazy-load ile düşük gecikme.
/// * Priority sistemi: aynı anda yalnızca en yüksek öncelikli ses çalar.
/// * Debounce: aynı event 300 ms içinde tekrar tetiklenmez.
/// * Fail-safe: asset yüklenemezse veya çalınamazsa sessizce devam eder.
class AudioManager {
  AudioManager._();

  static final AudioManager instance = AudioManager._();

  /// `false` ise hiçbir ses çalmaz (master mute).
  bool enabled = true;

  // ── Player havuzu ────────────────────────────────────────
  final Map<AudioEvent, AudioPlayer> _players = {};

  // ── Debounce ─────────────────────────────────────────────
  final Map<AudioEvent, DateTime> _lastPlayed = {};
  static const _debounceMs = 300;

  // ── Priority / queue ─────────────────────────────────────
  AudioEvent? _currentHighPriority;
  Timer? _priorityClearTimer;

  /// Sık kullanılan sesleri önceden yükler (uygulama açılışında çağrılır).
  Future<void> preload() async {
    for (final event in AudioAssets.preloadEvents) {
      await _ensurePlayer(event);
    }
  }

  /// Tek bir ses olayını tetikler.
  ///
  /// [questionId] verilirse aynı soru için aynı event tekrar çalmaz.
  Future<void> play(
    AudioEvent event, {
    String? questionId,
  }) async {
    if (!enabled) return;

    final path = AudioAssets.pathOf(event);
    if (path == null) return; // henüz ses dosyası yok

    // Debounce: aynı event kısa sürede tekrar çalmasın.
    final now = DateTime.now();
    final last = _lastPlayed[event];
    if (last != null && now.difference(last).inMilliseconds < _debounceMs) {
      return;
    }
    _lastPlayed[event] = now;

    // Priority: yüksek priority'li event aktifken düşük priority'li atlanır.
    if (_currentHighPriority != null &&
        event.priority < _currentHighPriority!.priority) {
      return;
    }

    try {
      final player = await _ensurePlayer(event);
      final volume = AudioAssets.volumeOf(event);
      await player.setVolume(volume);
      await player.stop();
      await player.play(AssetSource(path.replaceFirst('assets/', '')));

      // Yüksek priority olay süresince düşükleri engelle.
      if (event.priority >= 55) {
        _currentHighPriority = event;
        _priorityClearTimer?.cancel();
        _priorityClearTimer = Timer(const Duration(milliseconds: 1500), () {
          _currentHighPriority = null;
        });
      }
    } catch (e) {
      dev.log('AudioManager: $event sesi çalınamadı – $e', name: 'audio');
    }
  }

  /// Correct + XP gibi mikro ses dizileri için: ilk ses çalar, [delay] ms
  /// sonra ikinci ses tetiklenir.
  Future<void> playSequence(
    List<AudioEvent> events, {
    int delayMs = 300,
    String? questionId,
  }) async {
    if (!enabled || events.isEmpty) return;
    for (var i = 0; i < events.length; i++) {
      if (i > 0) {
        await Future<void>.delayed(Duration(milliseconds: delayMs));
      }
      await play(events[i], questionId: questionId);
    }
  }

  /// Karakter açılımında nadirlik bazlı en uygun ses event'ini döner.
  ///
  /// Priority: classUnlocked > epic > rare > generic characterUnlocked.
  /// [nadirlikSira] `CharacterCard.karakterSira` (1-5).
  /// [ilkSinifKarakteri] sınıfın ilk açılan karakteri ise `true`.
  static AudioEvent characterUnlockEvent({
    required int nadirlikSira,
    required bool ilkSinifKarakteri,
  }) {
    if (ilkSinifKarakteri) return AudioEvent.classUnlocked;
    return switch (nadirlikSira) {
      >= 5 => AudioEvent.mythicUnlocked,
      4 => AudioEvent.legendaryUnlocked,
      3 => AudioEvent.epicUnlocked,
      2 => AudioEvent.rareUnlocked,
      _ => AudioEvent.characterUnlocked,
    };
  }

  Future<AudioPlayer> _ensurePlayer(AudioEvent event) async {
    if (_players.containsKey(event)) return _players[event]!;
    final player = AudioPlayer();
    await player.setReleaseMode(ReleaseMode.stop);
    // Hata yakalama: kaynak yüklenemezse player boş kalır, play() yakalar.
    _players[event] = player;
    return player;
  }

  /// Test ve hot-restart temizliği.
  @visibleForTesting
  Future<void> dispose() async {
    _priorityClearTimer?.cancel();
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    _lastPlayed.clear();
    _currentHighPriority = null;
  }
}
