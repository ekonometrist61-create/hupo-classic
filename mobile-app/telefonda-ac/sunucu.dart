// Kucuk statik web sunucusu (yalnizca Dart SDK gerekir). build/web klasorunu 8080'de yayinlar.
import 'dart:io';

const mimes = {
  'html': 'text/html; charset=utf-8', 'js': 'application/javascript', 'mjs': 'application/javascript',
  'css': 'text/css', 'json': 'application/json', 'png': 'image/png', 'jpg': 'image/jpeg',
  'svg': 'image/svg+xml', 'ico': 'image/x-icon', 'wasm': 'application/wasm', 'ttf': 'font/ttf',
  'otf': 'font/otf', 'woff2': 'font/woff2', 'txt': 'text/plain', 'webmanifest': 'application/manifest+json',
};

Future<void> main(List<String> args) async {
  final root = Directory(args.isNotEmpty ? args[0] : 'build/web').absolute;
  final port = args.length > 1 ? int.parse(args[1]) : 8080;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  stdout.writeln('Sunucu calisiyor: port $port');
  await for (final req in server) {
    try {
      var p = Uri.decodeComponent(req.uri.path);
      if (p.endsWith('/')) p += 'index.html';
      var f = File('${root.path}${p.replaceAll('..', '')}');
      if (!await f.exists()) f = File('${root.path}/index.html');
      final ext = f.path.split('.').last.toLowerCase();
      req.response.headers.contentType = ContentType.parse(mimes[ext] ?? 'application/octet-stream');
      req.response.headers.set('Cache-Control', 'no-cache');
      await req.response.addStream(f.openRead());
    } catch (_) {
      req.response.statusCode = 500;
    }
    await req.response.close();
  }
}
