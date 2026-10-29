"""Sistem (native) splash varlıklarını Flutter sahnesinin ilk karesiyle eşleştirerek üretir.

Kural (bkz. kNativeSplashHupoBoyu, lib/widgets/splash/hupo_signature_entrance.dart):
  * Kaynak: assets/hupo/uygulama/hero_splash.webp (TÜM tuval; kırpma yok, Flutter'daki
    BoxFit.contain ile aynı kural).
  * Hupo'nun en uzun kenarı 144 dp; 288x288 dp saydam tuvalin ortasında.
  * Android: res/drawable-*dpi/splash_hupo.webp (Android 12+ ikonu ve eski launch arka planı).
  * iOS: Runner/Assets.xcassets/LaunchImage.imageset (1x/2x/3x, 288x288 pt).

Kullanım (repo kökünden):
  pip install opencv-python-headless numpy
  python mobile-app/tool/splash_varliklari_uret.py
"""
import pathlib
import sys

import cv2
import numpy as np

KOK = pathlib.Path(__file__).resolve().parents[1]
KAYNAK = KOK / "assets" / "hupo" / "uygulama" / "hero_splash.webp"
HUPO_DP = 144
TUVAL_DP = 288

ANDROID = {  # klasör eki -> yoğunluk çarpanı
    "mdpi": 1.0,
    "hdpi": 1.5,
    "xhdpi": 2.0,
    "xxhdpi": 3.0,
    "xxxhdpi": 4.0,
}
IOS = {"LaunchImage.png": 1, "LaunchImage@2x.png": 2, "LaunchImage@3x.png": 3}


def uret(kaynak: np.ndarray, carpan: float) -> np.ndarray:
    tuval = int(round(TUVAL_DP * carpan))
    hedef = HUPO_DP * carpan
    h, w = kaynak.shape[:2]
    olcek = hedef / max(h, w)
    nw, nh = max(1, int(round(w * olcek))), max(1, int(round(h * olcek)))
    kucuk = cv2.resize(kaynak, (nw, nh), interpolation=cv2.INTER_AREA)
    cikti = np.zeros((tuval, tuval, 4), dtype=np.uint8)
    x, y = (tuval - nw) // 2, (tuval - nh) // 2
    cikti[y : y + nh, x : x + nw] = kucuk
    return cikti


def main() -> int:
    img = cv2.imread(str(KAYNAK), cv2.IMREAD_UNCHANGED)
    if img is None:
        print(f"Kaynak okunamadı: {KAYNAK}", file=sys.stderr)
        return 1
    if img.shape[2] == 3:  # alfa yoksa ekle
        img = cv2.cvtColor(img, cv2.COLOR_BGR2BGRA)
    print(f"kaynak {img.shape[1]}x{img.shape[0]}")

    for ek, carpan in ANDROID.items():
        klasor = KOK / "android" / "app" / "src" / "main" / "res" / f"drawable-{ek}"
        klasor.mkdir(parents=True, exist_ok=True)
        # WebP (kayıplı, alfalı): tek seferlik splash için PNG'den çok küçük; APK bütçesi.
        cv2.imwrite(
            str(klasor / "splash_hupo.webp"),
            uret(img, carpan),
            [cv2.IMWRITE_WEBP_QUALITY, 90],
        )
    ios_klasor = KOK / "ios" / "Runner" / "Assets.xcassets" / "LaunchImage.imageset"
    for ad, carpan in IOS.items():
        cv2.imwrite(str(ios_klasor / ad), uret(img, carpan))
    print("Android ve iOS splash varlıkları üretildi.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
