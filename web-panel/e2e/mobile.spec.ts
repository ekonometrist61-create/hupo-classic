import { expect, test, type Page } from "@playwright/test";

// Telefon genişliği (iPhone 12–15 sınıfı). Projeden bağımsız olarak burada sabit.
test.use({ viewport: { width: 390, height: 844 }, hasTouch: true });

/** Sayfa yatay kaydırılabiliyorsa (taşma varsa) fark pozitif çıkar. */
async function yatayTasma(sayfa: Page) {
  return sayfa.evaluate(
    () => document.documentElement.scrollWidth - document.documentElement.clientWidth,
  );
}

test.describe("Mobil görünüm", () => {
  test("ana sayfada yatay kaydırma yok", async ({ page }) => {
    await page.goto("/");
    await expect(page.locator("main#main")).toBeVisible();
    expect(await yatayTasma(page)).toBeLessThanOrEqual(1);
  });

  test("giriş ekranında yatay kaydırma yok", async ({ page }) => {
    await page.goto("/signin");
    await expect(page.locator("#email")).toBeVisible();
    expect(await yatayTasma(page)).toBeLessThanOrEqual(1);
  });

  test("mobil menü açılıp kapanıyor", async ({ page }) => {
    await page.goto("/");
    const menuDugmesi = page.locator("header button[aria-expanded]");
    await expect(menuDugmesi).toBeVisible();
    await expect(menuDugmesi).toHaveAttribute("aria-expanded", "false");

    await menuDugmesi.click();
    await expect(menuDugmesi).toHaveAttribute("aria-expanded", "true");
    // Masaüstü menüsü telefonda gizli; görünen bağlantı mobil menüdendir.
    await expect(page.locator('header a[href="#pricing"]:visible')).toBeVisible();

    await menuDugmesi.click();
    await expect(menuDugmesi).toHaveAttribute("aria-expanded", "false");
  });

  test("giriş formu dokunma hedefleri en az 44px", async ({ page }) => {
    await page.goto("/signin");
    // Apple HIG ve Material önerisi: dokunma hedefi en az 44x44 px.
    for (const secici of ["#email", "#password", 'form button[type="submit"]']) {
      const kutu = await page.locator(secici).boundingBox();
      expect(kutu, `${secici} kutusu okunamadı`).not.toBeNull();
      expect(kutu!.height, `${secici} yüksekliği`).toBeGreaterThanOrEqual(44);
    }
  });
});
