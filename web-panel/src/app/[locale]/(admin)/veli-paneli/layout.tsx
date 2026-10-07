"use client";

import { useSidebar } from "@/context/SidebarContext";
import VeliSidebar from "@/layout/VeliSidebar";
import Backdrop from "@/layout/Backdrop";
import React from "react";

export default function VeliPaneliLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { isExpanded, isHovered, isMobileOpen } = useSidebar();

  const mainMargin = isMobileOpen
    ? "ml-0"
    : isExpanded || isHovered
    ? "lg:ml-[290px]"
    : "lg:ml-[90px]";

  return (
    <div className="min-h-screen bg-[#f4f6f6] xl:flex dark:bg-gray-950">
      <VeliSidebar />
      <Backdrop />
      <main
        id="veli-icerik"
        className={`flex-1 transition-all duration-300 ease-in-out ${mainMargin} mx-auto max-w-400 p-4 pb-10 md:p-6 xl:px-8 xl:pt-8`}
      >
        {children}
      </main>
    </div>
  );
}
