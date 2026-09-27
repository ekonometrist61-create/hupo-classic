"use client";

import { Link } from "@/i18n/navigation";
import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useMemo, useRef, useState } from "react";

import type { ImportResult } from "../types";
import {
  CHUNK_SIZE,
  chunk,
  convertRecords,
  emptyResult,
  errorsCsv,
  mapChunkErrors,
  mergeResults,
  parseCsv,
  templateCsv,
} from "./csv";
import ImportPreview from "./ImportPreview";
import ImportResultCard, { type FinalResult } from "./ImportResultCard";

function downloadCsv(filename: string, content: string) {
  const blob = new Blob([content], { type: "text/csv;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}

const cardClass =
  "mb-6 rounded-2xl border border-gray-200 bg-white p-4 sm:p-6 dark:border-gray-800 dark:bg-white/3";
const headingClass =
  "mb-3 text-base font-semibold text-gray-800 dark:text-white/90";
const outlineButton =
  "rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-50 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-white/5";
const checkboxClass =
  "mt-0.5 h-4 w-4 rounded border-gray-300 text-brand-500 focus:ring-brand-500/20 dark:border-gray-700 dark:bg-gray-900";

export default function BulkImport() {
  const t = useTranslations("yonetim.sorular.import");
  const fileInput = useRef<HTMLInputElement>(null);

  const [pasted, setPasted] = useState("");
  const [fileText, setFileText] = useState<string | null>(null);
  const [fileName, setFileName] = useState("");
  const [readError, setReadError] = useState<string | null>(null);
  const [onayla, setOnayla] = useState(false);
  const [hepsi, setHepsi] = useState(false);
  const [importing, setImporting] = useState(false);
  const [progress, setProgress] = useState<{ done: number; total: number } | null>(
    null
  );
  const [blockedMessage, setBlockedMessage] = useState<string | null>(null);
  const [result, setResult] = useState<FinalResult | null>(null);

  const text = fileText ?? pasted;
  const hasText = text.trim() !== "";

  const parsed = useMemo(() => (hasText ? parseCsv(text) : null), [text, hasText]);
  const rows = useMemo(
    () =>
      parsed && parsed.mapping.missing.length === 0
        ? convertRecords(parsed.records, parsed.mapping.columns)
        : [],
    [parsed]
  );
  const validRows = useMemo(() => rows.filter((r) => r.error === null), [rows]);
  const invalidCount = rows.length - validRows.length;
  const garbled = hasText && text.includes(String.fromCharCode(0xfffd));
  const canImport =
    !importing && parsed !== null && parsed.mapping.missing.length === 0;

  const onFile = async (file: File | undefined) => {
    if (!file) return;
    setReadError(null);
    setResult(null);
    setBlockedMessage(null);
    try {
      const content = await file.text(); // UTF-8
      setFileText(content);
      setFileName(file.name);
    } catch {
      setReadError(t("input.readError"));
    }
  };

  const clearInput = () => {
    setFileText(null);
    setFileName("");
    setPasted("");
    setResult(null);
    setBlockedMessage(null);
    setReadError(null);
    if (fileInput.current) fileInput.current.value = "";
  };

  const runImport = async () => {
    if (!parsed) return;
    setBlockedMessage(null);
    setResult(null);

    if (hepsi && invalidCount > 0) {
      setBlockedMessage(t("options.blocked", { count: invalidCount }));
      return;
    }
    if (validRows.length === 0) {
      setBlockedMessage(t("options.nothingToImport"));
      return;
    }

    setImporting(true);
    const validLines = validRows.map((r) => r.line);
    const chunks = chunk(validRows, CHUNK_SIZE);
    const supabase = createClient();

    let agg: ImportResult = emptyResult();
    const errors: { line: number; hata: string }[] = rows
      .filter((r) => r.error !== null)
      .map((r) => ({ line: r.line, hata: r.error as string }));
    let aborted: string | null = null;

    for (let i = 0; i < chunks.length; i++) {
      setProgress({ done: i, total: chunks.length });
      const { data, error } = await supabase.rpc("admin_import_questions", {
        p_rows: chunks[i].map((r) => r.question),
        p_onayla: onayla,
        p_hepsi_veya_hicbiri: hepsi,
      });
      if (error) {
        aborted = error.message;
        break;
      }
      const res = data as ImportResult;
      agg = mergeResults(agg, res);
      for (const e of mapChunkErrors(res.hatalar ?? [], validLines, i * CHUNK_SIZE)) {
        errors.push({ line: e.satir, hata: e.hata });
      }
    }

    setProgress(null);
    setImporting(false);
    errors.sort((a, b) => a.line - b.line);
    setResult({
      eklenen: agg.eklenen,
      tekrar: agg.tekrar,
      hatali: agg.hatali + invalidCount,
      errors,
      aborted,
    });
  };

  const downloadErrors = () => {
    if (!parsed || !result) return;
    const byLine = new Map(parsed.records.map((r) => [r.line, r.cells]));
    const out = result.errors.map((e) => ({
      cells: byLine.get(e.line) ?? [],
      error: e.hata,
    }));
    downloadCsv(
      "hatali-satirlar.csv",
      errorsCsv(parsed.headerCells, out, parsed.delimiter)
    );
  };

  return (
    <div>
      {/* 1. Şablon ve yardım */}
      <div className={cardClass}>
        <div className="mb-3 flex flex-wrap items-center justify-between gap-3">
          <h3 className="text-base font-semibold text-gray-800 dark:text-white/90">
            {t("help.title")}
          </h3>
          <div className="flex gap-2">
            <Link href="/yonetim/sorular" className={outlineButton}>
              {t("backToList")}
            </Link>
            <button
              type="button"
              onClick={() => downloadCsv("soru-sablonu.csv", templateCsv())}
              className="rounded-lg bg-brand-500 px-4 py-2.5 text-sm font-medium text-white shadow-theme-xs hover:bg-brand-600"
            >
              {t("help.download")}
            </button>
          </div>
        </div>
        <ul className="list-disc space-y-1.5 ps-5 text-theme-sm text-gray-600 dark:text-gray-400">
          <li>{t("help.columns")}</li>
          <li>{t("help.required")}</li>
          <li>{t("help.options")}</li>
          <li>{t("help.answer")}</li>
          <li>{t("help.steps")}</li>
          <li>{t("help.status")}</li>
          <li>{t("help.difficulty")}</li>
          <li>{t("help.encoding")}</li>
          <li>{t("help.duplicates")}</li>
        </ul>
      </div>

      {/* 2. Girdi */}
      <div className={cardClass}>
        <h3 className={headingClass}>{t("input.title")}</h3>
        <div className="mb-4 flex flex-wrap items-center gap-3">
          <input
            ref={fileInput}
            type="file"
            accept=".csv,.txt,text/csv,text/plain"
            disabled={importing}
            onChange={(e) => onFile(e.target.files?.[0])}
            className="block text-sm text-gray-700 file:me-3 file:rounded-lg file:border-0 file:bg-gray-100 file:px-4 file:py-2.5 file:text-sm file:font-medium file:text-gray-700 hover:file:bg-gray-200 dark:text-gray-300 dark:file:bg-white/10 dark:file:text-gray-300 dark:hover:file:bg-white/15"
          />
          {(fileText !== null || pasted !== "") && (
            <button
              type="button"
              disabled={importing}
              onClick={clearInput}
              className={outlineButton}
            >
              {t("input.clear")}
            </button>
          )}
        </div>

        {fileText !== null ? (
          <p className="text-theme-sm text-gray-600 dark:text-gray-400">
            {t("input.fileLoaded", { name: fileName })}
          </p>
        ) : (
          <>
            <label
              htmlFor="bulk-paste"
              className="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-400"
            >
              {t("input.pasteLabel")}
            </label>
            <textarea
              id="bulk-paste"
              rows={6}
              value={pasted}
              disabled={importing}
              onChange={(e) => {
                setPasted(e.target.value);
                setResult(null);
                setBlockedMessage(null);
              }}
              placeholder={t("input.pastePlaceholder")}
              className="w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 font-mono text-theme-xs text-gray-800 shadow-theme-xs placeholder:text-gray-400 focus:border-brand-300 focus:ring-3 focus:ring-brand-500/10 focus:outline-hidden dark:border-gray-700 dark:bg-gray-900 dark:text-white/90 dark:placeholder:text-white/30 dark:focus:border-brand-800"
            />
          </>
        )}

        {readError && (
          <p role="alert" className="mt-3 text-sm text-error-600 dark:text-error-400">
            {readError}
          </p>
        )}
        {garbled && (
          <div
            role="alert"
            className="mt-3 rounded-lg border border-warning-200 bg-warning-50 px-4 py-3 text-sm text-warning-700 dark:border-warning-500/30 dark:bg-warning-500/10 dark:text-orange-400"
          >
            {t("input.encodingWarning")}
          </div>
        )}
      </div>

      {/* 3. Önizleme */}
      {parsed && (
        <div className={cardClass}>
          <h3 className={headingClass}>{t("preview.title")}</h3>
          <ImportPreview
            mapping={parsed.mapping}
            delimiter={parsed.delimiter}
            rows={rows}
          />
        </div>
      )}

      {/* 4. Seçenekler ve içe aktarma */}
      {parsed && parsed.mapping.missing.length === 0 && !result && (
        <div className={cardClass}>
          <h3 className={headingClass}>{t("options.title")}</h3>
          <div className="mb-4 space-y-3">
            <label className="flex items-start gap-3 text-sm text-gray-700 dark:text-gray-300">
              <input
                type="checkbox"
                checked={onayla}
                disabled={importing}
                onChange={(e) => setOnayla(e.target.checked)}
                className={checkboxClass}
              />
              <span>
                <span className="font-medium">{t("options.approve")}</span>
                <span className="block text-theme-xs text-gray-500 dark:text-gray-400">
                  {t("options.approveHint")}
                </span>
              </span>
            </label>
            <label className="flex items-start gap-3 text-sm text-gray-700 dark:text-gray-300">
              <input
                type="checkbox"
                checked={hepsi}
                disabled={importing}
                onChange={(e) => setHepsi(e.target.checked)}
                className={checkboxClass}
              />
              <span>
                <span className="font-medium">{t("options.allOrNothing")}</span>
                <span className="block text-theme-xs text-gray-500 dark:text-gray-400">
                  {t("options.allOrNothingHint")}
                </span>
              </span>
            </label>
          </div>

          {blockedMessage && (
            <div
              role="alert"
              className="mb-4 rounded-lg border border-error-200 bg-error-50 px-4 py-3 text-sm text-error-700 dark:border-error-500/30 dark:bg-error-500/10 dark:text-error-400"
            >
              {blockedMessage}
            </div>
          )}

          <div className="flex flex-wrap items-center gap-3">
            <button
              type="button"
              disabled={!canImport || validRows.length === 0}
              onClick={runImport}
              className="rounded-lg bg-brand-500 px-5 py-2.5 text-sm font-medium text-white shadow-theme-xs hover:bg-brand-600 disabled:cursor-not-allowed disabled:opacity-50"
            >
              {importing
                ? t("options.importing")
                : t("options.import", { count: validRows.length })}
            </button>
            {progress && (
              <span className="text-theme-sm text-gray-500 dark:text-gray-400">
                {t("options.progress", {
                  done: progress.done,
                  total: progress.total,
                })}
              </span>
            )}
          </div>
        </div>
      )}

      {/* 5. Sonuç */}
      {result && (
        <div className={cardClass}>
          <h3 className={headingClass}>{t("result.title")}</h3>
          <ImportResultCard
            result={result}
            onDownloadErrors={downloadErrors}
            onReset={clearInput}
          />
        </div>
      )}
    </div>
  );
}
