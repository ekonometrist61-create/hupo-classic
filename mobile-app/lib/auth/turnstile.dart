import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Cloudflare Turnstile site anahtari (herkese aciktir, gizli degildir).
/// Derleme: --dart-define=TURNSTILE_SITE_KEY=...  Bos ise captcha istenmez.
const String _siteKey = String.fromEnvironment('TURNSTILE_SITE_KEY');

/// Turnstile'in kayitli alan adi; WebView bu kokenle yuklenir.
const String _kok = 'https://hupolingo.com';

/// Captcha jetonu ister.
/// - '' : site anahtari tanimli degil, captcha gerekmiyor (jeton gonderilmez).
/// - null: kullanici iptal etti.
/// - diger: Turnstile jetonu (tek kullanimlik).
Future<String?> turnstileTokenAl(BuildContext context) async {
  if (_siteKey.isEmpty) return '';
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _TurnstileDialog(),
  );
}

class _TurnstileDialog extends StatefulWidget {
  const _TurnstileDialog();

  @override
  State<_TurnstileDialog> createState() => _TurnstileDialogState();
}

class _TurnstileDialogState extends State<_TurnstileDialog> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'Captcha',
        onMessageReceived: (m) {
          if (!mounted) return;
          final v = m.message;
          if (v == 'hata') {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pop(v);
          }
        },
      )
      ..loadHtmlString(_html(), baseUrl: _kok);
  }

  String _html() => '''
<!doctype html><html><head>
<meta name="viewport" content="width=device-width,initial-scale=1">
<script src="https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit" async defer></script>
<style>body{margin:0;display:flex;align-items:center;justify-content:center;height:100vh;background:transparent}</style>
</head><body><div id="w"></div>
<script>
function basla(){
  if(!window.turnstile){setTimeout(basla,200);return;}
  turnstile.render('#w',{sitekey:'$_siteKey',
    callback:function(t){Captcha.postMessage(t);},
    'error-callback':function(){Captcha.postMessage('hata');}});
}
basla();
</script></body></html>''';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Güvenlik doğrulaması'),
      content: SizedBox(
        width: 300,
        height: 90,
        child: WebViewWidget(controller: _controller),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Vazgeç'),
        ),
      ],
    );
  }
}
