import { turEtiketi } from "@/lib/okuma/turler";
import { createClient } from "@/utils/supabase/server";
import { getTranslations } from "next-intl/server";

interface SiteOzeti {
  hikaye_sayisi?: number;
  sinif_alt?: number;
  sinif_ust?: number;
  turler?: { tur: string; adet: number }[];
}

// Okuma kataloğunun gerçek durumunu gösterir: sayılar okuma_site_ozeti() RPC'sinden gelir, metne sabit sayı yazılmaz.
// Yayında hikâye yoksa, modül kapalıysa ya da okuma hata verirse hiçbir şey çizilmez (ana sayfa bozulmaz).
export async function HikayelerSection() {
  let ozet: SiteOzeti | null = null;
  try {
    const supabase = await createClient();
    const { data, error } = await supabase.rpc("okuma_site_ozeti");
    if (error || !data) return null;
    ozet = data as SiteOzeti;
  } catch {
    return null;
  }
  if (!ozet?.hikaye_sayisi || !ozet.turler?.length) return null;

  const t = await getTranslations("landing.hikayeler");

  return (
    <section id="hikayeler" className="scroll-mt-20 bg-cream py-12 dark:bg-gray-950 sm:py-16 lg:py-20">
      <div className="mx-auto max-w-4xl px-4 text-center sm:px-6 lg:px-8">
        <h2 className="text-3xl font-extrabold tracking-tight text-navy dark:text-white sm:text-4xl">{t("title")}</h2>
        <p className="mx-auto mt-3 max-w-2xl text-lg text-navy/80 dark:text-gray-300">{t("desc")}</p>
        <p className="mt-6 text-xl font-extrabold text-navy dark:text-white">
          {t("sayi", { count: ozet.hikaye_sayisi })}
          {ozet.sinif_alt && ozet.sinif_ust ? (
            <span className="font-bold text-navy/70 dark:text-gray-300">
              {" · "}
              {t("sinif", { alt: ozet.sinif_alt, ust: ozet.sinif_ust })}
            </span>
          ) : null}
        </p>
        <h3 className="sr-only">{t("turler")}</h3>
        <ul className="mt-4 flex flex-wrap justify-center gap-2">
          {ozet.turler.map((x) => (
            <li
              key={x.tur}
              className="rounded-full border border-navy/15 bg-white px-4 py-1.5 text-sm font-bold text-navy dark:border-white/15 dark:bg-gray-900 dark:text-gray-100"
            >
              {turEtiketi(x.tur)}
            </li>
          ))}
        </ul>
        <p className="mx-auto mt-6 max-w-xl text-sm text-navy/70 dark:text-gray-400">{t("not")}</p>
      </div>
    </section>
  );
}
