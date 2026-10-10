import { getTranslations } from "next-intl/server";

// Real app colors from AppColors (mobile-app/lib/theme/app_theme.dart)
const C = {
  bg: "#FFF9ED",
  surface: "#FFFFFF",
  primary: "#147D8A",
  primarySoft: "#E8F5F7",
  sun: "#F5C842",
  sunDark: "#D9A91E",
  mint: "#2E9E62",
  mintSoft: "#E4F5EA",
  coral: "#D96A28",
  sky: "#4EA9D9",
  ink: "#17324D",
  muted: "#4A6A85",
  line: "#F0E6CF",
  lineDark: "#E0D2B0",
};

// Unicode escapes to survive any re-encoding
const E = {
  wave: "\u{1F44B}",    // 👋
  eagle: "\u{1F985}",   // 🦅
  target: "\u{1F3AF}", // 🎯
  ruler: "\u{1F4D0}",  // 📐
  book: "\u{1F4D6}",   // 📖
  micro: "\u{1F52C}",  // 🔬
  repeat: "\u{1F504}", // 🔄
  bolt: "\u{26A1}",    // ⚡
  check: "\u{2705}",   // ✅
  trophy: "\u{1F3C6}", // 🏆
  timer: "\u{23F1}",   // ⏱
};

function PhoneFrame({ children }: { children: React.ReactNode }) {
  return (
    <div
      className="relative mx-auto overflow-hidden rounded-[2.2rem] shadow-2xl"
      style={{ width: "100%", maxWidth: "220px", background: C.ink, padding: "3px" }}
    >
      <div
        style={{
          background: C.ink,
          padding: "8px 16px 4px",
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
        }}
      >
        <span style={{ color: "white", fontSize: "10px", fontWeight: 700 }}>9:41</span>
        <div style={{ width: "80px", height: "14px", background: C.ink, borderRadius: "8px" }} />
        <span style={{ color: "white", fontSize: "10px" }}>&#9679;&#9679;&#9679;</span>
      </div>
      <div
        style={{
          background: C.bg,
          borderRadius: "1.8rem",
          overflow: "hidden",
          aspectRatio: "9/19.5",
        }}
      >
        {children}
      </div>
      <div style={{ background: C.ink, padding: "6px", display: "flex", justifyContent: "center" }}>
        <div style={{ width: "48px", height: "4px", background: "rgba(255,255,255,0.3)", borderRadius: "3px" }} />
      </div>
    </div>
  );
}

function HomeScreenMock() {
  return (
    <div style={{ background: C.bg, height: "100%", display: "flex", flexDirection: "column", padding: "10px 10px 8px" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "8px" }}>
        <div>
          <p style={{ fontSize: "10px", color: C.muted, margin: 0 }}>Merhaba, Ece! {E.wave}</p>
          <p style={{ fontSize: "13px", fontWeight: 800, color: C.ink, margin: "1px 0 0" }}>
            Ne {"ö"}{"ğ"}renelim?
          </p>
        </div>
        <div style={{ width: "34px", height: "34px", borderRadius: "50%", background: C.primary, display: "flex", alignItems: "center", justifyContent: "center" }}>
          <span style={{ fontSize: "16px" }}>{E.eagle}</span>
        </div>
      </div>

      <div style={{ display: "flex", gap: "4px", marginBottom: "8px" }}>
        {[
          { label: "🔥 12", sub: "seri" },
          { label: `${E.bolt} 2.450`, sub: "XP" },
          { label: `${E.trophy} #7`, sub: "lig" },
        ].map(({ label, sub }) => (
          <div key={sub} style={{ flex: 1, background: C.surface, border: `1.5px solid ${C.line}`, borderRadius: "10px", padding: "4px 4px", textAlign: "center", boxShadow: `0 2px 0 ${C.lineDark}` }}>
            <p style={{ fontSize: "11px", fontWeight: 800, color: C.ink, margin: 0 }}>{label}</p>
            <p style={{ fontSize: "8px", color: C.muted, margin: 0 }}>{sub}</p>
          </div>
        ))}
      </div>

      <div style={{ background: C.surface, border: `1.5px solid ${C.line}`, borderRadius: "12px", padding: "8px 10px", display: "flex", alignItems: "center", gap: "8px", marginBottom: "8px", boxShadow: `0 2px 0 ${C.lineDark}` }}>
        <div style={{ position: "relative", width: "42px", height: "42px", flexShrink: 0 }}>
          <svg viewBox="0 0 42 42" style={{ width: "100%", height: "100%", transform: "rotate(-90deg)" }}>
            <circle cx="21" cy="21" r="17" fill="none" stroke={C.line} strokeWidth="5" />
            <circle cx="21" cy="21" r="17" fill="none" stroke={C.primary} strokeWidth="5" strokeDasharray={`${2 * Math.PI * 17 * 0.73} ${2 * Math.PI * 17}`} strokeLinecap="round" />
          </svg>
          <div style={{ position: "absolute", inset: 0, display: "flex", alignItems: "center", justifyContent: "center" }}>
            <span style={{ fontSize: "14px" }}>{E.target}</span>
          </div>
        </div>
        <div style={{ flex: 1 }}>
          <p style={{ fontSize: "10px", fontWeight: 800, color: C.ink, margin: 0 }}>Günlük hedef: 11/15</p>
          <div style={{ height: "5px", background: C.line, borderRadius: "4px", marginTop: "4px", overflow: "hidden" }}>
            <div style={{ width: "73%", height: "100%", background: C.primary, borderRadius: "4px" }} />
          </div>
          <p style={{ fontSize: "8px", color: C.muted, margin: "2px 0 0" }}>4 soru kald&#305;</p>
        </div>
      </div>

      <p style={{ fontSize: "9px", fontWeight: 700, color: C.muted, marginBottom: "5px", textTransform: "uppercase", letterSpacing: "0.5px" }}>Dersler</p>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "5px" }}>
        {[
          { label: "Matematik", icon: E.ruler, color: C.sky },
          { label: "Türkçe", icon: E.book, color: C.mint },
          { label: "Fen Bilimleri", icon: E.micro, color: C.coral },
          { label: "Tekrar Listesi", icon: E.repeat, color: C.sun },
        ].map(({ label, icon }) => (
          <div key={label} style={{ background: C.surface, border: `1.5px solid ${C.line}`, borderRadius: "10px", padding: "7px 6px", display: "flex", alignItems: "center", gap: "5px", boxShadow: `0 2px 0 ${C.lineDark}` }}>
            <span style={{ fontSize: "14px" }}>{icon}</span>
            <p style={{ fontSize: "9px", fontWeight: 700, color: C.ink, margin: 0, lineHeight: 1.2 }}>{label}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

function QuizScreenMock() {
  return (
    <div style={{ background: C.bg, height: "100%", display: "flex", flexDirection: "column", padding: "8px 10px" }}>
      <div style={{ display: "flex", alignItems: "center", gap: "6px", marginBottom: "6px" }}>
        <div style={{ flex: 1, height: "12px", background: C.line, borderRadius: "6px", overflow: "hidden" }}>
          <div style={{ width: "37.5%", height: "100%", background: C.mint, borderRadius: "6px" }} />
        </div>
        <div style={{ background: C.surface, border: `1.5px solid ${C.line}`, borderRadius: "14px", padding: "3px 8px", display: "flex", alignItems: "center", gap: "3px", boxShadow: `0 2px 0 ${C.lineDark}` }}>
          <span style={{ fontSize: "10px" }}>{E.timer}</span>
          <span style={{ fontSize: "10px", fontWeight: 800, color: C.primary }}>1:45</span>
        </div>
      </div>

      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "8px" }}>
        <div style={{ background: C.sun, borderRadius: "14px", padding: "3px 8px", boxShadow: `0 2px 0 ${C.sunDark}`, display: "flex", alignItems: "center", gap: "3px" }}>
          <span style={{ fontSize: "10px" }}>{E.bolt}</span>
          <span style={{ fontSize: "10px", fontWeight: 900, color: C.ink }}>+30 XP</span>
        </div>
        <span style={{ fontSize: "10px", fontWeight: 700, color: C.muted }}>Türkçe &bull; 3/8</span>
      </div>

      <div style={{ background: C.surface, border: `1.5px solid ${C.line}`, borderRadius: "14px", padding: "10px", marginBottom: "8px", boxShadow: `0 3px 0 ${C.lineDark}` }}>
        <p style={{ fontSize: "8px", fontWeight: 700, color: C.muted, textTransform: "uppercase", letterSpacing: "0.5px", margin: "0 0 5px" }}>Soru 3</p>
        <p style={{ fontSize: "11px", fontWeight: 600, color: C.ink, lineHeight: 1.5, margin: 0 }}>
          &#8220;Y&#305;ld&#305;zlar{" "}
          <strong style={{ fontWeight: 900, textDecoration: "underline", textDecorationColor: C.sun }}>parlad&#305;</strong>
          .&#8221; Alt&#305; çizili sözcük hangi soruya cevap verir?
        </p>
      </div>

      <div style={{ display: "flex", flexDirection: "column", gap: "5px" }}>
        {[
          { label: "A", text: "Ne?", selected: false },
          { label: "B", text: "Nasıl?", selected: true },
          { label: "C", text: "Ne zaman?", selected: false },
          { label: "D", text: "Kim?", selected: false },
        ].map(({ label, text, selected }) => (
          <div
            key={label}
            style={{
              background: selected ? C.primarySoft : C.surface,
              border: `1.5px solid ${selected ? C.primary : C.line}`,
              borderRadius: "10px",
              padding: "6px 8px",
              display: "flex",
              alignItems: "center",
              gap: "6px",
              boxShadow: selected ? "none" : `0 2px 0 ${C.lineDark}`,
            }}
          >
            <div style={{ width: "20px", height: "20px", borderRadius: "50%", background: selected ? C.primary : C.line, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
              <span style={{ fontSize: "9px", fontWeight: 800, color: selected ? "white" : C.muted }}>{label}</span>
            </div>
            <span
              style={{ fontSize: "10px", fontWeight: selected ? 800 : 600, color: selected ? C.primary : C.ink }}
            >
              {text}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}

function ResultScreenMock() {
  return (
    <div style={{ background: C.bg, height: "100%", display: "flex", flexDirection: "column", padding: "10px" }}>
      <div style={{ background: C.mintSoft, border: `1.5px solid ${C.mint}`, borderRadius: "14px", padding: "10px", textAlign: "center", marginBottom: "8px" }}>
        <p style={{ fontSize: "20px", margin: 0 }}>{E.check}</p>
        <p style={{ fontSize: "12px", fontWeight: 900, color: C.mint, margin: "3px 0 0" }}>Do&#287;ru!</p>
      </div>

      <div style={{ background: C.surface, border: `1.5px solid ${C.line}`, borderRadius: "12px", padding: "8px", marginBottom: "8px", boxShadow: `0 2px 0 ${C.lineDark}` }}>
        <p style={{ fontSize: "9px", fontWeight: 700, color: C.muted, textTransform: "uppercase", letterSpacing: "0.5px", margin: "0 0 4px" }}>Açıklama</p>
        <p style={{ fontSize: "10px", color: C.ink, lineHeight: 1.5, margin: 0 }}>
          &#8220;Parlad&#305;&#8221; eylemi{" "}
          <strong style={{ fontWeight: 800 }}>nas&#305;l?</strong>{" "}
          sorusuna cevap verir. Durum bildiren zarflar bu görevi üstlenir.
        </p>
      </div>

      <div style={{ background: C.surface, border: `1.5px solid ${C.line}`, borderRadius: "12px", padding: "8px", display: "flex", alignItems: "center", gap: "8px", marginBottom: "8px", boxShadow: `0 2px 0 ${C.lineDark}` }}>
        <div style={{ background: C.sun, borderRadius: "10px", width: "32px", height: "32px", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, boxShadow: `0 2px 0 ${C.sunDark}` }}>
          <span style={{ fontSize: "16px" }}>{E.bolt}</span>
        </div>
        <div>
          <p style={{ fontSize: "11px", fontWeight: 900, color: C.ink, margin: 0 }}>+15 XP kazand&#305;n</p>
          <p style={{ fontSize: "9px", color: C.muted, margin: 0 }}>Toplam: 2.465 XP</p>
        </div>
      </div>

      <div style={{ background: C.primary, borderRadius: "12px", padding: "10px", textAlign: "center", boxShadow: "0 3px 0 #0D5762" }}>
        <p style={{ fontSize: "11px", fontWeight: 800, color: "white", margin: 0 }}>Sonraki soru &#8594;</p>
      </div>
    </div>
  );
}

function LeagueScreenMock() {
  const players = [
    { name: "Ece", xp: "15.230", rank: 1 },
    { name: "Yusuf", xp: "12.450", rank: 2 },
    { name: "Sen", xp: "10.980", rank: 3, isUser: true },
    { name: "Zeynep", xp: "9.420", rank: 4 },
    { name: "Ali", xp: "8.760", rank: 5 },
  ] as { name: string; xp: string; rank: number; isUser?: boolean }[];
  const medalBg: Record<number, string> = { 1: C.sun, 2: "#C0C0C0", 3: "#CD7F32" };

  return (
    <div style={{ background: C.bg, height: "100%", display: "flex", flexDirection: "column", padding: "10px" }}>
      <div style={{ marginBottom: "8px" }}>
        <p style={{ fontSize: "14px", fontWeight: 900, color: C.ink, margin: 0 }}>{E.trophy} Ay Ligi</p>
        <p style={{ fontSize: "9px", color: C.muted, margin: "1px 0 0" }}>Bu ayki s&#305;ralama</p>
      </div>

      <div style={{ display: "flex", justifyContent: "center", alignItems: "flex-end", gap: "6px", marginBottom: "8px" }}>
        {([players[1], players[0], players[2]] as typeof players).map((p, i) => {
          const heights = ["54px", "66px", "46px"];
          const ranks = [2, 1, 3];
          return (
            <div key={p.name} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: "2px" }}>
              <span style={{ fontSize: "14px" }}>{E.eagle}</span>
              <p style={{ fontSize: "8px", fontWeight: 700, color: C.ink, margin: 0 }}>{p.name}</p>
              <div style={{ width: "44px", height: heights[i], background: medalBg[ranks[i]] ?? C.line, borderRadius: "6px 6px 0 0", display: "flex", alignItems: "center", justifyContent: "center" }}>
                <span style={{ fontSize: "14px", fontWeight: 900, color: C.ink }}>#{ranks[i]}</span>
              </div>
            </div>
          );
        })}
      </div>

      <div style={{ background: C.surface, border: `1.5px solid ${C.line}`, borderRadius: "12px", overflow: "hidden", boxShadow: `0 2px 0 ${C.lineDark}` }}>
        {players.slice(2).map((p, i) => (
          <div
            key={p.name}
            style={{
              display: "flex", alignItems: "center", gap: "7px", padding: "7px 10px",
              background: p.isUser ? C.primarySoft : "transparent",
              borderBottom: i < 2 ? `1px solid ${C.line}` : "none",
            }}
          >
            <span style={{ fontSize: "10px", fontWeight: 800, color: C.muted, width: "14px" }}>#{p.rank}</span>
            <div style={{ width: "24px", height: "24px", borderRadius: "50%", background: p.isUser ? C.primary : C.line, display: "flex", alignItems: "center", justifyContent: "center" }}>
              <span style={{ fontSize: "12px" }}>{E.eagle}</span>
            </div>
            <span style={{ flex: 1, fontSize: "10px", fontWeight: p.isUser ? 800 : 600, color: p.isUser ? C.primary : C.ink }}>{p.name}</span>
            <span style={{ fontSize: "9px", color: C.muted }}>{p.xp} XP</span>
          </div>
        ))}
      </div>
    </div>
  );
}

export async function AppScreensSection() {
  const t = await getTranslations("landing");
  const items = t.raw("appScreens.items") as { title: string; desc: string }[];
  const screens = [HomeScreenMock, QuizScreenMock, ResultScreenMock, LeagueScreenMock];

  return (
    <section
      id="app-screens"
      className="scroll-mt-20 bg-white py-8 sm:py-12 dark:bg-gray-900"
    >
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-2xl text-center">
          <p className="inline-flex items-center gap-2 rounded-full bg-brand-50 px-3 py-1 text-sm font-bold text-brand-700 dark:bg-brand-900/30 dark:text-brand-200">
            {t("appScreens.eyebrow")}
          </p>
          <h2 className="mt-4 text-balance text-3xl font-extrabold tracking-tight sm:text-4xl">
            {t("appScreens.title")}
          </h2>
          <p className="mt-3 text-lg leading-relaxed text-navy-muted dark:text-gray-300">
            {t("appScreens.desc")}
          </p>
        </div>

        <div className="mt-10 grid grid-cols-2 gap-6 sm:grid-cols-4">
          {screens.map((Screen, i) => {
            const item = items[i];
            return (
              <div key={i} className="flex flex-col items-center gap-4">
                <PhoneFrame>
                  <Screen />
                </PhoneFrame>
                {item && (
                  <div className="text-center">
                    <p className="text-sm font-extrabold text-navy dark:text-gray-100">{item.title}</p>
                    <p className="mt-0.5 text-xs leading-relaxed text-navy-muted dark:text-gray-400">{item.desc}</p>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
