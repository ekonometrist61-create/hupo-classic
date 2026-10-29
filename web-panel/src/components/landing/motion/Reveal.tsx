"use client";

import { useGSAP } from "@gsap/react";
import type { ReactNode } from "react";
import { useRef } from "react";

import { MOTION, gsap, prefersReducedMotion, registerHupoMotion } from "./gsap";

// Tek element: görünür alana girince 24 px yükselip belirir. once: true, yeniden oynamaz.
// Başlangıç durumu yalnız JS ile uygulanır; JS'siz ziyarette içerik doğrudan görünür.
export function Reveal({ children, className }: { children: ReactNode; className?: string }) {
  const ref = useRef<HTMLDivElement>(null);

  useGSAP(
    () => {
      const el = ref.current;
      if (!el || prefersReducedMotion()) return;
      registerHupoMotion();
      gsap.from(el, {
        opacity: 0,
        y: MOTION.rise,
        duration: MOTION.reveal,
        ease: "hupo-out",
        clearProps: "transform,opacity",
        scrollTrigger: { trigger: el, start: MOTION.trigger, once: true },
      });
    },
    { scope: ref },
  );

  return (
    <div ref={ref} className={className}>
      {children}
    </div>
  );
}
