"use client";

import { Link } from "@/i18n/navigation";
import {
  ANALYTICS_CONSENT_CHANGED_EVENT,
  COOKIE_PREFERENCES_OPEN_EVENT,
  readAnalyticsConsent,
  writeAnalyticsConsent,
} from "@/lib/analytics/consent";
import { useTranslations } from "next-intl";
import { useEffect, useRef, useState, useSyncExternalStore } from "react";

// Sunucuda ve hidrasyon sırasında bant gizli kalır; istemci kararı sonradan okunur.
const SUNUCU_DURUMU = "sunucu";
const KARAR_YOK = "yok";

function karardaDegisim(onChange: () => void) {
  window.addEventListener(ANALYTICS_CONSENT_CHANGED_EVENT, onChange);
  return () => window.removeEventListener(ANALYTICS_CONSENT_CHANGED_EVENT, onChange);
}

function kararOku() {
  return readAnalyticsConsent() ?? KARAR_YOK;
}

// Çerez onay bandı. Kabul ve reddet aynı görsel ağırlıktadır; reddetmek kabul etmek kadar
// kolaydır. Zorunlu oturum çerezleri onaya bağlı değildir.
export default function CookieConsent() {
  const t = useTranslations("cookie");
  // Karar yoksa veya metin sürümü değiştiyse bant gösterilir.
  const durum = useSyncExternalStore(karardaDegisim, kararOku, () => SUNUCU_DURUMU);
  // "Tercihler" olayı, karar verilmiş olsa bile bandı yeniden açar.
  const [elleAcildi, setElleAcildi] = useState(false);
  const bantRef = useRef<HTMLElement>(null);
  // Bant metni 320 px'te iki satıra inebilir; boşluk bandın ölçülen yüksekliğini izler.
  const [bantYuksekligi, setBantYuksekligi] = useState(0);

  useEffect(() => {
    const ac = () => setElleAcildi(true);
    window.addEventListener(COOKIE_PREFERENCES_OPEN_EVENT, ac);
    return () => window.removeEventListener(COOKIE_PREFERENCES_OPEN_EVENT, ac);
  }, []);

  const gorunur = elleAcildi || durum === KARAR_YOK;

  useEffect(() => {
    const el = bantRef.current;
    if (!el) return;
    const gozlemci = new ResizeObserver(() => setBantYuksekligi(el.offsetHeight));
    gozlemci.observe(el);
    return () => gozlemci.disconnect();
  }, [gorunur]);

  if (!gorunur) return null;

  function kararVer(karar: "granted" | "denied") {
    writeAnalyticsConsent(karar);
    setElleAcildi(false);
  }

  // Bant fixed olduğu için altındaki son içeriği örter; sayfa sonuna aynı yükseklikte boşluk
  // ekleyerek son içerik bandın altında kalmaz.
  return (
    <>
      <div aria-hidden="true" style={{ height: bantYuksekligi }} />
      <section
        ref={bantRef}
        aria-labelledby="cookie-baslik"
        className="fixed inset-x-0 bottom-0 z-50 border-t border-navy/10 bg-white px-3 py-1.5 shadow-lg sm:px-4 sm:py-3"
      >
        <h2 id="cookie-baslik" className="sr-only">
          {t("title")}
        </h2>
        {/* Tek satır: kısa metin, "Tercihler" (gizlilik sayfası) ve iki eşit ağırlıklı karar düğmesi. */}
        <div className="mx-auto flex max-w-5xl items-center gap-1 sm:gap-3">
          <p className="min-w-0 flex-1 text-xs leading-snug text-navy-muted sm:text-sm">
            {t("shortText")}
          </p>
          <Link
            href="/gizlilik"
            className="inline-flex h-11 shrink-0 items-center px-1.5 text-xs font-semibold sm:px-2 sm:text-sm text-brand-700 underline underline-offset-4 hover:text-brand-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
          >
            {t("preferences")}
          </Link>
          <button
            type="button"
            onClick={() => kararVer("denied")}
            className="inline-flex h-11 shrink-0 items-center justify-center rounded-xl border border-navy/20 px-3 text-xs font-semibold sm:px-4 sm:text-sm text-navy hover:bg-navy/5 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
          >
            {t("reject")}
          </button>
          <button
            type="button"
            onClick={() => kararVer("granted")}
            className="inline-flex h-11 shrink-0 items-center justify-center rounded-xl bg-brand-500 px-3 text-xs font-semibold sm:px-4 sm:text-sm text-white hover:bg-brand-600 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
          >
            {t("accept")}
          </button>
        </div>
      </section>
    </>
  );
}
