"use client";

import {
  ANALYTICS_CONSENT_CHANGED_EVENT,
  readAnalyticsConsent,
  type AnalyticsConsent,
} from "@/lib/analytics/consent";
import {
  analitikIstemcisi,
  analitikIstemcisiVarsa,
  type AnalitikIstemcisi,
} from "@/lib/analytics/posthog-istemci";
import { utmOzellikleri, utmYakala } from "@/lib/analytics/utm";
import { usePathname } from "next/navigation";
import { useEffect } from "react";

// Yalnızca bu yollarda sayfa görüntüsü kaydedilir. Oturum, veli, yönetim ve parola
// sayfaları bilerek dışarıda: URL'lerinde kişisel veya oturum parametreleri olabilir.
const IZINLI_YOLLAR = new Set(["/", "/demo", "/gizlilik", "/kosullar"]);

// Aynı yolun iki kez gönderilmemesi için son gönderilen yol.
let sonGonderilenYol: string | null = null;

function sayfaGoruntusuGonder(posthog: AnalitikIstemcisi, yol: string) {
  if (!IZINLI_YOLLAR.has(yol) || sonGonderilenYol === yol) return;
  sonGonderilenYol = yol;
  // URL'yi sorgu parametresiz, kendimiz kurarak gönderiyoruz.
  posthog.capture("$pageview", {
    $current_url: `${window.location.origin}${yol}`,
    // İlk temas UTM'si (yalnız onaylıysa dolu; izinli 4 alan).
    ...utmOzellikleri(),
  });
}

// Analitik betiği yalnızca kullanıcı onay verdiğinde yüklenir; reddederse hiç yüklenmez.
export default function AnalyticsProvider() {
  const pathname = usePathname();

  useEffect(() => {
    const anahtar = process.env.NEXT_PUBLIC_POSTHOG_KEY;
    // İlk temas UTM'si yalnız bellekte yakalanır (rıza öncesi depoya yazılmaz).
    utmYakala();
    if (!anahtar) return;

    const uygula = (durum: AnalyticsConsent | null) => {
      if (durum === "granted") {
        analitikIstemcisi(anahtar)
          .then((posthog) => {
            posthog.opt_in_capturing();
            sayfaGoruntusuGonder(posthog, window.location.pathname);
          })
          .catch(() => {
            // Betik yüklenemezse sayfa etkilenmez; ölçüm sessizce atlanır.
          });
      } else {
        // Betik hiç yüklenmemişse (null) kapatılacak bir şey yok.
        analitikIstemcisiVarsa()?.then((posthog) => posthog.opt_out_capturing()).catch(() => {});
      }
    };

    uygula(readAnalyticsConsent());

    const onDegisim = (olay: Event) => {
      uygula((olay as CustomEvent<AnalyticsConsent>).detail);
    };
    window.addEventListener(ANALYTICS_CONSENT_CHANGED_EVENT, onDegisim);
    return () => window.removeEventListener(ANALYTICS_CONSENT_CHANGED_EVENT, onDegisim);
  }, []);

  // İstemci gezinmesinde yol değişince (onay verildiyse) görüntü gönderilir.
  useEffect(() => {
    if (readAnalyticsConsent() !== "granted") return;
    analitikIstemcisiVarsa()?.then((posthog) => sayfaGoruntusuGonder(posthog, pathname)).catch(() => {});
  }, [pathname]);

  return null;
}
