import { Nunito } from "next/font/google";

// Halka açık satış yüzeyleri (landing, demo) için yuvarlak, çocuk/veli dostu yazı tipi.
// latin-ext olmadan ğ ş ı İ gibi Türkçe harfler yedek fonta düşer.
export const marketingFont = Nunito({
  subsets: ["latin", "latin-ext"],
  display: "swap",
});
