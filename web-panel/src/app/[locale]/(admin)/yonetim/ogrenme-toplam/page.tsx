import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import OgrenmeToplamManager from "@/components/yonetim/panel/OgrenmeToplamManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Öğrenme Analitiği (Toplu)" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="Öğrenme Analitiği (Toplu)" description={d("ogrenmeToplam")} />
      <OgrenmeToplamManager />
    </div>
  );
}
