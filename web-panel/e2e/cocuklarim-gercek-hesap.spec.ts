import { expect, test } from "@playwright/test";

import { girisYap, hesapBilgisi, karsilamaAtla } from "./helpers";

/**
 * GÖR-033: gerçek veli hesabıyla "Çocuklarım" sayfası.
 * Çalıştırma (PowerShell): E2E_BASE_URL=https://hupolingo.com npx playwright test e2e/cocuklarim-gercek-hesap.spec.ts --project=masaustu
 * Hesap: E2E_VELI_EMAIL / E2E_VELI_PASSWORD (ortam değişkeni, git'e yazılmaz).
 */
const COCUK_AD = process.env.E2E_COCUK_AD ?? "E2E Test Cocuk";

test.describe("Veli - Çocuklarım (gerçek hesap)", () => {
  test.skip(!hesapBilgisi("veli"), "E2E_VELI_EMAIL ve E2E_VELI_PASSWORD tanımlı değil.");

  test.beforeEach(async ({ page }) => {
    await karsilamaAtla(page);
    const hesap = hesapBilgisi("veli")!;
    await girisYap(page, hesap.email, hesap.password);
    await page.waitForURL(/\/veli-paneli/, { timeout: 30_000 });
  });

  test("Çocuklarım sayfası bağlı çocuğu listeler", async ({ page }) => {
    await page.goto("/veli-paneli/cocuklarim");
    await expect(page).toHaveURL(/\/veli-paneli\/cocuklarim$/);
    await expect(page.locator("#veli-icerik")).toContainText(COCUK_AD, { timeout: 30_000 });
  });

  test("destek planı kenar çubuğunda görünmüyor (GÖR-088 onayı bekliyor)", async ({ page }) => {
    await page.goto("/veli-paneli");
    await expect(page.locator("#veli-icerik")).toBeVisible();
    await expect(page.locator('aside a[href*="/veli-paneli/destek-plani"]')).toHaveCount(0);
  });
});
