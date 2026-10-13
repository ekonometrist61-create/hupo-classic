import { createClient } from "@/utils/supabase/client";

// Ziyaretçi izleme: yalnızca anonim kimlik ve UTM. Kişisel veri yok.
// Tüm okuma/yazmalar try/catch içinde; depolama yoksa sayfa yine çalışır.

const VID_KEY = "hupo_vid";
const UTM_KEY = "hupo_utm";
const UTM_KEYS = ["utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content"] as const;
const VID_RE = /^[A-Za-z0-9_-]{8,64}$/;

function depoOku(key: string): string | null {
  try {
    return window.localStorage.getItem(key);
  } catch {
    return null;
  }
}

function depoYaz(key: string, value: string): void {
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
export function ilkTemasUtm(): Record<string, string> {
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

// Form başarılı olduktan sonra: önce olay, sonra kimlik bağlama (bağlama olayları karta taşır).
// Hata sessizce yutulur; kullanıcı akışı bunu beklemez.
export async function erkenErisimSonrasiIzleme(email: string): Promise<void> {
  try {
    const supabase = createClient();
    const vid = ziyaretciKimligi();
    const utm = ilkTemasUtm();
    const olay = await supabase.rpc("growth_web_olay_kaydet", {
      p_anonymous_id: vid,
      p_event_name: "erken_erisim_gonderildi",
      p_utm: utm,
    });
    if (olay.error) return;
    await supabase.rpc("growth_web_kimlik_bagla", {
      p_anonymous_id: vid,
      p_eposta: email,
    });
  } catch {
    // İzleme başarısızlığı form sonucunu etkilemez.
  }
}
