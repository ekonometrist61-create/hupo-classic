// Telefonda onizleme icin kucuk statik web sunucusu.
//
// Yalnizca Dart SDK gerekir (Flutter'in icinden gelir); ek paket yoktur.
// build/web klasorunu yerel agdaki tum IPv4 adreslerinde yayinlar; boylece
// telefon, http://<bilgisayar-ip>:<port> adresiyle uygulamayi acabilir.
//
// Kullanim:
//   dart run telefonda-ac/sunucu.dart build/web 8080
import 'dart:async';
import 'dart:io';

// Dosya uzantisi -> MIME turu. Flutter web ciktisi icin gerekenler.
const Map<String, String> mimeTurleri = {
  'html': 'text/html; charset=utf-8',
  'js': 'application/javascript; charset=utf-8',
  'mjs': 'application/javascript; charset=utf-8',
  'css': 'text/css; charset=utf-8',
  'json': 'application/json; charset=utf-8',
  'map': 'application/json; charset=utf-8',
  'png': 'image/png',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'gif': 'image/gif',
  'svg': 'image/svg+xml',
  'ico': 'image/x-icon',
  'wasm': 'application/wasm',
  'ttf': 'font/ttf',
  'otf': 'font/otf',
  'woff': 'font/woff',
  'woff2': 'font/woff2',
  'txt': 'text/plain; charset=utf-8',
  'webmanifest': 'application/manifest+json',
  'bin': 'application/octet-stream',
};

Future<void> main(List<String> args) async {
  final kok = Directory(args.isNotEmpty ? args[0] : 'build/web').absolute;
  final port = args.length > 1 ? int.parse(args[1]) : 8080;

  if (!kok.existsSync()) {
    stderr.writeln('HATA: "${kok.path}" klasoru yok. '
        'Once "flutter build web --release" calistirin.');
    exitCode = 1;
    return;
  }

  final HttpServer sunucu;
  try {
    sunucu = await HttpServer.bind(InternetAddress.anyIPv4, port);
  } catch (e) {
    stderr.writeln('HATA: $port portu dinlenemedi ($e). '
        'Baska bir uygulama bu portu kullaniyor olabilir.');
    exitCode = 1;
    return;
  }
  // Telefonda daha hizli acilsin diye yanitlar sikistirilir.
  sunucu.autoCompress = true;

  stdout.writeln('');
  stdout.writeln('  ------------------------------------------------------------');
  stdout.writeln('   Sunucu calisiyor. Telefonun tarayicisina su adresi yazin:');
  stdout.writeln('');
  for (final ip in await yerelIPv4Adresleri()) {
    stdout.writeln('        http://$ip:$port');
  }
  stdout.writeln('');
  stdout.writeln('   * Telefon bu bilgisayarla AYNI Wi-Fi agina bagli olmali.');
  stdout.writeln('   * Durdurmak icin: Ctrl + C');
  stdout.writeln('  ------------------------------------------------------------');
  stdout.writeln('');

  await for (final istek in sunucu) {
    // Isleri es zamanli yap: buyuk dosya inerken digerleri beklemez.
    unawaited(_istegiYanitla(istek, kok));
  }
}

// Tek bir istegi yanitlar; beklenmeyen hata olsa bile sunucu ayakta kalir.
Future<void> _istegiYanitla(HttpRequest istek, Directory kok) async {
  try {
    var yol = Uri.decodeComponent(istek.uri.path);
    if (yol.isEmpty || yol.endsWith('/')) yol += 'index.html';

    // ".." segmentlerini atarak kok disina cikmayi engelle.
    final parcalar = yol
        .split('/')
        .where((parca) => parca.isNotEmpty && parca != '.' && parca != '..');
    var dosya = File('${kok.path}/${parcalar.join('/')}');

    // Tek sayfa uygulamasi: bilinmeyen adreste ana sayfayi dondur.
    if (!await dosya.exists()) {
      dosya = File('${kok.path}/index.html');
    }

    final uzanti = dosya.path.split('.').last.toLowerCase();
    istek.response.headers.contentType =
        ContentType.parse(mimeTurleri[uzanti] ?? 'application/octet-stream');
    // Onizlemede telefon her zaman en guncel surumu gorsun.
    istek.response.headers
        .set('Cache-Control', 'no-cache, no-store, must-revalidate');
    istek.response.headers.contentLength = await dosya.length();
    await istek.response.addStream(dosya.openRead());
    await istek.response.close();
  } catch (e) {
    // Beklenmeyen durum: 500 don ve baglantiyi kapat.
    await _guvenliKapat(istek.response, e);
  }
}

// Yaniti 500 ile kapatmayi dener; baglanti kapanmissa durum loglanir.
Future<void> _guvenliKapat(HttpResponse yanit, Object hata) async {
  try {
    yanit.statusCode = HttpStatus.internalServerError;
    await yanit.close();
  } catch (e) {
    stderr.writeln('UYARI: Istek yanitlanamadi ($hata); '
        'baglanti zaten kapali olabilir ($e).');
  }
}

// Yerel agda kullanilabilir IPv4 adreslerini dondurur (192.168.* once).
Future<List<String>> yerelIPv4Adresleri() async {
  final adresler = <String>[];
  try {
    final arayuzler =
        await NetworkInterface.list(type: InternetAddressType.IPv4);
    for (final arayuz in arayuzler) {
      for (final adres in arayuz.addresses) {
        adresler.add(adres.address);
      }
    }
  } catch (e) {
    // Adres listesi alinamazsa yalnizca uyari verilir; yayin yine baslar.
    stderr.writeln('UYARI: Yerel ag adresleri okunamadi ($e).');
  }
  adresler.sort((a, b) {
    final oncelikA = a.startsWith('192.168.') ? 0 : 1;
    final oncelikB = b.startsWith('192.168.') ? 0 : 1;
    if (oncelikA != oncelikB) return oncelikA - oncelikB;
    return a.compareTo(b);
  });
  return adresler;
}
