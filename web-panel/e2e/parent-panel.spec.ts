import { expect, test, type Page } from "@playwright/test";

import { DEMO, girisYap, hesapBilgisi, karsilamaAtla } from "./helpers";

test.describe("Veli paneli", () => {
  // Demo modunda hesap gerekmez; değilse veli hesabı ortam değişkenlerinde olmalı.
  test.skip(!DEMO && !hesapBilgisi("veli"), "E2E_VELI_EMAIL ve E2E_VELI_PASSWORD tanımlı değil.");

  test.beforeEach(async ({ page }) => {
    await karsilamaAtla(page);
  });

  /** Veli sayfasını açar: demo modunda doğrudan, değilse veli hesabıyla giriş yaparak. */
  async function veliPaneliniAc(sayfa: Page, yol: string) {
    if (DEMO) {
      await sayfa.goto(yol);
      return;
    }
    const hesap = hesapBilgisi("veli")!;
    await girisYap(sayfa, hesap.email, hesap.password);
    await sayfa.waitForURL(/\/veli-paneli/, { timeout: 30_000 });
    if (yol !== "/veli-paneli") await sayfa.goto(yol);
  }

  test("ana sayfa açılıyor ve kenar çubuğu görünüyor", async ({ page }) => {
    await veliPaneliniAc(page, "/veli-paneli");

    await expect(page.locator("aside").first()).toBeVisible();
    await expect(page.locator("#veli-icerik")).toBeVisible();
    await expect(page.locator("#veli-icerik")).not.toBeEmpty();
  });

  test("veli paneli yönetim kabuğunu kullanmıyor", async ({ page }) => {
    await veliPaneliniAc(page, "/veli-paneli");

    // Yönetim düzeni (#icerik) veli sayfalarında hiç render edilmemeli.
    await expect(page.locator("#veli-icerik")).toBeVisible();
    await expect(page.locator("#icerik")).toHaveCount(0);
  });

  for (const yol of ["/veli-paneli/dersler", "/veli-paneli/denemeler", "/veli-paneli/uyelik"]) {
    test(`alt sayfa açılıyor: ${yol}`, async ({ page }) => {
      await veliPaneliniAc(page, yol);
      await expect(page).toHaveURL(new RegExp(`${yol}$`));
      await expect(page.locator("#veli-icerik")).toBeVisible();
    });
  }
});
