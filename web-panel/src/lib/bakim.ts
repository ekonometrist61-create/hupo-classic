// Web yüzeyleri için bakım kontrolü.
//
// Kaynak: get_app_config() → bakim_modu.yuzeyler (admin ayarlar ekranından yazılır).
//   site    → genel sayfalar (landing, demo, vb.)
//   veli    → /veli-paneli/*
//   yonetim → /yonetim/* (yöneticiler bakım sırasında da girebilir)
// Mobil ve öğrenci web uygulaması (Flutter) bakim_modu.aktif alanını kullanır; burada değil.
//
// Hata davranışı: durum okunamazsa site AÇIK kabul edilir (fail-open). Bakım kapısı
// bir veritabanı hatası yüzünden tüm siteyi kilitlemesin.

export type BakimYuzeyi = "site" | "veli" | "yonetim";

// Bakım mesajı bakım sayfası tarafından okunur (src/app/[locale]/(full-width-pages)/bakim).
export type BakimDurumu = {
  yuzeyler: Record<BakimYuzeyi, boolean>;
};

const TTL_MS = 30_000;
let onbellek: { zaman: number; deger: BakimDurumu | null } | null = null;

/** Yoldan yüzeyi bulur. null: bakım kapısı uygulanmaz. */
export function yuzeyBul(pathname: string): BakimYuzeyi | null {
  // Yönetici giriş sayfası her zaman açık: yönetici bakımı kapatabilsin.
  if (pathname === "/yonetim-giris") return null;
  if (pathname === "/bakim" || pathname.startsWith("/bakim/")) return null;
  if (pathname === "/yonetim" || pathname.startsWith("/yonetim/")) return "yonetim";
  if (pathname === "/veli-paneli" || pathname.startsWith("/veli-paneli/")) return "veli";
  return "site";
}

/** Bakım durumunu döndürür; kısa süre önbelleğe alır. Hata → null (fail-open). */
export async function bakimDurumunuOku(): Promise<BakimDurumu | null> {
  const simdi = Date.now();
  if (onbellek && simdi - onbellek.zaman < TTL_MS) return onbellek.deger;

  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
  if (!url || !key) return null;

  let deger: BakimDurumu | null = null;
  try {
    const res = await fetch(`${url}/rest/v1/rpc/get_app_config`, {
      method: "POST",
      headers: {
        apikey: key,
        authorization: `Bearer ${key}`,
        "content-type": "application/json",
      },
      body: "{}",
      cache: "no-store",
    });
    if (res.ok) {
      const data = (await res.json()) as { bakim_modu?: Record<string, unknown> };
      const bm = data.bakim_modu ?? {};
      const y = (bm.yuzeyler ?? {}) as Partial<Record<BakimYuzeyi, unknown>>;
      deger = {
        yuzeyler: {
          site: y.site === true,
          veli: y.veli === true,
          yonetim: y.yonetim === true,
        },
      };
    }
  } catch {
    deger = null;
  }

  onbellek = { zaman: simdi, deger };
  return deger;
}

/** Bakım ekranının yolu (next-intl varsayılan yerel dil öneki ile). */
export function bakimSayfaYolu(yuzey: BakimYuzeyi): string {
  return `/tr/bakim?yuzey=${yuzey}`;
}
