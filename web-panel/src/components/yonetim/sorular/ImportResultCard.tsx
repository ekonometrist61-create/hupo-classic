"use client";

import { useTranslations } from "next-intl";

export interface FinalError {
  line: number;
  hata: string;
}

export interface FinalResult {
  eklenen: number;
  tekrar: number;
  hatali: number;
  errors: FinalError[];
  /** Ağ/RPC hatası nedeniyle yarıda kesildiyse mesaj. */
  aborted: string | null;
}

interface ImportResultCardProps {
  result: FinalResult;
  onDownloadErrors: () => void;
  onReset: () => void;
}

export default function ImportResultCard({
  result,
  onDownloadErrors,
  onReset,
}: ImportResultCardProps) {
  const t = useTranslations("yonetim.sorular.import");

  const stat = (label: string, value: number, valueClass: string) => (
    <div className="rounded-xl border border-gray-200 px-4 py-3 dark:border-gray-800">
      <div className="text-theme-xs text-gray-500 dark:text-gray-400">
        {label}
      </div>
      <div className={`text-title-sm font-semibold ${valueClass}`}>{value}</div>
    </div>
  );

  return (
    <div>
      {result.aborted && (
        <div
          role="alert"
          className="mb-4 rounded-lg border border-error-200 bg-error-50 px-4 py-3 text-sm text-error-700 dark:border-error-500/30 dark:bg-error-500/10 dark:text-error-400"
        >
          {t("result.aborted", { message: result.aborted })}
        </div>
      )}
      <div className="mb-4 grid gap-3 sm:grid-cols-3">
        {stat(
          t("result.added"),
          result.eklenen,
          "text-success-600 dark:text-success-500"
        )}
        {stat(
          t("result.duplicate"),
          result.tekrar,
          "text-gray-800 dark:text-white/90"
        )}
        {stat(
          t("result.failed"),
          result.hatali,
          result.hatali > 0
            ? "text-error-600 dark:text-error-400"
            : "text-gray-800 dark:text-white/90"
        )}
      </div>
      <p className="mb-4 text-theme-sm text-gray-500 dark:text-gray-400">
        {t("result.duplicateHint")}
      </p>

      {result.errors.length > 0 && (
        <>
          <h4 className="mb-2 text-sm font-semibold text-gray-800 dark:text-white/90">
            {t("result.errorList")}
          </h4>
          <ul className="custom-scrollbar mb-4 max-h-64 overflow-y-auto rounded-lg border border-gray-200 text-sm dark:border-gray-800">
            {result.errors.map((e, i) => (
              <li
                key={`${e.line}-${i}`}
                className="flex gap-3 border-b border-gray-100 px-4 py-2 last:border-b-0 dark:border-gray-800"
              >
                <span className="w-20 shrink-0 font-medium text-gray-700 dark:text-gray-300">
                  {t("result.line", { line: e.line })}
                </span>
                <span className="text-error-600 dark:text-error-400">
                  {e.hata}
                </span>
              </li>
            ))}
          </ul>
        </>
      )}

      <div className="flex flex-wrap gap-3">
        {result.errors.length > 0 && (
          <button
            type="button"
            onClick={onDownloadErrors}
            className="rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-white/5"
          >
            {t("result.downloadErrors")}
          </button>
        )}
        <button
          type="button"
          onClick={onReset}
          className="rounded-lg bg-brand-500 px-4 py-2.5 text-sm font-medium text-white shadow-theme-xs hover:bg-brand-600"
        >
          {t("result.again")}
        </button>
      </div>
    </div>
  );
}
