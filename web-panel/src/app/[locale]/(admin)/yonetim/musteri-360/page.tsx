import Musteri360Manager from "@/components/yonetim/panel/Musteri360Manager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Müşteri 360°" };

export default async function Musteri360Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("yonetim.shell");
  return (
    <div>
      <h2 className="mb-6 text-2xl font-bold text-gray-800 dark:text-white/90">
        {t("pageDesc.musteri360")}
      </h2>
      <Musteri360Manager />
    </div>
  );
}
