import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import PlanlerSayfa from "@/components/yonetim/panel/PlanlerSayfa";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata() {
  const t = await getTranslations("yonetim.odemeler.plans");
  return { title: t("title") };
}

export default async function Page({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("yonetim.odemeler.plans");

  return (
    <div>
      <PageBreadcrumb pageTitle={t("title")} />
      <PlanlerSayfa />
    </div>
  );
}
