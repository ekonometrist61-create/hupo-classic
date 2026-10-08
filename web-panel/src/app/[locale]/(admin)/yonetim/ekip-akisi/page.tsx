import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import EkipAkisiManager from "@/components/yonetim/panel/EkipAkisiManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Ekip Akışı" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="Ekip Akışı" description={d("ekipAkisi")} />
      <EkipAkisiManager />
    </div>
  );
}
