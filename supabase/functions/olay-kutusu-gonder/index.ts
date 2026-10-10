// Supabase Edge Function: olay-kutusu-gonder  (--no-verify-jwt ile yayınlanır)
//
// pg_cron (5 dk, pg_net) çağırır. olay_kutusu'ndaki 'deneme_sonuc_bildirimi' olaylarını
// veliye e-posta olarak gönderir. Kilitleme, yeniden deneme ve sonuç yazımı
// veritabanı RPC'lerinde yapılır (migration 20261020001100).
//
// Gizli anahtarlar (koda yazılmaz; `supabase secrets set` ile girilir):
//   OLAY_WORKER_SECRET  pg_cron'un x-webhook-secret başlığında yolladığı metin (Vault'takiyle aynı)
//   RESEND_API_KEY      e-posta sağlayıcı anahtarı
//   OLAY_MAIL_FROM      doğrulanmış gönderici, ör. "Hupolingo <bildirim@alan.adi>"
//   PUBLIC_SITE_URL     sonuç bağlantısı için site kökü
// SUPABASE_URL ve SUPABASE_SERVICE_ROLE_KEY platform tarafından eklenir.
//
// İçerik yalnızca hizmet bildirimidir (sınav sonucu); pazarlama içeriği eklenmez.
// Günlüğe e-posta, ad veya puan yazılmaz; yanıt yalnızca sayıları döner.

import { createClient } from "npm:@supabase/supabase-js@2";

declare const Deno: {
  env: { get(k: string): string | undefined };
  serve(handler: (req: Request) => Promise<Response> | Response): void;
};

const TUR = "deneme_sonuc_bildirimi";
const PARTI_BOYUTU = 20;

interface OlayKaydi {
  id: string;
  payload: { exam_id: string; student_id: string };
  deneme: number;
}

interface Alici {
  veli_eposta: string;
  veli_ad: string | null;
  cocuk_ad: string;
  sinav_ad: string;
  puan: number;
  sira: number;
  katilimci: number;
  teslim_turu: "elle" | "sure_doldu" | "otomatik" | null;
}

const json = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });

function sabitZamanliEsit(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let fark = 0;
  for (let i = 0; i < a.length; i++) fark |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return fark === 0;
}

const KACIS: Record<string, string> = { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" };
const esc = (s: string) => s.replace(/[&<>"']/g, (c) => KACIS[c]);

const TESLIM_ACIKLAMA: Record<string, string> = {
  elle: "Sınavı süresi içinde tamamladı.",
  sure_doldu: "Süre dolduğunda cevapları otomatik olarak teslim edildi.",
  otomatik: "Sınavı tamamlamadı; süre sonunda cevapları otomatik kaydedildi.",
};

function mesajOlustur(a: Alici, sonucUrl: string) {
  const puan = Number(a.puan).toFixed(1);
  const aciklama = TESLIM_ACIKLAMA[a.teslim_turu ?? "elle"] ?? TESLIM_ACIKLAMA.elle;
  const selam = a.veli_ad ? `Merhaba ${a.veli_ad},` : "Merhaba,";
  const konu = `${a.cocuk_ad} — ${a.sinav_ad} sonucu: ${puan} puan`;

  const text = [
    selam,
    "",
    `${a.cocuk_ad} "${a.sinav_ad}" deneme sınavını tamamladı.`,
    `Puan: ${puan}`,
    `Sınıf sıralaması: ${a.sira}. / ${a.katilimci}`,
    aciklama,
    "",
    `Ayrıntılı sonuç: ${sonucUrl}`,
  ].join("\n");

  const html = `<!doctype html><html lang="tr"><body style="font-family:Arial,sans-serif;color:#1f2937;line-height:1.5">
<p>${esc(selam)}</p>
<p><strong>${esc(a.cocuk_ad)}</strong> &quot;${esc(a.sinav_ad)}&quot; deneme sınavını tamamladı.</p>
<ul><li>Puan: <strong>${puan}</strong></li><li>Sınıf sıralaması: ${a.sira}. / ${a.katilimci}</li></ul>
<p>${esc(aciklama)}</p>
<p><a href="${esc(sonucUrl)}" style="color:#147D8A;font-weight:bold">Ayrıntılı sonucu gör</a></p>
<p style="font-size:12px;color:#6b7280">Bu e-posta, çocuğunuzun sınav sonucu hakkında hizmet bildirimidir.</p>
</body></html>`;

  return { konu, html, text };
}

async function epostaGonder(
  apiKey: string,
  from: string,
  to: string,
  konu: string,
  html: string,
  text: string,
  idempotencyKey: string,
) {
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      authorization: `Bearer ${apiKey}`,
      "content-type": "application/json",
      "idempotency-key": idempotencyKey,
    },
    body: JSON.stringify({ from, to: [to], subject: konu, html, text }),
  });
  if (!res.ok) throw new Error(`e-posta sağlayıcı yanıtı ${res.status}`);
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return json(405, { error: "POST gerekli" });

  const secret = Deno.env.get("OLAY_WORKER_SECRET");
  const verilen = req.headers.get("x-webhook-secret") ?? "";
  if (!secret || !sabitZamanliEsit(secret, verilen)) return json(401, { error: "yetkisiz" });

  const apiKey = Deno.env.get("RESEND_API_KEY");
  const from = Deno.env.get("OLAY_MAIL_FROM");
  const siteUrl = Deno.env.get("PUBLIC_SITE_URL");
  if (!apiKey || !from || !siteUrl) return json(500, { error: "e-posta yapılandırması eksik" });

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );

  const { data: talepler, error: talepHata } = await supabase.rpc("olay_kutusu_talep_et", {
    p_tur: TUR,
    p_limit: PARTI_BOYUTU,
  });
  if (talepHata) return json(500, { error: "olay talebi başarısız" });

  const olaylar = (talepler ?? []) as OlayKaydi[];
  const kokUrl = siteUrl.replace(/\/$/, "");
  let gonderilen = 0;
  let basarisiz = 0;

  for (const olay of olaylar) {
    try {
      const { data: alici, error: aliciHata } = await supabase.rpc("deneme_bildirim_alici", {
        p_exam_id: olay.payload.exam_id,
        p_student_id: olay.payload.student_id,
      });
      if (aliciHata) throw new Error("alıcı sorgusu başarısız");

      if (!alici) {
        await supabase.rpc("olay_kutusu_sonuc_yaz", { p_id: olay.id, p_basarili: true, p_hata: "alici_yok" });
        continue;
      }

      const a = alici as Alici;
      const { konu, html, text } = mesajOlustur(a, `${kokUrl}/deneme-sonuclari/${olay.payload.exam_id}`);
      await epostaGonder(apiKey, from, a.veli_eposta, konu, html, text, `olay-${olay.id}`);
      await supabase.rpc("olay_kutusu_sonuc_yaz", { p_id: olay.id, p_basarili: true, p_hata: null });
      gonderilen++;
    } catch (e) {
      basarisiz++;
      await supabase.rpc("olay_kutusu_sonuc_yaz", {
        p_id: olay.id,
        p_basarili: false,
        p_hata: String((e as Error).message).slice(0, 300),
      });
    }
  }

  return json(200, { ok: true, islenen: olaylar.length, gonderilen, basarisiz });
});
