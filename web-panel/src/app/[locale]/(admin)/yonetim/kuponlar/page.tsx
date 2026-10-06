import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import KuponManager from "@/components/yonetim/panel/KuponManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Kupon Yönetimi" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="Kupon Yönetimi" description={d("coupons")} />
      <KuponManager />
    </div>
  );
}
