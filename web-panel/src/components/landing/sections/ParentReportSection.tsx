import { IconRepeat } from "@/components/landing/Icons";
import { getTranslations } from "next-intl/server";

const REPORT_ROWS = [
  { key: "math", solved: 8, correct: 5 },
  { key: "turkish", solved: 7, correct: 6 },
  { key: "science", solved: 3, correct: 2 },
] as const;

const MIN_EVIDENCE = 6;

export async function ParentReportSection() {
  const t = await getTranslations("landing");

  return (
    <section id="report" className="scroll-mt-20 py-8 sm:py-12">
      <div className="mx-auto grid max-w-6xl items-start gap-8 px-4 sm:px-6 lg:grid-cols-[0.8fr_1.2fr] lg:gap-14 lg:px-8">
        <div className="min-w-0">
          <h2 className="text-balance text-3xl font-extrabold tracking-tight sm:text-4xl">
            {t("report.title")}
          </h2>
          <p className="mt-4 text-lg leading-relaxed text-navy-muted dark:text-gray-300">
            {t("report.desc")}
          </p>
        </div>

        <div className="min-w-0 rounded-3xl border border-cream-dark bg-white p-5 shadow-sm sm:p-8 dark:border-gray-700 dark:bg-gray-800">
          <div className="flex flex-wrap items-center gap-3">
            <span className="rounded-full bg-warning-100 px-3 py-1 text-xs font-extrabold tracking-wide text-warning-700">
              {t("report.badge")}
            </span>
            <p className="text-sm text-navy-muted dark:text-gray-300">{t("report.disclaimer")}</p>
          </div>

          <div className="mt-6 overflow-x-auto">
            <table className="w-full min-w-[30rem] text-start text-sm sm:text-base">
              <thead>
                <tr className="border-b border-cream-dark text-navy-muted dark:border-gray-700 dark:text-gray-300">
                  <th scope="col" className="py-2 pe-3 text-start font-bold">{t("report.colSubject")}</th>
                  <th scope="col" className="py-2 pe-3 text-start font-bold">{t("report.colSolved")}</th>
                  <th scope="col" className="py-2 pe-3 text-start font-bold">{t("report.colCorrect")}</th>
                  <th scope="col" className="py-2 text-start font-bold">{t("report.colRate")}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-cream-dark dark:divide-gray-700">
                {REPORT_ROWS.map((row) => {
                  const enough = row.solved >= MIN_EVIDENCE;
                  const rate = Math.round((row.correct / row.solved) * 100);
                  return (
                    <tr key={row.key}>
                      <th scope="row" className="py-3 pe-3 text-start font-bold">
                        {t(`report.subjects.${row.key}`)}
                      </th>
                      <td className="py-3 pe-3">{row.solved}</td>
                      <td className="py-3 pe-3">{row.correct}</td>
                      <td className="py-3">
                        {enough ? (
                          <div className="flex items-center gap-3">
                            <div
                              className="h-2.5 w-24 overflow-hidden rounded-full bg-cream-dark dark:bg-gray-700"
                              aria-hidden="true"
                            >
                              <div
                                className="h-full rounded-full bg-brand-500"
                                style={{ width: `${rate}%` }}
                              />
                            </div>
                            <span className="font-extrabold">%{rate}</span>
                          </div>
                        ) : (
                          <span className="italic text-navy-muted dark:text-gray-300">
                            {t("report.insufficient")}
                          </span>
                        )}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>

          <div className="mt-6 flex items-start gap-3 rounded-2xl bg-retry-500/15 p-4">
            <IconRepeat className="mt-0.5 h-5 w-5 shrink-0 text-warning-700 dark:text-retry-400" />
            <div>
              <p className="font-extrabold">{t("report.reviewTitle")}</p>
              <p className="mt-1 leading-relaxed text-navy-muted dark:text-gray-300">
                {t("report.reviewText")}
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

