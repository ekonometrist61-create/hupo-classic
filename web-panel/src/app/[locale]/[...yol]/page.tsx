import { notFound } from "next/navigation";

// Hiçbir rotaya uymayan adresler. Bu olmazsa Next.js istekleri statik `/_not-found` sayfasına
// gönderir; o sayfanın inline script'leri nonce taşımadığı için CSP tarafından engellenir (GÖR-102).
// Catch-all rota isteği [locale] layout'u (dinamik, nonce'lu) içinde 404'e yönlendirir.
// Tanımlı rotalar her zaman önceliklidir; bu sayfa yalnızca eşleşmeyenleri yakalar.
export default function BilinmeyenYol() {
  notFound();
}
