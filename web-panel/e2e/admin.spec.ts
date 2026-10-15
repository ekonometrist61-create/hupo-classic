import { expect, test } from "@playwright/test";

import { DEMO, girisYap, hesapBilgisi, karsilamaAtla } from "./helpers";

test.describe("Yönetim paneli (admin)", () => {
  test.beforeEach(async ({ page }) => {
    await karsilamaAtla(page);
  });

  test("admin oturumuyla yönetim ana sayfası açılıyor", async ({ page }) => {
    const hesap = hesapBilgisi("admin");
    test.skip(!DEMO && !hesap, "E2E_ADMIN_EMAIL ve E2E_ADMIN_PASSWORD tanımlı değil.");

    if (DEMO) {
      await page.goto("/yonetim");
    } else {
      await girisYap(page, hesap!.email, hesap!.password, "yonetim");
      await page.waitForURL(/\/yonetim/, { timeout: 30_000 });
    }

    await expect(page.locator("aside").first()).toBeVisible();
    await expect(page.locator("#icerik")).toBeVisible();
    await expect(page.locator("#icerik")).not.toBeEmpty();
  });

  test("kenar çubuğunda gezinme bağlantıları var", async ({ page }) => {
    test.skip(!DEMO && !hesapBilgisi("admin"), "Admin hesabı tanımlı değil.");

    if (DEMO) {
      await page.goto("/yonetim");
    } else {
      const hesap = hesapBilgisi("admin")!;
      await girisYap(page, hesap.email, hesap.password, "yonetim");
      await page.waitForURL(/\/yonetim/, { timeout: 30_000 });
    }

    const baglantilar = page.locator("aside nav a");
    await expect(baglantilar.first()).toBeVisible();
    expect(await baglantilar.count()).toBeGreaterThan(3);
  });
});
