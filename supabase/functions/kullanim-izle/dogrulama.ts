// kullanim-izle: istek gövdesi doğrulaması. Saf fonksiyonlar: ağ, veritabanı ve ortam değişkeni yok.
// Sınırlar 20261066000000_kullanim_suresi.sql ile aynıdır; RPC yine de kendi kontrolünü yapar.

export const YUZEYLER: readonly string[] = ["mobil", "flutter_web", "site", "yonetim", "veli", "ogretmen"];
export const ROLLER: readonly string[] = ["ogrenci", "veli", "ogretmen", "admin", "ziyaretci"];
export const EN_COK_OLAY = 50;
export const EN_COK_GOVDE_BAYT = 32 * 1024;
export const EN_UZUN_SURE_SN = 14400;
export const EKRAN_EN_UZUN = 60;

const EKRAN_DESENI = /^[A-Za-z0-9_/.:[\]-]+$/;
const OTURUM_DESENI = /^[A-Za-z0-9_-]{16,64}$/;
// Çevrimdışı kuyruk için geçmiş toleransı 2 gün; saat kayması için gelecek toleransı 5 dk.
const GECMIS_TOLERANS_MS = 2 * 24 * 60 * 60 * 1000;
const GELECEK_TOLERANS_MS = 5 * 60 * 1000;

export type KullanimOlayi = {
  yuzey: string;
  ekran: string;
  sure_sn: number;
  baslangic: string;
  oturum_anahtari: string;
  rol: string;
};

export type DogrulamaSonucu = { ok: true; olaylar: KullanimOlayi[] } | { ok: false; hata: string };

/** Gövde boyutu (bayt) sınırın içinde mi. */
export function govdeBoyutuUygun(bayt: number): boolean {
  return Number.isInteger(bayt) && bayt >= 0 && bayt <= EN_COK_GOVDE_BAYT;
}

/**
 * { olaylar: [...] } biçimindeki gövdeyi doğrular. Bilinmeyen alanlar atılır; baslangic ISO 8601 UTC'ye çevrilir.
 * simdiMs: karşılaştırma için şu anki zaman (ms). Test edilebilirlik için dışarıdan verilir.
 */
export function olaylariDogrula(govde: unknown, simdiMs: number): DogrulamaSonucu {
  if (typeof govde !== "object" || govde === null || Array.isArray(govde)) {
    return { ok: false, hata: "Gövde nesne olmalı" };
  }
  const dizi = (govde as Record<string, unknown>).olaylar;
  if (!Array.isArray(dizi)) return { ok: false, hata: "olaylar dizi olmalı" };
  if (dizi.length > EN_COK_OLAY) return { ok: false, hata: `Çağrı başına en çok ${EN_COK_OLAY} olay` };

  const olaylar: KullanimOlayi[] = [];
  for (let i = 0; i < dizi.length; i++) {
    const ham = dizi[i];
    if (typeof ham !== "object" || ham === null || Array.isArray(ham)) {
      return { ok: false, hata: `${i + 1}. olay nesne değil` };
    }
    const o = ham as Record<string, unknown>;
    const { yuzey, ekran, sure_sn, baslangic, oturum_anahtari, rol } = o;

    if (typeof yuzey !== "string" || !YUZEYLER.includes(yuzey)) return { ok: false, hata: "geçersiz yuzey" };
    if (typeof rol !== "string" || !ROLLER.includes(rol)) return { ok: false, hata: "geçersiz rol" };
    if (
      typeof ekran !== "string" ||
      ekran.length < 1 ||
      ekran.length > EKRAN_EN_UZUN ||
      !EKRAN_DESENI.test(ekran)
    ) {
      return { ok: false, hata: "geçersiz ekran adı" };
    }
    if (typeof sure_sn !== "number" || !Number.isInteger(sure_sn) || sure_sn < 1 || sure_sn > EN_UZUN_SURE_SN) {
      return { ok: false, hata: `sure_sn 1-${EN_UZUN_SURE_SN} tam sayı olmalı` };
    }
    if (typeof oturum_anahtari !== "string" || !OTURUM_DESENI.test(oturum_anahtari)) {
      return { ok: false, hata: "geçersiz oturum anahtarı" };
    }
    if (typeof baslangic !== "string") return { ok: false, hata: "geçersiz baslangic" };
    const bas = Date.parse(baslangic);
    if (Number.isNaN(bas)) return { ok: false, hata: "geçersiz baslangic" };
    if (bas < simdiMs - GECMIS_TOLERANS_MS || bas > simdiMs + GELECEK_TOLERANS_MS) {
      return { ok: false, hata: "baslangic izin verilen aralıkta değil" };
    }

    olaylar.push({
      yuzey,
      ekran,
      sure_sn,
      baslangic: new Date(bas).toISOString(),
      oturum_anahtari,
      rol,
    });
  }
  return { ok: true, olaylar };
}
