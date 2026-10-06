import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import AnalyticsView from "@/components/yonetim/merkez/AnalyticsView";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata() {
  const t = await getTranslations("yonetim.merkez.pages.analytics");
  return { title: t("title") };
}

export default async function Page({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("yonetim.merkez.pages.analytics");

  return (
    <div>
      <PageBreadcrumb pageTitle={t("title")} description={t("desc")} />
      <AnalyticsView />
    </div>
  );
}