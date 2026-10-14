import type { Page } from "@playwright/test";

/** E2E_DEMO=1 ile açılmış sunucu: oturum ve rol kontrolü kapalıdır (bkz. playwright.config.ts). */
export const DEMO = process.env.E2E_DEMO === "1";

/**
 * Test hesapları yalnızca ortam değişkenlerinden okunur; koda veya git'e yazılmaz
 * (AGENTS.md §5). Örnek (PowerShell):
 *   $env:E2E_ADMIN_EMAIL="..."; $env:E2E_ADMIN_PASSWORD="..."
 */
export function hesapBilgisi(rol: "admin" | "veli") {
  const email = process.env[rol === "admin" ? "E2E_ADMIN_EMAIL" : "E2E_VELI_EMAIL"];
  const password = process.env[rol === "admin" ? "E2E_ADMIN_PASSWORD" : "E2E_VELI_PASSWORD"];
  return email && password ? { email, password } : null;
}

/**
 * Karşılama ekranı (WelcomeSplash) tarayıcı oturumu başına bir kez çıkar ve
 * tıklamalarla çakışır. Testlerde işaretleyip atlıyoruz.
 */
export async function karsilamaAtla(page: Page) {
  await page.addInitScript(() => {
    try {
      window.sessionStorage.setItem("hupo-karsilama-gosterildi", "1");
    } catch {
      // Depolama kapalıysa karşılama çıkar; test yine de çalışır.
    }
  });
}

/**
 * Görünen giriş bağlantısını döndürür. Telefonda masaüstü menüsü gizlidir; bağlantı
 * yoksa mobil menü düğmesine basılıp bağlantı orada aranır.
 */
export async function girisBaglantisi(page: Page) {
  if ((await page.locator('a[href="/signin"]:visible').count()) === 0) {
    await page.locator("header button[aria-expanded]").click();
  }
  return page.locator('a[href="/signin"]:visible').first();
}

/** Giriş formunu doldurup gönderir. Başarı kontrolü çağıran testte yapılır. */
export async function girisYap(page: Page, email: string, password: string) {
  await page.goto("/signin");
  await page.locator("#email").fill(email);
  await page.locator("#password").fill(password);
  await page.locator('form button[type="submit"]').click();
}
