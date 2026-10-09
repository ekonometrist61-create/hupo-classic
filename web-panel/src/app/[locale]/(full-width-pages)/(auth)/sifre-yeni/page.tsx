import ResetPasswordForm from "@/components/auth/ResetPasswordForm";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "Yeni parola belirle | Hupolingo",
  description: "Hupolingo hesabın için yeni parola belirle.",
  // Parola sıfırlama bağlantısı içeren sayfa dizine eklenmesin.
  robots: { index: false, follow: false },
};

export default function ResetPassword() {
  return <ResetPasswordForm />;
}
