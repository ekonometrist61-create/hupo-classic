import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import AdminDashboard from "@/components/yonetim/panel/AdminDashboard";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata() {
  const t = await getTranslations("yonetim.panel");
  return { title: t("title") };
}

export default async function Page({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("yonetim.panel");

  return (
    <div>
      <PageBreadcrumb pageTitle={t("heading")} description={t("subtitle")} />
      <AdminDashboard />
    </div>
  );
}
