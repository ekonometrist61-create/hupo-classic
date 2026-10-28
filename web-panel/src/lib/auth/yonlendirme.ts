// Giriş sonrası `next` yönlendirmesini doğrular. Saf fonksiyon: tarayıcıda ve testte aynı çalışır.
// Kural: yalnızca aynı sitedeki, kapının kendi alanındaki bir yol kabul edilir; diğer her durumda
// varsayılan (kapının ana sayfası) kullanılır. Açık yönlendirme (https://, //, /\, javascript:) reddedilir.

const TEHLIKELI_KARAKTER = /[\u0000-\u001f\u007f\s\\]/;
// Kodlanmış eğik çizgi, nokta ve ters eğik çizgi: "/%2F%2Fevil", "/veli-paneli%2F..%2Fyonetim".
const KODLANMIS_TEHLIKE = /%(2e|2f|5c)/i;
const MAKS_UZUNLUK = 512;
const TEMEL = "https://panel.invalid";

// Giriş kapılarının kendi sayfaları; buralara dönmek döngü yaratır.
const GIRIS_YOLLARI = new Set(["/veli-paneli/giris", "/veli-paneli/kayit", "/yonetim-giris"]);

/**
 * @param aday        URL'den gelen `next` değeri (ham)
 * @param izinliOnekler kapının alanı, örn. ["/veli-paneli"]
 * @param varsayilan   doğrulanamayan her durumda kullanılan yol
 */
export function guvenliYonlendirme(
  aday: string | null | undefined,
  izinliOnekler: readonly string[],
  varsayilan: string,
): string {
  if (!aday || aday.length > MAKS_UZUNLUK) return varsayilan;
  // Tek eğik çizgi ile başlamalı; "//" protokolden bağımsız (dış site) adrestir.
  if (!aday.startsWith("/") || aday.startsWith("//")) return varsayilan;
  // Tarayıcılar tab/yeni satırı atar ("/\t/evil" -> "//evil"); kontrol karakterleri ve ters eğik çizgi yasak.
  if (TEHLIKELI_KARAKTER.test(aday) || KODLANMIS_TEHLIKE.test(aday)) return varsayilan;

  const yol = aday.split(/[?#]/)[0];
  if (GIRIS_YOLLARI.has(yol)) return varsayilan;
  const alanda = izinliOnekler.some((onek) => yol === onek || yol.startsWith(`${onek}/`));
  if (!alanda) return varsayilan;

  // Tarayıcının çözdüğü yol, bizim gördüğümüzle aynı olmalı (".." ve kodlanmış noktalar yakalanır).
  try {
    const cozulen = new URL(aday, TEMEL);
    if (cozulen.origin !== TEMEL || cozulen.pathname !== yol) return varsayilan;
  } catch {
    return varsayilan;
  }
  return aday;
}
