"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import { formatDateTime, formatKurus } from "@/utils/format";
import { cardClass, outlineBtn, tdClass, thClass } from "../panel/styles";
import Feedback from "../ui/Feedback";
import { adminCall } from "../useAdminRpc";
import { DEMO_RECON } from "./demoData";
import type { ReconciliationItem } from "./types";
import { DEMO_MODE } from "@/lib/demo-mode";

const COLOR = {
  bekleyen_eski: "warning",
  abonelik_yok: "warning",
  suresi_gecmis_aktif: "error",
  yinelenen: "error",
} as const;

/** Ödeme kayıtları arası tutarsızlık kontrolü. Sağlayıcı olayını DOĞRULAMAZ (sağlayıcı bağlı değil). */
export default function ReconciliationCard() {
  const t = useTranslations("yonetim.merkez.recon");
  const [items, setItems] = useState<ReconciliationItem[] | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const run = async () => {
    setBusy(true);
    setError(null);
    if (DEMO_MODE) {
      setItems(DEMO_RECON);
      setBusy(false);
      return;
    }
    const r = await adminCall<ReconciliationItem[]>("admin_odeme_mutabakat");
    setBusy(false);
    if (r.error) return setError(r.missing ? t("notDeployed") : r.error);
    setItems(r.data ?? []);
  };

  return (
    <section className={`${cardClass} p-5 sm:p-6`}>
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h2 className="text-lg font-semibold text-navy dark:text-white/90">{t("title")}</h2>
          <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t("desc")}</p>
        </div>
        <button type="button" className={outlineBtn} disabled={busy} onClick={run}>
          {busy ? t("running") : t("run")}
        </button>
      </div>
      <div className="mt-3"><Feedback kind="error" message={error} /></div>
      {items && (
        items.length === 0 ? (
          <p className="py-6 text-center text-sm text-success-700 dark:text-success-500">{t("clean")}</p>
        ) : (
          <div className="mt-3 overflow-x-auto">
            <table className="min-w-full">
              <thead>
                <tr>
                  <th className={thClass}>{t("cols.type")}</th>
                  <th className={thClass}>{t("cols.family")}</th>
                  <th className={thClass}>{t("cols.amount")}</th>
                  <th className={thClass}>{t("cols.date")}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {items.map((i) => (
                  <tr key={`${i.tur}-${i.kayit_id}`}>
                    <td className={tdClass}>
                      <Badge size="sm" color={COLOR[i.tur]}>{t(`types.${i.tur}`)}</Badge>
                    </td>
                    <td className={tdClass}>{i.veli_ad ?? "—"}</td>
                    <td className={tdClass}>{i.tutar_kurus === null ? "—" : formatKurus(i.tutar_kurus)}</td>
                    <td className={`${tdClass} whitespace-nowrap`}>{formatDateTime(i.tarih)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )
      )}
      <p className="mt-3 text-theme-xs text-gray-500">{t("note")}</p>
    </section>
  );
}
