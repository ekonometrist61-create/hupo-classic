import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import MembershipView from "@/components/veli-paneli/MembershipView";
import VeliMessage from "@/components/veli-paneli/VeliMessage";
import { redirect } from "@/i18n/navigation";
import { loadVeliAccess } from "@/lib/veli-paneli/access";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata() {
  const t = await getTranslations("veliPaneli.nav");
  return { title: t("membership") };
}

export default async function UyelikPage({
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

  // Üyelik verisi veliye aittir; çocuk listesi gerekmez.
  let body: React.ReactNode;
  if (access.kind === "ok") {
    body = <MembershipView />;
  } else if (access.kind === "error") {
    body = <VeliMessage text={t("error")} />;
  } else {
    body = <VeliMessage text={t("notParent")} />;
  }

  return (
    <div>
      <PageBreadcrumb pageTitle={t("nav.membership")} />
      {body}
    </div>
  );
}
