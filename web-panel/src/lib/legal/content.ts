// Gizlilik Politikası ve Kullanım Koşulları metinleri (Türk hukuku).
//
// ÖNEMLİ: Bu metinler TASLAKTIR. Yayına almadan önce KVKK ve tüketici hukuku konusunda
// uzman bir avukat tarafından incelenmeli; köşeli parantez içindeki alanlar (şirket
// unvanı, MERSİS, adres, iletişim, sunucu bölgesi, saklama süreleri, yurt dışı aktarım
// dayanağı, yetkili mahkeme, iade koşulları) gerçek bilgilerle doldurulmalıdır. Sayfalar
// bu alanlar kalmışken "taslak" uyarısı gösterir.
//
// Gizlilik metni değişirse uygulamadaki `kPrivacyNoticeVersion` (mobile-app/lib/content/
// privacy_notice.dart) da artırılmalıdır; öğrenci aydınlatma metni o sürümle ayrıca
// yönetilir ve bu dosyadaki metinle birebir aynı değildir.
//
// Bu içerik yalnızca Türkçe yazılmıştır (hukuki metin; çeviri ayrıca onaylanmalıdır).

export type LegalSection = {
  title: string;
  paragraphs: string[];
};

export const legalDraftNotice =
  "Bu sayfa taslaktır. Yayına almadan önce KVKK ve tüketici hukuku konusunda uzman bir avukat tarafından onaylanmalı ve köşeli parantez içindeki alanlar doldurulmalıdır.";

export const privacySummary: string[] = [
  "Veri sorumlusu [ŞİRKET UNVANI]'dır. Haklarını kullanmak için [İLETİŞİM E-POSTASI] adresine yazabilirsin; başvurular en geç 30 gün içinde yanıtlanır.",
  "Çocuk hesapları veli onayıyla açılır. Çocuklara yönelik reklam, davranışsal takip ve pazarlama iletisi yoktur.",
  "Yalnızca hizmeti sunmak için gerekli verileri işleriz; verilerini satmayız.",
  "Pazarlama iletileri (e-posta, SMS, telefon) ve analitik ölçüm yalnızca açık onayınla yapılır. Her kanal için onay ayrıdır ve başlangıçta işaretsizdir.",
  "Verdiğin rızayı istediğin zaman geri alabilirsin; bu, geri almadan önceki işlemleri geçersiz kılmaz.",
];

export const termsSummary: string[] = [
  "Hupolingo bir eğitim ve hazırlık hizmetidir; sınav veya puan garantisi vermez.",
  "18 yaşından küçük öğrencilerin hesabını veli açar ve yönetir.",
  "Ücretli abonelikte fiyat, yenileme ve iptal koşulları satın almadan önce gösterilir.",
  "Hesabını uygulamanın Ayarlar bölümünden dilediğin zaman silebilirsin.",
  "Tüketici olarak haklarınız (ve kanunun sınırlayamadığı haklar) saklıdır.",
];

export const privacySections: LegalSection[] = [
  {
    title: "Veri sorumlusu",
    paragraphs: [
      "Bu aydınlatma metni, 6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) m.10 uyarınca, Hupolingo hizmetini işleten veri sorumlusu [ŞİRKET UNVANI] tarafından hazırlanmıştır.",
      "Adres: [ADRES]. MERSİS no: [MERSİS NO]. E-posta: [İLETİŞİM E-POSTASI]. KEP: [KEP ADRESİ — varsa].",
      "Veri Sorumluları Siciline kayıt: [VERBİS KAYDI / MUAFİYET — hukukçu teyidi].",
    ],
  },
  {
    title: "Bu metin kimleri kapsar?",
    paragraphs: [
      "Veliler, veli hesabına bağlı öğrenciler, deneme sınavı ön kaydı ve veli adayı formunu dolduranlar, ödeme yapan kullanıcılar ile web sitesini ve uygulamayı ziyaret edenler.",
    ],
  },
  {
    title: "Hangi kişisel verileri işliyoruz?",
    paragraphs: [
      "Veli: ad soyad, e-posta adresi, telefon numarası (hesap doğrulaması ve SMS izni verdiysen SMS için), giriş bilgileri, veli panelindeki tercihler ve iletişim izinleri.",
      "Öğrenci: ad veya takma ad, sınıf, giriş e-postası (veli tarafından oluşturulur), çözdüğün soruların cevapları, XP, seviye, seri ve rozetler, deneme sınavı sonuçları (puan ve sıralama).",
      "Deneme sınavı ön kaydı ve veli adayı formu: veli adı, çocuğun adı ve sınıfı, telefon, e-posta, verdiğin iletişim izinleri ve formun geldiği kaynak (UTM parametreleri dâhil).",
      "Ödeme: iyzico üzerinden ödeme alınırken ad, soyad, e-posta ve ödeme anındaki IP adresi ödeme sağlayıcısına iletilir. Kart bilgilerin Hupolingo'ya ulaşmaz ve saklanmaz. Plan, tutar, tarih ve ödeme durumu kayıt altında tutulur.",
      "Teknik ve güvenlik: IP adresi, cihaz ve tarayıcı bilgisi, hata kayıtları (kişisel veri içermeyecek biçimde) ve form gönderimlerinin kötüye kullanımını önlemek için geçici hız sınırı kayıtları.",
      "Onay kayıtları: verdiğin veya geri aldığın onayın türü, metin sürümü ve tarihi.",
      "Analitik ölçüm (yalnızca onay verirsen): ana sayfa, demo, gizlilik ve kullanım koşulları sayfalarındaki sayfa görüntüleri; ana sayfada ana eylem düğmesine tıklama, demo tamamlama, veli kaydını başlatma ve fiyat bölümüne tıklama olayları ile genel cihaz ve tarayıcı bilgisi. Bu kayıtlarda ad, e-posta veya başka bir kişisel veri bulunmaz.",
      "Bildirim belirteci: bildirim özelliği kullanıma açıldığında ve sen bildirim izni verdiğinde.",
    ],
  },
  {
    title: "Hangi amaçla ve hangi hukuki sebeple işliyoruz?",
    paragraphs: [
      "Hesap oluşturma, giriş, hizmetin sunulması, öğrenme ilerlemesinin takibi ve veli takip ekranları: sözleşmenin kurulması ve ifası (KVKK m.5/2-c).",
      "Ödeme alma, kayıt ve fatura yükümlülükleri, muhasebe ve vergi mevzuatı: hukuki yükümlülük (KVKK m.5/2-ç).",
      "Güvenlik (bot ve kötüye kullanım önleme, dolandırıcılık önleme, hata ayıklama) ve hizmeti geliştirme (istatistiksel düzeyde): meşru menfaat (KVKK m.5/2-f). Bu menfaatin kişilerin temel hak ve özgürlükleriyle dengelendiği değerlendirilmiştir.",
      "Ticari elektronik iletiler (e-posta, SMS, telefon) ve analitik ölçüm: açık rıza (KVKK m.5/1) ve 6563 sayılı Elektronik Ticaretin Düzenlenmesi Hakkında Kanun.",
      "Çocuğa ait işlemler: veli onayı. Hangi işlemler için ayrıca açık rıza gerektiği hukukçu teyidine tabidir.",
      "Uyuşmazlık, savunma ve yetkili mercilerin talepleri: hukuki yükümlülük ve meşru menfaat.",
      "Sağlık, biyometrik veya diğer özel nitelikli kişisel verileri talep etmiyoruz; formlara bu tür bilgilerin yazılmamasını rica ederiz.",
    ],
  },
  {
    title: "Çocukların verileri",
    paragraphs: [
      "Hupolingo, 3–7. sınıf öğrencileri için tasarlanmıştır. Çocuk hesabı, veli tarafından açılır veya veli onayıyla bağlanır. Veli onayını veli panelinden verebilir ve geri çekebilir.",
      "Çocuklardan yalnızca hizmet için gerekli en az bilgiyi (ad veya takma ad, sınıf, giriş e-postası) isteriz.",
      "Çocuklara yönelik reklam, davranışsal takip, profilleme veya pazarlama iletisi yapmayız. Pazarlama iletileri yalnızca veli veya reşit kullanıcılara ve onaylarına göre gönderilir.",
      "Ligde diğer öğrencilere yalnızca isimsiz sıra bilgisi görünür; kişisel bilgiler görünmez.",
    ],
  },
  {
    title: "Açık rıza ve tercihlerin",
    paragraphs: [
      "Ticari ileti: e-posta, SMS ve telefon için üç ayrı onay kutusu vardır; tümü başlangıçta işaretsizdir. Onay zorunlu değildir ve onaysız hesap oluşturulabilir. Onayını veli panelindeki “İletişim izinlerim” kartından veya /ticari-ileti-izni sayfasından geri alabilirsin. Giriş, parola ve güvenlik gibi hizmet e-postaları bu onaydan bağımsızdır.",
      "Analitik çerezler: yalnızca onayınla çalışır. Reddedersen ölçüm betiği hiç yüklenmez. Onay tarayıcının depolama alanında saklanır; 'Çerez tercihlerimi değiştir' düğmesiyle istediğin zaman değiştirebilirsin.",
      "Veli onayı: çocuk hesabına ilişkin veri işlemleri için. Veli onayını veli panelinden geri çekebilir; geri çekilirse çocuğun hesabına ilişkin isteğe bağlı işlemler durdurulur.",
      "Reklam platformları: Meta, Google veya benzeri reklam platformlarıyla kişisel verilerini paylaşmıyor ve bu amaçla kitle (ör. karma değerli e-posta listesi) oluşturmuyoruz. İleride bunu yapmak istersek önce ayrı, açık ve ayrıştırılmış bir rıza alır ve bu metni güncelleriz.",
      "Pazarlama amaçlı segment oluşturma ve dışa aktarma yalnızca geçerli pazarlama izni olan kayıtlarla yapılır.",
      "Rızanı geri almak, geri almadan önce yapılan işlemlerin hukuka uygunluğunu etkilemez. Bir tercihi kapatman, temel hizmete erişimini engellemez; ancak ilgili izne bağlı bir özellik (ör. analitik ölçüm veya SMS bildirimi) çalışmayabilir.",
    ],
  },
  {
    title: "Kimlerle paylaşıyoruz?",
    paragraphs: [
      "Verilerini satmayız. Hizmeti sunmak için aşağıdaki hizmet sağlayıcılarla, KVKK m.12 uyarınca yazılı sözleşmeler çerçevesinde ve yalnızca gerekli ölçüde paylaşırız:",
      "Supabase: veritabanı, kimlik doğrulama ve dosya depolama (sunucu bölgesi: [SUNUCU BÖLGESİ]).",
      "Vercel: web sitesi ve web uygulamasının barındırılması.",
      "iyzico: ödeme alınması (yukarıda belirtilen alıcı bilgileriyle).",
      "İleti Merkezi: telefon doğrulama kodları ve SMS izni verdiğin durumlarda SMS iletileri.",
      "Brevo ve Resend: e-posta gönderimi (hesap ve hizmet e-postaları, sınav sonucu bildirimleri ve izin verdiğin pazarlama e-postaları).",
      "Cloudflare: bot koruması (Turnstile) ve güvenlik.",
      "PostHog (AB sunucuları): analitik ölçüm; yalnızca onayınla.",
      "Sentry: hata izleme. Hata raporları gönderilmeden önce kişisel veriler temizlenir.",
      "Google Firebase Cloud Messaging: bildirim gönderimi; bildirim özelliği açıkken.",
      "Google Drive: veritabanı yedeklerinin şifreli olarak saklanması.",
      "Apple App Store ve Google Play: uygulamanın dağıtımı ve mağaza üzerinden yapılan işlemler.",
      "Yetkili kamu kurum ve kuruluşları: yalnızca kanunen yetkili olduklarında ve talep ettiklerinde.",
      "Şirket devri: birleşme, devralma veya satış hâlinde veriler devralan şirkete aynı koşullarla aktarılabilir; seni bilgilendiririz.",
    ],
  },
  {
    title: "Yurt dışına aktarım",
    paragraphs: [
      "Yukarıdaki hizmet sağlayıcılardan bazıları (ör. Vercel, Cloudflare, Sentry, Google, Brevo, Resend, Apple ve Google Play) verileri Türkiye dışında işleyebilir. Yurt dışına aktarım, KVKK m.9 uyarınca [DAYANAK: yeterlilik kararı / standart sözleşme / bağlayıcı şirket kuralları / açık rıza — hukukçu teyidi ile belirlenecek] ile yürütülür.",
      "Veritabanının bulunduğu sunucu bölgesi: [SUNUCU BÖLGESİ].",
    ],
  },
  {
    title: "Ne kadar saklıyoruz?",
    paragraphs: [
      "Hesap: hesabın açık olduğu sürece. Hesap silindiğinde hesap ve ilişkili kişisel veriler [X GÜN] içinde silinir veya kişiyi tanımlanamaz hâle getirilir.",
      "Yedekler: veritabanı yedekleri şifrelenerek saklanır ve en çok 30 gün sonra döngüsü içinde silinir.",
      "Ödeme ve faturalama kayıtları: vergi ve ticaret mevzuatının öngördüğü süre boyunca.",
      "Deneme sınavı ön kaydı ve veli adayı kayıtları: pazarlama iletisi iznin geri alınana veya kayıt silinene kadar; hareketsiz kayıtlar [X AY] sonra gözden geçirilir.",
      "Sınav ve ilerleme sonuçları: hesap açık olduğu sürece. Kişisel olmayan istatistiksel özetler daha uzun süre tutulabilir.",
      "Onay kayıtları: rıza geçerliliğini ispat etmek için, ilgili rıza geri alındıktan sonra hukuki ispat süresi boyunca.",
      "Form ve giriş hız sınırı kayıtları: en çok 2 gün.",
      "Hata raporları ve teknik günlükler: [X GÜN].",
      "Analitik kayıtları: [X AY]. Onayını geri alırsan bundan sonra yeni analitik veri toplanmaz.",
      "Yasal ihtilaflar için gerekli kayıtlar, ilgili zamanaşımı süresince saklanır.",
    ],
  },
  {
    title: "Güvenlik",
    paragraphs: [
      "Veriler şifreli bağlantı (HTTPS/TLS) üzerinden iletilir. Veritabanında satır düzeyi güvenlik kuralları (RLS) ve rol bazlı erişim uygulanır. Yönetim ekranlarına erişim yetki denetimine tabidir.",
      "Girişler ve formlar bot koruması ve hız sınırıyla korunur. Yedekler şifrelenir. Parolalar açık metin olarak saklanmaz.",
      "Hiçbir sistem tamamen güvenli değildir. Bir veri ihlali olması hâlinde KVKK m.12 uyarınca gecikmeksizin, en geç 72 saat içinde Kişisel Verileri Koruma Kurulu'na; etkilenen kişileri de uygun yöntemlerle bilgilendiririz.",
    ],
  },
  {
    title: "Çerezler ve ölçüm",
    paragraphs: [
      "Oturumunun açık kalması için zorunlu çerezler kullanırız. Bunlar olmadan giriş yapılamaz; onaya bağlı değildir.",
      "Sitedeki bildirim ve ekran gösterimlerini oturum bazlı düzenlemek amacıyla zorunlu teknik yerel depolama araçları kullanılmaktadır. Bu araçlar kişisel profil oluşturmaz ve onaya bağlı değildir.",
      "Ürünü geliştirmek için analitik ölçüm yalnızca onayınla çalışır. Onay vermezsen ölçüm betiği hiç yüklenmez.",
      "Ölçüm; herkese açık sayfalardaki sayfa görüntülerini, ana sayfadaki belirli etkileşim olaylarını ve genel cihaz ve tarayıcı bilgisini kaydeder. Oturum kaydı yapılmaz, kişisel profil oluşturulmaz; veli, öğrenci ve yönetim sayfaları ölçüme dahil edilmez.",
      "Ölçüm hizmeti PostHog tarafından, Avrupa Birliği sunucularında sağlanır. Onayını bu sayfadaki 'Çerez tercihlerimi değiştir' düğmesiyle istediğin zaman geri alabilirsin. Tarayıcının 'Do Not Track' sinyali analitik tarafında dikkate alınır.",
      "Kullanılan teknolojilerin tam listesi ve süreleri: [ÇEREZ TABLOSU — yayın öncesi doldurulacak].",
    ],
  },
  {
    title: "Otomatik karar verme ve profilleme",
    paragraphs: [
      "Hukuki sonuç doğuran veya seni benzer biçimde önemli ölçüde etkileyen tamamen otomatik kararlar vermeyiz.",
      "Öğrenme ilerlemesine dayalı içerik seçimi yalnızca hizmeti kişiselleştirmek için yapılır; bu değerlendirmeler pazarlama amacıyla kullanılmaz.",
    ],
  },
  {
    title: "Haklarınız (KVKK m.11)",
    paragraphs: [
      "Kişisel verilerinizin işlenip işlenmediğini öğrenme; işlenmişse buna ilişkin bilgi talep etme; işleme amacını ve amacına uygun kullanılıp kullanılmadığını öğrenme; yurt içinde veya yurt dışında aktarıldığı üçüncü kişileri bilme.",
      "Eksik veya yanlış işlenmişse düzeltilmesini isteme; KVKK'da öngörülen koşullarda silinmesini veya yok edilmesini isteme ve bunun aktarıldığı üçüncü kişilere bildirilmesini isteme.",
      "Münhasıran otomatik sistemler ile analiz edilmesi sonucu aleyhine bir sonuç çıkmasına itiraz etme; kanuna aykırı işleme nedeniyle zararın giderilmesini talep etme.",
      "Verdiğin rızayı istediğin zaman geri alma.",
      "Hesabını ve verilerini uygulamanın Ayarlar bölümünden kopyalayabilir ve hesabını silebilirsin.",
    ],
  },
  {
    title: "Başvuru yolu ve şikâyet",
    paragraphs: [
      "Başvurularını [İLETİŞİM E-POSTASI] adresine e-postayla, [KEP ADRESİ] üzerinden veya [ADRES] adresine yazılı olarak iletebilirsin. Kimliğini doğrulamamız gerekebilir.",
      "Başvurular en geç 30 gün içinde sonuçlandırılır. Başvurular ücretsizdir; işlemin ayrıca maliyet gerektirmesi hâlinde Kişisel Verileri Koruma Kurulu'nun belirlediği tarifedeki ücret alınabilir.",
      "Başvurunun reddedilmesi, yetersiz bulunması veya süresinde cevap verilmemesi hâlinde Kişisel Verileri Koruma Kurulu'na şikâyette bulunabilirsin.",
    ],
  },
  {
    title: "Değişiklikler",
    paragraphs: [
      "Bu metni güncelleyebiliriz. Önemli değişikliklerde uygulama ve web sitesi üzerinden bilgilendiririz. İşleme amacı değişirse gerekli izinleri yeniden alırız.",
      "Son güncelleme tarihi sayfanın üst kısmında yer alır.",
    ],
  },
];

export const termsSections: LegalSection[] = [
  {
    title: "Taraflar ve kapsam",
    paragraphs: [
      "Bu koşullar, Hupolingo hizmetini işleten [ŞİRKET UNVANI] ile hizmeti kullanan kişiler arasında geçerlidir.",
      "Koşullar; hupolingo.com web sitesini, Hupolingo mobil uygulamasını, app.hupolingo.com web uygulamasını, veli panelini ve bunlara bağlı tüm içerik ve hizmetleri kapsar.",
      "Hizmeti kullanarak bu koşulları kabul etmiş olursun. Kabul etmiyorsan hizmeti kullanmamalısın.",
    ],
  },
  {
    title: "Tanımlar",
    paragraphs: [
      "Veli: hesabı açan ve bağlı öğrenci hesaplarını yöneten yetişkin.",
      "Öğrenci: veli hesabına bağlı çocuk veya genç kullanıcı.",
      "Hesap: veli veya öğrenci hesabı. İçerik: sorular, açıklamalar, metinler, görseller, karakterler ve diğer materyaller. Kullanıcı içeriği: kullanıcının hizmete girdiği cevaplar, notlar ve diğer veriler.",
    ],
  },
  {
    title: "Hizmetin niteliği",
    paragraphs: [
      "Hupolingo; 3–7. sınıf öğrencilerine yönelik kısa soru çalışmaları, öğrenme takibi ve veli takip ekranları sunan bir eğitim ve hazırlık hizmetidir.",
      "Hizmet resmi bir eğitim kurumu veya sınav kurumu değildir; sınav veya okul başarısı, ya da belirli bir puan garantisi vermez.",
      "İçeriklerde hata bulunabilir. Bir hata fark edersen bize bildirmen, düzeltmemize yardımcı olur.",
    ],
  },
  {
    title: "Hesap, veli sorumluluğu ve çocuklar",
    paragraphs: [
      "Hesabı doğru bilgilerle oluşturmalı ve bilgilerin değiştiğinde güncellemelisin.",
      "Hesabın güvenliği senin sorumluluğundadır. Parolanı kimseyle paylaşma; şüpheli bir durum fark edersen bize bildir.",
      "18 yaşından küçük öğrencilerin hesapları veli tarafından açılır ve yönetilir. Veli, bu koşulları çocuğu adına kabul ettiğini ve çocuğun hesap kullanımından sorumlu olduğunu beyan eder.",
      "Veli, bağlı öğrenci hesaplarına ilişkin veri işleme onaylarını veli panelinden verebilir veya geri çekebilir.",
      "Hesap yalnızca veli ve bağlı öğrenci tarafından kullanılır; başkasına devredilemez veya paylaşılamaz.",
    ],
  },
  {
    title: "Kabul edilemez kullanım",
    paragraphs: [
      "Hizmeti yasalara aykırı biçimde kullanmak veya başkalarının haklarını ihlal etmek yasaktır.",
      "Çocuklara zarar verecek, uygunsuz içerik veya iletişim yaymak; çocuklardan kişisel bilgi (adres, okul adı, telefon vb.) istemek yasaktır.",
      "Başkasının hesabına izinsiz erişmek, kimlik taklit etmek ve yanıltıcı bilgi vermek yasaktır.",
      "Hizmeti otomatik araçlarla (bot, veri kazıyıcı vb.) kullanmak, hız sınırlarını aşmaya çalışmak, hizmetin güvenliğini veya işleyişini bozmak yasaktır.",
      "İçerikleri izinsiz kopyalamak, çoğaltmak, satmak veya türev içerik oluşturmak yasaktır. Yazılımı tersine mühendislikle çözmeye çalışmak, kanunun izin verdiği ölçü dışında yasaktır.",
      "Hizmeti rekabet amaçlı kullanmak veya bir rakip ürün geliştirmek için kullanmak yasaktır.",
      "Sahte ödeme, deneme haklarının kötüye kullanımı ve benzeri suistimaller yasaktır.",
    ],
  },
  {
    title: "Ücretli hizmetler, abonelik ve ödeme",
    paragraphs: [
      "Ücretli planların fiyatı, süresi, yenileme koşulları ve kapsamı satın almadan önce gösterilir. Ödemeler iyzico üzerinden alınır; kart bilgileri Hupolingo tarafından görülmez veya saklanmaz.",
      "Abonelikler, iptal edilmediği sürece dönem sonunda aynı koşullarla otomatik yenilenir. Yenilemeden önce [X GÜN] içinde bilgilendirme yapılır.",
      "Yenilemeyi hesap ayarlarından veya [İLETİŞİM E-POSTASI] üzerinden durdurabilirsin. İptal bir sonraki döneme etki eder; mevcut dönem sonuna kadar hizmet devam eder.",
      "Fiyat değişiklikleri mevcut dönem bitene kadar uygulanmaz ve en az [X GÜN] önce bildirilir.",
      "Cayma hakkı, mesafeli sözleşmelere ilişkin mevzuat ve ön bilgilendirme formunda belirtilen koşullar çerçevesinde uygulanır. Dijital hizmetin cayma süresi dolmadan ifasına başlanmasına açıkça onay vermen hâlinde yasal istisnalar geçerli olabilir; bu onay satın alma adımında ayrıca alınır.",
      "İade koşulları: [İADE VE İPTAL KOŞULLARI — hukukçu teyidi]. Tüketici mevzuatından doğan iade hakların saklıdır.",
      "Ön bilgilendirme formu ve mesafeli satış sözleşmesi, ödeme öncesinde gösterilir ve bu koşullarla birlikte geçerlidir.",
    ],
  },
  {
    title: "İçerik ve fikri mülkiyet",
    paragraphs: [
      "Hupolingo'daki içerikler, yazılımlar, tasarımlar, karakterler, marka ve logolar Hupolingo'ya veya lisans verenlerine aittir. İzin verilmeden kopyalanamaz, değiştirilemez, dağıtılamaz veya ticari amaçla kullanılamaz.",
      "Kişisel ve ticari olmayan amaçla, hesabın kullanımı kapsamında içerikleri görüntüleyebilir ve kullanabilirsin.",
      "Önerilerini bize iletebilirsin; bu önerileri hizmeti geliştirmek için ek bir ücret ödemeden kullanabiliriz.",
    ],
  },
  {
    title: "Kullanıcı içeriği",
    paragraphs: [
      "Hizmete girdiğin cevaplar, notlar ve diğer kullanıcı içerikleri sana veya ilgili kullanıcıya aittir.",
      "Bu içerikleri hizmeti sunmak, hesabı çalıştırmak, güvenliği sağlamak ve hizmeti geliştirmek için, bu amaçlarla sınırlı olarak kullanma yetkisi Hupolingo'ya verilir. Bu yetki gizlilik metnindeki amaç ve sınırlara tabidir.",
      "Kullanıcı içeriklerini reklam amacıyla kullanmaz ve üçüncü kişilere satmayız.",
      "Çocukların kendi kişisel bilgilerini (adres, okul adı, telefon vb.) içeriklere yazmaması gerekir. Böyle bir bilgi tespit edilirse içerik kaldırılabilir.",
      "Uygunsuz içerik bildirimleri [BİLDİRİM E-POSTASI] adresine iletilebilir.",
    ],
  },
  {
    title: "Hizmet değişiklikleri, bakım ve kesintiler",
    paragraphs: [
      "Hizmeti geliştirmek için özellikleri değiştirebilir, ekleyebilir veya kaldırabiliriz. Önemli bir özelliğin kaldırılması hâlinde makul bir süre önceden bildirim yapılır ve gerekirse ücretli dönem için orantılı bir çözüm sunulur.",
      "Bakım, teknik arıza ve mücbir sebepler nedeniyle hizmet geçici olarak kesintiye uğrayabilir. Planlı bakımlar mümkün olduğunca önceden duyurulur.",
      "Kesintisiz erişim garanti edilmez. Uzun süreli kesintiler ücretli dönem için dikkate alınır ve gerekirse süre uzatılır.",
    ],
  },
  {
    title: "Üçüncü taraf hizmetleri ve bağlantılar",
    paragraphs: [
      "Hizmet; ödeme sağlayıcısı (iyzico), uygulama mağazaları (Apple App Store, Google Play) ve üçüncü taraf sitelere bağlantılar içerebilir.",
      "Bu hizmetlerin koşulları ve gizlilik uygulamaları kendi sorumluluklarındadır. Üçüncü taraflardan kaynaklanan sorunlardan, kanunen sorumlu olduğumuz durumlar dışında Hupolingo sorumlu değildir.",
    ],
  },
  {
    title: "Kişisel veriler",
    paragraphs: [
      "Kişisel verilerinin işlenmesi, Hupolingo Gizlilik Politikası ve KVKK kapsamında düzenlenir. Bu koşullar gizlilik metniyle birlikte okunur.",
    ],
  },
  {
    title: "Askıya alma ve fesih",
    paragraphs: [
      "Koşulların ihlali, dolandırıcılık veya güvenlik riski hâlinde hesabı geçici olarak askıya alabilir veya kapatabiliriz. Mümkün olduğunda önce uyarı yapılır; acil güvenlik durumları bunun dışındadır.",
      "Hesabını dilediğin zaman uygulamanın Ayarlar bölümünden silebilirsin. Hesap silindiğinde erişimin sona erer; yasal saklama yükümlülüğü olan kayıtlar ve yedekler gizlilik metnindeki sürelere göre işlenir.",
      "Hizmet sonlandırıldığında, ödenmiş ancak kullanılmamış dönem için orantılı iade [İADE VE İPTAL KOŞULLARI] maddesine göre yapılır.",
    ],
  },
  {
    title: "Sorumluluğun sınırlandırılması",
    paragraphs: [
      "Hupolingo, hizmetin sunumundan doğan dolaylı zararlardan (kâr, veri veya itibar kaybı gibi), kanunun izin verdiği ölçüde sorumlu değildir.",
      "Doğrudan zararlar için sorumluluk, zararın doğduğu dönemde ödenen abonelik tutarını aşmaz. [SORUMLULUK TAVANI — tüketici sözleşmelerindeki haksız şart riski nedeniyle hukukçu teyidi gerekir.]",
      "Bu sınırlama; ölüm veya bedensel zarar, kasıt veya ağır kusurdan doğan zararlar, Hupolingo'nun kendi kusuruyla oluşan kişisel veri ihlallerinden doğan yasal sorumluluk ve kanunla sınırlandırılamayan haklar için geçerli değildir.",
    ],
  },
  {
    title: "Tazminat",
    paragraphs: [
      "Veli veya kullanıcının bu koşulları ihlali sonucu Hupolingo'nun uğradığı doğrudan zararlardan, kanunun izin verdiği ölçüde sorumlu olduğu kabul edilir.",
    ],
  },
  {
    title: "Bildirimler",
    paragraphs: [
      "Koşullarla ilgili bildirimleri hesabında kayıtlı e-posta adresine, uygulama veya web sitesi üzerinden yaparız.",
    ],
  },
  {
    title: "Değişiklikler",
    paragraphs: [
      "Bu koşullar güncellenebilir. Önemli değişiklikler yürürlük tarihinden en az [X GÜN] önce duyurulur.",
      "Önemli değişikliklerde yeniden onayını isteriz. Değişikliği kabul etmediğin durumda hesabını silebilirsin.",
    ],
  },
  {
    title: "Uygulanacak hukuk ve uyuşmazlıklar",
    paragraphs: [
      "Bu koşullar Türkiye Cumhuriyeti kanunlarına tabidir.",
      "Tüketici sıfatıyla hizmeti kullanan veli ve öğrencilerle ilgili uyuşmazlıklarda 6502 sayılı Tüketici Kanunu hükümleri uygulanır. Tüketici, yerleşim yerindeki Tüketici Hakem Heyeti'ne veya Tüketici Mahkemesi'ne başvurma hakkını saklı tutar; Ticaret Bakanlığı tüketici şikâyet sistemine de başvurabilir.",
      "Diğer uyuşmazlıklarda yetkili mahkeme: [YETKİLİ MAHKEME — hukukçu teyidi].",
      "Uyuşmazlık çıkması hâlinde önce [İLETİŞİM E-POSTASI] üzerinden çözüm görüşmesi yapılması talep edilir.",
    ],
  },
  {
    title: "Çeşitli hükümler",
    paragraphs: [
      "Bu koşulların bir hükmü geçersiz olursa diğer hükümler geçerliliğini korur.",
      "Hupolingo'nun bir hakkını kullanmaması, o hakkından vazgeçtiği anlamına gelmez.",
      "Bu koşullar, gizlilik metni ile ödeme sırasında gösterilen ön bilgilendirme ve sözleşme belgeleriyle birlikte tüm anlaşmayı oluşturur.",
    ],
  },
  {
    title: "İletişim",
    paragraphs: [
      "[ŞİRKET UNVANI], [ADRES], [İLETİŞİM E-POSTASI].",
    ],
  },
];
