/**
 * Mobil ve tablet uyum sınıfları (TASKS §20). Yönetim ekranları bu sabitleri kullanır ki
 * dokunma hedefi, sabit ilk sütun ve kart/tablo ayrımı her yerde aynı kurala uysun.
 */

/** Dokunma hedefi: en az 44 px yükseklik (R2). Metin düğmeleri ve bağlantılar için. */
export const dokunmaHedefi = "inline-flex min-h-11 items-center";

/** Yatay kaydırılan tabloda sabit ilk sütun (gövde hücresi). Sayfa kaymaz, etiket görünür kalır. */
export const yapiskanHucre = "sticky start-0 z-[1] bg-white dark:bg-gray-900";

/** Sabit ilk sütun (başlık hücresi). */
export const yapiskanBaslik = "sticky start-0 z-[2] bg-[#f8fafb] dark:bg-gray-900";

/** Kart görünümü: yalnızca 768 px altında gösterilir. */
export const mobilKart = "space-y-3 md:hidden";

/** Tablo görünümü: 768 px ve üzerinde; kendi kapsayıcısında kayar. */
export const masaustuTablo = "hidden overflow-x-auto md:block";
