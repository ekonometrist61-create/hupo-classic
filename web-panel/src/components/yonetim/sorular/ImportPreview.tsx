"use client";

import Badge from "@/components/ui/badge/Badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { useTranslations } from "next-intl";
import { useState } from "react";

import type { ConvertedRow, HeaderMapping } from "./csv";

const PREVIEW_LIMIT = 50;

interface ImportPreviewProps {
  mapping: HeaderMapping;
  delimiter: string;
  rows: ConvertedRow[];
}

const boxBase = "mb-3 rounded-lg border px-4 py-3 text-sm";

export default function ImportPreview({
  mapping,
  delimiter,
  rows,
}: ImportPreviewProps) {
  const t = useTranslations("yonetim.sorular.import");
  const [onlyErrors, setOnlyErrors] = useState(false);

  const invalid = rows.filter((r) => r.error !== null).length;
  const valid = rows.length - invalid;
  const shown = (onlyErrors ? rows.filter((r) => r.error) : rows).slice(
    0,
    PREVIEW_LIMIT
  );

  const delimiterName =
    delimiter === ";"
      ? t("delimiter.semicolon")
      : delimiter === "\t"
        ? t("delimiter.tab")
        : t("delimiter.comma");

  const headerClass =
    "px-3 py-3 text-start text-theme-xs font-medium text-gray-500 dark:text-gray-400";
  const cellClass = "px-3 py-2.5 text-theme-sm text-gray-700 dark:text-gray-300";

  return (
    <div>
      <p className="mb-3 text-theme-sm text-gray-500 dark:text-gray-400">
        {t("detectedDelimiter", { name: delimiterName })}
      </p>

      {mapping.missing.length > 0 && (
        <div
          role="alert"
          className={`${boxBase} border-error-200 bg-error-50 text-error-700 dark:border-error-500/30 dark:bg-error-500/10 dark:text-error-400`}
        >
          {t("missingColumns", { columns: mapping.missing.join(", ") })}
        </div>
      )}
      {mapping.unknown.length > 0 && (
        <div
          className={`${boxBase} border-warning-200 bg-warning-50 text-warning-700 dark:border-warning-500/30 dark:bg-warning-500/10 dark:text-orange-400`}
        >
          {t("unknownColumns", { columns: mapping.unknown.join(", ") })}
        </div>
      )}
      {mapping.duplicates.length > 0 && (
        <div
          className={`${boxBase} border-warning-200 bg-warning-50 text-warning-700 dark:border-warning-500/30 dark:bg-warning-500/10 dark:text-orange-400`}
        >
          {t("duplicateColumns", { columns: mapping.duplicates.join(", ") })}
        </div>
      )}

      {mapping.missing.length === 0 && (
        <>
          <div className="mb-4 flex flex-wrap items-center gap-3">
            <Badge color="light">{t("count.total", { count: rows.length })}</Badge>
            <Badge color="success">{t("count.valid", { count: valid })}</Badge>
            <Badge color={invalid > 0 ? "error" : "light"}>
              {t("count.invalid", { count: invalid })}
            </Badge>
            {invalid > 0 && (
              <label className="ms-auto flex items-center gap-2 text-sm text-gray-700 dark:text-gray-300">
                <input
                  type="checkbox"
                  checked={onlyErrors}
                  onChange={(e) => setOnlyErrors(e.target.checked)}
                  className="h-4 w-4 rounded border-gray-300 text-brand-500 dark:border-gray-700 dark:bg-gray-900"
                />
                {t("onlyErrors")}
              </label>
            )}
          </div>

          {rows.length === 0 ? (
            <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">
              {t("noRows")}
            </p>
          ) : (
            <>
              <div className="max-w-full overflow-x-auto">
                <Table>
                  <TableHeader className="border-b border-gray-100 dark:border-gray-800">
                    <TableRow>
                      <TableCell isHeader className={headerClass}>
                        {t("table.line")}
                      </TableCell>
                      <TableCell isHeader className={headerClass}>
                        {t("table.question")}
                      </TableCell>
                      <TableCell isHeader className={headerClass}>
                        {t("table.course")}
                      </TableCell>
                      <TableCell isHeader className={headerClass}>
                        {t("table.answer")}
                      </TableCell>
                      <TableCell isHeader className={headerClass}>
                        {t("table.status")}
                      </TableCell>
                    </TableRow>
                  </TableHeader>
                  <TableBody className="divide-y divide-gray-100 dark:divide-gray-800">
                    {shown.map((r) => (
                      <TableRow key={r.line}>
                        <TableCell className={cellClass}>{r.line}</TableCell>
                        <TableCell className={`${cellClass} max-w-xs`}>
                          <span className="line-clamp-2">
                            {r.question.soru_metni}
                          </span>
                        </TableCell>
                        <TableCell className={cellClass}>
                          {[r.question.ders, r.question.konu]
                            .filter(Boolean)
                            .join(" / ")}
                        </TableCell>
                        <TableCell className={cellClass}>
                          {r.question.dogru_sik}
                        </TableCell>
                        <TableCell className={cellClass}>
                          {r.error === null ? (
                            <Badge size="sm" color="success">
                              {t("table.ok")}
                            </Badge>
                          ) : (
                            <span className="text-error-600 dark:text-error-400">
                              {r.error}
                            </span>
                          )}
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>
              <p className="pt-3 text-theme-xs text-gray-500 dark:text-gray-400">
                {t("previewNote", {
                  shown: shown.length,
                  total: onlyErrors ? invalid : rows.length,
                })}
              </p>
            </>
          )}
        </>
      )}
    </div>
  );
}
