"use client";

import { Link, usePathname } from "@/i18n/navigation";
import { useCurrentRole } from "@/hooks/useCurrentRole";
import { cn } from "@/utils";
import { useTranslations } from "next-intl";
import Image from "next/image";
import { useCallback, useEffect, useRef, useState } from "react";
import { useSidebar } from "../context/SidebarContext";
import {
  ChevronDownIcon,
  GridIcon,
  HorizontaLDots,
  TableIcon,
  UserCircleIcon,
} from "../icons/index";

type NavItem = {
  key: string;
  icon: React.ReactNode;
  path?: string;
  roles?: string[];
  subItems?: {
    key: string;
    path: string;
    roles?: string[];
  }[];
};

const navItems: NavItem[] = [
  {
    icon: <GridIcon />,
    key: "yonetim",
    roles: ["admin"],
    subItems: [
      { key: "yonetimPanel", path: "/yonetim" },
      { key: "sorular", path: "/yonetim/sorular" },
      { key: "kullanicilar", path: "/yonetim/kullanicilar" },
      { key: "odemeler", path: "/yonetim/odemeler" },
      { key: "planlar", path: "/yonetim/planlar" },
      { key: "siniflar", path: "/yonetim/siniflar" },
      { key: "kuponlar", path: "/yonetim/kuponlar" },
      { key: "bildirimler", path: "/yonetim/bildirimler" },
    ],
  },
  {
    icon: <UserCircleIcon />,
    key: "veliPaneli",
    path: "/veli-paneli",
    roles: ["admin", "veli"],
  },
  {
    icon: <TableIcon />,
    key: "ogretmenSiniflari",
    path: "/yonetim/siniflar",
    roles: ["ogretmen"],
  },
];

const AppSidebar: React.FC = () => {
  const { isExpanded, isMobileOpen, isHovered, setIsHovered } = useSidebar();
  const pathname = usePathname();
  const t = useTranslations("sidebar");
  const role = useCurrentRole();

  const visibleItems = navItems.filter(
    (item) => !item.roles || (role !== null && item.roles.includes(role)),
  );

  const [openSubmenu, setOpenSubmenu] = useState<{
    type: "main";
    index: number;
  } | null>(null);
  const [subMenuHeight, setSubMenuHeight] = useState<Record<string, number>>(
    {},
  );
  const subMenuRefs = useRef<Record<string, HTMLDivElement | null>>({});

  const isActive = useCallback(
    (path: string) => pathname === path || pathname.startsWith(path + "/"),
    [pathname],
  );

  useEffect(() => {
    let submenuMatched = false;
    visibleItems.forEach((nav, index) => {
      if (nav.subItems) {
        nav.subItems.forEach((subItem) => {
          if (isActive(subItem.path)) {
            setOpenSubmenu({ type: "main", index });
            submenuMatched = true;
          }
        });
      }
    });
    if (!submenuMatched) {
      setOpenSubmenu(null);
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [pathname]);

  useEffect(() => {
    if (openSubmenu !== null) {
      const key = `main-${openSubmenu.index}`;
      if (subMenuRefs.current[key]) {
        setSubMenuHeight((prev) => ({
          ...prev,
          [key]: subMenuRefs.current[key]?.scrollHeight || 0,
        }));
      }
    }
  }, [openSubmenu]);

  const handleSubmenuToggle = (index: number) => {
    setOpenSubmenu((prev) =>
      prev && prev.index === index ? null : { type: "main", index },
    );
  };

  const renderItem = (nav: NavItem, index: number) => {
    if (nav.subItems) {
      const isOpen = openSubmenu?.index === index;
      return (
        <li key={nav.key}>
          <button
            onClick={() => handleSubmenuToggle(index)}
            className={cn(
              "group menu-item cursor-pointer",
              isOpen ? "menu-item-active" : "menu-item-inactive",
              !isExpanded && !isHovered ? "lg:justify-center" : "lg:justify-start",
            )}
          >
            <span className={cn(isOpen ? "menu-item-icon-active" : "menu-item-icon-inactive")}>
              {nav.icon}
            </span>
            {(isExpanded || isHovered || isMobileOpen) && (
              <span className="menu-item-text">{t(`items.${nav.key}`)}</span>
            )}
            {(isExpanded || isHovered || isMobileOpen) && (
              <ChevronDownIcon
                className={cn(
                  "ms-auto h-5 w-5 transition-transform duration-200",
                  isOpen ? "rotate-180 text-brand-500" : "",
                )}
              />
            )}
          </button>
          {(isExpanded || isHovered || isMobileOpen) && (
            <div
              ref={(el) => { subMenuRefs.current[`main-${index}`] = el; }}
              className="overflow-hidden transition-all duration-300"
              style={{ height: isOpen ? `${subMenuHeight[`main-${index}`]}px` : "0px" }}
            >
              <ul className="ms-9 mt-2 space-y-1">
                {nav.subItems.map((subItem) => (
                  <li key={subItem.key}>
                    <Link
                      href={subItem.path}
                      className={`menu-dropdown-item ${
                        isActive(subItem.path)
                          ? "menu-dropdown-item-active"
                          : "menu-dropdown-item-inactive"
                      }`}
                    >
                      {t(`items.${subItem.key}`)}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </li>
      );
    }
    if (nav.path) {
      return (
        <li key={nav.key}>
          <Link
            href={nav.path}
            className={cn(
              "group menu-item",
              isActive(nav.path) ? "menu-item-active" : "menu-item-inactive",
            )}
          >
            <span className={cn(isActive(nav.path) ? "menu-item-icon-active" : "menu-item-icon-inactive")}>
              {nav.icon}
            </span>
            {(isExpanded || isHovered || isMobileOpen) && (
              <span className="menu-item-text">{t(`items.${nav.key}`)}</span>
            )}
          </Link>
        </li>
      );
    }
    return null;
  };

  return (
    <aside
      className={`fixed top-0 left-0 z-50 flex h-full flex-col border-r border-gray-200 bg-white px-5 text-gray-900 transition-all duration-300 ease-in-out xl:mt-0 rtl:right-0 rtl:left-auto rtl:border-r-0 rtl:border-l dark:border-gray-800 dark:bg-gray-900 ${
        isExpanded || isMobileOpen ? "w-72.5" : isHovered ? "w-72.5" : "w-22.5"
      } ${
        isMobileOpen ? "translate-x-0" : "-translate-x-full rtl:translate-x-full"
      } xl:translate-x-0 xl:rtl:translate-x-0`}
      onMouseEnter={() => !isExpanded && setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      <div
        className={`flex py-8 ${
          !isExpanded && !isHovered ? "xl:justify-center" : "justify-start"
        }`}
      >
        <Link href="/">
          {isExpanded || isHovered || isMobileOpen ? (
            <>
              <Image
                className="dark:hidden"
                src="/images/logo/logo.svg"
                alt="Hupo"
                width={150}
                height={40}
                priority
                style={{ width: "auto", height: "auto" }}
              />
              <Image
                className="hidden dark:block"
                src="/images/logo/logo-dark.svg"
                alt="Hupo"
                width={150}
                height={40}
                priority
                style={{ width: "auto", height: "auto" }}
              />
            </>
          ) : (
            <Image
              src="/images/logo/logo-icon.svg"
              alt="Hupo"
              width={32}
              height={32}
              priority
              style={{ width: "auto", height: "auto" }}
            />
          )}
        </Link>
      </div>

      <div className="no-scrollbar flex flex-col overflow-y-auto duration-300 ease-linear">
        <nav className="mb-6">
          <div className="flex flex-col gap-4">
            <div>
              <h2
                className={`mb-4 flex text-xs leading-5 text-gray-400 uppercase ${
                  !isExpanded && !isHovered ? "xl:justify-center" : "justify-start"
                }`}
              >
                {isExpanded || isHovered || isMobileOpen ? t("groups.menu") : <HorizontaLDots />}
              </h2>
              <ul className="flex flex-col gap-1">
                {visibleItems.map((nav, index) => renderItem(nav, index))}
              </ul>
            </div>
          </div>
        </nav>
      </div>
    </aside>
  );
};

export default AppSidebar;
