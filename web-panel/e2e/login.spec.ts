import { expect, test, type Page } from "@playwright/test";

import { authHataAnahtari, authHataMetni, authMetni } from "../src/lib/auth/hata";
import { guvenliYonlendirme } from "../src/lib/auth/yonlendirme";
import { DEMO, girisYap, hesapBilgisi, KAPI_YOLU } from "./helpers";

// Rol uyuşmazlığında gösterilen nötr metin (hesabın hangi role ait olduğu söylenmez).
const ROL_UYUSMAZLIK_TR = authMetni("rolUyusmazlik", "tr");

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

  test("öğrenci hesabı reddedilir; hesap türü ve bağlantı gösterilmez", async ({ page }) => {
    await oturumTaklidi(page, "ogrenci@ornek.com", "ogrenci");
    await girisYap(page, "ogrenci@ornek.com", "parola-1234");

    const uyari = page.locator("#signin-error");
    await expect(uyari).toContainText(ROL_UYUSMAZLIK_TR);
    await expect(uyari).not.toContainText("app.hupolingo.com");
    await expect(uyari.locator("a")).toHaveCount(0);
    await expect(page).toHaveURL(/\/veli-paneli\/giris$/);
  });

  test("yönetici hesabı veli kapısında nötr mesajla reddedilir", async ({ page }) => {
    await oturumTaklidi(page, "admin@ornek.com", "admin");
    await girisYap(page, "admin@ornek.com", "parola-1234");

    const uyari = page.locator("#signin-error");
    await expect(uyari).toContainText(ROL_UYUSMAZLIK_TR);
    await expect(uyari).not.toContainText("Yönetim");
    await expect(page).toHaveURL(/\/veli-paneli\/giris$/);
  });

  test("Supabase hata kodu Türkçeye çevrilir (çok fazla deneme)", async ({ page }) => {
    await page.route(/\/auth\/v1\/token/, (rota) =>
      rota.fulfill({
        status: 429,
        contentType: "application/json",
        headers: { "access-control-allow-origin": "*", "access-control-allow-headers": "*" },
        body: JSON.stringify({
          code: 429,
          error_code: "over_request_rate_limit",
          msg: "Request rate limit reached",
        }),
      }),
    );

    await girisYap(page, "test@ornek.com", "yanlis-parola");

    const uyari = page.locator("#signin-error");
    await expect(uyari).toContainText("Çok fazla deneme");
    await expect(uyari).not.toContainText("rate");
  });

  test("tanınmayan Supabase hatası ham İngilizce metin göstermez", async ({ page }) => {
    await page.route(/\/auth\/v1\/token/, (rota) =>
      rota.fulfill({
        status: 500,
        contentType: "application/json",
        headers: { "access-control-allow-origin": "*", "access-control-allow-headers": "*" },
        body: JSON.stringify({
          code: 500,
          error_code: "unexpected_failure",
          msg: "Database error saving new user",
        }),
      }),
    );

    await girisYap(page, "test@ornek.com", "yanlis-parola");

    const uyari = page.locator("#signin-error");
    await expect(uyari).toContainText("İşlem tamamlanamadı");
    await expect(uyari).not.toContainText("Database");
  });

  test("gerçek veli hesabı ile giriş (yalnızca ortam değişkeni tanımlıysa)", async ({ page }) => {
    const hesap = hesapBilgisi("veli");
    test.skip(!hesap, "E2E_VELI_EMAIL ve E2E_VELI_PASSWORD tanımlı değil.");

    await girisYap(page, hesap!.email, hesap!.password);
    await page.waitForURL(/\/veli-paneli/, { timeout: 30_000 });
  });
});

test.describe("Giriş sonrası dönüş (next)", () => {
  // Ziyaret edilen tam adresleri toplar; açık yönlendirme varsa dış host burada görünür.
  function gidisleriIzle(page: Page): string[] {
    const adresler: string[] = [];
    page.on("framenavigated", (cerceve) => {
      if (cerceve === page.mainFrame()) adresler.push(cerceve.url());
    });
    return adresler;
  }

  function yonetimYolu(adres: string): boolean {
    const yol = new URL(adres).pathname;
    return yol === "/yonetim" || yol.startsWith("/yonetim/");
  }

  async function nextIleGiris(page: Page, next: string) {
    await page.goto(`/veli-paneli/giris?next=${encodeURIComponent(next)}`);
    await page.locator("#email").fill("veli@ornek.com");
    await page.locator("#password").fill("parola-1234");
    const profil = page.waitForResponse(/\/rest\/v1\/profiles/);
    await page.locator('form button[type="submit"]').click();
    await profil;
    await page.waitForLoadState("networkidle");
  }

  test("dış siteye (//) dönüş yapılmaz", async ({ page }) => {
    await oturumTaklidi(page, "veli@ornek.com", "veli");
    const adresler = gidisleriIzle(page);
    await nextIleGiris(page, "//saldiri.example.net");

    expect(adresler.some((adres) => new URL(adres).hostname === "saldiri.example.net")).toBe(false);
    expect(new URL(page.url()).hostname).not.toBe("saldiri.example.net");
  });

  test("aynı sitedeki kapı alanı yoluna dönülür", async ({ page }) => {
    await oturumTaklidi(page, "veli@ornek.com", "veli");
    await nextIleGiris(page, "/veli-paneli/hedef-test");

    // Oturum sunucuda geçerli olmadığı için proxy bizi tekrar giriş sayfasına alabilir;
    // her iki durumda da adreste hedef yol görünür (doğrudan ya da next parametresinde).
    await expect(page).toHaveURL(/hedef-test/);
  });

  test("veli girişi yönetim alanını next ile açamaz", async ({ page }) => {
    await oturumTaklidi(page, "veli@ornek.com", "veli");
    const adresler = gidisleriIzle(page);
    await nextIleGiris(page, "/yonetim/kullanicilar");

    expect(adresler.some(yonetimYolu)).toBe(false);
    expect(yonetimYolu(page.url())).toBe(false);
  });
});

test.describe("Saf yardımcılar (tarayıcı gerektirmez)", () => {
  const VELI = ["/veli-paneli"];
  const YONETIM = ["/yonetim"];

  test("güvenli yollar aynen kabul edilir", () => {
    expect(guvenliYonlendirme("/veli-paneli", VELI, "/x")).toBe("/veli-paneli");
    expect(guvenliYonlendirme("/veli-paneli/cocuk/haftalik?sekme=1", VELI, "/x")).toBe(
      "/veli-paneli/cocuk/haftalik?sekme=1",
    );
    expect(guvenliYonlendirme("/yonetim/kullanicilar", YONETIM, "/yonetim")).toBe(
      "/yonetim/kullanicilar",
    );
  });

  test("dış site, protokol ve kaçış denemeleri varsayılana düşer", () => {
    const denemeler = [
      "https://evil.example",
      "//evil.example",
      "/\\evil.example",
      "/\t/evil.example",
      "/\n/evil.example",
      "javascript:alert(1)",
      "veli-paneli/x",
      "/%2F%2Fevil.example",
      "/veli-paneli/%2e%2e/yonetim",
      "/veli-paneli/../yonetim",
      "/veli-paneli/giris",
      "/veli-paneli/kayit?x=1",
      "/yonetim",
      "/yonetim-giris",
      "/veli-paneliX",
      "",
    ];
    for (const aday of denemeler) {
      expect(guvenliYonlendirme(aday, VELI, "/veli-paneli"), aday).toBe("/veli-paneli");
    }
    expect(guvenliYonlendirme(null, VELI, "/veli-paneli")).toBe("/veli-paneli");
    expect(guvenliYonlendirme(undefined, VELI, "/veli-paneli")).toBe("/veli-paneli");
  });

  test("Supabase hatası kullanıcı metnine çevrilir; İngilizce metin sızmaz", () => {
    expect(authHataMetni({ code: "invalid_credentials", message: "Invalid login credentials" }, "tr")).toContain(
      "hatalı",
    );
    expect(authHataMetni({ code: "over_request_rate_limit" }, "tr")).toContain("Çok fazla deneme");
    expect(authHataMetni({ message: "Email not confirmed" }, "tr")).toContain("doğrulanmamış");
    expect(
      authHataMetni({ code: "weak_password", message: "Password should be at least 6 characters." }, "tr"),
    ).toContain("güçlü");
    expect(
      authHataMetni({ message: "New password should be different from the old password." }, "tr"),
    ).toContain("aynı");
    expect(authHataMetni({ code: "otp_expired" }, "tr")).toContain("süresi dolmuş");
    expect(authHataMetni({ code: "bilinmeyen", message: "Database error saving new user" }, "tr")).toBe(
      authMetni("genel", "tr"),
    );
    expect(authHataMetni(null, "tr")).toBe(authMetni("genel", "tr"));
  });

  test("en dili İngilizce metin döndürür", () => {
    expect(authHataMetni({ code: "invalid_credentials" }, "en")).toContain("incorrect");
  });

  test("kayıt çakışması hesap varlığını söylemeyen tek metne düşer", () => {
    expect(authHataAnahtari({ code: "user_already_exists" })).toBe("kayitNotr");
    expect(authHataAnahtari({ message: "User already registered" })).toBe("kayitNotr");
    expect(authMetni("kayitNotr", "tr")).toBe(
      "Kayıt isteğin alındı; e-postanı kontrol et. Hesabın varsa giriş yapabilir veya şifreni sıfırlayabilirsin",
    );
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

    await expect(page.locator("#signin-error")).toContainText(ROL_UYUSMAZLIK_TR);
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
