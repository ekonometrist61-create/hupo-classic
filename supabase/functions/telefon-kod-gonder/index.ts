// Supabase Edge Function: telefon-kod-gonder
// Veli telefon doğrulaması: giriş yapmış veli numarasını gönderir, 6 haneli kod SMS'le gelir.
// JWT doğrulaması AÇIK (varsayılan): gateway geçersiz oturumu zaten reddeder; yine de
// kullanıcı kimliği admin.auth.getUser ile çözülür.
// Akış: JWT → telefon_kod_uret (service_role; tekillik, hız sınırı, rol kontrolü SQL'de) → SMS.
// SMS sağlayıcısı: İleti Merkezi. Ortam değişkenleri (Supabase secrets, repoya yazılmaz):
// ILETIMERKEZI_KEY, ILETIMERKEZI_HASH, ILETIMERKEZI_SENDER. Yapılandırılmadan fonksiyon
// kod üretmez ve 503 döner (fail-closed).

import { createClient } from "npm:@supabase/supabase-js@2";

declare const Deno: {
  env: { get(k: string): string | undefined };
  serve(handler: (req: Request) => Promise<Response> | Response): void;
};

const ALLOWED_ORIGINS = [
  "https://hupolingo.com",
  "https://www.hupolingo.com",
  "http://localhost:3000",
];

function cors(req: Request): Record<string, string> {
  const origin = req.headers.get("origin") ?? "";
  const h: Record<string, string> = {
    "access-control-allow-headers": "content-type, authorization, apikey, x-client-info",
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

// SMS sağlayıcısı: İleti Merkezi (karar, TASKS.md §22). Resmi dokümanla doğrulandı:
// POST https://api.iletimerkezi.com/v1/send-sms/json, kimlik doğrulama gövdede
// (request.authentication), alıcı alanı "receipents" (dokümandaki yazım), OTP
// işlemsel mesaj olduğu için iys "0". Başarı: response.status.code === 200.
// Erişim: panelde "API kullanımına izin ver" açık olmalı; panelde IP kısıtı varsa
// Supabase Edge Function'ların çıkış IP'si sabit olmadığı için kısıt kapatılmalı.
type SmsSaglayici = (telefon: string, metin: string) => Promise<void>;

function iletiMerkeziSaglayici(): SmsSaglayici | null {
  const key = Deno.env.get("ILETIMERKEZI_KEY");
  const hash = Deno.env.get("ILETIMERKEZI_HASH");
  // Gönderici başlığı açıkça tanımlanmalı; yoksa varsayılana düşülmez.
  const sender = Deno.env.get("ILETIMERKEZI_SENDER");
  if (!key || !hash || !sender) return null;

  return async (telefon, metin) => {
    const res = await fetch("https://api.iletimerkezi.com/v1/send-sms/json", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        request: {
          authentication: { key, hash },
          order: {
            sender,
            iys: "0",
            message: {
              text: metin,
              receipents: { number: [telefon.replace(/^\+/, "")] },
            },
          },
        },
      }),
    });
    const json = await res.json().catch(() => null);
    const kod = json?.response?.status?.code;
    if (kod !== 200) throw new Error(`İleti Merkezi hata kodu: ${kod ?? res.status}`);
  };
}

// Yapılandırılmamışsa null: fonksiyon kod üretmeden 503 döner (fail-closed).
const saglayiciSec = iletiMerkeziSaglayici;

// RPC hata kodlarını kullanıcıya gösterilebilir yanıta çevirir.
function rpcHatasi(req: Request, error: { code?: string; message: string }) {
  if (error.code === "22023") return reply(req, 400, { hata: error.message });
  if (error.code === "42501") return reply(req, 403, { hata: error.message });
  if (error.code === "23505") return reply(req, 409, { hata: error.message });
  if (error.code === "P0001") return reply(req, 429, { hata: error.message });
  console.error("telefon_kod_uret hatası:", error);
  return reply(req, 500, { hata: "Kod gönderilemedi. Lütfen tekrar deneyin." });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: cors(req) });
  if (req.method !== "POST") return reply(req, 405, { hata: "Yalnızca POST" });

  const token = (req.headers.get("authorization") ?? "").replace(/^Bearer\s+/i, "");
  if (!token) return reply(req, 401, { hata: "Oturum bulunamadı" });

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return reply(req, 400, { hata: "Geçersiz JSON" });
  }
  const telefon = typeof body.telefon === "string" ? body.telefon : "";

  const admin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );

  const { data: kullanici, error: kullaniciHata } = await admin.auth.getUser(token);
  if (kullaniciHata || !kullanici.user) return reply(req, 401, { hata: "Oturum geçersiz" });

  const gonder = saglayiciSec();
  if (!gonder) {
    return reply(req, 503, { hata: "Doğrulama SMS'i şu an gönderilemiyor. Daha sonra tekrar deneyin." });
  }

  const { data, error } = await admin.rpc("telefon_kod_uret", {
    p_user_id: kullanici.user.id,
    p_ham_telefon: telefon,
  });
  if (error) return rpcHatasi(req, error);

  const { telefon: normalize, kod } = data as { telefon: string; kod: string };
  try {
    await gonder(normalize, `Hupolingo doğrulama kodunuz: ${kod}. Bu kodu kimseyle paylaşmayın.`);
  } catch (e) {
    console.error("SMS gönderim hatası:", e);
    return reply(req, 502, { hata: "SMS gönderilemedi. Lütfen tekrar deneyin." });
  }

  return reply(req, 200, { ok: true, telefon: normalize });
});
