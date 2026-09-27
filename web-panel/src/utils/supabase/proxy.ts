import { createServerClient } from "@supabase/ssr";
import type { NextRequest, NextResponse } from "next/server";

// Supabase oturum cookie'lerini yeniler ve next-intl'in oluşturduğu yanıta yazar.
// Kullanıcının giriş yapıp yapmadığını da döndürür.
export async function updateSession(
  request: NextRequest,
  response: NextResponse
): Promise<{ response: NextResponse; isAuthenticated: boolean }> {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
  if (!url || !key) return { response, isAuthenticated: false };

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

  return { response, isAuthenticated: Boolean(data?.claims) };
}
