// Çalıştırma (proje kökünden):
//   node --experimental-strip-types --test supabase/functions/send-push/logic.test.ts
import test from "node:test";
import assert from "node:assert/strict";
import { generateKeyPairSync, createVerify } from "node:crypto";
import {
  base64url,
  buildFcmMessage,
  buildJwtClaims,
  classifyFcmResponse,
  isQuietHours,
  parseServiceAccount,
  parseWebhookPayload,
  signServiceAccountJwt,
  summarizeOutcomes,
  timingSafeEqual,
} from "./logic.ts";

const UUID = "123e4567-e89b-42d3-a456-426614174000";
const UUID2 = "223e4567-e89b-42d3-a456-426614174000";

test("webhook gövdesi: geçerli INSERT", () => {
  const r = parseWebhookPayload({ type: "INSERT", table: "push_outbox", record: { id: UUID, notification_id: UUID2 } });
  assert.deepEqual(r, { outboxId: UUID, notificationId: UUID2 });
});

test("webhook gövdesi: geçersizler reddedilir", () => {
  assert.throws(() => parseWebhookPayload(null));
  assert.throws(() => parseWebhookPayload({ type: "DELETE", record: {} }));
  assert.throws(() => parseWebhookPayload({ type: "INSERT", table: "profiles", record: { id: UUID, notification_id: UUID2 } }));
  assert.throws(() => parseWebhookPayload({ type: "INSERT", record: { id: "x; drop", notification_id: UUID2 } }));
  assert.throws(() => parseWebhookPayload({ type: "INSERT", record: { id: UUID } }));
});

test("timingSafeEqual", () => {
  assert.ok(timingSafeEqual("abc", "abc"));
  assert.ok(!timingSafeEqual("abc", "abd"));
  assert.ok(!timingSafeEqual("abc", "abcd"));
  assert.ok(!timingSafeEqual("", "x"));
});

test("sessiz saat 20:00-08:00 (Europe/Istanbul, UTC+3)", () => {
  const at = (iso: string) => new Date(iso);
  assert.ok(isQuietHours("20:00", "08:00", at("2026-09-21T21:00:00+03:00")));
  assert.ok(isQuietHours("20:00", "08:00", at("2026-09-21T03:00:00+03:00")));
  assert.ok(isQuietHours("20:00", "08:00", at("2026-09-21T07:59:00+03:00")));
  assert.ok(!isQuietHours("20:00", "08:00", at("2026-09-21T08:00:00+03:00")));
  assert.ok(!isQuietHours("20:00", "08:00", at("2026-09-21T12:00:00+03:00")));
  // UTC 18:00 = İstanbul 21:00
  assert.ok(isQuietHours("20:00", "08:00", at("2026-09-21T18:00:00Z")));
  assert.ok(isQuietHours("13:00", "15:00", at("2026-09-21T14:00:00+03:00")));
  assert.ok(!isQuietHours("00:00", "00:00", at("2026-09-21T03:00:00+03:00")));
  assert.throws(() => isQuietHours("bad", "08:00", new Date()));
});

test("FCM mesajı: yalnızca başlık/mesaj, string data, kişisel veri yok", () => {
  const m = buildFcmMessage({
    notification_id: UUID, user_id: UUID2, token: "tok", platform: "android",
    baslik: "Yeni rozet!", mesaj: "Harika gidiyorsun", tur: "rozet",
  });
  assert.equal(m.message.token, "tok");
  assert.equal(m.message.notification.title, "Yeni rozet!");
  assert.deepEqual(m.message.data, { route: "notifications", notification_id: UUID, tur: "rozet" });
  assert.ok(Object.values(m.message.data).every((v) => typeof v === "string"));
  assert.ok(!JSON.stringify(m).includes(UUID2), "user_id payload'a girmemeli");
});

test("FCM mesajı: uzun metin kısaltılır", () => {
  const m = buildFcmMessage({
    notification_id: UUID, user_id: UUID2, token: "t", platform: "ios",
    baslik: "a".repeat(500), mesaj: "b".repeat(900), tur: "bilgi",
  });
  assert.ok(m.message.notification.title.length <= 80);
  assert.ok(m.message.notification.body.length <= 240);
});

test("FCM yanıt sınıflandırma", () => {
  assert.equal(classifyFcmResponse(200, {}), "sent");
  assert.equal(
    classifyFcmResponse(404, { error: { status: "NOT_FOUND", details: [{ errorCode: "UNREGISTERED" }] } }),
    "invalid_token",
  );
  assert.equal(classifyFcmResponse(400, { error: { status: "INVALID_ARGUMENT" } }), "invalid_token");
  assert.equal(classifyFcmResponse(503, {}), "retry");
  assert.equal(classifyFcmResponse(429, {}), "retry");
  assert.equal(classifyFcmResponse(401, { error: { status: "UNAUTHENTICATED" } }), "fatal");
});

test("outbox durumu özeti", () => {
  assert.equal(summarizeOutcomes([]).status, "skipped");
  assert.equal(summarizeOutcomes(["sent", "invalid_token"]).status, "sent");
  assert.equal(summarizeOutcomes(["invalid_token"]).status, "skipped");
  assert.equal(summarizeOutcomes(["retry", "fatal"]).status, "failed");
});

test("servis hesabı ayrıştırma", () => {
  assert.throws(() => parseServiceAccount(undefined), /tanımlı değil/);
  assert.throws(() => parseServiceAccount("{bozuk"), /JSON/);
  assert.throws(() => parseServiceAccount('{"client_email":"a"}'), /eksik/);
});

test("JWT talepleri ve RS256 imzası doğrulanır", async () => {
  const { privateKey, publicKey } = generateKeyPairSync("rsa", { modulusLength: 2048 });
  const pem = privateKey.export({ type: "pkcs8", format: "pem" }).toString();
  const sa = parseServiceAccount(JSON.stringify({
    client_email: "svc@proj.iam.gserviceaccount.com", private_key: pem, project_id: "proj",
  }));
  const claims = buildJwtClaims(sa, 1000);
  assert.equal(claims.exp - claims.iat, 3600);
  assert.equal(claims.scope, "https://www.googleapis.com/auth/firebase.messaging");
  assert.equal(claims.aud, "https://oauth2.googleapis.com/token");

  const jwt = await signServiceAccountJwt(sa, 1000);
  const [h, p, s] = jwt.split(".");
  assert.deepEqual(JSON.parse(Buffer.from(h, "base64url").toString()), { alg: "RS256", typ: "JWT" });
  assert.equal(JSON.parse(Buffer.from(p, "base64url").toString()).iss, sa.client_email);
  const v = createVerify("RSA-SHA256");
  v.update(`${h}.${p}`);
  assert.ok(v.verify(publicKey, Buffer.from(s, "base64url")), "imza geçerli olmalı");
});

test("base64url dolgusuz ve URL güvenli", () => {
  assert.equal(base64url(new Uint8Array([251, 255, 254])), "-__-");
});
