import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import DuyuruManager from "@/components/yonetim/panel/DuyuruManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Duyurular" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="Duyurular" description={d("duyurular")} />
      <DuyuruManager />
    </div>
  );
}
