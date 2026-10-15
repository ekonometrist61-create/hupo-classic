import ResetPasswordForm from "@/components/auth/ResetPasswordForm";
import { Metadata } from "next";
import { getTranslations, setRequestLocale } from "next-intl/server";

// Parola sıfırlama bağlantısı içeren sayfa dizine eklenmesin.
export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "meta.sifreYeni" });
  return { title: t("title"), description: t("description"), robots: { index: false, follow: false } };
}

export default async function ResetPassword({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  return <ResetPasswordForm />;
}
