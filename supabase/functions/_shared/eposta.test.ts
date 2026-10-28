// Çalıştırma (Node 24 ile):  node --test supabase/functions/_shared/eposta.test.ts
// Çalıştırma (Deno ile):     deno test supabase/functions/_shared/eposta.test.ts
import test from "node:test";
import assert from "node:assert/strict";
import { epostaGonder, saglayiciSec } from "./eposta.ts";
import type { EpostaOrtam } from "./eposta.ts";

const GONDEREN = "gonderen@ornek.test";
const ALICI = "veli@ornek.test";
const MESAJ = { alici: ALICI, konu: "Deneme sonucu", metin: "Merhaba", html: "<p>Merhaba</p>" };

type Kayit = { url: string; init: RequestInit };

function sahteFetch(yanit: () => Response | Promise<Response>) {
  const cagrilar: Kayit[] = [];
  const f = async (url: string, init?: RequestInit): Promise<Response> => {
    cagrilar.push({ url, init: init ?? {} });
    return yanit();
  };
  return { f, cagrilar };
}

const govde = (k: Kayit) => JSON.parse(String(k.init.body));

test("saglayiciSec: hiçbir anahtar yoksa null", () => {
  assert.equal(saglayiciSec({ EPOSTA_GONDEREN_ADRES: GONDEREN }), null);
});

test("saglayiciSec: yalnız BREVO_API_KEY varsa brevo", () => {
  const s = saglayiciSec({ BREVO_API_KEY: "b-anahtar", EPOSTA_GONDEREN_ADRES: GONDEREN });
  assert.equal(s?.ad, "brevo");
  assert.equal(s?.apiKey, "b-anahtar");
  assert.equal(s?.gonderenAd, "Hupolingo");
});

test("saglayiciSec: yalnız RESEND_API_KEY varsa resend", () => {
  const s = saglayiciSec({ RESEND_API_KEY: "r-anahtar", EPOSTA_GONDEREN_ADRES: GONDEREN });
  assert.equal(s?.ad, "resend");
});

test("saglayiciSec: ikisi de varsa Brevo önceliklidir", () => {
  const s = saglayiciSec({
    BREVO_API_KEY: "b",
    RESEND_API_KEY: "r",
    EPOSTA_GONDEREN_ADRES: GONDEREN,
  });
  assert.equal(s?.ad, "brevo");
});

test("saglayiciSec: gönderen adresi yoksa anahtar olsa da null", () => {
  assert.equal(saglayiciSec({ BREVO_API_KEY: "b" }), null);
  assert.equal(saglayiciSec({ RESEND_API_KEY: "r", EPOSTA_GONDEREN_ADRES: "  " }), null);
});

test("saglayiciSec: boşluktan ibaret anahtar yok sayılır; gönderen adı verilirse kullanılır", () => {
  assert.equal(saglayiciSec({ BREVO_API_KEY: "   ", EPOSTA_GONDEREN_ADRES: GONDEREN }), null);
  const s = saglayiciSec({
    RESEND_API_KEY: "r",
    EPOSTA_GONDEREN_ADRES: GONDEREN,
    EPOSTA_GONDEREN_AD: "Hupo Test",
  });
  assert.equal(s?.gonderenAd, "Hupo Test");
});

test("epostaGonder: yapılandırma yoksa null ve hiçbir istek atılmaz", async () => {
  const { f, cagrilar } = sahteFetch(() => new Response("ok", { status: 200 }));
  const sonuc = await epostaGonder(MESAJ, {} as EpostaOrtam, f);
  assert.equal(sonuc, null);
  assert.equal(cagrilar.length, 0);
});

test("epostaGonder (Brevo): doğru uç nokta, başlık ve gövde; 201 başarı", async () => {
  const { f, cagrilar } = sahteFetch(() => new Response("{}", { status: 201 }));
  const sonuc = await epostaGonder(MESAJ, { BREVO_API_KEY: "b-anahtar", EPOSTA_GONDEREN_ADRES: GONDEREN }, f);

  assert.deepEqual(sonuc, { ok: true, saglayici: "brevo", durum: 201, hata: null });
  assert.equal(cagrilar.length, 1);
  assert.equal(cagrilar[0].url, "https://api.brevo.com/v3/smtp/email");
  assert.equal(cagrilar[0].init.method, "POST");
  const basliklar = cagrilar[0].init.headers as Record<string, string>;
  assert.equal(basliklar["api-key"], "b-anahtar");
  assert.deepEqual(govde(cagrilar[0]), {
    sender: { email: GONDEREN, name: "Hupolingo" },
    to: [{ email: ALICI }],
    subject: "Deneme sonucu",
    textContent: "Merhaba",
    htmlContent: "<p>Merhaba</p>",
  });
});

test("epostaGonder (Brevo): html verilmezse htmlContent alanı gönderilmez", async () => {
  const { f, cagrilar } = sahteFetch(() => new Response("{}", { status: 201 }));
  await epostaGonder({ alici: ALICI, konu: "k", metin: "m" }, { BREVO_API_KEY: "b", EPOSTA_GONDEREN_ADRES: GONDEREN }, f);
  assert.equal("htmlContent" in govde(cagrilar[0]), false);
});

test("epostaGonder (Brevo): 500 yanıtı ok=false, durum ve HTTP metni", async () => {
  const { f } = sahteFetch(() => new Response("hata", { status: 500 }));
  const sonuc = await epostaGonder(MESAJ, { BREVO_API_KEY: "b", EPOSTA_GONDEREN_ADRES: GONDEREN }, f);
  assert.deepEqual(sonuc, { ok: false, saglayici: "brevo", durum: 500, hata: "HTTP 500" });
});

test("epostaGonder (Resend): doğru uç nokta, Bearer başlığı ve gövde; 200 başarı", async () => {
  const { f, cagrilar } = sahteFetch(() => new Response("{}", { status: 200 }));
  const sonuc = await epostaGonder(MESAJ, { RESEND_API_KEY: "r-anahtar", EPOSTA_GONDEREN_ADRES: GONDEREN }, f);

  assert.deepEqual(sonuc, { ok: true, saglayici: "resend", durum: 200, hata: null });
  assert.equal(cagrilar[0].url, "https://api.resend.com/emails");
  const basliklar = cagrilar[0].init.headers as Record<string, string>;
  assert.equal(basliklar.authorization, "Bearer r-anahtar");
  assert.deepEqual(govde(cagrilar[0]), {
    from: `Hupolingo <${GONDEREN}>`,
    to: [ALICI],
    subject: "Deneme sonucu",
    text: "Merhaba",
    html: "<p>Merhaba</p>",
  });
});

test("epostaGonder (Resend): 422 yanıtı ok=false", async () => {
  const { f } = sahteFetch(() => new Response("{}", { status: 422 }));
  const sonuc = await epostaGonder(MESAJ, { RESEND_API_KEY: "r", EPOSTA_GONDEREN_ADRES: GONDEREN }, f);
  assert.deepEqual(sonuc, { ok: false, saglayici: "resend", durum: 422, hata: "HTTP 422" });
});

test("epostaGonder: ağ hatası fırlatmaz, ok=false ve durum null", async () => {
  const { f } = sahteFetch(() => { throw new TypeError("network down"); });
  const sonuc = await epostaGonder(MESAJ, { BREVO_API_KEY: "b", EPOSTA_GONDEREN_ADRES: GONDEREN }, f);
  assert.deepEqual(sonuc, { ok: false, saglayici: "brevo", durum: null, hata: "ağ hatası" });
});

test("epostaGonder: sonuç nesnesinde alıcı adresi veya içerik yer almaz", async () => {
  const { f } = sahteFetch(() => new Response("{}", { status: 500 }));
  const sonuc = await epostaGonder(MESAJ, { BREVO_API_KEY: "b", EPOSTA_GONDEREN_ADRES: GONDEREN }, f);
  const metin = JSON.stringify(sonuc);
  assert.equal(metin.includes(ALICI), false);
  assert.equal(metin.includes("Merhaba"), false);
});
