import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import BildirimSekmeleri from "@/components/yonetim/panel/BildirimSekmeleri";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Bildirim Yönetimi" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="Bildirim Yönetimi" description={d("notifications")} />
      <BildirimSekmeleri />
    </div>
  );
}
