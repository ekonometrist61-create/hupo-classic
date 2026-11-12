import { test } from "@playwright/test";
import { writeFileSync } from "node:fs";

import { girisYap, hesapBilgisi, karsilamaAtla } from "./helpers";

/**
 * GÖR-088 inceleme: gerçek veli hesabıyla destek planı sayfasının ekran görüntüsü ve metni.
 * Çıktı: E2E_SHOT_DIR klasörü (git dışı). Çalıştırma: E2E_BASE_URL=https://hupolingo.com npx playwright test e2e/destek-plani-ekran.spec.ts --project=masaustu
 */
const SHOT_DIR = process.env.E2E_SHOT_DIR ?? "";

test.describe("Destek planı ekran incelemesi", () => {
  test.skip(!hesapBilgisi("veli") || !SHOT_DIR, "E2E_VELI_* ve E2E_SHOT_DIR tanımlı değil.");

  test("masaüstü ve mobil görünüm", async ({ page }) => {
    await karsilamaAtla(page);
    const hesap = hesapBilgisi("veli")!;
    await girisYap(page, hesap.email, hesap.password);
    // Giriş sayfası da /veli-paneli altında; asıl kanıt kenar çubuğunun çıkmasıdır.
    await page.waitForSelector("aside a[href*='/veli-paneli/cocuklarim']", { timeout: 60_000 });

    await page.setViewportSize({ width: 1280, height: 900 });
    await page.goto("/veli-paneli/destek-plani");
    await page.waitForSelector("#veli-icerik", { timeout: 60_000 });
    await page.waitForTimeout(1500);
    await page.screenshot({ path: `${SHOT_DIR}/destek-masaustu.png`, fullPage: true });
    writeFileSync(`${SHOT_DIR}/destek-metin.txt`, await page.locator("#veli-icerik").innerText());

    await page.setViewportSize({ width: 390, height: 844 });
    await page.reload();
    await page.waitForSelector("#veli-icerik", { timeout: 60_000 });
    await page.waitForTimeout(1500);
    await page.screenshot({ path: `${SHOT_DIR}/destek-mobil.png`, fullPage: true });
    const yatay = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
    writeFileSync(`${SHOT_DIR}/destek-mobil-yatay-tasma.txt`, String(yatay));
  });
});
