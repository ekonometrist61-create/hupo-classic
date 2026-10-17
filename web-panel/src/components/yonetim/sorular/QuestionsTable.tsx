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

import { cardClass } from "../panel/styles";
import { dokunmaHedefi, masaustuTablo, mobilKart, yapiskanBaslik, yapiskanHucre } from "../ui/responsive";
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

/** Onay kutusu: dokunma hedefi 44 px olsun diye etrafı sarılır (R2). */
const checkboxWrap = "inline-flex min-h-11 min-w-11 items-center justify-center";
const checkboxClass =
  "h-4 w-4 rounded border-gray-300 text-brand-500 focus:ring-brand-500/20 dark:border-gray-700 dark:bg-gray-900";

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

  return (
    <>
      {/* 768 px altı: kart görünümü. Sorular tek tek seçilip düzenlenir; tüm sayfa seçimi üstte. */}
      <div className={mobilKart}>
        <label className="flex min-h-11 items-center gap-2 text-theme-sm font-medium text-gray-700 dark:text-gray-300">
          <span className={checkboxWrap}>
            <input
              type="checkbox"
              className={checkboxClass}
              checked={allSelected}
              disabled={disabled}
              onChange={onToggleAll}
              aria-label={t("table.selectAll")}
            />
          </span>
          {t("table.selectAll")}
        </label>
        <ul className="space-y-3">
          {rows.map((q) => (
            <li
              key={q.id}
              className={`${cardClass} p-4 ${selected.has(q.id) ? "bg-brand-25 dark:bg-brand-500/5" : ""}`}
            >
              <div className="flex items-start gap-2">
                <span className={`${checkboxWrap} -ms-2 -mt-2 shrink-0`}>
                  <input
                    type="checkbox"
                    className={checkboxClass}
                    checked={selected.has(q.id)}
                    disabled={disabled}
                    onChange={() => onToggle(q.id)}
                    aria-label={t("table.select")}
                  />
                </span>
                <div className="min-w-0 flex-1">
                  <p className="line-clamp-3 text-theme-sm wrap-break-word text-gray-800 dark:text-white/90">
                    {q.soru_metni}
                  </p>
                  <p className="mt-1 text-theme-xs wrap-break-word text-gray-500 dark:text-gray-400">
                    {q.ders}
                    {" · "}
                    {q.alt_konu ? `${q.konu} / ${q.alt_konu}` : q.konu}
                  </p>
                  <div className="mt-2 flex flex-wrap items-center gap-2">
                    <Badge size="sm" color={DIFFICULTY_COLOR[q.zorluk]}>
                      {difficultyLabel[q.zorluk]}
                    </Badge>
                    <Badge size="sm" color={STATUS_COLOR[q.onay_durumu]}>
                      {statusLabel[q.onay_durumu]}
                    </Badge>
                    <span className="text-theme-xs text-gray-500 dark:text-gray-400">
                      {formatDate(new Date(q.created_at))}
                    </span>
                  </div>
                </div>
              </div>
              <div className="mt-2 flex justify-end">
                <button
                  type="button"
                  disabled={disabled}
                  onClick={() => onEdit(q)}
                  className={`${dokunmaHedefi} px-3 text-theme-sm font-medium text-brand-500 hover:text-brand-600 disabled:opacity-50 dark:text-brand-400`}
                >
                  {t("table.edit")}
                </button>
              </div>
            </li>
          ))}
        </ul>
      </div>

      {/* 768 px ve üzeri: tablo; kendi kapsayıcısında kayar, ilk sütun (onay kutusu) sabit. */}
      <div className={masaustuTablo}>
        <Table>
          <TableHeader className="border-b border-gray-100 dark:border-gray-800">
            <TableRow>
              <TableCell isHeader className={`${headerClass} ${yapiskanBaslik}`}>
                <span className={checkboxWrap}>
                  <input
                    type="checkbox"
                    className={checkboxClass}
                    checked={allSelected}
                    disabled={disabled}
                    onChange={onToggleAll}
                    aria-label={t("table.selectAll")}
                  />
                </span>
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
                <TableCell className={`${cellClass} ${yapiskanHucre}`}>
                  <span className={checkboxWrap}>
                    <input
                      type="checkbox"
                      className={checkboxClass}
                      checked={selected.has(q.id)}
                      disabled={disabled}
                      onChange={() => onToggle(q.id)}
                      aria-label={t("table.select")}
                    />
                  </span>
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
                    className={`${dokunmaHedefi} text-theme-sm font-medium text-brand-500 hover:text-brand-600 disabled:opacity-50 dark:text-brand-400`}
                  >
                    {t("table.edit")}
                  </button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </>
  );
}
