// Ziyaretçi izleme: yalnızca anonim kimlik ve UTM. Kişisel veri yok.
// Rıza kapısı: analitik çerezine "Kabul et" denmeden localStorage'a yazılmaz, kimlik bağlanmaz,
// ağ isteği atılmaz. Karar okuyucusu consent.ts'tir (sürüm uyuşmazlığında karar yok sayılır).
// Tüm okuma/yazmalar try/catch içinde; depolama yoksa sayfa yine çalışır.

import { readAnalyticsConsent } from "../../../lib/analytics/consent";

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL;
// Vercel'de tanımlı olan publishable anahtar (ErkenErisimSection ile aynı).
const SUPABASE_KEY = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;

const VID_KEY = "hupo_vid";
const UTM_KEY = "hupo_utm";
const UTM_KEYS = ["utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content"] as const;
const VID_RE = /^[A-Za-z0-9_-]{8,64}$/;

function izinVar(): boolean {
  return readAnalyticsConsent() === "granted";
}

function depoOku(key: string): string | null {
  try {
    return window.localStorage.getItem(key);
  } catch {
    return null;
  }
}

function depoYaz(key: string, value: string): void {
  // Rıza yoksa hiçbir şey yazılmaz (tek çıkış noktası; tüm yazmalar buradan geçer).
  if (!izinVar()) return;
  try {
    window.localStorage.setItem(key, value);
  } catch {
    // Depo kapalıysa kimlik her seferinde yenilenir; bağlama yapılamaz ama form çalışır.
  }
}

export function ziyaretciKimligi(): string {
  const mevcut = depoOku(VID_KEY);
  if (mevcut && VID_RE.test(mevcut)) return mevcut;
  const yeni = `vid-${globalThis.crypto?.randomUUID?.() ?? `${Date.now().toString(36)}${Math.random().toString(36).slice(2)}`}`;
  depoYaz(VID_KEY, yeni);
  return yeni;
}

// İlk temas UTM'si: ilk ziyarette URL'den okunur ve saklanır; sonraki ziyarette değişmez.
// Rıza yoksa okunmaz ve saklanmaz; boş nesne döner.
export function ilkTemasUtm(): Record<string, string> {
  if (!izinVar()) return {};
  const mevcut = depoOku(UTM_KEY);
  if (mevcut) {
    try {
      const parsed = JSON.parse(mevcut) as Record<string, string>;
      if (parsed && typeof parsed === "object") return parsed;
    } catch {
      // Bozuk kayıt: aşağıda yeniden okunur.
    }
  }
  const params = new URLSearchParams(window.location.search);
  const utm: Record<string, string> = {};
  for (const k of UTM_KEYS) {
    const v = params.get(k)?.trim();
    if (v) utm[k] = v.slice(0, 100);
  }
  if (Object.keys(utm).length > 0) depoYaz(UTM_KEY, JSON.stringify(utm));
  return utm;
}

// Edge Function (growth-web-izle) IP hız sınırını uygular; RPC'lere doğrudan erişim kapalı.
async function izlemeIstegi(govde: Record<string, unknown>): Promise<boolean> {
  const res = await fetch(`${SUPABASE_URL}/functions/v1/growth-web-izle`, {
    method: "POST",
    headers: { "content-type": "application/json", apikey: SUPABASE_KEY ?? "" },
    body: JSON.stringify(govde),
  });
  return res.ok;
}

// Form başarılı olduktan sonra: önce olay, sonra kimlik bağlama (bağlama olayları karta taşır).
// Hata sessizce yutulur; kullanıcı akışı bunu beklemez.
export async function erkenErisimSonrasiIzleme(email: string): Promise<void> {
  // Analitik onayı yoksa: kimlik bağlama da dahil hiçbir ağ isteği atılmaz.
  if (!izinVar()) return;
  try {
    const vid = ziyaretciKimligi();
    const utm = ilkTemasUtm();
    const olay = await izlemeIstegi({
      islem: "olay",
      anonymous_id: vid,
      event_name: "erken_erisim_gonderildi",
      utm,
    });
    if (!olay) return;
    await izlemeIstegi({
      islem: "kimlik",
      anonymous_id: vid,
      eposta: email,
    });
  } catch {
    // İzleme başarısızlığı form sonucunu etkilemez.
  }
}
