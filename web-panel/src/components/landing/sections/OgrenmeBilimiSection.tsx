import { IconBook, IconRepeat, IconSteps, IconTimer } from "@/components/landing/Icons";
import { Reveal } from "@/components/landing/motion/Reveal";
import { RevealGroup } from "@/components/landing/motion/RevealGroup";
import { KAYNAKLAR } from "@/components/landing/yontem/kaynaklar";
import { getTranslations } from "next-intl/server";
import type { ComponentType, SVGProps } from "react";

// "Hupo neden böyle çalışıyor?" — her ilke iki ayrı satırla anlatılır:
//   "Hupo'da" = ürünün gerçek davranışı (kodla doğrulandı), "Araştırmalar" = yalnız kaynaklar.ts'teki kaynaklar.
// Akademik bulgu (g/d değerleri) ürün şemasına konmaz; ayrıntı ve sınırlar /yontem sayfasındadır.
// "Kaynakları kendiniz inceleyin" şeridi (kaynak sayısı, /yontem bağlantısı, dipnot) bu bölümden kaldırıldı (2026-11-14 kararı).
// Ürün kaynakları:
//   - Tekrar takvimi: submit_answer SM-2 (supabase/migrations/20261009000000_gorevler.sql):
//     yanlış → 1 gün; doğru → 1 gün, 6 gün, sonra aralık × kolaylık katsayısı.
//   - Önce cevap, sonra çözüm: mobile-app/lib/widgets/result_sheet.dart (cevap sunucuda kontrol edilir).
//   - Günlük hedef 5/10/15/20, varsayılan 10: mobile-app/lib/models/privacy_models.dart, get_daily_goal.
// Kaynağı olmayan ilke "Tasarım tercihimiz" olarak etiketlenir; araştırma iddiası yazılmaz.

type Icon = ComponentType<SVGProps<SVGSVGElement>>;
type IlkeId = "geriCagirma" | "aciklama" | "kisa";

const ILKELER: { id: IlkeId; icon: Icon; kaynaklar: string[]; ton: string }[] = [
  {
    id: "geriCagirma",
    icon: IconBook,
    kaynaklar: ["ruitenburg2026"],
    ton: "bg-brand-50 text-brand-700 dark:bg-brand-900/40 dark:text-brand-200",
  },
  {
    id: "aciklama",
    icon: IconSteps,
    kaynaklar: [],
    ton: "bg-gold-100 text-gold-900 dark:bg-gold-900/30 dark:text-gold-200",
  },
  {
    id: "kisa",
    icon: IconTimer,
    kaynaklar: [],
    ton: "bg-success-50 text-success-700 dark:bg-success-500/15 dark:text-success-300",
  },
];

const TEKRAR_KAYNAKLARI = ["ruitenburg2026", "mawson2025"];

function atiflar(ids: string[]): string {
  return ids
    .map((id) => KAYNAKLAR.find((k) => k.id === id)?.atif)
    .filter(Boolean)
    .join("; ");
}

const ETIKET_TABAN = "inline-flex rounded-full px-2.5 py-0.5 text-xs font-extrabold uppercase tracking-wider";
const ETIKET_HUPO = `${ETIKET_TABAN} bg-brand-50 text-brand-700 dark:bg-brand-900/50 dark:text-brand-200`;
const ETIKET_ARASTIRMA = `${ETIKET_TABAN} bg-gold-100 text-gold-900 dark:bg-gold-900/40 dark:text-gold-200`;
const ETIKET_TASARIM = `${ETIKET_TABAN} bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-300`;

// Tekrar takvimi çizimi: aralıklar büyüyerek çizilir (2 : 3 : 5); gerçek gün oranı değildir, "örnek" olarak etiketlenir.
async function TekrarTakvimi() {
  const t = await getTranslations("landing.ogrenmeBilimi.tekrar.takvim");
  const araliklar = [
    { etiket: t("aralik1"), oran: "flex-[2]" },
    { etiket: t("aralik2"), oran: "flex-[3]" },
    { etiket: t("aralik3"), oran: "flex-[5]" },
  ];
  const duraklar = [t("bugun"), t("tekrar1"), t("tekrar2"), t("tekrar3")];
  const ortala = "start-1/2 -translate-x-1/2 rtl:translate-x-1/2";
  const hiza = ["start-0", ortala, ortala, "end-0"];

  return (
    <figure className="rounded-2xl border border-brand-100 bg-brand-25 p-4 sm:p-6 dark:border-brand-900/60 dark:bg-brand-950/40">
      <figcaption className="text-sm font-extrabold text-navy dark:text-gray-100">{t("baslik")}</figcaption>

      {/* Görsel çizim; ekran okuyucu özeti aria-label'dan okur. */}
      <div role="img" aria-label={t("ozet")} className="px-1 pb-10 pt-9">
        <RevealGroup kind="grow-x" target="[data-hupo-fill]" className="flex items-center">
          {duraklar.map((durak, i) => (
            <div key={durak} className="contents">
              <div className="relative shrink-0">
                <span
                  className={`block h-4 w-4 rounded-full ring-4 ${
                    i === 0
                      ? "bg-gold-500 ring-gold-100 dark:ring-gold-900/50"
                      : "bg-brand-500 ring-brand-100 dark:bg-brand-400 dark:ring-brand-900/60"
                  }`}
                />
                <span
                  className={`absolute top-full mt-3 whitespace-nowrap text-xs font-bold text-navy sm:text-sm dark:text-gray-100 ${hiza[i]}`}
                >
                  {durak}
                </span>
              </div>
              {i < araliklar.length ? (
                <div className={`relative mx-1 h-1.5 rounded-full bg-cream-dark dark:bg-gray-700 ${araliklar[i].oran}`}>
                  <span
                    data-hupo-fill
                    className="absolute inset-0 origin-left rounded-full bg-brand-500 rtl:origin-right dark:bg-brand-400"
                  />
                  <span
                    className={`absolute bottom-full mb-2.5 whitespace-nowrap text-xs font-extrabold text-brand-700 sm:text-sm dark:text-brand-200 ${ortala}`}
                  >
                    {araliklar[i].etiket}
                  </span>
                </div>
              ) : null}
            </div>
          ))}
        </RevealGroup>
      </div>

      <p className="flex items-start gap-2 rounded-xl bg-white px-3 py-2.5 text-sm leading-relaxed text-navy dark:bg-gray-900 dark:text-gray-200">
        <IconRepeat className="mt-0.5 h-4 w-4 shrink-0 text-gold-700 dark:text-gold-300" />
        <span>{t("yanlis")}</span>
      </p>
      <p className="mt-2 text-xs leading-relaxed text-navy-muted dark:text-gray-400">{t("not")}</p>
    </figure>
  );
}

export async function OgrenmeBilimiSection() {
  const t = await getTranslations("landing.ogrenmeBilimi");

  return (
    <section
      id="ogrenme-bilimi"
      aria-labelledby="ogrenme-bilimi-baslik"
      className="scroll-mt-20 bg-cream py-6 text-navy sm:py-8 lg:py-10 dark:bg-gray-950 dark:text-gray-100"
    >
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="grid gap-4 lg:grid-cols-2 lg:items-end lg:gap-12">
          <div>
            <p className="text-sm font-extrabold uppercase tracking-wider text-brand-700 dark:text-brand-300">
              {t("etiket")}
            </p>
            <h2
              id="ogrenme-bilimi-baslik"
              className="mt-2 text-balance text-3xl font-extrabold tracking-tight sm:text-4xl"
            >
              {t("baslik")}
            </h2>
          </div>
          <p className="max-w-xl text-lg leading-relaxed text-navy-muted dark:text-gray-300">{t("giris")}</p>
        </div>

        {/* Öne çıkan ilke: aralıklı tekrar + ürünün gerçek tekrar takvimi */}
        <Reveal className="mt-8 sm:mt-10">
          <article className="grid gap-6 rounded-3xl border border-cream-dark bg-white p-5 shadow-sm sm:p-8 lg:grid-cols-[1fr_1.15fr] lg:items-center lg:gap-10 dark:border-gray-800 dark:bg-gray-900">
            <div>
              <div className="flex items-center gap-3">
                <span className="inline-flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-brand-500 text-white">
                  <IconRepeat className="h-6 w-6" />
                </span>
                <h3 className="text-xl font-extrabold leading-snug sm:text-2xl">{t("tekrar.baslik")}</h3>
              </div>
              <dl className="mt-5 space-y-4">
                <div>
                  <dt className={ETIKET_HUPO}>{t("etiketHupoda")}</dt>
                  <dd className="mt-2 leading-relaxed text-navy dark:text-gray-100">{t("tekrar.hupoda")}</dd>
                </div>
                <div className="border-t border-cream-dark pt-4 dark:border-gray-800">
                  <dt className={ETIKET_ARASTIRMA}>{t("etiketArastirma")}</dt>
                  <dd className="mt-2 leading-relaxed text-navy-muted dark:text-gray-300">{t("tekrar.arastirma")}</dd>
                  <dd className="mt-2 text-xs leading-relaxed text-navy-muted dark:text-gray-400">
                    {t("kaynakOnEki")}: {atiflar(TEKRAR_KAYNAKLARI)}
                  </dd>
                </div>
              </dl>
            </div>
            <TekrarTakvimi />
          </article>
        </Reveal>

        <RevealGroup as="ul" className="mt-6 grid gap-6 md:grid-cols-3">
          {ILKELER.map(({ id, icon: Icon, kaynaklar, ton }) => (
            <li
              key={id}
              className="flex flex-col rounded-3xl border border-cream-dark bg-white p-5 shadow-sm transition-shadow duration-300 ease-hupo-out hover:shadow-lg motion-reduce:transition-none sm:p-6 dark:border-gray-800 dark:bg-gray-900"
            >
              <span className={`inline-flex h-11 w-11 items-center justify-center rounded-xl ${ton}`}>
                <Icon className="h-6 w-6" />
              </span>
              <h3 className="mt-4 text-lg font-extrabold leading-snug">{t(`ilkeler.${id}.baslik`)}</h3>
              <dl className="mt-4 flex flex-1 flex-col gap-4">
                <div>
                  <dt className={ETIKET_HUPO}>{t("etiketHupoda")}</dt>
                  <dd className="mt-2 leading-relaxed text-navy dark:text-gray-100">{t(`ilkeler.${id}.hupoda`)}</dd>
                </div>
                <div className="mt-auto border-t border-cream-dark pt-4 dark:border-gray-800">
                  {kaynaklar.length > 0 ? (
                    <>
                      <dt className={ETIKET_ARASTIRMA}>{t("etiketArastirma")}</dt>
                      <dd className="mt-2 text-sm leading-relaxed text-navy-muted dark:text-gray-300">
                        {t(`ilkeler.${id}.arastirma`)}
                      </dd>
                      <dd className="mt-2 text-xs leading-relaxed text-navy-muted dark:text-gray-400">
                        {t("kaynakOnEki")}: {atiflar(kaynaklar)}
                      </dd>
                    </>
                  ) : (
                    <>
                      <dt className={ETIKET_TASARIM}>{t("etiketTasarim")}</dt>
                      <dd className="mt-2 text-sm leading-relaxed text-navy-muted dark:text-gray-300">
                        {t("tasarimNot")}
                      </dd>
                    </>
                  )}
                </div>
              </dl>
            </li>
          ))}
        </RevealGroup>
      </div>
    </section>
  );
}
