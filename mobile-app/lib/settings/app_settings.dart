import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/audio/audio_manager.dart';
import '../utils/haptics.dart';

/// Uygulama yazı tipi seçenekleri.
enum AppFont {
  /// Varsayılan: yuvarlak hatlı, çocuk dostu.
  nunito('Nunito', 'Varsayılan'),

  /// Harf aralığı geniş, okumayı kolaylaştırmak için tasarlanmış yazı tipi.
  lexend('Lexend', 'Okumayı kolaylaştıran');

  const AppFont(this.family, this.label);

  final String family;
  final String label;
}

/// Yazı boyutu seçenekleri (işletim sistemi ayarına ek olarak çarpılır).
enum TextSizeOption {
  normal(1.0, 'Normal'),
  large(1.15, 'Büyük'),
  xlarge(1.3, 'Çok büyük');

  const TextSizeOption(this.scale, this.label);

  final double scale;
  final String label;
}

class AppSettings {
  const AppSettings({
    this.reduceMotion = false,
    this.haptics = true,
    this.soundEffects = true,
    this.font = AppFont.nunito,
    this.textSize = TextSizeOption.normal,
  });

  /// true: konfeti, sallanma, süzülme ve hareketli animasyonlar kapanır.
  final bool reduceMotion;
  final bool haptics;
  final bool soundEffects;
  final AppFont font;
  final TextSizeOption textSize;

  AppSettings copyWith({
    bool? reduceMotion,
    bool? haptics,
    bool? soundEffects,
    AppFont? font,
    TextSizeOption? textSize,
  }) =>
      AppSettings(
        reduceMotion: reduceMotion ?? this.reduceMotion,
        haptics: haptics ?? this.haptics,
        soundEffects: soundEffects ?? this.soundEffects,
        font: font ?? this.font,
        textSize: textSize ?? this.textSize,
      );
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._prefs) : super(_load(_prefs)) {
    AppHaptics.enabled = state.haptics;
    AudioManager.instance.enabled = state.soundEffects;
  }

  final SharedPreferences _prefs;

  static const _kReduceMotion = 'reduce_motion';
  static const _kHaptics = 'haptics';
  static const _kSoundEffects = 'sound_effects';
  static const _kFont = 'font';
  static const _kTextSize = 'text_size';

  static AppSettings _load(SharedPreferences prefs) {
    T byName<T extends Enum>(List<T> values, String? name, T fallback) {
      for (final v in values) {
        if (v.name == name) return v;
      }
      return fallback;
    }

    return AppSettings(
      reduceMotion: prefs.getBool(_kReduceMotion) ?? false,
      haptics: prefs.getBool(_kHaptics) ?? true,
      soundEffects: prefs.getBool(_kSoundEffects) ?? true,
      font: byName(AppFont.values, prefs.getString(_kFont), AppFont.nunito),
      textSize: byName(
        TextSizeOption.values,
        prefs.getString(_kTextSize),
        TextSizeOption.normal,
      ),
    );
  }

  void setReduceMotion(bool value) {
    _prefs.setBool(_kReduceMotion, value);
    state = state.copyWith(reduceMotion: value);
  }

  void setHaptics(bool value) {
    _prefs.setBool(_kHaptics, value);
    AppHaptics.enabled = value;
    state = state.copyWith(haptics: value);
  }

  void setSoundEffects(bool value) {
    _prefs.setBool(_kSoundEffects, value);
    AudioManager.instance.enabled = value;
    state = state.copyWith(soundEffects: value);
  }

  void setFont(AppFont value) {
    _prefs.setString(_kFont, value.name);
    state = state.copyWith(font: value);
  }

  void setTextSize(TextSizeOption value) {
    _prefs.setString(_kTextSize, value.name);
    state = state.copyWith(textSize: value);
  }
}

/// main() içinde gerçek örnekle, testlerde sahte örnekle geçersiz kılınır.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider override edilmeli'),
);

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(ref.watch(sharedPreferencesProvider)),
);
