"use client";

import { useTranslations } from "next-intl";

import { formatDateTime } from "@/utils/format";
import Drawer from "../ui/Drawer";
import RpcBoundary from "../ui/RpcBoundary";
import { useAdminRpc } from "../useAdminRpc";

interface Revision {
  id: string;
  changed_at: string;
  old_data: Record<string, unknown> | null;
  degisen_alanlar: string[] | Record<string, unknown> | null;
  duzenleyen: string | null;
}

function fields(v: Revision["degisen_alanlar"]): string {
  if (!v) return "—";
  if (Array.isArray(v)) return v.join(", ") || "—";
  return Object.keys(v).join(", ") || "—";
}

/** Soru revizyon geçmişi (admin_question_history): kim, ne zaman, hangi alanları değiştirdi. */
export default function QuestionHistoryDrawer({
  questionId,
  onClose,
}: {
  questionId: string | null;
  onClose: () => void;
}) {
  const t = useTranslations("yonetim.sorular.history");
  const state = useAdminRpc<Revision[]>(
    "admin_question_history",
    { p_id: questionId },
    { enabled: questionId !== null, demo: [] },
  );

  return (
    <Drawer open={questionId !== null} onClose={onClose} title={t("title")} closeLabel={t("close")}>
      <p className="mb-4 text-theme-xs text-gray-500 dark:text-gray-400">{t("note")}</p>
      <RpcBoundary state={state}>
        {(rows) =>
          rows.length === 0 ? (
            <p className="py-8 text-center text-sm text-gray-500 dark:text-gray-400">{t("empty")}</p>
          ) : (
            <ol className="ms-2 border-s-2 border-brand-100 ps-5 dark:border-brand-500/30">
              {rows.map((r) => (
                <li key={r.id} className="relative pb-5 text-theme-sm">
                  <span className="absolute -inset-s-6.75 top-1.5 size-2 rounded-full bg-brand-500" aria-hidden />
                  <b className="font-medium">{t("changed", { fields: fields(r.degisen_alanlar) })}</b>
                  <br />
                  <span className="text-theme-xs text-gray-500 dark:text-gray-400">
                    {r.duzenleyen ?? "—"} · {formatDateTime(r.changed_at)}
                  </span>
                </li>
              ))}
            </ol>
          )
        }
      </RpcBoundary>
    </Drawer>
  );
}
