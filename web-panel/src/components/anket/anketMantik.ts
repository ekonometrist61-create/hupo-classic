// Anket veri modeli ve saf yardımcılar. Sunucu sözleşmesi:
// supabase/migrations/20261029000000_anket_yuzeyler.sql (anket_aktif_listem, anket_yanit_gonder).

export type Yuzey = "veli_paneli" | "web_sitesi";

export type SoruTuru =
  | "kisa_metin"
  | "uzun_metin"
  | "tek_secim"
  | "nps"
  | "csat"
  | "onay";

const SORU_TURLERI: readonly SoruTuru[] = [
  "kisa_metin",
  "uzun_metin",
  "tek_secim",
  "nps",
  "csat",
  "onay",
];

export interface Kosul {
  soru_id: string;
  op: "lte" | "gte" | "eq";
  deger: number;
}

export interface Soru {
  id: string;
  tur: SoruTuru;
  baslik: string;
  secenekler?: string[];
  kosul?: Kosul;
}

export interface Anket {
  id: string;
  ad: string;
  anonim: boolean;
  surum: number;
  sorular: Soru[];
}

export type Cevap = string | number | boolean;
export type Cevaplar = Record<string, Cevap>;

export const METIN_MAKS = 2000;

// Sunucudan gelen veriyi istemcide de doğrular; beklenmeyen şekil sessizce elenir.
export function anketGecerliMi(v: unknown): v is Anket {
  if (typeof v !== "object" || v === null) return false;
  const a = v as Record<string, unknown>;
  return (
    typeof a.id === "string" &&
    typeof a.ad === "string" &&
    typeof a.anonim === "boolean" &&
    typeof a.surum === "number" &&
    Array.isArray(a.sorular) &&
    a.sorular.every(
      (s) =>
        typeof s === "object" &&
        s !== null &&
        typeof (s as Soru).id === "string" &&
        typeof (s as Soru).baslik === "string" &&
        SORU_TURLERI.includes((s as Soru).tur)
    )
  );
}

// Koşullu soru: bağlı olduğu sorunun (kendisi de görünürse) sayısal yanıtı koşulu sağlamalı.
export function soruGorunurMu(
  soru: Soru,
  sorular: Soru[],
  cevaplar: Cevaplar,
  derinlik = 0
): boolean {
  if (!soru.kosul) return true;
  if (derinlik > 30) return false;
  const kosul = soru.kosul;
  const ust = sorular.find((s) => s.id === kosul.soru_id);
  if (!ust || !soruGorunurMu(ust, sorular, cevaplar, derinlik + 1)) return false;
  const deger = cevaplar[kosul.soru_id];
  if (typeof deger !== "number") return false;
  switch (kosul.op) {
    case "lte":
      return deger <= kosul.deger;
    case "gte":
      return deger >= kosul.deger;
    default:
      return deger === kosul.deger;
  }
}

// Yalnızca görünen, dolu ve türüne uygun yanıtları sunucuya gönderilecek şekle getirir.
export function yanitlariHazirla(sorular: Soru[], cevaplar: Cevaplar): Cevaplar {
  const cikti: Cevaplar = {};
  for (const soru of sorular) {
    if (!soruGorunurMu(soru, sorular, cevaplar)) continue;
    const deger = cevaplar[soru.id];
    if (deger === undefined) continue;
    if (soru.tur === "kisa_metin" || soru.tur === "uzun_metin") {
      if (typeof deger !== "string") continue;
      const metin = deger.trim();
      if (metin) cikti[soru.id] = metin.slice(0, METIN_MAKS);
      continue;
    }
    if (soru.tur === "onay") {
      if (deger === true) cikti[soru.id] = true;
      continue;
    }
    if (soru.tur === "nps" || soru.tur === "csat") {
      if (typeof deger === "number") cikti[soru.id] = deger;
      continue;
    }
    if (soru.tur === "tek_secim") {
      if (typeof deger === "string" && soru.secenekler?.includes(deger)) {
        cikti[soru.id] = deger;
      }
    }
  }
  return cikti;
}

// Ertelenen anket: aynı anket (id + sürüm) 1 gün boyunca gösterilmez.
const ERTELEME_ON_ANAHTAR = "hupo.anket.ertele.";
const ERTELEME_SURE_MS = 24 * 60 * 60 * 1000;

function ertelemeAnahtari(anket: Anket): string {
  return `${ERTELEME_ON_ANAHTAR}${anket.id}.${anket.surum}`;
}

export function ertelenmisMi(anket: Anket): boolean {
  try {
    const deger = window.localStorage.getItem(ertelemeAnahtari(anket));
    return deger !== null && Number(deger) > Date.now();
  } catch {
    // Depolama erişilemiyorsa (gizli pencere, engelli site verisi) erteleme yok sayılır.
    return false;
  }
}

export function ertele(anket: Anket): void {
  try {
    window.localStorage.setItem(
      ertelemeAnahtari(anket),
      String(Date.now() + ERTELEME_SURE_MS)
    );
  } catch {
    // Kayıt yapılamazsa anket bu oturumda yine de kapanır; bir sonraki sayfa yüklemesinde tekrar görünebilir.
  }
}
