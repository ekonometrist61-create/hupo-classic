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
 * Zincirleme middleware:
 *   1. once next-intl yerel dil yonlendirmesini uygular,
 *   2. sonra Supabase oturum cookie'lerini yeniler.
 *
 * Yonetim (`/yonetim/*`) ve veli paneli (`/veli-paneli/*`) rotalari giris ister.
 * Bu katman yalnizca oturumun varligini dogrular; kapi bazli rol kontrolu giris
 * sayfasinda, yonetim bolumu ise kendi layout'unda yapilir.
 */
export default async function proxy(request: NextRequest) {
  const intlResponse = createMiddleware(routing)(request);
  // next-intl, localePrefix="never" ile ic yolu /tr/... olarak yeniden yazar;
  // Supabase cookie yenilemesini bu yanit uzerinde tutariz.
  const { response, isAuthenticated, esAdmin } = await updateSession(
    request,
    intlResponse ?? NextResponse.next()
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
        const rewrite = NextResponse.rewrite(new URL(bakimSayfaYolu(yuzey), request.url));
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

  if (DEMO_MODE) return response;

  if (needsAuth && !isAuthenticated) {
    const url = request.nextUrl.clone();
    url.pathname = yonetimAlani ? YONETIM_GIRIS : VELI_GIRIS;
    // Giris sonrasi donus icin hedef yolu sakla (sorgu dizgisiyle birlikte).
    // Istemci (SignInForm) bu degeri yalnizca kapinin kendi alanindaysa kullanir.
    url.searchParams.set("next", `${normalizedPathname}${request.nextUrl.search}`);
    return NextResponse.redirect(url);
  }

  return response;
}

export const config = {
  matcher: ["/((?!api/|_next|_vercel|.*\\..*).*)"],
};
