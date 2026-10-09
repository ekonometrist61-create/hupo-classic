"use client";

import {
  ANALYTICS_CONSENT_CHANGED_EVENT,
  readAnalyticsConsent,
  type AnalyticsConsent,
} from "@/lib/analytics/consent";
import posthog from "posthog-js";
import { usePathname } from "next/navigation";
import { useEffect } from "react";

// Yalnızca bu yollarda sayfa görüntüsü kaydedilir. Oturum, veli, yönetim ve parola
// sayfaları bilerek dışarıda: URL'lerinde kişisel veya oturum parametreleri olabilir.
const IZINLI_YOLLAR = new Set(["/", "/demo", "/gizlilik", "/kosullar"]);

let baslatildi = false;
// Aynı yolun iki kez gönderilmemesi için son gönderilen yol.
let sonGonderilenYol: string | null = null;

function analitigiBaslat(anahtar: string) {
  if (baslatildi) return;
  baslatildi = true;
  posthog.init(anahtar, {
    api_host: process.env.NEXT_PUBLIC_POSTHOG_HOST || "https://eu.i.posthog.com",
    // Kişisel profil oluşturulmaz, oturum kaydı ve otomatik olay yakalama kapalıdır.
    person_profiles: "identified_only",
    autocapture: false,
    capture_pageview: false,
    capture_pageleave: false,
    disable_session_recording: true,
    respect_dnt: true,
    persistence: "localStorage",
  });
}

function sayfaGoruntusuGonder(yol: string) {
  if (!IZINLI_YOLLAR.has(yol) || sonGonderilenYol === yol) return;
  sonGonderilenYol = yol;
  // URL'yi sorgu parametresiz, kendimiz kurarak gönderiyoruz.
  posthog.capture("$pageview", {
    $current_url: `${window.location.origin}${yol}`,
  });
}

// Analitik betiği yalnızca kullanıcı onay verdiğinde yüklenir; reddederse hiç yüklenmez.
export default function AnalyticsProvider() {
  const pathname = usePathname();

  useEffect(() => {
    const anahtar = process.env.NEXT_PUBLIC_POSTHOG_KEY;
    if (!anahtar) return;

    const uygula = (durum: AnalyticsConsent | null) => {
      if (durum === "granted") {
        analitigiBaslat(anahtar);
        posthog.opt_in_capturing();
        sayfaGoruntusuGonder(window.location.pathname);
      } else if (baslatildi) {
        posthog.opt_out_capturing();
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
    if (!baslatildi || readAnalyticsConsent() !== "granted") return;
    sayfaGoruntusuGonder(pathname);
  }, [pathname]);

  return null;
}
