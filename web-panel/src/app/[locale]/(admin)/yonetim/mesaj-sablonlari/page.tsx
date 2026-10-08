import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import MesajSablonlariManager from "@/components/yonetim/panel/MesajSablonlariManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Mesaj Şablonları" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="Mesaj Şablonları" description={d("mesajSablonlari")} />
      <MesajSablonlariManager />
    </div>
  );
}
