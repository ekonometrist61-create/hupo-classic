import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import VeriKalitesiManager from "@/components/yonetim/panel/VeriKalitesiManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Veri Kalitesi ve İzin" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="Veri Kalitesi ve İzin" description={d("veriKalitesi")} />
      <VeriKalitesiManager />
    </div>
  );
}
