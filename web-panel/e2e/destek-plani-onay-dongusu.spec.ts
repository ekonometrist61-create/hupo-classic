import { expect, test } from "@playwright/test";

import { girisYap, hesapBilgisi, karsilamaAtla } from "./helpers";

/**
 * GÖR-088: onay verildikten sonra destek planı içeriğinin sayfa yenilemeden görünüp görünmediği.
 * Test çocuğu için onay verir, kontrol eder, yeniden yükler, sonra onayı geri çekerek başlangıç durumuna döner.
 * Yalnızca test hesabında çalışır. Çalıştırma: E2E_BASE_URL=https://hupolingo.com npx playwright test e2e/destek-plani-onay-dongusu.spec.ts --project=masaustu
 */
const BOS_DURUM = /Bu hafta öncelikli bir destek alanı görünmüyor|Bu hafta öncelikli/;

test.describe("Destek planı: onay döngüsü", () => {
  test.skip(!hesapBilgisi("veli"), "E2E_VELI_EMAIL ve E2E_VELI_PASSWORD tanımlı değil.");

  test("onay sonrası içerik yenilemeden görünür; onay geri çekilir", async ({ page }) => {
    test.setTimeout(120_000);
    await karsilamaAtla(page);
    const hesap = hesapBilgisi("veli")!;
    await girisYap(page, hesap.email, hesap.password);
    await page.waitForSelector("aside a[href*='/veli-paneli/cocuklarim']", { timeout: 60_000 });

    await page.setViewportSize({ width: 1280, height: 900 });
    await page.goto("/veli-paneli/destek-plani");
    await page.waitForSelector("#veli-icerik", { timeout: 60_000 });

    // Önceki bir koşudan kalan onayı geri çekerek her koşuyu aynı başlangıç durumunda başlat.
    const geriCek = page.getByRole("button", { name: "Onayı geri çek" });
    if (await geriCek.isVisible()) {
      await geriCek.click();
      await expect(page.getByText("Onay bekleniyor")).toBeVisible({ timeout: 30_000 });
    }

    await page.getByRole("button", { name: "Onay ver" }).click();
    await expect(page.getByText("Onay verildi")).toBeVisible({ timeout: 30_000 });
    await page.waitForTimeout(3000);
    const yenilemedenGorunur = await page.locator("#veli-icerik").innerText().then((t) => BOS_DURUM.test(t));

    await page.reload();
    await page.waitForSelector("#veli-icerik", { timeout: 60_000 });
    await expect(page.getByText("Onay verildi")).toBeVisible({ timeout: 30_000 });
    await page.waitForTimeout(2000);
    const yenilemeSonrasiGorunur = await page.locator("#veli-icerik").innerText().then((t) => BOS_DURUM.test(t));

    console.log(`YENILEMEDEN_GORUNUR=${yenilemedenGorunur} YENILEME_SONRASI_GORUNUR=${yenilemeSonrasiGorunur}`);

    await page.getByRole("button", { name: "Onayı geri çek" }).click();
    await expect(page.getByRole("button", { name: "Onay ver" })).toBeVisible({ timeout: 30_000 });

    expect(yenilemeSonrasiGorunur, "yenilemeden sonra öneri bölümü görünmeli").toBe(true);
    expect(yenilemedenGorunur, "onaydan hemen sonra öneri bölümü görünmeli").toBe(true);
  });
});
