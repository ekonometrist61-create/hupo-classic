import { expect, test } from "@playwright/test";

import { DEMO, girisYap, hesapBilgisi } from "./helpers";

test.describe("Giriş ekranı", () => {
  test("form alanları ve giriş butonu görünüyor", async ({ page }) => {
    await page.goto("/signin");
    await expect(page.locator("#email")).toBeVisible();
    await expect(page.locator("#password")).toBeVisible();
    await expect(page.locator('form button[type="submit"]')).toBeVisible();
  });

  test("boş form gönderilmiyor (zorunlu alan kontrolü)", async ({ page }) => {
    await page.goto("/signin");
    await page.locator('form button[type="submit"]').click();

    await expect(page).toHaveURL(/\/signin$/);
    const eksik = await page
      .locator("#email")
      .evaluate((el: HTMLInputElement) => el.validity.valueMissing);
    expect(eksik).toBe(true);
  });

  test("yanlış bilgilerde hata mesajı gösteriliyor", async ({ page }) => {
    // Gerçek Supabase Auth'a istek gitmesin diye yanıt taklit edilir.
    // CORS başlıkları şart: yoksa tarayıcı yanıtı atar ve hata mesajı hiç çıkmaz.
    await page.route(/\/auth\/v1\/token/, (rota) =>
      rota.fulfill({
        status: 400,
        contentType: "application/json",
        headers: {
          "access-control-allow-origin": "*",
          "access-control-allow-headers": "*",
          "access-control-allow-methods": "*",
        },
        body: JSON.stringify({
          code: 400,
          error_code: "invalid_credentials",
          msg: "Invalid login credentials",
        }),
      }),
    );

    await girisYap(page, "test@ornek.com", "yanlis-parola");

    await expect(page.locator("#signin-error")).toBeVisible();
    await expect(page.locator("#signin-error")).toContainText("hatalı");
  });

  test("admin hesabıyla giriş yönetim paneline yönlendiriyor", async ({ page }) => {
    const hesap = hesapBilgisi("admin");
    test.skip(!hesap, "E2E_ADMIN_EMAIL ve E2E_ADMIN_PASSWORD tanımlı değil.");

    await girisYap(page, hesap!.email, hesap!.password);
    await page.waitForURL(/\/yonetim/, { timeout: 30_000 });
  });

  test("veli hesabıyla giriş veli paneline yönlendiriyor", async ({ page }) => {
    const hesap = hesapBilgisi("veli");
    test.skip(!hesap, "E2E_VELI_EMAIL ve E2E_VELI_PASSWORD tanımlı değil.");

    await girisYap(page, hesap!.email, hesap!.password);
    await page.waitForURL(/\/veli-paneli/, { timeout: 30_000 });
  });
});

test.describe("Korumalı sayfalar", () => {
  // Demo modunda proxy oturum kontrolünü bilerek atlar; bu test anlamsız olur.
  test.skip(DEMO, "Demo modunda oturum kontrolü kapalı.");

  const yonlendirmeler: [string, RegExp][] = [
    ["/yonetim", /\/yonetim-giris\?next=/],
    ["/veli-paneli", /\/signin\?next=/],
  ];
  for (const [yol, beklenen] of yonlendirmeler) {
    test(`oturum yokken ${yol} giriş ekranına yönlendiriliyor`, async ({ page }) => {
      await page.goto(yol);
      await expect(page).toHaveURL(beklenen);
    });
  }
});
