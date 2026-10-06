"""rembg çıktısı (şeffaf PNG) Hupo pozlarını uygulamanın RGBA WebP varlıklarına çevirir.

İfade pozları kare tuvale (alt ortalı) oturtulur; böylece Hupo bileşeni tek oran kullanır.
Çalıştır: python tools/hupo_pozlari_donustur.py
"""
from pathlib import Path

from PIL import Image

KAYNAK = Path(r"C:\Users\cengi\OneDrive\Desktop\Hupo Tasarim\rembg-output")
HEDEF = Path(__file__).resolve().parent.parent / "mobile-app" / "assets" / "hupo"
KARE = 512

IFADE = {
    "Acele-Et---Hupo": "acele",
    "Adim-adim-gidelim---Hupo": "adim_adim",
    "Ahaaa---Hupo": "ahaaa",
    "Bir-daha-dene---Hupo": "bir_daha_dene",
    "Cok-yaklastin---Hupo": "cok_yaklastin",
    "Cozum---Hupo": "cozum",
    "Dogru---Hupo": "dogru",
    "Dusunuyor---Hupo": "dusunuyor",
    "Gunluk-hedef-tamamlandi---Hupo": "gunluk_hedef",
    "Harika---Hupo": "harika",
    "Hazir-misin---Hupo": "hazir_misin",
    "Hosgeldin---Hupo": "hosgeldin",
    "Ip-ucu-ister-misin---Hupo": "ipucu_ister",
    "Ipucu-Buldu---Hupo": "ipucu_buldu",
    "Konu-tamamlandi---Hupo": "konu_tamamlandi",
    "Merak-Ediyor---Hupo": "merak_ediyor",
    "Sasirmis---Hupo": "sasirmis",
    "Seri-Devam-Ediyor---Hupo": "seri_devam",
    "Seri-Tehlikede---Hupo": "seri_tehlikede",
    "Uzgun---Hupo": "uzgun",
    "Zor-soruydu---Hupo": "zor_soruydu",
}
UYGULAMA = {
    "Hero-Splash-Hupo.-Uygulama-ilk-acildiginda-gorulen-tam-boy-Hupo": ("hero_splash", 900),
    "soru-ekrani-ana-pozu.-Cocuk-soruyu-cozerken-ekranin-kenarinda-yasayacak-sakin-Hupo": ("rehber", KARE),
    "soru-ekrani-ana-pozu.-Cocuk-soruyu-cozerken-ekranin-kenarinda-yasayacak-sakin-Hupo.-sola-bakan": ("rehber_sol", KARE),
}


def kirp(im: Image.Image) -> Image.Image:
    kutu = im.getchannel("A").point(lambda a: 255 if a > 8 else 0).getbbox()
    return im.crop(kutu)


def kareye_oturt(im: Image.Image, kenar: int) -> Image.Image:
    im = kirp(im)
    im.thumbnail((kenar, kenar), Image.LANCZOS)
    tuval = Image.new("RGBA", (kenar, kenar), (0, 0, 0, 0))
    tuval.alpha_composite(im, ((kenar - im.width) // 2, kenar - im.height))
    return tuval


def main() -> None:
    for alt, esle in (("ifade", IFADE), ("app-ici", UYGULAMA)):
        for ad, hedef in esle.items():
            src = KAYNAK / alt / f"{ad}.png"
            if not src.exists():
                print("YOK", src.name, flush=True)
                continue
            im = Image.open(src).convert("RGBA")
            if alt == "ifade":
                cikti, dizin = kareye_oturt(im, KARE), "ifade"
            else:
                slug, kenar = hedef
                if slug == "hero_splash":
                    cikti = kirp(im)
                    cikti.thumbnail((kenar, kenar), Image.LANCZOS)
                else:
                    cikti = kareye_oturt(im, kenar)
                hedef, dizin = slug, "uygulama"
            yol = HEDEF / dizin / f"{hedef}.webp"
            cikti.save(yol, "WEBP", quality=85, method=6)
            print(f"{dizin}/{hedef}.webp {cikti.size} {yol.stat().st_size // 1024} KB", flush=True)


if __name__ == "__main__":
    main()
