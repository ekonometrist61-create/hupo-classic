"use client";

import { useCallback, useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import DesktopOnly from "@/components/ui/DesktopOnly";
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

// Dokunma hedefi en az 44 px; tablo ilk sütunu yatay kaydırmada sabit kalır (TASKS §20).
const LINK_TOUCH = `${linkBtn} inline-flex min-h-11 items-center`;
const TH_STICKY =
  "sticky start-0 z-10 bg-[#f8fafb] px-4 py-3 text-start text-[11px] font-semibold tracking-wide whitespace-nowrap text-gray-500 uppercase dark:bg-gray-900 dark:text-gray-400";
const TD_STICKY = `${tdClass} sticky start-0 z-10 bg-white dark:bg-gray-900`;

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
          <div className="w-full min-w-40 sm:w-auto">
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
          <div className="w-full sm:w-auto">
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
          <div className="w-full sm:w-auto">
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
          <DesktopOnly>
            <button
              type="button"
              className={`${primaryBtn} ms-auto`}
              onClick={() => setFormOpen(true)}
            >
              {t("manual")}
            </button>
          </DesktopOnly>
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
          <>
            {/* Telefon (md altı): kart görünümü, yalnızca okuma. */}
            <ul className="space-y-3 md:hidden">
              {rows.map((p) => (
                <li
                  key={p.id}
                  className="rounded-xl border border-gray-200 p-4 dark:border-gray-800"
                >
                  <div className="flex items-start justify-between gap-3">
                    <div className="min-w-0">
                      <p className="wrap-break-word font-medium text-gray-800 dark:text-white/90">
                        {p.veli_ad ?? "-"}
                      </p>
                      <p className="wrap-break-word text-theme-xs text-gray-500 dark:text-gray-400">
                        {p.veli_email ?? ""}
                      </p>
                    </div>
                    <StatusBadge status={p.durum} />
                  </div>
                  <dl className="mt-3 grid grid-cols-2 gap-x-4 gap-y-2 text-theme-sm">
                    <div>
                      <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.date")}</dt>
                      <dd className="text-gray-800 dark:text-white/90">{formatDate(new Date(p.tarih))}</dd>
                    </div>
                    <div>
                      <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.amount")}</dt>
                      <dd className="font-semibold text-gray-800 dark:text-white/90">{formatKurus(p.tutar_kurus)}</dd>
                    </div>
                    <div>
                      <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.plan")}</dt>
                      <dd className="wrap-break-word text-gray-800 dark:text-white/90">{p.plan_ad ?? p.plan_kod ?? "-"}</dd>
                    </div>
                    <div>
                      <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.provider")}</dt>
                      <dd className="wrap-break-word text-gray-800 dark:text-white/90">{p.saglayici}</dd>
                    </div>
                    {p.aciklama && (
                      <div className="col-span-2">
                        <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.note")}</dt>
                        <dd className="wrap-break-word text-gray-800 dark:text-white/90">{p.aciklama}</dd>
                      </div>
                    )}
                  </dl>
                </li>
              ))}
            </ul>

            {/* Tablet ve masaüstü: tablo; yatay kaydırma kapsayıcıda kalır. */}
            <div className="hidden overflow-x-auto md:block">
              <table className="min-w-full">
                <thead className="border-b border-gray-100 dark:border-gray-800">
                  <tr>
                    <th className={TH_STICKY}>{t("cols.date")}</th>
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
                      <td className={`${TD_STICKY} whitespace-nowrap`}>{formatDate(new Date(p.tarih))}</td>
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
                        <button type="button" className={LINK_TOUCH} onClick={() => setStatusTarget(p)}>
                          {t("changeStatus")}
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </>
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
