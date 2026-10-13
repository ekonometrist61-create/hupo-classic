// Anket ve duyuruların ortak "yayın yüzeyi" (mecra) seçimi.
// Sunucu sözlüğü: 'mobil' | 'web_app' | 'web_sitesi' | 'veli_paneli'.

import 'package:flutter/foundation.dart' show kIsWeb;

/// Uygulamanın çalıştığı mecra: `mobil` (Android/iOS) veya `web_app` (Flutter Web).
String yayinYuzeyi() => kIsWeb ? 'web_app' : 'mobil';
