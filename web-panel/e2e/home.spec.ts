import { expect, test } from "@playwright/test";

import { girisBaglantisi } from "./helpers";

test.describe("Ana sayfa", () => {
  test("açılıyor, başlık ve giriş/deneme bağlantıları görünüyor", async ({ page }) => {
    const sayfaHatalari: Error[] = [];
    page.on("pageerror", (hata) => sayfaHatalari.push(hata));

    const yanit = await page.goto("/");
    expect(yanit?.ok()).toBeTruthy();

    await expect(page.locator("main#main")).toBeVisible();
    await expect(page.getByRole("heading", { level: 1 })).toBeVisible();
    await expect(await girisBaglantisi(page)).toBeVisible();
    await expect(page.locator('a[href="/demo"]:visible').first()).toBeVisible();

    // Yakalanmamış JavaScript hataları sayfanın bozulduğunu gösterir.
    expect(sayfaHatalari).toEqual([]);
  });

  test("sayfa başlığı (title) boş değil", async ({ page }) => {
    await page.goto("/");
    await expect(page).toHaveTitle(/.+/);
  });

  test("giriş ekranına bağlantı çalışıyor", async ({ page }) => {
    await page.goto("/");
    await (await girisBaglantisi(page)).click();
    await expect(page).toHaveURL(/\/veli-paneli\/giris$/);
    await expect(page.locator("#email")).toBeVisible();
  });
});
