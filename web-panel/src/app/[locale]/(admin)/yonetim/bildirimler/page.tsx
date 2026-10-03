import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import BildirimManager from "@/components/yonetim/panel/BildirimManager";
import { setRequestLocale } from "next-intl/server";

export const metadata = { title: "Bildirim Yönetimi" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  return (
    <div>
      <PageBreadcrumb pageTitle="Bildirim Yönetimi" />
      <BildirimManager />
    </div>
  );
}
