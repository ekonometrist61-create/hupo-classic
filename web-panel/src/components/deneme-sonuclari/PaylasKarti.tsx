"use client";

import { useState } from "react";

interface Props {
  sinavAd: string;
  puan: number;
  sinif: number;
  sira: number;
  katilimci: number;
  yuzdelik: number;
}

const BOYUT = 1080;

function metniSigdir(g: CanvasRenderingContext2D, metin: string, maksGenislik: number, baslangic: number) {
  let boyut = baslangic;
  g.font = `600 ${boyut}px sans-serif`;
  while (g.measureText(metin).width > maksGenislik && boyut > 24) {
    boyut -= 2;
    g.font = `600 ${boyut}px sans-serif`;
  }
}

function kartCiz(p: Props): HTMLCanvasElement {
  const c = document.createElement("canvas");
  c.width = BOYUT;
  c.height = BOYUT;
  const g = c.getContext("2d");
  if (!g) throw new Error("canvas desteklenmiyor");

  const zemin = g.createLinearGradient(0, 0, BOYUT, BOYUT);
  zemin.addColorStop(0, "#147D8A");
  zemin.addColorStop(1, "#0d5762");
  g.fillStyle = zemin;
  g.fillRect(0, 0, BOYUT, BOYUT);

  g.fillStyle = "#ffffff";
  g.textAlign = "center";
  g.textBaseline = "middle";

  g.font = "600 56px sans-serif";
  g.globalAlpha = 0.85;
  g.fillText("Deneme Sınavı Sonucum", BOYUT / 2, 150);

  metniSigdir(g, p.sinavAd, 940, 48);
  g.globalAlpha = 0.95;
  g.fillText(p.sinavAd, BOYUT / 2, 240);
  g.globalAlpha = 1;

  g.font = "800 300px sans-serif";
  g.fillText(p.puan.toFixed(1), BOYUT / 2, 500);
  g.font = "600 52px sans-serif";
  g.fillText("puan", BOYUT / 2, 620);

  g.font = "700 64px sans-serif";
  g.fillText(`${p.sinif}. sınıf · ${p.sira}. / ${p.katilimci}`, BOYUT / 2, 760);
  g.font = "600 48px sans-serif";
  g.globalAlpha = 0.9;
  g.fillText(`Yüzdelik dilim %${Math.round(p.yuzdelik)}`, BOYUT / 2, 840);
  g.globalAlpha = 1;

  g.font = "700 44px sans-serif";
  g.globalAlpha = 0.8;
  g.fillText("Hupolingo", BOYUT / 2, 990);
  g.globalAlpha = 1;

  return c;
}

export default function PaylasKarti(props: Props) {
  const [durum, setDurum] = useState<"hazir" | "hazirlaniyor" | "hata">("hazir");

  async function paylas() {
    setDurum("hazirlaniyor");
    try {
      const c = kartCiz(props);
      const blob = await new Promise<Blob | null>((r) => c.toBlob(r, "image/png"));
      if (!blob) throw new Error("png üretilemedi");

      const dosya = new File([blob], "hupolingo-deneme-sonucu.png", { type: "image/png" });
      const metin = `Hupolingo deneme sınavında ${props.puan.toFixed(1)} puan aldım! Sınıfımda ${props.sira}. sıradayım.`;

      if (navigator.canShare?.({ files: [dosya] })) {
        try {
          await navigator.share({ files: [dosya], title: "Deneme Sınavı Sonucum", text: metin });
          setDurum("hazir");
          return;
        } catch (e) {
          if (e instanceof Error && e.name === "AbortError") {
            setDurum("hazir");
            return;
          }
        }
      }

      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = dosya.name;
      a.click();
      URL.revokeObjectURL(url);
      setDurum("hazir");
    } catch {
      setDurum("hata");
    }
  }

  return (
    <div className="mb-6 flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-gray-200 bg-white p-4 dark:border-gray-700 dark:bg-gray-800">
      <div>
        <p className="text-sm font-semibold text-gray-800 dark:text-gray-100">Sonucunu arkadaşlarınla paylaş</p>
        <p className="text-xs text-gray-500 dark:text-gray-400">Adın görünmez; yalnızca puanın ve sıran yer alır.</p>
      </div>
      <button
        type="button"
        onClick={paylas}
        disabled={durum === "hazirlaniyor"}
        className="rounded-lg bg-brand-500 px-4 py-2 text-sm font-bold text-white hover:bg-brand-600 disabled:opacity-60"
      >
        {durum === "hazirlaniyor" ? "Hazırlanıyor…" : "Kartı paylaş"}
      </button>
      {durum === "hata" && <p className="w-full text-xs text-red-600 dark:text-red-400">Kart oluşturulamadı, tekrar dene.</p>}
    </div>
  );
}
