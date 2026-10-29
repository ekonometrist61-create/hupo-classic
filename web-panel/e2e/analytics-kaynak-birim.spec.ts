// Hane kaynağı yardımcıları: birim testleri (tarayıcı açmaz, Node'da çalışır).
// Çalıştırma: $env:E2E_BASE_URL="http://127.0.0.1:9"; npx playwright test e2e/analytics-kaynak-birim.spec.ts
import type { SupabaseClient, User } from "@supabase/supabase-js";
import { expect, test } from "@playwright/test";

import { ANALYTICS_CONSENT_KEY, ANALYTICS_CONSENT_VERSION } from "../src/lib/analytics/consent";
import { haneKaynagiYaz, kayitUtmMetadata } from "../src/lib/analytics/kaynak";
import { utmBelleginiSifirla, utmDogrula } from "../src/lib/analytics/utm";

const g = globalThis as unknown as Record<string, unknown>;
const ORIJINAL_WINDOW = g.window;

function tarayiciKur(arama: string, onay: "granted" | "denied" | null) {
  const yerel = new Map<string, string>();
  const oturum = new Map<string, string>();
  if (onay) {
    yerel.set(
      ANALYTICS_CONSENT_KEY,
      JSON.stringify({ durum: onay, surum: ANALYTICS_CONSENT_VERSION, tarih: "2026-10-29T10:00:00.000Z" }),
    );
  }
  g.window = {
    localStorage: { getItem: (k: string) => yerel.get(k) ?? null, setItem: (k: string, v: string) => void yerel.set(k, v) },
    sessionStorage: { getItem: (k: string) => oturum.get(k) ?? null, setItem: (k: string, v: string) => void oturum.set(k, v) },
    location: { search: arama },
  };
}

function sahteIstemci() {
  const cagrilar: Array<{ ad: string; args: unknown }> = [];
  const istemci = { rpc: async (ad: string, args: unknown) => void cagrilar.push({ ad, args }) } as unknown as SupabaseClient;
  return { istemci, cagrilar };
}

const kullanici = (meta: Record<string, unknown>) => ({ user_metadata: meta }) as unknown as User;

test.beforeEach(() => utmBelleginiSifirla());
test.afterAll(() => {
  g.window = ORIJINAL_WINDOW;
});

test("utmDogrula yalnız güvenli değerleri ve izinli alanları geçirir", () => {
  expect(utmDogrula({ utm_source: "instagram", utm_term: "x", utm_medium: "a@b.com", utm_campaign: 5 })).toEqual({
    utm_source: "instagram",
  });
  expect(utmDogrula(null)).toEqual({});
  expect(utmDogrula("metin")).toEqual({});
});

test("rıza yokken kayıt metadata'sı boş", () => {
  tarayiciKur("?utm_source=instagram", null);
  expect(kayitUtmMetadata()).toEqual({});
});

test("rıza varken kayıt metadata'sı UTM taşır", () => {
  tarayiciKur("?utm_source=instagram&utm_campaign=sm-t0-h1", "granted");
  expect(kayitUtmMetadata()).toEqual({ hupo_utm: { utm_source: "instagram", utm_campaign: "sm-t0-h1" } });
});

test("haneKaynagiYaz geçerli metadata ile RPC çağırır", async () => {
  tarayiciKur("", "granted");
  const { istemci, cagrilar } = sahteIstemci();
  await haneKaynagiYaz(istemci, kullanici({ hupo_utm: { utm_source: "instagram", utm_medium: "x y" } }));
  expect(cagrilar).toEqual([{ ad: "hane_ilk_temas_yaz", args: { p_utm: { utm_source: "instagram" } } }]);
});

test("haneKaynagiYaz metadata yoksa veya rıza reddedilmişse çağırmaz", async () => {
  const { istemci, cagrilar } = sahteIstemci();
  tarayiciKur("", "granted");
  await haneKaynagiYaz(istemci, kullanici({}));
  await haneKaynagiYaz(istemci, null);
  tarayiciKur("", "denied");
  await haneKaynagiYaz(istemci, kullanici({ hupo_utm: { utm_source: "instagram" } }));
  expect(cagrilar).toEqual([]);
});
