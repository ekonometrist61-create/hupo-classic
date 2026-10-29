import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import HarcamaManager from "@/components/yonetim/panel/HarcamaManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Reklam Harcaması" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="Reklam Harcaması" description={d("harcama")} />
      <HarcamaManager />
    </div>
  );
}
