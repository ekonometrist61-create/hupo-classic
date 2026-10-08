import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import SatisHattiManager from "@/components/yonetim/panel/SatisHattiManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Satış Hattı" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="Satış Hattı" description={d("satisHatti")} />
      <SatisHattiManager />
    </div>
  );
}
