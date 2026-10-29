import { getTranslations } from "next-intl/server";
import type { ReactNode } from "react";

import {
  erisimYeterliMi,
  modulErisimiGetir,
  type ModulErisimDurumu,
} from "@/lib/paket/erisim";

type Props = {
  /** Modül kodu, paket_modul / moduller ile aynı (ör. "deneme", "soru_cevap"). */
  modul: string;
  /** Bu sayfa için gereken en düşük seviye. */
  gereken: Exclude<ModulErisimDurumu, "yok">;
  children: ReactNode;
};

/**
 * Sunucu tarafı paket kapısı. Erişim yoksa çocuğu göstermez, kısa bir bilgi kartı çıkarır.
 * Oturum yoksa kapıyı açmaz; sayfanın kendi giriş yönlendirmesi zaten çalışır.
 */
export default async function ModulKapisi({ modul, gereken, children }: Props) {
  const t = await getTranslations("paketKapisi");
  const erisim = await modulErisimiGetir(modul);

  if (erisim === null) return <>{children}</>;
  if (erisimYeterliMi(erisim.erisim, gereken)) return <>{children}</>;

  return (
    <section
      role="status"
      className="mx-auto my-12 max-w-md rounded-2xl border border-gray-200 bg-white p-6 text-center dark:border-gray-800 dark:bg-gray-900"
    >
      <h2 className="text-lg font-semibold text-gray-900 dark:text-white">{t("baslik")}</h2>
      <p className="mt-2 text-sm text-gray-600 dark:text-gray-300">{t("govde")}</p>
    </section>
  );
}
