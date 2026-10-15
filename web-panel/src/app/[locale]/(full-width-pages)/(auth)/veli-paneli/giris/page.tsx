import SignInForm from "@/components/auth/SignInForm";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "Veli Paneli Girişi | Hupolingo",
  description: "Veli ve öğretmen girişi. Öğrenci hesapları app.hupolingo.com üzerinden girer.",
};

export default function VeliGiris() {
  return <SignInForm variant="veli" />;
}
