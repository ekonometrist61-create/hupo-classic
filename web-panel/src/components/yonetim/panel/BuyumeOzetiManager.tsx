import { Link } from "@/i18n/navigation";

type Durum = "hazir" | "dagitim" | "ekranYok";

const EKRANLAR: { ad: string; yol: string; not: string }[] = [
  { ad: "Growth Analitik", yol: "/yonetim/growth-analitik", not: "Huni, UTM, aktiflik" },
  { ad: "Reklam Harcaması", yol: "/yonetim/harcama", not: "Manuel harcama ve CAC" },
  { ad: "Elde Tutma", yol: "/yonetim/elde-tutma", not: "D1 / D7 / D30" },
  { ad: "Veri Kalitesi ve İzin", yol: "/yonetim/veri-kalitesi", not: "Kalite kontrolleri, kanal izni" },
  { ad: "Haftalık Rapor Taslakları", yol: "/yonetim/rapor-taslaklari", not: "İnceleme ve onay; gönderim yok" },
  { ad: "Öğrenme Analitiği (Toplu)", yol: "/yonetim/ogrenme-toplam", not: "Sınıf ve hikâye bazında" },
  { ad: "A/B Deneyleri", yol: "/yonetim/ab-deneyler", not: "Taslak, başlat, durdur, karar formu" },
];

const EKRANI_OLMAYAN = [
  "Python ajan çıktıları (yerelde dosya)",
  "İçerik kalite raporu (yerelde dosya)",
  "A/B analizi (scripts/ab-analiz, yerel Python)",
  "Customer-Lab kataloğu ve sentetik lab",
  "ML eşik ölçümü (admin_growth_ml_esik)",
];

const ACIK_IS: { is: string; durum: string; sonraki: string }[] = [
  { is: "Kartsız deneme akışı", durum: "Ürün ve hukuk onayı bekliyor", sonraki: "Karar: deneme_gun plan alanı; hukuk metni" },
  { is: "Sandbox ödeme testi", durum: "Yapılmadı", sonraki: "Kayıt → deneme → ödeme → dönüş senaryosu" },
  { is: "Referans ölçümü (30 gün)", durum: "Sayaç başlamadı", sonraki: "Tetikleyici: mağaza yayını + ilk gerçek indirmeler" },
  { is: "A varyantı ekranı", durum: "Metin taslağı bekliyor", sonraki: "Tasarım-büyüme ajanı taslağı → proje sahibi onayı" },
  { is: "Mobil olay entegrasyonu (BACKLOG-M1)", durum: "Ertelendi", sonraki: "Web deneyi doğrulanınca, planlı sürümle" },
];

const ROZET: Record<Durum, string> = {
  hazir: "bg-green-50 text-green-700 dark:bg-green-500/10 dark:text-green-400",
  dagitim: "bg-amber-50 text-amber-700 dark:bg-amber-500/10 dark:text-amber-400",
  ekranYok: "bg-gray-100 text-gray-600 dark:bg-white/5 dark:text-gray-400",
};

export default function BuyumeOzetiManager() {
  const kart = "rounded-xl border border-gray-100 p-4 dark:border-gray-800";
  return (
    <div className="space-y-6">
      <section className="rounded-xl border border-amber-200 bg-amber-50 p-4 text-sm text-amber-800 dark:border-amber-500/20 dark:bg-amber-500/10 dark:text-amber-300">
        Aşağıdaki ekranların hiçbiri tarayıcıda görsel olarak kontrol edilmedi. Her ekranı yönetici girişiyle
        açıp kontrol listesine göre doğrulayın: yükleniyor, boş, hata ve dolu durumu; küçük sayıların gizlenmesi.
      </section>

      <section>
        <h2 className="mb-3 text-base font-semibold text-gray-800 dark:text-white/90">Büyüme ekranları</h2>
        <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-3">
          {EKRANLAR.map((e) => (
            <Link key={e.yol} href={e.yol} className={`${kart} block hover:border-brand-300`}>
              <div className="flex items-start justify-between gap-2">
                <span className="font-medium text-gray-800 dark:text-white/90">{e.ad}</span>
                <span className={`rounded-full px-2 py-0.5 text-xs ${ROZET.dagitim}`}>görsel kontrol yok</span>
              </div>
              <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">{e.not}</p>
            </Link>
          ))}
        </div>
      </section>

      <section className={kart}>
        <h2 className="mb-2 text-base font-semibold text-gray-800 dark:text-white/90">Panelde ekranı olmayanlar</h2>
        <ul className="space-y-1 text-sm text-gray-600 dark:text-gray-300">
          {EKRANI_OLMAYAN.map((x) => (
            <li key={x} className="flex items-center gap-2">
              <span className={`rounded-full px-2 py-0.5 text-xs ${ROZET.ekranYok}`}>ekran yok</span>
              {x}
            </li>
          ))}
        </ul>
      </section>

      <section className={kart}>
        <h2 className="mb-2 text-base font-semibold text-gray-800 dark:text-white/90">Açık işler</h2>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="border-b border-gray-100 dark:border-gray-800">
              <tr className="text-gray-500 dark:text-gray-400">
                <th className="py-2 pr-4">İş</th>
                <th className="py-2 pr-4">Durum</th>
                <th className="py-2">Sonraki adım</th>
              </tr>
            </thead>
            <tbody className="text-gray-700 dark:text-gray-300">
              {ACIK_IS.map((a) => (
                <tr key={a.is} className="border-b border-gray-50 dark:border-gray-800/50">
                  <td className="py-2 pr-4 font-medium">{a.is}</td>
                  <td className="py-2 pr-4">{a.durum}</td>
                  <td className="py-2">{a.sonraki}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <p className="mt-3 text-xs text-gray-500 dark:text-gray-400">
          Kaynak: docs/growth-crm/GIE_ANALIZ_VE_IS_PLANI_2026-10-28.md §34.
        </p>
      </section>
    </div>
  );
}
