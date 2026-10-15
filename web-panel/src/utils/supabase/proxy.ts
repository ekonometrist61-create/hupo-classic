import { createServerClient } from "@supabase/ssr";
import type { NextRequest, NextResponse } from "next/server";

// Supabase oturum cookie'lerini yeniler ve next-intl'in oluşturduğu yanıta yazar.
// Kullanıcının giriş yapıp yapmadığını ve yönetici olup olmadığını döndürür.
export async function updateSession(
  request: NextRequest,
  response: NextResponse
): Promise<{
  response: NextResponse;
  isAuthenticated: boolean;
  esAdmin: () => Promise<boolean>;
}> {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
  if (!url || !key) {
    return { response, isAuthenticated: false, esAdmin: async () => false };
  }

  const supabase = createServerClient(url, key, {
    cookies: {
      getAll() {
        return request.cookies.getAll();
      },
      setAll(cookiesToSet) {
        cookiesToSet.forEach(({ name, value }) =>
          request.cookies.set(name, value)
        );
        cookiesToSet.forEach(({ name, value, options }) =>
          response.cookies.set(name, value, options)
        );
      },
    },
  });

  // getClaims() JWT'yi doğrular ve gerekirse token'ı yeniler
  const { data } = await supabase.auth.getClaims();

  // `getClaims()` anonim token için de claims döndürebilir; gerçek oturumun
  // varlığını yalnızca JWT içindeki kullanıcı `sub` alanıyla kabul et.
  return {
    response,
    isAuthenticated: Boolean(data?.claims?.sub),
    // Yalnızca bakım modu yönetici bypass'ı gerektirdiğinde çağrılır (ek sorgu).
    esAdmin: async () => {
      const { data: admin } = await supabase.rpc("is_admin");
      return admin === true;
    },
  };
}
