"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import { Link } from "@/i18n/navigation";
import { formatDate } from "@/utils/format";
import { createClient } from "@/utils/supabase/client";
import Pager from "../Pager";
import type { GrowthAiOneri, GrowthAiOneriList } from "../types";
import ErrorNote from "./ErrorNote";
import { cardClass, linkBtn, outlineBtn, tdClass, thClass } from "./styles";

const PAGE_SIZE = 25;

type Durum = "accepted" | "pending" | "rejected" | "expired";

function durumOf(r: GrowthAiOneri): Durum {
  if (r.status === "expired") return "expired";
  if (r.accepted === true) return "accepted";
  if (r.accepted === false) return "rejected";
  return "pending";
}

const DURUM_COLOR: Record<Durum, "success" | "error" | "light"> = {
  accepted: "success",
  pending: "light",
  rejected: "error",
  expired: "light",
};

export default function AiOnerilerManager() {
  const t = useTranslations("yonetim.aiOneriler");
  const [page, setPage] = useState(0);
  const [reloadKey, setReloadKey] = useState(0);

  const [rows, setRows] = useState<GrowthAiOneri[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_ai_oneri_listele", {
        p_household_id: null,
        p_limit: PAGE_SIZE,
        p_offset: page * PAGE_SIZE,
      });
      if (cancelled) return;
      if (err) {
        setError(err.message);
        setRows([]);
        setTotal(0);
      } else {
        const list = data as GrowthAiOneriList;
        setError(null);
        setRows(list.rows ?? []);
        setTotal(list.total ?? 0);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [page, reloadKey]);

  // Kabul / red: önce arayüz güncellenir; RPC hata verirse yalnızca o satır geri alınır.
  const decide = async (row: GrowthAiOneri, accepted: boolean) => {
    const optimistic: GrowthAiOneri = {
      ...row,
      accepted,
      status: accepted ? "approved" : "rejected",
    };
    setActionError(null);
    setRows((rs) => rs.map((r) => (r.id === row.id ? optimistic : r)));

    const { error: err } = await createClient().rpc("admin_ai_oneri_geri_bildirim", {
      p_recommendation_id: row.id,
      p_accepted: accepted,
    });
    if (err) {
      setRows((rs) => rs.map((r) => (r.id === row.id ? row : r)));
      setActionError(err.message);
    }
  };

  const start = total === 0 ? 0 : page * PAGE_SIZE + 1;
  const end = Math.min(total, page * PAGE_SIZE + rows.length);

  return (
    <div className="space-y-6">
      <section className={`${cardClass} p-5 sm:p-6`}>
        <p className="mb-4 text-theme-sm text-gray-500 dark:text-gray-400">{t("readOnlyNote")}</p>

        {actionError && (
          <div className="mb-4">
            <ErrorNote message={actionError} />
          </div>
        )}

        {loading ? (
          <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
        ) : error ? (
          <div className="py-8 text-center">
            <p className="mb-3 text-sm text-error-600 dark:text-error-500">{error}</p>
            <button
              type="button"
              className={outlineBtn}
              onClick={() => {
                setLoading(true);
                setReloadKey((k) => k + 1);
              }}
            >
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
                  <th className={thClass}>{t("cols.type")}</th>
                  <th className={thClass}>{t("cols.title")}</th>
                  <th className={thClass}>{t("cols.description")}</th>
                  <th className={thClass}>{t("cols.score")}</th>
                  <th className={thClass}>{t("cols.status")}</th>
                  <th className={thClass}>{t("cols.expires")}</th>
                  <th className={thClass}>{t("cols.customer")}</th>
                  <th className={thClass}>{t("cols.actions")}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {rows.map((r) => {
                  const durum = durumOf(r);
                  const locked = r.status === "expired" || r.status === "executed";
                  return (
                    <tr key={r.id}>
                      <td className={`${tdClass} whitespace-nowrap font-mono`}>{r.recommendation_type}</td>
                      <td className={`${tdClass} font-medium text-gray-800 dark:text-white/90`}>{r.title}</td>
                      <td className={tdClass}>
                        <span className="line-clamp-2 block max-w-xs" title={r.description ?? undefined}>
                          {r.description ?? "-"}
                        </span>
                      </td>
                      <td className={`${tdClass} tabular-nums`}>{r.score ?? "-"}</td>
                      <td className={tdClass}>
                        <Badge size="sm" color={DURUM_COLOR[durum]}>{t(`status.${durum}`)}</Badge>
                      </td>
                      <td className={`${tdClass} whitespace-nowrap`}>
                        {r.expires_at ? formatDate(new Date(r.expires_at)) : "-"}
                      </td>
                      <td className={`${tdClass} whitespace-nowrap`}>
                        {r.household_id ? (
                          <Link href={`/yonetim/musteri-360/${r.household_id}`} className={linkBtn}>
                            {t("customerLink")}
                          </Link>
                        ) : (
                          "-"
                        )}
                      </td>
                      <td className={`${tdClass} whitespace-nowrap`}>
                        <span className="flex gap-3">
                          <button
                            type="button"
                            className={linkBtn}
                            disabled={locked || r.accepted === true}
                            onClick={() => void decide(r, true)}
                          >
                            {t("actions.accept")}
                          </button>
                          <button
                            type="button"
                            className={linkBtn}
                            disabled={locked || r.accepted === false}
                            onClick={() => void decide(r, false)}
                          >
                            {t("actions.reject")}
                          </button>
                        </span>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}

        {!loading && !error && total > 0 && (
          <Pager
            page={page}
            pageSize={PAGE_SIZE}
            total={total}
            onPage={(p) => {
              setLoading(true);
              setPage(p);
            }}
            labels={{ prev: t("pager.prev"), next: t("pager.next"), summary: `${start}–${end} / ${total}` }}
          />
        )}
      </section>
    </div>
  );
}
