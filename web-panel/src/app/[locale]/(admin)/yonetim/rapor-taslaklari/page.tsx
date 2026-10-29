import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import RaporTaslakManager from "@/components/yonetim/panel/RaporTaslakManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Haftalık Rapor Taslakları" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="Haftalık Rapor Taslakları" description={d("raporTaslak")} />
      <RaporTaslakManager />
    </div>
  );
}
