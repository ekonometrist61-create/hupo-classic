import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import BulkImport from "@/components/yonetim/sorular/BulkImport";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata() {
  const t = await getTranslations("yonetim.sorular");
  return { title: t("import.title") };
}

export default async function BulkImportPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("yonetim.sorular");

  return (
    <div>
      <PageBreadcrumb pageTitle={t("import.title")} />
      <BulkImport />
    </div>
  );
}
