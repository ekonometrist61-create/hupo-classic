"""HupoGiris filmi ses tasarimi v2 (K-0169): sicak mallet/celesta + pad, 4 notalik "Hu-po-lin-go" imzasi.

Harici ses dosyasi yok; her ses sentezlenir. Iki surum:
  tam  -> docs/splash/remotion/audio/giris_ses.wav        (varsayilan; atmosfer + yaklasma arpej + imza)
  sade -> docs/splash/remotion/audio/giris_ses_sade.wav   (yalniz drone, goz acilisi, imza, kapanis)
Kullanim: python -I docs/splash/remotion/tools/giris_ses_uret.py [tam|sade|ikisi]

Tasarim kurallari (gerekce docs/splash/GIRIS_FILMI.md "Ses tasarimi"):
- Majör, konsonans (D majör: D F# A + E); yukselen kontur; imza 4 hece = 4 nota (hece parcalama, ezber).
- Sicak tonlar: ana nota <= D6 (1,2 kHz); tiz kivilcim, hisirti, "slot makinesi" ding'i yok (cocuk + veli guveni).
- Yogunluk gerilim -> cozulme egrisini izler: sessiz gece, hizlanan arpej, gozlerin acildigi tek zirve, imza, kapanis.
- Senkron: ses olaylari gorunur kare zamanindan 0-40 ms SONRA (ITU-R BT.1359: ses geriden gelirse tolerans daha yuksek).
- Ses seviyesi hedefi: -16 LUFS (bütünlesik, K-agirlikli), ornek tepe <= -1,5 dBFS.
"""
import math
import sys
import wave
from pathlib import Path

import numpy as np
from scipy import signal

SR = 48000
SURE = 5.0
N = int(SR * SURE)
KLASOR = Path(__file__).resolve().parents[1] / "audio"
rng = np.random.default_rng(11)

# Gorunur kare zamanlari (HupoGiris.tsx'ten): ses bunlara gore +0,02..0,04 sn gecikmeli yerlestirilir
GORSEL = {
    "yildiz": 0.45,         # iki goz yildizi opaklik 0 -> 1
    "goz_acilis": 2.5333,   # gozKapali t < 2,52: ilk acik kare n=152 (60 fps)
    "inis": 2.90,           # siçrama inisi (hopT 0,42)
    "hu": 3.00, "po": 3.11, "lin": 3.22, "go": 3.385,  # harf baslangiclari (3,00 + indeks * 0,055); hece ilk harfi
    "ark_bitis": 3.95,      # altin iz tamamlanir, harf parlamasi baslar
}


def hz(n):
    adlar = {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}
    k = adlar[n[0]]
    i = 1
    if n[1] == "#":
        k += 1
        i = 2
    elif n[1] == "b":
        k -= 1
        i = 2
    o = int(n[i:])
    return 440.0 * 2 ** ((k + 12 * (o + 1) - 69) / 12)


def zaman(sure):
    return np.arange(int(sure * SR)) / SR


class Karisim:
    def __init__(self):
        self.L = np.zeros(N)
        self.R = np.zeros(N)
        self.sL = np.zeros(N)  # yanki gonderimi
        self.sR = np.zeros(N)

    def ekle(self, sig, t0, pan=0.0, amp=1.0, gonder=0.3):
        i0 = int(round(t0 * SR))
        if i0 >= N or i0 < 0:
            return
        n = min(len(sig), N - i0)
        a = (pan + 1) * math.pi / 4
        gl, gr = math.cos(a) * amp, math.sin(a) * amp
        self.L[i0:i0 + n] += sig[:n] * gl
        self.R[i0:i0 + n] += sig[:n] * gr
        self.sL[i0:i0 + n] += sig[:n] * gl * gonder
        self.sR[i0:i0 + n] += sig[:n] * gr * gonder

    def ekle_st(self, l, r, t0, amp=1.0, gonder=0.3):
        i0 = int(round(t0 * SR))
        if i0 >= N or i0 < 0:
            return
        n = min(len(l), N - i0)
        self.L[i0:i0 + n] += l[:n] * amp
        self.R[i0:i0 + n] += r[:n] * amp
        self.sL[i0:i0 + n] += l[:n] * amp * gonder
        self.sR[i0:i0 + n] += r[:n] * amp * gonder


def mallet(f, dur=1.6, tau=0.9, parlak=1.0):
    """Marimba benzeri modal ses (1 : 3,99 : 9,9 kismi tonlar), kisa yumusak mallet vurusu."""
    t = zaman(dur)
    s = np.zeros_like(t)
    for r, a, k in ((1.0, 1.0, 1.0), (3.99, 0.42 * parlak, 0.42), (9.9, 0.16 * parlak, 0.16)):
        if f * r < SR / 2.2:
            s += a * np.sin(2 * np.pi * f * r * t) * np.exp(-t / (tau * k))
    vurus = rng.standard_normal(len(t)) * np.exp(-t / 0.004)
    b, a_ = signal.butter(2, min(6500.0, f * 9) / (SR / 2))
    s += 0.16 * signal.lfilter(b, a_, vurus)
    return s * np.minimum(1, t / 0.0018)


def celesta(f, dur=1.6, tau=1.1):
    """Yumusak celesta/glockenspiel: ust tonlar zayif (parlak degil, cam gibi degil)."""
    t = zaman(dur)
    s = np.zeros_like(t)
    for r, a, k in ((1.0, 1.0, 1.0), (2.76, 0.18, 0.5), (5.4, 0.06, 0.25)):
        if f * r < SR / 2.2:
            s += a * np.sin(2 * np.pi * f * r * t) * np.exp(-t / (tau * k))
    return s * np.minimum(1, t / 0.004)


def pad(freqlar, dur, zarf, agirlik=(1.0, 0.5, 0.28, 0.14, 0.07), tremolo=0.05):
    """Sicak pad (iki hafif detune ses, sol/sag). zarf: [(sn, genlik), ...] dogrusal."""
    t = zaman(dur)
    vl = np.zeros_like(t)
    vr = np.zeros_like(t)
    for f in freqlar:
        for h, w in enumerate(agirlik, start=1):
            if f * h < SR / 2.2:
                vl += w * np.sin(2 * np.pi * f * h * 0.9977 * t + 0.7 * h)
                vr += w * np.sin(2 * np.pi * f * h * 1.0023 * t + 1.3 * h)
    tr = 1 + tremolo * np.sin(2 * np.pi * 0.23 * t)
    pt, pa = zip(*zarf)
    env = np.interp(t, pt, pa)
    norm = 1.0 / (len(freqlar) * sum(agirlik))
    return vl * env * tr * norm, vr * env * tr * norm


def tokmak(f0, f1, dur, tau):
    t = zaman(dur)
    f = f1 + (f0 - f1) * np.exp(-t / 0.035)
    faz = 2 * np.pi * np.cumsum(f) / SR
    return np.sin(faz) * np.exp(-t / tau) * np.minimum(1, t / 0.004)


def nefes(dur, fc0, fc1, tepe_t):
    """Dusuk geciren yumusak hava (tiz hisirti degil): kesim frekansi fc0 -> fc1, zarf tepe_t'de tepe."""
    t = zaman(dur)
    x = rng.standard_normal(len(t))
    fc = fc0 * (fc1 / fc0) ** (t / dur)
    a = 1 - np.exp(-2 * np.pi * fc / SR)
    y = np.empty_like(x)
    p = 0.0
    for i in range(len(x)):
        p += a[i] * (x[i] - p)
        y[i] = p
    zarf = np.interp(t, [0, tepe_t, dur], [0, 1, 0]) ** 2
    return y * zarf


def yanki_ir(sure=1.6):
    """Sentetik plaka/oda yankisi: on gecikme 18 ms, alt frekans uzun, ust frekans kisa surer (karanlik kuyruk)."""
    t = zaman(sure)
    cikis = []
    for _ in range(2):
        hi = signal.lfilter(*signal.butter(2, 5200 / (SR / 2)), rng.standard_normal(len(t))) * np.exp(-t / 0.26)
        lo = signal.lfilter(*signal.butter(2, 1300 / (SR / 2)), rng.standard_normal(len(t))) * np.exp(-t / 0.55) * 0.8
        h = hi + lo
        h[: int(0.018 * SR)] = 0
        cikis.append(h / math.sqrt(np.sum(h ** 2)))
    return cikis


def lufs(L, R):
    """ITU-R BS.1770 bütünlesik ses seviyesi (K-agirlikli, mutlak -70 ve goreli -10 LU kapisi), 48 kHz."""
    b1 = [1.53512485958697, -2.69169618940638, 1.19839281085285]
    a1 = [1.0, -1.69065929318241, 0.73248077421585]
    b2 = [1.0, -2.0, 1.0]
    a2 = [1.0, -1.99004745483398, 0.99007225036621]

    def kw(x):
        return signal.lfilter(b2, a2, signal.lfilter(b1, a1, x))

    yl, yr = kw(L), kw(R)
    blk, hop = int(0.4 * SR), int(0.1 * SR)
    z = np.array([np.mean(yl[s:s + blk] ** 2) + np.mean(yr[s:s + blk] ** 2) for s in range(0, len(yl) - blk + 1, hop)])
    l = -0.691 + 10 * np.log10(z + 1e-12)
    g = z[l > -70]
    rel = -0.691 + 10 * np.log10(g.mean()) - 10
    return -0.691 + 10 * np.log10(z[l > max(-70, rel)].mean())


def uret(varyant):
    tam = varyant == "tam"
    m = Karisim()

    # ---- Atmosfer: gece drone'u (D3 + A3), gozlerin acildigi ana dogru yavasca buyur, sonra cözülür ----
    dl, dr = pad([hz("D3"), hz("A3")], 2.7, [(0, 0), (0.3, 0.25), (1.6, 0.5), (2.30, 0.8), (2.44, 0.0), (2.7, 0.0)])
    m.ekle_st(dl, dr, 0.0, amp=0.09, gonder=0.3)
    if tam:  # 0-0,55: dunya sessizlesir (yumusak, alcak frekansli hava inisi)
        m.ekle(nefes(0.8, 1800, 300, 0.2), 0.0, amp=0.10, gonder=0.2)

    # ---- 0,45 iki goz yildizi: iki yumusak nota (D5, A5; saf besli), sol ve sag yildiz ----
    m.ekle(mallet(hz("D5"), 1.8, 1.0), GORSEL["yildiz"] + 0.03, pan=-0.30, amp=0.30, gonder=0.3)
    m.ekle(mallet(hz("A5"), 1.6, 0.9), GORSEL["yildiz"] + 0.10, pan=0.30, amp=0.24, gonder=0.3)

    # ---- 0,85-1,95 yildizlar Hupo'ya toplanir: hizlanan pentatonik yukselis (D E F# A B D) ----
    if tam:
        notalar = ["D5", "E5", "F#5", "A5", "B5", "D6"]
        zamanlar = [1.00, 1.30, 1.55, 1.74, 1.88, 1.98]
        for i, (n, tz) in enumerate(zip(notalar, zamanlar)):
            m.ekle(mallet(hz(n), 1.0, 0.55), tz, pan=(-0.4 if i % 2 else 0.4), amp=0.09 + 0.012 * i, gonder=0.35)

    # ---- 2,55 ZIRVE: gozler acilir. Sicak D majör vurusu + pad + celesta + yumusak "kalp" tokmagi ----
    ta = GORSEL["goz_acilis"] + 0.017
    for k, n in enumerate(["D4", "A4", "D5", "F#5"]):
        m.ekle(mallet(hz(n), 1.6, 0.55), ta + 0.012 * k, pan=-0.2 + 0.13 * k, amp=0.34 - 0.02 * k, gonder=0.3)
    m.ekle(celesta(hz("A5"), 1.6, 0.7), ta + 0.02, pan=0.15, amp=0.12, gonder=0.4)
    m.ekle(tokmak(95, 55, 0.3, 0.09), ta, amp=0.42, gonder=0.1)
    p1l, p1r = pad([hz("D3"), hz("A3"), hz("F#4"), hz("A4")], 2.45,
                   [(0, 0), (0.12, 0.75), (0.40, 0.6), (0.5, 0.38), (0.95, 0.38), (1.30, 0.75), (1.45, 1.0), (1.9, 0.75), (2.2, 0.4), (2.45, 0.0)])
    m.ekle_st(p1l, p1r, 2.55, amp=0.12, gonder=0.3)

    # Inis (2,90) bilerek sessiz: zirve akoru ile imza arasinda bosluk birakir; her ses olayi bir gorsel olaya baglidir,
    # ama her gorsel olaya ses konmaz (ayiklama = netlik).

    # ---- 3,03 ... 3,415 imza: Hu-po-lin-go = A4, D5, F#5, A5 (D majör arpej, 4 hece = 4 nota) ----
    imza = [("A4", GORSEL["hu"] + 0.03), ("D5", GORSEL["po"] + 0.03), ("F#5", GORSEL["lin"] + 0.03), ("A5", GORSEL["go"] + 0.03)]
    for i, (n, tz) in enumerate(imza):
        m.ekle(mallet(hz(n), 1.8, 1.0 if i == 3 else 0.13, parlak=1.15), tz, pan=-0.10 + 0.07 * i, amp=0.52 if i == 3 else 0.46, gonder=0.22)
    # ---- 3,12-3,95 altin iz: pad yukselir (yukaridaki pad zarfi), yumusak hava ----
    if tam:
        m.ekle(nefes(0.95, 500, 2200, 0.7), 3.08, amp=0.05, gonder=0.3)

    # ---- 3,97 kapanis: D majör (D4 A4 F#5) + D6 celesta, ardindan "slogan" icin sessiz pad ----
    tk = GORSEL["ark_bitis"] + 0.02
    for k, n in enumerate(["D4", "A4", "F#5"]):
        m.ekle(mallet(hz(n), 2.4, 1.4), tk + 0.010 * k, pan=-0.1 + 0.1 * k, amp=0.34, gonder=0.3)
    m.ekle(celesta(hz("D6"), 1.8, 1.4), tk + 0.02, pan=0.1, amp=0.16, gonder=0.4)
    if tam:  # soldan saga harf parlamasina: sakin pentatonik yukselis (D E F# A B D)
        for i, n in enumerate(["D5", "E5", "F#5", "A5", "B5", "D6"]):
            m.ekle(celesta(hz(n), 1.0, 0.7), tk + 0.07 * (i + 1), pan=-0.5 + 0.2 * i, amp=0.07 + 0.008 * i, gonder=0.4)

    # ---- yanki, filtre, seviye ----
    ir = yanki_ir()
    ho = N + len(ir[0]) - 1
    wl = signal.fftconvolve(m.sL, ir[0])[:N]
    wr = signal.fftconvolve(m.sR, ir[1])[:N]
    L = m.L + 0.6 * wl
    R = m.R + 0.6 * wr
    bh, ah = signal.butter(2, 40 / (SR / 2), "high")
    bl, al = signal.butter(2, 14000 / (SR / 2), "low")
    L = signal.lfilter(bl, al, signal.lfilter(bh, ah, L))
    R = signal.lfilter(bl, al, signal.lfilter(bh, ah, R))
    giris, cikis = int(0.02 * SR), int(0.45 * SR)
    for x in (L, R):
        x[:giris] *= np.linspace(0, 1, giris)
        x[-cikis:] *= np.linspace(1, 0, cikis) ** 1.5

    hedef = -16.0
    for _ in range(4):  # kazanc + yumusak sinirlayici donguyle hedef sese oturtulur
        mevcut = lufs(L, R)
        g = 10 ** ((hedef - mevcut) / 20)
        L, R = L * g, R * g
        tepe = max(np.abs(L).max(), np.abs(R).max())
        if tepe > 0.84:
            k = 0.84 / tepe
            # tepe baskilama: yalniz asan ornekleri tanh ile yumusat
            L = np.where(np.abs(L) > 0.6, np.sign(L) * (0.6 + 0.24 * np.tanh((np.abs(L) - 0.6) / 0.24)), L)
            R = np.where(np.abs(R) > 0.6, np.sign(R) * (0.6 + 0.24 * np.tanh((np.abs(R) - 0.6) / 0.24)), R)
    return L, R


def yaz(L, R, yol):
    pcm = (np.stack([L, R], axis=1) * 32767).astype("<i2")
    yol.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(yol), "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())


def rapor(L, R, ad):
    tepe = max(np.abs(L).max(), np.abs(R).max())
    mono = (L + R) / 2
    spek = np.abs(np.fft.rfft(mono)) ** 2
    fr = np.fft.rfftfreq(len(mono), 1 / SR)
    toplam = spek.sum()
    print(f"[{ad}] sure={N / SR:.2f} sn  LUFS={lufs(L, R):.1f}  tepe={20 * math.log10(tepe):.1f} dBFS  "
          f"kirpma={int((np.abs(np.stack([L, R])) >= 0.9999).sum())}  "
          f">4kHz enerji={100 * spek[fr > 4000].sum() / toplam:.2f}%  <200Hz enerji={100 * spek[fr < 200].sum() / toplam:.1f}%")
    for ad_bant, lo, hi in (("200-1k", 200, 1000), ("1-2k", 1000, 2000), ("2-4k", 2000, 4000)):
        print(f"[{ad}] bant {ad_bant}: %{100 * spek[(fr >= lo) & (fr < hi)].sum() / toplam:.1f}")
    # kontrol: her hedef zamanda (gorunur kare zamani + gecikme) enerji, oncesine gore kac dB yukseliyor
    b, a = signal.butter(2, 250 / (SR / 2), "high")
    y = signal.lfilter(b, a, mono)

    def rms(t0, t1):
        return math.sqrt(np.mean(y[int(t0 * SR):int(t1 * SR)] ** 2) + 1e-12)

    hedefler = [("yildiz", GORSEL["yildiz"] + 0.03), ("goz_acilis", GORSEL["goz_acilis"] + 0.017),
                ("hu", GORSEL["hu"] + 0.03), ("po", GORSEL["po"] + 0.03), ("lin", GORSEL["lin"] + 0.03),
                ("go", GORSEL["go"] + 0.03), ("ark_bitis", GORSEL["ark_bitis"] + 0.02)]
    for ad_h, th in hedefler:
        yuk = 20 * math.log10(rms(th, th + 0.02) / rms(th - 0.03, th - 0.005))
        print(f"[{ad}]   {ad_h:10s} t={th:.3f}  yukselis={yuk:+5.1f} dB")


if __name__ == "__main__":
    secim = sys.argv[1] if len(sys.argv) > 1 else "ikisi"
    for v, ad in (("tam", "giris_ses.wav"), ("sade", "giris_ses_sade.wav")):
        if secim in (v, "ikisi"):
            L, R = uret(v)
            yaz(L, R, KLASOR / ad)
            rapor(L, R, v)
            print(f"yazildi: {KLASOR / ad}")

