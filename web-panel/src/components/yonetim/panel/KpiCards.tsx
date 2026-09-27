"use client";

import { useTranslations } from "next-intl";

import { Link } from "@/i18n/navigation";
import { formatKurus } from "@/utils/format";
import type { DashboardSummary } from "../types";
import { percentChange } from "./helpers";

function Card({
  label,
  value,
  children,
}: {
  label: string;
  value: string;
  children?: React.ReactNode;
}) {
  return (
    <div className="rounded-2xl border border-gray-200 bg-white p-5 md:p-6 dark:border-gray-800 dark:bg-white/3">
      <span className="text-theme-sm text-gray-500 dark:text-gray-400">
        {label}
      </span>
      <h4 className="mt-2 text-title-sm font-bold text-gray-800 dark:text-white/90">
        {value}
      </h4>
      <div className="mt-2 text-theme-sm text-gray-500 dark:text-gray-400">
        {children}
      </div>
    </div>
  );
}

export default function KpiCards({ data }: { data: DashboardSummary }) {
  const t = useTranslations("yonetim.panel.kpi");
  const { kullanicilar: k, odemeler: o, abonelikler: a, sorular: s } = data;
  const change = percentChange(o.bu_ay_kurus, o.gecen_ay_kurus);

  let changeEl: React.ReactNode;
  if (change === null) {
    changeEl = (
      <span className="text-success-600 dark:text-success-500">
        {t("newRevenue")}
      </span>
    );
  } else if (change === 0) {
    changeEl = <span>{t("noChange")}</span>;
  } else {
    const up = change > 0;
    changeEl = (
      <span
        className={
          up
            ? "text-success-600 dark:text-success-500"
            : "text-error-600 dark:text-error-500"
        }
      >
        {up ? "▲" : "▼"} %{Math.abs(change).toLocaleString("tr-TR")}{" "}
        {t("vsLastMonth")}
      </span>
    );
  }

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-5">
        <Card label={t("parents")} value={k.veli.toLocaleString("tr-TR")}>
          {t("newLast30", { count: k.son_30_gun_yeni })}
        </Card>
        <Card label={t("students")} value={k.ogrenci.toLocaleString("tr-TR")} />
        <Card label={t("activeSubs")} value={a.aktif.toLocaleString("tr-TR")}>
          {t("expiringSoon", { count: a.yakinda_bitecek })}
        </Card>
        <Card label={t("revenueThisMonth")} value={formatKurus(o.bu_ay_kurus)}>
          {changeEl}
        </Card>
        <Card
          label={t("pendingQuestions")}
          value={s.bekleyen.toLocaleString("tr-TR")}
        >
          <Link
            href="/yonetim/sorular"
            className="font-medium text-brand-500 dark:text-brand-400"
          >
            {t("review")}
          </Link>
        </Card>
      </div>
      {k.bagsiz_ogrenci > 0 && (
        <div className="flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-warning-200 bg-warning-50 px-5 py-4 dark:border-warning-500/30 dark:bg-warning-500/10">
          <p className="text-theme-sm text-warning-700 dark:text-orange-400">
            {t("unlinkedWarning", { count: k.bagsiz_ogrenci })}
          </p>
          <Link
            href="/yonetim/kullanicilar"
            className="text-theme-sm font-medium text-warning-700 underline dark:text-orange-400"
          >
            {t("unlinkedAction")}
          </Link>
        </div>
      )}
    </div>
  );
}
