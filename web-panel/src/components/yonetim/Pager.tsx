"use client";

interface PagerProps {
  /** 0'dan başlar */
  page: number;
  pageSize: number;
  total: number;
  onPage: (page: number) => void;
  labels: { prev: string; next: string; summary: string };
}

/** Basit sayfalama çubuğu. labels.summary örn. "26–50 / 312" olarak dışarıdan üretilir. */
export default function Pager({ page, pageSize, total, onPage, labels }: PagerProps) {
  const lastPage = Math.max(0, Math.ceil(total / pageSize) - 1);
  const buttonClass =
    "rounded-lg border border-gray-300 px-3 py-1.5 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-40 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-white/5";

  return (
    <div className="flex flex-wrap items-center justify-between gap-3 pt-4">
      <span className="text-theme-sm text-gray-500 dark:text-gray-400">
        {labels.summary}
      </span>
      <div className="flex gap-2">
        <button
          type="button"
          className={buttonClass}
          disabled={page <= 0}
          onClick={() => onPage(page - 1)}
        >
          {labels.prev}
        </button>
        <button
          type="button"
          className={buttonClass}
          disabled={page >= lastPage}
          onClick={() => onPage(page + 1)}
        >
          {labels.next}
        </button>
      </div>
    </div>
  );
}
