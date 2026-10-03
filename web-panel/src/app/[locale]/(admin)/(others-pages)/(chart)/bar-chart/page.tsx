import BarChartOne from "@/components/charts/bar/BarChartOne";
import ComponentCard from "@/components/common/ComponentCard";
import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import { Metadata } from "next";
import React from "react";

export const metadata: Metadata = {
  title: "Next.js Bar Chart | Hupo",
  description:
    "This is Next.js Bar Chart page for Hupo",
};

export default function page() {
  return (
    <div>
      <PageBreadcrumb pageTitle="Sütun Grafiği" />
      <div className="space-y-6">
        <ComponentCard title="Bar Chart 1">
          <BarChartOne />
        </ComponentCard>
      </div>
    </div>
  );
}
