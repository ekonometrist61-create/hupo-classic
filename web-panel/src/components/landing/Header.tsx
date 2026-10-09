import { FontSizeToggle } from "@/components/landing/FontSizeToggle";
import { MobileMenu } from "@/components/landing/LandingClient";
import { marketingFont } from "@/components/landing/marketingFont";
import { STUDENT_APP_URL } from "@/lib/app-url";
import { getTranslations } from "next-intl/server";
import Image from "next/image";
import Link from "next/link";

export async function LandingHeader() {
  const t = await getTranslations("landing");

  const navItems: { href: string; label: string }[] = [
    { href: "#demo", label: t("nav.demo") },
    { href: "#app-screens", label: t("nav.appScreens") },
    { href: "#characters", label: t("nav.characters") },
    { href: "#how-it-works", label: t("nav.how") },
    { href: "#why-parents", label: t("nav.parents") },
    { href: "#pricing", label: t("nav.pricing") },
    { href: "#faq", label: t("nav.faq") },
  ];

  return (
    <header
      className={`${marketingFont.className} sticky top-0 z-50 border-b border-cream-dark bg-cream/90 backdrop-blur-md dark:border-gray-800 dark:bg-gray-950/90`}
    >
      <div className="relative mx-auto flex h-16 max-w-6xl items-center justify-between px-4 sm:px-6 lg:px-8">
        <Link href="/" className="flex items-center gap-2" aria-label={t("brand")}>
          <Image
            src="/hupo/hosgeldin.webp"
            alt=""
            width={420}
            height={415}
            className="h-9 w-9 object-contain"
          />
          <span className="text-xl font-extrabold tracking-tight">{t("brand")}</span>
        </Link>

        <nav
          aria-label={t("nav.label")}
          className="hidden items-center gap-5 text-sm font-bold text-navy-muted xl:flex dark:text-gray-300"
        >
          {navItems.map(({ href, label }) => (
            <a key={href} href={href} className="hover:text-brand-600 dark:hover:text-brand-300">
              {label}
            </a>
          ))}
        </nav>

        <div className="flex items-center gap-2 sm:gap-3">
          <FontSizeToggle />
          <Link
            href="/signin"
            className="hidden min-h-11 items-center px-2 text-sm font-bold text-navy hover:text-brand-600 sm:inline-flex dark:text-gray-100 dark:hover:text-brand-300"
          >
            {t("nav.signin")}
          </Link>
          <a
            href={STUDENT_APP_URL}
            className="hidden min-h-11 items-center px-2 text-sm font-bold text-navy-muted hover:text-brand-600 lg:inline-flex dark:text-gray-300 dark:hover:text-brand-300"
          >
            {t("nav.studentLogin")}
          </a>
          <Link
            href="/demo"
            className="inline-flex min-h-11 items-center rounded-xl bg-brand-500 px-4 text-sm font-bold text-white transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none"
          >
            {t("nav.freeTrial")}
          </Link>
          <MobileMenu />
        </div>
      </div>
    </header>
  );
}
