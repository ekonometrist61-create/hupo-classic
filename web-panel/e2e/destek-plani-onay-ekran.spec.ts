import { test } from "@playwright/test";
import { writeFileSync } from "node:fs";

import { girisYap, hesapBilgisi, karsilamaAtla } from "./helpers";

/**
 * GÖR-088 inceleme (onaylı): test veli hesabı, test çocuğu için veli onayını verir ve öneri
 * kartlarının ekran görüntüsünü ve metnini kaydeder. Yalnızca test hesabında çalışır.
 * Çıktı: E2E_SHOT_DIR (git dışı). Çalıştırma: E2E_BASE_URL=https://hupolingo.com npx playwright test e2e/destek-plani-onay-ekran.spec.ts --project=masaustu
 */
const SHOT_DIR = process.env.E2E_SHOT_DIR ?? "";

test.describe("Destek planı: onay sonrası içerik", () => {
  test.skip(!hesapBilgisi("veli") || !SHOT_DIR, "E2E_VELI_* ve E2E_SHOT_DIR tanımlı değil.");

  test("onay sonrası öneri kartları", async ({ page }) => {
    await karsilamaAtla(page);
    const hesap = hesapBilgisi("veli")!;
    await girisYap(page, hesap.email, hesap.password);
    await page.waitForSelector("aside a[href*='/veli-paneli/cocuklarim']", { timeout: 60_000 });

    await page.setViewportSize({ width: 1280, height: 900 });
    await page.goto("/veli-paneli/destek-plani");
    await page.waitForSelector("#veli-icerik", { timeout: 60_000 });
    await page.getByRole("button", { name: "Onay ver" }).click();
    await page.waitForTimeout(3000);

    await page.screenshot({ path: `${SHOT_DIR}/destek-onay-sonrasi.png`, fullPage: true });
    writeFileSync(`${SHOT_DIR}/destek-onay-sonrasi-metin.txt`, await page.locator("#veli-icerik").innerText());

    await page.setViewportSize({ width: 390, height: 844 });
    await page.reload();
    await page.waitForSelector("#veli-icerik", { timeout: 60_000 });
    await page.waitForTimeout(1500);
    await page.screenshot({ path: `${SHOT_DIR}/destek-onay-sonrasi-mobil.png`, fullPage: true });
    const yatay = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
    writeFileSync(`${SHOT_DIR}/destek-onay-mobil-yatay.txt`, String(yatay));
  });
});
