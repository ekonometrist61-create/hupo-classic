import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import UsersManager from "@/components/yonetim/panel/UsersManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata() {
  const t = await getTranslations("yonetim.kullanicilar");
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
  const t = await getTranslations("yonetim.kullanicilar");

  return (
    <div>
      <PageBreadcrumb pageTitle={t("title")} description={d("members")} />
      <UsersManager />
    </div>
  );
}
