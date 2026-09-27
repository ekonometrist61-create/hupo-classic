import SignInForm from "@/components/auth/SignInForm";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "Giriş Yap",
  description: "Proje Okulu veli ve yönetici giriş ekranı.",
};

export default function SignIn() {
  return <SignInForm />;
}
