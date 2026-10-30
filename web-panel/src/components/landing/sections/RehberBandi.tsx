import { LEAD_MAGNET_ACIK } from "@/lib/lead-magnet";
import { getTranslations } from "next-intl/server";
import { Link } from "@/i18n/navigation";

// İkincil, düşük vurgulu tek satırlık bant: düğme değil metin bağlantısı. Ana CTA (/demo) değişmez.
// Bayrak kapalıyken hiçbir şey çizilmez.
export async function RehberBandi() {
  if (!LEAD_MAGNET_ACIK) return null;
  const t = await getTranslations("landing.rehberBand");

  return (
    <aside aria-label={t("etiket")} className="border-y border-cream-dark bg-cream py-4 dark:border-gray-800 dark:bg-gray-950">
      <div className="mx-auto flex max-w-4xl flex-wrap items-center justify-center gap-x-3 gap-y-1 px-4 text-center text-sm sm:px-6">
        <span className="font-bold text-navy-muted dark:text-gray-300">{t("etiket")}:</span>
        <span className="font-semibold">{t("baslik")}</span>
        <Link
          href="/rehber/carpim-tablosu-pif-noktalari"
          className="inline-flex min-h-11 items-center font-bold text-brand-700 underline underline-offset-2 hover:text-brand-600 dark:text-brand-300"
        >
          {t("link")} →
        </Link>
      </div>
    </aside>
  );
}
