"""HupoGiris filmi icin ses tasarimi: 5,0 sn, 48 kHz stereo WAV. Harici ses dosyasi yok; her ses sentezlenir.

Zamanlar docs/splash/GIRIS_FILMI.md §2 ile eslesir. Tonlar D majör pentatonik (marka sicakligi), en yuksek
tepe degeri -1,5 dBFS. Cikti: docs/splash/remotion/audio/giris_ses.wav
Kullanim: python -I docs/splash/remotion/tools/giris_ses_uret.py
"""
import math
import wave
from pathlib import Path

import numpy as np

SR = 48000
SURE = 5.0
N = int(SR * SURE)
CIKTI = Path(__file__).resolve().parents[1] / "audio" / "giris_ses.wav"
rng = np.random.default_rng(7)

L = np.zeros(N)
R = np.zeros(N)


def zaman(sure):
    return np.arange(int(sure * SR)) / SR


def yerlestir(sig, t0, pan=0.0, amp=1.0):
    """Sesi t0 saniyesine, stereo konumla (-1 sol, +1 sag) ekler; sure asarsa kirpar."""
    i0 = int(t0 * SR)
    if i0 >= N:
        return
    n = min(len(sig), N - i0)
    aci = (pan + 1) * math.pi / 4
    L[i0:i0 + n] += sig[:n] * amp * math.cos(aci)
    R[i0:i0 + n] += sig[:n] * amp * math.sin(aci)


def cift(f, sure, tau, kat=(1, 0.35, 0.2, 0.08), atak=0.003):
    """Can sesi: kismi tonlar (2,01 / 2,76 / 5,4 kat), ust tonlar daha cabuk soner."""
    t = zaman(sure)
    s = np.zeros_like(t)
    for k, a in zip((1, 2.01, 2.76, 5.4), kat):
        s += a * np.sin(2 * np.pi * f * k * t) * np.exp(-t * k / tau)
    return s * np.minimum(1, t / atak)


def tokmak(f0, f1, sure, tau, atak=0.002):
    """Kisa, asagi kayan ton: goz 'pirt'i (f0 > f1 yukari kayar) ve inis tokmagi."""
    t = zaman(sure)
    f = f1 + (f0 - f1) * np.exp(-t / 0.03)
    faz = 2 * np.pi * np.cumsum(f) / SR
    return np.sin(faz) * np.exp(-t / tau) * np.minimum(1, t / atak)


def ruzgar(sure, f0, f1):
    """Filtreli gurultu: parlakligi f0'dan f1'e yukselen hava/altin suplirmesi (tek kutuplu alcak geciren, sinusoidal zarf)."""
    t = zaman(sure)
    x = rng.standard_normal(len(t))
    fc = f0 * (f1 / f0) ** (t / sure)
    a = 1 - np.exp(-2 * np.pi * fc / SR)
    y = np.empty_like(x)
    onceki = 0.0
    for i in range(len(x)):
        onceki += a[i] * (x[i] - onceki)
        y[i] = onceki
    zarf = np.sin(np.pi * t / sure) ** 2
    return y * zarf


def ped(frekanslar, sure, amp, atak=0.5, salim=0.35):
    """Sicak akor yastigi; yavas giris, yumusak cikis."""
    t = zaman(sure)
    s = sum(np.sin(2 * np.pi * f * t + 0.4 * i) for i, f in enumerate(frekanslar)) / len(frekanslar)
    zarf = np.minimum(1, t / atak) * np.minimum(1, (sure - t) / salim)
    return amp * s * zarf


def kaydir(x, s):
    k = int(s * SR)
    out = np.zeros_like(x)
    out[k:] = x[:-k]
    return out


# ---------- 0,45 yildiz atesi: iki can sesi (E6, B6) ----------
yerlestir(cift(1318.51, 1.8, 1.1), 0.45, pan=-0.35, amp=0.30)
yerlestir(cift(1975.53, 1.5, 0.9), 0.52, pan=0.35, amp=0.20)

# ---------- 0,85-1,95 isik yukselisi ve kivilcimlar ----------
yerlestir(ruzgar(1.1, 300, 6500), 0.85, amp=0.10)
for k, (zaman_s, f) in enumerate([(1.02, 2637.02), (1.20, 3136.0), (1.38, 3951.07),
                                  (1.52, 5274.04), (1.71, 6272.0), (1.84, 7902.13)]):
    yerlestir(cift(f, 0.7, 0.30, kat=(1, 0.3, 0.1, 0.0)), zaman_s, pan=(-0.6 if k % 2 else 0.6), amp=0.06)

# ---------- 2,48 goz acilisi (pirt + hafif can) ----------
yerlestir(tokmak(1300, 700, 0.12, 0.05), 2.48, amp=0.28)
yerlestir(cift(1567.98, 1.2, 0.9), 2.50, amp=0.15)

# ---------- 2,50-2,92 ziplama ve inis tokmagi ----------
yerlestir(tokmak(140, 55, 0.30, 0.08), 2.92, amp=0.40)
yerlestir(ruzgar(0.5, 900, 3500), 2.55, amp=0.05)

# ---------- 3,00-3,50 harf tiklari: D majör pentatonik, soldan saga yukselen ----------
harf_notalari = [587.33, 659.25, 739.99, 880.0, 987.77, 1174.66, 1318.51, 1479.98, 1760.0]  # D5..A6
for i, f in enumerate(harf_notalari):
    yerlestir(cift(f, 0.6, 0.22, kat=(1, 0.25, 0.08, 0.0)), 3.00 + i * 0.055,
              pan=-0.7 + 1.4 * i / (len(harf_notalari) - 1), amp=0.13)

# ---------- 3,12-3,95 altin iz: suplirme + akor parlamasi ----------
yerlestir(ruzgar(0.85, 1800, 7500), 3.12, amp=0.13)
for f in (1174.66, 1479.98, 1760.0):
    yerlestir(cift(f, 2.0, 1.4), 3.95, amp=0.14)

# ---------- 3,90-5,00 slogan yastigi (D majör) ----------
yerlestir(ped([146.83, 220.0, 369.99], 1.1, amp=0.07), 3.90, amp=1.0)

# ---------- hafif mekan (iki kisa gecikme), kenar yumusatma, normalizasyon ----------
L0, R0 = L.copy(), R.copy()
for kazanc, gecikme in ((0.22, 0.031), (0.14, 0.067), (0.08, 0.113)):
    L += kazanc * kaydir(L0, gecikme)
    R += kazanc * kaydir(R0, gecikme)

giris = int(0.02 * SR)
cikis = int(0.25 * SR)
L[:giris] *= np.linspace(0, 1, giris)
R[:giris] *= np.linspace(0, 1, giris)
L[-cikis:] *= np.linspace(1, 0, cikis)
R[-cikis:] *= np.linspace(1, 0, cikis)

tepe = max(np.abs(L).max(), np.abs(R).max())
kazanc = 0.84 / tepe
L *= kazanc
R *= kazanc

pcm = (np.stack([L, R], axis=1) * 32767).astype("<i2")
CIKTI.parent.mkdir(parents=True, exist_ok=True)
with wave.open(str(CIKTI), "wb") as w:
    w.setnchannels(2)
    w.setsampwidth(2)
    w.setframerate(SR)
    w.writeframes(pcm.tobytes())

# ---------- kontrol: tepe, sure ve 0,5 sn pencereli RMS (dinlemeden zamanlama kontrolu) ----------
tepe_db = 20 * math.log10(0.84)
print(f"sure={N / SR:.2f} sn  tepe={tepe_db:.1f} dBFS  kirpma={int((np.abs(pcm) >= 32767).sum())} ornek")
for s in np.arange(0, SURE, 0.5):
    a, b = int(s * SR), int((s + 0.5) * SR)
    rms = math.sqrt(np.mean(L[a:b] ** 2 + R[a:b] ** 2) / 2)
    cubuk = "#" * int(min(60, max(0, 20 * math.log10(rms + 1e-9) + 60)))
    print(f"{s:4.1f}-{s + 0.5:4.1f} sn  {20 * math.log10(rms + 1e-9):7.1f} dB  {cubuk}")
print(f"yazildi: {CIKTI} ({CIKTI.stat().st_size} bayt)")
