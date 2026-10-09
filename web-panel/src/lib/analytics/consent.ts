// Analitik çerez onayı. Onay yalnızca tarayıcıda (localStorage) tutulur; kullanıcı
// reddederse hiçbir ölçüm betiği yüklenmez. Metin sürümü değişirse onay yeniden sorulur.

export const ANALYTICS_CONSENT_KEY = "hupo-analytics-consent";
export const ANALYTICS_CONSENT_VERSION = "analitik-2026-10-taslak-1";

// Pencere olayları: onay değişti / banner'ı yeniden aç.
export const ANALYTICS_CONSENT_CHANGED_EVENT = "hupo:analytics-consent-changed";
export const COOKIE_PREFERENCES_OPEN_EVENT = "hupo:cookie-preferences-open";

export type AnalyticsConsent = "granted" | "denied";

type StoredConsent = {
  durum: AnalyticsConsent;
  surum: string;
  tarih: string;
};

export function readAnalyticsConsent(): AnalyticsConsent | null {
  try {
    const raw = window.localStorage.getItem(ANALYTICS_CONSENT_KEY);
    if (!raw) return null;
    const stored = JSON.parse(raw) as StoredConsent;
    if (stored.surum !== ANALYTICS_CONSENT_VERSION) return null;
    return stored.durum === "granted" || stored.durum === "denied" ? stored.durum : null;
  } catch {
    // Özel tarama veya engellenmiş depolama: karar okunamadı, kullanıcıya yeniden sorulur.
    return null;
  }
}

export function writeAnalyticsConsent(durum: AnalyticsConsent): void {
  const kayit: StoredConsent = {
    durum,
    surum: ANALYTICS_CONSENT_VERSION,
    tarih: new Date().toISOString(),
  };
  try {
    window.localStorage.setItem(ANALYTICS_CONSENT_KEY, JSON.stringify(kayit));
  } catch {
    // Depolama yazılamadıysa karar yalnızca bu oturumda geçerli olur; olay yine yayınlanır.
  }
  window.dispatchEvent(new CustomEvent(ANALYTICS_CONSENT_CHANGED_EVENT, { detail: durum }));
}

export function openCookiePreferences(): void {
  window.dispatchEvent(new Event(COOKIE_PREFERENCES_OPEN_EVENT));
}
