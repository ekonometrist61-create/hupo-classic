// node --experimental-strip-types --test supabase/functions/_shared/iyzico.test.ts
import test from "node:test";
import assert from "node:assert/strict";
import {
  buildAuthorization, buildInitPayload, cleanIp, decideCallback, formatKurus, hmacSha256Hex,
  iyzicoSignature, parseToKurus, redirectUrl, safeRaw, signedHeaders, splitName, toBase64,
} from "./iyzico.ts";

const PID = "123e4567-e89b-42d3-a456-426614174000";
const TOK = "tok_abcdef123456";

test("HMAC-SHA256 ilkeli: RFC 4231 test vektörü 2", async () => {
  assert.equal(
    await hmacSha256Hex("Jefe", "what do ya want for nothing?"),
    "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843",
  );
});

test("imza girdisi = randomKey + uriPath + body (sırayla birleştirme)", async () => {
  const a = await iyzicoSignature("s", "123456789", "/payment/bin/check", '{"a":1}');
  const b = await hmacSha256Hex("s", '123456789/payment/bin/check{"a":1}');
  assert.equal(a, b);
  assert.notEqual(a, await iyzicoSignature("s", "123456789", "/payment/bin/check", '{"a":2}'));
});

test("Authorization: iyzico belgesindeki örnekle birebir (base64 birleşimi)", () => {
  // docs.iyzico.com HMACSHA256 sayfasındaki örnek (secret belgede yok; imza hazır verilmiş)
  const sig = "079df4b2426fc7f4208d8f22fbc0349794019f8ce2b0711de7808b4874f4e796";
  const expected =
    "IYZWSv2 YXBpS2V5OnNhbmRib3gtbDlNZDFHajNJWWNtdTROZGFXeGFTVW9Db1g3REM1UkEmcmFuZG9tS2V5OjEyMzQ1Njc4OSZzaWduYXR1cmU6MDc5ZGY0YjI0MjZmYzdmNDIwOGQ4ZjIyZmJjMDM0OTc5NDAxOWY4Y2UyYjA3MTFkZTc4MDhiNDg3NGY0ZTc5Ng==";
  assert.equal(buildAuthorization("sandbox-l9Md1Gj3IYcmu4NdaWxaSUoCoX7DC5RA", "123456789", sig), expected);
});

test("signedHeaders: x-iyzi-rnd imzadaki randomKey ile aynı", async () => {
  const h = await signedHeaders("k", "s", "/x", "{}", "RND1");
  assert.equal(h["x-iyzi-rnd"], "RND1");
  assert.equal(h.authorization, buildAuthorization("k", "RND1", await iyzicoSignature("s", "RND1", "/x", "{}")));
  assert.equal(toBase64("çğ"), Buffer.from("çğ").toString("base64"));
});

test("formatKurus", () => {
  assert.equal(formatKurus(14990), "149.90");
  assert.equal(formatKurus(100), "1.00");
  assert.equal(formatKurus(5), "0.05");
  assert.equal(formatKurus(0), "0.00");
  assert.equal(formatKurus(29), "0.29");
  assert.equal(formatKurus(119900), "1199.00");
  assert.throws(() => formatKurus(-1));
  assert.throws(() => formatKurus(1.5));
  assert.throws(() => formatKurus(NaN));
});

test("parseToKurus: float tuzakları", () => {
  assert.equal(parseToKurus(0.29), 29);       // 0.29*100 = 28.999999999999996
  assert.equal(parseToKurus(1.15), 115);      // 114.99999999999999
  assert.equal(parseToKurus(149.9), 14990);
  assert.equal(parseToKurus("149.90"), 14990);
  assert.equal(parseToKurus("149.9"), 14990);
  assert.equal(parseToKurus("1"), 100);
  assert.equal(parseToKurus(1.005), null);    // 3 ondalık: kuruşa çevrilemez
  assert.equal(parseToKurus("abc"), null);
  assert.equal(parseToKurus(-1), null);
  assert.equal(parseToKurus(null), null);
  assert.equal(parseToKurus("1e3"), null);
  for (let k = 0; k <= 20000; k += 7) assert.equal(parseToKurus(formatKurus(k)), k);
  for (let k = 0; k <= 20000; k++) assert.equal(parseToKurus(k / 100), k);
});

test("buildInitPayload: alanlar ve tutar tutarlılığı", () => {
  const p = buildInitPayload({
    paymentId: PID, tutarKurus: 14990, planKod: "aylik", planAd: "Aylık Premium",
    buyer: { id: "u1", ad: "Ayşe", soyad: "Yılmaz", email: "a@b.co", ip: "1.2.3.4" },
    callbackUrl: "https://x.supabase.co/functions/v1/payments-callback?p=" + PID,
  }) as any;
  assert.equal(p.conversationId, PID);
  assert.equal(p.price, "149.90");
  assert.equal(p.paidPrice, "149.90");
  assert.equal(p.currency, "TRY");
  assert.deepEqual(p.enabledInstallments, [1]);
  assert.equal(p.basketItems[0].price, "149.90");
  assert.equal(p.basketItems[0].itemType, "VIRTUAL");
  assert.equal(p.buyer.ip, "1.2.3.4");
  assert.ok(p.buyer.identityNumber && p.buyer.gsmNumber && p.billingAddress.address);
  assert.equal(p.shippingAddress, undefined);
});

test("yardımcılar: ip ve ad ayrıştırma", () => {
  assert.equal(cleanIp("9.9.9.9, 10.0.0.1"), "9.9.9.9");
  assert.equal(cleanIp("<script>"), "85.34.78.112");
  assert.equal(cleanIp(null), "85.34.78.112");
  assert.deepEqual(splitName("Ayşe Nur Yılmaz", "a@b.co"), { ad: "Ayşe Nur", soyad: "Yılmaz" });
  assert.deepEqual(splitName("Ayşe", "a@b.co"), { ad: "Ayşe", soyad: "Veli" });
  assert.deepEqual(splitName(null, "ali@b.co"), { ad: "ali", soyad: "Veli" });
});

const ok = { status: "success", paymentStatus: "SUCCESS", conversationId: PID, token: TOK, paymentId: "1234", paidPrice: 149.9, currency: "TRY", fraudStatus: 1 };
const dec = (r: any, o: any = {}) =>
  decideCallback({ expectedPaymentId: PID, storedToken: TOK, postedToken: TOK, retrieve: r, ...o });

test("karar tablosu", () => {
  assert.deepEqual(dec(ok), { action: "complete", paymentRef: "1234", paidKurus: 14990 });
  assert.equal(dec({ ...ok, fraudStatus: undefined }).action, "complete");
  assert.equal(dec(ok, { postedToken: "baska" }).action, "reject");
  assert.equal(dec(ok, { postedToken: null }).action, "reject");
  assert.equal(dec(ok, { storedToken: null }).action, "reject");
  assert.equal(dec({ ...ok, conversationId: "baska" }).action, "reject");
  assert.equal(dec({ ...ok, token: "baska" }).action, "reject");
  assert.equal(dec({ ...ok, status: "failure", errorCode: "10051" }).action, "fail");
  assert.equal(dec({ ...ok, paymentStatus: "FAILURE" }).action, "fail");
  assert.equal(dec({ ...ok, currency: "USD" }).action, "fail");
  assert.equal(dec({ ...ok, fraudStatus: 0 }).action, "pending");
  assert.equal(dec({ ...ok, fraudStatus: -1 }).action, "fail");
  assert.equal(dec({ ...ok, paymentId: undefined }).action, "fail");
  assert.equal(dec(null).action, "fail");
  // yanlış tutar kararı SQL'e bırakılır; JS kuruşu olduğu gibi iletir
  assert.deepEqual(dec({ ...ok, paidPrice: 1 }), { action: "complete", paymentRef: "1234", paidKurus: 100 });
  assert.deepEqual(dec({ ...ok, paidPrice: "x" }), { action: "complete", paymentRef: "1234", paidKurus: null });
});

test("safeRaw ve redirectUrl", () => {
  assert.deepEqual(safeRaw({ ...ok, cardNumber: "5528", buyer: {} } as any), {
    status: "success", paymentStatus: "SUCCESS", paymentId: "1234", paidPrice: 149.9, currency: "TRY", conversationId: PID, fraudStatus: 1,
  });
  assert.equal(redirectUrl("https://app.example/", true, PID), `https://app.example/veli-paneli/abonelik?odeme=basarili&id=${PID}`);
  assert.equal(redirectUrl("https://app.example", false, PID), `https://app.example/veli-paneli/abonelik?odeme=basarisiz&id=${PID}`);
});
