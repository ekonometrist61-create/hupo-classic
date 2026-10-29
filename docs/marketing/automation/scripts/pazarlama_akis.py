"""Pazarlama içerik durum makinesi (dosya tabanlı, ağ kodu YOK).

Durumlar: taslak -> marka-denetimi -> insan-onayi -> planlandi -> yayinlandi
Güvence:
  * Bu betik hiçbir platforma bağlanmaz ve yayın yapmaz. 'yayinlandi' yalnız İNSAN yayınladıktan sonra
    kanıt (url/yayin_tarihi) ile kaydedilir.
  * insan-onayi: onaylayan + onay_tarihi + metnin SHA-256 özeti gerekir; metin sonradan değişirse onay geçersiz.
  * Atlama yok: her geçiş yalnız bir sonraki duruma.
  * DRY_RUN=1 (varsayılan) iken kayıt dosyaya yazılmaz, yalnız sonuç yazdırılır.
Kullanım:
  DRY_RUN=1 python pazarlama_akis.py gec <gonderi.json> <hedef_durum> [--onaylayan AD] [--kanit-url URL]
  python pazarlama_akis.py lint <gonderi.json> <olgular.json>
  python pazarlama_akis.py utm <taban> <kaynak> <kampanya> <icerik>
"""
import hashlib
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import sosyal_lint as L  # noqa: E402

SIRA = ["taslak", "marka-denetimi", "insan-onayi", "planlandi", "yayinlandi"]


class AkisHatasi(Exception):
    pass


def dry_run() -> bool:
    return os.environ.get("DRY_RUN", "1") != "0"


def ozet(metin: str) -> str:
    return hashlib.sha256(metin.encode("utf-8")).hexdigest()


def gec(gonderi: dict, hedef: str, olgular=None, onaylayan=None, kanit_url=None, simdi=None) -> dict:
    """Bir sonraki duruma geçirir. Kuralı ihlal ederse AkisHatasi."""
    if hedef not in SIRA:
        raise AkisHatasi(f"bilinmeyen durum: {hedef}")
    mevcut = gonderi.get("durum", "taslak")
    if mevcut not in SIRA:
        raise AkisHatasi(f"bilinmeyen mevcut durum: {mevcut}")
    if SIRA.index(hedef) != SIRA.index(mevcut) + 1:
        raise AkisHatasi(f"geçiş atlaması/geri dönüş yok: {mevcut} -> {hedef}")
    yeni = dict(gonderi)
    zaman = (simdi or datetime.now(timezone.utc)).isoformat(timespec="seconds")
    metin = gonderi.get("metin", "")

    if hedef == "marka-denetimi":
        if not metin.strip():
            raise AkisHatasi("metin boş")
        gecti, bulgular = L.lint(metin, olgular=olgular, kanit=gonderi.get("kanit", ""))
        yeni["lint"] = {"gecti": gecti, "bulgular": bulgular, "zaman": zaman}
        if not gecti:
            raise AkisHatasi("lint başarısız: " + "; ".join(b["kod"] for b in bulgular if b["ciddiyet"] == "HATA"))

    elif hedef == "insan-onayi":
        # Lint yeniden: onay anında metin hâlâ temiz olmalı
        gecti, bulgular = L.lint(metin, olgular=olgular, kanit=gonderi.get("kanit", ""))
        if not gecti:
            raise AkisHatasi("onay öncesi lint başarısız")
        if not onaylayan or not str(onaylayan).strip():
            raise AkisHatasi("onaylayan zorunlu (insan)")
        if str(onaylayan).strip().lower() in ("ajan", "ai", "mar-oto-ai", "otomatik", "bot"):
            raise AkisHatasi("onaylayan insan olmalı")
        yeni["onay"] = {"onaylayan": str(onaylayan).strip(), "onay_tarihi": zaman, "metin_ozeti": ozet(metin)}

    elif hedef == "planlandi":
        onay = gonderi.get("onay")
        if not onay or onay.get("metin_ozeti") != ozet(metin):
            raise AkisHatasi("geçerli onay yok (metin onaydan sonra değişmiş olabilir)")
        if not gonderi.get("planlanan_tarih"):
            raise AkisHatasi("planlanan_tarih zorunlu")

    elif hedef == "yayinlandi":
        onay = gonderi.get("onay")
        if not onay or onay.get("metin_ozeti") != ozet(metin):
            raise AkisHatasi("onaysız veya değişmiş metin yayınlandı olarak işaretlenemez")
        if not kanit_url:
            raise AkisHatasi("yayın kanıtı (insanın yayınladığı gönderi URL'si) zorunlu")
        yeni["yayin"] = {"kanit_url": kanit_url, "kaydeden_zaman": zaman, "not": "yayın platform aracında insan eliyle yapıldı"}

    yeni["durum"] = hedef
    yeni.setdefault("gecmis", []).append({"durum": hedef, "zaman": zaman})
    return yeni


def kaydet(yol: Path, gonderi: dict):
    if dry_run():
        print(f"[DRY_RUN] yazılmadı: {yol} -> durum={gonderi['durum']}")
        return
    yol.write_text(json.dumps(gonderi, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"yazıldı: {yol} -> durum={gonderi['durum']}")


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    komut = argv[1]
    if komut == "utm":
        print(L.utm_uret(argv[2], argv[3], argv[4], argv[5]))
        return 0
    if komut == "lint":
        g = json.loads(Path(argv[2]).read_text(encoding="utf-8"))
        o = L.olgular_yukle(argv[3])
        gecti, b = L.lint(g.get("metin", ""), olgular=o, kanit=g.get("kanit", ""))
        print(json.dumps({"gecti": gecti, "bulgular": b}, ensure_ascii=False, indent=2))
        return 0 if gecti else 1
    if komut == "gec":
        yol = Path(argv[2])
        g = json.loads(yol.read_text(encoding="utf-8"))
        hedef = argv[3]
        onaylayan = kanit_url = None
        olgular = None
        if "--onaylayan" in argv:
            onaylayan = argv[argv.index("--onaylayan") + 1]
        if "--kanit-url" in argv:
            kanit_url = argv[argv.index("--kanit-url") + 1]
        if "--olgular" in argv:
            olgular = L.olgular_yukle(argv[argv.index("--olgular") + 1])
        try:
            yeni = gec(g, hedef, olgular=olgular, onaylayan=onaylayan, kanit_url=kanit_url)
        except AkisHatasi as e:
            print(f"REDDEDİLDİ: {e}")
            return 1
        kaydet(yol, yeni)
        return 0
    print("bilinmeyen komut")
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
