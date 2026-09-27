import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import type { PaymentStatus } from "../types";

const COLORS = {
  basarili: "success",
  beklemede: "warning",
  basarisiz: "error",
  iade: "info",
} as const;

export default function StatusBadge({ status }: { status: PaymentStatus }) {
  const t = useTranslations("yonetim.odemeler.durum");
  return (
    <Badge size="sm" color={COLORS[status] ?? "light"}>
      {t.has(status) ? t(status) : status}
    </Badge>
  );
}
