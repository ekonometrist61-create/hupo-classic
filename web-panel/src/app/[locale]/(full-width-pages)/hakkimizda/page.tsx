import { marketingFont } from "@/components/landing/marketingFont";
import { Link } from "@/i18n/navigation";
import type { Metadata } from "next";
import { setRequestLocale } from "next-intl/server";

// Hakkımızda: kurucu hikâyesi ve Hupolingo'nun neden var olduğu. Metin proje sahibi tarafından verildi; değiştirirken
// doğrulanmamış sayı, sınav ya da kazanım iddiası eklenmez.
// Landing Header/Footer kullanılmaz: ana sayfa çapaları bu rotada kırılır (bkz. /yontem).

const EPOSTA = "info@hupolingo.com";

export const metadata: Metadata = {
  title: "Hakkımızda | Hupolingo",
  description:
    "Hupolingo'nun neden doğduğu: çocukların öğrenmeyi oyun kadar heyecanlı bulabilmesi için kurulan, pilot aşamadaki bir eğitim girişimi.",
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
        <h1 className="mt-2 text-balance text-3xl font-extrabold leading-tight tracking-tight sm:text-4xl">
          Bir babanın sorduğu soruyla başladı: Öğrenmek neden oyun kadar heyecan verici olmasın?
        </h1>

        <article className="mt-8 space-y-5 text-lg leading-relaxed text-gray-700">
          <p>Çocuklarımın oyun oynarken gösterdiği heyecanı, sabrı ve kararlılığı hep hayranlıkla izledim.</p>
          <p>
            Brawl Stars&apos;ta yeni bir karakter kazanmak, Minecraft&apos;ta yeni bir dünya kurmak, Duolingo&apos;da bir
            sonraki seviyeye ulaşmak için tekrar tekrar deniyor, zorlanıyor ama kolay kolay vazgeçmiyorlardı.
          </p>
          <p>Peki aynı çocuklar neden ders çalışırken bu kadar çabuk sıkılıyordu?</p>
          <p>
            Bir süre sonra fark ettim ki oyunlarda onları motive eden pek çok şey, geleneksel ders çalışma deneyiminde
            yeterince yoktu.
          </p>
          <p>
            <strong className="font-extrabold text-navy">Oyunlarda her çabanın bir karşılığı vardı.</strong> Bir puan,
            yeni bir seviye, kazanılan bir karakter, tamamlanan bir görev… Çocuklar ilerlediklerini görüyor, başardıklarını
            hissediyor, kazandıklarını arkadaşlarıyla ve aileleriyle heyecanla paylaşıyorlardı.
          </p>
          <p>
            Oysa ders çalışırken aynı ilerleme çoğu zaman görünmez kalıyordu. Öğrenilen yeni bir kelime, çözülen zor bir
            problem veya anlaşılan bir konu, oyundaki kadar hızlı ve somut bir başarı hissine dönüşmüyordu.
          </p>
          <p>Kendime şu soruyu sordum:</p>
          <p className="rounded-2xl border border-cream-dark bg-white p-5 font-bold text-navy shadow-sm">
            “Çocuklar oyunlarda bu kadar istekle öğreniyor, deniyor ve gelişiyorsa, ders çalışmak da aynı heyecanı
            yaşatamaz mı?”
          </p>
          <p>İşte Hupolingo fikri böyle doğdu.</p>
        </article>

        <section aria-labelledby="gercek-ogrenme" className="mt-12 space-y-5 text-lg leading-relaxed text-gray-700">
          <h2 id="gercek-ogrenme" className="text-2xl font-extrabold tracking-tight text-navy">
            Sadece oyunlaştırmak değil, gerçekten öğrenmelerini sağlamak
          </h2>
          <p>
            Amacım çocukların daha fazla ekran başında kalması değildi. Ekran karşısında geçirdikleri zamanı daha
            anlamlı, verimli ve öğretici hâle getirmekti.
          </p>
          <p>Üstelik çocuklarımın bazı konularda özel olarak desteğe ihtiyaç duyduğunu da görüyordum.</p>
          <p>
            Çarpım tablosu, eş ve zıt anlamlı kelimeler, eş sesli sözcükler, deyimler, atasözleri… Bunları tekrar etmek
            gerekiyordu ama tekrarın kendisi çoğu zaman sıkıcıydı.
          </p>
          <p>
            Peki tekrarlar küçük görevlere, meydan okumalara ve keşiflere dönüşseydi? Çocuklar zorlandıkları konuları
            çalışırken bir yandan da seviyelerini yükselttiklerini, yeni başarılar kazandıklarını hissedebilselerdi?
          </p>
          <p>
            Bir diğer ihtiyacımız da ilkokuldan ortaokula geçiş süreciydi. Özellikle 4. sınıftan 5. sınıfa geçerken proje
            okullarına hazırlık için hem nitelikli bir kaynağımız olsun hem de çocuklar bu kaynağı severek kullansın istedim.
          </p>
          <p>Sonra okuma alışkanlığını düşündüm.</p>
          <p>
            Belki de çocukların bazı hikâyeleri okumak istememesinin nedeni okumayı sevmemeleri değildi. Belki hikâyenin
            konusu ilgilerini çekmiyor, kahramanıyla bağ kuramıyor, anlatım onları içine alamıyordu.
          </p>
          <p>
            <strong className="font-extrabold text-navy">
              Ya okuyacakları hikâyenin kahramanını, dünyasını ve konusunu kendileri seçebilseydi?
            </strong>{" "}
            Ya karşılarına yalnızca okunması gereken bir metin değil, merakla sonunu öğrenmek isteyecekleri bir macera
            çıksaydı?
          </p>
          <p>Böylece Hupolingo&apos;nun dünyası genişlemeye başladı.</p>
          <p>
            Oyunlaştırılmış derslerden kişisel gelişim yolculuğuna, zorlanılan konuların tekrarından ilgi alanlarına uygun
            hikâyelere kadar bütün parçalar aynı amaç etrafında birleşti:
          </p>
          <p className="rounded-2xl border border-gold-300 bg-gold-50 p-5 font-extrabold text-navy">
            Çocukların öğrenmeyi bir zorunluluk olarak değil, isteyerek katıldıkları bir keşif yolculuğu olarak görmelerine
            yardımcı olmak.
          </p>
        </section>

        <section aria-labelledby="aileler" className="mt-12 space-y-5 text-lg leading-relaxed text-gray-700">
          <h2 id="aileler" className="text-2xl font-extrabold tracking-tight text-navy">
            Bir ailede başlayan fikir, bütün ailelere açık bir öğrenme yolculuğu
          </h2>
          <p>Biliyorum ki evimizde yaşadığımız bu deneyimler yalnızca bize özgü değil.</p>
          <p>
            Çocuğunun ders çalışmasını sürekli hatırlatmak istemeyen, onun kendi isteğiyle öğrenmesini arzulayan, zorlandığı
            konuları fark edip desteklemek isteyen, kitaplarla daha güçlü bağ kurmasını hayal eden pek çok anne baba var.
          </p>
          <p>Hupolingo&apos;yu bu aileler için geliştiriyoruz.</p>
          <p>
            Çocukların çabalarının karşılığını görebildikleri, küçük başarılarını kutlayabildikleri, eksiklerini
            tamamlayabildikleri ve öğrenirken eğlenebildikleri bir dünya oluşturmak istiyoruz.
          </p>
          <p>
            Çünkü bizim için başarı, yalnızca doğru cevaplanan soruların sayısı değil.
          </p>
          <p className="text-xl font-extrabold leading-snug text-navy">
            Bir çocuğun “Yapamıyorum.” dediği bir konuda, bir gün gülümseyerek “Artık yapabiliyorum!” diyebilmesidir.
          </p>
          <p>Hupolingo, işte o gülümsemeye giden yolculuğun arkadaşı olmak için var.</p>
        </section>

        <section
          aria-labelledby="iletisim-baslik"
          id="iletisim"
          className="mt-12 scroll-mt-8 rounded-2xl border border-gray-200 bg-white p-5 shadow-sm sm:p-6"
        >
          <h2 id="iletisim-baslik" className="text-2xl font-extrabold tracking-tight text-navy">
            Bize yazın
          </h2>
          <p className="mt-3 text-base leading-relaxed text-gray-700">
            Sorunuz, öneriniz ya da bir soruda gördüğünüz hata için bize ulaşın. Hupolingo pilot sürümdedir.
          </p>
          <p className="mt-3 text-base">
            E-posta:{" "}
            <a href={`mailto:${EPOSTA}`} className="font-semibold text-brand-700 underline underline-offset-2">
              {EPOSTA}
            </a>
          </p>
          <p className="mt-3 text-sm leading-relaxed text-gray-700">
            Bir soruda hata gördüyseniz sorunun ekran görüntüsünü ve sınıf bilgisini gönderin. Lütfen çocuğunuzun adını,
            okulunu veya fotoğrafını mesaja eklemeyin.
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
