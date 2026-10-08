import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import GrowthAnalitikManager from "@/components/yonetim/panel/GrowthAnalitikManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Growth Analitik" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="Growth Analitik" description={d("growthAnalitik")} />
      <GrowthAnalitikManager />
    </div>
  );
}
