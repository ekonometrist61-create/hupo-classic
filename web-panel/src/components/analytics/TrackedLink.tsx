"use client";

import { trackLandingEvent, type LandingEvent } from "@/lib/analytics/events";
import Link from "next/link";
import type { ReactNode } from "react";

// Sunucu bileşenlerinden kullanılabilmesi için olay bilgisi düz metin olarak alınır.
export function TrackedLink({
  href,
  className,
  olay,
  ozellik,
  children,
}: {
  href: string;
  className?: string;
  olay: LandingEvent;
  ozellik?: Record<string, string | number>;
  children: ReactNode;
}) {
  return (
    <Link href={href} className={className} onClick={() => trackLandingEvent(olay, ozellik)}>
      {children}
    </Link>
  );
}
