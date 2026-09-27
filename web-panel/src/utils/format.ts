// Türkçe biçim yardımcıları: tarih GG.AA.YYYY, para birimi ₺.

/** 2026-09-02 → "02.09.2026" */
export function formatDate(date: Date): string {
  const dd = String(date.getDate()).padStart(2, "0");
  const mm = String(date.getMonth() + 1).padStart(2, "0");
  return `${dd}.${mm}.${date.getFullYear()}`;
}

/** Kuruş (tamsayı) → "₺1.234,50". Veritabanındaki tüm tutarlar kuruştur. */
export function formatKurus(kurus: number): string {
  return formatTry(kurus / 100);
}

/** 1234.5 → "₺1.234,50" */
export function formatTry(amount: number): string {
  return new Intl.NumberFormat("tr-TR", {
    style: "currency",
    currency: "TRY",
  }).format(amount);
}
