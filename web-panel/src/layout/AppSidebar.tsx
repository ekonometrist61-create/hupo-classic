"use client";

import { Link, usePathname } from "@/i18n/navigation";
import { useCurrentRole } from "@/hooks/useCurrentRole";
import { DEMO_MODE } from "@/lib/demo-mode";
import { cn } from "@/utils";
import { useTranslations } from "next-intl";
import BrandMark from "@/components/common/BrandMark";
import { useSidebar } from "../context/SidebarContext";
import { HorizontaLDots } from "../icons/index";
import { navForRole } from "./adminNav";

const AppSidebar: React.FC = () => {
  const { isExpanded, isMobileOpen, isHovered, setIsHovered } = useSidebar();
  const pathname = usePathname();
  const t = useTranslations("yonetim.shell");
  const fetchedRole = useCurrentRole();
  // Demo modunda oturum yoktur; menü yine de önizlenebilsin.
  const role = DEMO_MODE ? "admin" : fetchedRole;
  const groups = navForRole(role);

  const wide = isExpanded || isHovered || isMobileOpen;

  const isActive = (path: string) =>
    path === "/yonetim"
      ? pathname === path
      : pathname === path || pathname.startsWith(path + "/");

  return (
    <aside
      aria-label={t("brandSub")}
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
        href="/yonetim"
        className={cn(
          "flex items-center gap-3 rounded-lg px-1 pb-1 focus-visible:outline-3 focus-visible:outline-offset-4 focus-visible:outline-blue-light-400",
          !wide && "xl:justify-center",
        )}
      >
        {wide ? (
          <div>
            <BrandMark onDark />
            <span className="mt-1.5 block ps-0.5 text-[11px] font-medium tracking-[1.1px] text-[#b3c3d0]">
              {t("brandSub")}
            </span>
          </div>
        ) : (
          <BrandMark compact />
        )}
      </Link>

      {wide && (
        <div className="mx-1 mt-5 flex items-center justify-between rounded-lg border border-[#425970] px-3 py-2.5 text-xs">
          <span className="flex items-center gap-2">
            <span className="size-1.5 rounded-full bg-success-500" aria-hidden />
            {t("workspace")}
          </span>
          <span>TR</span>
        </div>
      )}

      <nav
        aria-label={t("groups.workspace")}
        className="no-scrollbar mt-2 flex-1 overflow-y-auto"
      >
        {groups.map((group) => (
          <div key={group.key}>
            <h2
              className={cn(
                "mx-3 mt-5 mb-1.5 flex text-[10px] tracking-[1.3px] text-[#a7bdcc] uppercase",
                !wide && "xl:justify-center",
              )}
            >
              {wide ? t(`groups.${group.key}`) : <HorizontaLDots />}
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
                        title={`${label} · ${t("soon")}`}
                        className={cn(base, "cursor-not-allowed text-[#d2dce5]/45")}
                      >
                        {icon}
                        {wide && (
                          <>
                            <span className="truncate">{label}</span>
                            <span className="ms-auto rounded bg-[#365169] px-1.5 text-[10px] text-[#b3c3d0]">
                              {t("soon")}
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

      {wide && (
        <p className="mt-3 border-t border-[#3b5369] px-3 pt-4 text-[11px] text-[#b9cbd7]">
          {t("tagline")}
        </p>
      )}
    </aside>
  );
};

export default AppSidebar;
