import { CountdownTimer } from "@/components/landing/CountdownTimer";
import { IconArrowRight, IconCalendar, IconCheckCircle } from "@/components/landing/Icons";
import { createClient } from "@/utils/supabase/server";
import { getTranslations } from "next-intl/server";
import Link from "next/link";

const FALLBACK_EXAM_DATE = new Date("2026-11-15T06:00:00.000Z");

async function fetchExamDate(): Promise<Date> {
  try {
    const supabase = await createClient();
    const { data, error } = await supabase
      .from("app_settings")
      .select("value")
      .eq("key", "deneme_sinavi_tarihi")
      .single();
    if (error || !data) return FALLBACK_EXAM_DATE;
    const parsed = JSON.parse(data.value);
    const date = new Date(parsed);
    if (isNaN(date.getTime())) return FALLBACK_EXAM_DATE;
    return date;
  } catch {
    return FALLBACK_EXAM_DATE;
  }
}

export async function DenemeExamSection() {
  const t = await getTranslations("landing.denemeExam");
  const steps = t.raw("steps") as { title: string; desc: string }[];
  const labels = t.raw("countdown") as {
    days: string;
    hours: string;
    minutes: string;
    seconds: string;
    started: string;
  };

  const examDate = await fetchExamDate();

  return (
    <section
      id="deneme-sinavi"
      className="scroll-mt-20 overflow-hidden bg-[#0F1E2D] py-14 text-white sm:py-18 lg:py-20"
    >
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        {/* Başlık */}
        <div className="text-center">
          <p className="inline-flex items-center gap-2 rounded-full bg-white/10 px-3 py-1 text-sm font-bold text-gold-300">
            <IconCalendar className="h-4 w-4" />
            {t("eyebrow")}
          </p>
          <h2 className="mt-4 text-balance text-3xl font-extrabold tracking-tight sm:text-4xl lg:text-5xl">
            {t("title")}
          </h2>
          <p className="mx-auto mt-4 max-w-xl text-lg leading-relaxed text-white/70">
            {t("desc")}
          </p>
        </div>

        {/* Geri sayım */}
        <div className="mt-10 flex justify-center">
          <CountdownTimer targetDate={examDate} labels={labels} />
        </div>

        {/* 3 adım */}
        <div className="mt-12 grid gap-6 sm:grid-cols-3">
          {steps.map((step, i) => (
            <div
              key={step.title}
              className="flex flex-col items-start gap-3 rounded-2xl border border-white/10 bg-white/5 p-6"
            >
              <span className="flex h-10 w-10 items-center justify-center rounded-full bg-gold-500 text-lg font-extrabold text-navy">
                {i + 1}
              </span>
              <h3 className="text-lg font-extrabold">{step.title}</h3>
              <p className="leading-relaxed text-white/70">{step.desc}</p>
            </div>
          ))}
        </div>

        {/* CTA */}
        <div className="mt-10 flex flex-col items-center gap-4">
          <Link
            href="/signup"
            className="inline-flex min-h-12 items-center justify-center gap-2 rounded-xl bg-gold-500 px-8 py-3 text-base font-extrabold text-navy shadow-sm transition-colors hover:bg-gold-400 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-gold-400 motion-reduce:transition-none"
          >
            {t("cta")}
            <IconArrowRight className="h-5 w-5" />
          </Link>
          <p className="flex items-center gap-2 text-sm text-white/60">
            <IconCheckCircle className="h-4 w-4 text-brand-300" />
            {t("note")}
          </p>
        </div>
      </div>
    </section>
  );
}
