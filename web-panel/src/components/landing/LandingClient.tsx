"use client";

import { useTranslations } from "next-intl";
import Link from "next/link";
import { useEffect, useId, useState } from "react";

import { IconChevronDown, IconClose, IconMenu } from "./Icons";

const NAV_ITEMS = [
  { href: "#demo", key: "demo" },
  { href: "#app-screens", key: "appScreens" },
  { href: "#characters", key: "characters" },
  { href: "#how-it-works", key: "how" },
  { href: "#why-parents", key: "parents" },
  { href: "#pricing", key: "pricing" },
  { href: "#faq", key: "faq" },
] as const;

export function MobileMenu() {
  const t = useTranslations("landing.nav");
  const [open, setOpen] = useState(false);
  const panelId = useId();

  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") setOpen(false);
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [open]);

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        aria-expanded={open}
        aria-controls={panelId}
        aria-label={open ? t("close") : t("open")}
        className="inline-flex h-11 w-11 items-center justify-center rounded-xl text-navy hover:bg-cream-dark focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 md:hidden dark:text-gray-100 dark:hover:bg-gray-800"
      >
        {open ? <IconClose className="h-6 w-6" /> : <IconMenu className="h-6 w-6" />}
      </button>
      {open && (
        <div
          id={panelId}
          className="absolute inset-x-0 top-full z-40 border-b border-cream-dark bg-cream p-4 shadow-lg md:hidden dark:border-gray-700 dark:bg-gray-900"
        >
          <nav aria-label={t("label")} className="flex flex-col">
            {NAV_ITEMS.map((item) => (
              <a
                key={item.key}
                href={item.href}
                onClick={() => setOpen(false)}
                className="flex min-h-11 items-center rounded-lg px-3 text-base font-semibold text-navy hover:bg-cream-dark dark:text-gray-100 dark:hover:bg-gray-800"
              >
                {t(item.key)}
              </a>
            ))}
            <Link
              href="/signin"
              onClick={() => setOpen(false)}
              className="flex min-h-11 items-center rounded-lg px-3 text-base font-semibold text-navy-muted hover:bg-cream-dark dark:text-gray-400 dark:hover:bg-gray-800"
            >
              {t("signin")}
            </Link>
            <Link
              href="/demo"
              onClick={() => setOpen(false)}
              className="mt-2 flex min-h-12 items-center justify-center rounded-xl bg-brand-500 px-4 text-base font-extrabold text-white hover:bg-brand-600"
            >
              {t("freeTrial")}
            </Link>
          </nav>
        </div>
      )}
    </>
  );
}

export function FaqAccordion({ items }: { items: { q: string; a: string }[] }) {
  const [openIdx, setOpenIdx] = useState<number | null>(null);
  const baseId = useId();

  return (
    <div className="divide-y divide-cream-dark rounded-2xl border border-cream-dark bg-white dark:divide-gray-700 dark:border-gray-700 dark:bg-gray-800">
      {items.map((item, i) => {
        const isOpen = openIdx === i;
        const btnId = `${baseId}-q-${i}`;
        const panelId = `${baseId}-a-${i}`;
        return (
          <div key={item.q}>
            <h3>
              <button
                type="button"
                id={btnId}
                aria-expanded={isOpen}
                aria-controls={panelId}
                onClick={() => setOpenIdx(isOpen ? null : i)}
                className="flex min-h-14 w-full items-center justify-between gap-4 px-5 py-4 text-start text-base font-bold text-navy focus-visible:outline-2 focus-visible:-outline-offset-2 focus-visible:outline-brand-500 sm:text-lg dark:text-gray-100"
              >
                <span>{item.q}</span>
                <IconChevronDown
                  className={`h-5 w-5 shrink-0 text-brand-600 transition-transform motion-reduce:transition-none dark:text-brand-300 ${
                    isOpen ? "rotate-180" : ""
                  }`}
                />
              </button>
            </h3>
            <div
              id={panelId}
              role="region"
              aria-labelledby={btnId}
              hidden={!isOpen}
              className="px-5 pb-5 text-base leading-relaxed text-navy-muted dark:text-gray-300"
            >
              {item.a}
            </div>
          </div>
        );
      })}
    </div>
  );
}
