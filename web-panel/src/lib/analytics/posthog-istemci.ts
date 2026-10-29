// posthog-js yalnızca analitik onayı verildiğinde yüklenir ve başlatılır.
// Onay vermeyen veya henüz karar vermeyen ziyaretçiler için betik hiç indirilmez.
// AnalyticsProvider (sayfa görüntüsü) ve events.ts (landing olayları) aynı örneği kullanır.

export type AnalitikIstemcisi = typeof import("posthog-js").default;

let istemci: Promise<AnalitikIstemcisi> | null = null;

// İlk çağrıda yükler ve başlatır; sonraki çağrılar aynı örneği döndürür.
export function analitikIstemcisi(anahtar: string): Promise<AnalitikIstemcisi> {
  istemci ??= import("posthog-js").then(({ default: posthog }) => {
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
    return posthog;
  });
  return istemci;
}

// Betik henüz yüklenmediyse null döner; çağıran bu durumda hiçbir şey yapmaz.
export function analitikIstemcisiVarsa(): Promise<AnalitikIstemcisi> | null {
  return istemci;
}
