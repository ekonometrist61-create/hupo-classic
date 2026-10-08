import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import AiOnerilerManager from "@/components/yonetim/panel/AiOnerilerManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "AI Öneriler" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="AI Öneriler" description={d("aiOneriler")} />
      <AiOnerilerManager />
    </div>
  );
}
