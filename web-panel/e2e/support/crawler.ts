import type { APIRequestContext, Page } from "@playwright/test";

/**
 * Tarayıcı gezgini (monkey test).
 *
 * Sayfadaki bağlantıları izler, görünür düğmelere/alanlara rastgele eylemlerde bulunur ve
 * şunları bulgu olarak kaydeder:
 *   - http-hata      : aynı kaynaktan 4xx/5xx yanıt (sayfa, görsel, script, RSC isteği)
 *   - konsol-hatasi  : console.error (React hydration hatası dahil)
 *   - sayfa-hatasi   : yakalanmamış JavaScript istisnası veya hata ekranı
 *   - ag-hatasi      : aynı kaynaktan başarısız istek veya açılamayan sayfa
 *   - kirik-baglanti : "#id" bağlantısının hedefi sayfada yok
 *   - dis-baglanti   : dış bağlantı 4xx/5xx dönüyor veya hiç çözülemiyor
 *
 * GÜVENLİK: Tarayıcı veri değiştiremez. GET dışındaki her istek ağ katmanında kesilir
 * (kayıt, ödeme, silme, oturum açma POST'ları dahil). Formlar hiç gönderilmez. Yıkıcı
 * etiketli düğmeler (sil, gönder, öde, onayla…) hiç tıklanmaz.
 */

export type BulguTuru =
  | "http-hata"
  | "konsol-hatasi"
  | "sayfa-hatasi"
  | "ag-hatasi"
  | "kirik-baglanti"
  | "dis-baglanti";

export interface Bulgu {
  tur: BulguTuru;
  sayfa: string;
  mesaj: string;
  /** Bulguya giden son eylemler (yeniden üretmek için). */
  eylemler: string[];
}

export interface TaramaSecenekleri {
  /** Başlangıç yolları, örn. ["/", "/signin"]. */
  tohumlar: string[];
  /** Ziyaret edilecek en fazla sayfa sayısı. */
  maksSayfa: number;
  /** Sayfa başına rastgele eylem sayısı. */
  maksEylem: number;
  /** Rastgele sayı üreteci tohumu; aynı tohum aynı eylem sırasını üretir. */
  tohum: number;
  /** Dış bağlantılar ayrıca kontrol edilsin mi. */
  disLinkKontrol: boolean;
  /** Bu etiketli öğelere asla tıklanmaz. Varsayılan: yıkıcı işlemler. */
  yasakliDesen?: RegExp;
  /** Toplam süre sınırı (ms). Dolunca tarama durur ve rapor yine yazılır. Varsayılan 10 dk. */
  sureSiniriMs?: number;
}

export interface TaramaSonucu {
  bulgular: Bulgu[];
  ziyaretEdilen: string[];
  /** Ağ katmanında engellenen yazma istekleri (bilgi amaçlı, hata değil). */
  engellenenYazmalar: string[];
  /** Tıklanamayan öğeler (bilgi amaçlı). */
  eylemHatasi: number;
  eylemSayisi: number;
  /** Süre sınırı dolduğu için tarama erken durdu mu. */
  sureSiniriDoldu: boolean;
}

const VARSAYILAN_YASAK =
  /sil|kald[ıi]r|g[öo]nder|yay[ıi]nla|[öo]de(?!me)|sat[ıi]n|onayla|reddet|iptal|[çc][ıi]k[ıi][şs]|logout|sign ?out|kaydet|olu[şs]tur|ekle|bağla|kopar|d[ıi][şs]a aktar|export|indir|ba[şs]lat|g[üu]ncelle|s[ıi]f[ıi]rla/i;

/**
 * Etkileşimli öğelerin seçicisi. Öğeler DOM'a özellik eklenmeden, sıra numarasıyla
 * (nth) bulunur; DOM'a yazmak hidrasyon uyarılarına yol açar.
 */
const ETKILESIM_SECICI =
  'a[href], button, input:not([type="hidden"]), select, textarea, [role="button"], [role="tab"], [role="switch"], [role="checkbox"], summary';

/** Tohumlu rastgele sayı üreteci (mulberry32). Sonuç [0, 1) aralığında. */
function rastgeleUretici(tohum: number): () => number {
  let s = tohum >>> 0;
  return () => {
    s = (s + 0x6d2b79f5) >>> 0;
    let t = s;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function sahteDeger(tip: string | null): string {
  switch (tip) {
    case "email":
      return "crawler@ornek.com";
    case "password":
      return "Gecici-Parola-1";
    case "number":
      return "1";
    case "tel":
      return "5555555555";
    case "date":
      return "2026-01-15";
    case "url":
      return "https://ornek.com";
    default:
      return "Test";
  }
}

/** Karşılaştırma için yolu normalize eder: sonda eğik çizgi ve kesit (#) atılır. */
function yolAnahtari(url: URL): string {
  const yol = url.pathname.length > 1 ? url.pathname.replace(/\/+$/, "") : url.pathname;
  return yol + url.search;
}

interface EtkilesimliOge {
  id: number;
  etiket: string;
  tur: string;
  tip: string | null;
  href: string | null;
  gonderim: boolean;
}

export async function tara(
  sayfa: Page,
  istek: APIRequestContext,
  kok: string,
  secenek: TaramaSecenekleri,
): Promise<TaramaSonucu> {
  const kokUrl = new URL(kok);
  const rnd = rastgeleUretici(secenek.tohum);
  const yasak = secenek.yasakliDesen ?? VARSAYILAN_YASAK;
  const bitis = Date.now() + (secenek.sureSiniriMs ?? 10 * 60_000);
  let sureSiniriDoldu = false;

  const bulgular: Bulgu[] = [];
  const bulguAnahtarlari = new Set<string>();
  const engellenen: string[] = [];
  const engellenenUrller = new Set<string>();
  const ziyaretEdilen: string[] = [];
  const ziyaretKumesi = new Set<string>();
  const kuyruk: string[] = secenek.tohumlar.map((y) => yolAnahtari(new URL(y, kokUrl)));
  const disLinkler = new Map<string, string>();
  const izler: string[] = [];
  let mevcutSayfa = "";
  let eylemSayisi = 0;
  let eylemHatasi = 0;

  const bul = (tur: BulguTuru, mesaj: string, sayfaYolu = mevcutSayfa) => {
    const anahtar = `${tur}|${sayfaYolu}|${mesaj}`;
    if (bulguAnahtarlari.has(anahtar)) return;
    bulguAnahtarlari.add(anahtar);
    bulgular.push({ tur, sayfa: sayfaYolu, mesaj, eylemler: izler.slice(-6) });
  };

  // Yazma koruması: GET/HEAD dışındaki her istek ağ katmanında kesilir.
  await sayfa.route("**/*", (rota) => {
    const istegi = rota.request();
    if (istegi.method() !== "GET" && istegi.method() !== "HEAD") {
      engellenen.push(`${istegi.method()} ${istegi.url()}`);
      engellenenUrller.add(istegi.url());
      return rota.abort("blockedbyclient");
    }
    return rota.continue();
  });

  // Beklenmeyen diyaloglar (confirm/alert) testi kilitlemesin.
  sayfa.on("dialog", (diyalog) => void diyalog.dismiss());
  sayfa.on("pageerror", (hata) => bul("sayfa-hatasi", hata.message.split("\n")[0]));
  sayfa.on("console", (mesaj) => {
    if (mesaj.type() !== "error") return;
    const metin = mesaj.text();
    // Kaynak yükleme hataları, yanıt olaylarında http-hata olarak zaten yakalanıyor.
    if (metin.startsWith("Failed to load resource")) return;
    bul("konsol-hatasi", metin.split("\n")[0].slice(0, 300));
  });
  sayfa.on("response", (yanit) => {
    const url = new URL(yanit.url());
    if (url.origin !== kokUrl.origin || yanit.status() < 400) return;
    bul("http-hata", `${yanit.status()} ${yanit.request().method()} ${url.pathname}${url.search}`);
  });
  sayfa.on("requestfailed", (istegi) => {
    const url = new URL(istegi.url());
    const hataMetni = istegi.failure()?.errorText ?? "bilinmeyen";
    if (url.origin !== kokUrl.origin || engellenenUrller.has(istegi.url())) return;
    // ERR_ABORTED: gezgin, tıklamanın başlattığı gezinmeyi kendisi iptal eder; uygulama hatası değil.
    if (hataMetni.includes("ERR_ABORTED")) return;
    bul("ag-hatasi", `${hataMetni} ${url.pathname}`);
  });

  async function sayfayaGit(anahtar: string): Promise<boolean> {
    try {
      await sayfa.goto(anahtar, { waitUntil: "domcontentloaded", timeout: 60_000 });
      await sayfa.waitForLoadState("networkidle", { timeout: 3_000 }).catch(() => undefined);
      return true;
    } catch (hata) {
      const satir = (hata as Error).message.split("\n")[0];
      // Gezgin kendi tıklamasını durdurup sayfayı geri yüklediğinde oluşan iptaller gürültüdür.
      const gezginKaynakli = satir.includes("ERR_ABORTED") || satir.includes("interrupted by another navigation");
      if (!gezginKaynakli) bul("ag-hatasi", `Sayfa açılamadı: ${satir}`, anahtar);
      return false;
    }
  }

  async function hataEkraniKontrolu() {
    const govde = await sayfa.locator("body").innerText().catch(() => "");
    if (/Application error|Unhandled Runtime Error|Something went wrong/i.test(govde)) {
      bul("sayfa-hatasi", "Sayfa hata ekranına düştü");
    }
  }

  async function etkilesimliOgeler(): Promise<EtkilesimliOge[]> {
    return sayfa.evaluate((secici) => {
      const liste: EtkilesimliOge[] = [];
      document.querySelectorAll<HTMLElement>(secici).forEach((el, index) => {
        const stil = getComputedStyle(el);
        const kutu = el.getBoundingClientRect();
        if (kutu.width === 0 || kutu.height === 0) return;
        if (stil.visibility === "hidden" || stil.display === "none") return;
        if ((el as HTMLButtonElement).disabled) return;
        const id = index;
        const etiket = (
          el.getAttribute("aria-label") ||
          el.getAttribute("title") ||
          el.textContent ||
          (el as HTMLInputElement).placeholder ||
          el.getAttribute("name") ||
          el.tagName
        )
          .trim()
          .replace(/\s+/g, " ")
          .slice(0, 80);
        const tur = el.tagName.toLowerCase();
        const tip = el.getAttribute("type");
        const gonderim =
          (tur === "button" && (tip ?? "submit") === "submit" && !!el.closest("form")) ||
          (tur === "input" && tip === "submit");
        liste.push({ id, etiket, tur, tip, href: el.getAttribute("href"), gonderim });
      });
      return liste;
    }, ETKILESIM_SECICI);
  }

  while (kuyruk.length > 0 && ziyaretEdilen.length < secenek.maksSayfa) {
    if (Date.now() > bitis) {
      sureSiniriDoldu = true;
      break;
    }
    const anahtar = kuyruk.shift()!;
    if (ziyaretKumesi.has(anahtar)) continue;
    ziyaretKumesi.add(anahtar);
    ziyaretEdilen.push(anahtar);
    mevcutSayfa = anahtar;
    izler.length = 0;
    izler.push(`GİT ${anahtar}`);

    if (!(await sayfayaGit(anahtar))) continue;
    await hataEkraniKontrolu();

    const sayfaUrl = new URL(sayfa.url());
    // Sayfa bu sırada yeniden yüklenirse (gezinme) bağlantı listesi boş kalır; tarama sürer.
    const baglantilar = await sayfa
      .evaluate(() =>
        Array.from(document.querySelectorAll<HTMLAnchorElement>("a[href]")).map((a) => ({
          href: a.getAttribute("href") ?? "",
          metin: (a.textContent ?? "").trim().slice(0, 60),
        })),
      )
      .catch(() => [] as { href: string; metin: string }[]);

    for (const { href, metin } of baglantilar) {
      if (!href || /^(javascript|mailto|tel):/i.test(href)) continue;
      let hedef: URL;
      try {
        hedef = new URL(href, sayfaUrl);
      } catch {
        continue;
      }
      if (hedef.origin !== kokUrl.origin) {
        if (secenek.disLinkKontrol && !disLinkler.has(hedef.href)) disLinkler.set(hedef.href, anahtar);
        continue;
      }
      if (hedef.hash && hedef.pathname === sayfaUrl.pathname) {
        const kimlik = decodeURIComponent(hedef.hash.slice(1));
        if (!kimlik) continue;
        const hedefVar = await sayfa.evaluate(
          (id) => !!document.getElementById(id) || !!document.querySelector(`[name="${CSS.escape(id)}"]`),
          kimlik,
        ).catch(() => true);
        if (!hedefVar) bul("kirik-baglanti", `#${kimlik} hedefi yok (bağlantı: "${metin}")`);
        continue;
      }
      const yeni = yolAnahtari(hedef);
      if (!ziyaretKumesi.has(yeni) && !kuyruk.includes(yeni)) kuyruk.push(yeni);
    }

    for (let adim = 0; adim < secenek.maksEylem; adim++) {
      if (Date.now() > bitis) {
        sureSiniriDoldu = true;
        break;
      }
      // Gezinme sırasında öğe listesi alınamazsa bu adım boş sayılır; sayfa bir sonrakinde yeniden açılır.
      const adaylar = (await etkilesimliOgeler().catch(() => [] as EtkilesimliOge[])).filter((o) => {
        if (yasak.test(o.etiket)) return false;
        if (o.gonderim) return false;
        if (o.href && /^(javascript|mailto|tel):/i.test(o.href)) return false;
        if (o.href && new URL(o.href, sayfaUrl).origin !== kokUrl.origin) return false;
        return true;
      });
      if (adaylar.length === 0) break;

      const secilen = adaylar[Math.floor(rnd() * adaylar.length)];
      const oge = sayfa.locator(ETKILESIM_SECICI).nth(secilen.id);
      const oncekiUrl = sayfa.url();
      izler.push(`${secilen.tur} "${secilen.etiket}"`);
      eylemSayisi++;

      try {
        if (secilen.tur === "select") {
          const secenekSayisi = await oge.locator("option").count();
          if (secenekSayisi > 1) {
            await oge.selectOption({ index: 1 + Math.floor(rnd() * (secenekSayisi - 1)) }, { timeout: 2_000 });
          }
        } else if (secilen.tur === "textarea" || secilen.tur === "input") {
          if (["checkbox", "radio"].includes(secilen.tip ?? "")) {
            await oge.click({ timeout: 2_000 });
          } else {
            await oge.fill(sahteDeger(secilen.tip), { timeout: 2_000 });
          }
        } else {
          await oge.click({ timeout: 2_000 });
        }
        await sayfa.waitForLoadState("domcontentloaded", { timeout: 5_000 }).catch(() => undefined);
        await sayfa.waitForTimeout(250);
      } catch (hata) {
        eylemHatasi++;
        izler.push(`   ↳ yapılamadı: ${(hata as Error).message.split("\n")[0].slice(0, 120)}`);
        continue;
      }

      const yeniUrl = new URL(sayfa.url());
      if (sayfa.url() !== oncekiUrl) {
        if (yeniUrl.origin !== kokUrl.origin) {
          izler.push(`   ↳ dış adrese gitti: ${yeniUrl.origin} (geri dönülüyor)`);
        } else {
          const yeniAnahtar = yolAnahtari(yeniUrl);
          if (!ziyaretKumesi.has(yeniAnahtar) && !kuyruk.includes(yeniAnahtar)) kuyruk.push(yeniAnahtar);
        }
        // Eylem sayfayı değiştirdi: aynı sayfaya dönüp kalan eylemlere devam edilir.
        await sayfayaGit(anahtar);
        izler.push("   ↩ sayfaya dönüldü");
      }
      await hataEkraniKontrolu();
    }
  }

  if (secenek.disLinkKontrol) {
    for (const [url, kaynak] of Array.from(disLinkler.entries()).slice(0, 40)) {
      try {
        const yanit = await istek.get(url, { timeout: 15_000, maxRedirects: 5, failOnStatusCode: false });
        if (yanit.status() >= 400) bul("dis-baglanti", `${yanit.status()} ${url}`, kaynak);
      } catch (hata) {
        bul("dis-baglanti", `erişilemiyor: ${url} (${(hata as Error).message.split("\n")[0]})`, kaynak);
      }
    }
  }

  return {
    bulgular,
    ziyaretEdilen,
    engellenenYazmalar: engellenen,
    eylemHatasi,
    eylemSayisi,
    sureSiniriDoldu,
  };
}
