import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import KullanimRaporu from "@/components/yonetim/kullanim/KullanimRaporu";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata() {
  const t = await getTranslations("yonetim.kullanim");
  return { title: t("title") };
}

export default async function Page({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  const t = await getTranslations("yonetim.kullanim");

  return (
    <div>
      <PageBreadcrumb pageTitle={t("title")} description={d("kullanim")} />
      <KullanimRaporu />
    </div>
  );
}