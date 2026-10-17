import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import CocuklarimView from "@/components/veli-paneli/CocuklarimView";
import VeliMessage from "@/components/veli-paneli/VeliMessage";
import { redirect } from "@/i18n/navigation";
import { loadVeliAccess } from "@/lib/veli-paneli/access";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata() {
  const t = await getTranslations("veliPaneli.nav");
  return { title: t("children") };
}

export default async function CocuklarimPage({
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
    body = <CocuklarimView />;
  } else if (access.kind === "error") {
    body = <VeliMessage text={t("error")} />;
  } else {
    body = <VeliMessage text={t("notParent")} />;
  }

  return (
    <div>
      <PageBreadcrumb pageTitle={t("nav.children")} />
      {body}
    </div>
  );
}
