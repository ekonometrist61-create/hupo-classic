import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import EldeTutmaManager from "@/components/yonetim/panel/EldeTutmaManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Elde Tutma" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="Elde Tutma" description={d("eldeTutma")} />
      <EldeTutmaManager />
    </div>
  );
}
