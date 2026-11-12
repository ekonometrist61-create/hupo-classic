import { expect, test } from "@playwright/test";

import { girisYap, hesapBilgisi, karsilamaAtla } from "./helpers";

/**
 * GÖR-041: gerçek yönetici hesabıyla segmentli bildirim zinciri.
 * kaydet → ön kontrol → planla. Pazarlama push kapısı kapalıyken planlama yapılmaz (GÖR-031);
 * kapı kararı bu testte değiştirilmez. Test kampanyası ve segmenti bitişte iptal/arşivlenir.
 *
 * Ortam: E2E_ADMIN_EMAIL / E2E_ADMIN_PASSWORD, E2E_SB_URL, E2E_SB_ANON (git'e yazılmaz).
 * Çalıştırma (PowerShell): E2E_BASE_URL=https://hupolingo.com npx playwright test e2e/segmentli-bildirim-gercek-hesap.spec.ts --project=masaustu
 */
const SB_URL = process.env.E2E_SB_URL ?? "";
const SB_ANON = process.env.E2E_SB_ANON ?? "";
const SEGMENT_AD = `E2E test segmenti ${new Date().toISOString().slice(0, 16)}`;
const KAMPANYA_AD = `E2E test kampanyası ${new Date().toISOString().slice(11, 16)}`;

async function rpc<T = unknown>(token: string, fn: string, body: Record<string, unknown>): Promise<T> {
  const res = await fetch(`${SB_URL}/rest/v1/rpc/${fn}`, {
    method: "POST",
    headers: { apikey: SB_ANON, Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(`${fn} ${res.status}: ${await res.text()}`);
  return (await res.json()) as T;
}

async function adminToken(): Promise<string> {
  const hesap = hesapBilgisi("admin")!;
  const res = await fetch(`${SB_URL}/auth/v1/token?grant_type=password`, {
    method: "POST",
    headers: { apikey: SB_ANON, "Content-Type": "application/json" },
    body: JSON.stringify({ email: hesap.email, password: hesap.password }),
  });
  return ((await res.json()) as { access_token: string }).access_token;
}

test.describe("Yönetici - segmentli bildirim (gerçek hesap)", () => {
  // Testler sırayla çalışır: ikinci test birinci testin oluşturduğu kampanyaya bağlıdır.
  test.describe.configure({ mode: "serial" });
  test.skip(
    !hesapBilgisi("admin") || !SB_URL || !SB_ANON,
    "E2E_ADMIN_EMAIL, E2E_ADMIN_PASSWORD, E2E_SB_URL ve E2E_SB_ANON tanımlı değil.",
  );

  let segmentId = "";
  let kampanyaId = "";

  test.beforeAll(async () => {
    const token = await adminToken();
    segmentId = await rpc<string>(token, "admin_segment_kaydet", {
      p_id: null,
      p_ad: SEGMENT_AD,
      p_aciklama: "GÖR-041 uçtan uca test; otomatik temizlenir",
      p_kriterler: { ilk_gorev_bekleyen: true },
    });
  });

  test.afterAll(async () => {
    const token = await adminToken();
    if (kampanyaId) {
      await rpc(token, "admin_kampanya_iptal", { p_id: kampanyaId }).catch(() => undefined);
    }
    if (segmentId) {
      await rpc(token, "admin_segment_arsivle", { p_id: segmentId }).catch(() => undefined);
    }
  });

  test.beforeEach(async ({ page }) => {
    await karsilamaAtla(page);
    const hesap = hesapBilgisi("admin")!;
    await girisYap(page, hesap.email, hesap.password, "yonetim");
    await page.waitForURL(/\/yonetim(?!-giris)/, { timeout: 30_000 });
  });

  test("kaydet → ön kontrol: kapı kapalıyken planlama engellenir", async ({ page }) => {
    await page.goto("/yonetim/bildirimler");
    await expect(page.getByRole("status").filter({ hasText: "kapalı" })).toBeVisible({ timeout: 30_000 });

    await page.locator("#sb-segment").selectOption({ label: SEGMENT_AD });
    await page.locator("#sb-ad").fill(KAMPANYA_AD);
    await page.locator("#sb-baslik").fill("E2E test başlığı");
    await page.locator("#sb-mesaj").fill("E2E test mesajı, gönderilmez.");

    await page.getByRole("button", { name: "Ön kontrol yap" }).click();
    await expect(page.getByText("Ön kontrol sonucu")).toBeVisible({ timeout: 30_000 });
    await expect(page.getByText("Pazarlama push kapısı", { exact: false }).first()).toBeVisible();

    const planla = page.getByRole("button", { name: "Planla" });
    await expect(planla).toBeDisabled();
    await page.screenshot({ path: test.info().outputPath("segmentli-on-kontrol.png"), fullPage: true });

    const token = await adminToken();
    const liste = await rpc<Array<{ id: string; ad: string }>>(token, "admin_kampanya_listele", {});
    kampanyaId = liste.find((c) => c.ad === KAMPANYA_AD)?.id ?? "";
    expect(kampanyaId).not.toBe("");
  });

  test("sunucu tarafı: kapı kapalıyken planla RPC'si reddeder", async () => {
    // Arayüz düğmesine ek olarak sunucunun da planlamayı reddettiğini doğrular.
    const token = await adminToken();
    const liste = await rpc<Array<{ id: string; ad: string }>>(token, "admin_kampanya_listele", {});
    kampanyaId = liste.find((c) => c.ad === KAMPANYA_AD)?.id ?? kampanyaId;
    expect(kampanyaId).not.toBe("");

    const res = await fetch(`${SB_URL}/rest/v1/rpc/admin_kampanya_planla`, {
      method: "POST",
      headers: { apikey: SB_ANON, Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
      body: JSON.stringify({ p_id: kampanyaId }),
    });
    expect(res.ok).toBe(false);
  });
});
