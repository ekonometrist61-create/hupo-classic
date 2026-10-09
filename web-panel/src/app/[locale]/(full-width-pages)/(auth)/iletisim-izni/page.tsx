import UnsubscribeForm from "@/components/auth/UnsubscribeForm";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "İletişim iznini iptal et | Hupolingo",
  description: "Hupolingo'dan ticari ileti almayı durdur.",
  robots: { index: false, follow: false },
};

export default function Unsubscribe() {
  return <UnsubscribeForm />;
}
