"use client";

import WelcomeSplash from "@/components/common/WelcomeSplash";
import { useSidebar } from "@/context/SidebarContext";
import AppHeader from "@/layout/AppHeader";
import AppSidebar from "@/layout/AppSidebar";
import Backdrop from "@/layout/Backdrop";
import RoleGuard from "@/layout/RoleGuard";
import React from "react";

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { isExpanded, isHovered, isMobileOpen } = useSidebar();

  // Dynamic class for main content margin based on sidebar state
  const mainContentMargin = isMobileOpen
    ? "ml-0"
    : isExpanded || isHovered
    ? "lg:ml-[290px]"
    : "lg:ml-[90px]";

  return (
    <div className="min-h-screen bg-[#f4f6f6] xl:flex dark:bg-gray-950">
      <WelcomeSplash />
      <RoleGuard />
      {/* Sidebar and Backdrop */}
      <AppSidebar />
      <Backdrop />
      {/* Main Content Area */}
      <div
        className={`flex-1 transition-all  duration-300 ease-in-out ${mainContentMargin}`}
      >
        {/* Header */}
        <AppHeader />
        {/* Page Content */}
        <main id="icerik" className="mx-auto max-w-400 p-4 pb-10 md:p-6 xl:px-8 xl:pt-8">
          {children}
        </main>
      </div>
    </div>
  );
}
