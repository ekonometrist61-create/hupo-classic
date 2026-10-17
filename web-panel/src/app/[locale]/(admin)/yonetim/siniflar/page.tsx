import SiniflarManager from "@/components/yonetim/panel/SiniflarManager";
import { getTranslations, setRequestLocale } from "next-intl/server";

// Sayfa başlığı role göre (admin: "Sınıf Yönetimi", öğretmen: "Sınıflarım") istemcide seçilir.
export async function generateMetadata() {
  const t = await getTranslations("yonetim.shell.nav");
  return { title: t("classes") };
}

export default async function Page({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);

  return <SiniflarManager />;
}
