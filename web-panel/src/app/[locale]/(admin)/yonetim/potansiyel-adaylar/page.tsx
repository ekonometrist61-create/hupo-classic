import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import PotansiyelAdaylarManager from "@/components/yonetim/panel/PotansiyelAdaylarManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Potansiyel Adaylar" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="Potansiyel Adaylar" description={d("potansiyelAdaylar")} />
      <PotansiyelAdaylarManager />
    </div>
  );
}
