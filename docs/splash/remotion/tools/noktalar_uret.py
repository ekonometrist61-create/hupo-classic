"""Hupo silueti icin parcacik noktalari uretir (HupoGiris filmi, "yildizlardan Hupo olusur" sahnesi).

Kaynak: onayli master (mobile-app/assets/hupo/uygulama/hero_splash.webp, 845x900). Noktalar master'dan ORNEKLENIR:
konum ve renk master'dan gelir, yeni cizim yok. Sabit tohum: ayni girdi -> ayni cikti.
Cikti: docs/splash/remotion/data/hupo_noktalar.json  {w, h, goz: [[x,y],[x,y]], n: [[x, y, r, g, b, kenar], ...]}
       mobile-app/assets/hupo/uygulama/giris_noktalar.json  (ayni veri, n duz liste; Flutter filmi bunu okur)
Kullanim: python -I docs/splash/remotion/tools/noktalar_uret.py
"""
import json
import random
from pathlib import Path

from PIL import Image, ImageFilter

KOK = Path(__file__).resolve().parents[4]
KAYNAK = KOK / "mobile-app" / "assets" / "hupo" / "uygulama" / "hero_splash.webp"
CIKTI = Path(__file__).resolve().parents[1] / "data" / "hupo_noktalar.json"

ADIM_ICI = 23      # govde: ortalama nokta araligi (px, 845x900 tuvalinde)
ADIM_KENAR = 14    # siluet kenari: daha sik, sekil okunsun
KENAR_KALINLIK = 21  # MinFilter boyutu (tek sayi): kenar bandi ~10 px
ESIK = 230

rng = random.Random(61)
im = Image.open(KAYNAK).convert("RGBA")
w, h = im.size
alfa = im.getchannel("A")
ic = alfa.filter(ImageFilter.MinFilter(KENAR_KALINLIK))  # erozyon: kenar bandinin disini bulur

noktalar = []


def tara(adim, kenar_mi):
    for y0 in range(0, h, adim):
        for x0 in range(0, w, adim):
            x = min(w - 1, max(0, int(x0 + rng.uniform(0, adim))))
            y = min(h - 1, max(0, int(y0 + rng.uniform(0, adim))))
            if alfa.getpixel((x, y)) < ESIK:
                continue
            kenarda = ic.getpixel((x, y)) < ESIK
            if kenarda != kenar_mi:
                continue
            r, g, b, _ = im.getpixel((x, y))
            noktalar.append([x, y, r, g, b, 1 if kenar_mi else 0])


tara(ADIM_ICI, False)
tara(ADIM_KENAR, True)

# Gozler: master'daki iki goz bebeginin orta noktasi (845x900 tuvali, gozle olculdu)
veri = {"w": w, "h": h, "goz": [[303, 305], [488, 248]], "n": noktalar}
CIKTI.parent.mkdir(parents=True, exist_ok=True)
CIKTI.write_text(json.dumps(veri, separators=(",", ":")), encoding="utf-8")
print(f"{len(noktalar)} nokta (kenar: {sum(n[5] for n in noktalar)}), {CIKTI.stat().st_size} bayt")

# Mobil uygulama icin duz (tek boyutlu) kopya: giris_noktalar.json, [x, y, r, g, b, kenar] * N
UYGULAMA = KOK / "mobile-app" / "assets" / "hupo" / "uygulama" / "giris_noktalar.json"
duz = {"w": w, "h": h, "goz": veri["goz"], "n": [v for n in noktalar for v in n]}
UYGULAMA.write_text(json.dumps(duz, separators=(",", ":")), encoding="utf-8")
print(f"uygulama kopyasi: {UYGULAMA.stat().st_size} bayt")

