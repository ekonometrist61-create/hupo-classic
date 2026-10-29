import { FontSizeToggle } from "@/components/landing/FontSizeToggle";
import { MobileMenu } from "@/components/landing/LandingClient";
import { marketingFont } from "@/components/landing/marketingFont";
import { SignInMenu } from "@/components/landing/SignInMenu";
import { getTranslations } from "next-intl/server";
import Image from "next/image";
import Link from "next/link";

export async function LandingHeader() {
  const t = await getTranslations("landing");
  const g = await getTranslations("gorseller");

  // Menü kısa tutuldu: sayfada karşılığı olmayan bağlantılar (örnek sorular, uygulama, veliler) çıkarıldı.
  const navItems: { href: string; label: string }[] = [
    { href: "#how-it-works", label: t("nav.how") },
    { href: "#report", label: t("nav.report") },
    { href: "#characters", label: t("nav.characters") },
    { href: "#pricing", label: t("nav.pricing") },
    { href: "#faq", label: t("nav.faq") },
  ];

  return (
    <header
      className={`${marketingFont.className} sticky top-0 z-50 border-b border-cream-dark bg-cream/90 backdrop-blur-md dark:border-gray-800 dark:bg-gray-950/90`}
    >
      <div className="relative mx-auto flex h-16 max-w-6xl items-center justify-between gap-4 px-4 sm:px-6 lg:px-8">
        <Link href="/" className="flex min-h-11 shrink-0 items-center gap-2" aria-label={t("brand")}>
          <Image
            src={g("hupo.hosgeldin")}
            alt=""
            width={420}
            height={415}
            className="h-9 w-9 object-contain"
          />
          <span className="text-xl font-extrabold tracking-tight">{t("brand")}</span>
        </Link>

        <nav
          aria-label={t("nav.label")}
          className="hidden items-center gap-1 whitespace-nowrap text-sm font-bold text-navy-muted xl:flex dark:text-gray-300"
        >
          {navItems.map(({ href, label }) => (
            <a
              key={href}
              href={href}
              className="inline-flex min-h-11 min-w-11 items-center justify-center px-2 hover:text-brand-600 dark:hover:text-brand-300"
            >
              {label}
            </a>
          ))}
        </nav>

        <div className="flex items-center gap-1 sm:gap-2">
          <FontSizeToggle />
          <SignInMenu />
          <Link
            href="/demo"
            className="hidden min-h-11 shrink-0 items-center whitespace-nowrap rounded-xl sm:inline-flex bg-brand-500 px-4 text-sm font-bold text-white transition-colors duration-200 ease-hupo-out hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none"
          >
            {t("nav.freeTrial")}
          </Link>
          <MobileMenu />
        </div>
      </div>
    </header>
  );
}
