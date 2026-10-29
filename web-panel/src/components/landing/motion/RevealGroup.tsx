"use client";

import { useGSAP } from "@gsap/react";
import type { HTMLAttributes, ReactNode } from "react";
import { useRef } from "react";

import { MOTION, gsap, prefersReducedMotion, registerHupoMotion } from "./gsap";

type RevealGroupProps = Omit<HTMLAttributes<HTMLElement>, "children"> & {
  as?: "div" | "ul" | "ol";
  // Varsayılan: doğrudan çocuklar. Örn. "[data-hupo-fill]" ile iç öğeler sıralı animasyonlanır.
  target?: string;
  // rise: 24 px yükselme + belirme · grow-x: soldan (RTL'de sağdan) scaleX ile çizilme (bar, ölçü).
  kind?: "rise" | "grow-x";
  children: ReactNode;
};

// Grup: görünür alana girince hedef öğeler sırayla (stagger) animasyonlanır. Bir kez oynar.
// Bölüm dosyaları server component kalır; bu sarmalayıcı children olarak sarar.
export function RevealGroup({ as = "div", target, kind = "rise", children, ...rest }: RevealGroupProps) {
  const ref = useRef<HTMLDivElement>(null);

  useGSAP(
    () => {
      const root = ref.current;
      if (!root || prefersReducedMotion()) return;
      registerHupoMotion();
      const items = target ? Array.from(root.querySelectorAll(target)) : Array.from(root.children);
      if (items.length === 0) return;
      const from = kind === "rise" ? { opacity: 0, y: MOTION.rise, duration: MOTION.reveal } : { scaleX: 0, duration: MOTION.bar };
      gsap.from(items, {
        ...from,
        ease: "hupo-out",
        stagger: MOTION.stagger,
        clearProps: "transform,opacity",
        scrollTrigger: { trigger: root, start: MOTION.trigger, once: true },
      });
    },
    { scope: ref },
  );

  // Etiket çalışma anında ul/ol olabilir; ref yalnız sorgu için kullanılır.
  const Tag = as as "div";
  return (
    <Tag ref={ref} {...rest}>
      {children}
    </Tag>
  );
}
