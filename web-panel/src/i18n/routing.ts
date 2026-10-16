import { defineRouting } from "next-intl/routing";

export const routing = defineRouting({
  locales: ["tr", "en"],
  defaultLocale: "tr",
  localePrefix: "never",
  // Tarayıcı dili (Accept-Language) içeriği İngilizceye çevirmesin: site her zaman Türkçe açılır.
  localeDetection: false,
});

export type Locale = (typeof routing.locales)[number];
