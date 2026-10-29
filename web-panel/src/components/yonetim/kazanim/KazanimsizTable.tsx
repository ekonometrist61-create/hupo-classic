"use client";

import { useTranslations } from "next-intl";

import { cardClass } from "../panel/styles";
import { masaustuTablo, mobilKart } from "../ui/responsive";
import type { QuestionStatus } from "../types";

/** admin_kazanimsiz_sorular() satır şekli. */
export interface KazanimsizSoru {
  id: string;
  ders: string;
  sinif: number;
  konu: string;
  alt_konu: string | null;
  soru_metni: string;
  zorluk: number;
  onay_durumu: QuestionStatus;
}

interface KazanimsizTableProps {
  rows: KazanimsizSoru[];
  selected: Set<string>;
  disabled: boolean;
  onToggle: (id: string) => void;
  onToggleAll: () => void;
}

const checkboxWrap = "inline-flex min-h-11 min-w-11 items-center justify-center";
const checkboxClass =
  "h-4 w-4 rounded border-gray-300 text-brand-500 focus:ring-brand-500/20 dark:border-gray-700 dark:bg-gray-900";
const headerClass =
  "px-3 py-3 text-start text-theme-xs font-medium text-gray-500 dark:text-gray-400";
const cellClass = "px-3 py-3 text-theme-sm text-gray-700 dark:text-gray-300";

/** Kazanımsız sorular: seçim ve okuma. Düzenleme bu görünümde yapılmaz (liste satırı eksik alan taşır). */
export default function KazanimsizTable({
  rows,
  selected,
  disabled,
  onToggle,
  onToggleAll,
}: KazanimsizTableProps) {
  const t = useTranslations("yonetim.sorular");
  const k = useTranslations("yonetim.sorular.kazanim.kazanimsizTable");

  const allSelected = rows.length > 0 && rows.every((r) => selected.has(r.id));
  const difficultyLabel = {
    1: t("difficulty.1"),
    2: t("difficulty.2"),
    3: t("difficulty.3"),
  } as const;
  const statusLabel: Record<QuestionStatus, string> = {
    beklemede: t("status.beklemede"),
    onaylandi: t("status.onaylandi"),
    reddedildi: t("status.reddedildi"),
  };

  return (
    <>
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
                    {q.ders} · {q.sinif}. {k("sinifSuffix")} · {q.alt_konu ? `${q.konu} / ${q.alt_konu}` : q.konu}
                  </p>
                  <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">
                    {difficultyLabel[q.zorluk as 1 | 2 | 3]} · {statusLabel[q.onay_durumu]}
                  </p>
                </div>
              </div>
            </li>
          ))}
        </ul>
      </div>

      <div className={masaustuTablo}>
        <table className="w-full min-w-160 text-start">
          <thead className="border-b border-gray-100 dark:border-gray-800">
            <tr>
              <th scope="col" className={headerClass}>
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
              </th>
              <th scope="col" className={headerClass}>{t("table.question")}</th>
              <th scope="col" className={headerClass}>{k("ders")}</th>
              <th scope="col" className={headerClass}>{k("sinif")}</th>
              <th scope="col" className={headerClass}>{k("konu")}</th>
              <th scope="col" className={headerClass}>{t("table.difficulty")}</th>
              <th scope="col" className={headerClass}>{t("table.status")}</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
            {rows.map((q) => (
              <tr
                key={q.id}
                className={selected.has(q.id) ? "bg-brand-25 dark:bg-brand-500/5" : ""}
              >
                <td className={cellClass}>
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
                </td>
                <td className={`${cellClass} max-w-md`}>
                  <span className="line-clamp-2" title={q.soru_metni}>{q.soru_metni}</span>
                </td>
                <td className={cellClass}>{q.ders}</td>
                <td className={cellClass}>{q.sinif}</td>
                <td className={cellClass}>{q.alt_konu ? `${q.konu} / ${q.alt_konu}` : q.konu}</td>
                <td className={cellClass}>{difficultyLabel[q.zorluk as 1 | 2 | 3]}</td>
                <td className={cellClass}>{statusLabel[q.onay_durumu]}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}
