import { marketingFont } from "@/components/landing/marketingFont";
import Image from "next/image";
import Link from "next/link";

// Okuma sayfaları için sade üst bilgi. Landing üst bilgisi (#çapa menüsü) kullanılmaz:
// bu sayfalar navigasyona bağlı değildir ve çapa bağlantıları burada karşılıksız kalır.
export function OkumaSiteUst() {
  return (
    <header className={`${marketingFont.className} border-b border-cream-dark bg-cream dark:border-gray-800 dark:bg-gray-950`}>
      <div className="mx-auto flex h-16 max-w-3xl items-center justify-between gap-4 px-4 sm:px-6">
        <Link href="/" className="flex shrink-0 items-center gap-2" aria-label="Hupolingo ana sayfa">
          <Image src="/hupo/hosgeldin.webp" alt="" width={420} height={415} className="h-9 w-9 object-contain" />
          <span className="text-xl font-extrabold tracking-tight">Hupolingo</span>
        </Link>
        <Link
          href="/"
          className="inline-flex min-h-11 items-center px-2 text-sm font-bold text-navy-muted hover:text-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 dark:text-gray-300"
        >
          Ana sayfa
        </Link>
      </div>
    </header>
  );
}
