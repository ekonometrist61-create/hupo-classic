// send-push: saf (yan etkisiz) mantık. Deno ve Node (>=22.6, --experimental-strip-types)
// içinde aynı şekilde çalışır; ağ ve veritabanı erişimi burada YOKTUR (bkz. index.ts).

export interface ServiceAccount {
  client_email: string;
  private_key: string;
  project_id: string;
  token_uri?: string;
}

export interface PushTarget {
  notification_id: string;
  user_id: string;
  token: string;
  platform: string;
  baslik: string;
  mesaj: string;
  tur: string;
}

export const FCM_SCOPE = "https://www.googleapis.com/auth/firebase.messaging";
export const DEFAULT_TOKEN_URI = "https://oauth2.googleapis.com/token";

// ---------------------------------------------------------------------
// Webhook gövdesi
// ---------------------------------------------------------------------
export interface OutboxRef {
  outboxId: string;
  notificationId: string;
}

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** Supabase Database Webhook (INSERT, push_outbox) gövdesini doğrular. */
export function parseWebhookPayload(body: unknown): OutboxRef {
  const b = body as { type?: string; table?: string; record?: Record<string, unknown> } | null;
  if (!b || typeof b !== "object") throw new Error("Geçersiz gövde");
  if (b.type !== "INSERT") throw new Error("Yalnızca INSERT olayı desteklenir");
  if (b.table !== undefined && b.table !== "push_outbox") throw new Error("Beklenmeyen tablo");
  const r = b.record;
  const outboxId = r?.id;
  const notificationId = r?.notification_id;
  if (typeof outboxId !== "string" || !UUID_RE.test(outboxId)) throw new Error("record.id geçersiz");
  if (typeof notificationId !== "string" || !UUID_RE.test(notificationId)) {
    throw new Error("record.notification_id geçersiz");
  }
  return { outboxId, notificationId };
}

/** Sabit zamanlı karşılaştırma (webhook gizli anahtarı için). */
export function timingSafeEqual(a: string, b: string): boolean {
  const enc = new TextEncoder();
  const x = enc.encode(a);
  const y = enc.encode(b);
  let diff = x.length ^ y.length;
  const n = Math.max(x.length, y.length);
  for (let i = 0; i < n; i++) diff |= (x[i] ?? 0) ^ (y[i] ?? 0);
  return diff === 0;
}

// ---------------------------------------------------------------------
// Sessiz saat (SQL push_in_quiet_hours ile aynı kural)
// ---------------------------------------------------------------------
function toMinutes(hhmm: string): number {
  const m = /^(\d{1,2}):(\d{2})/.exec(hhmm);
  if (!m) throw new Error("Saat biçimi HH:MM olmalı");
  return Number(m[1]) * 60 + Number(m[2]);
}

export function istanbulMinutes(at: Date): number {
  const parts = new Intl.DateTimeFormat("en-GB", {
    timeZone: "Europe/Istanbul",
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23",
  }).formatToParts(at);
  const h = Number(parts.find((p) => p.type === "hour")?.value);
  const m = Number(parts.find((p) => p.type === "minute")?.value);
  return h * 60 + m;
}

/** start > end ise gece yarısını aşar; start = end ise sessiz saat yoktur. */
export function isQuietHours(start: string, end: string, at: Date): boolean {
  const s = toMinutes(start);
  const e = toMinutes(end);
  const t = istanbulMinutes(at);
  if (s === e) return false;
  return s < e ? t >= s && t < e : t >= s || t < e;
}

// ---------------------------------------------------------------------
// FCM mesajı
// ---------------------------------------------------------------------
const MAX_TITLE = 80;
const MAX_BODY = 240;

function clip(s: string, n: number): string {
  const t = (s ?? "").trim();
  return t.length <= n ? t : t.slice(0, n - 1) + "…";
}

/** FCM HTTP v1 gövdesi. Yalnızca başlık/mesaj + bildirim kimliği taşır; kişisel veri YOK. */
export function buildFcmMessage(t: PushTarget) {
  return {
    message: {
      token: t.token,
      notification: { title: clip(t.baslik, MAX_TITLE), body: clip(t.mesaj, MAX_BODY) },
      // FCM data değerleri string olmak zorundadır.
      data: { route: "notifications", notification_id: t.notification_id, tur: t.tur },
      android: { priority: "NORMAL", notification: { channel_id: "hupo_default" } },
      apns: { payload: { aps: { sound: "default" } } },
    },
  };
}

export type FcmOutcome = "sent" | "invalid_token" | "retry" | "fatal";

/** FCM HTTP v1 yanıtını sınıflandırır. */
export function classifyFcmResponse(status: number, body: unknown): FcmOutcome {
  if (status >= 200 && status < 300) return "sent";
  const err = (body as { error?: { status?: string; details?: Array<{ errorCode?: string }> } })?.error;
  const code = err?.details?.find((d) => d.errorCode)?.errorCode;
  if (code === "UNREGISTERED" || err?.status === "NOT_FOUND" || status === 404) return "invalid_token";
  if (code === "INVALID_ARGUMENT" || err?.status === "INVALID_ARGUMENT") {
    // Bozuk jeton ile bozuk gövde ayırt edilemez; jetonu silmek güvenli tarafta kalmaktır.
    return "invalid_token";
  }
  if (status === 429 || status >= 500) return "retry";
  return "fatal";
}

export type OutboxStatus = "sent" | "failed" | "skipped";

/** Jeton başına sonuçlardan outbox durumunu çıkarır. */
export function summarizeOutcomes(outcomes: FcmOutcome[]): { status: OutboxStatus; error: string | null } {
  if (outcomes.length === 0) return { status: "skipped", error: "gönderilecek jeton yok / izin yok" };
  if (outcomes.includes("sent")) return { status: "sent", error: null };
  if (outcomes.every((o) => o === "invalid_token")) return { status: "skipped", error: "tüm jetonlar geçersizdi" };
  return { status: "failed", error: outcomes.join(",") };
}

// ---------------------------------------------------------------------
// Google OAuth2 (servis hesabı JWT)
// ---------------------------------------------------------------------
export function parseServiceAccount(raw: string | undefined | null): ServiceAccount {
  if (!raw) throw new Error("FIREBASE_SERVICE_ACCOUNT tanımlı değil");
  let sa: Partial<ServiceAccount>;
  try {
    sa = JSON.parse(raw);
  } catch {
    throw new Error("FIREBASE_SERVICE_ACCOUNT geçerli bir JSON değil");
  }
  if (!sa.client_email || !sa.private_key || !sa.project_id) {
    throw new Error("Servis hesabı JSON'unda client_email, private_key veya project_id eksik");
  }
  return sa as ServiceAccount;
}

export function buildJwtClaims(sa: ServiceAccount, nowSec: number) {
  return {
    iss: sa.client_email,
    scope: FCM_SCOPE,
    aud: sa.token_uri ?? DEFAULT_TOKEN_URI,
    iat: nowSec,
    exp: nowSec + 3600,
  };
}

export function base64url(input: Uint8Array | string): string {
  const bytes = typeof input === "string" ? new TextEncoder().encode(input) : input;
  let bin = "";
  for (const b of bytes) bin += String.fromCharCode(b);
  return btoa(bin).replaceAll("+", "-").replaceAll("/", "_").replace(/=+$/, "");
}

export function pemToDer(pem: string): Uint8Array {
  const b64 = pem
    .replace(/-----BEGIN [A-Z ]+-----/, "")
    .replace(/-----END [A-Z ]+-----/, "")
    .replace(/\\n/g, "")
    .replace(/\s+/g, "");
  const bin = atob(b64);
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}

/** RS256 imzalı JWT üretir (WebCrypto: Deno ve Node'da hazır). */
export async function signServiceAccountJwt(sa: ServiceAccount, nowSec: number): Promise<string> {
  const header = base64url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const payload = base64url(JSON.stringify(buildJwtClaims(sa, nowSec)));
  const data = `${header}.${payload}`;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToDer(sa.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = new Uint8Array(
    await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(data)),
  );
  return `${data}.${base64url(sig)}`;
}
