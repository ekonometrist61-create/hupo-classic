import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import { redirect } from "@/i18n/navigation";
import ParentDashboard from "@/components/veli-paneli/ParentDashboard";
import type { Student } from "@/components/veli-paneli/types";
import { createClient } from "@/utils/supabase/server";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata() {
  const t = await getTranslations("veliPaneli");
  return { title: t("title") };
}

function Message({ title, text }: { title?: string; text: string }) {
  return (
    <div className="rounded-2xl border border-gray-200 bg-white px-6 py-12 text-center dark:border-gray-800 dark:bg-white/3">
      {title && (
        <h3 className="mb-2 text-lg font-semibold text-gray-800 dark:text-white/90">
          {title}
        </h3>
      )}
      <p className="text-sm text-gray-500 dark:text-gray-400">{text}</p>
    </div>
  );
}

export default async function VeliPaneliPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("veliPaneli");

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: profile } = user
    ? await supabase
        .from("profiles")
        .select("role")
        .eq("id", user.id)
        .maybeSingle()
    : { data: null };

  if (profile?.role === "admin") {
    redirect({ href: "/yonetim", locale });
  }

  let body: React.ReactNode;
  if (!user || profile?.role !== "veli") {
    body = <Message text={t("notParent")} />;
  } else {
    const { data: students } = await supabase
      .from("profiles")
      .select("id, full_name, username")
      .eq("parent_id", user.id)
      .order("full_name");

    body =
      students && students.length > 0 ? (
        <ParentDashboard students={students as Student[]} />
      ) : (
        <Message title={t("noChildren.title")} text={t("noChildren.text")} />
      );
  }

  return (
    <div>
      <PageBreadcrumb pageTitle={t("title")} />
      {body}
    </div>
  );
}
