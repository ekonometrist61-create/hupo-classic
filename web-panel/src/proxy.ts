import createMiddleware from "next-intl/middleware";
import { NextResponse, type NextRequest } from "next/server";

import { routing } from "./i18n/routing";
import { DEMO_MODE } from "./lib/demo-mode";
import { updateSession } from "./utils/supabase/proxy";

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
  const needsAuth =
    normalizedPathname.startsWith("/yonetim") ||
    normalizedPathname.startsWith("/veli-paneli");

  if (DEMO_MODE) return response;

  if (needsAuth && !isAuthenticated) {
    const url = request.nextUrl.clone();
    url.pathname = "/signin";
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
