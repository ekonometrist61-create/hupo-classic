import ComponentCard from "@/components/common/ComponentCard";
import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import BasicTableOne from "@/components/tables/BasicTableOne";
import { Metadata } from "next";
import React from "react";

export const metadata: Metadata = {
  title: "Next.js Basic Table | Hupo",
  description:
    "This is Next.js Basic Table  page for Hupo",
  // other metadata
};

export default function BasicTables() {
  return (
    <div>
      <PageBreadcrumb pageTitle="Temel Tablo" />
      <div className="space-y-6">
        <ComponentCard title="Basic Table 1">
          <BasicTableOne />
        </ComponentCard>
      </div>
    </div>
  );
}
