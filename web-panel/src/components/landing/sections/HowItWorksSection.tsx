import { getTranslations } from "next-intl/server";

// Unicode escapes to survive any re-encoding: phone=📲 books=📚 trophy=🏆
const STEP_EMOJIS = ["\u{1F4F2}", "\u{1F4DA}", "\u{1F3C6}"];
const STEP_COLORS = [
  "bg-green-100 dark:bg-green-900/30",
  "bg-blue-100 dark:bg-blue-900/30",
  "bg-gold-100 dark:bg-gold-900/30",
];

export async function HowItWorksSection() {
  const t = await getTranslations("landing.how");
  const steps = t.raw("steps") as { title: string; desc: string }[];

  return (
    <section id="how-it-works" className="scroll-mt-20 py-8 sm:py-12 lg:py-14">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <h2 className="text-center text-3xl font-extrabold tracking-tight sm:text-4xl">
          {t("title")}
        </h2>

        <div className="mt-12 grid gap-8 md:grid-cols-3">
          {steps.map((step, i) => (
            <div key={step.title} className="relative flex flex-col items-center text-center">
              {i < steps.length - 1 && (
                <div className="absolute start-[calc(50%+3rem)] top-10 hidden w-[calc(100%-6rem)] border-t-2 border-dashed border-navy/20 md:block dark:border-gray-700" />
              )}

              <div className="relative">
                <div
                  className={`flex h-20 w-20 items-center justify-center rounded-2xl text-4xl ${STEP_COLORS[i]}`}
                >
                  {STEP_EMOJIS[i]}
                </div>
                <span className="absolute -end-2 -top-2 flex h-7 w-7 items-center justify-center rounded-full bg-gold-500 text-sm font-extrabold text-navy shadow-sm">
                  {i + 1}
                </span>
              </div>

              <h3 className="mt-6 text-xl font-extrabold">{step.title}</h3>
              <p className="mt-2 max-w-xs leading-relaxed text-navy-muted dark:text-gray-300">
                {step.desc}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
