"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import { formatDateTime } from "@/utils/format";
import Pager from "../Pager";
import { cardClass, inputClass, tdClass, thClass } from "../panel/styles";
import RpcBoundary from "../ui/RpcBoundary";
import { useAdminRpc } from "../useAdminRpc";
import { DEMO_AUDIT, DEMO_TEAM } from "./demoData";
import type { AuditRow, TeamMember } from "./types";

const PAGE = 15;

/** Rol matrisi: planlanan model (henüz uygulanmaz). Satır → [yönetici, pazarlama, editör, finans, destek, analist]. */
const MATRIX: [string, string[]][] = [
  ["crm", ["full", "limited", "none", "billing", "limited", "bulk"]],
  ["campaignDraft", ["yes", "yes", "none", "none", "none", "none"]],
  ["campaignSend", ["yes", "approved", "none", "none", "none", "none"]],
  ["contentEdit", ["yes", "web", "yes", "none", "none", "none"]],
  ["contentPublish", ["yes", "none", "approved", "none", "none", "none"]],
  ["payments", ["yes", "none", "none", "approved", "view", "bulk"]],
  ["export", ["reason", "reason", "none", "limited", "none", "anon"]],
  ["roles", ["yes", "none", "none", "none", "none", "none"]],
];
const ROLES = ["admin", "marketing", "editor", "finance", "support", "analyst"];

export default function TeamView() {
  const t = useTranslations("yonetim.merkez.team");
  const team = useAdminRpc<TeamMember[]>("admin_ekip_listele", undefined, { demo: DEMO_TEAM });

  const [filter, setFilter] = useState("");
  const [page, setPage] = useState(0);
  const audit = useAdminRpc<{ toplam: number; satirlar: AuditRow[] }>(
    "admin_audit_listele",
    { p_islem: filter || null, p_limit: PAGE, p_offset: page * PAGE },
    { demo: DEMO_AUDIT },
  );

  return (
    <div className="space-y-6">
      <section className={`${cardClass} p-5 sm:p-6`}>
        <h2 className="text-lg font-semibold text-navy dark:text-white/90">{t("members")}</h2>
        <p className="mb-3 text-theme-xs text-gray-500 dark:text-gray-400">{t("membersDesc")}</p>
        <RpcBoundary state={team}>
          {(rows) => (
            <div className="overflow-x-auto">
              <table className="min-w-full">
                <thead>
                  <tr>
                    <th className={thClass}>{t("cols.name")}</th>
                    <th className={thClass}>{t("cols.email")}</th>
                    <th className={thClass}>{t("cols.role")}</th>
                    <th className={thClass}>{t("cols.last")}</th>
                    <th className={thClass}>{t("cols.actions30")}</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                  {rows.map((m) => (
                    <tr key={m.id}>
                      <td className={`${tdClass} font-medium text-gray-800 dark:text-white/90`}>{m.ad ?? "—"}</td>
                      <td className={tdClass}>{m.email ?? "—"}</td>
                      <td className={tdClass}>
                        <Badge size="sm" color={m.rol === "admin" ? "warning" : "success"}>{t(`roles.${m.rol}`)}</Badge>
                      </td>
                      <td className={`${tdClass} whitespace-nowrap`}>{formatDateTime(m.son_islem)}</td>
                      <td className={tdClass}>{m.islem_30_gun}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </RpcBoundary>
        <p className="mt-3 text-theme-xs text-gray-500">{t("roleNote")}</p>
      </section>

      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-3 flex flex-wrap items-center justify-between gap-2">
          <h2 className="text-lg font-semibold text-navy dark:text-white/90">{t("matrix.title")}</h2>
          <Badge size="sm" color="info">{t("matrix.planned")}</Badge>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full">
            <thead>
              <tr>
                <th className={thClass}>{t("matrix.permission")}</th>
                {ROLES.map((r) => <th key={r} className={thClass}>{t(`matrix.roles.${r}`)}</th>)}
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
              {MATRIX.map(([perm, cells]) => (
                <tr key={perm}>
                  <td className={`${tdClass} font-medium`}>{t(`matrix.perms.${perm}`)}</td>
                  {cells.map((c, i) => (
                    <td key={i} className={`${tdClass} text-gray-600`}>{c === "none" ? "—" : t(`matrix.cells.${c}`)}</td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <p className="mt-3 text-theme-xs text-gray-500">{t("matrix.note")}</p>
      </section>

      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-3 flex flex-wrap items-end justify-between gap-3">
          <div>
            <h2 className="text-lg font-semibold text-navy dark:text-white/90">{t("audit.title")}</h2>
            <p className="text-theme-xs text-gray-500">{t("audit.desc")}</p>
          </div>
          <input
            className={`${inputClass} w-64!`}
            placeholder={t("audit.filter")}
            aria-label={t("audit.filter")}
            value={filter}
            onChange={(e) => {
              setFilter(e.target.value.trim());
              setPage(0);
            }}
          />
        </div>
        <RpcBoundary state={audit}>
          {(a) => (
            <>
              {a.satirlar.length === 0 ? (
                <p className="py-8 text-center text-sm text-gray-500">{t("audit.empty")}</p>
              ) : (
                <div className="overflow-x-auto">
                  <table className="min-w-full">
                    <thead>
                      <tr>
                        <th className={thClass}>{t("audit.time")}</th>
                        <th className={thClass}>{t("audit.actor")}</th>
                        <th className={thClass}>{t("audit.action")}</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                      {a.satirlar.map((r) => (
                        <tr key={r.id}>
                          <td className={`${tdClass} whitespace-nowrap`}>{formatDateTime(r.zaman)}</td>
                          <td className={tdClass}>{r.admin_ad ?? "—"}</td>
                          <td className={tdClass}>
                            <code className="rounded bg-gray-100 px-1.5 py-0.5 text-theme-xs dark:bg-white/5">{r.islem}</code>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
              {a.toplam > 0 && (
                <Pager
                  page={page}
                  pageSize={PAGE}
                  total={a.toplam}
                  onPage={setPage}
                  labels={{
                    prev: t("audit.prev"),
                    next: t("audit.next"),
                    summary: `${page * PAGE + 1}–${Math.min(a.toplam, page * PAGE + a.satirlar.length)} / ${a.toplam}`,
                  }}
                />
              )}
            </>
          )}
        </RpcBoundary>
      </section>
    </div>
  );
}
