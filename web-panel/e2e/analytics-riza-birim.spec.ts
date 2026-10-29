// Analitik rıza kapısı: birim testleri (tarayıcı açmaz, Node'da çalışır).
// Tarayıcı global'leri (window, fetch) sahte nesnelerle kurulur ve her testten sonra geri alınır.
// Çalıştırma (PowerShell, sunucu gerekmez):
//   $env:E2E_BASE_URL="http://127.0.0.1:9"; npx playwright test e2e/analytics-riza-birim.spec.ts
import { expect, test } from "@playwright/test";

import {
  ANALYTICS_CONSENT_CHANGED_EVENT,
  ANALYTICS_CONSENT_KEY,
  ANALYTICS_CONSENT_VERSION,
  readAnalyticsConsent,
  writeAnalyticsConsent,
} from "../src/lib/analytics/consent";

type Istek = { url: string; govde: Record<string, unknown> };
type Kayit = {
  depo: Map<string, string>;
  yazim: number;
  istekler: Istek[];
  olaylar: string[];
};

const g = globalThis as unknown as Record<string, unknown>;
const ORIJINAL_FETCH = globalThis.fetch;
const ORIJINAL_WINDOW = g.window;

// Sahte tarayıcı: localStorage yazımları sayılır; fetch çağrıları kaydedilir.
function tarayiciKur(depoIcerik: Record<string, string> = {}, arama = "?utm_source=test&utm_medium=cpc"): Kayit {
  const kayit: Kayit = { depo: new Map(Object.entries(depoIcerik)), yazim: 0, istekler: [], olaylar: [] };
  g.window = {
    localStorage: {
      getItem: (k: string) => kayit.depo.get(k) ?? null,
      setItem: (k: string, v: string) => {
        kayit.yazim++;
        kayit.depo.set(k, v);
      },
      removeItem: (k: string) => {
        kayit.depo.delete(k);
      },
    },
    location: { search: arama },
    dispatchEvent: (e: Event) => {
      kayit.olaylar.push(e.type);
      return true;
    },
  };
  globalThis.fetch = (async (url: string | URL, init?: RequestInit) => {
    kayit.istekler.push({
      url: String(url),
      govde: JSON.parse(String(init?.body ?? "{}")) as Record<string, unknown>,
    });
    return new Response("{}", { status: 200 });
  }) as typeof fetch;
  return kayit;
}

function tarayiciGeriAl() {
  if (ORIJINAL_WINDOW === undefined) delete g.window;
  else g.window = ORIJINAL_WINDOW;
  globalThis.fetch = ORIJINAL_FETCH;
}

function onayKaydi(durum: string, surum: string = ANALYTICS_CONSENT_VERSION): string {
  return JSON.stringify({ durum, surum, tarih: "2026-10-27T10:00:00.000Z" });
}

test.beforeAll(() => {
  // Sunucu/Supabase yapılandırması: modül yüklenirken okunur.
  process.env.NEXT_PUBLIC_SUPABASE_URL = "https://ornek-proje.supabase.test";
  process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY = "test-yayinlanabilir-anahtar";
});

test.afterEach(() => {
  tarayiciGeriAl();
});

test.describe("consent.ts: karar okuma ve yazma", () => {
  test("karar yoksa okunan değer null", () => {
    tarayiciKur({});
    expect(readAnalyticsConsent()).toBeNull();
  });

  test("kabul kaydı granted, reddi denied olarak okunur", () => {
    tarayiciKur({ [ANALYTICS_CONSENT_KEY]: onayKaydi("granted") });
    expect(readAnalyticsConsent()).toBe("granted");

    tarayiciKur({ [ANALYTICS_CONSENT_KEY]: onayKaydi("denied") });
    expect(readAnalyticsConsent()).toBe("denied");
  });

  test("metin sürümü değişince eski karar yok sayılır (yeniden sorulur)", () => {
    tarayiciKur({ [ANALYTICS_CONSENT_KEY]: onayKaydi("granted", "eski-metin-surumu") });
    expect(readAnalyticsConsent()).toBeNull();
  });

  test("bozuk kayıt null döner ve hata fırlatmaz", () => {
    tarayiciKur({ [ANALYTICS_CONSENT_KEY]: "{bozuk" });
    expect(readAnalyticsConsent()).toBeNull();
  });

  test("bilinmeyen durum değeri null döner", () => {
    tarayiciKur({ [ANALYTICS_CONSENT_KEY]: onayKaydi("belki") });
    expect(readAnalyticsConsent()).toBeNull();
  });

  test("writeAnalyticsConsent kararı geçerli sürümle yazar ve değişiklik olayını yayınlar", () => {
    const kayit = tarayiciKur({});
    writeAnalyticsConsent("denied");
    expect(readAnalyticsConsent()).toBe("denied");
    const kaydedilen = JSON.parse(kayit.depo.get(ANALYTICS_CONSENT_KEY) ?? "{}") as { surum: string };
    expect(kaydedilen.surum).toBe(ANALYTICS_CONSENT_VERSION);
    expect(kayit.olaylar).toContain(ANALYTICS_CONSENT_CHANGED_EVENT);

    writeAnalyticsConsent("granted");
    expect(readAnalyticsConsent()).toBe("granted");
  });
});

test.describe("erkenErisimIzleme.ts: rıza kapısı", () => {
  async function modul() {
    return import("../src/components/landing/sections/erkenErisimIzleme");
  }
  const EPOSTA = "veli@ornek.test";

  for (const [ad, depo] of [
    ["onay yok", {}],
    ["onay reddedilmiş", { [ANALYTICS_CONSENT_KEY]: onayKaydi("denied") }],
    ["onay eski sürümde", { [ANALYTICS_CONSENT_KEY]: onayKaydi("granted", "eski-metin-surumu") }],
  ] as const) {
    test(`${ad}: 0 fetch, 0 localStorage yazımı, UTM ve kimlik üretilmez`, async () => {
      const kayit = tarayiciKur({ ...depo });
      const izleme = await modul();

      await izleme.erkenErisimSonrasiIzleme(EPOSTA);
      const utm = izleme.ilkTemasUtm();
      izleme.ziyaretciKimligi();

      expect(kayit.istekler).toHaveLength(0);
      expect(kayit.yazim).toBe(0);
      expect(utm).toEqual({});
      expect(kayit.depo.has("hupo_vid")).toBe(false);
      expect(kayit.depo.has("hupo_utm")).toBe(false);
    });
  }

  test("onay var: olay ve kimlik bağlama istekleri gönderilir, UTM ve kimlik saklanır", async () => {
    const kayit = tarayiciKur({ [ANALYTICS_CONSENT_KEY]: onayKaydi("granted") });
    const izleme = await modul();

    await izleme.erkenErisimSonrasiIzleme(EPOSTA);

    expect(kayit.istekler).toHaveLength(2);
    expect(kayit.istekler[0].url).toContain("/functions/v1/growth-web-izle");
    expect(kayit.istekler[0].govde.islem).toBe("olay");
    expect(kayit.istekler[0].govde.event_name).toBe("erken_erisim_gonderildi");
    // Olay isteği e-posta taşımaz; e-posta yalnızca kimlik bağlama isteğindedir.
    expect(kayit.istekler[0].govde).not.toHaveProperty("eposta");
    expect(kayit.istekler[1].govde.islem).toBe("kimlik");
    expect(kayit.istekler[1].govde.eposta).toBe(EPOSTA);

    expect(kayit.depo.get("hupo_vid")).toMatch(/^vid-/);
    const utm = JSON.parse(kayit.depo.get("hupo_utm") ?? "{}") as Record<string, string>;
    expect(utm).toEqual({ utm_source: "test", utm_medium: "cpc" });
  });
});

test.describe("events.ts: trackLandingEvent rıza kapısı", () => {
  test("onay yokken posthog.capture çağrılmaz; onay varken çağrılır", async () => {
    // CJS paketlerde dinamik import'un "default"u ile modülün gerçek örneği farklı nesne olabilir.
    // Olası iki adayın da capture'ını yakalıyoruz; events.ts hangisini kullanırsa kullansın görülür.
    type PH = { capture: (...a: unknown[]) => unknown };
    const esle = (x: unknown): x is PH => typeof (x as PH | undefined)?.capture === "function";
    const pm = (await import("posthog-js")) as unknown as { default?: unknown };
    const adaylar = [...new Set([pm.default, (pm.default as { default?: unknown } | undefined)?.default])].filter(esle);
    expect(adaylar.length).toBeGreaterThan(0);

    const orijinaller = adaylar.map((p) => p.capture);
    const cagrilar: unknown[][] = [];
    adaylar.forEach((p) => {
      p.capture = (...a: unknown[]) => {
        cagrilar.push(a);
      };
    });
    try {
      const olaylar = await import("../src/lib/analytics/events");

      tarayiciKur({});
      olaylar.trackLandingEvent("hero_cta_tiklandi");
      tarayiciKur({ [ANALYTICS_CONSENT_KEY]: onayKaydi("denied") });
      olaylar.trackLandingEvent("fiyat_tiklandi");
      expect(cagrilar).toHaveLength(0);

      tarayiciKur({ [ANALYTICS_CONSENT_KEY]: onayKaydi("granted") });
      olaylar.trackLandingEvent("hero_cta_tiklandi");
      expect(cagrilar).toHaveLength(1);
      expect(cagrilar[0][0]).toBe("hero_cta_tiklandi");
    } finally {
      adaylar.forEach((p, i) => {
        p.capture = orijinaller[i];
      });
    }
  });
});
