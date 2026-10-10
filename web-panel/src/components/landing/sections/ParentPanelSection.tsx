import { getTranslations } from "next-intl/server";
import Link from "next/link";

// Colors matching the real parent panel (TailAdmin-based light theme)
const P = {
  bg: "#F9FAFB",
  card: "#FFFFFF",
  border: "#E5E7EB",
  ink: "#111928",
  muted: "#6B7280",
  brand: "#147D8A",
  brandSoft: "#E8F5F7",
  success: "#16A34A",
  successSoft: "#F0FDF4",
  warning: "#D97706",
  warnSoft: "#FFFBEB",
  error: "#DC2626",
  errorSoft: "#FEF2F2",
  sun: "#F5C842",
};

function StatCard({ label, value, hint, color }: { label: string; value: string; hint?: string; color?: string }) {
  return (
    <div style={{ background: P.card, border: `1px solid ${P.border}`, borderRadius: "12px", padding: "16px 20px" }}>
      <p style={{ fontSize: "12px", color: P.muted, margin: 0 }}>{label}</p>
      <div style={{ display: "flex", alignItems: "flex-end", gap: "6px", marginTop: "6px" }}>
        <p style={{ fontSize: "22px", fontWeight: 800, color: color ?? P.ink, margin: 0, lineHeight: 1 }}>{value}</p>
        {hint && <p style={{ fontSize: "11px", color: P.muted, margin: "0 0 2px" }}>{hint}</p>}
      </div>
    </div>
  );
}

interface SubjectBar { label: string; pct: number; color: string }
const subjectBars: SubjectBar[] = [
  { label: "Türkçe", pct: 82, color: P.success },
  { label: "Matematik", pct: 58, color: P.warning },
  { label: "Fen Bilimleri", pct: 44, color: P.error },
  { label: "Sosyal Bilgiler", pct: 71, color: P.success },
];

interface ReviewRow { konu: string; ders: string; yanlis: number; pct: number | null }
const reviewRows: ReviewRow[] = [
  { konu: "Kesirler", ders: "Matematik", yanlis: 5, pct: 40 },
  { konu: "Ses Olayları", ders: "Türkçe", yanlis: 3, pct: 67 },
  { konu: "Madde ve Özellikleri", ders: "Fen", yanlis: 4, pct: 25 },
];

function badgeStyle(pct: number | null): { bg: string; color: string; text: string } {
  if (pct === null) return { bg: P.border, color: P.muted, text: "-" };
  if (pct >= 70) return { bg: P.successSoft, color: P.success, text: `%${pct}` };
  if (pct >= 40) return { bg: P.warnSoft, color: P.warning, text: `%${pct}` };
  return { bg: P.errorSoft, color: P.error, text: `%${pct}` };
}

export async function ParentPanelSection() {
  const t = await getTranslations("landing.report");

  return (
    <section id="report" className="scroll-mt-20 py-8 sm:py-12 lg:py-14">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="lg:grid lg:grid-cols-[1fr_1.6fr] lg:gap-14 lg:items-start">
          {/* Sol: Açıklama */}
          <div>
            <h2 className="text-balance text-3xl font-extrabold tracking-tight sm:text-4xl">
              {t("title")}
            </h2>
            <p className="mt-4 text-lg leading-relaxed text-navy-muted dark:text-gray-300">
              {t("desc")}
            </p>
            <p className="mt-4 inline-flex items-center gap-2 rounded-full bg-warning-100 px-3 py-1 text-xs font-bold text-warning-700">
              {t("badge")} — {t("disclaimer")}
            </p>
            <div className="mt-6">
              <Link
                href="/signup"
                className="inline-flex min-h-11 items-center justify-center gap-2 rounded-xl bg-brand-500 px-5 py-2.5 text-sm font-bold text-white transition-colors hover:bg-brand-600"
              >
                Veli Hesabı Oluştur
              </Link>
            </div>
          </div>

          {/* Sağ: Panel Mockup */}
          <div
            style={{ background: P.bg, borderRadius: "16px", border: `1px solid ${P.border}`, padding: "16px", marginTop: "2rem" }}
            className="lg:mt-0"
          >
            {/* Öğrenci seçici */}
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "12px" }}>
              <div>
                <p style={{ fontSize: "11px", color: P.muted, margin: 0 }}>Öğrenci</p>
                <p style={{ fontSize: "14px", fontWeight: 800, color: P.ink, margin: 0 }}>Ece Yılmaz</p>
              </div>
              <div style={{ background: P.card, border: `1px solid ${P.border}`, borderRadius: "8px", padding: "4px 12px", fontSize: "11px", color: P.muted }}>
                Son 7 gün
              </div>
            </div>

            {/* Stat kartlar */}
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "8px", marginBottom: "12px" }}>
              <StatCard label="Toplam XP" value="2.450" hint="Seviye 8" color={P.brand} />
              <StatCard label="Günlük Seri" value="12" hint="gün" color={P.sun} />
              <StatCard label="Bu Hafta" value="47" hint="dk" />
              <StatCard label="Çözülen Soru" value="124" />
            </div>

            {/* Konu başarı */}
            <div style={{ background: P.card, border: `1px solid ${P.border}`, borderRadius: "12px", padding: "12px", marginBottom: "10px" }}>
              <p style={{ fontSize: "12px", fontWeight: 700, color: P.ink, margin: "0 0 10px" }}>Ders Başarısı</p>
              <div style={{ display: "flex", flexDirection: "column", gap: "7px" }}>
                {subjectBars.map(({ label, pct, color }) => (
                  <div key={label}>
                    <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "3px" }}>
                      <span style={{ fontSize: "10px", fontWeight: 600, color: P.ink }}>{label}</span>
                      <span style={{ fontSize: "10px", fontWeight: 700, color }}>{pct}%</span>
                    </div>
                    <div style={{ height: "7px", background: P.border, borderRadius: "4px", overflow: "hidden" }}>
                      <div style={{ width: `${pct}%`, height: "100%", background: color, borderRadius: "4px" }} />
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Tekrar listesi */}
            <div style={{ background: P.card, border: `1px solid ${P.border}`, borderRadius: "12px", padding: "12px" }}>
              <p style={{ fontSize: "12px", fontWeight: 700, color: P.ink, margin: "0 0 8px" }}>Tekrar Önerileri</p>
              <table style={{ width: "100%", borderCollapse: "collapse", fontSize: "10px" }}>
                <thead>
                  <tr style={{ borderBottom: `1px solid ${P.border}` }}>
                    {["Konu", "Ders", "Yanlış", "%"].map((h) => (
                      <th key={h} style={{ textAlign: "left", padding: "4px 6px 6px 0", fontWeight: 600, color: P.muted }}>{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {reviewRows.map((row) => {
                    const badge = badgeStyle(row.pct);
                    return (
                      <tr key={row.konu} style={{ borderBottom: `1px solid ${P.border}` }}>
                        <td
                          style={{ padding: "5px 6px 5px 0", fontWeight: 600, color: P.ink }}
                        >
                          {row.konu}
                        </td>
                        <td style={{ padding: "5px 6px 5px 0", color: P.muted }}>{row.ders}</td>
                        <td style={{ padding: "5px 6px 5px 0", color: P.ink }}>{row.yanlis}</td>
                        <td style={{ padding: "5px 0 5px 0" }}>
                          <span style={{ background: badge.bg, color: badge.color, borderRadius: "6px", padding: "1px 5px", fontWeight: 700, fontSize: "9px" }}>
                            {badge.text}
                          </span>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
