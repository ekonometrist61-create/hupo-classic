// İlk temas UTM'si: birim testleri (tarayıcı açmaz, Node'da çalışır).
// Çalıştırma (PowerShell, sunucu gerekmez):
//   $env:E2E_BASE_URL="http://127.0.0.1:9"; npx playwright test e2e/analytics-utm-birim.spec.ts
import { expect, test } from "@playwright/test";

import { ANALYTICS_CONSENT_KEY, ANALYTICS_CONSENT_VERSION } from "../src/lib/analytics/consent";
import { UTM_OTURUM_KEY, utmAyristir, utmBelleginiSifirla, utmOzellikleri, utmYakala } from "../src/lib/analytics/utm";

const g = globalThis as unknown as Record<string, unknown>;
const ORIJINAL_WINDOW = g.window;

type Kayit = { yerel: Map<string, string>; oturum: Map<string, string>; oturumYazim: number; yerelYazim: number };

function tarayiciKur(arama: string, onay: "granted" | "denied" | null): Kayit {
  const kayit: Kayit = { yerel: new Map(), oturum: new Map(), oturumYazim: 0, yerelYazim: 0 };
  if (onay) {
    kayit.yerel.set(
      ANALYTICS_CONSENT_KEY,
      JSON.stringify({ durum: onay, surum: ANALYTICS_CONSENT_VERSION, tarih: "2026-10-29T10:00:00.000Z" }),
    );
  }
  g.window = {
    localStorage: {
      getItem: (k: string) => kayit.yerel.get(k) ?? null,
      setItem: (k: string, v: string) => {
        kayit.yerelYazim++;
        kayit.yerel.set(k, v);
      },
    },
    sessionStorage: {
      getItem: (k: string) => kayit.oturum.get(k) ?? null,
      setItem: (k: string, v: string) => {
        kayit.oturumYazim++;
        kayit.oturum.set(k, v);
      },
    },
    location: { search: arama },
  };
  return kayit;
}

test.beforeEach(() => utmBelleginiSifirla());
test.afterEach(() => {
  if (ORIJINAL_WINDOW === undefined) delete g.window;
  else g.window = ORIJINAL_WINDOW;
  utmBelleginiSifirla();
});

test.describe("utm.ts", () => {
  test("ayrıştırma: 4 izinli alan alınır, utm_term ve güvensiz değerler atılır", () => {
    const s = utmAyristir(
      "?utm_source=instagram&utm_medium=organic_social&utm_campaign=sm-2026-11-h1&utm_content=bio&utm_term=x&utm_id=1",
    );
    expect(s).toEqual({
      utm_source: "instagram",
      utm_medium: "organic_social",
      utm_campaign: "sm-2026-11-h1",
      utm_content: "bio",
    });
    // E-posta, boşluk, URL ve uzun değerler reddedilir.
    expect(utmAyristir("?utm_source=ali@ornek.com")).toEqual({});
    expect(utmAyristir("?utm_source=a%20b")).toEqual({});
    expect(utmAyristir("?utm_source=http://x.y")).toEqual({});
    expect(utmAyristir(`?utm_source=${"a".repeat(101)}`)).toEqual({});
  });

  test("rıza yok: UTM yakalanır ama olay özelliği boş, hiçbir depoya yazılmaz", () => {
    const k = tarayiciKur("?utm_source=instagram&utm_content=bio", null);
    utmYakala();
    expect(utmOzellikleri()).toEqual({});
    expect(k.oturumYazim).toBe(0);
    expect(k.yerelYazim).toBe(0);
  });

  test("rıza reddedildi: boş ve yazım yok", () => {
    const k = tarayiciKur("?utm_source=instagram", "denied");
    utmYakala();
    expect(utmOzellikleri()).toEqual({});
    expect(k.oturumYazim).toBe(0);
  });

  test("rıza sonradan verildi: bellekteki UTM oturum deposuna yazılır ve döner", () => {
    const k = tarayiciKur("?utm_source=instagram&utm_medium=organic_social&utm_content=bio", null);
    utmYakala();
    // Kullanıcı bu sırada "Kabul et" der.
    k.yerel.set(
      ANALYTICS_CONSENT_KEY,
      JSON.stringify({ durum: "granted", surum: ANALYTICS_CONSENT_VERSION, tarih: "2026-10-29T10:01:00.000Z" }),
    );
    expect(utmOzellikleri()).toEqual({
      utm_source: "instagram",
      utm_medium: "organic_social",
      utm_content: "bio",
    });
    expect(k.oturumYazim).toBe(1);
    expect(k.yerelYazim).toBe(0);
    expect(k.oturum.has(UTM_OTURUM_KEY)).toBe(true);
  });

  test("ilk temas korunur: oturumda kayıtlı UTM, sonraki URL'deki yeni UTM ile ezilmez", () => {
    const k = tarayiciKur("?utm_source=youtube&utm_content=g06", "granted");
    k.oturum.set(UTM_OTURUM_KEY, JSON.stringify({ utm_source: "instagram", utm_content: "bio" }));
    utmYakala();
    expect(utmOzellikleri()).toEqual({ utm_source: "instagram", utm_content: "bio" });
    expect(k.oturumYazim).toBe(0);
  });

  test("UTM'siz ziyaret: boş, yazım yok", () => {
    const k = tarayiciKur("", "granted");
    utmYakala();
    expect(utmOzellikleri()).toEqual({});
    expect(k.oturumYazim).toBe(0);
  });

  test("bozuk oturum kaydı: yok sayılır, URL'den yeniden okunur", () => {
    const k = tarayiciKur("?utm_source=linkedin", "granted");
    k.oturum.set(UTM_OTURUM_KEY, "{bozuk");
    utmYakala();
    expect(utmOzellikleri()).toEqual({ utm_source: "linkedin" });
  });
});
