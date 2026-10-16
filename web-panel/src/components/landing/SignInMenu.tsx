"use client";

import { STUDENT_APP_URL } from "@/lib/app-url";
import { useTranslations } from "next-intl";
import Link from "next/link";
import { useEffect, useId, useRef, useState } from "react";

// Üst menüde tek "Giriş" düğmesi. Açılınca üç giriş yolu gösterilir: öğrenci, veli, öğretmen.
// Öğretmen rolü /yonetim altında çalıştığı için öğretmen girişi /yonetim-giris'e gider.
export function SignInMenu() {
  const t = useTranslations("landing.nav");
  const [open, setOpen] = useState(false);
  const panelId = useId();
  const kapsayici = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") setOpen(false);
    };
    const onDisari = (e: MouseEvent) => {
      if (kapsayici.current && !kapsayici.current.contains(e.target as Node)) setOpen(false);
    };
    window.addEventListener("keydown", onKey);
    document.addEventListener("mousedown", onDisari);
    return () => {
      window.removeEventListener("keydown", onKey);
      document.removeEventListener("mousedown", onDisari);
    };
  }, [open]);

  const secenekler = [
    { href: STUDENT_APP_URL, ad: t("studentLogin"), aciklama: t("studentLoginDesc"), dis: true },
    { href: "/veli-paneli/giris", ad: t("parentLogin"), aciklama: t("parentLoginDesc"), dis: false },
    { href: "/yonetim-giris", ad: t("teacherLogin"), aciklama: t("teacherLoginDesc"), dis: false },
  ];

  const satirSinifi =
    "flex items-start gap-3 rounded-xl px-3 py-3 transition-colors hover:bg-cream focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 dark:hover:bg-gray-800";

  return (
    <div ref={kapsayici} className="relative">
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        aria-expanded={open}
        aria-controls={panelId}
        className="inline-flex min-h-11 items-center gap-1 rounded-xl px-3 text-sm font-bold text-navy transition-colors hover:bg-cream-dark hover:text-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 dark:text-gray-100 dark:hover:bg-gray-800 dark:hover:text-brand-300"
      >
        {t("signinMenu")}
        <svg
          aria-hidden="true"
          viewBox="0 0 24 24"
          className={`h-4 w-4 transition-transform motion-reduce:transition-none ${open ? "rotate-180" : ""}`}
          fill="none"
          stroke="currentColor"
          strokeWidth={2.5}
        >
          <path d="m6 9 6 6 6-6" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </button>

      {open && (
        <div
          id={panelId}
          className="absolute end-0 top-full z-50 mt-2 w-72 rounded-2xl border border-cream-dark bg-white p-2 shadow-xl dark:border-gray-700 dark:bg-gray-900"
        >
          {secenekler.map((s) =>
            s.dis ? (
              <a key={s.ad} href={s.href} onClick={() => setOpen(false)} className={satirSinifi}>
                <SatirIcerik ad={s.ad} aciklama={s.aciklama} />
              </a>
            ) : (
              <Link key={s.ad} href={s.href} onClick={() => setOpen(false)} className={satirSinifi}>
                <SatirIcerik ad={s.ad} aciklama={s.aciklama} />
              </Link>
            )
          )}
        </div>
      )}
    </div>
  );
}

function SatirIcerik({ ad, aciklama }: { ad: string; aciklama: string }) {
  return (
    <span className="min-w-0 flex-1">
      <span className="block text-sm font-extrabold text-navy dark:text-gray-100">{ad}</span>
      <span className="mt-0.5 block text-xs leading-snug text-navy-muted dark:text-gray-400">{aciklama}</span>
    </span>
  );
}
