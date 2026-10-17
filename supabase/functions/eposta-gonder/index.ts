// E-posta kuyruğu gönderici (eposta_outbox → Brevo transactional API).
//
// Tetikleme: zamanlanmış çağrı (pg_cron + pg_net ya da harici cron) veya elle POST.
// Güvenlik: x-eposta-secret başlığı EPOSTA_GONDER_SECRET ile eşleşmeli. Secret yoksa
//           fonksiyon kapalı kalır (fail-closed). Adres ve içerik log'a yazılmaz.
//
// Gerekli ortam değişkenleri (Supabase secrets):
//   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY   (otomatik gelir)
//   EPOSTA_GONDER_SECRET                      (çağıranla paylaşılan gizli başlık)
//   BREVO_API_KEY                             (Brevo transactional API anahtarı)
//   EPOSTA_GONDEREN_ADRES                     (Brevo'da doğrulanmış gönderici adresi)
//   EPOSTA_GONDEREN_AD                        (opsiyonel; varsayılan "Hupolingo")
//
// Durum: kod hazır; Brevo anahtarı ve gönderici doğrulaması olmadan çalışmaz.
import { createClient } from "npm:@supabase/supabase-js@2";

const MAX_DENEME = 5;
const PARTI = 25;

type Satir = { id: string; alici_id: string; konu: string; govde: string; deneme: number };

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  const secret = Deno.env.get("EPOSTA_GONDER_SECRET");
  if (!secret) {
    return new Response("Yapılandırma eksik", { status: 503 });
  }
  if (req.headers.get("x-eposta-secret") !== secret) {
    return new Response("Yetkisiz", { status: 401 });
  }

  const apiKey = Deno.env.get("BREVO_API_KEY");
  const gonderen = Deno.env.get("EPOSTA_GONDEREN_ADRES");
  if (!apiKey || !gonderen) {
    return new Response("Brevo yapılandırması eksik", { status: 503 });
  }
  const gonderenAd = Deno.env.get("EPOSTA_GONDEREN_AD") ?? "Hupolingo";

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const { data: satirlar, error } = await supabase
    .from("eposta_outbox")
    .select("id, alici_id, konu, govde, deneme")
    .eq("durum", "bekliyor")
    .lt("deneme", MAX_DENEME)
    .order("created_at", { ascending: true })
    .limit(PARTI);

  if (error) {
    console.error("eposta_outbox okunamadı", error.code);
    return new Response("Kuyruk okunamadı", { status: 500 });
  }

  let gonderildi = 0;
  let basarisiz = 0;

  for (const satir of (satirlar ?? []) as Satir[]) {
    const { data: kullanici } = await supabase.auth.admin.getUserById(satir.alici_id);
    const adres = kullanici?.user?.email ?? null;

    if (!adres) {
      await supabase
        .from("eposta_outbox")
        .update({ durum: "basarisiz", son_hata: "alıcı e-posta adresi yok" })
        .eq("id", satir.id);
      basarisiz++;
      continue;
    }

    let sonuc: Response | null = null;
    try {
      sonuc = await fetch("https://api.brevo.com/v3/smtp/email", {
        method: "POST",
        headers: {
          "api-key": apiKey,
          "content-type": "application/json",
          accept: "application/json",
        },
        body: JSON.stringify({
          sender: { email: gonderen, name: gonderenAd },
          to: [{ email: adres }],
          subject: satir.konu,
          textContent: satir.govde,
        }),
      });
    } catch {
      sonuc = null;
    }

    if (sonuc?.ok) {
      await supabase
        .from("eposta_outbox")
        .update({ durum: "gonderildi", gonderildi_at: new Date().toISOString(), son_hata: null })
        .eq("id", satir.id);
      gonderildi++;
    } else {
      const yeniDeneme = satir.deneme + 1;
      await supabase
        .from("eposta_outbox")
        .update({
          deneme: yeniDeneme,
          son_hata: sonuc ? `HTTP ${sonuc.status}` : "ağ hatası",
          durum: yeniDeneme >= MAX_DENEME ? "basarisiz" : "bekliyor",
        })
        .eq("id", satir.id);
      basarisiz++;
    }
  }

  return Response.json({ islenen: (satirlar ?? []).length, gonderildi, basarisiz });
});
