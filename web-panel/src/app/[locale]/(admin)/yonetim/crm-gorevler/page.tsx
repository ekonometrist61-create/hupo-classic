import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import CrmGorevlerManager from "@/components/yonetim/panel/CrmGorevlerManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "CRM Görevleri" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="CRM Görevleri" description={d("crmGorevler")} />
      <CrmGorevlerManager />
    </div>
  );
}
