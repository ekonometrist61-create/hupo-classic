import UnsubscribeForm from "@/components/auth/UnsubscribeForm";
import { Metadata } from "next";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "meta.iletisimIzni" });
  return { title: t("title"), description: t("description"), robots: { index: false, follow: false } };
}

export default async function Unsubscribe({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  return <UnsubscribeForm />;
}
