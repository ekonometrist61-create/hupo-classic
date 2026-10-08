// Statik veri yalnızca fallback olarak kullanılır (DB boşsa)
import { CHARACTER_CLASSES } from "@/data/characters";
import { createClient } from "@/utils/supabase/server";
import { IconArrowRight } from "@/components/landing/Icons";
import { getTranslations } from "next-intl/server";
import Image from "next/image";
import Link from "next/link";

// Renk haritası — character_definitions tablosunda renk kolonu yok
const CLASS_COLORS: Record<string, string> = {
  ozgur_ruhlar:   "#6CAF45",
  firtina:        "#4EA9D9",
  kasifler:       "#F59E42",
  bozkir:         "#B07D4B",
  zihin_ustalari: "#8B5CF6",
  muhafizlar:     "#147D8A",
  ustalar:        "#F5C842",
  efsaneler:      "#6B7280",
};

const primaryBtn =
  "inline-flex min-h-12 items-center justify-center gap-2 rounded-xl bg-brand-500 px-6 py-3 text-base font-bold text-white shadow-sm transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none";

type ClassGroup = {
  kod: string;
  color: string;
  characters: { kod: string }[];
};

export async function CharacterUniverseSection() {
  const t = await getTranslations("landing");
  const classData = t.raw("characters.classes") as { kod: string; ad: string; desc: string }[];

  // DB'den karakter listesini çek (herkes okuyabilir — RLS policy açık)
  const supabase = await createClient();
  const { data: dbRows } = await supabase
    .from("character_definitions")
    .select("kod, sinif, sinif_sira, karakter_sira")
    .order("sinif_sira", { ascending: true })
    .order("karakter_sira", { ascending: true });

  // DB boşsa statik veriye düş
  let classes: ClassGroup[];

  if (!dbRows || dbRows.length === 0) {
    classes = CHARACTER_CLASSES.map((cls) => ({
      kod: cls.kod,
      color: cls.color,
      characters: cls.characters.map((c) => ({ kod: c.kod })),
    }));
  } else {
    const map = new Map<string, ClassGroup>();
    for (const row of dbRows) {
      if (!map.has(row.sinif)) {
        map.set(row.sinif, {
          kod: row.sinif,
          color: CLASS_COLORS[row.sinif] ?? "#6B7280",
          characters: [],
        });
      }
      map.get(row.sinif)!.characters.push({ kod: row.kod });
    }
    classes = Array.from(map.values());
  }

  return (
    <section
      id="characters"
      className="scroll-mt-20 overflow-hidden bg-[#0F1E2D] py-14 text-white sm:py-18 lg:py-20"
    >
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        {/* Başlık */}
        <div className="text-center">
          <p className="inline-flex rounded-full bg-white/10 px-3 py-1 text-sm font-bold text-gold-300">
            {t("characters.eyebrow")}
          </p>
          <h2 className="mt-4 text-balance text-3xl font-extrabold tracking-tight sm:text-4xl lg:text-5xl">
            {t("characters.title")}
          </h2>
          <p className="mx-auto mt-4 max-w-xl text-lg leading-relaxed text-white/70">
            {t("characters.desc")}
          </p>
        </div>

        {/* Karakter ızgarası */}
        <div className="mt-12 grid grid-cols-2 gap-4 sm:grid-cols-4 lg:grid-cols-8">
          {classes.map((cls) => {
            // Sınıf adını kod üzerinden bul (index bağımlılığından kaçın)
            const info = classData.find((d) => d.kod === cls.kod);

            return (
              <div key={cls.kod} className="flex flex-col items-center">
                {/* Sınıf başlığı */}
                <p
                  className="mb-3 text-center text-[11px] font-extrabold uppercase tracking-wide"
                  style={{ color: cls.color }}
                >
                  {info?.ad ?? cls.kod}
                </p>

                {/* Karakterler */}
                <div className="flex w-full flex-col gap-1.5">
                  {cls.characters.map((char, charIdx) => {
                    const isRevealed = charIdx === 0;
                    const imgSrc = `/characters/${cls.kod}/${char.kod}.webp`;

                    return (
                      <div
                        key={char.kod}
                        className="relative overflow-hidden rounded-xl"
                        style={{
                          background: isRevealed ? `${cls.color}22` : "rgba(255,255,255,0.04)",
                          border: isRevealed ? `1.5px solid ${cls.color}55` : "1.5px solid rgba(255,255,255,0.08)",
                        }}
                      >
                        <Image
                          src={imgSrc}
                          alt={isRevealed ? char.kod : ""}
                          width={80}
                          height={80}
                          className={`h-auto w-full object-contain transition-all ${
                            isRevealed ? "" : "brightness-0 opacity-20"
                          }`}
                        />
                        {!isRevealed && (
                          <div className="absolute inset-0 flex items-center justify-center">
                            <span className="text-base font-extrabold text-white/20">?</span>
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>

                {/* Açıklama */}
                {info && (
                  <p className="mt-2 text-center text-[9px] leading-relaxed text-white/50">
                    {info.desc}
                  </p>
                )}
              </div>
            );
          })}
        </div>

        {/* CTA */}
        <div className="mt-12 flex justify-center">
          <Link href="/signup" className={primaryBtn}>
            {t("characters.cta")}
            <IconArrowRight className="h-5 w-5" />
          </Link>
        </div>
      </div>
    </section>
  );
}
