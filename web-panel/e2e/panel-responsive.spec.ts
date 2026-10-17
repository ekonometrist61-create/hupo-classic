import { expect, test, type Page } from "@playwright/test";

import { DEMO, karsilamaAtla } from "./helpers";

// Kabul ölçütü (TASKS §20): tüm panel rotaları telefon ve tablet genişliğinde
// yatay taşmadan açılmalı; mobilde kontroller ≥44 px, girdiler ≥16 px olmalı.
// Yalnızca demo modunda çalışır (sahte veri, yerel sunucu): E2E_DEMO=1.

const GENISLIKLER = [
  { ad: "telefon", width: 390, height: 844 },
  { ad: "tablet-dik", width: 768, height: 1024 },
  { ad: "tablet-yatay", width: 1024, height: 768 },
] as const;

const YONETIM_YOLLARI = [
  "/yonetim",
  "/yonetim/analitik",
  "/yonetim/anketler",
  "/yonetim/ai-oneriler",
  "/yonetim/ayarlar",
  "/yonetim/bildirimler",
  "/yonetim/crm-gorevler",
  "/yonetim/denemeler",
  "/yonetim/deneme-sinavlari",
  "/yonetim/destek-masasi",
  "/yonetim/duyurular",
  "/yonetim/ekip",
  "/yonetim/ekip-akisi",
  "/yonetim/gorevler",
  "/yonetim/growth-analitik",
  "/yonetim/journey-otomasyonlari",
  "/yonetim/kanal-ayarlari",
  "/yonetim/karakterler",
  "/yonetim/kelime-evreni",
  "/yonetim/kimlik-eslestirme",
  "/yonetim/kampanyalar",
  "/yonetim/kullanicilar",
  "/yonetim/kuponlar",
  "/yonetim/ligler",
  "/yonetim/mesaj-sablonlari",
  "/yonetim/musteri-360",
  "/yonetim/odemeler",
  "/yonetim/otomasyonlar",
  "/yonetim/planlar",
  "/yonetim/potansiyel-adaylar",
  "/yonetim/rozetler",
  "/yonetim/satis-hatti",
  "/yonetim/segmentler",
  "/yonetim/siniflar",
  "/yonetim/site-icerik",
  "/yonetim/sorular",
  "/yonetim/sorular/toplu-ekle",
  "/yonetim/veli-adaylari",
];

const VELI_YOLLARI = [
  "/veli-paneli",
  "/veli-paneli/basarilar",
  "/veli-paneli/dersler",
  "/veli-paneli/denemeler",
  "/veli-paneli/hedefler",
  "/veli-paneli/aktivite",
  "/veli-paneli/tekrar",
  "/veli-paneli/uyelik",
];

const GIRIS_YOLLARI = ["/yonetim-giris", "/veli-paneli/giris", "/veli-paneli/kayit"];

const TUM_YOLLAR = [...YONETIM_YOLLARI, ...VELI_YOLLARI, ...GIRIS_YOLLARI];

/** Sayfa düzeyinde taşma ve kaydırılabilir kapsayıcı dışında viewport'tan taşan öğeler. */
async function tasmaRaporu(page: Page) {
  return page.evaluate(() => {
    const genislik = document.documentElement.clientWidth;
    const sayfaTasmasi = document.documentElement.scrollWidth - genislik;

    const kaydirilirMi = (el: HTMLElement) => {
      for (let n: HTMLElement | null = el; n; n = n.parentElement) {
        const ox = getComputedStyle(n).overflowX;
        if (ox === "auto" || ox === "scroll" || ox === "hidden") return true;
      }
      return false;
    };

    const tasanlar: string[] = [];
    for (const el of Array.from(document.querySelectorAll<HTMLElement>("body *"))) {
      const r = el.getBoundingClientRect();
      if (r.width === 0 || r.height === 0) continue;
      if (r.right > genislik + 1 && r.left < genislik && !kaydirilirMi(el)) {
        tasanlar.push(`${el.tagName.toLowerCase()}.${String(el.className).slice(0, 60)}`);
        if (tasanlar.length >= 5) break;
      }
    }
    return { sayfaTasmasi, tasanlar };
  });
}

/** Mobilde girdi yazı boyutu 16 px'den küçükse iOS odakta sayfayı yakınlaştırır. */
async function kucukGirdiler(page: Page) {
  return page.evaluate(() => {
    const sonuc: string[] = [];
    for (const el of Array.from(document.querySelectorAll<HTMLElement>("input, select, textarea"))) {
      const r = el.getBoundingClientRect();
      if (r.width === 0 || r.height === 0) continue;
      const tip = (el as HTMLInputElement).type;
      if (tip === "checkbox" || tip === "radio" || tip === "hidden") continue;
      if (parseFloat(getComputedStyle(el).fontSize) < 16) {
        sonuc.push(`${el.tagName.toLowerCase()}#${el.id || el.getAttribute("name") || "?"}`);
        if (sonuc.length >= 5) break;
      }
    }
    return sonuc;
  });
}

/** Üst çubuktaki görünür düğmeler en az 44 px olmalı (dokunma hedefi). */
async function kucukUstDugmeler(page: Page) {
  return page.evaluate(() => {
    const sonuc: string[] = [];
    for (const el of Array.from(document.querySelectorAll<HTMLElement>("header button"))) {
      const r = el.getBoundingClientRect();
      if (r.width === 0 || r.height === 0) continue;
      if (r.width < 44 || r.height < 44) {
        sonuc.push(`${Math.round(r.width)}x${Math.round(r.height)} ${el.getAttribute("aria-label") ?? el.textContent?.trim().slice(0, 20) ?? ""}`);
      }
    }
    return sonuc;
  });
}

test.describe("Panel mobil ve tablet uyumluluğu (TASKS §20)", () => {
  test.skip(!DEMO, "Yalnızca E2E_DEMO=1 ile (yerel, sahte veri) çalışır.");
  test.setTimeout(240_000);

  for (const yol of TUM_YOLLAR) {
    test(`${yol}: üç genişlikte yatay taşma yok`, async ({ page }) => {
      await karsilamaAtla(page);
      const bulgular: string[] = [];

      for (const g of GENISLIKLER) {
        await page.setViewportSize({ width: g.width, height: g.height });
        await page.goto(yol, { waitUntil: "domcontentloaded" });
        await page.waitForLoadState("networkidle", { timeout: 20_000 }).catch(() => undefined);

        const tasma = await tasmaRaporu(page);
        if (tasma.sayfaTasmasi > 1) {
          bulgular.push(`[${g.ad} ${g.width}px] sayfa ${tasma.sayfaTasmasi}px taşıyor`);
        }
        if (tasma.tasanlar.length > 0) {
          bulgular.push(`[${g.ad} ${g.width}px] viewport dışı öğeler: ${tasma.tasanlar.join(" | ")}`);
        }

        if (g.width === 390) {
          const girdi = await kucukGirdiler(page);
          if (girdi.length > 0) bulgular.push(`[telefon] 16px altı girdi: ${girdi.join(", ")}`);
          const dugme = await kucukUstDugmeler(page);
          if (dugme.length > 0) bulgular.push(`[telefon] 44px altı üst düğme: ${dugme.join(" | ")}`);
        }
      }

      expect(bulgular, bulgular.join("\n")).toHaveLength(0);
    });
  }

  test("veli paneli telefonda menü düğmesiyle açılır ve kapanır", async ({ page }) => {
    await karsilamaAtla(page);
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto("/veli-paneli", { waitUntil: "domcontentloaded" });

    // Sözleşme: mobil menü düğmesi data-mobil-menu özniteliğine sahiptir (P1).
    const dugme = page.locator("[data-mobil-menu]");
    await expect(dugme).toBeVisible();
    await expect(dugme).toHaveAttribute("aria-expanded", "false");

    await dugme.click();
    await expect(dugme).toHaveAttribute("aria-expanded", "true");
    await expect(page.locator('aside a[href="/veli-paneli/dersler"]')).toBeVisible();

    // Menü açıkken arka plan perdesi (z-40) düğmenin üstüne gelir; kapatma perdeye dokunarak olur.
    await page.mouse.click(370, 400);
    await expect(dugme).toHaveAttribute("aria-expanded", "false");
  });
});
