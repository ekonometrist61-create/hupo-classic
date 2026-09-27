"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";
import type { DashboardSummary } from "../types";
import { DEMO_SUMMARY } from "./demoData";
import KpiCards from "./KpiCards";
import QuestionMix from "./QuestionMix";
import {
  PaymentStatusCounts,
  RecentActions,
  RecentPayments,
} from "./RecentList";
import RevenueChart from "./RevenueChart";
import { cardClass, primaryBtn } from "./styles";

export default function AdminDashboard() {
  const t = useTranslations("yonetim.panel");
  const [data, setData] = useState<DashboardSummary | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    let cancelled = false;

    // Yerel gelistirmede oturum/veri yokken panelin arayuzunu gormek icin.
    if (process.env.NEXT_PUBLIC_DEMO_MODE === "1") {
      setData(DEMO_SUMMARY);
      setLoading(false);
      return;
    }

    const run = async () => {
      const { data: res, error: err } = await createClient().rpc(
        "admin_dashboard_summary",
      );
      if (cancelled) return;
      if (err) {
        setError(err.message);
        setData(null);
      } else {
        setError(null);
        setData(res as DashboardSummary);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [reloadKey]);

  const retry = () => {
    setLoading(true);
    setReloadKey((k) => k + 1);
  };

  if (loading) {
    return (
      <div
        className={`${cardClass} px-6 py-16 text-center text-sm text-gray-500 dark:text-gray-400`}
      >
        {t("loading")}
      </div>
    );
  }
  if (error || !data) {
    return (
      <div className={`${cardClass} px-6 py-12 text-center`}>
        <p className="mb-1 text-sm font-medium text-error-600 dark:text-error-500">
          {t("error")}
        </p>
        {error && (
          <p className="mb-4 text-theme-sm text-gray-500 dark:text-gray-400">
            {error}
          </p>
        )}
        <button type="button" className={primaryBtn} onClick={retry}>
          {t("retry")}
        </button>
      </div>
    );
  }

  const empty =
    data.kullanicilar.veli + data.kullanicilar.ogrenci === 0 &&
    data.sorular.toplam === 0;

  return (
    <div className="space-y-6">
      {empty && (
        <div
          className={`${cardClass} px-6 py-4 text-sm text-gray-500 dark:text-gray-400`}
        >
          {t("empty")}
        </div>
      )}
      <KpiCards data={data} />
      <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
        <div className="xl:col-span-2">
          <RevenueChart data={data.odemeler.aylik} />
        </div>
        <QuestionMix data={data.sorular} />
      </div>
      <PaymentStatusCounts data={data.odemeler} />
      <div className="grid grid-cols-1 gap-6 xl:grid-cols-2">
        <RecentPayments data={data.son_odemeler} />
        <RecentActions data={data.son_islemler} />
      </div>
    </div>
  );
}
