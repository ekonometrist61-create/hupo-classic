import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import QuestionsManager from "@/components/yonetim/sorular/QuestionsManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata() {
  const t = await getTranslations("yonetim.sorular");
  return { title: t("title") };
}

export default async function QuestionsPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("yonetim.sorular");

  return (
    <div>
      <PageBreadcrumb pageTitle={t("title")} />
      <QuestionsManager />
    </div>
  );
}
