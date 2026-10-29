import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import KazanimKapsamiManager from "@/components/yonetim/kazanim/KazanimKapsamiManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata() {
  const t = await getTranslations("yonetim.sorular.kazanim.kapsam");
  return { title: t("title") };
}

export default async function KazanimKapsamiPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  const t = await getTranslations("yonetim.sorular.kazanim.kapsam");

  return (
    <div>
      <PageBreadcrumb pageTitle={t("title")} description={d("kazanimKapsami")} />
      <KazanimKapsamiManager />
    </div>
  );
}
