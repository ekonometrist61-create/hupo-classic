"use client";

import { useState } from "react";

// Sayfayı yeniden yükler. Tarayıcı yenilemeyi engellerse buton 8 sn sonra tekrar etkinleşir.
export default function TekrarDenedButton() {
  const [kontrolEdiliyor, setKontrolEdiliyor] = useState(false);

  function handleClick() {
    setKontrolEdiliyor(true);
    window.setTimeout(() => setKontrolEdiliyor(false), 8000);
    window.location.reload();
  }

  return (
    <button
      type="button"
      onClick={handleClick}
      disabled={kontrolEdiliyor}
      aria-busy={kontrolEdiliyor}
      className="inline-flex min-h-12 w-full cursor-pointer items-center justify-center rounded-2xl bg-[#147D8A] px-5 text-base font-bold text-white transition-colors duration-150 hover:bg-[#0D5762] focus-visible:outline-3 focus-visible:outline-offset-3 focus-visible:outline-[#0D5762] enabled:active:scale-[0.98] disabled:cursor-progress disabled:opacity-60 dark:bg-[#4FB3BF] dark:text-[#0E2630] dark:hover:bg-[#7FC9D2] dark:focus-visible:outline-[#F5C842] motion-reduce:transition-none motion-reduce:enabled:active:scale-100"
    >
      {kontrolEdiliyor ? "Kontrol ediliyor…" : "Tekrar dene"}
    </button>
  );
}
