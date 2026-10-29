import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import PaketYonetimi from "@/components/yonetim/panel/PaketYonetimi";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata() {
  const t = await getTranslations("yonetim.shell.nav");
  return { title: t("paketler") };
}

export default async function Page({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  const t = await getTranslations("yonetim.shell.nav");

  return (
    <div>
      <PageBreadcrumb pageTitle={t("paketler")} description={d("paketler")} />
      <PaketYonetimi />
    </div>
  );
}
