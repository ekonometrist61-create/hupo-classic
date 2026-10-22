import { IconBook, IconChart, IconHeart } from "@/components/landing/Icons";

// Veli odaklı tek bileşen. Ölçülebilir iddia yok: puan, sınav, sıralama veya yüzde yazılmaz.
// Ana sayfaya bu aşamada eklenmez; yalnız /okuma-demo altında kullanılır (yayın kapısı: pilot bitişi + hukuk onayı).
const MADDELER = [
  {
    Ikon: IconHeart,
    baslik: "Maarif değerleri",
    metin:
      "Her hikâye Maarif Modeli değerlerinden birini merkeze alır. Değer öğüt olarak değil, olayların içinde anlatılır.",
  },
  {
    Ikon: IconBook,
    baslik: "Sınıfa uygun kelime",
    metin:
      "Hikâyelerdeki hedef sözcük ve deyimler, çocuğun sınıf düzeyine göre seçilir.",
  },
  {
    Ikon: IconChart,
    baslik: "Açıklanabilir veli özeti",
    metin:
      "Veli özeti hangi sözcüklerle tanışıldığını, hangi soru türlerinde zorlanıldığını ve bu sonuçların neye dayandığını açıklar.",
  },
] as const;

export function VeliOkumaBolumu() {
  return (
    <section aria-labelledby="veli-okuma-baslik" className="space-y-6">
      <div className="space-y-3">
        <h2 id="veli-okuma-baslik" className="text-2xl font-extrabold tracking-tight sm:text-3xl">
          Çocuğun kahramanı olduğu hikâyeler
        </h2>
        <p className="leading-relaxed text-navy-muted dark:text-gray-300">
          Çocuğunuz kendi adıyla yer aldığı kısa hikâyeleri okur ve sonunda birkaç soruyu yanıtlar. Siz de neyi
          okuduğunu ve hangi soru türlerinde desteğe ihtiyaç duyduğunu görürsünüz.
        </p>
      </div>

      <ul className="grid gap-4">
        {MADDELER.map(({ Ikon, baslik, metin }) => (
          <li
            key={baslik}
            className="flex gap-4 rounded-2xl border border-cream-dark bg-white p-5 dark:border-gray-700 dark:bg-gray-800"
          >
            <span
              aria-hidden="true"
              className="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-brand-50 text-brand-600 dark:bg-gray-700 dark:text-brand-300"
            >
              <Ikon className="h-6 w-6" />
            </span>
            <div className="min-w-0">
              <h3 className="text-lg font-extrabold">{baslik}</h3>
              <p className="mt-1 leading-relaxed text-navy-muted dark:text-gray-300">{metin}</p>
            </div>
          </li>
        ))}
      </ul>

      <p className="text-sm leading-relaxed text-navy-muted dark:text-gray-400">
        Hupolingo bir sınav garantisi değildir. Milli Eğitim Bakanlığı tarafından onaylanmış bir yayın değildir.
      </p>
    </section>
  );
}
