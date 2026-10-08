"use client";

import { Link, usePathname, useRouter } from "@/i18n/navigation";
import { useCurrentRole } from "@/hooks/useCurrentRole";
import { DEMO_MODE } from "@/lib/demo-mode";
import { cn } from "@/utils";
import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import BrandMark from "@/components/common/BrandMark";
import { useSidebar } from "../context/SidebarContext";
import {
  BoltIcon,
  BoxIcon,
  DocsIcon,
  GridIcon,
  GroupIcon,
  HorizontaLDots,
  MailIcon,
  PieChartIcon,
  ShootingStarIcon,
  TableIcon,
  TaskIcon,
  UserCircleIcon,
} from "../icons/index";

type VeliNavItem = {
  key: string;
  icon: React.ReactNode;
  path?: string;
};

type VeliNavGroup = {
  key: string;
  items: VeliNavItem[];
};

const VELI_NAV: VeliNavGroup[] = [
  {
    key: "tracking",
    items: [
      { key: "overview", icon: <GridIcon />, path: "/veli-paneli" },
      { key: "learning", icon: <BoltIcon /> },
      { key: "subjects", icon: <TableIcon />, path: "/veli-paneli/dersler" },
    ],
  },
  {
    key: "performance",
    items: [
      { key: "questions", icon: <PieChartIcon /> },
      { key: "review", icon: <TaskIcon />, path: "/veli-paneli/tekrar" },
      { key: "exams", icon: <DocsIcon /> },
    ],
  },
  {
    key: "motivation",
    items: [
      { key: "goals", icon: <ShootingStarIcon /> },
      { key: "achievements", icon: <BoxIcon />, path: "/veli-paneli/basarilar" },
      { key: "activity", icon: <BoltIcon /> },
    ],
  },
  {
    key: "account",
    items: [
      { key: "notifications", icon: <MailIcon /> },
      { key: "children", icon: <GroupIcon /> },
      { key: "membership", icon: <UserCircleIcon />, path: "/veli-paneli/uyelik" },
    ],
  },
];

const VeliSidebar: React.FC = () => {
  const { isExpanded, isMobileOpen, isHovered, setIsHovered } = useSidebar();
  const pathname = usePathname();
  const router = useRouter();
  const t = useTranslations("veliPaneli");
  const fetchedRole = useCurrentRole();
  const role = DEMO_MODE ? "admin" : fetchedRole;

  const cikisYap = async () => {
    await createClient().auth.signOut();
    router.replace("/signin");
  };

  const wide = isExpanded || isHovered || isMobileOpen;

  const isActive = (path: string) =>
    path === "/veli-paneli"
      ? pathname === path
      : pathname === path || pathname.startsWith(path + "/");

  return (
    <aside
      aria-label={t("shell.brandSub")}
      className={cn(
        "fixed top-0 left-0 z-50 flex h-full flex-col bg-navy px-4 pt-7 pb-4 text-[#d2dce5] transition-all duration-300 ease-in-out xl:mt-0 rtl:right-0 rtl:left-auto",
        wide ? "w-72.5" : "w-22.5",
        isMobileOpen ? "translate-x-0" : "-translate-x-full rtl:translate-x-full",
        "xl:translate-x-0 xl:rtl:translate-x-0",
      )}
      onMouseEnter={() => !isExpanded && setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      <Link
        href="/veli-paneli"
        className={cn(
          "flex items-center gap-3 rounded-lg px-1 pb-1 focus-visible:outline-3 focus-visible:outline-offset-4 focus-visible:outline-blue-light-400",
          !wide && "xl:justify-center",
        )}
      >
        {wide ? (
          <div>
            <BrandMark onDark />
            <span className="mt-1.5 block ps-0.5 text-[11px] font-medium tracking-[1.1px] text-[#b3c3d0]">
              {t("shell.brandSub")}
            </span>
          </div>
        ) : (
          <BrandMark compact />
        )}
      </Link>

      <nav
        aria-label={t("shell.brandSub")}
        className="no-scrollbar mt-4 flex-1 overflow-y-auto"
      >
        {VELI_NAV.map((group) => (
          <div key={group.key}>
            <h2
              className={cn(
                "mx-3 mt-5 mb-1.5 flex text-[10px] tracking-[1.3px] text-[#a7bdcc] uppercase",
                !wide && "xl:justify-center",
              )}
            >
              {wide ? t(`navGroups.${group.key}`) : <HorizontaLDots />}
            </h2>
            <ul className="flex flex-col gap-0.5">
              {group.items.map((item) => {
                const label = t(`nav.${item.key}`);
                const base =
                  "group relative flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-theme-sm";
                const icon = (
                  <span className="size-5 shrink-0 [&>svg]:size-5">{item.icon}</span>
                );

                if (!item.path) {
                  return (
                    <li key={item.key}>
                      <span
                        aria-disabled="true"
                        title={`${label} · ${t("shell.soon")}`}
                        className={cn(base, "cursor-not-allowed text-[#d2dce5]/45")}
                      >
                        {icon}
                        {wide && (
                          <>
                            <span className="truncate">{label}</span>
                            <span className="ms-auto rounded bg-[#365169] px-1.5 text-[10px] text-[#b3c3d0]">
                              {t("shell.soon")}
                            </span>
                          </>
                        )}
                      </span>
                    </li>
                  );
                }

                const active = isActive(item.path);
                return (
                  <li key={item.key}>
                    <Link
                      href={item.path}
                      aria-current={active ? "page" : undefined}
                      title={wide ? undefined : label}
                      className={cn(
                        base,
                        "focus-visible:outline-3 focus-visible:outline-offset-2 focus-visible:outline-blue-light-400",
                        active
                          ? "bg-[#e6f3ec] font-bold text-[#244b3e]"
                          : "font-medium hover:bg-[#29475e]",
                        !wide && "xl:justify-center",
                      )}
                    >
                      {active && (
                        <span
                          aria-hidden
                          className="absolute inset-s-1 h-5.5 w-0.75 rounded-full bg-gold-500"
                        />
                      )}
                      {icon}
                      {wide && <span className="truncate">{label}</span>}
                    </Link>
                  </li>
                );
              })}
            </ul>
          </div>
        ))}
      </nav>

      {/* Admin kullanıcılar için yönetim paneline geri dön */}
      <div className="mt-3 border-t border-[#3b5369] pt-3">
        {role === "admin" && wide && (
          <Link
            href="/yonetim"
            className="flex items-center gap-2 rounded-lg px-3 py-2 text-[12px] text-[#b3c3d0] hover:bg-[#29475e] hover:text-white transition-colors"
          >
            <span>← {t("shell.backToAdmin")}</span>
          </Link>
        )}
        <button
          type="button"
          onClick={cikisYap}
          title={wide ? undefined : t("shell.signOut")}
          className={cn(
            "flex w-full items-center gap-2 rounded-lg px-3 py-2 text-[12px] text-[#b3c3d0] hover:bg-[#29475e] hover:text-white transition-colors",
            !wide && "xl:justify-center",
          )}
        >
          <span>{wide ? t("shell.signOut") : "⎋"}</span>
        </button>
      </div>
    </aside>
  );
};

export default VeliSidebar;
