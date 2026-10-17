"use client";

import BrandMark from "@/components/common/BrandMark";
import { Link } from "@/i18n/navigation";
import { useTranslations } from "next-intl";
import { useSidebar } from "../context/SidebarContext";

/** Veli kabuğunun mobil ve tablet üst çubuğu. Menüyü (VeliSidebar) açar; xl'de gizlidir. */
const VeliHeader: React.FC = () => {
  const t = useTranslations("veliPaneli");
  const { isMobileOpen, toggleMobileSidebar } = useSidebar();

  return (
    <header className="sticky top-0 z-40 flex items-center gap-3 border-b border-gray-200 bg-white px-4 py-2 xl:hidden dark:border-gray-800 dark:bg-gray-900">
      <button
        type="button"
        data-mobil-menu
        aria-controls="kenar-menu"
        aria-expanded={isMobileOpen}
        aria-label={t("shell.menu")}
        onClick={toggleMobileSidebar}
        className="flex h-11 w-11 shrink-0 items-center justify-center rounded-lg text-gray-600 hover:bg-gray-100 focus-visible:outline-3 focus-visible:outline-offset-2 focus-visible:outline-blue-light-400 dark:text-gray-400 dark:hover:bg-gray-800"
      >
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" aria-hidden>
          <path
            d="M4 6h16M4 12h16M4 18h16"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
          />
        </svg>
      </button>
      <Link href="/veli-paneli" className="min-w-0">
        <BrandMark />
      </Link>
    </header>
  );
};

export default VeliHeader;
