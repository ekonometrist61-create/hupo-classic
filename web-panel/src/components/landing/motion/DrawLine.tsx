"use client";

import { useGSAP } from "@gsap/react";
import { useRef } from "react";

import { MOTION, gsap, prefersReducedMotion, registerHupoMotion } from "./gsap";

// Adımlar arası kesikli bağlayıcı: görünür alana girince scaleX ile çizilir (origin start: RTL'de sağdan).
// Konum ve görünürlük (hidden md:block) çağıranın className'inde kalır.
export function DrawLine({ className }: { className?: string }) {
  const ref = useRef<HTMLDivElement>(null);

  useGSAP(
    () => {
      const el = ref.current;
      if (!el || prefersReducedMotion()) return;
      registerHupoMotion();
      gsap.from(el, {
        scaleX: 0,
        duration: MOTION.line,
        delay: MOTION.lineDelay,
        ease: "hupo-inout",
        clearProps: "transform",
        scrollTrigger: { trigger: el, start: MOTION.trigger, once: true },
      });
    },
    { scope: ref },
  );

  return <div ref={ref} aria-hidden="true" className={`origin-left rtl:origin-right ${className ?? ""}`} />;
}
