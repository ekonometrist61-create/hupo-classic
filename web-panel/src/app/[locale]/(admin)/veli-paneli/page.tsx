import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import { redirect } from "@/i18n/navigation";
import CocukEkleKarti from "@/components/veli-paneli/CocukEkleKarti";
import ParentDashboard from "@/components/veli-paneli/ParentDashboard";
import type { DashboardData } from "@/components/veli-paneli/types";
import VeliAnketKapisi from "@/components/veli-paneli/VeliAnketKapisi";
import VeliMessage from "@/components/veli-paneli/VeliMessage";
import { DEMO_MODE } from "@/lib/demo-mode";
import { loadVeliAccess } from "@/lib/veli-paneli/access";
import { createClient } from "@/utils/supabase/server";
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

  // İlk çocuğun panosu sunucuda okunur ve ilk çizimde istemciye verilir; tarayıcı ayrı bir istek beklemez.
  // Okuma başarısız olursa istemci mevcut yoldan (ilk seçimde RPC) yüklemeye devam eder.
  let ilkVeri: { studentId: string; data: DashboardData } | undefined;
  if (access.kind === "ok" && access.students.length > 0 && !DEMO_MODE) {
    const studentId = access.students[0].id;
    const supabase = await createClient();
    const { data, error } = await supabase.rpc("get_student_dashboard", {
      p_student_id: studentId,
      p_gun: 7,
    });
    if (!error && data) ilkVeri = { studentId, data: data as DashboardData };
  }

  let body: React.ReactNode;
  if (access.kind === "ok") {
    const bagliCocukYok = access.students.length === 0;
    // K4: ana ekran "Bu hafta" özetiyle açılır (ParentDashboard). Pazarlama izni kartı
    // ana sayfadan çıkarıldı; Üyelik ve Hesap sayfasında (K6 / 2. karar) yer alır.
    body = (
      <div className="space-y-4 md:space-y-6">
        {/* Anket kartı (ana sayfa, 24 saatte en fazla bir kez). Yerleşimi layout'tan taşındı (W10). */}
        <VeliAnketKapisi />
        {/* #cocuk-ekle: Sonraki adım kartının "kod" bağlantısının hedefi. */}
        {bagliCocukYok && <div id="cocuk-ekle"><CocukEkleKarti /></div>}
        <ParentDashboard students={access.students} ilkVeri={ilkVeri} />
        {!bagliCocukYok && <div id="cocuk-ekle"><CocukEkleKarti /></div>}
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
