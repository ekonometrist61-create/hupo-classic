"use client";

import { useEffect, useState } from "react";

type FontLevel = "normal" | "large";

const STORAGE_KEY = "hupo-font-size";
const SIZES: Record<FontLevel, string> = {
  normal: "",
  large: "18px",
};

function applyFontSize(level: FontLevel) {
  document.documentElement.style.fontSize = SIZES[level];
}

export function FontSizeToggle() {
  const [level, setLevel] = useState<FontLevel>("normal");

  useEffect(() => {
    try {
      const saved = localStorage.getItem(STORAGE_KEY) as FontLevel | null;
      if (saved && saved in SIZES) {
        setLevel(saved);
        applyFontSize(saved);
      }
    } catch {}
  }, []);

  function handleClick(next: FontLevel) {
    setLevel(next);
    applyFontSize(next);
    try {
      localStorage.setItem(STORAGE_KEY, next);
    } catch {}
  }

  const levels: { key: FontLevel; label: string }[] = [
    { key: "normal", label: "A" },
    { key: "large", label: "A+" },
  ];

  return (
    <div
      role="group"
      aria-label="Yazı boyutu"
      className="hidden items-center gap-0.5 rounded-lg border border-navy/10 bg-cream-dark p-0.5 sm:flex dark:border-gray-700 dark:bg-gray-800"
    >
      {levels.map(({ key, label }) => (
        <button
          key={key}
          type="button"
          onClick={() => handleClick(key)}
          aria-pressed={level === key}
          className={`flex h-7 min-w-[2rem] items-center justify-center rounded-md px-1.5 text-xs font-bold transition-colors focus-visible:outline-2 focus-visible:outline-offset-1 focus-visible:outline-brand-500 ${
            level === key
              ? "bg-brand-500 text-white shadow-sm"
              : "text-navy-muted hover:text-brand-600 dark:text-gray-400 dark:hover:text-brand-300"
          }`}
        >
          {label}
        </button>
      ))}
    </div>
  );
}
