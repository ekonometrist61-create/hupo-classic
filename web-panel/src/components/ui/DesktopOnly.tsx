"use client";

import { useTranslations } from "next-intl";

/**
 * Telefonda (md altı) yalnızca bilgilendirme gösterir, işlemi gizler (TASKS §20, K3).
 * Tablet (md ve üstü) işlemi aynen gösterir. Veri değiştiren işler bu sarmalayıcıyla kullanılır;
 * yetki kontrolü yine de veritabanında yapılır.
 */
export default function DesktopOnly({ children }: { children: React.ReactNode }) {
  const t = useTranslations("yonetim.shell");

  return (
    <>
      <div className="hidden md:contents">{children}</div>
      <p
        role="note"
        className="rounded-xl border border-gray-200 bg-gray-50 p-4 text-sm text-gray-600 md:hidden dark:border-gray-800 dark:bg-white/3 dark:text-gray-400"
      >
        {t("desktopOnly")}
      </p>
    </>
  );
}
