// Supabase Edge Function: kullanim-izle
// Kullanım süresi olaylarının anonim toplu girişi (mobil, Flutter web, site ve panel yüzeyleri).
// JWT doğrulaması KAPALI (oturumsuz ziyaretçi de gönderir).
// Akış: IP hız sınırı → gövde boyutu → şema doğrulaması (dogrulama.ts) → kullanim_olaylari_gonder (service_role).
// Bu RPC anon/authenticated için kapatılır (20261108000000); yalnızca bu fonksiyon çağırır.
//
// İstek gövdesi (en çok 50 olay, en çok 32 KB):
//   { "olaylar": [ { yuzey, ekran, sure_sn, baslangic, oturum_anahtari, rol }, ... ] }
//
// Deploy: supabase functions deploy kullanim-izle --no-verify-jwt

import { createClient } from "npm:@supabase/supabase-js@2";
import { hizIzinliMi, istemciIp } from "../_shared/guvenlik.ts";
import { govdeBoyutuUygun, olaylariDogrula } from "./dogrulama.ts";

declare const Deno: {
  env: { get(k: string): string | undefined };
  serve(handler: (req: Request) => Promise<Response> | Response): void;
};

const ALLOWED_ORIGINS = [
  "https://hupolingo.com",
  "https://www.hupolingo.com",
  "https://app.hupolingo.com",
  "http://localhost:3000",
  "http://localhost:3001",
];

// IP başına 10 dakikada en çok 60 istek (her istek en çok 50 olay taşır).
const HIZ_LIMITI = 60;
const PENCERE_SN = 600;
const BUCKET = "kullanim_olaylari";

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

/**
 * Hız sınırı anahtarı: IP düz yazılmaz. Gizli anahtarla HMAC-SHA256 alınır; rate_limit_hits tablosunda
 * yalnızca bu özet bulunur. Gizli anahtar sunucuda kalır ve döndürülmez.
 */
async function ipAnahtari(ip: string, gizli: string): Promise<string> {
  const kodlayici = new TextEncoder();
  const anahtar = await crypto.subtle.importKey(
    "raw",
    kodlayici.encode(gizli),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const imza = await crypto.subtle.sign("HMAC", anahtar, kodlayici.encode(ip));
  return "ip:" + Array.from(new Uint8Array(imza), (b) => b.toString(16).padStart(2, "0")).join("");
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: cors(req) });
  if (req.method !== "POST") return reply(req, 405, { hata: "Yalnızca POST" });

  const url = Deno.env.get("SUPABASE_URL");
  const gizli = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !gizli) {
    console.error("kullanim-izle: SUPABASE_URL ya da SUPABASE_SERVICE_ROLE_KEY tanımlı değil");
    return reply(req, 500, { hata: "Kayıt yapılamadı." });
  }
  const admin = createClient(url, gizli, { auth: { persistSession: false } });

  // Hız sınırı, gövde okunmadan önce: geçersiz istekler de sayılır.
  const izinli = await hizIzinliMi(admin, BUCKET, await ipAnahtari(istemciIp(req), gizli), HIZ_LIMITI, PENCERE_SN);
  if (!izinli) return reply(req, 429, { hata: "Çok fazla istek. Birkaç dakika sonra tekrar deneyin." });

  let metin: string;
  try {
    metin = await req.text();
  } catch {
    return reply(req, 400, { hata: "Gövde okunamadı" });
  }
  if (!govdeBoyutuUygun(new TextEncoder().encode(metin).byteLength)) {
    return reply(req, 413, { hata: "İstek çok büyük" });
  }

  let govde: unknown;
  try {
    govde = JSON.parse(metin);
  } catch {
    return reply(req, 400, { hata: "Geçersiz JSON" });
  }

  const dogrulama = olaylariDogrula(govde, Date.now());
  if (!dogrulama.ok) return reply(req, 400, { hata: dogrulama.hata });
  if (dogrulama.olaylar.length === 0) return reply(req, 200, { ok: true, kabul: 0 });

  const { error } = await admin.rpc("kullanim_olaylari_gonder", { p_olaylar: dogrulama.olaylar });
  if (error) {
    // 22023: RPC'nin doğrulama mesajı (istemciye güvenli). 54000: oturum başına hız sınırı.
    if (error.code === "22023") return reply(req, 400, { hata: error.message });
    if (error.code === "54000") return reply(req, 429, { hata: "Çok fazla istek. Birkaç dakika sonra tekrar deneyin." });
    console.error("kullanim_olaylari_gonder hatası:", error.code ?? "", error.message);
    return reply(req, 500, { hata: "Kayıt yapılamadı." });
  }
  return reply(req, 200, { ok: true, kabul: dogrulama.olaylar.length });
});
