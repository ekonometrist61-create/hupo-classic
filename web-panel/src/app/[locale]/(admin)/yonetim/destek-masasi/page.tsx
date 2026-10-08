import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import DestekMasasiManager from "@/components/yonetim/panel/DestekMasasiManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Destek Masası" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="Destek Masası" description={d("destekMasasi")} />
      <DestekMasasiManager />
    </div>
  );
}
