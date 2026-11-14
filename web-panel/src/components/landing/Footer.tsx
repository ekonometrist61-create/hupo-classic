import { IconInstagram, IconLinkedIn, IconYoutube } from "@/components/landing/Icons";
import { marketingFont } from "@/components/landing/marketingFont";
import { STUDENT_APP_URL } from "@/lib/app-url";
import { LEAD_MAGNET_ACIK } from "@/lib/lead-magnet";
import { getTranslations } from "next-intl/server";
import Image from "next/image";
import Link from "next/link";

export async function LandingFooter() {
  const t = await getTranslations("landing");
  const g = await getTranslations("gorseller");

  return (
    <footer className={`${marketingFont.className} bg-cream py-10 dark:bg-gray-950`}>
      <div className="mx-auto grid max-w-6xl gap-8 px-4 sm:px-6 md:grid-cols-[1.4fr_1fr_1fr_1fr] lg:px-8">
        {/* Marka */}
        <div>
          <p className="flex items-center gap-2 text-xl font-extrabold">
            <Image src={g("hupo.hosgeldin")} alt="" width={420} height={415} className="h-9 w-9 object-contain" />
            {t("brand")}
          </p>
          <p className="mt-3 leading-relaxed text-navy-muted dark:text-gray-300">{t("footer.tagline")}</p>
          {/* Sosyal medya */}
          <div className="mt-4 flex items-center gap-3">
            <a
              href="https://instagram.com/hupolingo"
              aria-label="Instagram"
              className="flex h-11 w-11 items-center justify-center rounded-lg text-navy-muted transition-colors hover:bg-cream-dark hover:text-brand-600 dark:text-gray-400 dark:hover:bg-gray-800"
            >
              <IconInstagram className="h-5 w-5" />
            </a>
            <a
              href="https://youtube.com/@hupolingo"
              aria-label="YouTube"
              className="flex h-11 w-11 items-center justify-center rounded-lg text-navy-muted transition-colors hover:bg-cream-dark hover:text-brand-600 dark:text-gray-400 dark:hover:bg-gray-800"
            >
              <IconYoutube className="h-5 w-5" />
            </a>
            <a
              href="https://linkedin.com/company/hupolingo"
              aria-label="LinkedIn"
              className="flex h-11 w-11 items-center justify-center rounded-lg text-navy-muted transition-colors hover:bg-cream-dark hover:text-brand-600 dark:text-gray-400 dark:hover:bg-gray-800"
            >
              <IconLinkedIn className="h-5 w-5" />
            </a>
          </div>
          {/* Mağaza yayını yok: tıklanamaz rozet yerine sakin not. */}
          <p className="mt-4 text-sm font-semibold text-navy-muted dark:text-gray-400">{t("footer.appSoon")}</p>
        </div>

        {/* Ürün */}
        <nav aria-label={t("footer.colProduct")}>
          <p className="font-extrabold">{t("footer.colProduct")}</p>
          <ul className="mt-3 space-y-1 text-navy-muted dark:text-gray-300">
            <li><Link href="/demo" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.demo")}</Link></li>
            <li><a href="#how-it-works" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.how")}</a></li>
            <li><a href="#characters" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.characters")}</a></li>
            <li><a href="#deneme-sinavi"className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.denemeExam")}</a></li>
            <li><a href="#pricing" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.pricing")}</a></li>
            <li><a href="#faq" className="inline-flex min-h-11 min-w-11 items-center hover:text-brand-600">{t("footer.faq")}</a></li>
          </ul>
        </nav>

        {/* Veliler */}
        <nav aria-label={t("footer.colParents")}>
          <p className="font-extrabold">{t("footer.colParents")}</p>
          <ul className="mt-3 space-y-1 text-navy-muted dark:text-gray-300">
            <li><a href="#why-parents" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.parentGuide")}</a></li>
            <li><a href="#report" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.parentPanel")}</a></li>
            {LEAD_MAGNET_ACIK && (
              <li><Link href="/rehber/carpim-tablosu-pif-noktalari" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.rehber")}</Link></li>
            )}
            <li><Link href="/veli-paneli/kayit" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.signup")}</Link></li>
            <li><Link href="/veli-paneli/giris" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.signin")}</Link></li>
            <li><a href={STUDENT_APP_URL} className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.studentLogin")}</a></li>
          </ul>
        </nav>

        {/* Şirket */}
        <nav aria-label={t("footer.colCompany")}>
          <p className="font-extrabold">{t("footer.colCompany")}</p>
          <ul className="mt-3 space-y-1 text-navy-muted dark:text-gray-300">
            <li><Link href="/yontem" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.method")}</Link></li>
            <li><Link href="/gizlilik" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.privacy")}</Link></li>
            <li><Link href="/kosullar" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.terms")}</Link></li>
          </ul>
        </nav>
      </div>

      <div className="mx-auto mt-8 flex max-w-6xl flex-wrap items-center justify-between gap-4 border-t border-cream-dark px-4 pt-6 sm:px-6 lg:px-8 dark:border-gray-800">
        <p className="text-sm text-navy-muted dark:text-gray-400">{t("footer.copyright")}</p>
      </div>
    </footer>
  );
}
