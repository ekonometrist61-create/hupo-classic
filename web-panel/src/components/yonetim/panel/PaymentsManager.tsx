"use client";

import { useCallback, useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import { formatDate, formatKurus } from "@/utils/format";
import { createClient } from "@/utils/supabase/client";
import Pager from "../Pager";
import ReconciliationCard from "../merkez/ReconciliationCard";
import type { PaymentList, PaymentStatus, Plan } from "../types";
import { dateOrNull } from "./helpers";
import PaymentFormModal, { PAYMENT_STATUSES } from "./PaymentFormModal";
import PaymentStatusModal from "./PaymentStatusModal";
import PlanManager from "./PlanManager";
import StatusBadge from "./StatusBadge";
import {
  cardClass,
  inputClass,
  labelClass,
  linkBtn,
  primaryBtn,
  tdClass,
  thClass,
} from "./styles";
import type { AdminPayment } from "../types";

const PAGE_SIZE = 25;

export default function PaymentsManager() {
  const t = useTranslations("yonetim.odemeler");
  const tStatus = useTranslations("yonetim.odemeler.durum");

  const [durum, setDurum] = useState<"" | PaymentStatus>("");
  const [from, setFrom] = useState("");
  const [to, setTo] = useState("");
  const [page, setPage] = useState(0);
  const [reloadKey, setReloadKey] = useState(0);

  const [list, setList] = useState<PaymentList | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [plans, setPlans] = useState<Plan[]>([]);
  const [formOpen, setFormOpen] = useState(false);
  const [statusTarget, setStatusTarget] = useState<AdminPayment | null>(null);

  const reload = useCallback(() => setReloadKey((k) => k + 1), []);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_list_payments", {
        p_durum: durum || null,
        p_baslangic: dateOrNull(from),
        p_bitis: dateOrNull(to),
        p_limit: PAGE_SIZE,
        p_offset: page * PAGE_SIZE,
      });
      if (cancelled) return;
      if (err) {
        setError(err.message);
        setList(null);
      } else {
        setError(null);
        setList(data as PaymentList);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [durum, from, to, page, reloadKey]);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data } = await createClient()
        .from("plans")
        .select("*")
        .order("sira")
        .order("kod");
      if (!cancelled && data) setPlans(data as Plan[]);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [reloadKey]);

  const changeFilter = (fn: () => void) => {
    fn();
    setPage(0);
    setLoading(true);
  };

  const rows = list?.satirlar ?? [];
  const total = list?.toplam ?? 0;
  const start = total === 0 ? 0 : page * PAGE_SIZE + 1;
  const end = Math.min(total, page * PAGE_SIZE + rows.length);

  return (
    <div className="space-y-6">
      <div className="rounded-2xl border border-blue-light-200 bg-blue-light-50 px-5 py-4 text-theme-sm text-blue-light-700 dark:border-blue-light-500/30 dark:bg-blue-light-500/10 dark:text-blue-light-500">
        {t("banner")}
      </div>

      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-4 flex flex-wrap items-end gap-4">
          <div className="min-w-40">
            <label className={labelClass} htmlFor="f-durum">{t("filters.status")}</label>
            <select
              id="f-durum"
              className={inputClass}
              value={durum}
              onChange={(e) => changeFilter(() => setDurum(e.target.value as "" | PaymentStatus))}
            >
              <option value="">{t("filters.all")}</option>
              {PAYMENT_STATUSES.map((s) => (
                <option key={s} value={s}>{tStatus(s)}</option>
              ))}
            </select>
          </div>
          <div>
            <label className={labelClass} htmlFor="f-from">{t("filters.from")}</label>
            <input
              id="f-from"
              type="date"
              className={inputClass}
              value={from}
              max={to || undefined}
              onChange={(e) => changeFilter(() => setFrom(e.target.value))}
            />
          </div>
          <div>
            <label className={labelClass} htmlFor="f-to">{t("filters.to")}</label>
            <input
              id="f-to"
              type="date"
              className={inputClass}
              value={to}
              min={from || undefined}
              onChange={(e) => changeFilter(() => setTo(e.target.value))}
            />
          </div>
          <div className="ms-auto">
            <button type="button" className={primaryBtn} onClick={() => setFormOpen(true)}>
              {t("manual")}
            </button>
          </div>
        </div>

        <div className="mb-4 grid grid-cols-1 gap-3 sm:grid-cols-2">
          <div className="rounded-xl bg-gray-50 px-4 py-3 dark:bg-white/5">
            <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t("summary.successTotal")}</p>
            <p className="text-lg font-semibold text-success-600 dark:text-success-500">
              {formatKurus(list?.basarili_tutar_kurus ?? 0)}
            </p>
          </div>
          <div className="rounded-xl bg-gray-50 px-4 py-3 dark:bg-white/5">
            <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t("summary.count")}</p>
            <p className="text-lg font-semibold text-gray-800 dark:text-white/90">
              {total.toLocaleString("tr-TR")}
            </p>
          </div>
        </div>

        {loading ? (
          <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
        ) : error ? (
          <div className="py-8 text-center">
            <p className="mb-3 text-sm text-error-600 dark:text-error-500">{error}</p>
            <button type="button" className={primaryBtn} onClick={() => { setLoading(true); reload(); }}>
              {t("retry")}
            </button>
          </div>
        ) : rows.length === 0 ? (
          <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("empty")}</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full">
              <thead className="border-b border-gray-100 dark:border-gray-800">
                <tr>
                  <th className={thClass}>{t("cols.date")}</th>
                  <th className={thClass}>{t("cols.parent")}</th>
                  <th className={thClass}>{t("cols.plan")}</th>
                  <th className={thClass}>{t("cols.amount")}</th>
                  <th className={thClass}>{t("cols.status")}</th>
                  <th className={thClass}>{t("cols.provider")}</th>
                  <th className={thClass}>{t("cols.note")}</th>
                  <th className={thClass} />
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {rows.map((p) => (
                  <tr key={p.id}>
                    <td className={`${tdClass} whitespace-nowrap`}>{formatDate(new Date(p.tarih))}</td>
                    <td className={tdClass}>
                      <span className="block font-medium text-gray-800 dark:text-white/90">{p.veli_ad ?? "-"}</span>
                      <span className="block text-theme-xs text-gray-500 dark:text-gray-400">{p.veli_email ?? ""}</span>
                    </td>
                    <td className={tdClass}>{p.plan_ad ?? p.plan_kod ?? "-"}</td>
                    <td className={`${tdClass} whitespace-nowrap font-medium`}>{formatKurus(p.tutar_kurus)}</td>
                    <td className={tdClass}><StatusBadge status={p.durum} /></td>
                    <td className={tdClass}>{p.saglayici}</td>
                    <td className={`${tdClass} max-w-56 truncate`}>{p.aciklama ?? "-"}</td>
                    <td className={`${tdClass} whitespace-nowrap text-end`}>
                      <button type="button" className={linkBtn} onClick={() => setStatusTarget(p)}>
                        {t("changeStatus")}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {!loading && !error && total > 0 && (
          <Pager
            page={page}
            pageSize={PAGE_SIZE}
            total={total}
            onPage={(p) => { setLoading(true); setPage(p); }}
            labels={{ prev: t("pager.prev"), next: t("pager.next"), summary: `${start}–${end} / ${total}` }}
          />
        )}
      </section>

      <ReconciliationCard />

      <PlanManager plans={plans} onChanged={reload} />

      <PaymentFormModal
        isOpen={formOpen}
        onClose={() => setFormOpen(false)}
        plans={plans.filter((p) => p.aktif)}
        onSaved={reload}
      />
      {statusTarget && (
        <PaymentStatusModal
          key={statusTarget.id}
          payment={statusTarget}
          onClose={() => setStatusTarget(null)}
          onSaved={reload}
        />
      )}
    </div>
  );
}
