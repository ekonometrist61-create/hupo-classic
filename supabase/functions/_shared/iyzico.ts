// iyzico Checkout Form için SAF (yan etkisiz) mantık: imzalama, tutar biçimi, istek gövdesi,
// callback karar tablosu. Ağ/DB çağrısı YOKTUR; node ile test edilir:
//   node --experimental-strip-types --test supabase/functions/_shared/iyzico.test.ts
//
// Kaynak: docs.iyzico.com (IYZWSv2: HMAC-SHA256(secret, randomKey + uriPath + body) -> hex;
// Authorization = "IYZWSv2 " + base64("apiKey:..&randomKey:..&signature:.."); başlık x-iyzi-rnd = randomKey).

export const SANDBOX_BASE_URL = "https://sandbox-api.iyzipay.com";
export const INIT_PATH = "/payment/iyzipos/checkoutform/initialize/auth/ecom";
export const RETRIEVE_PATH = "/payment/iyzipos/checkoutform/auth/ecom/detail";

const enc = new TextEncoder();

function toHex(buf: ArrayBuffer): string {
  return [...new Uint8Array(buf)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

export function toBase64(s: string): string {
  const bytes = enc.encode(s);
  let bin = "";
  for (const b of bytes) bin += String.fromCharCode(b);
  return btoa(bin);
}

export async function hmacSha256Hex(secret: string, message: string): Promise<string> {
  const key = await crypto.subtle.importKey("raw", enc.encode(secret), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
  return toHex(await crypto.subtle.sign("HMAC", key, enc.encode(message)));
}

/** İmza: HMAC-SHA256(secret, randomKey + uriPath + body) -> hex. `body` gönderilecek bayt-bayt aynı metin olmalı. */
export function iyzicoSignature(secret: string, randomKey: string, uriPath: string, body: string): Promise<string> {
  return hmacSha256Hex(secret, randomKey + uriPath + body);
}

export function buildAuthorization(apiKey: string, randomKey: string, signature: string): string {
  return "IYZWSv2 " + toBase64(`apiKey:${apiKey}&randomKey:${randomKey}&signature:${signature}`);
}

export function randomKey(): string {
  // zaman + rastgele; iyzico yalnızca imza ile başlıkta aynı değerin gelmesini ister
  const r = crypto.getRandomValues(new Uint32Array(2));
  return `${Date.now()}${r[0].toString(36)}${r[1].toString(36)}`;
}

export async function signedHeaders(
  apiKey: string, secret: string, uriPath: string, body: string, rnd: string = randomKey(),
): Promise<Record<string, string>> {
  const sig = await iyzicoSignature(secret, rnd, uriPath, body);
  return {
    "content-type": "application/json",
    accept: "application/json",
    authorization: buildAuthorization(apiKey, rnd, sig),
    "x-iyzi-rnd": rnd,
  };
}

// ---------------- Tutar ----------------

/** 14990 -> "149.90"; 100 -> "1.00". Yalnızca tamsayı aritmetiği (float yok). */
export function formatKurus(kurus: number): string {
  if (!Number.isSafeInteger(kurus) || kurus < 0) throw new Error("kurus negatif olmayan tamsayı olmalı");
  const lira = Math.floor(kurus / 100);
  return `${lira}.${String(kurus % 100).padStart(2, "0")}`;
}

/** iyzico'nun döndürdüğü tutarı ("149.9", 149.9, "149.90") kuruşa çevirir; anlaşılmazsa null. */
export function parseToKurus(v: unknown): number | null {
  if (typeof v === "number") {
    if (!Number.isFinite(v) || v < 0) return null;
    const k = Math.round(v * 100);            // 0.29*100 = 28.999999999999996 tuzağı için round
    return Math.abs(v * 100 - k) < 1e-6 ? k : null; // 3'ten fazla ondalık -> reddet
  }
  if (typeof v === "string") {
    const m = /^(\d{1,9})(?:\.(\d{1,2}))?$/.exec(v.trim());
    if (!m) return null;
    return Number(m[1]) * 100 + Number((m[2] ?? "").padEnd(2, "0") || "0");
  }
  return null;
}

// ---------------- İstek gövdesi ----------------

export interface BuyerInfo {
  id: string;
  ad: string;
  soyad: string;
  email: string;
  ip: string;
}

// iyzico bu alanları ZORUNLU sayar. Biz gerçek TCKN/telefon/adres TOPLAMIYORUZ;
// bu yüzden belgelenen yer tutucular gönderilir (bkz. ODEME_KURULUM.md, "Yer tutucu alanlar").
export const PLACEHOLDERS = {
  identityNumber: "11111111111",
  gsmNumber: "+905350000000",
  address: "Türkiye (dijital ürün, teslimat yok)",
  city: "Istanbul",
  country: "Turkey",
  fallbackIp: "85.34.78.112",
} as const;

export function cleanIp(raw: string | null | undefined): string {
  const first = (raw ?? "").split(",")[0].trim();
  return /^[0-9a-fA-F:.]{3,45}$/.test(first) ? first : PLACEHOLDERS.fallbackIp;
}

export function splitName(full: string | null | undefined, email: string): { ad: string; soyad: string } {
  const parts = (full ?? "").trim().split(/\s+/).filter(Boolean);
  if (parts.length >= 2) return { ad: parts.slice(0, -1).join(" "), soyad: parts[parts.length - 1] };
  if (parts.length === 1) return { ad: parts[0], soyad: "Veli" };
  return { ad: email.split("@")[0] || "Veli", soyad: "Veli" };
}

export function buildInitPayload(p: {
  paymentId: string;
  tutarKurus: number;
  planKod: string;
  planAd: string;
  buyer: BuyerInfo;
  callbackUrl: string;
}): Record<string, unknown> {
  const fiyat = formatKurus(p.tutarKurus);
  const ad = `${p.buyer.ad} ${p.buyer.soyad}`.trim();
  return {
    locale: "tr",
    conversationId: p.paymentId,
    price: fiyat,
    paidPrice: fiyat,
    currency: "TRY",
    basketId: p.paymentId,
    paymentGroup: "PRODUCT",
    callbackUrl: p.callbackUrl,
    enabledInstallments: [1], // taksit yok: taksit faizi paidPrice'ı değiştirir, doğrulamayı bozar
    buyer: {
      id: p.buyer.id,
      name: p.buyer.ad,
      surname: p.buyer.soyad,
      identityNumber: PLACEHOLDERS.identityNumber,
      email: p.buyer.email,
      gsmNumber: PLACEHOLDERS.gsmNumber,
      registrationAddress: PLACEHOLDERS.address,
      city: PLACEHOLDERS.city,
      country: PLACEHOLDERS.country,
      ip: p.buyer.ip,
    },
    billingAddress: { contactName: ad, city: PLACEHOLDERS.city, country: PLACEHOLDERS.country, address: PLACEHOLDERS.address },
    // Tüm kalemler VIRTUAL: shippingAddress gerekmez. Kalem fiyatları toplamı = price olmalı.
    basketItems: [{ id: p.planKod, name: p.planAd, category1: "Egitim", itemType: "VIRTUAL", price: fiyat }],
  };
}

// ---------------- Callback karar tablosu ----------------

export interface RetrieveResponse {
  status?: unknown;
  paymentStatus?: unknown;
  conversationId?: unknown;
  token?: unknown;
  paymentId?: unknown;
  paidPrice?: unknown;
  currency?: unknown;
  fraudStatus?: unknown;
  errorMessage?: unknown;
  errorCode?: unknown;
}

export type Decision =
  | { action: "complete"; paymentRef: string; paidKurus: number | null }
  | { action: "fail"; reason: string }
  | { action: "pending"; reason: string }   // iyzico "inceleme": beklemede bırak
  | { action: "reject"; reason: string };   // sahte/uyumsuz istek: DB'ye DOKUNMA

/**
 * Callback'in kendi gövdesine ASLA güvenilmez; yalnızca sunucudan sunucuya retrieve yanıtı karara girer.
 * expectedPaymentId: URL'deki ?p=; storedToken: payment_set_token ile saklanan; postedToken: tarayıcıdan gelen.
 */
export function decideCallback(args: {
  expectedPaymentId: string;
  storedToken: string | null;
  postedToken: string | null;
  retrieve: RetrieveResponse | null;
}): Decision {
  const { expectedPaymentId, storedToken, postedToken, retrieve: r } = args;
  if (!storedToken || !postedToken || storedToken !== postedToken) {
    return { action: "reject", reason: "token_uyusmuyor" };
  }
  if (!r || typeof r !== "object") return { action: "fail", reason: "retrieve_yanit_yok" };
  if (r.conversationId !== expectedPaymentId) return { action: "reject", reason: "conversation_uyusmuyor" };
  if (r.token !== undefined && r.token !== storedToken) return { action: "reject", reason: "yanit_token_uyusmuyor" };
  if (r.status !== "success") return { action: "fail", reason: `iyzico_status_${String(r.errorCode ?? r.status ?? "yok")}`.slice(0, 80) };
  if (r.paymentStatus !== "SUCCESS") return { action: "fail", reason: `paymentStatus_${String(r.paymentStatus ?? "yok")}`.slice(0, 80) };
  if (r.currency !== undefined && r.currency !== "TRY") return { action: "fail", reason: "para_birimi_TRY_degil" };
  if (r.fraudStatus === 0) return { action: "pending", reason: "fraud_inceleme" };
  if (r.fraudStatus === -1) return { action: "fail", reason: "fraud_red" };
  if (typeof r.paymentId !== "string" || r.paymentId.length === 0) return { action: "fail", reason: "paymentId_yok" };
  return { action: "complete", paymentRef: r.paymentId, paidKurus: parseToKurus(r.paidPrice) };
}

/** Yalnızca DB'ye yazılacak güvenli alanlar (SQL tarafı da beyaz listeler). */
export function safeRaw(r: RetrieveResponse): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  for (const k of ["status", "paymentStatus", "paymentId", "paidPrice", "price", "currency", "conversationId", "fraudStatus", "installment", "errorCode"]) {
    const v = (r as Record<string, unknown>)[k];
    if (["string", "number", "boolean"].includes(typeof v)) out[k] = v;
  }
  return out;
}

export function redirectUrl(webPanelUrl: string, ok: boolean, paymentId: string): string {
  const base = webPanelUrl.replace(/\/+$/, "");
  return `${base}/veli-paneli/abonelik?odeme=${ok ? "basarili" : "basarisiz"}&id=${encodeURIComponent(paymentId)}`;
}

export const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
