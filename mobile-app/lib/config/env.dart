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
}
