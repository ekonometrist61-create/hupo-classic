// Çocuklar için sade dille yazılmış gizlilik bildirimi.
//
// ÖNEMLİ: Bu metin bir TASLAKTIR. Yayına almadan önce KVKK uzmanı bir hukukçu tarafından
// gözden geçirilmelidir (hangi yaşta hangi rıza gerektiği, veri sorumlusu bilgileri,
// saklama süreleri vb.). Metin değiştiğinde [kPrivacyNoticeVersion] değerini artırın;
// böylece öğrencilere bildirim yeniden gösterilir.

const kPrivacyNoticeVersion = '2026-09-taslak-1';

class PrivacySection {
  const PrivacySection(this.title, this.body);

  final String title;
  final String body;
}

const kPrivacySections = [
  PrivacySection(
    'Hangi bilgilerini tutuyoruz?',
    'Adını, sınıfını, giriş yapmak için e-posta adresini, çözdüğün soruları ve '
        'cevaplarını, XP, seviye, seri ve rozetlerini tutuyoruz.',
  ),
  PrivacySection(
    'Bunları neden kullanıyoruz?',
    'Sana uygun soruları göstermek, ilerlemeni hesaplamak ve velinin gelişimini '
        'görebilmesi için kullanıyoruz.',
  ),
  PrivacySection(
    'Bilgilerini kimler görür?',
    'Sen ve velin görebilir. Diğer öğrenciler adını veya bilgilerini göremez; '
        'ligde başkalarına yalnızca sıra numaran gibi isimsiz sayılar görünür.',
  ),
  PrivacySection(
    'Reklam ve takip var mı?',
    'Uygulamada reklam ve seni takip eden araçlar yok.',
  ),
  PrivacySection(
    'Haklarını nasıl kullanırsın?',
    'Ayarlar bölümünden bilgilerini kopyalayabilir ve hesabını silebilirsin. '
        'Velin de veli panelinden onay verebilir veya onayını geri çekebilir.',
  ),
];
