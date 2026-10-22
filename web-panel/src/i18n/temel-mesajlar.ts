import type { MesajNesnesi } from "../lib/cms/icerik";
import type { Locale } from "./routing";

// Panel bölümlerinin metinleri ayrı dosyalarda tutulur ve ana sözlüğe eklenir.
// (Her dosya kendi kök anahtarını taşır: yonetim.* ve veliPaneli.*)
const MESAJ_PARCALARI = [
  "veli-paneli",
  "yonetim-panel",
  "yonetim-sorular",
  "yonetim-merkez",
  "yonetim-okuma",
  "veli-okuma",
  "yonetim-kullanim",
] as const;

function nesneMi(value: unknown): value is MesajNesnesi {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function derinBirlestir(base: MesajNesnesi, extra: MesajNesnesi): MesajNesnesi {
  const out: MesajNesnesi = { ...base };
  for (const [key, value] of Object.entries(extra)) {
    const current = out[key];
    out[key] =
      nesneMi(current) && nesneMi(value) ? derinBirlestir(current, value) : value;
  }
  return out;
}

/**
 * JSON'da gömülü temel metinler (yedek). CMS'te satır yoksa veya okuma başarısızsa kullanılır.
 * Yönetim ekranı varsayılan metni de buradan okur.
 */
export async function temelMesajlar(locale: Locale): Promise<MesajNesnesi> {
  const base = (await import(`../messages/${locale}.json`)).default as MesajNesnesi;
  const parts = await Promise.all(
    MESAJ_PARCALARI.map(
      async (part) =>
        (await import(`../messages/${part}.${locale}.json`)).default as MesajNesnesi,
    ),
  );
  return parts.reduce(derinBirlestir, base);
}
