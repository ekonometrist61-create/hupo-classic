import { getRequestConfig } from "next-intl/server";

import { type Locale, routing } from "./routing";

type Messages = Record<string, unknown>;

// Panel bölümlerinin metinleri ayrı dosyalarda tutulur ve ana sözlüğe eklenir.
// (Her dosya kendi kök anahtarını taşır: yonetim.* ve veliPaneli.*)
const MESSAGE_PARTS = [
  "veli-paneli",
  "yonetim-panel",
  "yonetim-sorular",
  "yonetim-merkez",
] as const;

function isObject(value: unknown): value is Messages {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function deepMerge(base: Messages, extra: Messages): Messages {
  const out: Messages = { ...base };
  for (const [key, value] of Object.entries(extra)) {
    const current = out[key];
    out[key] =
      isObject(current) && isObject(value) ? deepMerge(current, value) : value;
  }
  return out;
}

export default getRequestConfig(async ({ requestLocale }) => {
  const requested = await requestLocale;
  const locale = routing.locales.includes(requested as Locale)
    ? (requested as Locale)
    : routing.defaultLocale;

  const base = (await import(`../messages/${locale}.json`)).default as Messages;
  const parts = await Promise.all(
    MESSAGE_PARTS.map(
      async (part) =>
        (await import(`../messages/${part}.${locale}.json`)).default as Messages
    )
  );

  return {
    locale,
    messages: parts.reduce(deepMerge, base),
  };
});
