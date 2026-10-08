import { IconInstagram, IconLinkedIn, IconYoutube } from "@/components/landing/Icons";
import { marketingFont } from "@/components/landing/marketingFont";
import { getTranslations } from "next-intl/server";
import Image from "next/image";
import Link from "next/link";

export async function LandingFooter() {
  const t = await getTranslations("landing");

  return (
    <footer className={`${marketingFont.className} bg-cream py-10 dark:bg-gray-950`}>
      <div className="mx-auto grid max-w-6xl gap-8 px-4 sm:px-6 md:grid-cols-[1.4fr_1fr_1fr_1fr] lg:px-8">
        {/* Marka */}
        <div>
          <p className="flex items-center gap-2 text-xl font-extrabold">
            <Image src="/hupo/hosgeldin.webp" alt="" width={420} height={415} className="h-9 w-9 object-contain" />
            {t("brand")}
          </p>
          <p className="mt-3 leading-relaxed text-navy-muted dark:text-gray-300">{t("footer.tagline")}</p>
          {/* Sosyal medya */}
          <div className="mt-4 flex items-center gap-3">
            <a
              href="https://instagram.com/hupolingo"
              aria-label="Instagram"
              className="flex h-9 w-9 items-center justify-center rounded-lg text-navy-muted transition-colors hover:bg-cream-dark hover:text-brand-600 dark:text-gray-400 dark:hover:bg-gray-800"
            >
              <IconInstagram className="h-5 w-5" />
            </a>
            <a
              href="https://youtube.com/@hupolingo"
              aria-label="YouTube"
              className="flex h-9 w-9 items-center justify-center rounded-lg text-navy-muted transition-colors hover:bg-cream-dark hover:text-brand-600 dark:text-gray-400 dark:hover:bg-gray-800"
            >
              <IconYoutube className="h-5 w-5" />
            </a>
            <a
              href="https://linkedin.com/company/hupolingo"
              aria-label="LinkedIn"
              className="flex h-9 w-9 items-center justify-center rounded-lg text-navy-muted transition-colors hover:bg-cream-dark hover:text-brand-600 dark:text-gray-400 dark:hover:bg-gray-800"
            >
              <IconLinkedIn className="h-5 w-5" />
            </a>
          </div>
          {/* App store badges */}
          <div className="mt-4 flex flex-col gap-2">
            <span className="inline-flex items-center gap-2 rounded-xl border border-navy/15 bg-navy px-4 py-2 text-xs font-bold text-white dark:border-gray-600">
              <svg className="h-4 w-4" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/></svg>
              {t("footer.appStore")}
            </span>
            <span className="inline-flex items-center gap-2 rounded-xl border border-navy/15 bg-navy px-4 py-2 text-xs font-bold text-white dark:border-gray-600">
              <svg className="h-4 w-4" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M3.18 23.76c.33.18.71.21 1.07.09l11.5-6.64-2.36-2.36L3.18 23.76zm13.24-7.65L4.24.74C3.88.55 3.47.55 3.1.74L14.06 11.7l2.36-1.59zm3.51-2.02-3.04-1.76-2.6 1.75 2.6 1.75 3.04-1.74zM3.1 23.26c.37.19.78.19 1.14 0L16.42 16.7l-2.36-2.35L3.1 23.26z"/></svg>
              {t("footer.googlePlay")}
            </span>
          </div>
        </div>

        {/* Ürün */}
        <nav aria-label={t("footer.colProduct")}>
          <p className="font-extrabold">{t("footer.colProduct")}</p>
          <ul className="mt-3 space-y-1 text-navy-muted dark:text-gray-300">
            <li><Link href="/demo" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.demo")}</Link></li>
            <li><a href="#how-it-works" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.how")}</a></li>
            <li><a href="#characters" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.characters")}</a></li>
            <li><a href="#deneme-exam" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.denemeExam")}</a></li>
            <li><a href="#pricing" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.pricing")}</a></li>
            <li><a href="#faq" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.faq")}</a></li>
          </ul>
        </nav>

        {/* Veliler */}
        <nav aria-label={t("footer.colParents")}>
          <p className="font-extrabold">{t("footer.colParents")}</p>
          <ul className="mt-3 space-y-1 text-navy-muted dark:text-gray-300">
            <li><a href="#why-parents" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.parentGuide")}</a></li>
            <li><a href="#report" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.parentPanel")}</a></li>
            <li><Link href="/signup" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.signup")}</Link></li>
            <li><Link href="/signin" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.signin")}</Link></li>
          </ul>
        </nav>

        {/* Şirket */}
        <nav aria-label={t("footer.colCompany")}>
          <p className="font-extrabold">{t("footer.colCompany")}</p>
          <ul className="mt-3 space-y-1 text-navy-muted dark:text-gray-300">
            <li><a href="#" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.about")}</a></li>
            <li><a href="#" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.blog")}</a></li>
            <li><a href="#" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.contact")}</a></li>
            <li><a href="#" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.privacy")}</a></li>
            <li><a href="#" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.terms")}</a></li>
          </ul>
        </nav>
      </div>

      <div className="mx-auto mt-8 flex max-w-6xl flex-wrap items-center justify-between gap-4 border-t border-cream-dark px-4 pt-6 sm:px-6 lg:px-8 dark:border-gray-800">
        <p className="text-sm text-navy-muted dark:text-gray-400">{t("footer.copyright")}</p>
        <p className="inline-flex items-center gap-2 rounded-full bg-gold-100 px-3 py-1 text-xs font-bold text-gold-900 dark:bg-gold-900/30 dark:text-gold-200">
          {t("footer.pilot")}
        </p>
      </div>
    </footer>
  );
}
