// Saf yardımcılar (yol takma adı içermez; bağımsız test edilebilir).

/** Kuruş sütunu Postgres integer (int4) olduğundan üst sınır. */
export const MAX_KURUS = 2147483647;

/**
 * Yöneticinin yazdığı ₺ tutarını tamsayı kuruşa çevirir. Kayan nokta kullanılmaz.
 * Kabul: "149,90", "149.90", "1.499,90", "1,499.90", "0", "₺149". Reddeder (null): boş, harf, negatif, 2'den fazla ondalık.
 */
export function parseTryToKurus(input: string): number | null {
  const s = input.replace(/[₺\s]/g, "");
  if (!/^\d[\d.,]*$/.test(s)) return null;

  const lastComma = s.lastIndexOf(",");
  const lastDot = s.lastIndexOf(".");
  let intPart: string;
  let frac = "";

  if (lastComma >= 0 && lastDot >= 0) {
    // İkisi de var: sonuncusu ondalık ayracı, diğeri binlik ayracı
    const decIdx = Math.max(lastComma, lastDot);
    const thousandsChar = decIdx === lastComma ? "." : ",";
    intPart = s.slice(0, decIdx);
    frac = s.slice(decIdx + 1);
    if (intPart.includes(decIdx === lastComma ? "," : ".")) return null;
    intPart = intPart.split(thousandsChar).join("");
  } else if (lastComma >= 0) {
    if (s.indexOf(",") !== lastComma) return null; // birden çok virgül
    intPart = s.slice(0, lastComma);
    frac = s.slice(lastComma + 1);
  } else if (lastDot >= 0) {
    const parts = s.split(".");
    const isThousands =
      parts.length > 2 ||
      (parts.length === 2 && parts[1].length === 3 && parts[0].length <= 3 && parts[0] !== "0");
    if (isThousands) {
      if (parts.slice(1).some((p) => p.length !== 3)) return null;
      intPart = parts.join("");
    } else {
      intPart = parts[0];
      frac = parts[1] ?? "";
    }
  } else {
    intPart = s;
  }

  if (!/^\d+$/.test(intPart)) return null;
  if (frac !== "" && !/^\d{1,2}$/.test(frac)) return null;
  if (s.endsWith(",") || s.endsWith(".")) return null;

  const kurus = Number(intPart) * 100 + Number(frac.padEnd(2, "0") || "0");
  if (!Number.isSafeInteger(kurus) || kurus > MAX_KURUS) return null;
  return kurus;
}

/** 14990 → "149,90" (forma geri doldurma için, para simgesi yok). */
export function kurusToInput(kurus: number): string {
  const whole = Math.floor(kurus / 100);
  const rest = String(kurus % 100).padStart(2, "0");
  return `${whole},${rest}`;
}

export const MONTHS_TR = ["Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara"];
export const MONTHS_EN = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

/** "2026-09" → "Eyl 2026" (Date kullanılmaz; saat dilimi kayması olmaz). Geçersizse girdiyi döndürür. */
export function monthLabel(ym: string, months: readonly string[] = MONTHS_TR): string {
  const m = /^(\d{4})-(\d{2})/.exec(ym);
  if (!m) return ym;
  const idx = Number(m[2]) - 1;
  if (idx < 0 || idx > 11) return ym;
  return `${months[idx]} ${m[1]}`;
}

/**
 * Önceki döneme göre yüzde değişim (1 ondalık). Önceki 0 ise: bu da 0 → 0, aksi halde null ("yeni", oran tanımsız).
 */
export function percentChange(current: number, previous: number): number | null {
  if (previous === 0) return current === 0 ? 0 : null;
  return Math.round(((current - previous) / previous) * 1000) / 10;
}

/** Aralık içindeki "YYYY-MM-DD" (date input) doğrulaması; boşsa null. */
export function dateOrNull(v: string): string | null {
  return /^\d{4}-\d{2}-\d{2}$/.test(v) ? v : null;
}
