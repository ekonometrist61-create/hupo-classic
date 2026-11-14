"use client";

import { IconArrowRight, IconCheck, IconChevronDown } from "@/components/landing/Icons";
import { useEffect, useRef, useState } from "react";

import { BECERI_ETIKET, DEMO_HIKAYE, type DemoSoru, type SecenekId, hikayeMetniDoldur } from "./okumaDemoHikaye";

// Uygulamadaki akış: kahraman seçimi → hikâye → sayfalar → sorular → sonuç.
// Kayıtsız demo: ad ve cevaplar yalnız bu sayfanın belleğinde tutulur; sunucuya gitmez, saklanmaz.

type Asama = "kahraman" | "liste" | "okuma" | "sorular" | "sonuc";

interface KahramanSecenegi {
  id: string;
  etiket: string;
  alt: string;
  adIster: boolean;
  // Hayvan, araç ve hayalî karakterde hazır ad önerileri (uygulamayla aynı).
  oneriler?: string[];
}

const KAHRAMANLAR: KahramanSecenegi[] = [
  { id: "ben", etiket: "Ben", alt: "Başrolde ben varım!", adIster: true },
  { id: "hazir", etiket: "Hupo", alt: "Hupo'yla keşfet!", adIster: false },
  { id: "aile", etiket: "Ailem", alt: "Annem, babam…", adIster: true },
  { id: "arkadas", etiket: "Arkadaşım", alt: "Birlikte keşfet", adIster: true },
  {
    id: "hayvan",
    etiket: "Hayvan Dostlarımız",
    alt: "At, aslan, fil…",
    adIster: true,
    oneriler: ["Kedi", "Köpek", "Tavşan", "Kuş", "Kaplumbağa", "Balık"],
  },
  {
    id: "arac",
    etiket: "Araçlar",
    alt: "Otomobil, vapur…",
    adIster: true,
    oneriler: ["Roket", "Tren", "Balon", "Kamyon", "Gemi"],
  },
  {
    id: "hayali",
    etiket: "Hayalî karakter",
    alt: "Hayal gücün",
    adIster: true,
    oneriler: ["Gökkuşağı Perisi", "Uzay Kedisi", "Dev Kurbağa", "Işık Muhafızı"],
  },
  { id: "baska", etiket: "Başka biri", alt: "Tanıdığın biri", adIster: true },
];

// Ad kuralları uygulamayla aynıdır (kahraman_secim, KahramanSecimi.adKontrol): 1–24 karakter, harf/boşluk/nokta/kesme/kısa çizgi.
const AD_KURALI = /^\p{L}[\p{L} .'\-]{0,23}$/u;

// Yasak sözcükler uygulamadaki listeyle aynıdır: Türkçe harfler sadeleştirilmiş, tam sözcük olarak kontrol edilir.
const DIN_ADLARI = new Set([
  "allah", "tanri", "peygamber", "muhammed", "mevlana", "ebubekir", "omer", "osman", "ali", "hasan",
  "huseyin", "fatima", "aise", "hatice", "adem", "nuh", "ibrahim", "musa", "isa", "davud", "suleyman",
  "yusuf", "meryem", "cebrail", "mikail", "azrail",
]);
const KUFUR_ADLARI = new Set([
  "amk", "aq", "amcik", "orospu", "pic", "sik", "siktir", "yarak", "yarrak", "got", "ibne", "kahpe",
  "gavat", "pezevenk", "surtuk", "fahise", "porno", "seks", "sex",
]);
const KUFUR_KOKLERI = ["orospu", "amcik", "siktir", "yarrak", "pezevenk", "surtuk", "fahise", "kahpe"];
const MARKA_ADLARI = new Set([
  "pikachu", "mickey", "minnie", "batman", "superman", "spiderman", "pokemon", "doraemon", "naruto",
  "shrek", "barbie", "sonic", "mario", "hulk", "goofy",
]);
const GERCEK_KISI_ADLARI = new Set([
  "ataturk", "tarkan", "messi", "ronaldo", "ronaldinho", "neymar", "erdogan", "obama", "trump", "putin",
  "hitler", "elon", "musk",
]);

function sadelestir(ad: string): string {
  const harita: Record<string, string> = { ç: "c", ğ: "g", ı: "i", ö: "o", ş: "s", ü: "u", â: "a", î: "i", û: "u" };
  const kucuk = ad.replaceAll("I", "ı").replaceAll("İ", "i").toLowerCase();
  return [...kucuk].map((c) => harita[c] ?? c).join("");
}

function yasakliMi(ad: string, dinKisitli: boolean): boolean {
  const sozcukler = sadelestir(ad).split(/[^a-z]+/).filter(Boolean);
  return sozcukler.some(
    (s) =>
      KUFUR_ADLARI.has(s) ||
      KUFUR_KOKLERI.some((k) => s.startsWith(k)) ||
      MARKA_ADLARI.has(s) ||
      GERCEK_KISI_ADLARI.has(s) ||
      (dinKisitli && DIN_ADLARI.has(s)),
  );
}

/** Ad hatası; null ise ad geçerli. Allah ve peygamber adları yalnız hayvan, araç ve hayalî karakterde yasaktır. */
function adHatasi(ad: string, dinKisitli = false): string | null {
  const t = ad.trim();
  if (!t) return "Bir ad yaz.";
  if ([...t].length > 24) return "En fazla 24 harf olabilir.";
  if (!AD_KURALI.test(t)) return "Ad yalnızca harf, boşluk, kesme ya da kısa çizgiden oluşmalı.";
  if (yasakliMi(t, dinKisitli)) return "Bu ad kullanılamaz. Başka bir ad dene.";
  return null;
}

export function OkumaDemo() {
  const sayfalar = DEMO_HIKAYE.sayfalar;
  const sorular = DEMO_HIKAYE.sorular;

  const [asama, setAsama] = useState<Asama>("kahraman");
  const [turId, setTurId] = useState<string | null>(null);
  const [ad, setAd] = useState("");
  const [yoldasVar, setYoldasVar] = useState(false);
  const [yoldasAd, setYoldasAd] = useState("");
  const [sayfa, setSayfa] = useState(0);
  const [soruNo, setSoruNo] = useState(0);
  const [secilen, setSecilen] = useState<SecenekId | null>(null);
  const [cevaplar, setCevaplar] = useState<Partial<Record<string, SecenekId>>>({});
  const [ipucuAcik, setIpucuAcik] = useState(false);

  const ilkRender = useRef(true);
  useEffect(() => {
    // Her adım değişince demo alanının başına kaydır; ilk açılışta sayfa yerinde kalır.
    if (ilkRender.current) {
      ilkRender.current = false;
      return;
    }
    document.getElementById("okuma-demo-alani")?.scrollIntoView({
      behavior: window.matchMedia("(prefers-reduced-motion: reduce)").matches ? "auto" : "smooth",
      block: "start",
    });
  }, [asama, sayfa, soruNo]);

  const secim = KAHRAMANLAR.find((k) => k.id === turId) ?? null;
  const dinKisitli = turId === "hayvan" || turId === "arac" || turId === "hayali";
  const kahramanAdi = secim?.adIster === false ? "Hupo" : ad.trim();

  // Devam engelinin nedeni; null ise seçim tamamdır (uygulamadaki _neden ile aynı sıra).
  let neden: string | null = null;
  if (!secim) neden = "Önce bir kahraman seç.";
  else if (secim.adIster && adHatasi(ad, dinKisitli)) neden = adHatasi(ad, dinKisitli);
  else if (yoldasVar && adHatasi(yoldasAd)) neden = "Yol arkadaşının adını yaz.";

  function kahramaniSec(id: string) {
    setTurId(id);
    setAd("");
  }

  function hikayeyiBaslat() {
    setSayfa(0);
    setSoruNo(0);
    setSecilen(null);
    setCevaplar({});
    setIpucuAcik(false);
    setAsama("okuma");
  }

  function kahramaniSifirla() {
    setTurId(null);
    setAd("");
    setYoldasVar(false);
    setYoldasAd("");
    setCevaplar({});
    setAsama("kahraman");
  }

  const dogruSayi = sorular.filter((s) => cevaplar[s.id] === s.dogru).length;
  const soru: DemoSoru = sorular[soruNo];
  const geri = cevaplar[soru.id];
  const cevaplandi = geri !== undefined;
  const dogruMu = geri === soru.dogru;
  const dogruSecenek = soru.secenekler.find((s) => s.id === soru.dogru);
  const yoldasMetin = yoldasVar ? yoldasAd : undefined;

  return (
    <div id="okuma-demo-alani" className="scroll-mt-6 space-y-8">
      {asama === "kahraman" && (
        <section aria-labelledby="kahraman-baslik" className="space-y-6 rounded-2xl border border-cream-dark bg-white p-5 shadow-sm sm:p-8 dark:border-gray-700 dark:bg-gray-800">
          <div>
            <p className="text-xs font-extrabold uppercase tracking-wider text-brand-600 dark:text-brand-300">Haydi, hikâye başlasın!</p>
            <h2 id="kahraman-baslik" className="mt-2 text-2xl font-extrabold tracking-tight">
              Kahramanın kim olsun?
            </h2>
            <p className="mt-2 leading-relaxed text-navy-muted dark:text-gray-300">
              Kendini, bir aile üyeni, bir hayvanı ya da hayalî bir karakteri seçebilirsin.
            </p>
          </div>

          <div role="radiogroup" aria-label="Kahraman türü" className="grid grid-cols-2 gap-3">
            {KAHRAMANLAR.map((k) => {
              const secili = turId === k.id;
              return (
                <button
                  key={k.id}
                  type="button"
                  role="radio"
                  aria-checked={secili}
                  onClick={() => kahramaniSec(k.id)}
                  className={`flex min-h-16 flex-col items-start rounded-xl border-2 p-3 text-left transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none ${
                    secili
                      ? "border-brand-500 bg-brand-50 dark:bg-gray-700"
                      : "border-cream-dark hover:border-brand-300 dark:border-gray-600"
                  }`}
                >
                  <span className="flex w-full items-center justify-between gap-2 font-extrabold leading-snug">
                    {k.etiket}
                    {secili && <IconCheck className="h-5 w-5 shrink-0 text-brand-600 dark:text-brand-300" />}
                  </span>
                  <span className="mt-1 text-sm text-navy-muted dark:text-gray-300">{k.alt}</span>
                </button>
              );
            })}
          </div>

          {secim?.oneriler && (
            <div>
              <p className="text-sm font-extrabold text-navy-muted dark:text-gray-300">Ya da birini seç:</p>
              <div className="mt-2 flex flex-wrap gap-2">
                {secim.oneriler.map((o) => (
                  <button
                    key={o}
                    type="button"
                    onClick={() => setAd(o)}
                    className="min-h-11 rounded-full border border-cream-dark bg-white px-4 text-sm font-bold text-navy hover:border-brand-300 dark:border-gray-600 dark:bg-gray-900 dark:text-gray-100"
                  >
                    {o}
                  </button>
                ))}
              </div>
            </div>
          )}

          {secim?.adIster && (
            <div>
              <label htmlFor="demo-kahraman-ad" className="block text-sm font-extrabold">
                Kahramanın adı
              </label>
              <input
                id="demo-kahraman-ad"
                type="text"
                value={ad}
                maxLength={24}
                onChange={(e) => setAd(e.target.value)}
                placeholder={secim.id === "hayvan" ? "Örn. Pati" : secim.id === "arac" ? "Örn. Mavi Şimşek" : secim.id === "hayali" ? "Örn. Işık Muhafızı" : "Adını yaz"}
                aria-invalid={ad.length > 0 && Boolean(adHatasi(ad, dinKisitli))}
                className="mt-2 min-h-12 w-full rounded-xl border-2 border-cream-dark bg-white px-4 text-base text-navy focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 dark:border-gray-600 dark:bg-gray-900 dark:text-gray-100"
              />
              <div className="mt-1 flex justify-between gap-3 text-sm text-navy-muted dark:text-gray-400">
                <span>{ad.length > 0 ? adHatasi(ad, dinKisitli) ?? "" : ""}</span>
                <span>{[...ad.trim()].length}/24</span>
              </div>
            </div>
          )}

          <div className="rounded-xl border border-cream-dark p-4 dark:border-gray-600">
            <div className="flex items-center justify-between gap-4">
              <span className="font-bold">Yol arkadaşı ekle (isteğe bağlı)</span>
              <button
                type="button"
                role="switch"
                aria-checked={yoldasVar}
                onClick={() => setYoldasVar((v) => !v)}
                className={`relative h-7 w-12 shrink-0 rounded-full transition-colors ${yoldasVar ? "bg-brand-500" : "bg-cream-dark dark:bg-gray-600"}`}
              >
                <span className={`absolute top-1 h-5 w-5 rounded-full bg-white shadow transition-transform ${yoldasVar ? "translate-x-6" : "translate-x-1"}`} />
                <span className="sr-only">Yol arkadaşı ekle</span>
              </button>
            </div>
            {yoldasVar && (
              <div className="mt-3">
                <label htmlFor="demo-yoldas-ad" className="block text-sm font-bold">
                  Yol arkadaşının adı
                </label>
                <input
                  id="demo-yoldas-ad"
                  type="text"
                  value={yoldasAd}
                  maxLength={24}
                  onChange={(e) => setYoldasAd(e.target.value)}
                  className="mt-2 min-h-12 w-full rounded-xl border-2 border-cream-dark bg-white px-4 text-base text-navy focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 dark:border-gray-600 dark:bg-gray-900 dark:text-gray-100"
                />
                {yoldasAd.length > 0 && adHatasi(yoldasAd) && (
                  <p className="mt-1 text-sm text-navy-muted dark:text-gray-400">{adHatasi(yoldasAd)}</p>
                )}
              </div>
            )}
          </div>

          <p className="text-sm leading-relaxed text-navy-muted dark:text-gray-400">
            Yazdığın adlar yalnızca bu cihazda, bu sayfada kalır.
          </p>

          <div className="space-y-3">
            {neden && (
              <p role="status" className="text-center text-sm font-bold text-navy-muted dark:text-gray-300">
                {neden}
              </p>
            )}
            <button
              type="button"
              disabled={neden !== null}
              onClick={() => setAsama("liste")}
              className="inline-flex min-h-12 w-full items-center justify-center gap-2 rounded-xl bg-brand-500 px-6 text-base font-extrabold text-white transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 disabled:cursor-not-allowed disabled:opacity-50 motion-reduce:transition-none"
            >
              Hikâyeleri gör
              <IconArrowRight className="h-5 w-5" />
            </button>
          </div>
        </section>
      )}

      {asama === "liste" && (
        <section aria-labelledby="liste-baslik" className="space-y-6 rounded-2xl border border-cream-dark bg-white p-5 shadow-sm sm:p-8 dark:border-gray-700 dark:bg-gray-800">
          <div>
            <h2 id="liste-baslik" className="text-2xl font-extrabold tracking-tight">
              Hangi hikâyeyi okuyalım?
            </h2>
            <p className="mt-2 leading-relaxed text-navy-muted dark:text-gray-300">{kahramanAdi} için hikâye seçtim.</p>
          </div>
          <article className="rounded-2xl border-2 border-brand-500 bg-brand-50 p-5 dark:bg-gray-700">
            <p className="text-sm font-bold text-navy-muted dark:text-gray-300">
              {DEMO_HIKAYE.tur} · {DEMO_HIKAYE.sinif}. sınıf · {sorular.length} soru
            </p>
            <h3 className="mt-1 text-xl font-extrabold">{DEMO_HIKAYE.baslik}</h3>
            <p className="mt-2 leading-relaxed text-navy-muted dark:text-gray-300">
              Maarif değeri: {DEMO_HIKAYE.deger}. Sayfaları kendi hızında çevir; sorular hikâyenin sonunda gelir.
            </p>
          </article>
          <div className="flex flex-col gap-3 sm:flex-row sm:justify-between">
            <button
              type="button"
              onClick={kahramaniSifirla}
              className="inline-flex min-h-12 items-center justify-center rounded-xl border-2 border-cream-dark px-5 text-base font-bold text-navy hover:border-brand-300 dark:border-gray-600 dark:text-gray-100"
            >
              Kahramanı değiştir
            </button>
            <button
              type="button"
              onClick={hikayeyiBaslat}
              className="inline-flex min-h-12 items-center justify-center gap-2 rounded-xl bg-brand-500 px-6 text-base font-extrabold text-white transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none"
            >
              Hikâyeye başla
              <IconArrowRight className="h-5 w-5" />
            </button>
          </div>
        </section>
      )}

      {asama === "okuma" && (
        <section aria-label="Hikâye metni" className="rounded-2xl border border-cream-dark bg-white p-5 shadow-sm sm:p-8 dark:border-gray-700 dark:bg-gray-800">
          <div className="flex items-center justify-between gap-3">
            <p className="text-sm font-extrabold text-brand-600 dark:text-brand-300">
              Sayfa {sayfa + 1} / {sayfalar.length}
            </p>
            <p className="text-sm font-bold text-navy-muted dark:text-gray-300">
              {DEMO_HIKAYE.tur} · {DEMO_HIKAYE.sinif}. sınıf
            </p>
          </div>

          <div
            role="progressbar"
            aria-label="Okuma ilerlemesi"
            aria-valuemin={1}
            aria-valuemax={sayfalar.length}
            aria-valuenow={sayfa + 1}
            aria-valuetext={`${sayfalar.length} sayfadan ${sayfa + 1}. sayfa`}
            className="mt-3 h-2 overflow-hidden rounded-full bg-cream-dark dark:bg-gray-700"
          >
            <div
              className="h-full rounded-full bg-brand-500 transition-[width] duration-300 motion-reduce:transition-none"
              style={{ width: `${((sayfa + 1) / sayfalar.length) * 100}%` }}
            />
          </div>

          <p className="mt-6 wrap-break-word text-xl leading-relaxed sm:text-2xl sm:leading-relaxed">
            {hikayeMetniDoldur(sayfalar[sayfa], kahramanAdi, yoldasMetin)}
          </p>

          <div className="mt-8 flex flex-col-reverse gap-3 sm:flex-row sm:items-center sm:justify-between">
            <button
              type="button"
              onClick={() => setSayfa(sayfa - 1)}
              disabled={sayfa === 0}
              className="inline-flex min-h-12 items-center justify-center gap-2 rounded-xl border-2 border-cream-dark px-5 text-base font-bold text-navy transition-colors hover:border-brand-300 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 disabled:cursor-not-allowed disabled:opacity-50 dark:border-gray-600 dark:text-gray-100 motion-reduce:transition-none"
            >
              <IconChevronDown className="h-5 w-5 rotate-90" />
              Önceki
            </button>
            {sayfa < sayfalar.length - 1 ? (
              <button
                type="button"
                onClick={() => setSayfa(sayfa + 1)}
                className="inline-flex min-h-12 items-center justify-center gap-2 rounded-xl bg-brand-500 px-6 text-base font-extrabold text-white transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none"
              >
                Sonraki sayfa
                <IconArrowRight className="h-5 w-5" />
              </button>
            ) : (
              <button
                type="button"
                onClick={() => {
                  setSoruNo(0);
                  setSecilen(null);
                  setAsama("sorular");
                }}
                className="inline-flex min-h-12 items-center justify-center gap-2 rounded-xl bg-brand-500 px-6 text-base font-extrabold text-white transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none"
              >
                Sorulara geç
                <IconArrowRight className="h-5 w-5" />
              </button>
            )}
          </div>
        </section>
      )}

      {asama === "sorular" && (
        <section aria-labelledby="soru-baslik" className="space-y-5 rounded-2xl border border-cream-dark bg-white p-5 shadow-sm sm:p-8 dark:border-gray-700 dark:bg-gray-800">
          <div className="flex items-center justify-between gap-3">
            <p id="soru-baslik" className="text-sm font-extrabold text-brand-600 dark:text-brand-300">
              Soru {soruNo + 1} / {sorular.length}
            </p>
            {!cevaplandi && (
              <button
                type="button"
                onClick={() => setIpucuAcik((v) => !v)}
                aria-expanded={ipucuAcik}
                className="inline-flex min-h-11 items-center font-bold text-brand-600 underline underline-offset-4 hover:text-brand-700 dark:text-brand-300"
              >
                İpucu
              </button>
            )}
          </div>

          <div className="flex gap-2" aria-label="Soru ilerlemesi">
            {sorular.map((s, i) => {
              const sonuc = cevaplar[s.id];
              const renk =
                sonuc === undefined
                  ? i === soruNo
                    ? "bg-brand-500"
                    : "bg-cream-dark dark:bg-gray-600"
                  : sonuc === s.dogru
                    ? "bg-brand-500"
                    : "bg-gold-500";
              return <span key={s.id} className={`h-2 flex-1 rounded-full ${renk}`} />;
            })}
          </div>

          {ipucuAcik && !cevaplandi && (
            <p className="rounded-xl bg-cream p-4 leading-relaxed dark:bg-gray-900">
              Cevabı bulmak için hikâyenin {soru.dayanakSayfa}. sayfasına bakabilirsin.
            </p>
          )}

          <h3 className="text-xl font-extrabold leading-snug sm:text-2xl">{soru.metin}</h3>
          <p className="text-sm font-bold text-navy-muted dark:text-gray-300">{BECERI_ETIKET[soru.beceri]}</p>

          <div role="radiogroup" aria-label={soru.metin} className="grid gap-3">
            {soru.secenekler.map((s) => {
              const durumSecili = !cevaplandi && secilen === s.id;
              const dogruSik = cevaplandi && s.id === soru.dogru;
              const yanlisSecim = cevaplandi && s.id === geri && s.id !== soru.dogru;
              const pasif = cevaplandi && !dogruSik && !yanlisSecim;
              const kenar = dogruSik
                ? "border-brand-500 bg-brand-50 dark:bg-gray-700"
                : yanlisSecim
                  ? "border-gold-500 bg-gold-50 dark:bg-gray-700"
                  : durumSecili
                    ? "border-brand-500 bg-brand-50 dark:bg-gray-700"
                    : "border-cream-dark dark:border-gray-600";
              return (
                <button
                  key={s.id}
                  type="button"
                  role="radio"
                  aria-checked={secilen === s.id}
                  disabled={cevaplandi}
                  onClick={() => setSecilen(s.id)}
                  className={`flex min-h-12 items-center gap-3 rounded-xl border-2 px-4 py-3 text-left text-base font-semibold transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 disabled:cursor-default motion-reduce:transition-none ${kenar} ${pasif ? "opacity-60" : ""}`}
                >
                  <span className="grid h-7 w-7 shrink-0 place-items-center rounded-full border-2 border-navy-muted text-xs font-extrabold text-navy-muted dark:border-gray-400 dark:text-gray-300">
                    {s.id}
                  </span>
                  <span className="min-w-0 flex-1 wrap-break-word">{s.metin}</span>
                  {dogruSik && <IconCheck className="h-5 w-5 shrink-0 text-brand-600 dark:text-brand-300" />}
                </button>
              );
            })}
          </div>

          <div role="status" aria-live="polite" className="empty:hidden">
            {cevaplandi && dogruMu && (
              <div className="rounded-xl border border-brand-200 bg-brand-50 p-4 text-navy dark:border-brand-700 dark:bg-gray-900 dark:text-gray-100">
                <p className="flex items-center gap-2 font-extrabold">
                  <IconCheck className="h-5 w-5 shrink-0 text-brand-600 dark:text-brand-300" />
                  Doğru!
                </p>
                <p className="mt-1 leading-relaxed">{soru.aciklama}</p>
              </div>
            )}
            {cevaplandi && !dogruMu && (
              <div className="rounded-xl border border-gold-300 bg-gold-50 p-4 text-navy dark:border-gold-700 dark:bg-gray-900 dark:text-gray-100">
                <p className="font-extrabold">Bu kez olmadı.</p>
                <p className="mt-1 font-bold">
                  Doğru cevap bu: {dogruSecenek?.id}) {dogruSecenek?.metin}
                </p>
                <p className="mt-2 leading-relaxed">{soru.aciklama}</p>
              </div>
            )}
          </div>

          {!cevaplandi ? (
            <div className="space-y-2">
              {!secilen && <p className="text-center text-sm font-bold text-navy-muted dark:text-gray-300">Bir şık seç, sonra cevapla.</p>}
              <button
                type="button"
                disabled={!secilen}
                onClick={() => secilen && setCevaplar((onceki) => ({ ...onceki, [soru.id]: secilen }))}
                className="inline-flex min-h-12 w-full items-center justify-center rounded-xl bg-brand-500 px-6 text-base font-extrabold text-white transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 disabled:cursor-not-allowed disabled:opacity-50 motion-reduce:transition-none"
              >
                Cevapla
              </button>
            </div>
          ) : (
            <button
              type="button"
              onClick={() => {
                if (soruNo === sorular.length - 1) {
                  setAsama("sonuc");
                  return;
                }
                setSoruNo(soruNo + 1);
                setSecilen(null);
                setIpucuAcik(false);
              }}
              className="inline-flex min-h-12 w-full items-center justify-center gap-2 rounded-xl bg-brand-500 px-6 text-base font-extrabold text-white transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none"
            >
              {soruNo === sorular.length - 1 ? "Sonucu gör" : "Sonraki soru"}
              <IconArrowRight className="h-5 w-5" />
            </button>
          )}
        </section>
      )}

      {asama === "sonuc" && (
        <section aria-labelledby="sonuc-baslik" className="space-y-6 rounded-2xl border border-cream-dark bg-white p-5 shadow-sm sm:p-8 dark:border-gray-700 dark:bg-gray-800">
          <div>
            <p className="text-xs font-extrabold uppercase tracking-wider text-brand-600 dark:text-brand-300">Hikâye bitti</p>
            <h2 id="sonuc-baslik" className="mt-2 text-2xl font-extrabold tracking-tight">
              {dogruSayi} / {sorular.length} doğru
            </h2>
            <p className="mt-3 leading-relaxed text-navy-muted dark:text-gray-300">
              Gerçek uygulamada bu sonuç veli panelinde soru türlerine göre görünür. Bu bir puan ya da sınav tahmini
              değildir. Bu demoda hiçbir şey kaydedilmez.
            </p>
          </div>
          <div className="flex flex-col gap-3 sm:flex-row sm:justify-between">
            <button
              type="button"
              onClick={kahramaniSifirla}
              className="inline-flex min-h-12 items-center justify-center rounded-xl border-2 border-cream-dark px-5 text-base font-bold text-navy hover:border-brand-300 dark:border-gray-600 dark:text-gray-100"
            >
              Başka kahramanla dene
            </button>
            <button
              type="button"
              onClick={hikayeyiBaslat}
              className="inline-flex min-h-12 items-center justify-center rounded-xl bg-brand-500 px-6 text-base font-extrabold text-white transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none"
            >
              Hikâyeyi baştan oku
            </button>
          </div>
        </section>
      )}
    </div>
  );
}
