import createMiddleware from "next-intl/middleware";
import { NextResponse, type NextRequest } from "next/server";

import { routing } from "./i18n/routing";
import { DEMO_MODE } from "./lib/demo-mode";
import { bakimDurumunuOku, bakimSayfaYolu, yuzeyBul } from "./lib/bakim";
import { updateSession } from "./utils/supabase/proxy";

// Giriş ve kayıt kapıları (hupolingo.com alt klasörleri). Öğrenci girişi app.hupolingo.com'da.
const VELI_GIRIS = "/veli-paneli/giris";
const VELI_KAYIT = "/veli-paneli/kayit";
const YONETIM_GIRIS = "/yonetim-giris";

// Eski adresler: yer imleri ve dış bağlantılar kırılmasın diye kalıcı yönlendirme.
const ESKI_YOLLAR: Record<string, string> = {
  "/signin": VELI_GIRIS,
  "/signup": VELI_KAYIT,
};

// Girişsiz erişilebilen kapılar; korumalı alan sayılmazlar.
const HERKESE_ACIK = new Set([VELI_GIRIS, VELI_KAYIT, YONETIM_GIRIS]);

/**
 * Her istek için taze nonce (16 bayt rastgele, base64). Sayfa başına sabit değil:
 * nonce tekrar kullanılırsa script-src koruması anlamsızlaşır.
 */
function nonceUret(): string {
  return Buffer.from(crypto.getRandomValues(new Uint8Array(16))).toString("base64");
}

/**
 * Sayfa belgeleri için CSP. script-src yalnız nonce ile inline script'e izin verir
 * ('unsafe-inline' yok). style-src bilerek değiştirilmedi (ayrı iş).
 */
function cspOlustur(nonce: string): string {
  const isDev = process.env.NODE_ENV === "development";
  return [
    "default-src 'self'",
    // Supabase API + Realtime
    "connect-src 'self' https://*.supabase.co wss://*.supabase.co https://eu.i.posthog.com https://eu-assets.i.posthog.com https://challenges.cloudflare.com",
    // Nonce'lu inline script'ler ve kendi alanımızdaki dosyalar. Next.js hot reload için
    // 'unsafe-eval' yalnızca geliştirmede açık (TASKS.md §11.3).
    `script-src 'self' 'nonce-${nonce}' https://challenges.cloudflare.com${isDev ? " 'unsafe-eval'" : ""}`,
    // Cloudflare Turnstile widget'ı iframe içinde çalışır (bot doğrulaması)
    "frame-src https://challenges.cloudflare.com",
    // Yazı tipleri next/font ile derleme sırasında kendi alanımıza alınır; tarayıcı Google'a istek atmaz.
    "style-src 'self' 'unsafe-inline'",
    "font-src 'self'",
    // Uygulama logoları ve kullanıcı avatarları (ileriki sürümde kısıtlanacak)
    "img-src 'self' data: blob: https://*.supabase.co",
    "frame-ancestors 'none'",
    "object-src 'none'",
    "base-uri 'self'",
    "form-action 'self'",
  ].join("; ");
}

/**
 * Zincirleme middleware:
 *   1. once next-intl yerel dil yonlendirmesini uygular,
 *   2. sonra Supabase oturum cookie'lerini yeniler.
 *
 * Yonetim (`/yonetim/*`) ve veli paneli (`/veli-paneli/*`) rotalari giris ister.
 * Bu katman yalnizca oturumun varligini dogrular; kapi bazli rol kontrolu giris
 * sayfasinda, yonetim bolumu ise kendi layout'unda yapilir.
 *
 * CSP nonce'u (Next.js proxy belgesi, "Adding a nonce with Proxy"): nonce isteğin
 * `content-security-policy` başlığına yazılır; Next.js sayfa işlenirken bu başlıktan
 * nonce'u okuyup kendi script etiketlerine ekler. Aynı başlık yanıta da konur.
 * Bu yüzden her yanıt dalı (rewrite dahil) başlığı taşımalıdır.
 */
export default async function proxy(request: NextRequest) {
  const nonce = nonceUret();
  const csp = cspOlustur(nonce);
  // İstek başlıklarını ilk satırda yazıyoruz: next-intl ve updateSession bu isteğin
  // başlıklarını kopyalayarak kendi yanıtlarını üretir.
  request.headers.set("x-nonce", nonce);
  request.headers.set("Content-Security-Policy", csp);

  const yanitaCsp = <T extends NextResponse>(yanit: T): T => {
    yanit.headers.set("Content-Security-Policy", csp);
    return yanit;
  };

  const intlResponse = createMiddleware(routing)(request);
  // next-intl, localePrefix="never" ile ic yolu /tr/... olarak yeniden yazar;
  // Supabase cookie yenilemesini bu yanit uzerinde tutariz.
  const { response, isAuthenticated, esAdmin } = await updateSession(
    request,
    intlResponse ?? NextResponse.next({ request: { headers: request.headers } })
  );

  const { pathname } = request.nextUrl;
  // localePrefix="never" olsa da gelen isteklerde /tr veya /en kalabilir;
  // yetki kontrolleri once yerellestirme onekini temizler.
  const normalizedPathname = pathname.replace(/^\/(tr|en)(?=\/|$)/, "") || "/";

  const eskiYol = ESKI_YOLLAR[normalizedPathname];
  if (eskiYol) {
    const url = request.nextUrl.clone();
    url.pathname = eskiYol;
    return NextResponse.redirect(url, 308);
  }

  // Bakım kapısı: yüzey kapalıysa bakım ekranına yeniden yazılır (URL aynı kalır).
  // Yönetici, yönetim yüzeyinde bakım sırasında da çalışabilir.
  const yuzey = yuzeyBul(normalizedPathname);
  if (yuzey) {
    const bakim = await bakimDurumunuOku();
    if (bakim?.yuzeyler[yuzey]) {
      const yoneticiGecer = yuzey === "yonetim" && isAuthenticated && (await esAdmin());
      if (!yoneticiGecer) {
        // Not: rewrite yanıtında durum kodu middleware'den değil hedef sayfadan gelir (200).
        // Bakım sayfası bu yüzden noindex'tir.
        // Rewrite'ta istek başlıkları açıkça verilir; yoksa bakım sayfasında nonce olmaz.
        const rewrite = yanitaCsp(
          NextResponse.rewrite(new URL(bakimSayfaYolu(yuzey), request.url), {
            request: { headers: request.headers },
          })
        );
        // Oturum cookie'leri (yenilenmiş olabilir) bakım yanıtına da taşınır.
        response.cookies.getAll().forEach((c) => rewrite.cookies.set(c));
        rewrite.headers.set("Cache-Control", "no-store");
        rewrite.headers.set("Retry-After", "300");
        return rewrite;
      }
    }
  }

  // "/yonetim-giris" ve "/veli-paneli/giris" kendi kapilari oldugu icin korumali degil;
  // aksi halde giris sayfasi kendi yonlendirmesine girer.
  const yonetimAlani =
    normalizedPathname === "/yonetim" || normalizedPathname.startsWith("/yonetim/");
  const veliAlani =
    (normalizedPathname === "/veli-paneli" || normalizedPathname.startsWith("/veli-paneli/")) &&
    !HERKESE_ACIK.has(normalizedPathname);
  const needsAuth = yonetimAlani || veliAlani;

  if (DEMO_MODE) return yanitaCsp(response);

  if (needsAuth && !isAuthenticated) {
    const url = request.nextUrl.clone();
    url.pathname = yonetimAlani ? YONETIM_GIRIS : VELI_GIRIS;
    // Giris sonrasi donus icin hedef yolu sakla (sorgu dizgisiyle birlikte).
    // Istemci (SignInForm) bu degeri yalnizca kapinin kendi alanindaysa kullanir.
    url.searchParams.set("next", `${normalizedPathname}${request.nextUrl.search}`);
    return NextResponse.redirect(url);
  }

  return yanitaCsp(response);
}

export const config = {
  matcher: ["/((?!api/|_next|_vercel|.*\\..*).*)"],
};
