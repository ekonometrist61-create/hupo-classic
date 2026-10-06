"use client";

import { ThemeToggleButton } from "@/components/common/ThemeToggleButton";
import NotificationDropdown from "@/components/header/NotificationDropdown";
import UserDropdown from "@/components/header/UserDropdown";
import CommandPalette from "@/components/yonetim/ui/CommandPalette";
import { useSidebar } from "@/context/SidebarContext";
import { Link, usePathname } from "@/i18n/navigation";
import { cn } from "@/utils";
import { useTranslations } from "next-intl";
import BrandMark from "@/components/common/BrandMark";
import { useState } from "react";
import { findNavEntry } from "./adminNav";

const AppHeader: React.FC = () => {
  const t = useTranslations("header");
  const ts = useTranslations("yonetim.shell");
  const pathname = usePathname();
  const [isApplicationMenuOpen, setApplicationMenuOpen] = useState(false);

  const { isMobileOpen, toggleSidebar, toggleMobileSidebar } = useSidebar();

  const handleToggle = () => {
    if (window.innerWidth >= 1280) {
      toggleSidebar();
    } else {
      toggleMobileSidebar();
    }
  };

  const current = findNavEntry(pathname);

  return (
    <header className="sticky top-0 z-99999 flex w-full border-gray-200 bg-white xl:border-b dark:border-gray-800 dark:bg-gray-900">
      <div className="flex grow flex-col items-center justify-between xl:h-19 xl:flex-row xl:px-8">
        <div className="flex w-full items-center justify-between gap-2 border-b border-gray-200 px-3 py-3 sm:gap-4 xl:justify-normal xl:border-b-0 xl:px-0 xl:py-0 dark:border-gray-800">
          <button
            className={cn(
              "z-99999 flex h-10 w-10 items-center justify-center rounded-lg border-gray-200 text-gray-500 focus-visible:outline-3 focus-visible:outline-offset-2 focus-visible:outline-blue-light-400 lg:h-11 lg:w-11 xl:border dark:border-gray-800 dark:text-gray-400",
              isMobileOpen && "bg-gray-100 dark:bg-white/3",
            )}
            onClick={handleToggle}
            aria-label={t("toggleSidebar")}
          >
            {isMobileOpen ? (
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" aria-hidden>
                <path
                  d="M6.22 7.28a.75.75 0 0 1 0-1.06.75.75 0 0 1 1.06 0L12 10.94l4.72-4.72a.75.75 0 1 1 1.06 1.06L13.06 12l4.72 4.72a.75.75 0 1 1-1.06 1.06L12 13.06l-4.72 4.72a.75.75 0 1 1-1.06-1.06L10.94 12z"
                  fill="currentColor"
                />
              </svg>
            ) : (
              <svg className="rtl:-scale-x-100" width="16" height="12" viewBox="0 0 16 12" fill="none" aria-hidden>
                <path
                  d="M1.33 .25h13.34a.75.75 0 0 1 0 1.5H1.33a.75.75 0 0 1 0-1.5Zm0 10h13.34a.75.75 0 0 1 0 1.5H1.33a.75.75 0 0 1 0-1.5ZM1.33 5.25H8a.75.75 0 0 1 0 1.5H1.33a.75.75 0 0 1 0-1.5Z"
                  fill="currentColor"
                />
              </svg>
            )}
          </button>

          <Link href="/yonetim" className="xl:hidden">
            <BrandMark />
          </Link>

          <button
            onClick={() => setApplicationMenuOpen((v) => !v)}
            aria-label={ts("workspaceCrumb")}
            aria-expanded={isApplicationMenuOpen}
            className="z-99999 flex h-10 w-10 items-center justify-center rounded-lg text-gray-700 hover:bg-gray-100 xl:hidden dark:text-gray-400 dark:hover:bg-gray-800"
          >
            <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor" aria-hidden>
              <circle cx="6" cy="12" r="1.5" />
              <circle cx="12" cy="12" r="1.5" />
              <circle cx="18" cy="12" r="1.5" />
            </svg>
          </button>

          <nav aria-label="breadcrumb" className="hidden text-xs text-gray-500 xl:block dark:text-gray-400">
            {ts("workspaceCrumb")}
            {current && (
              <>
                <span className="mx-2">/</span>
                <strong className="font-semibold text-navy dark:text-white/90">
                  {ts(`nav.${current.key}`)}
                </strong>
              </>
            )}
          </nav>
        </div>

        <div
          className={cn(
            "w-full items-center justify-between gap-4 px-5 py-4 shadow-theme-md xl:flex xl:w-auto xl:justify-end xl:px-0 xl:py-0 xl:shadow-none",
            isApplicationMenuOpen ? "flex" : "hidden",
          )}
        >
          <div className="flex items-center gap-2 2xsm:gap-3">
            <CommandPalette />
            <ThemeToggleButton />
            <NotificationDropdown />
          </div>
          <UserDropdown />
        </div>
      </div>
    </header>
  );
};

export default AppHeader;
