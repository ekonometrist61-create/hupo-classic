"use client";

import { useTranslations } from "next-intl";

import { Link } from "@/i18n/navigation";
import {
  DocsIcon,
  DollarLineIcon,
  GroupIcon,
  TimeIcon,
} from "@/icons";
import type { DashboardSummary } from "../types";
import { cardClass } from "./styles";

type Item = {
  key: string;
  icon: React.ReactNode;
  count: number;
  href: string;
};

/** "İlgi bekleyen işler": yalnızca gerçek özet verisinden türetilen, aksiyonu olan kuyruk. */
export default function WorkQueue({ data }: { data: DashboardSummary }) {
  const t = useTranslations("yonetim.panel.queue");

  const items: Item[] = [
    { key: "questions", icon: <DocsIcon />, count: data.sorular.bekleyen, href: "/yonetim/sorular" },
    { key: "payments", icon: <DollarLineIcon />, count: data.odemeler.bekleyen_adet, href: "/yonetim/odemeler" },
    { key: "expiring", icon: <TimeIcon />, count: data.abonelikler.yakinda_bitecek, href: "/yonetim/odemeler" },
    { key: "unlinked", icon: <GroupIcon />, count: data.kullanicilar.bagsiz_ogrenci, href: "/yonetim/kullanicilar" },
  ].filter((i) => i.count > 0);

  return (
    <section className={`${cardClass} p-5 sm:p-6`}>
      <div className="mb-3 flex items-start justify-between gap-3">
        <div>
          <h2 className="text-lg font-semibold text-navy dark:text-white/90">{t("title")}</h2>
          <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t("desc")}</p>
        </div>
        {items.length > 0 && (
          <span className="rounded-md bg-warning-50 px-2 py-1 text-[10px] font-semibold text-warning-700 dark:bg-warning-500/15 dark:text-orange-400">
            {t("topics", { count: items.length })}
          </span>
        )}
      </div>

      {items.length === 0 ? (
        <p className="py-6 text-center text-theme-sm text-gray-500 dark:text-gray-400">
          {t("clear")}
        </p>
      ) : (
        <ul>
          {items.map((i) => (
            <li key={i.key} className="border-b border-gray-100 last:border-0 dark:border-gray-800">
              <Link
                href={i.href}
                className="group flex items-center gap-3 py-3.5 focus-visible:outline-3 focus-visible:outline-offset-2 focus-visible:outline-blue-light-400"
              >
                <span className="grid size-9.5 shrink-0 place-items-center rounded-xl bg-brand-50 text-brand-500 dark:bg-brand-500/15 [&>svg]:size-5">
                  {i.icon}
                </span>
                <span className="min-w-0">
                  <b className="block text-theme-sm font-semibold text-gray-800 dark:text-white/90">
                    {t(`${i.key}.title`, { count: i.count })}
                  </b>
                  <span className="text-theme-xs text-gray-500 dark:text-gray-400">
                    {t(`${i.key}.desc`)}
                  </span>
                </span>
                <span aria-hidden className="ms-auto text-lg text-gray-400 transition group-hover:translate-x-0.5">
                  ›
                </span>
              </Link>
            </li>
          ))}
        </ul>
      )}

      <div className="mt-4 rounded-xl bg-[#eef5f2] px-4 py-3 text-theme-xs text-[#3d6654] dark:bg-brand-500/10 dark:text-brand-300">
        <b>{t("principleTitle")}</b>
        <br />
        {t("principleText")}
      </div>
    </section>
  );
}
