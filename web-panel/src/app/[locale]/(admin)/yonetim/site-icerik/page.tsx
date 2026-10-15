import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import SiteIcerikManager from "@/components/yonetim/panel/SiteIcerikManager";
import { temelMesajlar } from "@/i18n/temel-mesajlar";
import { adAlaniDeMi, metinYapraklari } from "@/lib/cms/icerik";
import { getTranslations, setRequestLocale } from "next-intl/server";

export const metadata = { title: "Site içeriği" };

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const d = await getTranslations("yonetim.shell.pageDesc");

  // Varsayılan (JSON) metinler iki dil için de okunur; düzenleme anında site_icerik'ten gelir.
  const [tr, en] = await Promise.all([temelMesajlar("tr"), temelMesajlar("en")]);
  const varsayilanlar = {
    tr: metinYapraklari(tr).filter((y) => adAlaniDeMi(y.anahtar)),
    en: metinYapraklari(en).filter((y) => adAlaniDeMi(y.anahtar)),
  };

  return (
    <div>
      <PageBreadcrumb pageTitle="Site içeriği" description={d("siteIcerik")} />
      <SiteIcerikManager varsayilanlar={varsayilanlar} />
    </div>
  );
}
