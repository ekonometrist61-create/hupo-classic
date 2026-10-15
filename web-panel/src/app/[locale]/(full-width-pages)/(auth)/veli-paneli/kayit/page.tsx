import SignUpForm from "@/components/auth/SignUpForm";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "Veli Hesabı Oluştur | Hupolingo",
  description: "Veli hesabı oluşturma. Öğrenci hesapları app.hupolingo.com üzerinden açılır.",
};

export default function VeliKayit() {
  return <SignUpForm />;
}
