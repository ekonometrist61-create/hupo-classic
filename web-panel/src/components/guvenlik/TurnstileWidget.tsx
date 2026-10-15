"use client";

import { useEffect, useRef } from "react";

// Cloudflare Turnstile görünmez/otomatik widget'ı. Token üretilemezse onToken(null) çağrılır.
// Site anahtarı: NEXT_PUBLIC_TURNSTILE_SITE_KEY. Yoksa widget çizilmez ve form gönderilemez
// (Edge Function de gizli anahtar yokken reddeder — fail-closed).

const SCRIPT_SRC = "https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit";

type TurnstileApi = {
  render: (
    el: HTMLElement,
    opts: {
      sitekey: string;
      callback: (token: string) => void;
      "expired-callback": () => void;
      "error-callback": () => void;
    },
  ) => string;
  remove: (widgetId: string) => void;
};

declare global {
  interface Window {
    turnstile?: TurnstileApi;
  }
}

function scriptYukle(): Promise<void> {
  return new Promise((resolve, reject) => {
    if (window.turnstile) return resolve();
    const mevcut = document.querySelector<HTMLScriptElement>(`script[src="${SCRIPT_SRC}"]`);
    if (mevcut) {
      mevcut.addEventListener("load", () => resolve());
      mevcut.addEventListener("error", () => reject(new Error("turnstile")));
      return;
    }
    const s = document.createElement("script");
    s.src = SCRIPT_SRC;
    s.async = true;
    s.onload = () => resolve();
    s.onerror = () => reject(new Error("turnstile"));
    document.head.appendChild(s);
  });
}

interface Props {
  onToken: (token: string | null) => void;
  // Değiştiğinde widget yeniden çizilir (tek kullanımlık token sonrası).
  resetKey: number;
}

export function TurnstileWidget({ onToken, resetKey }: Props) {
  const ref = useRef<HTMLDivElement>(null);
  const siteKey = process.env.NEXT_PUBLIC_TURNSTILE_SITE_KEY;

  useEffect(() => {
    if (!siteKey || !ref.current) {
      onToken(null);
      return;
    }
    let widgetId: string | null = null;
    let iptal = false;
    const el = ref.current;
    el.innerHTML = "";

    scriptYukle()
      .then(() => {
        if (iptal || !window.turnstile) return;
        widgetId = window.turnstile.render(el, {
          sitekey: siteKey,
          callback: (token) => onToken(token),
          "expired-callback": () => onToken(null),
          "error-callback": () => onToken(null),
        });
      })
      .catch(() => onToken(null));

    return () => {
      iptal = true;
      if (widgetId && window.turnstile) {
        try {
          window.turnstile.remove(widgetId);
        } catch {
          /* widget zaten kaldırılmış olabilir */
        }
      }
    };
    // onToken kararlı bir çağrı değil; yalnızca anahtar ve resetKey'e göre yeniden çiz.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [siteKey, resetKey]);

  if (!siteKey) return null;
  return <div ref={ref} className="min-h-[65px]" />;
}
