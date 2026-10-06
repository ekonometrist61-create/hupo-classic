"use client";

import { useCurrentRole } from "@/hooks/useCurrentRole";
import { usePathname, useRouter } from "@/i18n/navigation";
import { useEffect } from "react";

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
      !pathname.startsWith("/yonetim/siniflar")
    ) {
      router.replace("/yonetim/siniflar");
    }
  }, [role, pathname, router]);

  return null;
}
