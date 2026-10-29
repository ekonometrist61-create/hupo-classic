// İlk temas UTM'si: oturum kapsamlı, çerezsiz, rıza kapılı. Kişisel veri yok.
// Kural:
//  - URL'deki UTM yalnızca bellekte (modül değişkeni) tutulur; rıza öncesi hiçbir depoya yazılmaz.
//  - Analitik çerezine "Kabul et" denmişse oturum deposuna (sessionStorage) yazılır ve oradan okunur;
//    sekme kapanınca silinir. Oturum içinde ilk değer korunur (ilk temas).
//  - Yalnızca 4 alan (utm_term kullanılmaz) ve güvenli karakter kümesindeki değerler kabul edilir.
// Karar: docs/hupo-design-growth/decisions.md "Kanal ölçümü (2026-10-29)".
import { readAnalyticsConsent } from "./consent";

export const UTM_ANAHTARLARI = ["utm_source", "utm_medium", "utm_campaign", "utm_content"] as const;
export const UTM_OTURUM_KEY = "hupo_utm_oturum";
// Harf, rakam, nokta, alt çizgi, tilde, tire. Boşluk, @, e-posta, URL ve serbest metin reddedilir.
const DEGER_RE = /^[A-Za-z0-9._~-]{1,100}$/;

export type UtmOzellikleri = Partial<Record<(typeof UTM_ANAHTARLARI)[number], string>>;

let bellek: UtmOzellikleri = {};

// Saf fonksiyon: arama dizesinden izinli UTM alanlarını ayıklar.
export function utmAyristir(arama: string): UtmOzellikleri {
  const sonuc: UtmOzellikleri = {};
  try {
    const params = new URLSearchParams(arama);
    for (const k of UTM_ANAHTARLARI) {
      const v = params.get(k)?.trim();
      if (v && DEGER_RE.test(v)) sonuc[k] = v;
    }
  } catch {
    // Bozuk arama dizesi: boş sonuç.
  }
  return sonuc;
}

// Sayfa açılışında çağrılır (rızadan bağımsız; yalnız bellek). İlk temas bellekte korunur.
export function utmYakala(): void {
  try {
    if (Object.keys(bellek).length > 0) return;
    const bulunan = utmAyristir(window.location.search);
    if (Object.keys(bulunan).length > 0) bellek = bulunan;
  } catch {
    // window yoksa (sunucu) sessizce geç.
  }
}

// Saf fonksiyon: bilinmeyen bir değerden izinli UTM alanlarını ayıklar (kayıt metadata'sı için).
export function utmDogrula(ham: unknown): UtmOzellikleri {
  const sonuc: UtmOzellikleri = {};
  if (!ham || typeof ham !== "object") return sonuc;
  for (const k of UTM_ANAHTARLARI) {
    const v = (ham as Record<string, unknown>)[k];
    if (typeof v === "string" && DEGER_RE.test(v)) sonuc[k] = v;
  }
  return sonuc;
}

function oturumOku(): UtmOzellikleri {
  try {
    const ham = window.sessionStorage.getItem(UTM_OTURUM_KEY);
    if (!ham) return {};
    const parsed = JSON.parse(ham) as Record<string, unknown>;
    const sonuc: UtmOzellikleri = {};
    for (const k of UTM_ANAHTARLARI) {
      const v = parsed[k];
      if (typeof v === "string" && DEGER_RE.test(v)) sonuc[k] = v;
    }
    return sonuc;
  } catch {
    return {};
  }
}

// Olaylara eklenecek UTM özellikleri. Rıza yoksa boş nesne döner ve hiçbir şey yazılmaz.
export function utmOzellikleri(): UtmOzellikleri {
  if (readAnalyticsConsent() !== "granted") return {};
  const kayitli = oturumOku();
  if (Object.keys(kayitli).length > 0) return kayitli;
  utmYakala();
  if (Object.keys(bellek).length === 0) return {};
  try {
    window.sessionStorage.setItem(UTM_OTURUM_KEY, JSON.stringify(bellek));
  } catch {
    // Depo kapalıysa bellekteki değer yine kullanılır.
  }
  return { ...bellek };
}

// Yalnız test için.
export function utmBelleginiSifirla(): void {
  bellek = {};
}
