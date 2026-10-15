import type { Metadata } from "next";
import { getTranslations, setRequestLocale } from "next-intl/server";
import Image from "next/image";
import TekrarDenedButton from "./TekrarDenedButton";

// Bakım ekranı: kurumsal, sakin, suçlamayan. Arama motorlarına kapalı.
export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "meta.bakim" });
  return { title: t("title"), description: t("description"), robots: { index: false, follow: false } };
}

const VARSAYILAN_MESAJ =
  "Hupolingo'yu senin için daha iyi hale getiriyoruz. Kısa bir çalışma yapıyoruz; birkaç dakika sonra tekrar dene.";

const KAPSAM_METNI = {
  site: "Hupolingo şu an bakımda",
  veli: "Veli paneli şu an bakımda",
  yonetim: "Yönetim paneli şu an bakımda",
} as const;

type Yuzey = keyof typeof KAPSAM_METNI;

function yuzeyCoz(deger: string | string[] | undefined): Yuzey {
  const ham = Array.isArray(deger) ? deger[0] : deger;
  return ham === "veli" || ham === "yonetim" ? ham : "site";
}

type AppConfigYaniti = { bakim_modu?: { mesaj?: unknown } } | null;

// Admin'in yazdığı bakım mesajını okur. Her hata durumunda varsayılan metne düşer;
// sayfa bu fonksiyon yüzünden asla hata fırlatmaz.
async function bakimMesaji(): Promise<string> {
  try {
    const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
    const anahtar = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
    if (!url || !anahtar) return VARSAYILAN_MESAJ;

    const yanit = await fetch(`${url}/rest/v1/rpc/get_app_config`, {
      method: "POST",
      headers: {
        apikey: anahtar,
        Authorization: `Bearer ${anahtar}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({}),
      next: { revalidate: 30 },
      signal: AbortSignal.timeout(5000),
    });
    if (!yanit.ok) return VARSAYILAN_MESAJ;

    const veri = (await yanit.json()) as AppConfigYaniti;
    const mesaj = veri?.bakim_modu?.mesaj;
    return typeof mesaj === "string" && mesaj.trim() ? mesaj.trim() : VARSAYILAN_MESAJ;
  } catch {
    return VARSAYILAN_MESAJ;
  }
}

export default async function BakimSayfasi({
  searchParams,
}: {
  searchParams: Promise<{ yuzey?: string | string[] }>;
}) {
  const g = await getTranslations("gorseller");
  const { yuzey: ham } = await searchParams;
  const yuzey = yuzeyCoz(ham);
  const mesaj = await bakimMesaji();

  return (
    <main className="grid min-h-dvh place-items-center overflow-x-hidden bg-[#FFF9ED] px-4 py-6 text-[#17324D] dark:bg-[#0E2630] dark:text-[#FFF9ED]">
      <section
        aria-labelledby="bakim-baslik"
        className="w-full max-w-[420px] rounded-3xl border border-[#E4DCC8] bg-white p-6 text-center sm:p-8 dark:border-[#2A4D5A] dark:bg-[#143240]"
      >
        <div className="mx-auto size-28 overflow-hidden rounded-full motion-safe:animate-hupo-float">
          <Image
            src={g("hupo.logoIcon")}
            alt=""
            width={112}
            height={112}
            priority
            className="size-full object-cover"
          />
        </div>

        <p
          role="status"
          className="mt-5 inline-flex items-center gap-2 rounded-full bg-[#E8F5F7] px-3 py-1.5 text-sm leading-5 font-semibold text-[#0D5762] dark:bg-[#1B4250] dark:text-[#7FC9D2]"
        >
          <span
            aria-hidden="true"
            className="size-2 rounded-full bg-current motion-safe:animate-pulse"
          />
          Bakım çalışması sürüyor
        </p>

        <h1
          id="bakim-baslik"
          className="mt-4 text-2xl leading-8 font-extrabold tracking-tight"
        >
          {KAPSAM_METNI[yuzey]}
        </h1>

        <p className="mx-auto mt-3 max-w-[32ch] text-base leading-6 break-words text-[#4A6A85] dark:text-[#B9CCD3]">
          {mesaj}
        </p>

        <div className="mt-7">
          <TekrarDenedButton />
        </div>

        <p className="mt-6 text-xs leading-[18px] text-[#4A6A85] dark:text-[#B9CCD3]">
          Hupolingo
        </p>
      </section>
    </main>
  );
}
