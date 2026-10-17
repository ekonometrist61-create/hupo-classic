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

// Satır eylemleri (Kabul / Reddet) en az 44 px dokunma hedefi.
const EYLEM_BTN = `${linkBtn} inline-flex min-h-11 items-center disabled:opacity-50`;

// Tablo kendi kapsayıcısında kayar; ilk sütun kaydırmada sabit kalır.
const ILK_SUTUN_SABIT =
  "[&_tr>*:first-child]:sticky [&_tr>*:first-child]:inset-s-0 [&_tr>*:first-child]:z-1 [&_tr>*:first-child]:bg-white dark:[&_tr>*:first-child]:bg-gray-900";

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

  // Kabul ve red düğmeleri: kart ve tabloda aynı kurallar.
  const kararDugmeleri = (r: GrowthAiOneri) => {
    const locked = r.status === "expired" || r.status === "executed";
    return (
      <>
        <button
          type="button"
          className={EYLEM_BTN}
          disabled={locked || r.accepted === true}
          onClick={() => void decide(r, true)}
        >
          {t("actions.accept")}
        </button>
        <button
          type="button"
          className={EYLEM_BTN}
          disabled={locked || r.accepted === false}
          onClick={() => void decide(r, false)}
        >
          {t("actions.reject")}
        </button>
      </>
    );
  };

  const musteriBaglantisi = (r: GrowthAiOneri) =>
    r.household_id ? (
      <Link href={`/yonetim/musteri-360/${r.household_id}`} className={`${linkBtn} inline-flex min-h-11 items-center`}>
        {t("customerLink")}
      </Link>
    ) : (
      "-"
    );

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
          <>
            {/* Telefon ve küçük tablet (md altı): kart görünümü */}
            <ul className="space-y-3 md:hidden">
              {rows.map((r) => {
                const durum = durumOf(r);
                return (
                  <li key={r.id} className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
                    <div className="flex flex-wrap items-start justify-between gap-2">
                      <p className="min-w-0 font-medium wrap-break-word text-gray-800 dark:text-white/90">{r.title}</p>
                      <Badge size="sm" color={DURUM_COLOR[durum]}>{t(`status.${durum}`)}</Badge>
                    </div>
                    <p className="mt-1 font-mono text-theme-xs break-all text-gray-500 dark:text-gray-400">{r.recommendation_type}</p>
                    {r.description && (
                      <p className="mt-2 text-theme-sm wrap-break-word text-gray-700 dark:text-gray-300">{r.description}</p>
                    )}
                    <dl className="mt-3 grid grid-cols-2 gap-x-4 gap-y-3 text-theme-sm">
                      <div>
                        <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.score")}</dt>
                        <dd className="tabular-nums text-gray-800 dark:text-white/90">{r.score ?? "-"}</dd>
                      </div>
                      <div>
                        <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.expires")}</dt>
                        <dd className="text-gray-800 dark:text-white/90">
                          {r.expires_at ? formatDate(new Date(r.expires_at)) : "-"}
                        </dd>
                      </div>
                      <div>
                        <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.customer")}</dt>
                        <dd>{musteriBaglantisi(r)}</dd>
                      </div>
                    </dl>
                    <div className="mt-3 flex flex-wrap gap-x-4 gap-y-1 border-t border-gray-100 pt-2 dark:border-gray-800">
                      {kararDugmeleri(r)}
                    </div>
                  </li>
                );
              })}
            </ul>

            {/* Tablet ve masaüstü (md ve üzeri): tablo; kapsayıcısı kayar */}
            <div className={`hidden overflow-x-auto md:block ${ILK_SUTUN_SABIT}`}>
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
                        <td className={`${tdClass} whitespace-nowrap`}>{musteriBaglantisi(r)}</td>
                        <td className={`${tdClass} whitespace-nowrap`}>
                          <span className="flex flex-wrap gap-x-4 gap-y-1">{kararDugmeleri(r)}</span>
                        </td>
                      </tr>
                    );
                  })}
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
