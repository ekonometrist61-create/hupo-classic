// Ortak e-posta gönderici: Brevo veya Resend (ortam değişkenine göre).
//
// Sağlayıcı seçimi:
//   BREVO_API_KEY varsa  → Brevo (transactional API)
//   yoksa RESEND_API_KEY → Resend
//   ikisi de yoksa       → null (gönderim yapılmaz; çağıran 503 döner)
// Gönderen adresi (EPOSTA_GONDEREN_ADRES) sağlayıcıda doğrulanmış olmalıdır; adres yoksa
// anahtar olsa bile yapılandırma eksik sayılır ve null döner.
//
// Saf modül: ortam değerleri ve fetch parametre olarak alınır. Deno global'i kullanılmaz,
// bu yüzden hem Deno hem Node ile test edilebilir (eposta.test.ts).
// Günlük / sonuç: alıcı adresi ve içerik dönüş değerine veya log'a yazılmaz; yalnızca
// sağlayıcı adı, HTTP durumu ve kısa hata metni döner.

export type EpostaOrtam = {
  BREVO_API_KEY?: string;
  RESEND_API_KEY?: string;
  EPOSTA_GONDEREN_ADRES?: string;
  EPOSTA_GONDEREN_AD?: string;
};

export type EpostaMesaji = {
  alici: string;
  konu: string;
  html?: string;
  metin: string;
};

export type SaglayiciAdi = "brevo" | "resend";

export type Saglayici = {
  ad: SaglayiciAdi;
  apiKey: string;
  gonderenAdres: string;
  gonderenAd: string;
};

export type EpostaSonuc = {
  ok: boolean;
  saglayici: SaglayiciAdi;
  durum: number | null;
  hata: string | null;
};

export type FetchFn = (url: string, init?: RequestInit) => Promise<Response>;

/** Ortama göre sağlayıcıyı seçer. Yapılandırma eksikse null döner. */
export function saglayiciSec(ortam: EpostaOrtam): Saglayici | null {
  const gonderenAdres = ortam.EPOSTA_GONDEREN_ADRES?.trim() ?? "";
  if (!gonderenAdres) return null;
  const gonderenAd = ortam.EPOSTA_GONDEREN_AD?.trim() || "Hupolingo";

  const brevoAnahtar = ortam.BREVO_API_KEY?.trim() ?? "";
  if (brevoAnahtar) {
    return { ad: "brevo", apiKey: brevoAnahtar, gonderenAdres, gonderenAd };
  }
  const resendAnahtar = ortam.RESEND_API_KEY?.trim() ?? "";
  if (resendAnahtar) {
    return { ad: "resend", apiKey: resendAnahtar, gonderenAdres, gonderenAd };
  }
  return null;
}

function brevoIstek(s: Saglayici, m: EpostaMesaji, fetchFn: FetchFn): Promise<Response> {
  return fetchFn("https://api.brevo.com/v3/smtp/email", {
    method: "POST",
    headers: {
      "api-key": s.apiKey,
      "content-type": "application/json",
      accept: "application/json",
    },
    body: JSON.stringify({
      sender: { email: s.gonderenAdres, name: s.gonderenAd },
      to: [{ email: m.alici }],
      subject: m.konu,
      textContent: m.metin,
      ...(m.html ? { htmlContent: m.html } : {}),
    }),
  });
}

function resendIstek(s: Saglayici, m: EpostaMesaji, fetchFn: FetchFn): Promise<Response> {
  return fetchFn("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      authorization: `Bearer ${s.apiKey}`,
      "content-type": "application/json",
    },
    body: JSON.stringify({
      from: `${s.gonderenAd} <${s.gonderenAdres}>`,
      to: [m.alici],
      subject: m.konu,
      text: m.metin,
      ...(m.html ? { html: m.html } : {}),
    }),
  });
}

/**
 * Tek bir e-postayı seçilen sağlayıcıyla gönderir.
 * null: sağlayıcı yapılandırılmamış (hiçbir istek atılmaz).
 * ok=false: HTTP hatası (durum dolu) veya ağ hatası (durum null). Asla fırlatmaz.
 */
export async function epostaGonder(
  mesaj: EpostaMesaji,
  ortam: EpostaOrtam,
  fetchFn: FetchFn = (url, init) => fetch(url, init),
): Promise<EpostaSonuc | null> {
  const saglayici = saglayiciSec(ortam);
  if (!saglayici) return null;

  let res: Response;
  try {
    res = saglayici.ad === "brevo"
      ? await brevoIstek(saglayici, mesaj, fetchFn)
      : await resendIstek(saglayici, mesaj, fetchFn);
  } catch {
    return { ok: false, saglayici: saglayici.ad, durum: null, hata: "ağ hatası" };
  }

  if (!res.ok) {
    return { ok: false, saglayici: saglayici.ad, durum: res.status, hata: `HTTP ${res.status}` };
  }
  return { ok: true, saglayici: saglayici.ad, durum: res.status, hata: null };
}
