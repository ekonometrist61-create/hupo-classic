"use client";

import type { LenisOptions } from "lenis";
import { ReactLenis, useLenis } from "lenis/react";
import type { ReactNode } from "react";
import { useEffect } from "react";

import { gsap, registerHupoMotion, ScrollTrigger } from "./gsap";

// Lenis yalnız landing'de. autoRaf kapalı: sürüş GSAP ticker'ından yapılır (Lenis + GSAP ScrollTrigger deseni).
// anchors: true. Lenis çapa hedefinde CSS scroll-margin-top'u (bölümlerde scroll-mt-20 = 80 px) zaten okur;
// ayrıca offset verilirse boşluk iki kez eklenir (ölçümle 160 px oldu). Sticky header (64 px) bu marjla kapanmaz.
// respectReducedMotion (varsayılan true): hareket tercihi "azalt" ise yumuşatma kapanır (lerp 1).
const LENIS_OPTIONS: LenisOptions = {
  autoRaf: false,
  respectReducedMotion: true,
  anchors: true,
};

// Lenis ile GSAP arasındaki köprü. Efekt temizliğinde ticker kaldırılır ve lagSmoothing varsayılana döner;
// böylece landing'den çıkınca diğer sayfalardaki GSAP davranışı sızmaz.
function ScrollBridge() {
  const lenis = useLenis();

  useEffect(() => {
    if (!lenis) return;
    registerHupoMotion();
    const onScroll = () => ScrollTrigger.update();
    const tick = (time: number) => lenis.raf(time * 1000);
    lenis.on("scroll", onScroll);
    gsap.ticker.add(tick);
    gsap.ticker.lagSmoothing(0);
    return () => {
      lenis.off("scroll", onScroll);
      gsap.ticker.remove(tick);
      gsap.ticker.lagSmoothing(500, 33);
    };
  }, [lenis]);

  return null;
}

// Landing içeriğini sarar. root modunda wrapper div eklenmez; DOM yapısı değişmez.
export function LandingMotion({ children }: { children: ReactNode }) {
  useEffect(() => {
    registerHupoMotion();
    // Web font yüklendikten sonra ScrollTrigger konumlarını yeniden hesapla (metin yüksekliği değişebilir).
    let active = true;
    document.fonts?.ready.then(() => {
      if (active) ScrollTrigger.refresh();
    });
    return () => {
      active = false;
    };
  }, []);

  return (
    <ReactLenis root options={LENIS_OPTIONS}>
      <ScrollBridge />
      {children}
    </ReactLenis>
  );
}
