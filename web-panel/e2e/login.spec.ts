import { expect, test, type Page } from "@playwright/test";

import { DEMO, girisYap, hesapBilgisi, KAPI_YOLU } from "./helpers";

// Supabase Auth ve profil yanıtlarını taklit eder. Giriş formu tarayıcıdan Supabase'e
// gider, bu yüzden yönlendirme (page.route) ile yanıtlanır. Sunucu tarafı kontroller
// (proxy, layout) gerçek Supabase'e gittiği için bu testler yalnızca giriş kapısındaki
// davranışı (rol reddi, yönlendirme, mesaj) kapsar.
const KULLANICI_ID = "00000000-0000-4000-8000-000000000001";

function sahteOturum(email: string) {
  const b64 = (nesne: object) => Buffer.from(JSON.stringify(nesne)).toString("base64url");
  const exp = Math.floor(Date.now() / 1000) + 3600;
  const access_token = `${b64({ alg: "HS256", typ: "JWT" })}.${b64({
    sub: KULLANICI_ID,
    exp,
    role: "authenticated",
    aud: "authenticated",
  })}.sahte`;
  return {
    access_token,
    token_type: "bearer",
    expires_in: 3600,
    expires_at: exp,
    refresh_token: "sahte-yenileme",
    user: {
      id: KULLANICI_ID,
      aud: "authenticated",
      role: "authenticated",
      email,
      app_metadata: {},
      user_metadata: {},
      identities: [],
      created_at: "2026-10-01T00:00:00Z",
    },
  };
}

async function oturumTaklidi(page: Page, email: string, rol: string) {
  await page.route(/\/auth\/v1\/token/, (rota) =>
    rota.fulfill({
      status: 200,
      contentType: "application/json",
      headers: { "access-control-allow-origin": "*", "access-control-allow-headers": "*" },
      body: JSON.stringify(sahteOturum(email)),
    }),
  );
  await page.route(/\/rest\/v1\/profiles/, (rota) =>
    rota.fulfill({
      status: 200,
      contentType: "application/json",
      headers: { "access-control-allow-origin": "*", "access-control-allow-headers": "*" },
      body: JSON.stringify({ role: rol }),
    }),
  );
  await page.route(/\/auth\/v1\/logout/, (rota) =>
    rota.fulfill({
      status: 204,
      headers: { "access-control-allow-origin": "*", "access-control-allow-headers": "*" },
      body: "",
    }),
  );
}

test.describe("Veli giriş kapısı", () => {
  test("form alanları ve giriş butonu görünüyor", async ({ page }) => {
    await page.goto("/veli-paneli/giris");
    await expect(page.locator("#email")).toBeVisible();
    await expect(page.locator("#password")).toBeVisible();
    await expect(page.locator('form button[type="submit"]')).toBeVisible();
  });

  test("boş form gönderilmiyor (zorunlu alan kontrolü)", async ({ page }) => {
    await page.goto("/veli-paneli/giris");
    await page.locator('form button[type="submit"]').click();

    await expect(page).toHaveURL(/\/veli-paneli\/giris$/);
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

  test("öğrenci hesabı reddedilir ve app.hupolingo.com bağlantısı gösterilir", async ({ page }) => {
    await oturumTaklidi(page, "ogrenci@ornek.com", "ogrenci");
    await girisYap(page, "ogrenci@ornek.com", "parola-1234");

    const uyari = page.locator("#signin-error");
    await expect(uyari).toContainText("app.hupolingo.com");
    await expect(uyari.locator("a")).toHaveAttribute("href", /app\.hupolingo\.com/);
    await expect(page).toHaveURL(/\/veli-paneli\/giris$/);
  });

  test("yönetici hesabı veli kapısında reddedilir", async ({ page }) => {
    await oturumTaklidi(page, "admin@ornek.com", "admin");
    await girisYap(page, "admin@ornek.com", "parola-1234");

    await expect(page.locator("#signin-error")).toContainText("Yönetim girişi");
    await expect(page).toHaveURL(/\/veli-paneli\/giris$/);
  });

  test("gerçek veli hesabı ile giriş (yalnızca ortam değişkeni tanımlıysa)", async ({ page }) => {
    const hesap = hesapBilgisi("veli");
    test.skip(!hesap, "E2E_VELI_EMAIL ve E2E_VELI_PASSWORD tanımlı değil.");

    await girisYap(page, hesap!.email, hesap!.password);
    await page.waitForURL(/\/veli-paneli/, { timeout: 30_000 });
  });
});

test.describe("Yönetim giriş kapısı", () => {
  test("form ve kurumsal başlık görünüyor", async ({ page }) => {
    await page.goto(KAPI_YOLU.yonetim);
    await expect(page.locator("#email")).toBeVisible();
    await expect(page.getByRole("heading", { name: "Hupolingo Yönetim Paneli" })).toBeVisible();
  });

  test("sayfa arama motorlarına kapalı", async ({ page }) => {
    await page.goto(KAPI_YOLU.yonetim);
    await expect(page.locator('meta[name="robots"]')).toHaveAttribute("content", /noindex/);
  });

  test("veli hesabı yönetim kapısında reddedilir", async ({ page }) => {
    await oturumTaklidi(page, "veli@ornek.com", "veli");
    await girisYap(page, "veli@ornek.com", "parola-1234", "yonetim");

    await expect(page.locator("#signin-error")).toContainText("yetkili değil");
    await expect(page).toHaveURL(/\/yonetim-giris$/);
  });

  test("gerçek yönetici hesabı ile giriş (yalnızca ortam değişkeni tanımlıysa)", async ({ page }) => {
    const hesap = hesapBilgisi("admin");
    test.skip(!hesap, "E2E_ADMIN_EMAIL ve E2E_ADMIN_PASSWORD tanımlı değil.");

    await girisYap(page, hesap!.email, hesap!.password, "yonetim");
    await page.waitForURL(/\/yonetim/, { timeout: 30_000 });
  });
});

test.describe("Eski adresler ve korumalı sayfalar", () => {
  test("/signin veli giriş kapısına kalıcı yönlendirilir", async ({ page }) => {
    await page.goto("/signin");
    await expect(page).toHaveURL(/\/veli-paneli\/giris$/);
  });

  test("/signup veli kayıt ekranına kalıcı yönlendirilir", async ({ page }) => {
    await page.goto("/signup");
    await expect(page).toHaveURL(/\/veli-paneli\/kayit$/);
  });

  test("veli kayıt ekranı açılıyor", async ({ page }) => {
    await page.goto("/veli-paneli/kayit");
    await expect(page.locator("#email")).toBeVisible();
  });

  test.describe("oturum kontrolü", () => {
    // Demo modunda proxy oturum kontrolünü bilerek atlar; bu testler anlamsız olur.
    test.skip(DEMO, "Demo modunda oturum kontrolü kapalı.");

    test("oturum yokken /yonetim yönetim girişine yönlendiriliyor", async ({ page }) => {
      await page.goto("/yonetim");
      await expect(page).toHaveURL(/\/yonetim-giris\?next=/);
    });

    test("oturum yokken /veli-paneli veli girişine yönlendiriliyor", async ({ page }) => {
      await page.goto("/veli-paneli");
      await expect(page).toHaveURL(/\/veli-paneli\/giris\?next=/);
    });
  });
});
