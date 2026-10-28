import SayfaIskeleti from "@/components/common/SayfaIskeleti";
import { getTranslations } from "next-intl/server";

// Veli sayfası geçişlerinde içerik gelene kadar iskelet (tıklama anında geri bildirim verir).
export default async function Loading() {
  const t = await getTranslations("veliPaneli");
  return <SayfaIskeleti etiket={t("loading")} />;
}
