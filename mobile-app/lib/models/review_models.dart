// Tekrar (Yanlışları Tekrar Çöz / Günün Tekrarı) ve Kayıtlı Sorular modelleri.
//
// APK sınıf adları: ReviewEntry, ReviewFilter, SavedQuestion.

import 'models.dart';

/// Hangi soruların filtreleneceği seçeneği.
enum ReviewFilter {
  all,
  due,
  wrong,
}

/// Tekrar listesindeki bir sorunun giriş modeli.
class ReviewEntry {
  const ReviewEntry({
    required this.question,
    this.lastAnswer,
    this.isCorrect = false,
    this.nextReviewDate,
    this.attemptCount = 0,
  });

  final Question question;
  final String? lastAnswer;
  final bool isCorrect;
  final DateTime? nextReviewDate;
  final int attemptCount;

  factory ReviewEntry.fromMap(Map<String, dynamic> map) => ReviewEntry(
        question: Question.fromMap(
          map['question'] is Map<String, dynamic>
              ? map['question'] as Map<String, dynamic>
              : map,
        ),
        lastAnswer: map['secilen_sik'] as String?,
        isCorrect: map['dogru_mu'] as bool? ?? false,
        nextReviewDate: map['sonraki_tekrar_tarihi'] == null
            ? null
            : DateTime.parse(map['sonraki_tekrar_tarihi'] as String).toLocal(),
        attemptCount: (map['deneme_sayisi'] as num?)?.toInt() ?? 0,
      );
}

/// public.list_bookmarks() RPC'si ve yer imleri tablosu modeli.
class SavedQuestion {
  const SavedQuestion({
    required this.questionId,
    required this.question,
    required this.createdAt,
  });

  final String questionId;
  final Question question;
  final DateTime createdAt;

  factory SavedQuestion.fromMap(Map<String, dynamic> map) {
    final qId = (map['question_id'] ?? map['id']) as String;
    return SavedQuestion(
      questionId: qId,
      question: Question(
        id: qId,
        ders: map['ders'] as String? ?? '',
        konu: map['konu'] as String? ?? '',
        altKonu: map['alt_konu'] as String?,
        zorluk: (map['zorluk'] as num?)?.toInt() ?? 1,
        text: map['soru_metni'] as String? ?? '',
        options: map['siklar'] is Map
            ? {
                for (final e in (map['siklar'] as Map).entries)
                  e.key.toString(): e.value.toString(),
              }
            : const {},
      ),
      createdAt: map['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['created_at'] as String).toLocal(),
    );
  }
}
