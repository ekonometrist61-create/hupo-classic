// Cevap sonrası Hupo'nun çocuğa dost geri bildirim mesajları.
//
// kurtarilan/missing-turkish.txt içindeki birebir metinler kullanılmıştır.

import 'dart:math';

class AnswerFeedback {
  static final _random = Random();

  /// Doğru cevap verildiğinde gösterilen teşvik metinleri.
  static const List<String> correctMessages = [
    'Harikasın, doğru!',
    'Harikasın!',
    'Doğru! Bunu zaten biliyordun.',
    'Aynen böyle!',
    'Tam isabet!',
  ];

  /// Zor bir soru doğru bilindiğinde gösterilen metinler.
  static const List<String> hardQuestionSuccessMessages = [
    'Bu seviyede doğru bilmek gerçekten iyi!',
    'Bu, diğerlerinden daha zor bir soruydu yine de başardın!',
    'Zor bir soruyu hallettin!',
  ];

  /// Yanlış cevap verildiğinde moral veren ve öğrenmeye odaklayan metinler.
  static const List<String> wrongMessages = [
    'Olmadı, hadi doğrusuna bakalım',
    'Bir daha bakalım',
    'Sorun değil, bunu birlikte öğreniyoruz!',
    'Bu da öğrenmenin bir yolu!',
    'Olsun, öğrenmenin bir parçası bu!',
    'Herkes böyle öğrenir, devam!',
    'Az kaldı, pes etme!',
    'Az kaldı, neredeyse tamam!',
    'Güzel bir denemeydi, biraz daha pratikle çok daha iyi olacaksın!',
  ];

  /// Test veya tur bittiğinde gösterilen özet mesajları.
  static const List<String> roundSummaryMessages = [
    'Bugünlük harikaydın!',
    'Bu turda doğru yok ama olsun, her deneme öğretir!',
  ];

  /// Rastgele doğru cevap mesajı döner.
  static String getCorrectFeedback({bool isHard = false}) {
    if (isHard && _random.nextBool()) {
      return hardQuestionSuccessMessages[
          _random.nextInt(hardQuestionSuccessMessages.length)];
    }
    return correctMessages[_random.nextInt(correctMessages.length)];
  }

  /// Rastgele yanlış cevap mesajı döner.
  static String getWrongFeedback() {
    return wrongMessages[_random.nextInt(wrongMessages.length)];
  }
}
