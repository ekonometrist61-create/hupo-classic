// Supabase Edge Function: payments-callback  (--no-verify-jwt ile yayınlanır!)
// iyzico, ödeme sonrası kullanıcının TARAYICISINI buraya yönlendirir (POST form: token; JWT YOK).
// Tarayıcıdan gelen hiçbir şeye güvenilmez: yalnızca token alınır, sonuç iyzico'dan SUNUCUDAN
// SUNUCUYA sorgulanır (retrieve), ödeme kaydı ve saklı token ile karşılaştırılır.
// Tekrar (yenileme / iyzico yeniden deneme) güvenlidir: ödeme zaten sonuçlanmışsa iyzico'ya bile gidilmez.

import { createClient } from "npm:@supabase/supabase-js@2";
import {
  decideCallback, redirectUrl, RETRIEVE_PATH, safeRaw, SANDBOX_BASE_URL, signedHeaders, UUID_RE,
} from "../_shared/iyzico.ts";

declare const Deno: {
  env: { get(k: string): string | undefined };
  serve(handler: (req: Request) => Promise<Response> | Response): void;
};

const see = (location: string) => new Response(null, { status: 303, headers: { location } });

Deno.serve(async (req) => {
  const webPanel = Deno.env.get("WEB_PANEL_URL") ?? "";
  const apiKey = Deno.env.get("IYZICO_API_KEY");
  const secret = Deno.env.get("IYZICO_SECRET_KEY");
  const base = (Deno.env.get("IYZICO_BASE_URL") ?? SANDBOX_BASE_URL).replace(/\/+$/, "");
  if (!webPanel || !apiKey || !secret) return new Response("Yapılandırma eksik", { status: 500 });
  if (req.method !== "POST" && req.method !== "GET") return new Response("Method not allowed", { status: 405 });

  const reqUrl = new URL(req.url);
  const paymentId = reqUrl.searchParams.get("p") ?? "";
  if (!UUID_RE.test(paymentId)) return new Response("Geçersiz istek", { status: 400 });

  // Token: iyzico form-POST eder; GET ile de kabul (yalnızca token'ı okuruz, başka alan yok)
  let postedToken: string | null = reqUrl.searchParams.get("token");
  if (req.method === "POST") {
    try {
      const ct = req.headers.get("content-type") ?? "";
      if (ct.includes("application/x-www-form-urlencoded") || ct.includes("multipart/form-data")) {
        const t = (await req.formData()).get("token");
        if (typeof t === "string") postedToken = t;
      } else if (ct.includes("json")) {
        const j = await req.json();
        if (typeof j?.token === "string") postedToken = j.token;
      }
    } catch { /* token yoksa aşağıda reddedilir */ }
  }

  const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {
    auth: { persistSession: false },
  });

  const { data: pay } = await admin.rpc("payment_get", { p_payment_id: paymentId });
  if (!pay) return see(redirectUrl(webPanel, false, paymentId));

  // İdempotent: zaten sonuçlanmış -> iyzico'ya gitmeden aynı sonuca yönlendir
  if (pay.durum === "basarili") return see(redirectUrl(webPanel, true, paymentId));
  if (pay.durum !== "beklemede") return see(redirectUrl(webPanel, false, paymentId));

  // Sunucudan sunucuya doğrulama
  const body = JSON.stringify({ locale: "tr", conversationId: paymentId, token: postedToken ?? "" });
  let retrieve: any = null;
  try {
    const res = await fetch(base + RETRIEVE_PATH, {
      method: "POST",
      headers: await signedHeaders(apiKey, secret, RETRIEVE_PATH, body),
      body,
    });
    retrieve = await res.json();
  } catch (_) { /* retrieve = null -> fail (token uyuşsa bile) */ }

  const d = decideCallback({
    expectedPaymentId: paymentId, storedToken: pay.iyzico_token ?? null, postedToken, retrieve,
  });

  if (d.action === "complete") {
    const { data, error } = await admin.rpc("payment_complete", {
      p_payment_id: paymentId, p_saglayici_ref: d.paymentRef, p_odenen_kurus: d.paidKurus, p_ham: safeRaw(retrieve),
    });
    if (error) {
      console.error("payment_complete hata", error.code);
      return see(redirectUrl(webPanel, false, paymentId));
    }
    return see(redirectUrl(webPanel, data?.durum === "basarili", paymentId));
  }
  if (d.action === "fail") {
    await admin.rpc("payment_fail", { p_payment_id: paymentId, p_neden: d.reason });
    return see(redirectUrl(webPanel, false, paymentId));
  }
  // pending (fraud incelemesi) ve reject: kayda DOKUNMA (reject sahte istek olabilir; gerçek kullanıcının
  // ödemesini bozmasın). Kullanıcı "başarısız/bekliyor" görür; yönetici panelinde beklemede kalır.
  console.error("callback işlenmedi:", d.action, d.reason);
  return see(redirectUrl(webPanel, false, paymentId));
});
