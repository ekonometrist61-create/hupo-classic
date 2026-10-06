// Türkçe biçim yardımcıları: tarih GG.AA.YYYY, para birimi ₺.

/** 2026-09-02 → "02.09.2026" */
export function formatDate(date: Date): string {
  const dd = String(date.getDate()).padStart(2, "0");
  const mm = String(date.getMonth() + 1).padStart(2, "0");
  return `${dd}.${mm}.${date.getFullYear()}`;
}

/** ISO zaman damgası → "02.09.2026 14:30" (cihaz saat dilimi). Geçersizse "—". */
export function formatDateTime(iso: string | null | undefined): string {
  if (!iso) return "—";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "—";
  const hh = String(d.getHours()).padStart(2, "0");
  const mi = String(d.getMinutes()).padStart(2, "0");
  return `${formatDate(d)} ${hh}:${mi}`;
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
