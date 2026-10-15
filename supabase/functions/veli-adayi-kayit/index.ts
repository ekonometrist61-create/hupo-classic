// Supabase Edge Function: veli-adayi-kayit
// Web sitesi erken erişim formu için tek giriş noktası. JWT doğrulaması KAPALI.
// Akış: Turnstile (fail-closed) → IP hız sınırı (5 istek / 10 dakika) → veli_adayi_olustur (service_role).
// Veli adayı RPC'si anonim/authenticated için kapatıldı (20261033000200); bu fonksiyon dışından çağrılamaz.

import { createClient } from "npm:@supabase/supabase-js@2";
import { captchaKontrol, hizIzinliMi, istemciIp } from "../_shared/guvenlik.ts";

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

// Form yalnızca bu kaynakları gönderebilir; diğerleri varsayılan kaynağa düşer.
const IZINLI_KAYNAKLAR = new Set(["landing_erken_erisim"]);

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

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: cors(req) });
  if (req.method !== "POST") return reply(req, 405, { hata: "Yalnızca POST" });

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return reply(req, 400, { hata: "Geçersiz JSON" });
  }

  const captcha = await captchaKontrol(body.captcha_token, req);
  if (!captcha.ok) return reply(req, captcha.status, { hata: captcha.hata });

  const admin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );

  const izinli = await hizIzinliMi(admin, "veli_adayi", istemciIp(req), 5, 600);
  if (!izinli) {
    return reply(req, 429, { hata: "Çok fazla deneme yaptınız. Birkaç dakika sonra tekrar deneyin." });
  }

  const email = typeof body.email === "string" ? body.email.trim() : "";
  const ad = typeof body.ad === "string" ? body.ad.trim() : "";
  const telefon = typeof body.telefon === "string" ? body.telefon.trim() : "";
  const kaynakIstek = typeof body.kaynak === "string" ? body.kaynak : "";
  const kaynak = IZINLI_KAYNAKLAR.has(kaynakIstek) ? kaynakIstek : "web_form";
  const pazarlamaIzni = body.pazarlama_izni === true;

  // Kısa ön kontrol; asıl doğrulama RPC'de yapılır ve Türkçe mesajı döner.
  if (!email.includes("@")) return reply(req, 400, { hata: "Geçerli bir e-posta girin." });

  const { error } = await admin.rpc("veli_adayi_olustur", {
    p_email: email,
    p_ad: ad,
    p_telefon: telefon || null,
    p_kaynak: kaynak,
    p_pazarlama_izni: pazarlamaIzni,
  });

  if (error) {
    // 22023: RPC'nin kendi doğrulama mesajı (kullanıcıya gösterilebilir).
    if (error.code === "22023") return reply(req, 400, { hata: error.message });
    console.error("veli_adayi_olustur hatası:", error);
    return reply(req, 500, { hata: "Kayıt sırasında bir hata oluştu. Lütfen tekrar deneyin." });
  }

  return reply(req, 200, { ok: true });
});
