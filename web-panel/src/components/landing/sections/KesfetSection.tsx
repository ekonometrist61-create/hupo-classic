import { RevealGroup } from "@/components/landing/motion/RevealGroup";
import { getTranslations } from "next-intl/server";
import Image from "next/image";

// Çarpım Şifreleri, Kelime Evreni ve Arena: çalışmanın içindeki keşif alanları.
// Konumlandırma (ajan önerisi, kullanıcı onayı bekliyor): "Senin Hikâyen" değer çıpasıdır (veli neyle karşılaştıracağını görür),
// bu üç alan ise çocuğun kendi isteğiyle açtığı merak alanlarıdır. Pazarlama metninde bu terimler geçmez.
// Çarpım ve Kelime görselleri uygulamanın gerçek ekranlarıdır (maskot/illüstrasyon değil); kırpma yalnız durum çubuğu ve alt gezinmeyi dışarıda bırakır.
// Arena görseli özel çizilmiş düello kompozisyonudur (ekran görüntüsü değil): arkadaşa meydan okuma gerçek ekranda
// anlaşılmadığı için burada Sen / VS / Arkadaşın olarak gösterilir ve "Yakında" etiketi taşır (arena_screen.dart: arkadaşla yarışma yakında).
// Ay Ligi ve Günün 5 Sorusu uygulamadaki gerçek özellik adlarıdır.
// Durum rozetleri koddaki/belgedeki gerçek duruma bağlıdır (K-0215, GÖR-091, arena_screen.dart); hazır olmayan "Yakında" yazar.
// Çocuğa satış, ödül baskısı, süre dayatması yok; metrik öğrenmedir (XP/sıra değil).
const KARTLAR = [
  { key: "carpim", image: "/landing/ekran/carpim.webp", h: 1004, durum: "erken" },
  { key: "kelime", image: "/landing/ekran/kelime.webp", h: 498, durum: "yakinda" },
  { key: "arena", image: null, h: 0, durum: "erken" },
] as const;

const IKON = "/landing/ikon/ikon-";
const KARAKTER = "/landing/ikon/karakter-";

// Arena kartının görsel alanı: üstte Ay Ligi ve Günün 5 Sorusu satırları, ortada Sen · VS · Arkadaşın, altta (yakında) meydan okuma.
// Genişlik kart genişliğine göre değiştiği için ölçüler container query (@[15rem]) ile ayarlanır.
async function ArenaDuello({ alt }: { alt: string }) {
  const t = await getTranslations("landing.kesfet");

  const sen = { src: `${KARAKTER}ben-kiz.webp`, ad: t("arena.duello.sen"), zemin: "bg-brand-100" };
  const arkadas = { src: `${KARAKTER}arkadas.webp`, ad: t("arena.duello.arkadas"), zemin: "bg-gold-100" };
  const satir =
    "flex min-w-0 items-center gap-2 rounded-xl bg-white px-2.5 py-1.5 shadow-sm ring-1 ring-navy/5 dark:bg-gray-800 dark:ring-white/10";

  return (
    <div
      role="img"
      aria-label={alt}
      className="@container relative flex h-72 flex-col gap-2 overflow-hidden rounded-2xl border border-cream-dark bg-gradient-to-b from-brand-50 via-cream to-gold-50 p-3 sm:h-80 dark:border-gray-700 dark:from-brand-900/40 dark:via-gray-900 dark:to-gray-900"
    >
      {/* Ay Ligi ve Günün 5 Sorusu (görsel gösterge; sayı yok) */}
      <div className="flex flex-col gap-1.5">
        <div className={satir}>
          <Image src={`${IKON}kupa.webp`} alt="" width={28} height={28} className="h-7 w-7 shrink-0 rounded-lg bg-cream" />
          <span className="min-w-0 flex-1 text-xs font-extrabold leading-tight text-navy dark:text-gray-100">
            {t("arena.duello.lig")}
          </span>
          <span className="hidden h-1.5 w-14 shrink-0 overflow-hidden rounded-full bg-brand-100 @[15rem]:block dark:bg-gray-700">
            <span className="block h-full w-3/5 rounded-full bg-gold-500" />
          </span>
        </div>
        <div className={satir}>
          <Image src={`${IKON}hedef.webp`} alt="" width={28} height={28} className="h-7 w-7 shrink-0 rounded-lg bg-cream" />
          <span className="min-w-0 flex-1 text-xs font-extrabold leading-tight text-navy dark:text-gray-100">
            {t("arena.duello.gun")}
          </span>
          <span className="hidden shrink-0 items-center gap-0.5 @[15rem]:flex">
            {["bg-gold-500", "bg-gold-500", "bg-gold-500", "bg-brand-100 dark:bg-gray-700", "bg-brand-100 dark:bg-gray-700"].map(
              (renk, i) => (
                <span key={i} className={`h-2 w-2 rounded-full ${renk}`} />
              ),
            )}
          </span>
        </div>
      </div>

      {/* Düello: Sen · VS · Arkadaşın */}
      <div className="relative flex min-h-0 flex-1 items-center justify-between overflow-hidden rounded-2xl bg-white/70 px-3 ring-1 ring-navy/5 @[15rem]:px-4 dark:bg-gray-800/60 dark:ring-white/10">
        <span
          aria-hidden="true"
          className="absolute inset-y-0 start-0 w-1/2 bg-gradient-to-r from-brand-100 to-transparent dark:from-brand-900/50"
        />
        <span
          aria-hidden="true"
          className="absolute inset-y-0 end-0 w-1/2 bg-gradient-to-l from-gold-100 to-transparent dark:from-gold-900/30"
        />
        <Oyuncu {...sen} />
        <span className="relative z-10 flex h-9 w-9 shrink-0 -rotate-6 items-center justify-center rounded-full bg-gold-500 text-sm font-extrabold text-navy shadow-lg ring-4 ring-white @[15rem]:h-12 @[15rem]:w-12 @[15rem]:text-base dark:ring-gray-900">
          {t("arena.duello.vs")}
        </span>
        <Oyuncu {...arkadas} />
      </div>

      {/* Arkadaşına meydan oku (henüz açık değil) */}
      <div className="flex flex-wrap items-center justify-center gap-x-2 gap-y-1 rounded-2xl border-2 border-dashed border-navy/20 bg-white/80 px-2 py-2 text-center dark:border-white/20 dark:bg-gray-800/80">
        <span className="whitespace-nowrap text-[13px] font-extrabold text-navy @[15rem]:text-sm dark:text-gray-100">
          {t("arena.duello.meydan")}
        </span>
        <span className="rounded-full bg-warning-100 px-2.5 py-0.5 text-[11px] font-extrabold uppercase tracking-wide text-warning-700">
          {t("rozetYakinda")}
        </span>
      </div>
    </div>
  );
}

function Oyuncu({ src, ad, zemin }: { src: string; ad: string; zemin: string }) {
  return (
    <div className="relative z-10 flex flex-col items-center gap-1.5">
      <span
        className={`block h-12 w-12 overflow-hidden rounded-full shadow-md ring-[3px] ring-white @[15rem]:h-[4.75rem] @[15rem]:w-[4.75rem] @[15rem]:ring-4 dark:ring-gray-800 ${zemin}`}
      >
        <Image src={src} alt="" width={96} height={96} className="h-full w-full object-cover" />
      </span>
      <span className="rounded-full bg-white px-2.5 py-0.5 text-xs font-extrabold text-navy shadow-sm dark:bg-gray-800 dark:text-gray-100">
        {ad}
      </span>
    </div>
  );
}

export async function KesfetSection() {
  const t = await getTranslations("landing.kesfet");

  return (
    <section id="kesfet" className="scroll-mt-20 bg-white py-6 dark:bg-gray-900 sm:py-8 lg:py-10">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-3xl text-center">
          <p className="text-sm font-extrabold uppercase tracking-wider text-brand-600 dark:text-brand-300">
            {t("eyebrow")}
          </p>
          <h2 className="mt-2 text-balance text-3xl font-extrabold tracking-tight sm:text-4xl">{t("title")}</h2>
          <p className="mt-4 text-lg leading-relaxed text-navy-muted dark:text-gray-300">{t("desc")}</p>
        </div>

        <RevealGroup as="ul" className="mt-10 grid gap-6 md:grid-cols-3">
          {KARTLAR.map((k) => (
            <li
              key={k.key}
              className="flex flex-col overflow-hidden rounded-3xl border border-cream-dark bg-white p-3 shadow-sm dark:border-gray-700 dark:bg-gray-800"
            >
              {k.image ? (
                <div className="relative h-72 overflow-hidden rounded-2xl border border-cream-dark bg-cream dark:border-gray-700 dark:bg-gray-900 sm:h-80">
                  <Image
                    src={k.image}
                    alt={t(`${k.key}.alt`)}
                    width={540}
                    height={k.h}
                    sizes="(min-width: 768px) 340px, 90vw"
                    className="h-full w-full object-cover object-top"
                  />
                </div>
              ) : (
                <ArenaDuello alt={t(`${k.key}.alt`)} />
              )}
              <div className="flex flex-1 flex-col px-3 pb-4 pt-5">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <h3 className="text-xl font-extrabold leading-snug">{t(`${k.key}.ad`)}</h3>
                  <span
                    className={`rounded-full px-3 py-1 text-xs font-extrabold uppercase tracking-wide ${
                      k.durum === "erken"
                        ? "bg-brand-50 text-brand-700 dark:bg-brand-900/40 dark:text-brand-200"
                        : "bg-warning-100 text-warning-700"
                    }`}
                  >
                    {t(k.durum === "erken" ? "rozetErken" : "rozetYakinda")}
                  </span>
                </div>
                <p className="mt-3 leading-relaxed text-navy-muted dark:text-gray-300">{t(`${k.key}.desc`)}</p>
              </div>
            </li>
          ))}
        </RevealGroup>

        <p className="mx-auto mt-8 max-w-2xl text-center text-sm leading-relaxed text-navy-muted dark:text-gray-400">
          {t("durumNotu")}
        </p>
      </div>
    </section>
  );
}
