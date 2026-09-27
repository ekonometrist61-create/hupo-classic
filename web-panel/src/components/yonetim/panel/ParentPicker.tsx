"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";
import type { AdminUser, Paged } from "../types";
import { inputClass, labelClass } from "./styles";
import useDebounced from "./useDebounced";

interface ParentPickerProps {
  selected: AdminUser | null;
  onSelect: (user: AdminUser | null) => void;
}

/** Veli arama kutusu + sonuç listesi (admin_list_users('veli', q, 10, 0)). */
export default function ParentPicker({ selected, onSelect }: ParentPickerProps) {
  const t = useTranslations("yonetim.panel.picker");
  const [query, setQuery] = useState("");
  const debounced = useDebounced(query);
  const [results, setResults] = useState<AdminUser[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (selected) return;
    let cancelled = false;
    const run = async () => {
      setLoading(true);
      setError(null);
      const { data, error: err } = await createClient().rpc("admin_list_users", {
        p_rol: "veli",
        p_arama: debounced.trim() || null,
        p_limit: 10,
        p_offset: 0,
      });
      if (cancelled) return;
      if (err) {
        setError(err.message);
        setResults([]);
      } else {
        setResults((data as Paged<AdminUser>).satirlar);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [debounced, selected]);

  if (selected) {
    return (
      <div>
        <span className={labelClass}>{t("label")}</span>
        <div className="flex items-center justify-between gap-3 rounded-lg border border-brand-300 bg-brand-25 px-4 py-2.5 dark:border-brand-800 dark:bg-brand-500/10">
          <div className="min-w-0">
            <p className="truncate text-sm font-medium text-gray-800 dark:text-white/90">
              {selected.ad ?? "-"}
            </p>
            <p className="truncate text-theme-xs text-gray-500 dark:text-gray-400">
              {selected.email}
            </p>
          </div>
          <button
            type="button"
            className="text-theme-sm font-medium text-brand-500 dark:text-brand-400"
            onClick={() => onSelect(null)}
          >
            {t("change")}
          </button>
        </div>
      </div>
    );
  }

  return (
    <div>
      <label className={labelClass} htmlFor="parent-search">
        {t("label")}
      </label>
      <input
        id="parent-search"
        type="search"
        className={inputClass}
        placeholder={t("placeholder")}
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        autoComplete="off"
      />
      <div className="mt-2 max-h-48 overflow-y-auto rounded-lg border border-gray-200 dark:border-gray-800">
        {loading && (
          <p className="px-4 py-3 text-theme-sm text-gray-500 dark:text-gray-400">
            {t("loading")}
          </p>
        )}
        {error && (
          <p className="px-4 py-3 text-theme-sm text-error-600 dark:text-error-500">
            {error}
          </p>
        )}
        {!loading && !error && results.length === 0 && (
          <p className="px-4 py-3 text-theme-sm text-gray-500 dark:text-gray-400">
            {t("none")}
          </p>
        )}
        {results.map((u) => (
          <button
            key={u.id}
            type="button"
            onClick={() => onSelect(u)}
            className="block w-full border-b border-gray-100 px-4 py-2.5 text-start last:border-b-0 hover:bg-gray-50 dark:border-gray-800 dark:hover:bg-white/5"
          >
            <span className="block text-sm font-medium text-gray-800 dark:text-white/90">
              {u.ad ?? "-"}
            </span>
            <span className="block text-theme-xs text-gray-500 dark:text-gray-400">
              {u.email}
            </span>
          </button>
        ))}
      </div>
    </div>
  );
}
