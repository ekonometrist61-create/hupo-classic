import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import SegmentsManager from "@/components/yonetim/merkez/SegmentsManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata() {
  const t = await getTranslations("yonetim.merkez.pages.segments");
  return { title: t("title") };
}

export default async function Page({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("yonetim.merkez.pages.segments");

  return (
    <div>
      <PageBreadcrumb pageTitle={t("title")} description={t("desc")} />
      <SegmentsManager />
    </div>
  );
}