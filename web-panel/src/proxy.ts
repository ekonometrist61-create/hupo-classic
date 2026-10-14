import createMiddleware from "next-intl/middleware";
import { NextResponse, type NextRequest } from "next/server";

import { routing } from "./i18n/routing";
import { DEMO_MODE } from "./lib/demo-mode";
import { updateSession } from "./utils/supabase/proxy";

const APP_WEB_URL = "https://app.hupolingo.com";
const APP_LOGIN_PATHS = ["/signin", "/signup"];

/**
 * Zincirleme middleware:
 *   1. once next-intl yerel dil yonlendirmesini uygular,
 *   2. sonra Supabase oturum cookie'lerini yeniler.
 *
 * Yonetim sayfalari (`/yonetim`, `/veli-paneli`) giris zorunlu. Rol kontrolu
 * (veli mi, admin mi) sunucu tarafinda `useCurrentRole` ile yapilir; bu katman
 * yalnizca oturumun varligini dogrular.
 */
export default async function proxy(request: NextRequest) {
  const intlResponse = createMiddleware(routing)(request);
  // next-intl, localePrefix="never" ile /signin isteğini içerde /tr/signin
  // olarak yeniden yazar; Supabase cookie yenilemesini bu yanıt üzerinde tutarız.
  const { response, isAuthenticated } = await updateSession(
    request,
    intlResponse ?? NextResponse.next()
  );

  const { pathname } = request.nextUrl;
  // next-intl localePrefix="never" olsa da gelen isteklerde /tr veya /en
  // kalabildiğinden yetki kontrolleri önce yerelleştirme önekini temizler.
  const normalizedPathname = pathname.replace(/^\/(tr|en)(?=\/|$)/, "") || "/";

  // Kayıt ve giriş yalnızca uygulamada (app.hupolingo.com). hupolingo.com bir tanıtım
  // sitesi; buradaki giriş sayfaları uygulamaya yönlenir. Şifre kurtarma
  // (/sifre-unuttum, /sifre-yeni) bu listede değil: Flutter uygulamasının "Şifremi
  // unuttum" bağlantısı bu sayfalara gidiyor.
  if (APP_LOGIN_PATHS.includes(normalizedPathname)) {
    return NextResponse.redirect(APP_WEB_URL, 307);
  }

  // Yönetim ve veli paneli rotaları giriş ister. "/yonetim-giris" girişin kendisi
  // olduğu için korumalı sayılmaz; yoksa giriş sayfası kendi yönlendirmesine girer.
  const yonetimAlani =
    normalizedPathname === "/yonetim" || normalizedPathname.startsWith("/yonetim/");
  const veliAlani =
    normalizedPathname === "/veli-paneli" || normalizedPathname.startsWith("/veli-paneli/");
  const needsAuth = yonetimAlani || veliAlani;

  if (DEMO_MODE) return response;

  if (needsAuth && !isAuthenticated) {
    const url = request.nextUrl.clone();
    // Yönetim sayfaları kendi (sade) girişine, veli paneli veli girişine gider.
    url.pathname = yonetimAlani ? "/yonetim-giris" : "/signin";
    // Kullanılmayacak sayfanın yolunu geri dönüş için sakla.
    url.searchParams.set("next", normalizedPathname);
    return NextResponse.redirect(url);
  }

  // Giriş sayfası herkese açık bırakılır. Oturum açmış kullanıcı da burada
  // kalabilir; bu, next-intl'in localePrefix="never" yeniden yazmasıyla
  // yönlendirme döngüsü oluşmasını engeller.
  return response;
}

export const config = {
  matcher: ["/((?!api/|_next|_vercel|.*\\..*).*)"],
};
