import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import AbDeneyManager from "@/components/yonetim/panel/AbDeneyManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "A/B Deneyleri" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="A/B Deneyleri" description={d("abDeney")} />
      <AbDeneyManager />
    </div>
  );
}
