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
    <div className="rounded-2xl border border-gray-200 bg-white p-5 dark:border-gray-800 dark:bg-white/3">
      <span className="text-theme-xs font-medium text-gray-500 dark:text-gray-400">
        {label}
      </span>
      <h4 className="mt-2.5 text-[28px] leading-9 font-semibold tracking-tight text-navy dark:text-white/90">
        {value}
      </h4>
      <div className="mt-1.5 text-theme-xs font-medium text-gray-500 dark:text-gray-400">
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
    </div>
  );
}
