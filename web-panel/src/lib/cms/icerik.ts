// Site metinlerinin CMS (site_icerik) katmanı — saf mantık.
// İstemci ve sunucu tarafında ortak kullanılır; bu dosyada sunucu/istemci bağımlılığı yoktur.
//
// Kural: JSON mesaj dosyaları (messages/*.json) yedektir. site_icerik'te bir satır
// varsa, o anahtarın metni onunla değiştirilir. Satır yoksa JSON metni kullanılır.

export type MesajNesnesi = Record<string, unknown>;

export type IcerikSatiri = { anahtar: string; dil: string; deger: string };

/** Bir metin yaprağı: noktalı anahtar + JSON'daki varsayılan metin. */
export type MetinYaprak = { anahtar: string; varsayilan: string };

/**
 * CMS'in yönettiği ad alanları: herkese açık web sitesi, giriş/kayıt ekranları,
 * yasal sayfalar ve veli paneli. Yönetim paneli (`yonetim`) metinleri bilerek dışarıda —
 * admin arayüzü kendi metinlerini düzenlemeye devam eder; bozuk bir metin yönetim ekranını kilitlemesin.
 */
export const CMS_AD_ALANLARI = [
  "landing",
  "meta",
  "gorseller",
  "signin",
  "signup",
  "forgot",
  "reset",
  "unsubscribe",
  "cookie",
  "welcome",
  "anket",
  "notFound",
  "common",
  "demo",
  "adminSignin",
  "veliPaneli",
  "denemeSonuclari",
] as const;

export function adAlaniDeMi(anahtar: string): boolean {
  const ad = anahtar.split(".")[0];
  return (CMS_AD_ALANLARI as readonly string[]).includes(ad);
}

/** Yönetim ekranında kaydedilebilir en uzun metin (tablo CHECK sınırıyla aynı). */
export const METIN_MAKS_UZUNLUK = 5000;

function nesneMi(v: unknown): v is Record<string, unknown> {
  return typeof v === "object" && v !== null && !Array.isArray(v);
}

/** Bir düğümün çocuğunu anahtar parçasıyla bulur. Dizide sayısal indeks, nesnede yalnızca kendi özelliği. */
function cocuk(dugum: unknown, parca: string): unknown {
  if (Array.isArray(dugum)) {
    if (!/^\d+$/.test(parca)) return undefined;
    return dugum[Number(parca)];
  }
  if (nesneMi(dugum) && Object.prototype.hasOwnProperty.call(dugum, parca)) {
    return dugum[parca];
  }
  return undefined;
}

/** Mesaj ağacındaki tüm metin yapraklarını noktalı anahtarla listeler (dizi indeksi sayı olarak). */
export function metinYapraklari(kok: MesajNesnesi): MetinYaprak[] {
  const sonuc: MetinYaprak[] = [];
  const gez = (dugum: unknown, yol: string) => {
    if (typeof dugum === "string") {
      sonuc.push({ anahtar: yol, varsayilan: dugum });
      return;
    }
    if (Array.isArray(dugum)) {
      dugum.forEach((v, i) => gez(v, yol ? `${yol}.${i}` : String(i)));
      return;
    }
    if (nesneMi(dugum)) {
      for (const [k, v] of Object.entries(dugum)) gez(v, yol ? `${yol}.${k}` : k);
    }
  };
  gez(kok, "");
  return sonuc;
}

/**
 * Temel mesajların bir kopyasına, verilen dil için CMS satırlarını uygular.
 * - Yalnızca CMS ad alanındaki anahtarlar değişir.
 * - Yalnızca temelde var olan metin yaprakları değişir; CMS'ten yeni yapı üretilmez.
 * - Boş metin uygulanmaz (yanlışlıkla boşaltılan alan sayfayı boş bırakmasın).
 * Temel nesne değiştirilmez.
 */
export function icerikUygula(
  temel: MesajNesnesi,
  satirlar: IcerikSatiri[],
  dil: string,
): MesajNesnesi {
  if (satirlar.length === 0) return temel;
  const kopya = structuredClone(temel);

  for (const satir of satirlar) {
    if (satir.dil !== dil) continue;
    if (!adAlaniDeMi(satir.anahtar)) continue;
    if (satir.deger.trim() === "") continue;

    const parcalar = satir.anahtar.split(".");
    const sonParca = parcalar.pop();
    if (sonParca === undefined) continue;

    let ebeveyn: unknown = kopya;
    for (const parca of parcalar) {
      ebeveyn = cocuk(ebeveyn, parca);
      if (ebeveyn === undefined) break;
    }
    if (ebeveyn === undefined) continue;
    if (typeof cocuk(ebeveyn, sonParca) !== "string") continue;

    if (Array.isArray(ebeveyn)) {
      ebeveyn[Number(sonParca)] = satir.deger;
    } else if (nesneMi(ebeveyn)) {
      ebeveyn[sonParca] = satir.deger;
    }
  }

  return kopya;
}
