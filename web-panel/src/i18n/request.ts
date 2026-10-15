import { getRequestConfig } from "next-intl/server";

import { type MesajNesnesi, icerikUygula } from "../lib/cms/icerik";
import { yayinSiteIcerigi } from "../lib/cms/icerik-sunucu";
import { temelMesajlar } from "./temel-mesajlar";
import { type Locale, routing } from "./routing";

export default getRequestConfig(async ({ requestLocale }) => {
  const requested = await requestLocale;
  const locale = routing.locales.includes(requested as Locale)
    ? (requested as Locale)
    : routing.defaultLocale;

  // Önce JSON'daki temel metinler, sonra CMS'te (site_icerik) tanımlı olanlar üzerine yazılır.
  const temel = await temelMesajlar(locale);
  const satirlar = await yayinSiteIcerigi(locale);

  return {
    locale,
    messages: icerikUygula(temel, satirlar, locale) as MesajNesnesi,
  };
});
