import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import MesajGunluguManager from "@/components/yonetim/panel/MesajGunluguManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Gönderim Günlüğü" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");
  return (
    <div>
      <PageBreadcrumb pageTitle="Gönderim Günlüğü" description={d("mesajGunlugu")} />
      <MesajGunluguManager />
    </div>
  );
}
