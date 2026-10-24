// Supabase Edge Function: iletisim-izni-iptal
// Ticari ileti iznini e-posta adresi üzerinden iptal eden sayfa için tek giriş noktası.
// JWT doğrulaması KAPALI (kimliksiz kullanıcı). Akış: IP hız sınırı → iletisim_izni_iptal_et (service_role).
// Bu RPC anon/authenticated için kapatıldı (20261080000000); yalnızca bu fonksiyon çağırır.
//
// Not: İptal bağlantısı imzasız kalır (e-posta adresi yeterli). Hız sınırı, toplu kötüye kullanımı
// frenler. İmzalı (tek kullanımlık) bağlantı ayrı bir ürün kararıdır.

import { createClient } from "npm:@supabase/supabase-js@2";
import { hizIzinliMi, istemciIp } from "../_shared/guvenlik.ts";

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

// IP başına 10 dakikada 10 iptal denemesi: meşru kullanıcı için fazlasıyla yeterli.
const IPTAL_LIMIT = 10;
const PENCERE_SN = 600;

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

  const admin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );

  const izinli = await hizIzinliMi(admin, "iletisim_iptal", istemciIp(req), IPTAL_LIMIT, PENCERE_SN);
  if (!izinli) return reply(req, 429, { hata: "Çok fazla deneme yaptınız. Birkaç dakika sonra tekrar deneyin." });

  const { error } = await admin.rpc("iletisim_izni_iptal_et", {
    p_email: typeof body.email === "string" ? body.email : "",
    p_kanal: typeof body.kanal === "string" ? body.kanal : "eposta",
  });

  if (error) {
    // 22023: RPC'nin kendi doğrulama mesajı (kullanıcıya gösterilebilir).
    if (error.code === "22023") return reply(req, 400, { hata: error.message });
    console.error("iletisim_izni_iptal_et hatası:", error);
    return reply(req, 500, { hata: "İptal işlemi tamamlanamadı. Lütfen tekrar deneyin." });
  }

  return reply(req, 200, { ok: true });
});
