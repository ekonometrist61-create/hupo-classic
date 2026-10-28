"use client";

// Anonim kullanım süresi ölçümü (site, yönetim, veli ve öğretmen yüzeyleri).
// Toplanan: yüzey, ekran adı (yol; kimlik benzeri bölümler ":id" olur, sorgu yok), süre (sn), başlangıç,
// rastgele oturum anahtarı, kaba rol (yüzeyden türetilir). Hesap/çocuk kimliği, e-posta, serbest metin YOK.
// Çerez/analitik onayı ("granted") yoksa hiçbir şey kaydedilmez ve gönderilmez.
// Sunucu: supabase/migrations/20261066000000_kullanim_suresi.sql (300 gün saklama); giriş kapısı
// supabase/functions/kullanim-izle (IP hız sınırı → service_role RPC).
import {
  ANALYTICS_CONSENT_CHANGED_EVENT,
  readAnalyticsConsent,
} from "@/lib/analytics/consent";
import { usePathname } from "next/navigation";
import { useEffect } from "react";

type Yuzey = "site" | "yonetim" | "veli" | "ogretmen";
type Rol = "ziyaretci" | "admin" | "veli" | "ogretmen";
type Olay = {
  yuzey: Yuzey;
  ekran: string;
  sure_sn: number;
  baslangic: string;
  oturum_anahtari: string;
  rol: Rol;
};

const KUYRUK_LIMITI = 200;
const GRUP_LIMITI = 50;
const EKRAN_LIMITI = 60;
const EN_UZUN_SURE_SN = 14400;
const GONDERIM_ARALIGI_MS = 60_000;

export function yuzeyVeRol(yol: string): { yuzey: Yuzey; rol: Rol } {
  if (yol === "/yonetim" || yol.startsWith("/yonetim/")) return { yuzey: "yonetim", rol: "admin" };
  if (yol === "/veli-paneli" || yol.startsWith("/veli-paneli/")) return { yuzey: "veli", rol: "veli" };
  if (yol === "/ogretmen" || yol.startsWith("/ogretmen/")) return { yuzey: "ogretmen", rol: "ogretmen" };
  return { yuzey: "site", rol: "ziyaretci" };
}

/** Yol → ekran adı: sorgu/parça atılır; sayı, UUID ve rakamlı uzun bölümler ":id" olur; ≤60 karakter. */
export function ekranAdi(yol: string): string {
  const temiz = (yol || "/").split("?")[0].split("#")[0];
  const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  const ad = temiz
    .split("/")
    .map((b) => (b && (uuid.test(b) || /^\d+$/.test(b) || (b.length > 20 && /\d/.test(b))) ? ":id" : b))
    .join("/")
    .replace(/[^A-Za-z0-9_/.:[\]-]/g, "_");
  return (ad || "/").slice(0, EKRAN_LIMITI);
}

function oturumAnahtari(): string {
  const bayt = new Uint8Array(18);
  crypto.getRandomValues(bayt);
  return Array.from(bayt, (b) => b.toString(36).padStart(2, "0")).join("").slice(0, 28);
}

const kuyruk: Olay[] = [];
let gonderiliyor = false;

async function gonder(): Promise<void> {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const anahtar = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
  if (!url || !anahtar || gonderiliyor || kuyruk.length === 0) return;
  if (readAnalyticsConsent() !== "granted") {
    kuyruk.length = 0;
    return;
  }
  gonderiliyor = true;
  try {
    while (kuyruk.length > 0) {
      const grup = kuyruk.slice(0, GRUP_LIMITI);
      let islendi = false;
      try {
        // Edge Function (kullanim-izle) IP hız sınırını uygular; RPC'ye doğrudan erişim kapalı.
        const yanit = await fetch(`${url}/functions/v1/kullanim-izle`, {
          method: "POST",
          headers: { "Content-Type": "application/json", apikey: anahtar },
          body: JSON.stringify({ olaylar: grup }),
          keepalive: true,
        });
        // 5xx dışındaki yanıtlarda (kabul ya da sunucu reddi) grup düşer; 5xx/ağ hatasında kuyrukta kalır.
        islendi = yanit.status < 500;
      } catch {
        islendi = false;
      }
      if (!islendi) break;
      kuyruk.splice(0, grup.length);
    }
  } finally {
    gonderiliyor = false;
  }
}

export default function KullanimSuresi() {
  const pathname = usePathname();

  useEffect(() => {
    const ekran = ekranAdi(pathname);
    const yol = pathname;
    let baslangic: number | null = null;
    let oturum: string | null = null;

    const izinli = () => readAnalyticsConsent() === "granted";

    const baslat = () => {
      if (!izinli()) return;
      oturum ??= oturumAnahtari();
      baslangic = Date.now();
    };

    const kapat = () => {
      const bas = baslangic;
      baslangic = null;
      if (bas === null || oturum === null || !izinli()) return;
      const sn = Math.min(Math.round((Date.now() - bas) / 1000), EN_UZUN_SURE_SN);
      if (sn < 1) return;
      const { yuzey, rol } = yuzeyVeRol(yol);
      kuyruk.push({
        yuzey,
        ekran,
        sure_sn: sn,
        baslangic: new Date(bas).toISOString(),
        oturum_anahtari: oturum,
        rol,
      });
      while (kuyruk.length > KUYRUK_LIMITI) kuyruk.shift();
    };

    const gorunurlukDegisti = () => {
      if (document.visibilityState === "hidden") {
        kapat();
        oturum = null; // arka plan: oturum kapanır, boşta süre sayılmaz
        void gonder();
      } else {
        baslat();
      }
    };

    const onayDegisti = () => {
      if (izinli()) {
        if (document.visibilityState === "visible" && baslangic === null) baslat();
      } else {
        baslangic = null;
        oturum = null;
        kuyruk.length = 0;
      }
    };

    if (document.visibilityState === "visible") baslat();
    document.addEventListener("visibilitychange", gorunurlukDegisti);
    window.addEventListener("pagehide", gorunurlukDegisti);
    window.addEventListener(ANALYTICS_CONSENT_CHANGED_EVENT, onayDegisti);
    const zamanlayici = window.setInterval(() => void gonder(), GONDERIM_ARALIGI_MS);

    return () => {
      // Rota değişti ya da bileşen kalktı: bu ekranın süresi kapanır.
      kapat();
      document.removeEventListener("visibilitychange", gorunurlukDegisti);
      window.removeEventListener("pagehide", gorunurlukDegisti);
      window.removeEventListener(ANALYTICS_CONSENT_CHANGED_EVENT, onayDegisti);
      window.clearInterval(zamanlayici);
    };
  }, [pathname]);

  return null;
}