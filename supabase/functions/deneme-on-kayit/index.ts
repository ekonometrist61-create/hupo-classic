// Supabase Edge Function: deneme-on-kayit
// Herkese açık ön kayıt uç noktası. JWT doğrulaması KAPALI (giriş gerektirmez).
// Captcha: CAPTCHA_SECRET ortam değişkeni varsa doğrular; yoksa geçer (geliştirme modu).
// Gizli anahtarlar: CAPTCHA_SECRET (opsiyonel), SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY (otomatik).

import { createClient } from "npm:@supabase/supabase-js@2";

declare const Deno: {
  env: { get(k: string): string | undefined };
  serve(handler: (req: Request) => Promise<Response> | Response): void;
};

const ALLOWED_ORIGINS = [
  "https://hupolingo.com",
  "https://www.hupolingo.com",
  "http://localhost:3000",
  "http://localhost:3001",
];

function cors(req: Request): Record<string, string> {
  const origin = req.headers.get("origin") ?? "";
  const h: Record<string, string> = {
    "access-control-allow-headers": "content-type, apikey, x-client-info",
    "access-control-allow-methods": "POST, OPTIONS",
    vary: "Origin",
  };
  if (ALLOWED_ORIGINS.includes(origin)) h["access-control-allow-origin"] = origin;
  return h;
}

const reply = (req: Request, status: number, body: unknown) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json", ...cors(req) },
  });

async function validateCaptcha(token: string, secret: string): Promise<boolean> {
  // Cloudflare Turnstile doğrulama
  const res = await fetch("https://challenges.cloudflare.com/turnstile/v0/siteverify", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ secret, response: token }),
  });
  if (!res.ok) return false;
  const data = await res.json() as { success: boolean };
  return data.success === true;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: cors(req) });
  if (req.method !== "POST") return reply(req, 405, { hata: "Yalnızca POST" });

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const captchaSecret = Deno.env.get("CAPTCHA_SECRET");

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return reply(req, 400, { hata: "Geçersiz JSON" });
  }

  // Captcha doğrulama (CAPTCHA_SECRET varsa zorunlu)
  if (captchaSecret) {
    const captchaToken = typeof body.captcha_token === "string" ? body.captcha_token : "";
    if (!captchaToken) return reply(req, 400, { hata: "Güvenlik doğrulaması gerekli" });
    const ok = await validateCaptcha(captchaToken, captchaSecret);
    if (!ok) return reply(req, 400, { hata: "Güvenlik doğrulaması başarısız" });
  }

  // Giriş doğrulama
  const exam_id = typeof body.exam_id === "string" ? body.exam_id : null;
  const veli_ad = typeof body.veli_ad === "string" ? body.veli_ad.trim() : "";
  const cocuk_ad = typeof body.cocuk_ad === "string" ? body.cocuk_ad.trim() : "";
  const sinif = typeof body.sinif === "number" ? body.sinif : null;
  const eposta = typeof body.eposta === "string" ? body.eposta.trim().toLowerCase() : "";
  const telefon = typeof body.telefon === "string" ? body.telefon.trim() : "";
  const kvkk_onay = body.kvkk_onay === true;
  const kvkk_surum = typeof body.kvkk_surum === "string" ? body.kvkk_surum : "1.0";
  const izin_surum = typeof body.izin_surum === "string" ? body.izin_surum : "1.0";
  const izin_eposta = body.izin_eposta === true;
  const izin_sms = body.izin_sms === true;
  const izin_telefon = body.izin_telefon === true;

  if (!exam_id) return reply(req, 400, { hata: "Sınav kimliği gerekli" });
  if (veli_ad.length < 2) return reply(req, 400, { hata: "Veli adı en az 2 karakter olmalı" });
  if (cocuk_ad.length < 2) return reply(req, 400, { hata: "Çocuk adı en az 2 karakter olmalı" });
  if (!sinif || sinif < 1 || sinif > 12) return reply(req, 400, { hata: "Geçerli bir sınıf seçin" });
  if (!eposta.includes("@")) return reply(req, 400, { hata: "Geçerli bir e-posta girin" });
  if (!kvkk_onay) return reply(req, 400, { hata: "KVKK onayı zorunludur" });

  const admin = createClient(supabaseUrl, serviceKey, { auth: { persistSession: false } });

  const { data, error } = await admin.rpc("deneme_on_kayit_ekle", {
    p_exam_id: exam_id,
    p_veli_ad: veli_ad,
    p_cocuk_ad: cocuk_ad,
    p_sinif: sinif,
    p_eposta: eposta,
    p_telefon: telefon,
    p_kvkk_onay: kvkk_onay,
    p_kvkk_surum: kvkk_surum,
    p_izin_surum: izin_surum,
    p_izin_eposta: izin_eposta,
    p_izin_sms: izin_sms,
    p_izin_telefon: izin_telefon,
  });

  if (error) {
    // Kullanıcı dostu hata mesajları
    const msg = error.message ?? "";
    if (msg.includes("kayıt kapalı")) return reply(req, 400, { hata: "Bu sınav için kayıt süresi doldu." });
    if (msg.includes("sınıf")) return reply(req, 400, { hata: "Bu sınav seçilen sınıf için açık değil." });
    if (msg.includes("telefon")) return reply(req, 400, { hata: "Geçerli bir telefon numarası girin (ör: 05XX XXX XX XX)." });
    if (msg.includes("KVKK")) return reply(req, 400, { hata: "KVKK onayı zorunludur." });
    console.error("deneme_on_kayit_ekle error:", error);
    return reply(req, 500, { hata: "Kayıt sırasında bir hata oluştu. Lütfen tekrar deneyin." });
  }

  return reply(req, 200, { on_kayit_id: data });
});
