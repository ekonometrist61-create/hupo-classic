// Hupo landing hareket sistemi: GSAP kurulumu, eğriler ve ortak süreler.
// Eğri adları globals.css @theme tokenlarıyla aynı değerlere bağlıdır:
//   hupo-out   = --ease-hupo-out   (cubic-bezier(0.16, 1, 0.3, 1))
//   hupo-inout = --ease-hupo-inout (cubic-bezier(0.65, 0, 0.35, 1))
// Tüm eğri kullanımları bu iki ad üzerinden yapılır. Pop eğrisi yalnız CSS maskotunda kullanılır.
import { useGSAP } from "@gsap/react";
import { gsap } from "gsap";
import { CustomEase } from "gsap/CustomEase";
import { ScrollTrigger } from "gsap/ScrollTrigger";

// Ortak süreler: reveal 700–900 ms, kart stagger 70–100 ms, mesafe 24 px (mobilde de aynı).
export const MOTION = {
  reveal: 0.8,
  stagger: 0.08,
  rise: 24,
  bar: 0.9,
  line: 0.9,
  lineDelay: 0.3,
  trigger: "top 85%",
} as const;

let registered = false;

// Idempotent kayıt. Çocuk efektler ebeveyninden önce çalıştığı için her efekt tween'den önce çağırır.
export function registerHupoMotion() {
  if (registered) return;
  gsap.registerPlugin(ScrollTrigger, CustomEase, useGSAP);
  CustomEase.create("hupo-out", "M0,0 C0.16,1 0.3,1 1,1");
  CustomEase.create("hupo-inout", "M0,0 C0.65,0 0.35,1 1,1");
  registered = true;
}

export function prefersReducedMotion(): boolean {
  return window.matchMedia("(prefers-reduced-motion: reduce)").matches;
}

export { gsap, ScrollTrigger };
