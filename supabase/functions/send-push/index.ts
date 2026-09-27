// Supabase Edge Function: send-push
//
// Database Webhook (push_outbox INSERT) -> bu fonksiyon -> FCM HTTP v1.
// Gerekli gizli anahtarlar (ASLA koda yazılmaz):
//   FIREBASE_SERVICE_ACCOUNT  Firebase servis hesabı JSON'unun tamamı
//   PUSH_WEBHOOK_SECRET       Webhook'ta "x-webhook-secret" başlığına yazılan uzun rastgele metin
// SUPABASE_URL ve SUPABASE_SERVICE_ROLE_KEY Supabase tarafından otomatik eklenir.
//
// Kurulum: mobile-app/docs/PUSH_KURULUM.md

import { createClient } from "npm:@supabase/supabase-js@2";
import {
  buildFcmMessage,
  classifyFcmResponse,
  DEFAULT_TOKEN_URI,
  type FcmOutcome,
  parseServiceAccount,
  parseWebhookPayload,
  type PushTarget,
  signServiceAccountJwt,
  summarizeOutcomes,
  timingSafeEqual,
} from "./logic.ts";

declare const Deno: {
  env: { get(k: string): string | undefined };
  serve(handler: (req: Request) => Promise<Response> | Response): void;
};

const json = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });

async function fetchAccessToken(sa: ReturnType<typeof parseServiceAccount>): Promise<string> {
  const assertion = await signServiceAccountJwt(sa, Math.floor(Date.now() / 1000));
  const res = await fetch(sa.token_uri ?? DEFAULT_TOKEN_URI, {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });
  if (!res.ok) throw new Error(`OAuth token alınamadı (${res.status})`);
  const data = await res.json();
  return data.access_token as string;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return json(405, { error: "POST gerekli" });

  const secret = Deno.env.get("PUSH_WEBHOOK_SECRET");
  const given = req.headers.get("x-webhook-secret") ?? "";
  if (!secret || !timingSafeEqual(secret, given)) return json(401, { error: "yetkisiz" });

  let ref;
  try {
    ref = parseWebhookPayload(await req.json());
  } catch (e) {
    return json(400, { error: (e as Error).message });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );

  // Aynı olay iki kez gelirse tekrar göndermemek için satırı "sending"e çek.
  const { data: claimed } = await supabase
    .from("push_outbox")
    .update({ status: "sending" })
    .eq("id", ref.outboxId)
    .in("status", ["pending", "failed"])
    .select("id, attempts")
    .maybeSingle();
  if (!claimed) return json(200, { ok: true, note: "zaten işlendi" });

  const finish = async (status: string, error: string | null) => {
    await supabase
      .from("push_outbox")
      .update({
        status,
        last_error: error,
        attempts: (claimed.attempts ?? 0) + 1,
        sent_at: status === "sent" ? new Date().toISOString() : null,
      })
      .eq("id", ref.outboxId);
  };

  try {
    // İzin/rıza/sessiz saat kuralları burada TEKRAR uygulanır (bkz. push_targets).
    const { data: targets, error } = await supabase.rpc("push_targets", {
      p_notification_id: ref.notificationId,
    });
    if (error) throw new Error(error.message);
    const list = (targets ?? []) as PushTarget[];

    if (list.length === 0) {
      const s = summarizeOutcomes([]);
      await finish(s.status, s.error);
      return json(200, { ok: true, status: s.status });
    }

    const sa = parseServiceAccount(Deno.env.get("FIREBASE_SERVICE_ACCOUNT"));
    const accessToken = await fetchAccessToken(sa);
    const url = `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`;

    const outcomes: FcmOutcome[] = [];
    for (const t of list) {
      const res = await fetch(url, {
        method: "POST",
        headers: { authorization: `Bearer ${accessToken}`, "content-type": "application/json" },
        body: JSON.stringify(buildFcmMessage(t)),
      });
      const body = await res.json().catch(() => ({}));
      const outcome = classifyFcmResponse(res.status, body);
      outcomes.push(outcome);
      if (outcome === "invalid_token") {
        await supabase.from("device_tokens").delete().eq("token", t.token);
      }
    }

    const s = summarizeOutcomes(outcomes);
    await finish(s.status, s.error);
    return json(200, { ok: true, status: s.status });
  } catch (e) {
    // Hata metnine gizli bilgi girmesin: yalnızca mesaj, en çok 300 karakter.
    await finish("failed", String((e as Error).message).slice(0, 300));
    return json(500, { ok: false });
  }
});
