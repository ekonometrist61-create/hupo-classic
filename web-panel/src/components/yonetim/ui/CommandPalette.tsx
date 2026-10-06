"use client";

import { useCurrentRole } from "@/hooks/useCurrentRole";
import { useRouter } from "@/i18n/navigation";
import { navForRole } from "@/layout/adminNav";
import { DEMO_MODE } from "@/lib/demo-mode";
import { useTranslations } from "next-intl";
import { useEffect, useMemo, useRef, useState } from "react";

/** Ctrl/⌘+K ile açılan ekran arama paleti. Yalnızca gerçek (path'i olan) ekranlar listelenir. */
export default function CommandPalette() {
  const t = useTranslations("yonetim.shell");
  const router = useRouter();
  const fetchedRole = useCurrentRole();
  const role = DEMO_MODE ? "admin" : fetchedRole;
  const dialogRef = useRef<HTMLDialogElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const [query, setQuery] = useState("");

  const entries = useMemo(
    () =>
      navForRole(role)
        .flatMap((g) => g.items)
        .filter((i) => i.path)
        .map((i) => ({ ...i, label: t(`nav.${i.key}`) })),
    [role, t],
  );

  const q = query.toLocaleLowerCase("tr");
  const results = entries.filter((e) => e.label.toLocaleLowerCase("tr").includes(q));

  const open = () => {
    setQuery("");
    if (!dialogRef.current?.open) dialogRef.current?.showModal();
    setTimeout(() => inputRef.current?.focus(), 30);
  };
  const close = () => dialogRef.current?.close();

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === "k") {
        e.preventDefault();
        open();
      }
    };
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, []);

  const go = (path: string) => {
    close();
    router.push(path);
  };

  return (
    <>
      <button
        type="button"
        onClick={open}
        className="hidden h-11 w-77.5 items-center justify-between rounded-lg border border-gray-200 bg-gray-50 px-4 text-theme-xs text-gray-500 transition hover:bg-brand-25 focus-visible:outline-3 focus-visible:outline-offset-2 focus-visible:outline-blue-light-400 xl:flex dark:border-gray-800 dark:bg-white/3 dark:text-gray-400"
      >
        <span>⌕ &nbsp; {t("command.open")}</span>
        <span className="rounded border border-gray-200 px-1.5 text-[10px] dark:border-gray-700">
          Ctrl K
        </span>
      </button>

      <dialog
        ref={dialogRef}
        aria-label={t("command.title")}
        onClick={(e) => e.target === dialogRef.current && close()}
        className="m-auto mt-[12vh] w-[90%] max-w-lg rounded-2xl border border-gray-200 bg-white p-5 text-gray-800 shadow-theme-xl backdrop:bg-navy/40 backdrop:backdrop-blur-sm dark:border-gray-800 dark:bg-gray-900 dark:text-white/90"
      >
        <div className="mb-3 flex items-center justify-between">
          <h2 className="text-base font-semibold">{t("command.title")}</h2>
          <button
            type="button"
            onClick={close}
            aria-label={t("command.close")}
            className="rounded-lg px-2 py-1 text-gray-500 hover:bg-gray-100 dark:hover:bg-white/5"
          >
            ✕
          </button>
        </div>
        <input
          ref={inputRef}
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter" && results[0]?.path) go(results[0].path);
          }}
          aria-label={t("command.placeholder")}
          placeholder={t("command.placeholder")}
          className="h-11 w-full rounded-lg border border-gray-300 bg-transparent px-4 text-sm focus:border-brand-300 focus:ring-3 focus:ring-brand-500/10 focus:outline-hidden dark:border-gray-700"
        />
        <ul className="mt-3 max-h-80 overflow-y-auto">
          {results.map((e) => (
            <li key={e.key}>
              <button
                type="button"
                onClick={() => e.path && go(e.path)}
                className="flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-start text-theme-sm hover:bg-brand-25 dark:hover:bg-white/5"
              >
                <span className="size-5 text-brand-500 [&>svg]:size-5">{e.icon}</span>
                {e.label}
              </button>
            </li>
          ))}
          {results.length === 0 && (
            <li className="px-3 py-6 text-center text-theme-sm text-gray-500">
              {t("command.empty")}
            </li>
          )}
        </ul>
      </dialog>
    </>
  );
}
