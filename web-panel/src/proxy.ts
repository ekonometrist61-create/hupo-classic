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
const PUBLIC_PREFIXES = ["/signin", "/signup", "/error-404"];

function isPublic(pathname: string): boolean {
  return PUBLIC_PREFIXES.some((p) => pathname.startsWith(p));
}

export default async function proxy(request: NextRequest) {
  const intlResponse = createMiddleware(routing)(request);

  const { response, isAuthenticated } = await updateSession(
    request,
    NextResponse.next(intlResponse)
  );

  const { pathname } = request.nextUrl;
  const needsAuth =
    pathname.startsWith("/yonetim") || pathname.startsWith("/veli-paneli");

  if (DEMO_MODE) return response;

  if (needsAuth && !isAuthenticated) {
    const url = request.nextUrl.clone();
    url.pathname = "/signin";
    // Kullanilmayacak sayfanin yolunu geri donus icin sakla.
    url.searchParams.set("next", pathname);
    return NextResponse.redirect(url);
  }

  // Giris yapmis kullanici dogrudan /signin'a gidemesin.
  if (isPublic(pathname) && isAuthenticated) {
    const url = request.nextUrl.clone();
    url.pathname = "/";
    url.search = "";
    return NextResponse.redirect(url);
  }

  return response;
}

export const config = {
  matcher: ["/((?!api/|_next|_vercel|.*\\..*).*)"],
};
