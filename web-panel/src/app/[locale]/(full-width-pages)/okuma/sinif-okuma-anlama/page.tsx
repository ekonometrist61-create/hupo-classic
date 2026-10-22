import { marketingFont } from "@/components/landing/marketingFont";
import { OkumaSiteUst } from "@/components/okuma-site/OkumaSiteUst";
import type { Metadata } from "next";
import Link from "next/link";

// Yayın kapısı: navigasyona, sitemap'e veya canonical'a eklenmez. Pilot bitişi ve hukuk onayı sonrası
// kararla birlikte noindex kaldırılır. İçerikteki süreç cümleleri yayın anında gerçekten uygulanmış olmalıdır.
export const metadata: Metadata = {
  title: "Sınıfa göre okuduğunu anlama · Hupolingo",
  description:
    "Okuduğunu anlama nedir, sınıf düzeyine göre nasıl değişir ve Hupolingo hikâyeleri nasıl hazırlanır? Veliler için açıklama.",
  robots: { index: false, follow: false },
};

const BILESENLER = [
  {
    baslik: "Açık bilgiyi bulma",
    metin: "Metinde doğrudan yazan bir bilgiyi bulmak: kim, nerede, ne zaman, ne oldu.",
  },
  {
    baslik: "Çıkarım",
    metin: "Metinde yazmayan ama ipuçlarından anlaşılan bir sonucu kurmak.",
  },
  {
    baslik: "Sözcük anlamı",
    metin: "Bilinmeyen bir sözcüğün, geçtiği cümlelerdeki anlamını tahmin edip doğrulamak.",
  },
  {
    baslik: "Yorumlama",
    metin: "Bir karakterin davranışını ya da metnin mesajını açıklamak.",
  },
  {
    baslik: "Değerlendirme",
    metin: "Bir görüşü metindeki kanıtlarla gerekçelendirmek.",
  },
];

const SINIF_BANTLARI = [
  {
    bant: "2. sınıf",
    metin: "Kısa ve tek olaylı metinler. Olay sırasını ve açık bilgiyi bulmak; yeni sözcüğü çevresindeki cümlelerden anlamak.",
  },
  {
    bant: "4. ve 5. sınıf",
    metin: "Neden–sonuç ilişkisi, ana fikir ve metinde geçen kavramları birbiriyle ilişkilendirmek.",
  },
  {
    bant: "6. ile 8. sınıf",
    metin: "Çıkarım ve yorum; karakter ve metnin mesajı üzerine düşünmek; bir görüşü kanıtla gerekçelendirmek.",
  },
];

export default function SinifOkumaAnlamaPage() {
  return (
    <div className={`${marketingFont.className} min-h-screen bg-cream text-navy dark:bg-gray-950 dark:text-gray-100`}>
      <OkumaSiteUst />

      <main id="main" className="mx-auto max-w-2xl space-y-14 px-4 py-8 sm:px-6 sm:py-12">
        <article className="space-y-12">
          <header className="space-y-4">
            <h1 className="text-3xl font-extrabold leading-tight tracking-tight sm:text-4xl">
              Sınıfa göre okuduğunu anlama
            </h1>
            <p className="text-lg leading-relaxed text-navy-muted dark:text-gray-300">
              Okuduğunu anlama; bir metinde yazanı bulmak, yazılmayanı ipuçlarından çıkarmak ve sözcüklerin bağlamdaki
              anlamını kavramaktır. Hızlı okumaktan çok, okunanı doğru kurmakla ilgilidir. Bu sayfada becerinin ne
              olduğunu, sınıf düzeyine göre nasıl değiştiğini ve Hupolingo hikâyelerinin nasıl hazırlandığını anlatıyoruz.
            </p>
          </header>

          <section aria-labelledby="bilesenler" className="space-y-4">
            <h2 id="bilesenler" className="text-2xl font-extrabold tracking-tight">
              Okuduğunu anlamanın bileşenleri
            </h2>
            <ul className="grid gap-3">
              {BILESENLER.map((b) => (
                <li
                  key={b.baslik}
                  className="rounded-2xl border border-cream-dark bg-white p-4 dark:border-gray-700 dark:bg-gray-800"
                >
                  <h3 className="font-extrabold">{b.baslik}</h3>
                  <p className="mt-1 leading-relaxed text-navy-muted dark:text-gray-300">{b.metin}</p>
                </li>
              ))}
            </ul>
          </section>

          <section aria-labelledby="sinif-duzeyi" className="space-y-4">
            <h2 id="sinif-duzeyi" className="text-2xl font-extrabold tracking-tight">
              Sınıf düzeyine göre ne değişir?
            </h2>
            <p className="leading-relaxed text-navy-muted dark:text-gray-300">
              Beklenti sınıfla birlikte artar, ancak her çocuğun okuma hızı farklıdır. Aşağıdaki bantlar bir yön gösterir;
              kesin bir kazanım listesi değildir.
            </p>
            <dl className="grid gap-3">
              {SINIF_BANTLARI.map((s) => (
                <div
                  key={s.bant}
                  className="rounded-2xl border border-cream-dark bg-white p-4 dark:border-gray-700 dark:bg-gray-800"
                >
                  <dt className="font-extrabold">{s.bant}</dt>
                  <dd className="mt-1 leading-relaxed text-navy-muted dark:text-gray-300">{s.metin}</dd>
                </div>
              ))}
            </dl>
          </section>

          <section aria-labelledby="nasil-calisir" className="space-y-4">
            <h2 id="nasil-calisir" className="text-2xl font-extrabold tracking-tight">
              Hupolingo’da okuma nasıl ilerler?
            </h2>
            <ol className="list-decimal space-y-3 ps-6 leading-relaxed">
              <li>Hikâye kısa sayfalara bölünür. Çocuk sayfaları kendi hızında çevirir.</li>
              <li>Hikâye bitince birkaç anlama sorusu gelir. Her sorunun hangi sayfaya dayandığı gösterilir.</li>
              <li>Cevaptan sonra kısa bir açıklama görünür.</li>
              <li>
                Veli panelinde çocuğun okuduğu hikâyeler ve soru türlerindeki durumu görülür. Bu bilgi bir puan ya da
                sınav tahmini değildir.
              </li>
            </ol>
          </section>

          <section aria-labelledby="hazirlama" className="space-y-4">
            <h2 id="hazirlama" className="text-2xl font-extrabold tracking-tight">
              Hikâyeler nasıl hazırlanır?
            </h2>
            <ul className="list-disc space-y-3 ps-6 leading-relaxed">
              <li>Her hikâyenin sınıf düzeyi ve hedef sözcük listesi önceden belirlenir.</li>
              <li>
                Maarif Modeli değerlerinden biri hikâyenin merkezindedir. Değer olayın içinden okunur, öğüt olarak
                yazılmaz.
              </li>
              <li>Sorular metnin kendisine dayanır; metin dışı bilgi gerektirmez.</li>
              <li>
                Hikâye yayınlanmadan önce üç onay tamamlanır: iki ayrı yapay zekâ denetimi ve bir insan okuması.
                Bu onaylar olmadan hikâye yayına alınmaz.
              </li>
              <li>
                Kamu malı bir kaynaktan uyarlanan hikâyelerde kaynak kaydı tutulur ve metin sıfırdan anlatılır.
              </li>
            </ul>
          </section>

          <section aria-labelledby="vaat" className="space-y-4">
            <h2 id="vaat" className="text-2xl font-extrabold tracking-tight">
              Bu sayfa neyi vaat etmez?
            </h2>
            <ul className="list-disc space-y-3 ps-6 leading-relaxed">
              <li>Hupolingo bir okul ya da sınav hazırlık kursu değildir; sınav sonucu ya da puan artışı garantisi vermez.</li>
              <li>Hupolingo, Milli Eğitim Bakanlığı tarafından onaylanmış bir yayın değildir.</li>
              <li>Okuma becerisi düzenli pratikle gelişir; kısa sürede kesin bir sonuç beklenmemelidir.</li>
            </ul>
          </section>
        </article>

        <section
          aria-labelledby="dene"
          className="space-y-4 rounded-2xl border border-cream-dark bg-white p-6 dark:border-gray-700 dark:bg-gray-800"
        >
          <h2 id="dene" className="text-xl font-extrabold">
            Örnek hikâyeyi deneyin
          </h2>
          <p className="leading-relaxed text-navy-muted dark:text-gray-300">
            Kayıt gerekmez. Sayfaları okuyabilir, soruları çözebilirsiniz; cevaplarınız kaydedilmez.
          </p>
          <Link
            href="/okuma-demo"
            className="inline-flex min-h-12 items-center justify-center rounded-xl bg-brand-500 px-6 text-base font-extrabold text-white transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none"
          >
            Örnek hikâyeyi aç
          </Link>
        </section>
      </main>
    </div>
  );
}
