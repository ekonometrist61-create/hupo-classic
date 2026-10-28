import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import BuyumeOzetiManager from "@/components/yonetim/panel/BuyumeOzetiManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Büyüme Özeti" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="Büyüme Özeti" description={d("buyumeOzeti")} />
      <BuyumeOzetiManager />
    </div>
  );
}
