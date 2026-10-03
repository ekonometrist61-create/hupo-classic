import Calendar from "@/components/calendar/Calendar";
import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import "@fullcalendar/react/skeleton.css";
import "@fullcalendar/react/themes/classic/palette.css";
import "@fullcalendar/react/themes/classic/theme.css";

import { Metadata } from "next";

export const metadata: Metadata = {
  title: "Next.js Calender | Hupo",
  description:
    "This is Next.js Calender page for Hupo",
  // other metadata
};
export default function page() {
  return (
    <div>
      <PageBreadcrumb pageTitle="Takvim" />
      <Calendar />
    </div>
  );
}
