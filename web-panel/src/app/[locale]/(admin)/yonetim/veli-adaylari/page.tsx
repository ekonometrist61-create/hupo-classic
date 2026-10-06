import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import VeliAdaylariManager from "@/components/yonetim/panel/VeliAdaylariManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Veli Adayları" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="Veli Adayları" description={d("leads")} />
      <VeliAdaylariManager />
    </div>
  );
}
