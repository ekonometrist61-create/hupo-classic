"use client";

import { useCurrentRole } from "@/hooks/useCurrentRole";
import { usePathname, useRouter } from "@/i18n/navigation";
import { DEMO_MODE } from "@/lib/demo-mode";
import { useTranslations } from "next-intl";
import { useEffect, type ReactNode } from "react";

// Öğretmenin tek kullanabildiği /yonetim ekranı (TASKS §20, K1-K2).
const OGRETMEN_ANA_YOLU = "/yonetim/siniflar";

/** Öğretmen rolünü /yonetim altında yalnızca "Sınıflarım" ekranına yönlendirir.
 *  Yalnızca arayüz kolaylığıdır; asıl yetki veritabanı fonksiyonlarındadır. */
export default function RoleGuard() {
  const role = useCurrentRole();
  const pathname = usePathname();
  const router = useRouter();

  useEffect(() => {
    if (
      role === "ogretmen" &&
      pathname.startsWith("/yonetim") &&
      !pathname.startsWith(OGRETMEN_ANA_YOLU)
    ) {
      router.replace(OGRETMEN_ANA_YOLU);
    }
  }, [role, pathname, router]);

  return null;
}

/** /yonetim içeriğini rol çözülene kadar gizler; böylece öğretmen yönetim ekranlarını bir an bile görmez.
 *  Admin içeriği yalnızca rol admin olduğunda çizilir. Öğretmen yalnızca Sınıflarım ekranını görür,
 *  diğer yollar oraya yönlenirken yükleme durumu gösterilir. Demo modunda rol admin kabul edilir. */
export function RolKapisi({ children }: { children: ReactNode }) {
  const t = useTranslations("yonetim.siniflar");
  const fetchedRole = useCurrentRole();
  const role = DEMO_MODE ? "admin" : fetchedRole;
  const pathname = usePathname();
  const router = useRouter();

  const ogretmenBaskaYolda =
    role === "ogretmen" && !pathname.startsWith(OGRETMEN_ANA_YOLU);

  useEffect(() => {
    if (ogretmenBaskaYolda) router.replace(OGRETMEN_ANA_YOLU);
  }, [ogretmenBaskaYolda, router]);

  const icerikGosterilebilir =
    role === "admin" || (role === "ogretmen" && !ogretmenBaskaYolda);

  if (!icerikGosterilebilir) {
    return (
      <p
        role="status"
        className="py-16 text-center text-sm text-gray-500 dark:text-gray-400"
      >
        {t("loading")}
      </p>
    );
  }

  return <>{children}</>;
}
