"""40 karakter görselini şeffaf (RGBA) WebP yapar. Ara çıktı: OneDrive'daki hazırlık klasörü.

Model: isnet-anime (çizgi film karakterlerinde u2net'ten çok daha iyi; bria-rmbg CPU'da çok yavaş).
Son işlem: düşük alfayı sıfırla, küçük kopuk parçaları (duman/ışık tozu) ele, kenarı yumuşat.
Kaynak dosyalara dokunmaz; kontrol edildikten sonra assets/characters/ üzerine kopyalanır.
Yeniden çalıştırılabilir: var olan çıktılar atlanır.
Çalıştır: python tools/rembg_karakterler.py
"""
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter
from rembg import new_session, remove
from scipy import ndimage

KAYNAK = Path(__file__).resolve().parent.parent / "mobile-app" / "assets" / "characters"
HEDEF = Path(r"C:\Users\cengi\OneDrive\Desktop\Hupo Tasarim\rembg-output\karakterler-isnet")
BOYUT = 640
ALFA_ESIK = 40          # bunun altı tamamen saydam
PARCA_ORANI = 0.04      # en büyük parçanın alanının %4'ünden küçük kopuk parçalar atılır


def temizle(alfa: np.ndarray) -> np.ndarray:
    alfa = np.where(alfa < ALFA_ESIK, 0, alfa).astype(np.uint8)
    maske = alfa > 128
    etiket, adet = ndimage.label(maske)
    if adet > 1:
        alanlar = ndimage.sum(maske, etiket, index=range(1, adet + 1))
        tut = [i + 1 for i, a in enumerate(alanlar) if a >= alanlar.max() * PARCA_ORANI]
        kalan = np.isin(etiket, tut)
        # Tutulan parçaların çevresindeki yumuşak kenarı da koru.
        kalan = ndimage.binary_dilation(kalan, iterations=6)
        alfa = np.where(kalan, alfa, 0).astype(np.uint8)
    return alfa


def main() -> None:
    dosyalar = sorted(KAYNAK.rglob("*.webp"))
    print(f"{len(dosyalar)} dosya", flush=True)
    oturum = new_session("isnet-anime")
    for i, src in enumerate(dosyalar, 1):
        cikti = HEDEF / src.relative_to(KAYNAK)
        if cikti.exists():
            print(f"[{i}/{len(dosyalar)}] atla {src.name}", flush=True)
            continue
        try:
            im = Image.open(src).convert("RGB")
            sonuc = remove(im, session=oturum).convert("RGBA")
            alfa = temizle(np.array(sonuc.getchannel("A")))
            a = Image.fromarray(alfa).filter(ImageFilter.GaussianBlur(0.8))
            sonuc.putalpha(a)
            kutu = sonuc.getchannel("A").point(lambda v: 255 if v > 8 else 0).getbbox()
            if kutu:
                sonuc = sonuc.crop(kutu)
            tuval = max(sonuc.size)
            kare = Image.new("RGBA", (tuval, tuval), (0, 0, 0, 0))
            kare.alpha_composite(sonuc, ((tuval - sonuc.width) // 2, tuval - sonuc.height))
            kare.thumbnail((BOYUT, BOYUT), Image.LANCZOS)
            cikti.parent.mkdir(parents=True, exist_ok=True)
            kare.save(cikti, "WEBP", quality=88, method=6)
            print(f"[{i}/{len(dosyalar)}] OK {src.name} {cikti.stat().st_size // 1024} KB", flush=True)
        except Exception as e:  # noqa: BLE001
            print(f"[{i}/{len(dosyalar)}] HATA {src.name}: {e}", flush=True)
    print("bitti", flush=True)


if __name__ == "__main__":
    main()
