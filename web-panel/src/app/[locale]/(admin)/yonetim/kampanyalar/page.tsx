import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import CampaignsManager from "@/components/yonetim/merkez/CampaignsManager";
import { getTranslations, setRequestLocale } from "next-intl/server";
import { Suspense } from "react";

export async function generateMetadata() {
  const t = await getTranslations("yonetim.merkez.pages.campaigns");
  return { title: t("title") };
}

export default async function Page({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("yonetim.merkez.pages.campaigns");

  return (
    <div>
      <PageBreadcrumb pageTitle={t("title")} description={t("desc")} />
      <Suspense fallback={null}>
        <CampaignsManager />
      </Suspense>
    </div>
  );
}