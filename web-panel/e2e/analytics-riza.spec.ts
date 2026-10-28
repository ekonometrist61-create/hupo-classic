// Analitik rıza kapısı: gerçek sayfa ve gerçek bileşenlerle (çerez banner'ı + KullanimSuresi).
// Ağ isteği sayılır: kullanim_olaylari_gonder RPC'si. Supabase URL'si build'e gömülür (.env.local).
// Çalıştırma (PowerShell): cd web-panel; npx playwright test e2e/analytics-riza.spec.ts --project=masaustu
import { expect, test, type Page } from "@playwright/test";

import { ANALYTICS_CONSENT_KEY, ANALYTICS_CONSENT_VERSION } from "../src/lib/analytics/consent";
import { karsilamaAtla } from "./helpers";

const RPC = "**/rest/v1/rpc/kullanim_olaylari_gonder";
const banner = (page: Page) => page.locator('section[aria-labelledby="cookie-baslik"]');

async function istekSayaci(page: Page) {
  const sayac = { adet: 0 };
  await page.route(RPC, async (route) => {
    sayac.adet++;
    await route.fulfill({ status: 200, contentType: "application/json", body: '{"kabul":1}' });
  });
  return sayac;
}

// Sayfa arka plana alınır: kullanım süresi kapanır ve kuyruk gönderilmeye çalışılır.
async function arkaPlanaAl(page: Page) {
  await page.waitForTimeout(1500); // süre ölçümü en az 1 sn sürsün
  await page.evaluate(() => {
    Object.defineProperty(document, "visibilityState", { configurable: true, get: () => "hidden" });
    document.dispatchEvent(new Event("visibilitychange"));
  });
  await page.waitForTimeout(500);
}

// Önceden kayıtlı karar: yalnızca karar yoksa yazılır (sayfa yüklenmeden önce).
async function kararKoy(page: Page, durum: "granted" | "denied", surum: string = ANALYTICS_CONSENT_VERSION) {
  const kayit = JSON.stringify({ durum, surum, tarih: new Date().toISOString() });
  await page.addInitScript(
    ([k, v]: [string, string]) => {
      try {
        if (!window.localStorage.getItem(k)) window.localStorage.setItem(k, v);
      } catch {
        // Depo kapalıysa karar yazılamaz; test yine de sonucu gösterir.
      }
    },
    [ANALYTICS_CONSENT_KEY, kayit] as [string, string],
  );
}

test.describe("çerez onayı ve kullanım süresi", () => {
  test("reddet: kullanım süresi hiç ağ isteği atmaz", async ({ page }) => {
    await karsilamaAtla(page);
    const sayac = await istekSayaci(page);
    await page.goto("/");

    await banner(page).getByRole("button", { name: "Reddet" }).click();
    await expect(banner(page)).toBeHidden();
    await arkaPlanaAl(page);

    expect(sayac.adet).toBe(0);
    const kayitli = await page.evaluate((k) => window.localStorage.getItem(k), ANALYTICS_CONSENT_KEY);
    expect(JSON.parse(kayitli ?? "{}")).toMatchObject({ durum: "denied", surum: ANALYTICS_CONSENT_VERSION });
  });

  test("kabul (kontrol): aynı akış ağ isteği üretir", async ({ page }) => {
    // Kontrol testi: istek sayacı gerçekten çalışıyor mu? Kabul yoksa reddet testi anlamsız kalır.
    await karsilamaAtla(page);
    const sayac = await istekSayaci(page);
    await page.goto("/");

    await banner(page).getByRole("button", { name: "Kabul et" }).click();
    await expect(banner(page)).toBeHidden();
    await arkaPlanaAl(page);

    expect(sayac.adet).toBeGreaterThan(0);
  });

  test("metin sürümü değişmişse banner yeniden sorar", async ({ page }) => {
    await karsilamaAtla(page);
    await kararKoy(page, "granted", "eski-metin-surumu");
    await page.goto("/");
    await expect(banner(page)).toBeVisible();
  });

  test("geçerli sürümde kayıtlı karar varken banner gösterilmez", async ({ page }) => {
    await karsilamaAtla(page);
    await kararKoy(page, "denied");
    await page.goto("/");
    await expect(banner(page)).toBeHidden();
  });
});
