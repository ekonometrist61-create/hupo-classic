"use client";

import Badge from "@/components/ui/badge/Badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { formatDate } from "@/utils/format";
import { useTranslations } from "next-intl";

import type { AdminQuestion, QuestionStatus } from "../types";

interface QuestionsTableProps {
  rows: AdminQuestion[];
  selected: Set<string>;
  disabled: boolean;
  onToggle: (id: string) => void;
  onToggleAll: () => void;
  onEdit: (question: AdminQuestion) => void;
}

const STATUS_COLOR: Record<QuestionStatus, "warning" | "success" | "error"> = {
  beklemede: "warning",
  onaylandi: "success",
  reddedildi: "error",
};

const DIFFICULTY_COLOR = { 1: "info", 2: "primary", 3: "dark" } as const;

export default function QuestionsTable({
  rows,
  selected,
  disabled,
  onToggle,
  onToggleAll,
  onEdit,
}: QuestionsTableProps) {
  const t = useTranslations("yonetim.sorular");

  const statusLabel: Record<QuestionStatus, string> = {
    beklemede: t("status.beklemede"),
    onaylandi: t("status.onaylandi"),
    reddedildi: t("status.reddedildi"),
  };
  const difficultyLabel = {
    1: t("difficulty.1"),
    2: t("difficulty.2"),
    3: t("difficulty.3"),
  } as const;

  const allSelected = rows.length > 0 && rows.every((r) => selected.has(r.id));
  const headerClass =
    "px-3 py-3 text-start text-theme-xs font-medium text-gray-500 dark:text-gray-400";
  const cellClass = "px-3 py-3 text-theme-sm text-gray-700 dark:text-gray-300";
  const checkboxClass =
    "h-4 w-4 rounded border-gray-300 text-brand-500 focus:ring-brand-500/20 dark:border-gray-700 dark:bg-gray-900";

  return (
    <div className="max-w-full overflow-x-auto">
      <Table>
        <TableHeader className="border-b border-gray-100 dark:border-gray-800">
          <TableRow>
            <TableCell isHeader className={headerClass}>
              <input
                type="checkbox"
                className={checkboxClass}
                checked={allSelected}
                disabled={disabled}
                onChange={onToggleAll}
                aria-label={t("table.selectAll")}
              />
            </TableCell>
            <TableCell isHeader className={headerClass}>
              {t("table.question")}
            </TableCell>
            <TableCell isHeader className={headerClass}>
              {t("table.course")}
            </TableCell>
            <TableCell isHeader className={headerClass}>
              {t("table.difficulty")}
            </TableCell>
            <TableCell isHeader className={headerClass}>
              {t("table.status")}
            </TableCell>
            <TableCell isHeader className={headerClass}>
              {t("table.created")}
            </TableCell>
            <TableCell isHeader className={headerClass}>
              {t("table.actions")}
            </TableCell>
          </TableRow>
        </TableHeader>
        <TableBody className="divide-y divide-gray-100 dark:divide-gray-800">
          {rows.map((q) => (
            <TableRow
              key={q.id}
              className={
                selected.has(q.id) ? "bg-brand-25 dark:bg-brand-500/5" : ""
              }
            >
              <TableCell className={cellClass}>
                <input
                  type="checkbox"
                  className={checkboxClass}
                  checked={selected.has(q.id)}
                  disabled={disabled}
                  onChange={() => onToggle(q.id)}
                  aria-label={t("table.select")}
                />
              </TableCell>
              <TableCell className={`${cellClass} max-w-md`}>
                <span className="line-clamp-2" title={q.soru_metni}>
                  {q.soru_metni}
                </span>
              </TableCell>
              <TableCell className={cellClass}>
                <div className="font-medium text-gray-800 dark:text-white/90">
                  {q.ders}
                </div>
                <div className="text-theme-xs text-gray-500 dark:text-gray-400">
                  {q.alt_konu ? `${q.konu} / ${q.alt_konu}` : q.konu}
                </div>
              </TableCell>
              <TableCell className={cellClass}>
                <Badge size="sm" color={DIFFICULTY_COLOR[q.zorluk]}>
                  {difficultyLabel[q.zorluk]}
                </Badge>
              </TableCell>
              <TableCell className={cellClass}>
                <Badge size="sm" color={STATUS_COLOR[q.onay_durumu]}>
                  {statusLabel[q.onay_durumu]}
                </Badge>
              </TableCell>
              <TableCell className={`${cellClass} whitespace-nowrap`}>
                {formatDate(new Date(q.created_at))}
              </TableCell>
              <TableCell className={cellClass}>
                <button
                  type="button"
                  disabled={disabled}
                  onClick={() => onEdit(q)}
                  className="text-theme-sm font-medium text-brand-500 hover:text-brand-600 disabled:opacity-50 dark:text-brand-400"
                >
                  {t("table.edit")}
                </button>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
