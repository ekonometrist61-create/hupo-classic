import ForgotPasswordForm from "@/components/auth/ForgotPasswordForm";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "Parolanı sıfırla | Hupolingo",
  description: "Hupolingo hesabın için parola sıfırlama bağlantısı iste.",
};

export default function ForgotPassword() {
  return <ForgotPasswordForm />;
}
