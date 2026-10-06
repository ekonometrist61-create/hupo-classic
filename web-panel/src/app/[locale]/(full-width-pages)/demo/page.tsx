import DemoQuiz from "@/components/demo/DemoQuiz";
import { marketingFont } from "@/components/landing/marketingFont";
import type { Metadata } from "next";
import { getTranslations } from "next-intl/server";
import Image from "next/image";
import Link from "next/link";

export async function generateMetadata(): Promise<Metadata> {
  const t = await getTranslations("demo");
  return { title: t("metaTitle"), description: t("metaDescription") };
}

export default async function DemoPage() {
  const t = await getTranslations("demo");
  const landing = await getTranslations("landing");

  return (
    <div
      className={`${marketingFont.className} min-h-screen bg-cream text-navy dark:bg-gray-950 dark:text-gray-100`}
    >
      <header className="border-b border-cream-dark dark:border-gray-800">
        <div className="mx-auto flex h-16 max-w-3xl items-center justify-between px-4 sm:px-6">
          <Link href="/" className="flex items-center gap-2" aria-label={landing("brand")}>
            <Image
              src="/hupo/hosgeldin.webp"
              alt=""
              width={420}
              height={415}
              className="h-9 w-9 object-contain"
            />
            <span className="text-xl font-extrabold tracking-tight">{landing("brand")}</span>
          </Link>
          <Link
            href="/"
            className="inline-flex min-h-11 items-center px-2 text-sm font-bold text-navy-muted hover:text-brand-600 dark:text-gray-300"
          >
            {t("back")}
          </Link>
        </div>
      </header>
      <main className="mx-auto max-w-3xl px-4 py-8 sm:px-6 sm:py-12">
        <h1 className="sr-only">{t("metaTitle")}</h1>
        <DemoQuiz />
      </main>
    </div>
  );
}
