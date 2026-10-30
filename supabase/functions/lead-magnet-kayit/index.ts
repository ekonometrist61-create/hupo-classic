// Supabase Edge Function: lead-magnet-kayit
// Herkese açık lead magnet kaydı (e-posta + sınıf + ayrı pazarlama izni). JWT doğrulaması KAPALI.
// Captcha: Turnstile zorunlu (CAPTCHA_SECRET yoksa 503; yalnızca SKIP_CAPTCHA=true ile atlanır).
// IP başına hız sınırı: 10 istek / 10 dakika.
// Deploy: supabase functions deploy lead-magnet-kayit --no-verify-jwt
// Gizli anahtarlar: CAPTCHA_SECRET, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY (otomatik).

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

// Yeni magnet eklenirken burası genişletilir; bilinmeyen kimlik reddedilir.
const MAGNETLER = new Set(["carpim-pif-noktalari"]);

const EPOSTA_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

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

/** UTM benzeri kaynak bilgisini yalnız bilinen anahtarlarla, kısaltılmış metin olarak alır. */
function kaynakTemizle(v: unknown): Record<string, string> {
  const out: Record<string, string> = {};
  if (typeof v !== "object" || v === null) return out;
  for (const k of ["kaynak", "kanal", "icerik"]) {
    const val = (v as Record<string, unknown>)[k];
    if (typeof val === "string" && val.trim()) out[k] = val.trim().slice(0, 80);
  }
  return out;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: cors(req) });
  if (req.method !== "POST") return reply(req, 405, { hata: "Yalnızca POST" });

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return reply(req, 400, { hata: "Geçersiz JSON" });
  }

  const admin = createClient(supabaseUrl, serviceKey, { auth: { persistSession: false } });

  // Captcha (fail-closed) ve IP hız sınırı
  const captcha = await captchaKontrol(body.captcha_token, req);
  if (!captcha.ok) return reply(req, captcha.status, { hata: captcha.hata });

  const izinli = await hizIzinliMi(admin, "lead_magnet_kayit", istemciIp(req), 10, 600);
  if (!izinli) {
    return reply(req, 429, { hata: "Çok fazla deneme yaptınız. Birkaç dakika sonra tekrar deneyin." });
  }

  // Giriş doğrulama
  const magnet = typeof body.magnet === "string" ? body.magnet : "";
  const eposta = typeof body.eposta === "string" ? body.eposta.trim().toLowerCase() : "";
  const sinif = typeof body.sinif === "number" ? body.sinif : null;
  const kvkk_onay = body.kvkk_onay === true;
  const kvkk_surum = typeof body.kvkk_surum === "string" ? body.kvkk_surum.slice(0, 80) : "";
  const izin_surum = typeof body.izin_surum === "string" ? body.izin_surum.slice(0, 80) : "";
  const izin_eposta = body.izin_eposta === true;

  if (!MAGNETLER.has(magnet)) return reply(req, 400, { hata: "Geçersiz içerik" });
  if (eposta.length < 5 || eposta.length > 254 || !EPOSTA_RE.test(eposta)) {
    return reply(req, 400, { hata: "Geçerli bir e-posta girin" });
  }
  if (!sinif || !Number.isInteger(sinif) || sinif < 3 || sinif > 7) {
    return reply(req, 400, { hata: "Geçerli bir sınıf seçin" });
  }
  if (!kvkk_onay) return reply(req, 400, { hata: "KVKK aydınlatma onayı zorunludur" });
  if (!kvkk_surum || !izin_surum) return reply(req, 400, { hata: "Metin sürümü gerekli" });

  const { data, error } = await admin.rpc("lead_magnet_kayit_ekle", {
    p_magnet: magnet,
    p_eposta: eposta,
    p_sinif: sinif,
    p_kvkk_onay: kvkk_onay,
    p_kvkk_surum: kvkk_surum,
    p_izin_surum: izin_surum,
    p_izin_eposta: izin_eposta,
    p_kaynak: kaynakTemizle(body.utm),
  });

  if (error) {
    const msg = error.message ?? "";
    if (msg.includes("KVKK")) return reply(req, 400, { hata: "KVKK aydınlatma onayı zorunludur" });
    if (msg.includes("sınıf")) return reply(req, 400, { hata: "Geçerli bir sınıf seçin" });
    console.error("lead_magnet_kayit_ekle error:", error);
    return reply(req, 500, { hata: "Kayıt sırasında bir hata oluştu. Lütfen tekrar deneyin." });
  }

  return reply(req, 200, { lead_id: data });
});
