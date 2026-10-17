import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import { redirect } from "@/i18n/navigation";
import CocukEkleKarti from "@/components/veli-paneli/CocukEkleKarti";
import ParentDashboard from "@/components/veli-paneli/ParentDashboard";
import VeliMessage from "@/components/veli-paneli/VeliMessage";
import { loadVeliAccess } from "@/lib/veli-paneli/access";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata() {
  const t = await getTranslations("veliPaneli");
  return { title: t("title") };
}

export default async function VeliPaneliPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("veliPaneli");

  const access = await loadVeliAccess();
  if (access.kind === "admin") {
    redirect({ href: "/yonetim", locale });
  }
  // K1: öğretmen veli panelinde kalmaz; sınıf sayfasına yönlenir.
  if (access.kind === "ogretmen") {
    redirect({ href: "/yonetim/siniflar", locale });
  }

  let body: React.ReactNode;
  if (access.kind === "ok") {
    const bagliCocukYok = access.students.length === 0;
    // K4: ana ekran "Bu hafta" özetiyle açılır (ParentDashboard). Pazarlama izni kartı
    // ana sayfadan çıkarıldı; Üyelik ve Hesap sayfasında (K6 / 2. karar) yer alır.
    body = (
      <div className="space-y-4 md:space-y-6">
        {bagliCocukYok && <CocukEkleKarti />}
        <ParentDashboard students={access.students} />
        {!bagliCocukYok && <CocukEkleKarti />}
      </div>
    );
  } else if (access.kind === "error") {
    body = <VeliMessage text={t("error")} />;
  } else {
    body = <VeliMessage text={t("notParent")} />;
  }

  return (
    <div>
      <PageBreadcrumb pageTitle={t("title")} />
      {body}
    </div>
  );
}
