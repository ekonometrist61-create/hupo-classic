import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/auth/login.dart';

void main() {
  testWidgets('giriş ekranında parola sıfırlama bağlantısı var', (tester) async {
    // Hupo maskotu sürekli animasyon içerdiği için pumpAndSettle kullanılmaz.
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pump();

    expect(find.text('Parolanı mı unuttun?'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Parolanı mı unuttun?'), findsOneWidget);
  });
}
