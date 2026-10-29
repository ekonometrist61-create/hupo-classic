// Statik veri yalnızca fallback olarak kullanılır (DB boşsa)
import { TrackedLink } from "@/components/analytics/TrackedLink";
import { CHARACTER_CLASSES } from "@/data/characters";
import { landingPrimaryBtn } from "@/components/landing/buttons";
import { IconArrowRight } from "@/components/landing/Icons";
import { RevealGroup } from "@/components/landing/motion/RevealGroup";
import { SplitText } from "@/components/landing/motion/SplitText";
import { createClient } from "@/utils/supabase/server";
import { getTranslations } from "next-intl/server";
import Image from "next/image";

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

type ClassGroup = {
  kod: string;
  color: string;
  characters: { kod: string }[];
};

// Yol: sınıflar sırayla açılır (RevealGroup). Her kartta bir açık karakter ve kilitli (silik) siluetler görünür.
// XP veya süre gösterilmez; bu bölüm koleksiyonu anlatır, başarı metriği değildir.
export async function CharacterUniverseSection() {
  const t = await getTranslations("landing");
  const g = await getTranslations("gorseller");
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
      className="scroll-mt-20 overflow-hidden bg-night py-14 text-white sm:py-18 lg:py-20"
    >
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        {/* Başlık */}
        <div className="text-center">
          <p className="inline-flex rounded-full bg-white/10 px-3 py-1 text-sm font-bold text-gold-300">
            {t("characters.eyebrow")}
          </p>
          {/* Başlık kelime kelime belirir. Blok sarmalayıcı: SplitText inline-block olduğu için etiketle aynı satıra düşmez. */}
          <div className="mt-4">
            <SplitText
              text={t("characters.title")}
              tag="h2"
              textAlign="center"
              splitType="words"
              effect="rise"
              trigger="view"
              from={{ opacity: 0, y: 24 }}
              to={{ opacity: 1, y: 0 }}
              delay={70}
              duration={0.8}
              ease="hupo-out"
              className="-my-2 py-2 text-balance text-3xl font-extrabold tracking-tight sm:text-4xl lg:text-5xl"
            />
            <noscript>
              <style>{".split-parent{visibility:visible!important}"}</style>
            </noscript>
          </div>
          <p className="mx-auto mt-4 max-w-xl text-lg leading-relaxed text-white/70">
            {t("characters.desc")}
          </p>
        </div>

        {/* Yol: sekiz sınıf kartı, soldan sağa */}
        <RevealGroup as="ol" className="mt-12 grid grid-cols-2 gap-3 sm:grid-cols-4 lg:grid-cols-8">
          {classes.map((cls) => {
            const info = classData.find((d) => d.kod === cls.kod);
            const [acik, ...kilitli] = cls.characters;

            return (
              <li
                key={cls.kod}
                style={{
                  background: `${cls.color}1f`,
                  borderColor: `${cls.color}55`,
                }}
                className="flex flex-col rounded-2xl border p-3"
              >
                <p
                  className="text-center text-xs font-extrabold uppercase tracking-wide"
                  style={{ color: cls.color }}
                >
                  {info?.ad ?? cls.kod}
                </p>

                {/* Açık karakter */}
                <div className="mt-3 flex justify-center">
                  {acik && (
                    <Image
                      src={g(`karakter.${cls.kod}.${acik.kod}`)}
                      alt=""
                      width={96}
                      height={96}
                      sizes="80px"
                      className="h-20 w-20 object-contain"
                    />
                  )}
                </div>

                {/* Kilitli karakterler: silik siluet */}
                {kilitli.length > 0 && (
                  <div className="mt-2 flex justify-center gap-1.5" aria-hidden="true">
                    {kilitli.slice(0, 3).map((c) => (
                      <Image
                        key={c.kod}
                        src={g(`karakter.${cls.kod}.${c.kod}`)}
                        alt=""
                        width={40}
                        height={40}
                        sizes="24px"
                        className="h-6 w-6 object-contain brightness-0 opacity-25"
                      />
                    ))}
                  </div>
                )}

                {info && (
                  <p className="mt-3 text-center text-xs leading-relaxed text-white/60">
                    {info.desc}
                  </p>
                )}
              </li>
            );
          })}
        </RevealGroup>

        {/* CTA */}
        <div className="mt-12 flex justify-center">
          <TrackedLink
            href="/veli-paneli/kayit"
            olay="veli_kayit_baslatildi"
            ozellik={{ konum: "karakterler" }}
            className={landingPrimaryBtn}
          >
            {t("characters.cta")}
            <IconArrowRight className="h-5 w-5" />
          </TrackedLink>
        </div>
      </div>
    </section>
  );
}
