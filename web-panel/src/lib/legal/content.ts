// Gizlilik Politikası ve Kullanım Koşulları metinleri.
//
// ÖNEMLİ: Bu metinler TASLAKTIR. Yayına almadan önce KVKK uzmanı bir avukat tarafından
// incelenmeli ve köşeli parantez içindeki alanlar (şirket unvanı, iletişim, sunucu bölgesi,
// saklama süreleri, uygulanacak hukuk) gerçek bilgilerle doldurulmalıdır. Sayfalar bu
// alanlar kalmışken "taslak" uyarısı gösterir. Metin değişince uygulamadaki
// `kPrivacyNoticeVersion` da artırılmalıdır (mobile-app/lib/content/privacy_notice.dart).
// Bu içerik yalnızca Türkçe yazılmıştır (hukuki metin; çeviri ayrıca onaylanmalıdır).

export type LegalSection = {
  title: string;
  paragraphs: string[];
};

export const legalDraftNotice =
  "Bu sayfa taslaktır. Yayına almadan önce KVKK uzmanı bir avukat tarafından onaylanmalı ve köşeli parantez içindeki alanlar doldurulmalıdır.";

export const privacySections: LegalSection[] = [
  {
    title: "Veri sorumlusu",
    paragraphs: [
      "Bu politika, Hupolingo hizmetini sunan [ŞİRKET UNVANI] tarafından 6698 sayılı Kişisel Verilerin Korunması Kanunu kapsamında hazırlanmıştır.",
    ],
  },
  {
    title: "Hangi bilgileri topluyoruz?",
    paragraphs: [
      "Veli hesabı için ad soyad ve e-posta adresi.",
      "Öğrenci hesapları için ad, sınıf, giriş e-postası, çözülen soruların cevapları, XP, seviye, seri ve rozet bilgileri.",
      "Bildirimleri açtığında bildirim göndermek için cihaz belirteci.",
      "Ödeme, iyzico'nun ödeme sayfasında alınır; Hupolingo kart bilgilerini görmez ve saklamaz.",
    ],
  },
  {
    title: "Bilgileri neden kullanıyoruz?",
    paragraphs: [
      "Hesabını oluşturmak ve giriş yapmanı sağlamak.",
      "Sana uygun soruları göstermek, ilerlemeni hesaplamak ve velinin gelişimini görebilmesini sağlamak.",
      "Ücretli plan varsa ödeme ve aboneliğini yönetmek.",
      "Hesabını ve hizmeti güvende tutmak.",
    ],
  },
  {
    title: "Çocukların verileri",
    paragraphs: [
      "Hupolingo öğrencilere yönelik tasarlanmıştır. Öğrenci hesapları veli onayıyla bağlanır; veli onayını veli panelinden verebilir veya geri çekebilir.",
      "Uygulamada reklam ve davranışsal takip araçları bulunmaz.",
    ],
  },
  {
    title: "Kimlerle paylaşıyoruz?",
    paragraphs: [
      "Verileri, hizmeti sağlamak için çalıştığımız hizmet sağlayıcılarla paylaşırız: veri barındırma için Supabase, ödeme için iyzico ve bildirimler için (yalnızca bildirimleri açtıysan) Firebase Cloud Messaging.",
      "Veliler, bağlı çocuklarının bilgilerini görür. Diğer öğrenciler kişisel bilgilerini göremez; ligde yalnızca isimsiz sıra numarası görünür.",
      "Yasal bir zorunluluk olduğunda yetkili kamu kurumlarına bilgi verebiliriz.",
    ],
  },
  {
    title: "Ticari iletiler",
    paragraphs: [
      "Abonelik, ürün ve kampanya bilgileri için e-posta göndermemizi kayıt sırasında ayrıca ve açıkça onaylarsan bu iletileri göndeririz. Bu onay zorunlu değildir ve onaysız hesap oluşturabilirsin.",
      "Onayını istediğin zaman veli panelindeki 'İletişim izinlerim' kartından ya da /iletisim-izni sayfasından geri alabilirsin. Geri aldıktan sonra o adrese ticari ileti göndermeyiz.",
      "Onay ve geri alma kayıtları, KVKK ve ticari elektronik ileti mevzuatından doğan ispat yükümlülüğü için saklanır. Giriş, parola ve güvenlik gibi hizmet e-postaları bu izinden bağımsızdır.",
    ],
  },
  {
    title: "Çerezler ve ölçüm",
    paragraphs: [
      "Oturumunun açık kalması için zorunlu çerezler kullanırız. Bunlar olmadan giriş yapılamaz; onaya bağlı değildir.",
      "Ürünü geliştirmek için analitik ölçüm yalnızca onayınla çalışır. Onay vermezsen ölçüm betiği hiç yüklenmez.",
      "Ölçüm, yalnızca herkese açık sayfalardaki sayfa görüntülerini ve genel cihaz ve tarayıcı bilgisini kaydeder. Oturum kaydı yapılmaz, kişisel profil oluşturulmaz; veli, öğrenci ve yönetim sayfaları ölçüme dahil edilmez.",
      "Ölçüm hizmeti PostHog tarafından, Avrupa Birliği sunucularında sağlanır. Onayını bu sayfadaki 'Çerez tercihlerimi değiştir' düğmesiyle istediğin zaman geri alabilirsin.",
    ],
  },
  {
    title: "Yurt dışına aktarım",
    paragraphs: [
      "Verilerin barındırıldığı sunucu bölgesi: [SUNUCU BÖLGESİ]. Hizmet sağlayıcıların yurt dışında bulunan altyapısı varsa bu aktarım, KVKK'nın öngördüğü koşullara uygun şekilde yürütülür.",
    ],
  },
  {
    title: "Ne kadar saklıyoruz?",
    paragraphs: [
      "Hesabın açık olduğu sürece verilerini tutarız. Hesabını sildiğinde hesabın ve ilişkili veriler silinir.",
      "Yasal yükümlülükler nedeniyle saklanması gereken kayıtlar için saklama süresi: [SAKLAMA SÜRESİ].",
    ],
  },
  {
    title: "Güvenlik",
    paragraphs: [
      "Veriler şifreli bağlantı (HTTPS/TLS) üzerinden iletilir. Veritabanında satır düzeyi güvenlik kuralları uygulanır. Parolalar açık metin olarak saklanmaz.",
    ],
  },
  {
    title: "Haklarını nasıl kullanırsın?",
    paragraphs: [
      "Uygulamanın Ayarlar bölümünden bilgilerini kopyalayabilir ve hesabını silebilirsin. Ticari ileti iznini veli panelinden veya /iletisim-izni sayfasından geri alabilirsin.",
      "KVKK'nın 11. maddesindeki diğer haklarını kullanmak için [İLETİŞİM E-POSTASI] adresine yazabilirsin.",
    ],
  },
  {
    title: "Değişiklikler",
    paragraphs: [
      "Bu politika değişirse bu sayfada ve uygulamada duyuru yaparız. Önemli değişikliklerde seni yeniden bilgilendiririz.",
    ],
  },
];

export const termsSections: LegalSection[] = [
  {
    title: "Hizmet",
    paragraphs: [
      "Hupolingo, 3–7. sınıf öğrencileri için kısa soru çalışmaları ve veli takip ekranları sunan bir eğitim hizmetidir.",
      "Hupolingo bir sınav veya puan garantisi vermez. Hizmet hazırlık amaçlıdır.",
    ],
  },
  {
    title: "Hesap ve güvenlik",
    paragraphs: [
      "Hesabı doğru bilgilerle oluşturmalısın. Parolanı gizli tutmak senin ve velinin sorumluluğundadır.",
      "18 yaş altındaki öğrenciler için hesap, veli tarafından yönetilir.",
    ],
  },
  {
    title: "Veli sorumluluğu",
    paragraphs: [
      "Veli, bağlı çocuğunun hesabını ve veli panelindeki izinleri yönetir. Veri işlemeye ilişkin onay veli tarafından verilir ve geri çekilebilir.",
    ],
  },
  {
    title: "Ücretler ve abonelik",
    paragraphs: [
      "Ücretli planların fiyatları ödeme sayfasında gösterilir. Ödemeler iyzico üzerinden alınır.",
      "Yenileme, iptal ve iade koşulları: [İADE VE İPTAL KOŞULLARI].",
    ],
  },
  {
    title: "Kabul edilemez kullanım",
    paragraphs: [
      "Hesabını başkasına devretmek, otomatik araçlarla içerik toplamak, hizmetin işleyişini bozmaya yönelik girişimlerde bulunmak ve başkalarının kişisel bilgilerini paylaşmak yasaktır.",
    ],
  },
  {
    title: "Fikri mülkiyet",
    paragraphs: [
      "Sorular, metinler, karakterler ve Hupo markasına ait öğeler Hupolingo'ya aittir; izinsiz kopyalanamaz veya dağıtılamaz.",
    ],
  },
  {
    title: "Hizmetin sınırları",
    paragraphs: [
      "Hizmet olduğu gibi sunulur; kesintisiz erişim garanti edilmez. Yasaların izin verdiği ölçüde sorumluluk sınırlandırılır.",
    ],
  },
  {
    title: "Hesabın kapatılması",
    paragraphs: [
      "Hesabını Ayarlar bölümünden silebilirsin. Bu koşullara aykırı kullanımda hesap askıya alınabilir.",
    ],
  },
  {
    title: "Değişiklikler",
    paragraphs: [
      "Bu koşullar güncellenebilir. Önemli değişiklikleri uygulama ve web sitesi üzerinden duyururuz.",
    ],
  },
  {
    title: "Uygulanacak hukuk ve iletişim",
    paragraphs: [
      "Uygulanacak hukuk: [UYGULANACAK HUKUK]. İletişim: [İLETİŞİM E-POSTASI].",
    ],
  },
];
