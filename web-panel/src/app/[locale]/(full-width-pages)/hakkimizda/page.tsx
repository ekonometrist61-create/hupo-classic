import { marketingFont } from "@/components/landing/marketingFont";
import { Link } from "@/i18n/navigation";
import type { Metadata } from "next";
import { setRequestLocale } from "next-intl/server";

// Hakkımızda ve iletişim. Metin: docs/pazarlama/tanitim-metinleri-2026-11-14.md §2.5 (MAR-OTO-AI sürümü).
// "Yayından önce insan incelemesi" ve yanıt süresi sözü doğrulanmadığı için yazılmadı (D5, D9).
// Landing Header/Footer kullanılmaz: ana sayfa çapaları bu rotada kırılır (bkz. /yontem).

const EPOSTA = "info@hupolingo.com";

export const metadata: Metadata = {
  title: "Hakkımızda | Hupolingo",
  description:
    "Hupolingo, kısa soru görevleri ve dürüst veli raporuyla düzenli pratiği kolaylaştıran pilot aşamadaki bir eğitim girişimidir.",
};

export default async function HakkimizdaPage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);

  return (
    <div className={`${marketingFont.className} min-h-dvh bg-cream text-navy`}>
      <header className="border-b border-cream-dark bg-cream">
        <div className="mx-auto flex h-16 max-w-3xl items-center justify-between gap-4 px-4 sm:px-6">
          <Link href="/" className="inline-flex min-h-11 items-center text-xl font-extrabold tracking-tight">
            Hupolingo
          </Link>
          <Link
            href="/"
            className="inline-flex min-h-11 items-center text-sm font-semibold text-brand-700 underline-offset-2 hover:underline"
          >
            ← Ana sayfaya dön
          </Link>
        </div>
      </header>

      <main id="main" className="mx-auto max-w-3xl px-4 pb-16 pt-8 sm:px-6">
        <p className="text-sm font-extrabold uppercase tracking-wider text-brand-700">Hakkımızda</p>
        <h1 className="mt-2 text-balance text-3xl font-extrabold tracking-tight sm:text-4xl">Neden buradayız?</h1>

        <div className="mt-4 space-y-4 text-lg leading-relaxed text-gray-700">
          <p>
            Pek çok evde akşam aynı soruyla başlar: &ldquo;Bugün ne çalıştın?&rdquo; Cevap çoğu zaman belirsizdir.
            Çocuk çalışmıştır ama neyin oturduğu, neyin tekrar istediği görünmez.
          </p>
          <p>
            Hupolingo bu belirsizliği küçültmek için doğdu. Çocuğunuz kısa soru görevleri çözer, her cevaptan sonra adım
            adım açıklamayı görür. Yanlış yaptığı soru ertesi gün yeniden karşısına çıkar. Siz de veli panelinde hangi
            derste ne kadar çalışıldığını ve hangi konunun tekrar istediğini görürsünüz.
          </p>
        </div>

        <section aria-labelledby="hupo-baslik" className="mt-10">
          <h2 id="hupo-baslik" className="text-2xl font-extrabold tracking-tight">
            Hupo kim?
          </h2>
          <p className="mt-3 text-lg leading-relaxed text-gray-700">
            Hupo, çocuğunuzun çalışma arkadaşı. Çocuk görevlerde ona eşlik eder, siz de panelden sakin bir özet görürsünüz.
          </p>
        </section>

        <section aria-labelledby="calisma-baslik" className="mt-10">
          <h2 id="calisma-baslik" className="text-2xl font-extrabold tracking-tight">
            Nasıl çalışıyoruz?
          </h2>
          <p className="mt-3 text-lg leading-relaxed text-gray-700">
            Sorular sınıf kazanımlarına göre Hupo için hazırlanır. Az veriyle kesin hüküm vermeyiz. Öğrenci
            uygulamasında reklam varsayılan olarak kapalıdır. Süreç ve kaynaklar için{" "}
            <Link href="/yontem" className="font-semibold text-brand-700 underline underline-offset-2">
              Yöntem ve kaynaklar
            </Link>{" "}
            sayfasına bakabilirsiniz.
          </p>
        </section>

        <section
          aria-labelledby="soz-baslik"
          className="mt-10 rounded-2xl border border-gray-200 bg-white p-5 shadow-sm sm:p-6"
        >
          <h2 id="soz-baslik" className="text-2xl font-extrabold tracking-tight">
            Söz vermediklerimiz
          </h2>
          <p className="mt-3 text-base leading-relaxed text-gray-800">
            Sınav kazanma, puan artışı ya da okulun yerini alma. Söz verdiğimiz şey düzenli pratiği kolaylaştırmak ve
            ilerlemeyi dürüstçe göstermek. Hupolingo pilot sürümdedir.
          </p>
        </section>

        <section aria-labelledby="iletisim-baslik" id="iletisim" className="mt-10 scroll-mt-8">
          <h2 id="iletisim-baslik" className="text-2xl font-extrabold tracking-tight">
            Bize yazın
          </h2>
          <p className="mt-3 text-lg leading-relaxed text-gray-700">
            Sorunuz, öneriniz ya da bir soruda gördüğünüz hata için bize ulaşın.
          </p>
          <p className="mt-3 text-lg">
            E-posta:{" "}
            <a href={`mailto:${EPOSTA}`} className="font-semibold text-brand-700 underline underline-offset-2">
              {EPOSTA}
            </a>
          </p>
          <p className="mt-3 text-base leading-relaxed text-gray-700">
            Bir soruda hata gördüyseniz sorunun ekran görüntüsünü ve sınıf bilgisini gönderin. Lütfen çocuğunuzun adını,
            okulunu veya fotoğrafını mesaja eklemeyin. Hesapla ilgili konularda veli hesabınızın e-posta adresinden
            yazmanız yeterli.
          </p>
          <p className="mt-4 text-base text-gray-700">
            Bizi takip edin:{" "}
            <a
              href="https://www.instagram.com/hupolingo_app/"
              className="font-semibold text-brand-700 underline underline-offset-2"
            >
              Instagram
            </a>
            {" · "}
            <a
              href="https://www.youtube.com/@Hupolingo"
              className="font-semibold text-brand-700 underline underline-offset-2"
            >
              YouTube
            </a>
          </p>
        </section>
      </main>
    </div>
  );
}
