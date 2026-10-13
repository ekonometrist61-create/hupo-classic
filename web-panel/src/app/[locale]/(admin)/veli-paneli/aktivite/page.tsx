import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import ActivityView from "@/components/veli-paneli/ActivityView";
import VeliMessage from "@/components/veli-paneli/VeliMessage";
import ChildScope from "@/components/veli-paneli/ChildScope";
import { redirect } from "@/i18n/navigation";
import { loadVeliAccess } from "@/lib/veli-paneli/access";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata() {
  const t = await getTranslations("veliPaneli.nav");
  return { title: t("activity") };
}

export default async function AktivitePage({
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

  let body: React.ReactNode;
  if (access.kind === "ok") {
    body = (
      <ChildScope
        students={access.students}
        render={(_studentId, data) => (
          <ActivityView haftalik={data.haftalik} />
        )}
      />
    );
  } else if (access.kind === "error") {
    body = <VeliMessage text={t("error")} />;
  } else {
    body = <VeliMessage text={t("notParent")} />;
  }

  return (
    <div>
      <PageBreadcrumb pageTitle={t("nav.activity")} />
      {body}
    </div>
  );
}
