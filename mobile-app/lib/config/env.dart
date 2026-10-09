/// Supabase bağlantı bilgileri.
///
/// Publishable (anon) key istemciye açık olacak şekilde tasarlanmıştır; veriler
/// RLS kurallarıyla korunur. Secret key ASLA buraya veya uygulamaya konmaz.
///
/// Farklı bir proje için: flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...
class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ccozfrpnvyrnktpffkwo.supabase.co',
  );

  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_Ou2vCWJsewMILZzK1PdCyQ_W9Sp5avP',
  );

  /// Web sitesinin (veli paneli, parola sıfırlama, yasal sayfalar) kök adresi.
  /// Parola sıfırlama ve koşullar bu adreste açılır.
  static const webBaseUrl = String.fromEnvironment(
    'WEB_BASE_URL',
    defaultValue: 'https://hupolingo.com',
  );

  /// Sentry DSN'i. Gizli anahtar değildir ama projeye özeldir; kod içine yazılmaz.
  /// Boşsa çökme raporlama kapalıdır: flutter run --dart-define=SENTRY_DSN=...
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');
}
