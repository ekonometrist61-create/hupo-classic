// E-posta kuyruğu gönderici (eposta_outbox → Brevo veya Resend; sağlayıcı _shared/eposta.ts'te seçilir).
//
// Tetikleme: pg_cron (5 dk, pg_net) — migration 20261098000000 — veya elle POST.
// Güvenlik (fail-closed, sabit zamanlı karşılaştırma):
//   * x-webhook-secret başlığı OLAY_WORKER_SECRET ile eşleşirse yetkili (pg_cron yolu;
//     Vault'taki 'olay_worker_secret' ile aynı değer).
//   * x-eposta-secret başlığı EPOSTA_GONDER_SECRET ile eşleşirse yetkili (elle çağrı, geriye uyum).
//   * İki gizli de tanımsızsa 503; eşleşme yoksa 401.
//   * Adres ve içerik log'a yazılmaz.
//
// Gerekli ortam değişkenleri (Supabase secrets):
//   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY   (otomatik gelir)
//   OLAY_WORKER_SECRET                        (pg_cron ile paylaşılan gizli başlık)
//   EPOSTA_GONDER_SECRET                      (opsiyonel; elle çağrı için)
//   BREVO_API_KEY veya RESEND_API_KEY         (ikisi varsa Brevo; ayrıntı _shared/eposta.ts)
//   EPOSTA_GONDEREN_ADRES                     (sağlayıcıda doğrulanmış gönderici adresi)
//   EPOSTA_GONDEREN_AD                        (opsiyonel; varsayılan "Hupolingo")
//   PANEL_BASE_URL                            (opsiyonel; iptal bağlantısı kökü, varsayılan https://hupolingo.com)
//
// Growth kökenli satırlar (growth_household_id dolu): adres growth_households'tan, metin
// growth_templates'ten (_shared/sablon.ts üzerinden, _shared/growth_eposta.ts) gönderim anında
// üretilir. Sonuç growth_message_log'a growth_gonderim_sonucu_yaz ile yansıtılır. Diğer satırlar
// (alici_id dolu) eskisi gibi çalışır.
//
// Dağıtım: JWT doğrulaması kapalı olmalı (pg_cron Authorization başlığı göndermez):
//   supabase functions deploy eposta-gonder --no-verify-jwt
import { createClient } from "npm:@supabase/supabase-js@2";
import { epostaGonder, saglayiciSec } from "../_shared/eposta.ts";
import type { EpostaOrtam } from "../_shared/eposta.ts";
import { growthDegiskenleri, growthMesajiHazirla } from "../_shared/growth_eposta.ts";

const MAX_DENEME = 5;
const PARTI = 25;

type Satir = {
  id: string;
  alici_id: string | null;
  konu: string;
  govde: string;
  deneme: number;
  growth_household_id: string | null;
  growth_message_id: string | null;
  sablon_anahtar: string | null;
};
type Istemci = ReturnType<typeof createClient>;

// Sabit zamanlı karşılaştırma (olay-kutusu-gonder ile aynı mantık).
function sabitZamanliEsit(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let fark = 0;
  for (let i = 0; i < a.length; i++) fark |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return fark === 0;
}

// Growth kökenli bir satırı gönderir. Dönüş: gönderildi mi.
// Geçici hatalarda (okuma hatası) satır 'bekliyor' kalır; kalıcı engel/hata outbox ve günlükte işaretlenir.
// Loglara adres, metin veya değişken değeri yazılmaz; yalnız neden kodu.
async function growthSatiriGonder(
  supabase: Istemci,
  satir: Satir,
  ortam: EpostaOrtam,
  panelTaban: string,
): Promise<boolean> {
  const haneId = satir.growth_household_id;
  const mesajId = satir.growth_message_id;
  if (!haneId) return false;

  const outbox = (alan: Record<string, unknown>) =>
    supabase.from("eposta_outbox").update(alan).eq("id", satir.id);
  const gunluk = async (durum: "gonderildi" | "basarisiz" | "engellendi", hata: string | null) => {
    if (mesajId) {
      await supabase.rpc("growth_gonderim_sonucu_yaz", { p_id: mesajId, p_status: durum, p_error: hata });
    }
  };
  const kalici = async (neden: string, gunlukDurum: "basarisiz" | "engellendi") => {
    await outbox({ durum: "basarisiz", son_hata: neden });
    await gunluk(gunlukDurum, neden);
    return false;
  };

  const { data: hane, error: haneHata } = await supabase
    .from("growth_households")
    .select("email, parent_name, account_status")
    .eq("id", haneId)
    .maybeSingle();
  if (haneHata) {
    console.error("growth_households okunamadı", haneHata.code);
    return false;
  }
  if (!hane?.email || hane.account_status === "blocked") {
    return kalici("hane_uygun_degil", "engellendi");
  }

  // Gönderim anı izin kontrolü: kuyruğa alındıktan sonra geri çekilmiş izin gönderilmez.
  const { data: izinVar, error: izinHata } = await supabase.rpc("growth_pazarlama_izni_var_mi", {
    p_household_id: haneId,
    p_channel: "email",
  });
  if (izinHata) {
    console.error("growth izin kontrolü başarısız", izinHata.code);
    return false;
  }
  if (izinVar !== true) {
    return kalici("izin_yok", "engellendi");
  }

  if (!satir.sablon_anahtar) {
    return kalici("sablon_anahtari_yok", "basarisiz");
  }
  const { data: sablon, error: sablonHata } = await supabase
    .from("growth_templates")
    .select("subject, body")
    .eq("name", satir.sablon_anahtar)
    .eq("channel", "email")
    .eq("status", "active")
    .order("version", { ascending: false })
    .limit(1)
    .maybeSingle();
  if (sablonHata) {
    console.error("growth_templates okunamadı", sablonHata.code);
    return false;
  }
  if (!sablon) {
    return kalici("sablon_yok", "basarisiz");
  }

  const hazir = growthMesajiHazirla(sablon, growthDegiskenleri(hane.parent_name, panelTaban));
  if (!hazir.ok) {
    return kalici(hazir.hata, "basarisiz");
  }

  const sonuc = await epostaGonder(
    { alici: hane.email, konu: hazir.mesaj.konu, metin: hazir.mesaj.metin },
    ortam,
  );
  if (sonuc?.ok) {
    await outbox({ durum: "gonderildi", gonderildi_at: new Date().toISOString(), son_hata: null });
    await gunluk("gonderildi", null);
    return true;
  }

  const yeniDeneme = satir.deneme + 1;
  const sonHata = sonuc?.hata ?? "sağlayıcı yok";
  const kaliciMi = yeniDeneme >= MAX_DENEME;
  await outbox({
    deneme: yeniDeneme,
    son_hata: sonHata,
    durum: kaliciMi ? "basarisiz" : "bekliyor",
  });
  if (kaliciMi) {
    await gunluk("basarisiz", sonHata);
  }
  return false;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  const olaySecret = Deno.env.get("OLAY_WORKER_SECRET") ?? "";
  const epostaSecret = Deno.env.get("EPOSTA_GONDER_SECRET") ?? "";
  if (!olaySecret && !epostaSecret) {
    return new Response("Yapılandırma eksik", { status: 503 });
  }

  const webhookYetkili = olaySecret !== "" &&
    sabitZamanliEsit(olaySecret, req.headers.get("x-webhook-secret") ?? "");
  const epostaYetkili = epostaSecret !== "" &&
    sabitZamanliEsit(epostaSecret, req.headers.get("x-eposta-secret") ?? "");
  if (!webhookYetkili && !epostaYetkili) {
    return new Response("Yetkisiz", { status: 401 });
  }

  const ortam: EpostaOrtam = {
    BREVO_API_KEY: Deno.env.get("BREVO_API_KEY"),
    RESEND_API_KEY: Deno.env.get("RESEND_API_KEY"),
    EPOSTA_GONDEREN_ADRES: Deno.env.get("EPOSTA_GONDEREN_ADRES"),
    EPOSTA_GONDEREN_AD: Deno.env.get("EPOSTA_GONDEREN_AD"),
  };
  if (!saglayiciSec(ortam)) {
    return new Response("E-posta sağlayıcı yapılandırması eksik", { status: 503 });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  const panelTaban = Deno.env.get("PANEL_BASE_URL") ?? "https://hupolingo.com";

  const { data: satirlar, error } = await supabase
    .from("eposta_outbox")
    .select("id, alici_id, konu, govde, deneme, growth_household_id, growth_message_id, sablon_anahtar")
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
    if (satir.growth_household_id) {
      if (await growthSatiriGonder(supabase, satir, ortam, panelTaban)) gonderildi++;
      else basarisiz++;
      continue;
    }

    if (!satir.alici_id) {
      await supabase
        .from("eposta_outbox")
        .update({ durum: "basarisiz", son_hata: "alıcı kimliği yok" })
        .eq("id", satir.id);
      basarisiz++;
      continue;
    }
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

    const sonuc = await epostaGonder(
      { alici: adres, konu: satir.konu, metin: satir.govde },
      ortam,
    );

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
          son_hata: sonuc?.hata ?? "sağlayıcı yok",
          durum: yeniDeneme >= MAX_DENEME ? "basarisiz" : "bekliyor",
        })
        .eq("id", satir.id);
      basarisiz++;
    }
  }

  return Response.json({ islenen: (satirlar ?? []).length, gonderildi, basarisiz });
});
