import type { Metadata } from "next";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "meta.ticariIletiIzni" });
  return { title: t("title"), description: t("description") };
}

// TODO (canlıya almadan önce hukuk onayı gerekli):
//   - [ŞİRKET_UNVANI] alanını doldurun
//   - [İLETİŞİM_EPOSTASI] alanını doldurun
//   - [WEB_SİTESİ] alanını doldurun
//   - [SON_GUNCELLEME_TARİHİ] alanını doldurun
//   - Metnin hukuk birimi tarafından onaylanmasını sağlayın

const PLACEHOLDER_UNVAN = "[Şirketin Tam Ticaret Unvanı]";
const PLACEHOLDER_EPOSTA = "[iletisim@hupolingo.com]";
const PLACEHOLDER_SITE = "hupolingo.com";

export default async function TicariIletiIzniPage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  return (
    <div className="min-h-dvh bg-cream py-12 text-navy">
      <div className="mx-auto max-w-3xl px-4 sm:px-6">
        {/* Yer tutucu uyarısı — geliştirme ortamında görünür */}
        {process.env.NODE_ENV !== "production" && (
          <div className="mb-6 rounded-xl border border-amber-300 bg-amber-50 px-4 py-3 text-sm text-amber-800">
            <strong>Geliştirici notu:</strong> Bu sayfada doldurulması gereken yer tutucular var
            ({PLACEHOLDER_UNVAN}, {PLACEHOLDER_EPOSTA}, {PLACEHOLDER_SITE}). Canlıya almadan önce
            hukuk onayı alın.
          </div>
        )}

        <h1 className="text-3xl font-extrabold tracking-tight">
          HUPOLİNGO Ticari Elektronik İleti Bilgilendirme ve Onay Metni
        </h1>
        <p className="mt-2 text-sm text-gray-500">
          Son Güncelleme: [SON_GÜNCELLEME_TARİHİ] · Sürüm: hupolingo-ticari-ileti-2026-10-v1
        </p>

        <div className="mt-8 space-y-6 text-base leading-relaxed text-gray-800">
          <section>
            <p>
              <strong>Hizmet Sağlayıcı:</strong> {PLACEHOLDER_UNVAN} (<strong>HUPOLİNGO</strong>)<br />
              <strong>İletişim:</strong> {PLACEHOLDER_EPOSTA}<br />
              <strong>İnternet Sitesi:</strong> {PLACEHOLDER_SITE}
            </p>
          </section>

          <section>
            <h2 className="text-xl font-extrabold">1. Amaç ve Kapsam</h2>
            <p className="mt-2">
              İşbu Ticari Elektronik İleti Bilgilendirme ve Onay Metni, {PLACEHOLDER_UNVAN} tarafından
              HUPOLİNGO markası altında sunulan dijital eğitim, öğrenme, sınav hazırlık, ölçme ve
              değerlendirme, oyunlaştırılmış eğitim, öğrenci gelişim takibi, ebeveyn destek, abonelik
              ve bunlarla bağlantılı ürün ve hizmetlere ilişkin ticari elektronik ileti faaliyetleri
              hakkında kullanıcıların bilgilendirilmesi ve tercih etmeleri hâlinde onaylarının
              alınması amacıyla hazırlanmıştır.
            </p>
            <p className="mt-2">
              Ticari elektronik ileti onayı isteğe bağlıdır. Kullanıcı, onay vermeksizin
              HUPOLİNGO&apos;nun temel üyelik, eğitim ve abonelik hizmetlerinden yararlanabilir.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-extrabold">2. Ticari Elektronik İletilerin Konusu</h2>
            <p className="mt-2">Kullanıcının onay vermesi hâlinde şu konularda ticari elektronik ileti gönderilebilir:</p>
            <ul className="mt-2 list-disc space-y-1 pl-6">
              <li>Ürün ve hizmet tanıtımları (mobil uygulama, soru bankaları, deneme sınavları, öğrenme modülleri)</li>
              <li>Kampanya, indirim ve ticari teklifler (abonelik fırsatları, kuponlar, referans programları)</li>
              <li>Eğitim programları ve yeni hizmetler (sınava hazırlık kursları, çevrim içi etkinlikler)</li>
              <li>Üyelik ve abonelik fırsatları (premium özellikler, aile paketleri)</li>
              <li>Yarışmalar, ödüller ve sadakat programları</li>
              <li>Marka, içerik ve iş birliği duyuruları</li>
              <li>Kullanıcı deneyimi araştırmaları ve geri bildirim talepleri</li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl font-extrabold">3. İletişim Kanalları</h2>
            <p className="mt-2">
              Ticari elektronik iletiler, kullanıcının ayrıca seçerek onay verdiği kanallardan
              gönderilebilir:
            </p>
            <ul className="mt-2 list-disc space-y-1 pl-6">
              <li><strong>E-posta:</strong> Ticari tanıtımlar, kampanyalar, abonelik fırsatları, ürün duyuruları.</li>
              <li><strong>SMS/MMS:</strong> Kampanyalar, özel teklifler, promosyonlar, üyelik avantajları.</li>
              <li><strong>Telefon Araması:</strong> Ürün ve hizmet tanıtımları, abonelik teklifleri.</li>
              <li><strong>Uygulama bildirimleri (push):</strong> Kampanya ve teklifler. Yalnızca bu kanala ayrıca onay veren velilere gönderilir.</li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl font-extrabold">4. İleti Yönetim Sistemi (İYS)</h2>
            <p className="mt-2">
              Verilen ticari elektronik ileti onayları, 6563 sayılı Kanun kapsamında İleti Yönetim
              Sistemi&apos;ne (İYS) kaydedilir ve bu sistem üzerinden yönetilir. Kullanıcı, seçtiği
              kanallara ilişkin onay ve ret tercihlerini İYS üzerinden de yönetebilir.
            </p>
            <p className="mt-2">
              İYS internet adresi:{" "}
              <a
                href="https://vatandas.iys.org.tr"
                target="_blank"
                rel="noopener noreferrer"
                className="font-semibold text-brand-600 underline hover:text-brand-700"
              >
                vatandas.iys.org.tr
              </a>
            </p>
          </section>

          <section>
            <h2 className="text-xl font-extrabold">5. Onayın Geri Alınması ve Ret Hakkı</h2>
            <p className="mt-2">
              Kullanıcı, ticari elektronik ileti almayı hiçbir gerekçe göstermeksizin, dilediği
              zaman ve ücretsiz olarak reddedebilir. Ret hakkı şu yollarla kullanılabilir:
            </p>
            <ul className="mt-2 list-disc space-y-1 pl-6">
              <li>Gönderilen iletideki abonelikten çıkma bağlantısı</li>
              <li>HUPOLİNGO hesabındaki iletişim tercihleri bölümü</li>
              <li>İleti Yönetim Sistemi (İYS)</li>
            </ul>
            <p className="mt-2">
              Ret talebinin Şirkete ulaşmasını takip eden en geç <strong>üç iş günü</strong> içinde
              ilgili kanaldan ticari elektronik ileti gönderimi durdurulur.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-extrabold">6. Çocuklara İlişkin Özel Düzenleme</h2>
            <p className="mt-2">
              HUPOLİNGO, çocukların eğitim ve gelişimini destekleyen bir platformdur. Ticari
              elektronik ileti izinleri, kural olarak yetişkin veli veya yasal temsilcilerin kendi
              iletişim bilgileri ve kendi irade beyanları üzerinden alınır. Öğrenci (çocuk)
              hesapları, ticari pazarlama iznini bağımsız olarak verebilen bir mekanizma şeklinde
              tasarlanmaz.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-extrabold">7. Hizmet Bildirimleri ile Ticari İletilerin Ayrımı</h2>
            <p className="mt-2">
              Hesap güvenliği, ödeme işlemleri, sınav hatırlatmaları (üyelik kapsamında) ve mevzuat
              gereği yapılması zorunlu bildirimler, ticari elektronik ileti onayından bağımsız olarak
              gönderilebilir.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-extrabold">8. Kişisel Verilerin Korunması</h2>
            <p className="mt-2">
              Ticari elektronik ileti gönderimi kapsamında işlenen kişisel verilere ilişkin ayrıntılı
              bilgi HUPOLİNGO Gizlilik Politikası&apos;nda sunulur. Bu onay, KVKK kapsamında ayrıca açık
              rıza gerektiren veri işleme faaliyetleri için verilmiş bir açık rıza olarak
              yorumlanamaz.
            </p>
          </section>
        </div>
      </div>
    </div>
  );
}
