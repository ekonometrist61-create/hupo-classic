// Supabase Edge Function: payments-checkout  (JWT DOĞRULAMASI AÇIK kalır)
// Veli web panelinden çağrılır: POST { plan_kod } + Authorization: Bearer <kullanıcı JWT'si>
// -> bekleyen ödeme oluşturur, iyzico Checkout Form başlatır, { payment_id, odeme_url } döner.
// Gizli anahtarlar: IYZICO_API_KEY, IYZICO_SECRET_KEY, IYZICO_BASE_URL (varsayılan sandbox),
// WEB_PANEL_URL. SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_SERVICE_ROLE_KEY otomatik gelir.
// Kurulum: supabase/docs/ODEME_KURULUM.md

import { createClient } from "npm:@supabase/supabase-js@2";
import { buildInitPayload, cleanIp, INIT_PATH, SANDBOX_BASE_URL, signedHeaders, splitName } from "../_shared/iyzico.ts";

declare const Deno: {
  env: { get(k: string): string | undefined };
  serve(handler: (req: Request) => Promise<Response> | Response): void;
};

function cors(req: Request): Record<string, string> {
  const allowed = (Deno.env.get("WEB_PANEL_URL") ?? "").replace(/\/+$/, "");
  const origin = req.headers.get("origin") ?? "";
  const h: Record<string, string> = {
    "access-control-allow-headers": "authorization, content-type, apikey, x-client-info",
    "access-control-allow-methods": "POST, OPTIONS",
    vary: "Origin",
  };
  // Yalnızca veli panelinin adresine izin (WEB_PANEL_URL); '*' KULLANILMAZ
  if (allowed && origin === allowed) h["access-control-allow-origin"] = origin;
  return h;
}

const reply = (req: Request, status: number, body: unknown) =>
  new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json", ...cors(req) } });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: cors(req) });
  if (req.method !== "POST") return reply(req, 405, { hata: "Yalnızca POST" });

  const url = Deno.env.get("SUPABASE_URL")!;
  const anon = Deno.env.get("SUPABASE_ANON_KEY")!;
  const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const apiKey = Deno.env.get("IYZICO_API_KEY");
  const secret = Deno.env.get("IYZICO_SECRET_KEY");
  const base = (Deno.env.get("IYZICO_BASE_URL") ?? SANDBOX_BASE_URL).replace(/\/+$/, "");
  if (!apiKey || !secret) return reply(req, 500, { hata: "Ödeme yapılandırılmamış" });

  // 1) Çağıran kim? (JWT sunucuda doğrulanır)
  const auth = req.headers.get("authorization") ?? "";
  if (!auth.toLowerCase().startsWith("bearer ")) return reply(req, 401, { hata: "Giriş gerekli" });
  const userClient = createClient(url, anon, { global: { headers: { Authorization: auth } } });
  const { data: u, error: uErr } = await userClient.auth.getUser();
  if (uErr || !u?.user) return reply(req, 401, { hata: "Geçersiz oturum" });
  const user = u.user;

  // 2) Veli mi?
  const admin = createClient(url, service, { auth: { persistSession: false } });
  const { data: prof } = await admin.from("profiles").select("role, full_name").eq("id", user.id).maybeSingle();
  if (!prof || prof.role !== "veli") return reply(req, 403, { hata: "Yalnızca veli hesabı satın alabilir" });

  // 3) Gövde: yalnızca plan_kod. Tutar İSTEMCİDEN ALINMAZ.
  let planKod = "";
  try {
    const b = await req.json();
    planKod = typeof b?.plan_kod === "string" ? b.plan_kod : "";
  } catch { /* boş */ }
  if (!/^[a-z0-9_]{2,30}$/.test(planKod)) return reply(req, 400, { hata: "Geçersiz plan" });

  // 4) Bekleyen ödeme (tutar plans tablosundan)
  const { data: pend, error: pErr } = await admin.rpc("payment_create_pending", { p_veli_id: user.id, p_plan_kod: planKod });
  if (pErr || !pend) return reply(req, 400, { hata: "Plan satın alınamıyor" });
  const paymentId: string = pend.payment_id;

  // 5) iyzico Checkout Form başlat
  const email = user.email ?? "";
  const { ad, soyad } = splitName(prof.full_name, email);
  const callbackUrl = `${url}/functions/v1/payments-callback?p=${paymentId}`;
  const body = JSON.stringify(buildInitPayload({
    paymentId, tutarKurus: pend.tutar_kurus, planKod: pend.plan_kod, planAd: pend.plan_ad,
    buyer: { id: user.id, ad, soyad, email, ip: cleanIp(req.headers.get("x-forwarded-for")) },
    callbackUrl,
  }));

  let r: any = null;
  try {
    const res = await fetch(base + INIT_PATH, {
      method: "POST",
      headers: await signedHeaders(apiKey, secret, INIT_PATH, body),
      body,
    });
    r = await res.json();
  } catch (_) { /* aşağıda başarısız sayılır */ }

  if (!r || r.status !== "success" || typeof r.token !== "string" || typeof r.paymentPageUrl !== "string") {
    await admin.rpc("payment_fail", { p_payment_id: paymentId, p_neden: `init_${String(r?.errorCode ?? "hata")}`.slice(0, 80) });
    // Hata ayrıntısı kullanıcıya sızdırılmaz; sunucu günlüğüne yalnızca kod yazılır
    console.error("iyzico init başarısız", r?.errorCode, r?.errorMessage);
    return reply(req, 502, { hata: "Ödeme sayfası açılamadı, lütfen sonra tekrar deneyin" });
  }

  const { error: tErr } = await admin.rpc("payment_set_token", { p_payment_id: paymentId, p_token: r.token });
  if (tErr) return reply(req, 500, { hata: "Ödeme kaydedilemedi" });

  return reply(req, 200, { payment_id: paymentId, odeme_url: r.paymentPageUrl });
});
