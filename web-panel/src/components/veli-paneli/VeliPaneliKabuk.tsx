"use client";

// Veli paneli istemci kabuğu (kenar çubuğu, başlık, duyuru). Rol kapısı sunucudaki layout.tsx'te.
// Anket kartı ana sayfaya taşındı (page.tsx, VeliAnketKapisi); burada gösterilmez (W10).

import { useSidebar } from "@/context/SidebarContext";
import VeliSidebar from "@/layout/VeliSidebar";
import VeliHeader from "@/layout/VeliHeader";
import Backdrop from "@/layout/Backdrop";
import DuyuruBandi from "@/components/duyuru/DuyuruBandi";
import React from "react";

export default function VeliPaneliKabuk({
  children,
}: {
  children: React.ReactNode;
}) {
  const { isExpanded, isHovered, isMobileOpen } = useSidebar();

  // Sidebar xl (1280 px) altında gizli; içerik boşluğu da aynı kırılımda verilir (tablet daralmasını önler).
  const mainMargin = isMobileOpen
    ? "ml-0"
    : isExpanded || isHovered
    ? "xl:ml-[290px]"
    : "xl:ml-[90px]";

  return (
    <div className="min-h-screen bg-[#f4f6f6] xl:flex dark:bg-gray-950">
      <VeliSidebar />
      <Backdrop />
      <div className="min-w-0 flex-1">
        <VeliHeader />
        <main
          id="veli-icerik"
          className={`transition-all duration-300 ease-in-out ${mainMargin} mx-auto max-w-400 p-4 pb-10 md:p-6 xl:px-8 xl:pt-8`}
        >
          <DuyuruBandi yuzey="veli_paneli" />
          {children}
        </main>
      </div>
    </div>
  );
}
