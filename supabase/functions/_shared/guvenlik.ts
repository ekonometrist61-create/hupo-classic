// Herkese açık Edge Function'lar için ortak güvenlik katmanı:
//   * Cloudflare Turnstile doğrulaması (fail-closed)
//   * IP başına hız sınırı (rate_limit_kontrol RPC'si, service_role)
//
// Ortam değişkenleri:
//   CAPTCHA_SECRET   Turnstile gizli anahtarı. ZORUNLU (canlıda).
//   SKIP_CAPTCHA     "true" ise captcha atlanır. YALNIZCA yerel geliştirme.
//                    Canlı projede ASLA ayarlanmamalı.

import type { SupabaseClient } from "npm:@supabase/supabase-js@2";

declare const Deno: {
  env: { get(k: string): string | undefined };
};

export function istemciIp(req: Request): string {
  const xff = req.headers.get("x-forwarded-for") ?? "";
  const ip =
    xff.split(",")[0]?.trim() ||
    req.headers.get("cf-connecting-ip")?.trim() ||
    req.headers.get("x-real-ip")?.trim() ||
    "";
  return ip.slice(0, 64) || "bilinmiyor";
}

export type CaptchaSonuc = { ok: true } | { ok: false; status: number; hata: string };

async function turnstileDogrula(token: string, secret: string, ip: string): Promise<boolean> {
  const res = await fetch("https://challenges.cloudflare.com/turnstile/v0/siteverify", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ secret, response: token, remoteip: ip }),
  });
  if (!res.ok) return false;
  const data = (await res.json()) as { success?: boolean };
  return data.success === true;
}

/** Captcha'yı doğrular. Gizli anahtar yoksa ve geliştirme bayrağı yoksa REDDEDER. */
export async function captchaKontrol(
  token: unknown,
  req: Request,
): Promise<CaptchaSonuc> {
  const secret = Deno.env.get("CAPTCHA_SECRET");
  if (!secret) {
    if (Deno.env.get("SKIP_CAPTCHA") === "true") return { ok: true };
    return {
      ok: false,
      status: 503,
      hata: "Güvenlik doğrulaması şu an yapılandırılmadı. Lütfen daha sonra tekrar deneyin.",
    };
  }
  if (typeof token !== "string" || token.length === 0 || token.length > 2048) {
    return { ok: false, status: 400, hata: "Güvenlik doğrulaması gerekli" };
  }
  const ok = await turnstileDogrula(token, secret, istemciIp(req));
  if (!ok) return { ok: false, status: 400, hata: "Güvenlik doğrulaması başarısız" };
  return { ok: true };
}

/** true: istek izinli. false: pencere içinde sınır aşıldı. */
export async function hizIzinliMi(
  admin: SupabaseClient,
  bucket: string,
  anahtar: string,
  limit: number,
  pencereSn: number,
): Promise<boolean> {
  const { data, error } = await admin.rpc("rate_limit_kontrol", {
    p_bucket: bucket,
    p_anahtar: anahtar,
    p_limit: limit,
    p_pencere_sn: pencereSn,
  });
  // Sayaç hatasında isteği reddetmeyiz (kullanıcı kaybı olmasın); hata loglanır.
  if (error) {
    console.error("rate_limit_kontrol hatası:", error.message);
    return true;
  }
  return data === true;
}
