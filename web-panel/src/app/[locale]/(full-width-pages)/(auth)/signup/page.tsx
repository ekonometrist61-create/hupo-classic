import SignUpForm from "@/components/auth/SignUpForm";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "Kayıt Ol | Hupo",
  description: "Proje Okulu veli ve öğretmen kayıt ekranı.",
};

export default function SignUp() {
  return <SignUpForm />;
}
