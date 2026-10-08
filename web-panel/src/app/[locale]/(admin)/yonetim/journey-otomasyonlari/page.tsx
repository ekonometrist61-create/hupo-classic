import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import JourneyOtomasyonlariManager from "@/components/yonetim/panel/JourneyOtomasyonlariManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Journey Otomasyonları" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="Journey Otomasyonları" description={d("journey-otomasyonlari")} />
      <JourneyOtomasyonlariManager />
    </div>
  );
}
