import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import KimlikEslestirmeManager from "@/components/yonetim/panel/KimlikEslestirmeManager";
import { setRequestLocale } from "next-intl/server";

export const metadata = { title: "Kimlik Eşleştirme" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  return (
    <div>
      <PageBreadcrumb
        pageTitle="Kimlik Eşleştirme"
        description="Aynı çocuğun farklı veli hesaplarından kayıtlı olduğu durumları tespit et ve çöz."
      />
      <KimlikEslestirmeManager />
    </div>
  );
}
