// Supabase Edge Function: growth-web-izle
// Landing ziyaretçi izleme için tek giriş noktası. JWT doğrulaması KAPALI (anonim ziyaretçi).
// Akış: IP hız sınırı → growth_web_olay_kaydet veya growth_web_kimlik_bagla (service_role).
// Bu RPC'ler anon/authenticated için kapatıldı (20261080000000); yalnızca bu fonksiyon çağırır.
//
// İstek gövdesi:
//   { islem: "olay",  anonymous_id, event_name, utm }
//   { islem: "kimlik", anonymous_id, eposta }

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

// IP başına 10 dakikada: olay bir sayfa görüntülemesinde bir kez, kimlik bağlama formda bir kez gider.
const OLAY_LIMIT = 30;
const KIMLIK_LIMIT = 10;
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

function rpcHatasi(req: Request, error: { code?: string; message: string }, ad: string): Response {
  // 22023: RPC'nin kendi doğrulama mesajı.
  if (error.code === "22023") return reply(req, 400, { hata: error.message });
  console.error(`${ad} hatası:`, error);
  return reply(req, 500, { hata: "İzleme kaydedilemedi." });
}

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

  const vid = typeof body.anonymous_id === "string" ? body.anonymous_id : "";

  if (body.islem === "olay") {
    const izinli = await hizIzinliMi(admin, "growth_web_olay", istemciIp(req), OLAY_LIMIT, PENCERE_SN);
    if (!izinli) return reply(req, 429, { hata: "Çok fazla istek. Birkaç dakika sonra tekrar deneyin." });

    const utm = body.utm && typeof body.utm === "object" && !Array.isArray(body.utm) ? body.utm : {};
    const { error } = await admin.rpc("growth_web_olay_kaydet", {
      p_anonymous_id: vid,
      p_event_name: typeof body.event_name === "string" ? body.event_name : "",
      p_utm: utm,
    });
    if (error) return rpcHatasi(req, error, "growth_web_olay_kaydet");
    return reply(req, 200, { ok: true });
  }

  if (body.islem === "kimlik") {
    const izinli = await hizIzinliMi(admin, "growth_web_kimlik", istemciIp(req), KIMLIK_LIMIT, PENCERE_SN);
    if (!izinli) return reply(req, 429, { hata: "Çok fazla istek. Birkaç dakika sonra tekrar deneyin." });

    const { error } = await admin.rpc("growth_web_kimlik_bagla", {
      p_anonymous_id: vid,
      p_eposta: typeof body.eposta === "string" ? body.eposta : "",
    });
    if (error) return rpcHatasi(req, error, "growth_web_kimlik_bagla");
    return reply(req, 200, { ok: true });
  }

  return reply(req, 400, { hata: "Geçersiz işlem" });
});
