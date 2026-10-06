import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import SurveysManager from "@/components/yonetim/merkez/SurveysManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata() {
  const t = await getTranslations("yonetim.merkez.pages.surveys");
  return { title: t("title") };
}

export default async function Page({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("yonetim.merkez.pages.surveys");

  return (
    <div>
      <PageBreadcrumb pageTitle={t("title")} description={t("desc")} />
      <SurveysManager />
    </div>
  );
}